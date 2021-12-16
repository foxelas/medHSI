function [newI, idxs] = GetQualityPixelsInternal(I, meanLimit, maxLimit)
%     GETQUALITYPIXELS removes over-saturated and under-exposed pixels from base image
%
%     Usage:
%     [newI, idxs] = GetQualityPixels(I, meanLimit, maxLimit)

if nargin < 2
    meanLimit = 0.2;
end
if nargin < 3
    maxLimit = 0.99;
end

if ndims(I) == 2
    spectralMean = mean(I, 2);
    spectralMax = max(I, [], 2);
    idxs = spectralMean > meanLimit & spectralMax < maxLimit & spectralMean > 0;
    newI = I(idxs, :);
else
    [m, n, w] = size(I);
    I2d = reshape(I, [m * n, w]);
    [newI, idxs] = GetQualityPixelsinternal(I2d, meanLimit, maxLimit);
end
end