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
        %> [varargout] = plots.Apply(1, @PlotSpectra, spectra);
        %> @endcode
        %>
        %> @param fig [int] | The figure handle
        %> @param functionName [Function Handle] | Handle of the target function to be applied
        %> @param varargin [Cell array] | The arguments necessary for the target function
        %>
        %> @retval varargout [Cell array] | The return values of the target function
        %======================================================================
        function [varargout] = Apply(fig, functionName, varargin)
            % Apply runs a plotting function.
            %
            % The function should take the figure handle as last argument.
            %
            % @b Usage
            %
            % @code
            % [varargout] = plots.Apply(1, @PlotSpectra, spectra);
            % @endcode
            %
            % @param fig [int] | The figure handle
            % @param functionName [Function Handle] | Handle of the target function to be applied
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

            newVarargin = varargin;
            expectedArgs = nargin(functionName);
            for i = (length(newVarargin) + 1):(expectedArgs - 1)
                newVarargin{i} = [];
            end
            newVarargin{length(newVarargin)+1} = fig;

            if nargout(functionName) > 0
                varargout{:} = functionName(newVarargin{:});
            else
                functionName(newVarargin{:});
                varargout{:} = {};
            end
        end

        %======================================================================
        %> @brief SavePlot saves a figure plot.
        %>
        %> The plot name should be set beforehand in config::[plotName].
        %>
        %> @b Usage
        %>
        %> @code
        %> plots.SavePlot(1);
        %> @endcode
        %>
        %> @param fig [int] | The figure handle
        %======================================================================
        function [] = SavePlot(fig)
            % SavePlot saves a figure plot.
            %
            % The plot name should be set beforehand in config::[plotName].
            %
            % @b Usage
            %
            % @code
            % plots.SavePlot(1);
            % @endcode
            %
            % @param fig [int] | The figure handle
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
        %> [imCorr] = plots.BandStatistics(fig, inVectors, 'correlation');
        %>
        %> [imCorr] = plots.BandStatistics(fig, inVectors, 'covariance');
        %> @endcode
        %>
        %> @param fig [int] | The figure handle
        %> @param inVectors [numeric array] | The input vectors
        %> @param statistic [char] | The statistic name
        %>
        %> @retval imCorr [numeric array] | The statistics values
        %======================================================================
        function [imCorr] = BandStatistics(fig, varargin)
            % BandStatistics plots statistics among spectral bands.
            %
            % For more details check @c function PlotBandStatistics .
            %
            % @b Usage
            %
            % @code
            % [imCorr] = plots.BandStatistics(fig, inVectors, 'correlation');
            %
            % [imCorr] = plots.BandStatistics(fig, inVectors, 'covariance');
            % @endcode
            %
            % @param fig [int] | The figure handle
            % @param inVectors [numeric array] | The input vectors
            % @param statistic [char] | The statistic name
            %
            % @retval imCorr [numeric array] | The statistics values

            [imCorr] = plots.Apply(fig, @PlotBandStatistics, varargin{:});
        end

        %======================================================================
        %> @brief Spectra plots multiple spectra together.
        %>
        %> For more details check @c function PlotSpectra .
        %>
        %> @b Usage
        %>
        %> @code
        %> plots.Spectra(fig, spectra, wavelengths, names, figTitle, markers);
        %>
        %> plots.Spectra(fig, spectra);
        %> @endcode
        %>
        %> @param fig [int] | The figure handle
        %> @param spectra [numeric array] | The input vectors
        %> @param wavelengths [numeric array] | The wavlength values
        %> @param names [cell array] | The curve names
        %> @param figTitle [char] | The figure title
        %> @param markers [cell array] | The curve markers
        %======================================================================
        function [] = Spectra(fig, varargin)
            % Spectra plots multiple spectra together.
            %
            % For more details check @c function PlotSpectra .
            %
            % @b Usage
            %
            % @code
            % plots.Spectra(fig, spectra, wavelengths, names, figTitle, markers);
            %
            % plots.Spectra(fig, spectra);
            % @endcode
            %
            % @param fig [int] | The figure handle
            % @param spectra [numeric array] | The input vectors
            % @param wavelengths [numeric array] | The wavlength values
            % @param names [cell array] | The curve names
            % @param figTitle [char] | The figure title
            % @param markers [cell array] | The curve markers

            plots.Apply(fig, @PlotSpectra, varargin{:});
        end

        %======================================================================
        %> @brief AverageSpectrum plots average spectra using a promt for custom mask selection.
        %>
        %> For more details check @c function PlotAverageSpectrum .
        %>
        %> @b Usage
        %>
        %> @code
        %> plots.AverageSpectrum(fig, hsIm, figTitle);
        %> @endcode
        %>
        %> @param fig [int] | The figure handle
        %> @param hsIm [hsi] | An instance of the hsi class
        %> @param figTitle [char] | The figure title
        %======================================================================
        function [] = AverageSpectrum(fig, varargin)
            % AverageSpectrum plots average spectra using a promt for custom mask selection.
            %
            % For more details check @c function PlotAverageSpectrum .
            %
            % @b Usage
            %
            % @code
            % plots.AverageSpectrum(fig, hsIm, figTitle);
            % @endcode
            %
            % @param fig [int] | The figure handle
            % @param hsIm [hsi] | An instance of the hsi class
            % @param figTitle [char] | The figure title

            plots.Apply(fig, @PlotAverageSpectrum, varargin{:});
        end

        %======================================================================
        %> @brief Components plots the components of a hyperspectral image.
        %>
        %> For more details check @c function PlotComponents .
        %>
        %> @b Usage
        %>
        %> @code
        %> plots.Components(fig, hsIm, pcNum);
        %> @endcode
        %>
        %> @param fig [int] | The figure handle
        %> @param hsIm [hsi] | An instance of the hsi class
        %> @param pcNum [int] | The number of components
        %======================================================================
        function [] = Components(varargin)
            % Components plots the components of a hyperspectral image.
            %
            % @b Usage
            %
            % @code
            % plots.Components(fig, hsIm, pcNum);
            % @endcode
            %
            % @param fig [int] | The figure handle
            % @param hsIm [hsi] | An instance of the hsi class
            % @param pcNum [int] | The number of components

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
        %> plots.Eigenvectors(fig, coeff, xValues, pcNum);
        %> @endcode
        %>
        %> @param fig [int] | The figure handle
        %> @param eigenvec [numeric array] | The eigenvectors
        %> @param xValues [numeric vector] | The x-axis values
        %> @param pcNum [int] | Optional: The number of components. Default: 3
        %======================================================================
        function [] = Eigenvectors(fig, varargin)
            % Eigenvectors plots the eigenvectors of a decomposition.
            %
            % For more details check @c function PlotEigenvectors .
            %
            % @b Usage
            %
            % @code
            % plots.Eigenvectors(fig, coeff, xValues, pcNum);
            % @endcode
            %
            % @param fig [int] | The figure handle
            % @param eigenvec [numeric array] | The eigenvectors
            % @param xValues [numeric vector] | The x-axis values
            % @param pcNum [int] | Optional: The number of components. Default: 3

            plots.Apply(fig, @PlotEigenvectors, varargin{:});
        end

        %======================================================================
        %> @brief Overlay applies a mask over a base image.
        %>
        %> For more details check @c function PlotOverlay .
        %>
        %> @b Usage
        %>
        %> @code
        %> plots.Overlay(fig, baseIm, topIm, figTitle);
        %> @endcode
        %>
        %> @param fig [int] | The figure handle
        %> @param baseIm [numeric array] | The base image
        %> @param topIm [numeric array] | The top image
        %> @param figTitle [char] | The figure title
        %======================================================================
        function [] = Overlay(fig, varargin)
            % Overlay applies a mask over a base image.
            %
            % For more details check @c function PlotOverlay .
            %
            % @b Usage
            %
            % @code
            % plots.Overlay(fig, baseIm, topIm, figTitle);
            % @endcode
            %
            % @param fig [int] | The figure handle
            % @param baseIm [numeric array] | The base image
            % @param topIm [numeric array] | The top image
            % @param figTitle [char] | The figure title

            plots.Apply(fig, @PlotOverlay, varargin{:});
        end

        %======================================================================
        %> @brief Superpixels plots superpixel labels
        %>
        %> For more details check @c function PlotSuperpixels .
        %>
        %> @b Usage
        %>
        %> @code
        %> plots.Superpixels(fig, baseImage, labels, 'Superpixel Boundary of image 3', 'boundary', []);
        %>
        %> plots.Superpixels(fig, baseImage, labels, 'Superpixels of image 3', 'color', fgMask);
        %> @endcode
        %>
        %> @param fig [int] | The figure handle
        %> @param baseIm [numeric array] | The base image
        %> @param topIm [numeric array] | The top image
        %> @param figTitle [char] | The figure title
        %> @param plotType [char] | The plot type, either 'color' or 'boundary'
        %> @param fgMask [numeric array] | The foreground mask
        %======================================================================
        function [] = Superpixels(fig, varargin)
            % Superpixels plots superpixel labels
            %
            % For more details check @c function PlotSuperpixels .
            %
            % @b Usage
            %
            % @code
            % plots.Superpixels(fig, baseImage, labels, 'Superpixel Boundary of image 3', 'boundary', []);
            %
            % plots.Superpixels(fig, baseImage, labels, 'Superpixels of image 3', 'color', fgMask);
            % @endcode
            %
            % @param fig [int] | The figure handle
            % @param baseIm [numeric array] | The base image
            % @param topIm [numeric array] | The top image
            % @param figTitle [char] | The figure title
            % @param plotType [char] | The plot type, either 'color' or 'boundary'
            % @param fgMask [numeric array] | The foreground mask
            plots.Apply(fig, @PlotSuperpixels, varargin{:});
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
        %>       'TargetName', strcat(target, '.jpg'), ...
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
            %       'TargetName', strcat(target, '.jpg'), ...
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
            plots.Apply(fig, @PlotMontageFolderContents, varargin{:});
        end

        %======================================================================
        %> @brief NormalizationCheck  plots the values recovered after normalization.
        %>
        %> For more details check @c function PlotNormalizationCheck .
        %> The user needs to input a custom mask.
        %> Disable in config::[disableReflectranceExtremaPlots].
        %>
        %> @b Usage
        %> plots.NormalizationCheck(fig, Iin, Iblack, Iwhite, Inorm);
        %> @endcode
        %>
        %> @param fig [int] | The figure handle
        %> @param Iin [hsi] | The measurement image
        %> @param Iblack [hsi] | The black image
        %> @param Iwhite [hsi] | The white image
        %> @param Inorm [hsi] | The normalization image
        %======================================================================
        function [] = NormalizationCheck(fig, varargin)
            % NormalizationCheck  plots the values recovered after normalization.
            %
            % For more details check @c function PlotNormalizationCheck .
            % The user needs to input a custom mask.
            % Disable in config::[disableReflectranceExtremaPlots].
            %
            % @b Usage
            % plots.NormalizationCheck(fig, Iin, Iblack, Iwhite, Inorm);
            % @endcode
            %
            % @param fig [int] | The figure handle
            % @param Iin [hsi] | The measurement image
            % @param Iblack [hsi] | The black image
            % @param Iwhite [hsi] | The white image
            % @param Inorm [hsi] | The normalization image
            %====================================================

            plots.Apply(fig, @PlotNormalizationCheck, varargin{:});
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
            config.SetSetting('plotName', config.DirMake(config.GetSetting('outputDir'), config.GetSetting('common'), 'samReferenceLibrarySpectra.png'));
            plots.Apply(fig, @PlotSpectra, spectra, wavelengths, names, figTitle, markers);
        end

        %======================================================================
        %> @brief Illumination  plots the illumination spectrum.
        %>
        %> The name of the illumination source is saved in config::[illuminationSource].
        %> Illumination information is saved in medHSI\\config::[paramDir]\\displayParam.mat
        %>
        %> @b Usage
        %> plots.Illumination();
        %> @endcode
        %======================================================================
        function [] = Illumination()
            % Illumination  plots the illumination spectrum.
            %
            % The name of the illumination source is saved in config::[illuminationSource].
            % Illumination information is saved in medHSI\\config::[paramDir]\\displayParam.mat
            %
            % @b Usage
            % plots.Illumination();
            % @endcode
            filename = commonUtility.GetFilename('param', 'displayParam');

            z = 401;
            lambdaIn = hsiUtility.GetWavelengths(z, 'raw');
            load(filename, 'illumination');

            fig = figure();
            plot(lambdaIn, illumination, 'DisplayName', config.GetSetting('illuminationSource'));
            config.SetSetting('plotName', fullfile(config.GetSetting('outputDir'), config.GetSetting('common'), 'illumination'));
            title('Illumination');
            xlabel('Wavelength (nm)');
            ylabel('Radiant Intensity (a.u.)');
            legend();
            plots.SavePlot(fig);
        end

        %======================================================================
        %> @brief ColorMatchingFunctions  plots the color matching functions.
        %>
        %> Information is saved in medHSI\\config::[paramDir]\\displayParam.mat
        %>
        %> @b Usage
        %> plots.ColorMatchingFunctions();
        %> @endcode
        %======================================================================
        function [] = ColorMatchingFunctions()
            % ColorMatchingFunctions  plots the color matching functions.
            %
            % Information is saved in medHSI\\config::[paramDir]\\displayParam.mat
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
            config.SetSetting('plotName', fullfile(config.GetSetting('outputDir'), config.GetSetting('common'), 'interpColorMatchingFunctions'));
            title('Interpolated Color Matching Functions');
            xlabel('Wavelength (nm)');
            ylabel('Weight (a.u.)');
            plots.SavePlot(fig);

        end

        %======================================================================
        %> @brief ChromophoreAbsorption  plots the skin chromophore absorption functions.
        %>
        %> Information is saved in config::[importDir]\\*.csv.
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
            % Information is saved in config::[importDir]\\*.csv.
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

            importDir = config.GetSetting('importDir');
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

            % config.SetSetting('saveEps', false);
            config.SetSetting('plotName', fullfile(config.GetSetting('outputDir'), config.GetSetting('common'), 'skinChromophoreExtinctionCoeff'));
            plots.SavePlot(fig);

            filename = commonUtility.GetFilename('param', 'extinctionCoefficients');
            save(filename, 'extCoeffEumelanin2', 'extCoeffHbO', 'extCoeffHbR', 'eumelaninLambda', 'hbLambda');

        end
    end
end