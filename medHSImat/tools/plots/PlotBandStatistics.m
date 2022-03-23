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
%> @param inVectors [numeric array] | The input vectors
%> @param statistic [char] | The statistic name
%> @param figTitle [char] | The figure title
%> @param fig [int] | The figure handle
%>
%> @retval imCorr [numeric array] | The statistics values
%======================================================================
function [imCorr] = PlotBandStatistics(inVectors, statistic, figTitle, fig)
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
% @param inVectors [numeric array] | The input vectors
% @param statistic [char] | The statistic name
% @param figTitle [char] | The figure title
% @param fig [int] | The figure handle
%
% @retval imCorr [numeric array] | The statistics values

if strcmpi(statistic, 'correlation')
    imCorr = corr(inVectors);
    if isempty(figTitle)
        figTitle = 'Correlation among bands';
    end
elseif strcmpi(statistic, 'covariance')
    imCorr = cov(inVectors);
    if isempty(figTitle)
        figTitle = 'Covariance among bands';
    end
else
    error('Unsupported statistic');
end

figure(fig);
imagesc(imCorr);
set(gca, 'XTick', 1:50:311, 'XTickLabel', [1:50:311]+420-1)
set(gca, 'YTick', 1:50:311, 'YTickLabel', [1:50:311]+420-1)
title(figTitle);
c = colorbar;
title(figTtitle)

plots.SavePlot(fig);

end