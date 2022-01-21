function [mask, maskedPixels] = GetMaskFromFigureInternal(hsIm)
%GetMaskFromFigure returns a mask corresponding to a polygon selection on
%the figure, as well as the marked pixel vectors belogning to the mask.
%
%   Usage:
%   [mask, maskedPixels] = GetMaskFromFigure(I)

[~, ~, w] = size(hsIm);
if w > 3
    Irgb = GetDisplayImageInternal(hsIm);
else
    Irgb = hsIm;
end
[m, n, ~] = size(hsIm);

mask = roipoly(Irgb);
title('Draw polygon')

maskedPixels = GetPixelsFromMaskInternal(hsIm, mask);
end