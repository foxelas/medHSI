%======================================================================
%> @brief PlotBandStatistics plots statistics among spectral bands.
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
function [imCorr] = PlotBandStatistics(inVectors, statistic, fig)
% PlotBandStatistics plots statistics among spectral bands.
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

plots.SavePlot(fig);

end