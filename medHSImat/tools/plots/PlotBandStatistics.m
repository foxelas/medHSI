function [imCorr] = PlotBandStatistics(inVectors, statistic, fig)
% PlotBandStatistics plots the correlation among spectral bands
%
%   Usage:
%   [imCorr] = PlotBandStatistics(inVectors, 'correlation', fig)
%   [imCorr] = PlotBandStatistics(inVectors, 'covariance', fig)

if strcmpi(statistic, 'correlation')
    imCorr = corr(inVectors);
    figTitle = 'Correlation among bands';
elseif strcmpi(statistic, 'covariance')
    imCorr = cov(inVectors);
    figTitle = 'Covariance among bands';
else
    error('Unsupported statistic');
end

figure(fig);
imagesc(imCorr);
set(gca, 'XTick', 1:50:311, 'XTickLabel', [1:50:311]+420-1)
set(gca, 'YTick', 1:50:311, 'YTickLabel', [1:50:311]+420-1)
title(figTitle);
c = colorbar;

SavePlot(fig)
end