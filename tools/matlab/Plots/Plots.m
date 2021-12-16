classdef Plots
    methods (Static)

        %% Contents
        %
        %   Static:
        %         Apply(fig, funcName, varargin)
        %         SavePlot(fig)
        %         MontageFolderContents(fig, path, criteria, figTitle)
        %         Superpixels(fig, baseImage, labels, figTitle, plotType, fgMask)
        %         SubimageMontage(fig, hsi, figTitle, limit)
        %         Spectra(fig, spectra, wavelengths, names, figTitle)
        %         Overlay(fig, baseIm, topIm, figTitle)
        %         DualMontage(fig, left, right, figTitle)
        %         Dimred(method, dimredResult, w, redHsis)
        %         Components(hsi, pcNum, figStart)
        %         [imCorr] = BandStatistics(inVectors, statistic, fig)
        %         [lineColorMap] = GetLineColorMap(style, names)


        function [varargout] = Apply(fig, funcName, varargin)
            %PLOTS wraps plotting functions
            %
            %   Usage:
            %   Plots(fig, funcName, varargin) plots function with funcName and
            %   arguments varargin in figure fig
            %   Plots(1, @PlotSpectra, spectra)

            if isnumeric(fig) && ~isempty(fig)
                %disp('Check if no overlaps appear and correct fig is saved.')
                figure(fig);
                clf(fig);
            else
                fig = gcf;
            end

            newVarargin = varargin;
            expectedArgs = nargin(funcName);
            for i = (length(newVarargin) + 1):(expectedArgs - 1)
                newVarargin{i} = [];
            end
            newVarargin{length(newVarargin)+1} = fig;

            if nargout(funcName) > 0
                varargout{:} = funcName(newVarargin{:});
            else
                funcName(newVarargin{:});
                varargout{:} = {};
            end

        end

        function [] = SavePlot(fig)
            %SAVEPLOT saves the plot shown in figure fig
            %
            %   Usage:
            %   SavePlot(2);

            SavePlot(fig);
        end

        function [] = MontageFolderContents(fig, varargin)
            % PlotMontageFolderContents returns the images in a path as a montage
            %
            %   Usage:
            %   PlotMontageFolderContents(path, criteria, figTitle, fig)
            %
            %   criteria = struct('TargetDir', 'subfolders', ...
            %       'TargetName', strcat(target, '.jpg'), ...
            %       'TargetType', 'fix');
            %   Plots.MontageFolderContents(1, [], criteria);
            Plots.Apply(fig, @PlotMontageFolderContents, varargin{:});
        end

        function [] = Superpixels(fig, varargin)
            % PlotSuperpixels plots the results of superpixel segmentation on the image
            %
            %   Usage:
            %   PlotSuperpixels(baseImage, labels, 'Superpixel Boundary of image 3', 'boundary', [], 1);
            %   PlotSuperpixels(baseImage, labels, 'Superpixels of image 3', 'color', fgMask, 1);

            Plots.Apply(fig, @PlotSuperpixels, varargin{:});
        end

        function [] = SubimageMontage(fig, varargin)
            % PlotSubimageMontage plots all or selected members of an hsi
            % as a montage figure
            %
            %   Usage:
            %   PlotSubimageMontage(hsi, figTitle, limit, fig);

            Plots.Apply(fig, @PlotSubimageMontage, varargin{:});
        end

        function [] = Spectra(fig, varargin)
            %%PLOTSPECTRA plots one or more spectra together
            %
            %   Usage:
            %   PlotSpectra(spectra, wavelengths, names, figTitle, fig);
            %   PlotSpectra(spectra)

            Plots.Apply(fig, @PlotSpectra, varargin{:});
        end

        function [] = Overlay(fig, varargin)
            % PlotOverlay plots an image with an overlay mask
            %
            %   Usage:
            %   PlotOverlay(baseIm, topIm, figTitle, fig)

            Plots.Apply(fig, @PlotOverlay, varargin{:});
        end

        function [] = Eigenvectors(fig, varargin)
            % PlotEigenvectors plots eigenvectors of a deconmposition
            %
            %   Usage:
            %   PlotEigenvectors(coeff, xValues, pcNum, fig)

            Plots.Apply(fig, @PlotEigenvectors, varargin{:});
        end

        function [] = DualMontage(fig, varargin)
            Plots.Apply(fig, @PlotDualMontage, varargin{:});
        end

        function [] = Dimred(method, dimredResult, w, redHsis)
            PlotDimred(method, dimredResult, w, redHsis);
        end

        function [] = Components(varargin)
            %PLOTCOMPONENTS plots a pcNum number of PCs, starting at figure figStart
            %
            %   Usage:
            %   PlotComponents(hsi, 3, 4);

            PlotComponents(varargin{:});
        end

        function [lineColorMap] = GetLineColorMap(varargin)
            %     PLOTGETLINECOLORMAP returns a linecolor map based on the style
            %
            %     Usage:
            %     [lineColorMap] = PlotGetLineColorMap('class')

            [lineColorMap] = PlotGetLineColorMap(varargin{:});
        end

        function [imCorr] = BandStatistics(fig, varargin)
            % PlotBandStatistics plots the correlation among spectral bands
            %
            %   Usage:
            %   [imCorr] = PlotBandStatistics(inVectors, 'correlation', fig)
            %   [imCorr] = PlotBandStatistics(inVectors, 'covariance', fig)

            [imCorr] = Plots.Apply(fig, @PlotBandStatistics, varargin{:});
        end

    end
end