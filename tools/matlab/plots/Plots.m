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
            SavePlot(fig);
        end
        
        function [] = MontageFolderContents(fig, path, criteria, figTitle)
            Plots.Apply(fig, @PlotMontageFolderContents, path, criteria, figTitle);
        end
        
        function [] = Superpixels(fig, baseImage, labels, figTitle, plotType, fgMask)
            Plots.Apply(fig, @PlotSuperpixels, baseImage, labels, figTitle, plotType, fgMask);
        end
        
        function [] = SubimageMontage(fig, hsi, figTitle, limit)
            Plots.Apply(fig, @PlotSubimageMontage, hsi, figTitle, limit);
        end
        
        function [] = Spectra(fig, spectra, wavelengths, names, figTitle)
            Plots.Apply(fig, @PlotSpectra, spectra, wavelengths, names, figTitle);
        end
        
        function [] = Overlay(fig, baseIm, topIm, figTitle)
            Plots.Apply(fig, @PlotOverlay, baseIm, topIm, figTitle);
        end
        
        function [] = Eigenvectors(fig, coeff, xValues, pcNum)
            Plots.Apply(fig, @PlotEigenvectors, coeff, xValues, pcNum);
        end
        
        function [] = DualMontage(fig, left, right, figTitle)
            Plots.Apply(fig, @PlotDualMontage, left, right, figTitle);
        end
        
        function [] = Dimred(method, dimredResult, w, redHsis)
            PlotDimred(method, dimredResult, w, redHsis);
        end
        
        function [] = Components(hsi, pcNum, figStart)
            PlotComponents(hsi, pcNum, figStart);
        end
        
        function [lineColorMap] = GetLineColorMap(style, names)
            [lineColorMap] = PlotGetLineColorMap(style, names);
        end
        
        function [imCorr] = BandStatistics(inVectors, statistic, fig)
            [imCorr] = PlotBandStatistics(inVectors, statistic, fig);
        end

    end
end