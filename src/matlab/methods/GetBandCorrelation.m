function [c] = GetBandCorrelation(I, hasPixelSelection)
%     GETBANDCORRELATION returns the array of band correlation for an msi I
%
%     Usage:
%     [c] = GetBandCorrelation(I)
%     [c] = GetBandCorrelation(I, hasPixelSelection)

if nargin < 2
    hasPixelSelection = false;
end

if ndims(I) > 2
    [b, m, n] = size(I);
    I = reshape(I, b, m*n)';
end

if hasPixelSelection
    spectralMean = mean(I, 2);
    spectralMax = max(I, [], 2);
    acceptablePixels = spectralMean > 0.2 & spectralMax < 0.99;
    tempI = I(acceptablePixels, :);
else
    tempI = I;
end
c = corr(tempI);
end