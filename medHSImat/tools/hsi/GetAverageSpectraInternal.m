% ======================================================================
%> @brief GetAverageSpectraInternal returns average spectra for different masks.
%>
%> The target masks are set in an 3D array where the last dimension is the mask counter.
%> If the mask is missing, then the average of the entire image is
%> calculated.
%>
%> @b Usage
%>
%> @code
%> averages = GetAverageSpectraInternal(spectralData, subMasks);
%> @endcode
%>
%> @param obj [hsi] | An instance of the hsi class
%> @param subMasks [numeric array] | Optional: Array of submasks
%>
%> @retval averages [numeric array] | A stack of average spectra
%> for each mask. Each row is the average corresponding to a
%> submask.
% ======================================================================
function spectrumCurves = GetAverageSpectraInternal(hsi, subMasks)

hasMasks = nargin > 1;

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