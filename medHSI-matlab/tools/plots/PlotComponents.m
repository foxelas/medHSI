function [] = PlotComponents(hsi, pcNum, figStart)
%PLOTCOMPONENTS plots a pcNum number of PCs, starting at figure figStart
%
%   Usage:
%   PlotComponents(hsi, 3, 4);

if nargin < 3
    figStart = 1;
end

plotName = config.GetSetting('plotName');
for i = 1:pcNum
    fig = figStart + i - 1;
    figure(fig);
    img = squeeze(hsi(:, :, i));
    mask = (img ~= 0);
    h = imagesc(img, 'AlphaData', mask);
    title(strcat('PC', num2str(i)));
    colorbar;
    config.SetSetting('plotName', strcat(plotName, num2str(i)));
    plots.SavePlot(fig);
end

end
