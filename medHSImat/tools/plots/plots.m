% ======================================================================
%> @brief plots is a class that holds all functions for figure plotting.
%
% For details check https://foxelas.github.io/medHSIdocs/classplots.html
% ======================================================================
classdef plots
    methods (Static)

        %======================================================================
        %> @brief plots.Apply runs a plotting function.
        %>
        %> The function should take the figure handle as last argument.
        %>
        %> @b Usage
        %>
        %> @code
        %> [varargout] = plots.Apply(1, '\temp\folder\name.png', @PlotSpectra, spectra);
        %>
        %> [varargout] = plots.Apply(1, [], @PlotSpectra, spectra);
        %> @endcode
        %>
        %> @param fig [int] | The figure handle
        %> @param plotPath [char] | The path for saving plot figures
        %> @param funcHandle [Function Handle] | Handle of the target function to be applied
        %> @param varargin [Cell array] | The arguments necessary for the target function
        %>
        %> @retval varargout [Cell array] | The return values of the target function
        %======================================================================
        function [varargout] = Apply(fig, plotPath, funcHandle, varargin)

            if isnumeric(fig) && ~isempty(fig)
                %disp('Check if no overlaps appear and correct fig is saved.')
                figure(fig);
                clf(fig);
            else
                fig = gcf;
            end

            if ~isempty(plotPath)
                config.SetSetting('PlotPath', plotPath);
            end

            newVarargin = varargin;
            expectedArgs = nargin(funcHandle);
            for i = (length(newVarargin) + 1):(expectedArgs - 1)
                newVarargin{i} = [];
            end
            newVarargin{length(newVarargin)+1} = fig;

            if nargout(funcHandle) > 0
                varargout{:} = funcHandle(newVarargin{:});
            else
                funcHandle(newVarargin{:});
                varargout{:} = {};
            end
        end

        %======================================================================
        %> @brief plots.SavePlot saves a figure plots.
        %>
        %> The plot name should be set beforehand in config::[PlotPath].
        %>
        %> @b Usage
        %>
        %> @code
        %> plots.SavePlot(1);
        %> plots.SavePlot(1, '\\temp\\folder\\name.png');
        %> @endcode
        %>
        %> @param fig [int] | The figure handle
        %> @param plotPath [char] | The path for saving plot figures
        %======================================================================
        function [] = SavePlot(fig, plotPath)
            if nargin > 1
                config.SetSetting('PlotPath', plotPath);
            end
            SavePlot(fig);
        end

        %======================================================================
        %> @brief plots.GetLineColorMap returns a linecolor map based on the style.
        %>
        %> Available keys are:
        %> 'class': {'Benign', 'Atypical', 'Malignant'}
        %> 'type': {'Unfixed', 'Fixed', 'Sectioned'}
        %> 'sample': {'0037', '0045', '0053', '0059', '0067', '9913', '9933', '9940', '9949', '9956'}
        %> 'custom': user-defined
        %> default: {'1', '2', '3', '4', '5', '6', '7', '8', '9', '10'}
        %>
        %> @b Usage
        %>
        %> @code
        %> lineColorMap = plots.GetLineColorMap('class');
        %> @endcode
        %>
        %> @param style [char] | The line group style. Default: 'class'.
        %> @param names [cell array] | Optional: The line group names
        %>
        %> @retval lineColorMap [map] | The line color map
        %======================================================================
        function [lineColorMap] = GetLineColorMap(style, names)

            if (nargin < 1)
                style = 'class';
            end

            switch style
                case 'class'
                    key = {'Benign', 'Atypical', 'Malignant'};
                    value = {'g', 'm', 'r'};
                case 'type'
                    key = {'Unfixed', 'Fixed', 'Sectioned'};
                    value = {'g', 'm', 'r'};
                case 'sample'
                    key = {'0037', '0045', '0053', '0059', '0067', '9913', '9933', '9940', '9949', '9956'};
                    value = jet(10);
                case 'custom'
                    key = names;
                    key = unique(key);
                    value = jet(length(key));
                otherwise
                    key = {'1', '2', '3', '4', '5', '6', '7', '8', '9', '10'};
                    value = jet(10);
            end


            if ~isvector(value)
                v = cell(size(value, 1), 1);
                for i = 1:size(value, 1)
                    v{i} = value(i, :);
                end
                value = v;
            end

            if size(value, 1) == 1
                value = {value};
            end
            lineColorMap = containers.Map(key, value);
        end

        %======================================================================
        %> @brief plots.BandStatistics plots statistics among spectral bands.
        %>
        %> For more details check @c function PlotBandStatistics .
        %>
        %> @b Usage
        %>
        %> @code
        %> [imCorr] = plots.BandStatistics(fig, '\\temp\\folder\\name.png', inVectors, 'correlation');
        %>
        %> [imCorr] = plots.BandStatistics(fig, '\\temp\\folder\\name.png', inVectors, 'covariance');
        %> @endcode
        %>
        %> @param fig [int] | The figure handle
        %> @param plotPath [char] | The path for saving plot figures
        %> @param inVectors [numeric array] | The input vectors
        %> @param statistic [char] | The statistic name
        %>
        %> @retval imCorr [numeric array] | The statistics values
        %======================================================================
        function [imCorr] = BandStatistics(fig, plotPath, varargin)
            [imCorr] = plots.Apply(fig, plotPath, @PlotBandStatistics, varargin{:});
        end

        %======================================================================
        %> @brief plots.Spectra plots multiple spectra together.
        %>
        %> For more details check @c function PlotSpectra .
        %>
        %> @b Usage
        %>
        %> @code
        %> plots.Spectra(fig, '\\temp\\folder\\name.png', spectra, wavelengths, names, figTitle, markers);
        %>
        %> plots.Spectra(fig, '\\temp\\folder\\name.png', spectra);
        %> @endcode
        %>
        %> @param fig [int] | The figure handle
        %> @param plotPath [char] | The path for saving plot figures
        %> @param spectra [numeric array] | The input vectors
        %> @param wavelengths [numeric array] | The wavlength values
        %> @param names [cell array] | The curve names
        %> @param figTitle [char] | The figure title
        %> @param markers [cell array] | The curve markers
        %======================================================================
        function [] = Spectra(fig, plotPath, varargin)
            plots.Apply(fig, plotPath, @PlotSpectra, varargin{:});
        end

        %======================================================================
        %> @brief plots.AverageSpectrum plots average spectra using a promt for custom mask selection.
        %>
        %> Need to set config[SaveFolder] for saving purposes.
        %> For more details check @c function PlotAverageSpectrum .
        %>
        %> @b Usage
        %>
        %> @code
        %> plots.AverageSpectrum(fig, '\\temp\\folder\\name.png', hsIm, figTitle);
        %> @endcode
        %>
        %> @param fig [int] | The figure handle
        %> @param plotPath [char] | The path for saving plot figures
        %> @param hsIm [hsi] | An instance of the hsi class
        %> @param figTitle [char] | The figure title
        %======================================================================
        function [] = AverageSpectrum(fig, plotPath, varargin)
            plots.Apply(fig, plotPath, @PlotAverageSpectrum, varargin{:});
        end

        %======================================================================
        %> @brief plots.Components plots the components of a hyperspectral image.
        %>
        %> For more details check @c function PlotComponents .
        %>
        %> @b Usage
        %>
        %> @code
        %> plots.Components(hsIm, pcNum, figStart, '\\temp\\folder\\name.png');
        %> @endcode
        %>
        %> @param hsIm [hsi] | An instance of the hsi class
        %> @param pcNum [int] | The number of components
        %> @param fig [int] | The figure handle
        %> @param plotBasePath [char] | The base path for saving plot figures
        %======================================================================
        function [] = Components(varargin)
            PlotComponents(varargin{:});
        end

        %======================================================================
        %> @brief plots.Eigenvectors plots the eigenvectors of a decomposition.
        %>
        %> For more details check @c function PlotEigenvectors .
        %>
        %> @b Usage
        %>
        %> @code
        %> plots.Eigenvectors(fig, '\\temp\\folder\\name.png', coeff, xValues, pcNum);
        %> @endcode
        %>
        %> @param fig [int] | The figure handle
        %> @param plotPath [char] | The path for saving plot figures
        %> @param eigenvec [numeric array] | The eigenvectors
        %> @param xValues [numeric vector] | The x-axis values
        %> @param pcNum [int] | Optional: The number of components. Default: 3
        %======================================================================
        function [] = Eigenvectors(fig, plotPath, varargin)
            plots.Apply(fig, plotPath, @PlotEigenvectors, varargin{:});
        end

        %======================================================================
        %> @brief plots.Overlay applies a mask over a base image.
        %>
        %> For more details check @c function PlotOverlay .
        %>
        %> @b Usage
        %>
        %> @code
        %> plots.Overlay(fig, '\\temp\\folder\\name.png', baseIm, topIm, figTitle);
        %> @endcode
        %>
        %> @param fig [int] | The figure handle
        %> @param plotPath [char] | The path for saving plot figures
        %> @param baseIm [numeric array] | The base image
        %> @param topIm [numeric array] | The top image
        %> @param figTitle [char] | The figure title
        %======================================================================
        function [] = Overlay(fig, plotPath, varargin)
            plots.Apply(fig, plotPath, @PlotOverlay, varargin{:});
        end

        %======================================================================
        %> @brief plots.Pair displays a pair of images side by side.
        %>
        %> @b Usage
        %>
        %> @code
        %> plots.Pair(fig, '\\temp\\folder\\name.png', baseIm, topIm, figTitle);
        %> @endcode
        %>
        %> @param fig [int] | The figure handle
        %> @param plotPath [char] | The path for saving plot figures
        %> @param img1 [numeric array] | The left image
        %> @param img2 [numeric array] | The right image
        %> @param figTitle [char] | The figure title
        %======================================================================
        function [] = Pair(fig, plotPath, img1, img2, figTitle)
            figHandle = figure(fig);
            clf;
            imshowpair(img1, img2, 'Scaling', 'joint');
            if nargin > 4
                title(figTitle);
            end

            figHandle.Position = [50, 50, 550, 550];
            plots.SavePlot(figHandle, plotPath);
        end

        %======================================================================
        %> @brief plots.Show displays an image.
        %>
        %> @b Usage
        %>
        %> @code
        %> plots.Show(fig, '\\temp\\folder\\name.png', img, figTitle);
        %> @endcode
        %>
        %> @param fig [int] | The figure handle
        %> @param plotPath [char] | The path for saving plot figures
        %> @param img [numeric array] | The left image
        %> @param figTitle [char] | The figure title
        %======================================================================
        function [] = Show(fig, plotPath, img, figTitle)
            figHandle = figure(fig);
            clf;
            imshow(img);
            if nargin > 3
                title(figTitle);
            end
            plots.SavePlot(figHandle, plotPath);
        end

        %======================================================================
        %> @brief plots.Export exports an image using imwrite.
        %>
        %> @b Usage
        %>
        %> @code
        %> plots.Show(fig, '\\temp\\folder\\name.png', img);
        %> @endcode
        %>
        %> @param fig [int] | The figure handle
        %> @param plotPath [char] | The path for saving plot figures
        %> @param img [numeric array] | The left image
        %======================================================================
        function [] = Export(fig, plotPath, img)
            figHandle = figure(fig);
            clf;
            imshow(img);
            %             Export(figHandle, plotPath);
            imwrite(img, plotPath);
        end


        %======================================================================
        %> @brief plots.Cmap displays a gray image with a jet colormap.
        %>
        %> @b Usage
        %>
        %> @code
        %> plots.Cmap(fig, '\\temp\\folder\\name.png', img, figTitle);
        %> @endcode
        %>
        %> @param fig [int] | The figure handle
        %> @param plotPath [char] | The path for saving plot figures
        %> @param img [numeric array] | The left image
        %> @param figTitle [char] | The figure title
        %======================================================================
        function [] = Cmap(fig, plotPath, img, figTitle)
            figHandle = figure(fig);
            clf;
            imagesc(img);
            if nargin > 3
                title(figTitle);
            end
            plots.SavePlot(figHandle, plotPath);
        end

        %======================================================================
        %> @brief plots.Superpixels plots superpixel labels
        %>
        %> For more details check @c function PlotSuperpixels .
        %>
        %> @b Usage
        %>
        %> @code
        %> plots.Superpixels(fig, '\\temp\\folder\\name.png', baseImage, labels, 'Superpixel Boundary of image 3', 'boundary', []);
        %>
        %> plots.Superpixels(fig, '\\temp\\folder\\name.png', baseImage, labels, 'Superpixels of image 3', 'color', fgMask);
        %> @endcode
        %>
        %> @param fig [int] | The figure handle
        %> @param plotPath [char] | The path for saving plot figures
        %> @param baseIm [numeric array] | The base image
        %> @param topIm [numeric array] | The top image
        %> @param figTitle [char] | The figure title
        %> @param plotType [char] | The plot type, either 'color' or 'boundary'
        %> @param fgMask [numeric array] | The foreground mask
        %======================================================================
        function [] = Superpixels(fig, plotPath, varargin)
            plots.Apply(fig, plotPath, @PlotSuperpixels, varargin{:});
        end

        %======================================================================
        %> @brief plots.MontageFolderContents plots contents of a folder as a montage.
        %>
        %> For more details check @c function PlotMontageFolderContents .
        %>
        %> @b Usage
        %>
        %> @code
        %>   criteria = struct('TargetDir', 'subfolders', ...
        %>       'TargetName', strcat(target, '.png'), ...
        %>       'TargetType', 'fix');
        %> plots.MontageFolderContents(1, [], criteria, [500, 500], 20);
        %> @endcode
        %>
        %> @param fig [int] | The figure handle
        %> @param path [char] | The path to image folder
        %> @param criteria [struct] | The montage options
        %> @param figTitle [char] | The figure title
        %> @param standardDim [int vector] | The dimensions for subimage resizing
        %> @param imageLimit [int] | The maximum number of subimages to be montaged
        %======================================================================
        function [] = MontageFolderContents(fig, varargin)
            plots.Apply(fig, [], @PlotMontageFolderContents, varargin{:});
        end

        %======================================================================
        %> @brief plots.GetMontagetCollection plots a montage of images with a target filename under different subfolders.
        %>
        %> The base output folder is assumed to be pre-set with config::[SaveFolder].
        %> Subfolders are assumed to be named with a sample's TargetID.
        %> For more details check @c function PlotMontageFolderContents .
        %>
        %> @b Usage
        %>
        %> @code
        %> plots.GetMontagetCollection(1, 'eigenvectors');
        %> @endcode
        %>
        %> @param fig [int] | The figure handle
        %> @param target [char] | The target filename
        %======================================================================
        function GetMontagetCollection(fig, target)
            plotPath = commonUtility.GetFilename('output', config.GetSetting('SaveFolder'), '');
            fprintf('Montage from path %s.\n', plotPath);
            criteria = struct('TargetDir', 'subfolders', 'TargetName', target);
            plots.Apply(fig, plotPath, @PlotMontageFolderContents, [], criteria, [], [800, 800]);
        end

        %======================================================================
        %> @brief plots.NormalizationCheck  plots the values recovered after normalization.
        %>
        %> For more details check @c function PlotNormalizationCheck .
        %> The user needs to input a custom mask.
        %> Disable in config::[DisableReflectranceExtremaPlots].
        %>
        %> @b Usage
        %> plots.NormalizationCheck(fig, plotPath, Iin, Iblack, Iwhite, Inorm);
        %> @endcode
        %>
        %> @param fig [int] | The figure handle
        %> @param plotPath [char] | The path for saving plot figures
        %> @param Iin [hsi] | The measurement image
        %> @param Iblack [hsi] | The black image
        %> @param Iwhite [hsi] | The white image
        %> @param Inorm [hsi] | The normalization image
        %======================================================================
        function [] = NormalizationCheck(fig, plotPath, varargin)
            plots.Apply(fig, plotPath, @PlotNormalizationCheck, varargin{:});
        end

        %======================================================================
        %> @brief plots.Montage plots the montage of an image list.
        %>
        %> @b Usage
        %> plots.Montage(1, plotPath, labels, names, plotPath);
        %> @endcode
        %>
        %> @param figNum [int] | The figure handle
        %> @param plotPath [char] | The path for saving plot figures
        %> @param img [cell array] | The list of images
        %> @param names [cell array] | The list of image names
        %======================================================================
        function [] = Montage(figNum, plotPath, img, names)
            fig = figure(figNum);
            clf;
            tlo = tiledlayout(fig, 2, 3, 'TileSpacing', 'None');
            for i = 1:numel(img)
                ax = nexttile(tlo);
                imshow(img{i}, 'Parent', ax)
                title(names{i});
            end
            plots.SavePlot(fig, plotPath);
        end

        %======================================================================
        %> @brief plots.MontageCmap plots the heat map montage of an image list.
        %>
        %> @b Usage
        %> plots.MontageCmap(1, plotPath, labels, names);
        %> @endcode
        %>
        %> @param figNum [int] | The figure handle
        %> @param plotPath [char] | The path for saving plot figures
        %> @param img [cell array] | The list of images
        %> @param names [cell array] | The list of image names
        %> @param hasLimits [boolean] | Optional: A flag to show whether scaling has limits. Default: true.
        %======================================================================
        function [] = MontageCmap(figNum, plotPath, img, names, hasLimits, limitVal)
            cmapIndex = cell2mat(cellfun(@(x) ndims(x) < 3, img, 'un', 0));
            cmapImg = img(cmapIndex);
            if nargin < 5
                hasLimits = true;
            end

            if hasLimits
                if nargin < 6
                    minval = min(cellfun(@(x) min(x, [], 'all'), cmapImg));
                    maxval = max(cellfun(@(x) max(x, [], 'all'), cmapImg));

                    limitVal = repmat([minval, maxval], numel(img), 1);
                end
            end

            fig = figure(figNum);
            clf;
            numRow = ceil(numel(img)/2);
            numCol = mod(numel(img), 2) + 2;
            tlo = tiledlayout(fig, numRow, numCol, 'TileSpacing', 'None');
            for i = 1:numel(img)
                ax = nexttile(tlo);
                if cmapIndex(i)
                    if hasLimits
                        imagesc(ax, img{i}, [limitVal(i, 1), limitVal(i, 2)]);
                    else
                        imagesc(ax, img{i});
                    end
                    ax.Visible = 'off';
                    ax.XTick = [];
                    ax.YTick = [];
                    colormap(ax, 'hot');
                    cb = colorbar(ax);
                    axis square;
                else
                    imshow(img{i}, 'Parent', ax);
                end
                title(names{i});
            end
            plots.SavePlot(fig, plotPath);
        end

        %======================================================================
        %> @brief plots.MontageWithLabel plots a montage of an image list with labels.
        %>
        %> @b Usage
        %> plots.MontageWithLabel(1, plotPath, img, names, labelMask, fgMask);
        %> @endcode
        %>
        %> @param figNum [int] | The figure handle
        %> @param plotPath [char] | The path for saving plot figures
        %> @param img [cell array] | The list of images
        %> @param names [cell array] | The list of image names
        %> @param labelMask [numeric array] | The label mask
        %> @param fgMask [numeric array] | The foreground mask
        %======================================================================
        function [] = MontageWithLabel(figNum, plotPath, img, names, labelMask, fgMask)

            fig = figure(figNum);
            clf;
            numRow = ceil(numel(img)/2);
            numCol = mod(numel(img), 2) + 2;
            tlo = tiledlayout(fig, numRow, numCol, 'TileSpacing', 'None');
            for i = 1:numel(img)
                ax = nexttile(tlo);

                curImg = img{i};
                if ndims(curImg) < 3
                    lb = unique(curImg(:));
                    colors = parula(numel(lb));
                    [m, n] = size(curImg);
                    newImg = zeros(m * n, 3);
                    for k = 1:numel(lb)
                        mask = curImg == lb(k);
                        maskCol = reshape(mask, [m * n, 1]);
                        newImg(maskCol, :) = repmat(colors(k, :), sum(maskCol), 1);
                    end
                    curImg = reshape(newImg, [m, n, 3]);
                end
                C = insertObjectMask(curImg, edge(labelMask), 'Color', 'w');
                hold on;
                h = imshow(C, 'Parent', ax);
                set(h, 'AlphaData', fgMask);

                hold off;
                title(names{i});
            end
            plots.SavePlot(fig, plotPath);
        end

        %======================================================================
        %> @brief plots.GroundTruthComparison plots the comparison of a prediction image to the ground truth labels.
        %>
        %> The Jaccard Coefficient is also presented in the title.
        %>
        %> @b Usage
        %> plots.GroundTruthComparison(1, plotPath, rgbImg, labelImg, predImg);
        %> @endcode
        %>
        %> @param figNum [int] | The figure handle
        %> @param plotPath [char] | The path for saving plot figures
        %> @param rgbImg [numeric array] | The sRGB base image
        %> @param labelMask [numeric array] | The label mask
        %> @param predImg [numeric array] | The prediction mask
        %======================================================================
        function [] = GroundTruthComparison(figNum, plotPath, rgbImg, labelImg, predImg)

            jacCoeff = jaccard(labelImg, round(predImg));

            fig = figure(figNum);
            clf;

            subplot(1, 3, 1);
            imshow(rgbImg);
            title('Input Image', 'FontSize', 12);

            subplot(1, 3, 2);
            imshow(labelImg);
            title('Ground Truth', 'FontSize', 12);

            subplot(1, 3, 3);
            imshow(predImg);
            title('Prediction', 'FontSize', 12);
            text(min(xlim), max(ylim), sprintf('JC: %.2f%%', jacCoeff*100), 'Horiz', 'left', 'Vert', 'bottom', 'FontSize', 12, 'Color', 'g');

            plots.SavePlot(fig, plotPath);
        end

        %======================================================================
        %> @brief plots.PostProcessingComparison plots the comparison of a prediction image to the ground truth labels and to post processed labels.
        %>
        %> The Jaccard Coefficient is also presented in the title.
        %>
        %> @b Usage
        %> plots.PostProcessingComparison(1, plotPath, labelImg, predImg, postPredImg);
        %> @endcode
        %>
        %> @param figNum [int] | The figure handle
        %> @param plotPath [char] | The path for saving plot figures
        %> @param labelMask [numeric array] | The label mask
        %> @param predImg [numeric array] | The prediction mask
        %> @param postPredImg [numeric array] | The post-processed prediction mask
        %======================================================================
        function [] = PostProcessingComparison(figNum, plotPath, labelImg, predImg, postPredImg)
            jacCoeff1 = jaccard(labelImg, round(predImg));
            jacCoeff2 = jaccard(labelImg, round(postPredImg));

            fig = figure(figNum);
            clf;

            subplot(1, 3, 1);
            imshow(labelImg);
            title('Ground Truth', 'FontSize', 12);

            subplot(1, 3, 2);
            imshow(predImg);
            text(min(xlim), max(ylim), sprintf('JC: %.2f%%', jacCoeff1*100), 'Horiz', 'left', 'Vert', 'bottom', 'FontSize', 12, 'Color', 'g');
            title('Prediction', 'FontSize', 12);

            subplot(1, 3, 3);
            imshow(postPredImg);
            title('Post-Processed', 'FontSize', 12);
            text(min(xlim), max(ylim), sprintf('JC: %.2f%%', jacCoeff2*100), 'Horiz', 'left', 'Vert', 'bottom', 'FontSize', 12, 'Color', 'g');

            plots.SavePlot(fig, plotPath);
        end

        %======================================================================
        %> @brief plots.PredictionValues plots the prediction values using a heatmap.
        %>
        %> The borders of patches are also presented with green.
        %>
        %> @b Usage
        %> plots.PredictionValues(1, plotPath, labelImg, predImg, borderImg);
        %> @endcode
        %>
        %> @param figNum [int] | The figure handle
        %> @param plotPath [char] | The path for saving plot figures
        %> @param predImg [numeric array] | The prediction mask
        %> @param borderImg [numeric array] | The mask of patch borders
        %======================================================================
        function [] = PredictionValues(figNum, plotPath, predImg, borderImg)

            fig = figure(figNum);
            clf;

            subplot(1, 2, 1);
            imshow(predImg);
            green = cat(3, zeros(size(borderImg)), borderImg, zeros(size(borderImg)));
            hold on;
            h = imshow(green);
            hold off
            h.AlphaData = 0.4;
            title('Patch borders');

            subplot(1, 2, 2);
            imagesc(predImg, [0, 1]);
            colormap('hot');
            axis('off');
            axis equal
            axis tight;
            %c = colorbar('Location', 'southoutside');
            title('Output values');

            plots.SavePlot(fig, plotPath);

        end

        %======================================================================
        %> @brief plots.ReferenceLibrary  plots the reference spectra in the library.
        %>
        %> @b Usage
        %> refLib = hsiUtility.GetReferenceLibrary();
        %> plots.ReferenceLibrary(1, refLib);
        %> @endcode
        %>
        %> @param fig [int] | The figure handle
        %> @param refLib [struct] | A struct that contains the reference library. The struct has fields 'Data', 'Label' (Malignant (1) or Benign (0)) and 'Disease'.
        %======================================================================
        function [] = ReferenceLibrary(fig, refLib)
            spectra = cell2mat({refLib.Data}');
            [m, n] = size(spectra);
            wavelengths = hsiUtility.GetWavelengths(n);
            names = cellfun(@(x) x{1}, {refLib.Disease}', 'un', 0);
            markers = cell(numel(names), 1);
            for i = 1:m
                if refLib(i).Label == 0
                    names{i} = strcat(names{i}, ' Benign');
                    markers{i} = "-";
                else
                    names{i} = strcat(names{i}, ' Malignant');
                    markers{i} = ":";
                end
            end
            figTitle = 'Reference Spectra';
            plotPath = config.DirMake(config.GetSetting('OutputDir'), config.GetSetting('Common'), 'samReferenceLibrarySpectra.png');
            plots.Apply(fig, plotPath, @PlotSpectra, spectra, wavelengths, names, figTitle, markers);
        end

        %======================================================================
        %> @brief plots.Illumination  plots the illumination spectrum.
        %>
        %> The name of the illumination source is saved in config::[IlluminationSource].
        %> Illumination information is saved in medHSI\\parameters\\displayParam.mat
        %>
        %> @b Usage
        %> plots.Illumination();
        %> @endcode
        %======================================================================
        function [] = Illumination()
            filename = commonUtility.GetFilename('param', 'displayParam');

            z = 401;
            lambdaIn = hsiUtility.GetWavelengths(z, 'raw');
            load(filename, 'illumination');

            fig = figure();
            plot(lambdaIn, illumination, 'DisplayName', config.GetSetting('IlluminationSource'));
            plotPath = fullfile(config.GetSetting('OutputDir'), config.GetSetting('Common'), 'illumination');
            title('Illumination');
            xlabel('Wavelength (nm)');
            ylabel('Radiant Intensity (a.u.)');
            legend();
            plots.SavePlot(fig, plotPath);
        end

        %======================================================================
        %> @brief plots.ColorMatchingFunctions  plots the color matching functions.
        %>
        %> Information is saved in medHSI\\parameters\\displayParam.mat
        %>
        %> @b Usage
        %> plots.ColorMatchingFunctions();
        %> @endcode
        %======================================================================
        function [] = ColorMatchingFunctions()

            filename = commonUtility.GetFilename('param', 'displayParam');

            z = 401;
            lambdaIn = hsiUtility.GetWavelengths(z, 'raw');
            load(filename, 'xyz');

            %% Plots XYZ curve
            fig = figure();
            hold on
            plot(lambdaIn, xyz(:, 1), 'DisplayName', 'x');
            plot(lambdaIn, xyz(:, 2), 'DisplayName', 'y');
            plot(lambdaIn, xyz(:, 3), 'DisplayName', 'z');
            hold off
            legend();
            title('Interpolated Color Matching Functions');
            xlabel('Wavelength (nm)');
            ylabel('Weight (a.u.)');
            plotPath = fullfile(config.GetSetting('OutputDir'), config.GetSetting('Common'), 'interpColorMatchingFunctions');
            plots.SavePlot(fig, plotPath);

        end

        %======================================================================
        %> @brief plots.ChromophoreAbsorption  plots the skin chromophore absorption functions.
        %>
        %> Information is saved in config::[ImportDir]\\*.csv.
        %> Required .csv files:
        %> - 'pheomelanin_absroption.csv'
        %> - 'eumelanin_absroption.csv'
        %> - 'hb_absorption_spectra_prahl.csv'
        %> Values by Scott Prahl (https://omlc.org/spectra/)
        %>
        %>
        %> @b Usage
        %> [extCoeffEumelanin2, extCoeffHbO, extCoeffHbR] = plots.ChromophoreAbsorption();
        %> @endcode
        %======================================================================
        function [extCoeffEumelanin2, extCoeffHbO, extCoeffHbR] = ChromophoreAbsorption()

            importDir = config.GetSetting('ImportDir');
            pheomelaninFilename = 'pheomelanin_absroption.csv';
            eumelaninFilename = 'eumelanin_absroption.csv';
            hbFilename = 'hb_absorption_spectra_prahl.csv';
            eumelaninData = delimread(fullfile(importDir, eumelaninFilename), ',', 'num');
            eumelaninData = eumelaninData.num;
            hbData = delimread(fullfile(importDir, hbFilename), ',', 'num');
            hbData = hbData.num;
            pheomelaninData = delimread(fullfile(importDir, pheomelaninFilename), ',', 'num');
            pheomelaninData = pheomelaninData.num;

            eumelaninLambda = eumelaninData(:, 1);
            % extCoeffEumelanin1 = eumelaninData(:, 2);
            extCoeffEumelanin2 = eumelaninData(:, 3);

            pheomelaninLambda = pheomelaninData(:, 1);
            % extCoeffPheomelanin1 = pheomelaninData(:, 2);
            extCoeffPheomelanin2 = pheomelaninData(:, 3);

            % hbAmount = 150; %   A typical value of x for whole blood is x=150 g Hb/liter.
            % convertHbfun = @(x) 2.303 * hbAmount * x / 64500;
            hbLambda = hbData(:, 1);
            extCoeffHbO = hbData(:, 2);
            extCoeffHbR = hbData(:, 3);
            % absCoeffHbO = convertHbfun(extCoeffHbO);
            % absCoeffHbR = convertHbfun(extCoeffHbR);

            % (moles/liter) = M

            fig = figure();
            hold on;
            %plot(eumelaninLambda, extCoeffEumelanin1, 'DisplayName', 'Eumelanin1', 'LineWidth', 2); %cm-1 / (mg/ml)
            plot(eumelaninLambda, extCoeffEumelanin2, 'DisplayName', 'Eumelanin', 'LineWidth', 2); %cm-1 / (moles/liter)
            plot(pheomelaninLambda, extCoeffPheomelanin2, 'DisplayName', 'Pheomelanin', 'LineWidth', 2); %cm-1 / (moles/liter)
            plot(hbLambda, extCoeffHbR, 'DisplayName', 'Hb', 'LineWidth', 2); %cm-1/M
            plot(hbLambda, extCoeffHbO, 'DisplayName', 'HbO_2', 'LineWidth', 2); %cm-1/M

            hold off
            % xlim([300, 800]);
            xlabel('Wavelength (nm)', 'FontSize', 15);
            ylabel('Extinction Coefficient (cm^{-1}/ M)', 'FontSize', 15);
            l = legend('Location', 'northeast');
            l.FontSize = 13;

            set(gca, 'yscale', 'log');
            %set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0, 1, 1]);

            % config.SetSetting('SaveEps', false);
            plotPath = fullfile(config.GetSetting('OutputDir'), config.GetSetting('Common'), 'skinChromophoreExtinctionCoeff');
            plots.SavePlot(fig, plotPath);

            filename = commonUtility.GetFilename('param', 'extinctionCoefficients');
            save(filename, 'extCoeffEumelanin2', 'extCoeffHbO', 'extCoeffHbR', 'eumelaninLambda', 'hbLambda');

        end

        %======================================================================
        %> @brief plots.WithShadedArea plots a the average and std for a set of lines and returns the line handle.
        %>
        %> The average is presented together with a shaded area above and below.
        %>
        %> @b Usage
        %> h = plots.WithShadedArea(x, arr, lineName, lineOpt);
        %> @endcode
        %>
        %> @param x [numeric array] | The x-axis values
        %> @param arr [numeric array] | An array of lines, each row is an observation.
        %> @param lineName [char] | The line name
        %> @param lineOpt [char] | The line color and shape options
        %>
        %> @retval h [line handle] | The line handle
        %======================================================================
        function [h] = WithShadedArea(x, arr, lineName, lineOpt)
            y = mean(arr, 1);
            stds = std(arr, 1);
            curve1 = y + stds;
            curve2 = y - stds;
            lineOptPlain = strrep(strrep(lineOpt, ':', '-'), '--', '-');
            hold on;
            shade(x, curve1, lineOptPlain, x, curve2, lineOptPlain, 'FillType', [1, 2; 2, 1], 'FillAlpha', 0.2);
            h = plot(x, y, lineOpt, 'LineWidth', 3, 'DisplayName', lineName);
            hold off;
        end
    end
end