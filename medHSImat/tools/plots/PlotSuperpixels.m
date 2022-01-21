function [] = PlotSuperpixels(baseImage, labels, figTitle, plotType, fgMask, fig)
% PlotSuperpixels plots the results of superpixel segmentation on the image
%
%   Usage:
%   PlotSuperpixels(baseImage, labels, 'Superpixel Boundary of image 3', 'boundary', [], 1);
%   PlotSuperpixels(baseImage, labels, 'Superpixels of image 3', 'color', fgMask, 1);

if ~isempty(plotType) && strcmpi(plotType, 'color') % isColor = 'color'
    if ~isempty(fgMask)
        v = labels(fgMask);
        a = unique(v);
        counts = histc(v(:), a);
        specimenSuperpixelIds = a(counts > 300)';
    else
        specimenSuperpixelIds = 1:length(unique(v));
    end
    B = labeloverlay(baseImage, labels, 'IncludedLabels', specimenSuperpixelIds);
    imshow(B);
else % isColor = 'boundary'
    BW = boundarymask(labels);
    imshow(imoverlay(baseImage, BW, 'cyan'), 'InitialMagnification', 67);
end

title(figTitle);
SavePlot(fig);

end