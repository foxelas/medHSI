function spectrumCurves = GetSpectraFromMaskInternal(hsi, subMasks, targetMask)
%%GetSpectraFromMask returns the average spectrum of a specific ROI mask
%
%   Usage:
%   spectrumCurves = GetSpectraFromMask(target, subMasks, targetMask)

hasMasks = nargin > 1;

if nargin > 2
    hsi = cropROI(hsi, targetMask);
end

[~, ~, w] = size(hsi);

if hasMasks
    y = size(subMasks, 3);
    spectrumCurves = zeros(y, w);

    isSinglePoint = sum(subMasks(:, :, 1), 'all') == 1;
    for k = 1:y
        subMask = subMasks(:, :, k);
        patchSpectra = cropROI(hsi, subMask);
        if isSinglePoint
            spectrumCurves(k, :) = patchSpectra;
        else
            spectrumCurves(k, :) = mean(reshape(patchSpectra, [size(patchSpectra, 1) * size(patchSpectra, 2), w]));
        end
    end
else
    spectrumCurves = zeros(1, w);
    spectrumCurves(1, :) = mean(reshape(hsi, [size(hsi, 1) * size(hsi, 2), w]));
end

end

function hsiOut = cropROI(hsiIn, cropMask)
%has opposite indexes because of any()
hsiOut = hsiIn(any(cropMask, 2), any(cropMask, 1), :);
end