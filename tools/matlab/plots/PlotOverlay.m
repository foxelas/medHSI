function [] = PlotOverlay(baseIm, topIm, figTitle, fig)
% PlotOverlay plots an image with an overlay mask
%
%   Usage:
%   PlotOverlay(baseIm, topIm, figTitle, fig)

hasTitle = true;
if nargin < 4
    hasTitle = isnumeric(figTitle);
    if ~hasTitle
        fig = figTitle;
        figTitle = '';
    end
end

imshow(imoverlay(baseIm, topIm, 'cyan'), 'InitialMagnification', 67);
if hasTitle
    title(figTitle);
end

SavePlot(fig);
warning('on');

end
