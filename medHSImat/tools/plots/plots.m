% ======================================================================
%> @brief plots is a class that holds all functions for figure plotting.
%>
% ======================================================================
classdef plots
    methods (Static)

        %======================================================================
        %> @brief Apply runs a plotting function.
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
            % Apply runs a plotting function.
            %
            % The function should take the figure handle as last argument.
            %
            % @b Usage
            %
            % @code
            % [varargout] = plots.Apply(1, '\temp\folder\name.png', @PlotSpectra, spectra);
            %
            % [varargout] = plots.Apply(1, [], @PlotSpectra, spectra);
            % @endcode
            %
            % @param fig [int] | The figure handle
            % @param plotPath [char] | The path for saving plot figures
            % @param funcHandle [Function Handle] | Handle of the target function to be applied
            % @param varargin [Cell array] | The arguments necessary for the target function
            %
            % @retval varargout [Cell array] | The return values of the target function

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
        %> @brief SavePlot saves a figure plot.
        %>
        %> The plot name should be set beforehand in config::[PlotPath].
        %>
        %> @b Usage
        %>
        %> @code
        %> plots.SavePlot(1);
        %> plots.SavePlot(1, '\temp\folder\name.png');
        %> @endcode
        %>
        %> @param fig [int] | The figure handle
        %> @param plotPath [char] | The path for saving plot figures
        %======================================================================
        function [] = SavePlot(fig, plotPath)
            % SavePlot saves a figure plot.
            %
            % The plot name should be set beforehand in config::[PlotPath].
            %
            % @b Usage
            %
            % @code
            % plots.SavePlot(1);
            % plots.SavePlot(1, '\temp\folder\name.png');
            % @endcode
            %
            % @param fig [int] | The figure handle
            % @param plotPath [char] | The path for saving plot figures

            if nargin > 1
                config.SetSetting('PlotPath', plotPath);
            end
            SavePlot(fig);
        end

        %======================================================================
        %> @brief GetLineColorMap returns a linecolor map based on the style.
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
            % GetLineColorMap returns a linecolor map based on the style.
            %
            % Available keys are:
            % 'class': {'Benign', 'Atypical', 'Malignant'}
            % 'type': {'Unfixed', 'Fixed', 'Sectioned'}
            % 'sample': {'0037', '0045', '0053', '0059', '0067', '9913', '9933', '9940', '9949', '9956'}
            % 'custom': user-defined
            % default: {'1', '2', '3', '4', '5', '6', '7', '8', '9', '10'}
            %
            % @b Usage
            %
            % @code
            % lineColorMap = plots.GetLineColorMap('class');
            % @endcode
            %
            % @param style [char] | The line group style. Default: 'class'.
            % @param names [cell array] | Optional: The line group names
            %
            % @retval lineColorMap [map] | The line color map

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
        %> @brief BandStatistics plots statistics among spectral bands.
        %>
        %> For more details check @c function PlotBandStatistics .
        %>
        %> @b Usage
        %>
        %> @code
        %> [imCorr] = plots.BandStatistics(fig, '\temp\folder\name.png', inVectors, 'correlation');
        %>
        %> [imCorr] = plots.BandStatistics(fig, '\temp\folder\name.png', inVectors, 'covariance');
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
            % BandStatistics plots statistics among spectral bands.
            %
            % For more details check @c function PlotBandStatistics .
            %
            % @b Usage
            %
            % @code
            % [imCorr] = plots.BandStatistics(fig, '\temp\folder\name.png', inVectors, 'correlation');
            %
            % [imCorr] = plots.BandStatistics(fig, '\temp\folder\name.png', inVectors, 'covariance');
            % @endcode
            %
            % @param fig [int] | The figure handle
            % @param plotPath [char] | The path for saving plot figures
            % @param inVectors [numeric array] | The input vectors
            % @param statistic [char] | The statistic name
            %
            % @retval imCorr [numeric array] | The statistics values

            [imCorr] = plots.Apply(fig, plotPath, @PlotBandStatistics, varargin{:});
        end

        %======================================================================
        %> @brief Spectra plots multiple spectra together.
        %>
        %> For more details check @c function PlotSpectra .
        %>
        %> @b Usage
        %>
        %> @code
        %> plots.Spectra(fig, '\temp\folder\name.png', spectra, wavelengths, names, figTitle, markers);
        %>
        %> plots.Spectra(fig, '\temp\folder\name.png', spectra);
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
            % Spectra plots multiple spectra together.
            %
            % For more details check @c function PlotSpectra .
            %
            % @b Usage
            %
            % @code
            % plots.Spectra(fig, '\temp\folder\name.png', spectra, wavelengths, names, figTitle, markers);
            %
            % plots.Spectra(fig, '\temp\folder\name.png', spectra);
            % @endcode
            %
            % @param fig [int] | The figure handle
            % @param plotPath [char] | The path for saving plot figures
            % @param spectra [numeric array] | The input vectors
            % @param wavelengths [numeric array] | The wavlength values
            % @param names [cell array] | The curve names
            % @param figTitle [char] | The figure title
            % @param markers [cell array] | The curve markers

            plots.Apply(fig, plotPath, @PlotSpectra, varargin{:});
        end

        %======================================================================
        %> @brief AverageSpectrum plots average spectra using a promt for custom mask selection.
        %>
        %> Need to set config[SaveFolder] for saving purposes.
        %> For more details check @c function PlotAverageSpectrum .
        %>
        %> @b Usage
        %>
        %> @code
        %> plots.AverageSpectrum(fig, '\temp\folder\name.png', hsIm, figTitle);
        %> @endcode
        %>
        %> @param fig [int] | The figure handle
        %> @param plotPath [char] | The path for saving plot figures
        %> @param hsIm [hsi] | An instance of the hsi class
        %> @param figTitle [char] | The figure title
        %======================================================================
        function [] = AverageSpectrum(fig, plotPath, varargin)
            % AverageSpectrum plots average spectra using a promt for custom mask selection.
            %
            % Need to set config[SaveFolder] for saving purposes.
            % For more details check @c function PlotAverageSpectrum .
            %
            % @b Usage
            %
            % @code
            % plots.AverageSpectrum(fig, '\temp\folder\name.png', hsIm, figTitle);
            % @endcode
            %
            % @param fig [int] | The figure handle
            % @param plotPath [char] | The path for saving plot figures
            % @param hsIm [hsi] | An instance of the hsi class
            % @param figTitle [char] | The figure title

            plots.Apply(fig, plotPath, @PlotAverageSpectrum, varargin{:});
        end

        %======================================================================
        %> @brief Components plots the components of a hyperspectral image.
        %>
        %> For more details check @c function PlotComponents .
        %>
        %> @b Usage
        %>
        %> @code
        %> plots.Components(hsIm, pcNum, figStart, '\temp\folder\name.png');
        %> @endcode
        %>
        %> @param hsIm [hsi] | An instance of the hsi class
        %> @param pcNum [int] | The number of components
        %> @param fig [int] | The figure handle
        %> @param plotBasePath [char] | The base path for saving plot figures
        %======================================================================
        function [] = Components(varargin)
            % Components plots the components of a hyperspectral image.
            %
            % @b Usage
            %
            % @code
            % plots.Components(hsIm, pcNum, figStart, '\temp\folder\name.png');
            % @endcode
            %
            % @param hsIm [hsi] | An instance of the hsi class
            % @param pcNum [int] | The number of components
            % @param fig [int] | The figure handle
            % @param plotBasePath [char] | The base path for saving plot figures

            PlotComponents(varargin{:});
        end

        %======================================================================
        %> @brief Eigenvectors plots the eigenvectors of a decomposition.
        %>
        %> For more details check @c function PlotEigenvectors .
        %>
        %> @b Usage
        %>
        %> @code
        %> plots.Eigenvectors(fig, plotPath, coeff, xValues, pcNum);
        %> @endcode
        %>
        %> @param fig [int] | The figure handle
        %> @param plotPath [char] | The path for saving plot figures
        %> @param eigenvec [numeric array] | The eigenvectors
        %> @param xValues [numeric vector] | The x-axis values
        %> @param pcNum [int] | Optional: The number of components. Default: 3
        %======================================================================
        function [] = Eigenvectors(fig, plotPath, varargin)
            % Eigenvectors plots the eigenvectors of a decomposition.
            %
            % For more details check @c function PlotEigenvectors .
            %
            % @b Usage
            %
            % @code
            % plots.Eigenvectors(fig, plotPath, coeff, xValues, pcNum);
            % @endcode
            %
            % @param fig [int] | The figure handle
            % @param plotPath [char] | The path for saving plot figures
            % @param eigenvec [numeric array] | The eigenvectors
            % @param xValues [numeric vector] | The x-axis values
            % @param pcNum [int] | Optional: The number of components. Default: 3

            plots.Apply(fig, plotPath, @PlotEigenvectors, varargin{:});
        end

        %======================================================================
        %> @brief Overlay applies a mask over a base image.
        %>
        %> For more details check @c function PlotOverlay .
        %>
        %> @b Usage
        %>
        %> @code
        %> plots.Overlay(fig, plotPath, baseIm, topIm, figTitle);
        %> @endcode
        %>
        %> @param fig [int] | The figure handle
        %> @param plotPath [char] | The path for saving plot figures
        %> @param baseIm [numeric array] | The base image
        %> @param topIm [numeric array] | The top image
        %> @param figTitle [char] | The figure title
        %======================================================================
        function [] = Overlay(fig, plotPath, varargin)
            % Overlay applies a mask over a base image.
            %
            % For more details check @c function PlotOverlay .
            %
            % @b Usage
            %
            % @code
            % plots.Overlay(fig, plotPath, baseIm, topIm, figTitle);
            % @endcode
            %
            % @param fig [int] | The figure handle
            % @param plotPath [char] | The path for saving plot figures
            % @param baseIm [numeric array] | The base image
            % @param topIm [numeric array] | The top image
            % @param figTitle [char] | The figure title

            plots.Apply(fig, plotPath, @PlotOverlay, varargin{:});
        end

        %======================================================================
        %> @brief Pair displays a pair of images side by side.
        %>
        %> @b Usage
        %>
        %> @code
        %> plots.Pair(fig, plotPath, baseIm, topIm, figTitle);
        %> @endcode
        %>
        %> @param fig [int] | The figure handle
        %> @param plotPath [char] | The path for saving plot figures
        %> @param img1 [numeric array] | The left image
        %> @param img2 [numeric array] | The right image
        %> @param figTitle [char] | The figure title
        %======================================================================
        function [] = Pair(fig, plotPath, img1, img2, figTitle)
            % Pair displays a pair of images side by side.
            %
            % @b Usage
            %
            % @code
            % plots.Pair(fig, plotPath, baseIm, topIm, figTitle);
            % @endcode
            %
            % @param fig [int] | The figure handle
            % @param plotPath [char] | The path for saving plot figures
            % @param img1 [numeric array] | The left image
            % @param img2 [numeric array] | The right image
            % @param figTitle [char] | The figure title

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
        %> @brief Show displays an image.
        %>
        %> @b Usage
        %>
        %> @code
        %> plots.Show(fig, plotPath, img, figTitle);
        %> @endcode
        %>
        %> @param fig [int] | The figure handle
        %> @param plotPath [char] | The path for saving plot figures
        %> @param img [numeric array] | The left image
        %> @param figTitle [char] | The figure title
        %======================================================================
        function [] = Show(fig, plotPath, img, figTitle)
            % Show displays an image.
            %
            % @b Usage
            %
            % @code
            % plots.Show(fig, plotPath, img, figTitle);
            % @endcode
            %
            % @param fig [int] | The figure handle
            % @param plotPath [char] | The path for saving plot figures
            % @param img [numeric array] | The left image
            % @param figTitle [char] | The figure title
            figHandle = figure(fig);
            clf;
            imshow(img);
            if nargin > 3
                title(figTitle);
            end
            plots.SavePlot(figHandle, plotPath);
        end

        %======================================================================
        %> @brief Cmap displays a gray image with a jet colormap.
        %>
        %> @b Usage
        %>
        %> @code
        %> plots.Cmap(fig, plotPath, img, figTitle);
        %> @endcode
        %>
        %> @param fig [int] | The figure handle
        %> @param plotPath [char] | The path for saving plot figures
        %> @param img [numeric array] | The left image
        %> @param figTitle [char] | The figure title
        %======================================================================
        function [] = Cmap(fig, plotPath, img, figTitle)
            % Cmap displays a gray image with a jet colormap.
            %
            % @b Usage
            %
            % @code
            % plots.Cmap(fig, plotPath, img, figTitle);
            % @endcode
            %
            % @param fig [int] | The figure handle
            % @param plotPath [char] | The path for saving plot figures
            % @param img [numeric array] | The left image
            % @param figTitle [char] | The figure title
            figHandle = figure(fig);
            clf;
            imagesc(img);
            if nargin > 3
                title(figTitle);
            end
            plots.SavePlot(figHandle, plotPath);
        end

        %======================================================================
        %> @brief Superpixels plots superpixel labels
        %>
        %> For more details check @c function PlotSuperpixels .
        %>
        %> @b Usage
        %>
        %> @code
        %> plots.Superpixels(fig, plotPath, baseImage, labels, 'Superpixel Boundary of image 3', 'boundary', []);
        %>
        %> plots.Superpixels(fig, plotPath, baseImage, labels, 'Superpixels of image 3', 'color', fgMask);
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
            % Superpixels plots superpixel labels
            %
            % For more details check @c function PlotSuperpixels .
            %
            % @b Usage
            %
            % @code
            % plots.Superpixels(fig, plotPath, baseImage, labels, 'Superpixel Boundary of image 3', 'boundary', []);
            %
            % plots.Superpixels(fig, plotPath, baseImage, labels, 'Superpixels of image 3', 'color', fgMask);
            % @endcode
            %
            % @param fig [int] | The figure handle
            % @param plotPath [char] | The path for saving plot figures
            % @param baseIm [numeric array] | The base image
            % @param topIm [numeric array] | The top image
            % @param figTitle [char] | The figure title
            % @param plotType [char] | The plot type, either 'color' or 'boundary'
            % @param fgMask [numeric array] | The foreground mask
            plots.Apply(fig, plotPath, @PlotSuperpixels, varargin{:});
        end

        %======================================================================
        %> @brief MontageFolderContents plots contents of a folder as a montage.
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
            % MontageFolderContents plots contents of a folder as a montage.
            %
            % For more details check @c function PlotMontageFolderContents .
            %
            % @b Usage
            %
            % @code
            %   criteria = struct('TargetDir', 'subfolders', ...
            %       'TargetName', strcat(target, '.png'), ...
            %       'TargetType', 'fix');
            % plots.MontageFolderContents(1, [], criteria, [500, 500], 20);
            % @endcode
            %
            % @param fig [int] | The figure handle
            % @param path [char] | The path to image folder
            % @param criteria [struct] | The montage options
            % @param figTitle [char] | The figure title
            % @param standardDim [int vector] | The dimensions for subimage resizing
            % @param imageLimit [int] | The maximum number of subimages to be montaged
            plots.Apply(fig, [], @PlotMontageFolderContents, varargin{:});
        end

        %======================================================================
        %> @brief GetMontagetCollection plots a montage of images with a target filename under different subfolders.
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
            % GetMontagetCollection plots a montage of images with a target filename under different subfolders.
            %
            % The base output folder is assumed to be pre-set with config::[SaveFolder].
            % Subfolders are assumed to be named with a sample's TargetID.
            % For more details check @c function PlotMontageFolderContents .
            %
            % @b Usage
            %
            % @code
            % plots.GetMontagetCollection('eigenvectors');
            % @endcode
            %
            % @param fig [int] | The figure handle
            % @param target [char] | The target filename
            plotPath = commonUtility.GetFilename('output', config.GetSetting('SaveFolder'), '');
            fprintf('Montage from path %s.\n', plotPath);
            criteria = struct('TargetDir', 'subfolders', 'TargetName', target);
            plots.Apply(fig, plotPath, @PlotMontageFolderContents, [], criteria, [], [800, 800]);
        end

        %======================================================================
        %> @brief NormalizationCheck  plots the values recovered after normalization.
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
            % NormalizationCheck  plots the values recovered after normalization.
            %
            % For more details check @c function PlotNormalizationCheck .
            % The user needs to input a custom mask.
            % Disable in config::[DisableReflectranceExtremaPlots].
            %
            % @b Usage
            % plots.NormalizationCheck(fig, plotPath, Iin, Iblack, Iwhite, Inorm);
            % @endcode
            %
            % @param fig [int] | The figure handle
            % @param plotPath [char] | The path for saving plot figures
            % @param Iin [hsi] | The measurement image
            % @param Iblack [hsi] | The black image
            % @param Iwhite [hsi] | The white image
            % @param Inorm [hsi] | The normalization image
            %====================================================

            plots.Apply(fig, plotPath, @PlotNormalizationCheck, varargin{:});
        end

        %======================================================================
        %> @brief Montage plots the montage of an image list.
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
            % Montage plots the montage of an image list.
            %
            % @b Usage
            % plots.Montage(1, plotPath, labels, names, plotPath);
            % @endcode
            %
            % @param figNum [int] | The figure handle
            % @param plotPath [char] | The path for saving plot figures
            % @param img [cell array] | The list of images
            % @param names [cell array] | The list of image names

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
        %> @brief MontageCmap plots the heat map montage of an image list.
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
            % MontageCmap plots the heat map montage of an image list.
            %
            % @b Usage
            % plots.MontageCmap(1, plotPath, labels, names);
            % @endcode
            %
            % @param figNum [int] | The figure handle
            % @param plotPath [char] | The path for saving plot figures
            % @param img [cell array] | The list of images
            % @param names [cell array] | The list of image names
            % @param hasLimits [boolean] | Optional: A flag to show whether scaling has limits. Default: true.


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

        function [] = MontageWithLabel(figNum, plotPath, img, names, labelMask, fgMask)
            % MontageCmap plots the heat map montage of an image list.
            %
            % @b Usage
            % plots.MontageCmap(1, plotPath, labels, names);
            % @endcode
            %
            % @param figNum [int] | The figure handle
            % @param plotPath [char] | The path for saving plot figures
            % @param img [cell array] | The list of images
            % @param names [cell array] | The list of image names
            % @param hasLimits [boolean] | Optional: A flag to show whether scaling has limits. Default: true.

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
                    newImg = zeros(m, n, 3);
                    for k = 1:numel(lb)
                        mask = curImg == lb(k);
                        maskCol = reshape(mask, [m * n, 1]);
                        newImg(maskCol, :) = repmat(colors(k, :), sum(maskCol));
                    end
                    curImg = newImg;
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
        %> @brief ReferenceLibrary  plots the reference spectra in the library.
        %>
        %> @b Usage
        %> refLib = hsiUtility.GetReferenceLibrary();
        %> plots.NormalizationCheck(fig, Iin, Iblack, Iwhite, Inorm);
        %> @endcode
        %>
        %> @param fig [int] | The figure handle
        %> @param refLib [struct] | A struct that contains the reference
        %> library. The struct has fields 'Data', 'Label' (Malignant (1) or
        %> Benign (0)) and 'Disease'.
        %======================================================================
        function [] = ReferenceLibrary(fig, refLib)
            % ReferenceLibrary  plots the reference spectra in the library.
            %
            % @b Usage
            % refLib = hsiUtility.GetReferenceLibrary();
            % plots.NormalizationCheck(fig, Iin, Iblack, Iwhite, Inorm);
            % @endcode
            %
            % @param fig [int] | The figure handle
            % @param refLib [struct] | A struct that contains the reference
            % library. The struct has fields 'Data', 'Label' (Malignant (1) or
            % Benign (0)) and 'Disease'.

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
        %> @brief Illumination  plots the illumination spectrum.
        %>
        %> The name of the illumination source is saved in config::[IlluminationSource].
        %> Illumination information is saved in medHSI\\config::[ParamDir]\\displayParam.mat
        %>
        %> @b Usage
        %> plots.Illumination();
        %> @endcode
        %======================================================================
        function [] = Illumination()
            % Illumination  plots the illumination spectrum.
            %
            % The name of the illumination source is saved in config::[IlluminationSource].
            % Illumination information is saved in medHSI\\config::[ParamDir]\\displayParam.mat
            %
            % @b Usage
            % plots.Illumination();
            % @endcode
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
        %> @brief ColorMatchingFunctions  plots the color matching functions.
        %>
        %> Information is saved in medHSI\\config::[ParamDir]\\displayParam.mat
        %>
        %> @b Usage
        %> plots.ColorMatchingFunctions();
        %> @endcode
        %======================================================================
        function [] = ColorMatchingFunctions()
            % ColorMatchingFunctions  plots the color matching functions.
            %
            % Information is saved in medHSI\\config::[ParamDir]\\displayParam.mat
            %
            % @b Usage
            % plots.ColorMatchingFunctions();
            % @endcode
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
        %> @brief ChromophoreAbsorption  plots the skin chromophore absorption functions.
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
            % ChromophoreAbsorption  plots the skin chromophore absorption functions.
            %
            % Information is saved in config::[ImportDir]\\*.csv.
            % Required .csv files:
            % - 'pheomelanin_absroption.csv'
            % - 'eumelanin_absroption.csv'
            % - 'hb_absorption_spectra_prahl.csv'
            % Values by Scott Prahl (https://omlc.org/spectra/)
            %
            %
            % @b Usage
            % [extCoeffEumelanin2, extCoeffHbO, extCoeffHbR] = plots.ChromophoreAbsorption();
            % @endcode

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