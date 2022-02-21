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

            plots.SavePlot(fig);
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
        %> @b Optional
        %> @param names [cell array] | The line group names
        %>
        %> @retval lineColorMap [map] | The line color map
        %======================================================================
        function [lineColorMap] = GetLineColorMap(varargin)
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
        % @b Optional
        % @param names [cell array] | The line group names
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

        function [] = AverageSpectrum(fig, varargin)
            %%PlotAverageSpectrum plots the values recovered after normalization
            %   user needs to input a mask
            %
            %   Usage:
            %   PlotsNormalizationCheck(Inorm, figName, fig)
            %   plots.NormalizationCheck(fig, figName, Inorm)

            plots.Apply(fig, @PlotAverageSpectrum, varargin{:});
        end

        function [] = Components(varargin)
            %PLOTCOMPONENTS plots a pcNum number of PCs, starting at figure figStart
            %
            %   Usage:
            %   PlotComponents(hsi, 3, 4);

            PlotComponents(varargin{:});
        end

        function [] = Eigenvectors(fig, varargin)
            % PlotEigenvectors plots eigenvectors of a deconmposition
            %
            %   Usage:
            %   PlotEigenvectors(coeff, xValues, pcNum, fig)

            plots.Apply(fig, @PlotEigenvectors, varargin{:});
        end

        %% Images %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [] = Overlay(fig, varargin)
            % PlotOverlay plots an image with an overlay mask
            %
            %   Usage:
            %   PlotOverlay(baseIm, topIm, figTitle, fig)

            plots.Apply(fig, @PlotOverlay, varargin{:});
        end

        function [] = Dimred(method, dimredResult, w, redHsis)
            PlotDimred(method, dimredResult, w, redHsis);
        end

        function [] = Superpixels(fig, varargin)
            % PlotSuperpixels plots the results of superpixel segmentation on the image
            %
            %   Usage:
            %   PlotSuperpixels(baseImage, labels, 'Superpixel Boundary of image 3', 'boundary', [], 1);
            %   PlotSuperpixels(baseImage, labels, 'Superpixels of image 3', 'color', fgMask, 1);

            plots.Apply(fig, @PlotSuperpixels, varargin{:});
        end

        %% Multi-image %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function [] = MontageFolderContents(fig, varargin)
            % PlotMontageFolderContents returns the images in a path as a montage
            %
            %   Usage:
            %   PlotMontageFolderContents(path, criteria, figTitle, standardDim, imageLimit, fig)
            %
            %   criteria = struct('TargetDir', 'subfolders', ...
            %       'TargetName', strcat(target, '.jpg'), ...
            %       'TargetType', 'fix');
            %   plots.MontageFolderContents(1, [], criteria, [500, 500], 20);
            plots.Apply(fig, @PlotMontageFolderContents, varargin{:});
        end

        function [] = SubimageMontage(fig, varargin)
            % PlotSubimageMontage plots all or selected members of an hsi
            % as a montage figure
            %
            %   Usage:
            %   PlotSubimageMontage(hsi, figTitle, limit, fig);

            plots.Apply(fig, @PlotSubimageMontage, varargin{:});
        end

        function [] = DualMontage(fig, varargin)
            plots.Apply(fig, @PlotDualMontage, varargin{:});
        end

        %% Checks %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [] = NormalizationCheck(fig, varargin)
            %%PlotNormalizationCheck plots the values recovered after normalization
            %   user needs to input a mask
            %
            %   Usage:
            %   PlotsNormalizationCheck(Iin, Iblack, Iwhite, Inorm, fig)
            %   plots.NormalizationCheck(fig, Iin, Iblack, Iwhite, Inorm)

            plots.Apply(fig, @PlotNormalizationCheck, varargin{:});
        end

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
            config.SetSetting('plotName', config.DirMake(config.GetSetting('outputDir'), config.GetSetting('common'), 'samReferenceLibrarySpectra.png'));
            plots.Apply(fig, @PlotSpectra, spectra, wavelengths, names, figTitle, markers);
        end

    end
end