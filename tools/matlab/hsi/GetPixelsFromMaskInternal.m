function [maskedPixels] = GetPixelsFromMaskInternal(hsi, mask)

%% GetPixelsFromMask returns flattened pixels according to a 2D mask

[m, n, w] = size(hsi);
IFlat = reshape(hsi, [m * n, w]);
maskFlat = reshape(mask, [m * n, 1]);
maskedPixels = IFlat(maskFlat, :);
end