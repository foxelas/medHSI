function [maskedPixels] = GetPixelsFromMask(I, mask)

%% GetPixelsFromMask returns flattened pixels according to a 2D mask

[m, n, w] = size(I);
IFlat = reshape(I, [m * n, w]);
maskFlat = reshape(mask, [m * n, 1]);
maskedPixels = IFlat(maskFlat, :);
end