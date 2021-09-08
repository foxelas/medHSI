function [imCorr] = PlotBandCorrelation(inVectors, fig)
% PlotBandCorrelation plots the correlation among spectral bands
%
%   Usage:
%   [imCorr] = PlotBandCorrelation(inVectors, fig)

imCorr = corr(inVectors);
figure(fig);
imagesc(imCorr);
set(gca, 'XTick', 1:50:311, 'XTickLabel', [1:50:311]+420-1)
set(gca, 'YTick', 1:50:311, 'YTickLabel', [1:50:311]+420-1)
title('Correlation among bands');
c = colorbar;

SavePlot(fig)
end