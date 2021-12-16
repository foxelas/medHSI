function [mask, maskedPixels] = GetMaskFromFigure(hsi)
%GetMaskFromFigure returns a mask corresponding to a polygon selection on
%the figure, as well as the marked pixel vectors belogning to the mask.
%
%   Usage:
%   [mask, maskedPixels] = GetMaskFromFigure(I)

[~, ~, w] = size(hsi);
if w > 3
    Irgb = GetDisplayImage(hsi);
else
    Irgb = hsi;
end
[m, n, ~] = size(hsi);

mask = roipoly(Irgb);
title('Draw polygon')

maskedPixels = GetPixelsFromMask(hsi, mask);
end