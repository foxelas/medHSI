function [] = PlotSuperpixels(baseImage, labels, figTitle, plotType, fgMask, fig)
% PlotSuperpixels plots the results of superpixel segmentation on the image
%
%   Usage:
%   PlotSuperpixels(baseImage, labels, 'Superpixel Boundary of image 3', 'boundary', [], 1);
%   PlotSuperpixels(baseImage, labels, 'Superpixels of image 3', 'color', fgMask, 1);

if ~isempty(plotType) && strcmpi(plotType, 'color') % isColor = 'color'
    labels = labels + 1; % To remove label 0, because labeloverlay ignores it 
    labels(~fgMask) = 0;
    B = labeloverlay(baseImage, labels);
    imshow(B);
    
else % isColor = 'boundary'
    BW = boundarymask(labels);
    imshow(imoverlay(baseImage, BW, 'cyan'), 'InitialMagnification', 67);
end

title(figTitle);
SavePlot(fig);

end