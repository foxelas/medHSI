classdef Plots
    methods(Static)
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


        function [] = Apply(fig, funcName, varargin)
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

            funcName(newVarargin{:});
        end
        
        function [] = SavePlot(fig)
%SAVEPLOT saves the plot shown in figure fig
%
%   Usage:
%   SavePlot(2);

            SavePlot(fig);
        end
        
        function [] = MontageFolderContents(fig, path, criteria, figTitle)
% PlotMontageFolderContents returns the images in a path as a montage
%
%   Usage:
%   PlotMontageFolderContents(path, criteria, figTitle, fig)
%
%   criteria = struct('TargetDir', 'subfolders', ...
%       'TargetName', strcat(target, '.jpg'), ...
%       'TargetType', 'fix');
%   Plots.MontageFolderContents(1, [], criteria);
            Plots.Apply(fig, @PlotMontageFolderContents, path, criteria, figTitle);
        end
        
        function [] = Superpixels(fig, baseImage, labels, figTitle, plotType, fgMask)
% PlotSuperpixels plots the results of superpixel segmentation on the image
%
%   Usage:
%   PlotSuperpixels(baseImage, labels, 'Superpixel Boundary of image 3', 'boundary', [], 1);
%   PlotSuperpixels(baseImage, labels, 'Superpixels of image 3', 'color', fgMask, 1);

            Plots.Apply(fig, @PlotSuperpixels, baseImage, labels, figTitle, plotType, fgMask);
        end
        
        function [] = SubimageMontage(fig, hsi, figTitle, limit)
% PlotSubimageMontage plots all or selected members of an hsi
% as a montage figure
%
%   Usage:
%   PlotSubimageMontage(hsi, figTitle, limit, fig);

            Plots.Apply(fig, @PlotSubimageMontage, hsi, figTitle, limit);
        end
        
        function [] = Spectra(fig, spectra, wavelengths, names, figTitle)
%%PLOTSPECTRA plots one or more spectra together
%
%   Usage:
%   PlotSpectra(spectra, wavelengths, names, figTitle, fig);
%   PlotSpectra(spectra)

            Plots.Apply(fig, @PlotSpectra, spectra, wavelengths, names, figTitle);
        end
        
        function [] = Overlay(fig, baseIm, topIm, figTitle)
% PlotOverlay plots an image with an overlay mask
%
%   Usage:
%   PlotOverlay(baseIm, topIm, figTitle, fig)

            Plots.Apply(fig, @PlotOverlay, baseIm, topIm, figTitle);
        end
        
        function [] = Eigenvectors(fig, coeff, xValues, pcNum)
% PlotEigenvectors plots eigenvectors of a deconmposition
%
%   Usage:
%   PlotEigenvectors(coeff, xValues, pcNum, fig)

            Plots.Apply(fig, @PlotEigenvectors, coeff, xValues, pcNum);
        end
        
        function [] = DualMontage(fig, left, right, figTitle)
            Plots.Apply(fig, @PlotDualMontage, left, right, figTitle);
        end
        
        function [] = Dimred(method, dimredResult, w, redHsis)
            PlotDimred(method, dimredResult, w, redHsis);
        end
        
        function [] = Components(hsi, pcNum, figStart)
%PLOTCOMPONENTS plots a pcNum number of PCs, starting at figure figStart
%
%   Usage:
%   PlotComponents(hsi, 3, 4);

            PlotComponents(hsi, pcNum, figStart);
        end
        
        function [lineColorMap] = GetLineColorMap(style, names)
%     PLOTGETLINECOLORMAP returns a linecolor map based on the style
%
%     Usage:
%     [lineColorMap] = PlotGetLineColorMap('class')

            [lineColorMap] = PlotGetLineColorMap(style, names);
        end
        
        function [imCorr] = BandStatistics(inVectors, statistic, fig)
% PlotBandStatistics plots the correlation among spectral bands
%
%   Usage:
%   [imCorr] = PlotBandStatistics(inVectors, 'correlation', fig)
%   [imCorr] = PlotBandStatistics(inVectors, 'covariance', fig)

            [imCorr] = PlotBandStatistics(inVectors, statistic, fig);
        end

    end
end