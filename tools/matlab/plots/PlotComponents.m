function [] = PlotComponents(hsi, pcNum, figStart)
%PLOTCOMPONENTS plots a pcNum number of PCs, starting at figure figStart
%
%   Usage:
%   PlotComponents(hsi, 3, 4);

if nargin < 3 
    figStart = 1; 
end 

for i = 1:pcNum
    figure(figStart + i - 1);
    img = squeeze(hsi(:, :, i));
    mask = (img ~= 0);
    h = imagesc(img, 'AlphaData', mask);
    title(strcat('PC', num2str(i)));
    colorbar;
    % SavePlot(fig);
end 

end 
