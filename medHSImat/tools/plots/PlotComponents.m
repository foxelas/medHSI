%======================================================================
%> @brief PlotComponents plots the components of a hyperspectral image.
%>
%> @b Usage
%>
%> @code
%> plots.Components(fig, hsIm, pcNum, 1, '\temp\folder\img');
%> @endcode
%>
%> @param hsIm [hsi] | An instance of the hsi class
%> @param pcNum [int] | The number of components
%> @param fig [int] | The figure handle
%> @param plotBasePath [char] | The base path for saving plot figures
%======================================================================
function [] = PlotComponents(hsIm, pcNum, figStart, plotBasePath)
% PlotComponents plots the components of a hyperspectral image.
%
% @b Usage
%
% @code
% plots.Components(fig, hsIm, pcNum, 1, '\temp\folder\img');
% @endcode
%
% @param hsIm [hsi] | An instance of the hsi class
% @param pcNum [int] | The number of components
% @param fig [int] | The figure handle
% @param plotBasePath [char] | The base path for saving plot figures

if isempty(figStart)
    figStart = 1;
end

for i = 1:pcNum
    fig = figStart + i - 1;
    figure(fig);
    img = squeeze(hsIm(:, :, i));
    mask = (img ~= 0);
    h = imagesc(img, 'AlphaData', mask);
    axis image;
    title(strcat('PC', num2str(i)));
    colorbar;
    plotPath = strcat(plotBasePath, num2str(i));
    plots.SavePlot(fig, plotPath);
end

end
