%======================================================================
%> @brief PlotComponents plots the components of a hyperspectral image.
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
function [] = PlotComponents(hsIm, pcNum, figStart)
% PlotComponents plots the components of a hyperspectral image.
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

if nargin < 3
    figStart = 1;
end

plotName = config.GetSetting('plotName');
for i = 1:pcNum
    fig = figStart + i - 1;
    figure(fig);
    img = squeeze(hsIm(:, :, i));
    mask = (img ~= 0);
    h = imagesc(img, 'AlphaData', mask);
    axis image;
    title(strcat('PC', num2str(i)));
    colorbar;
    config.SetSetting('plotName', strcat(plotName, num2str(i)));
    plots.SavePlot(fig);
end

end
