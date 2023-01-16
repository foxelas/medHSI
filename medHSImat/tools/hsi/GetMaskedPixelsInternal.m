% ======================================================================
%> @brief GetMaskedPixelsInternal gets all spectral values included in a mask.
%>
%> If the input is a cell array, GetMaskedPixelsInternal is applied on each element of the cell array.
%>
%> If the mask is missing, a manually selected mask is assigned by
%> a polygon selection prompt.
%>
%> @b Usage
%>
%> @code
%> hsIm = GetMaskedPixelsInternal(I, mask);
%> @endcode
%>
%> @param I [numeric array or cell array] | A 3D array of hyperspectral Data
%> @param inMask [numeric array] | A target mask
%>
%> @retval maskedPixels [numeric array or cell array] | A 2D array of pixel
%> spectra aligned vertically. One row is one pixel's spectrum
% ======================================================================
function [maskedPixels] = GetMaskedPixelsInternal(I, mask)

if ~islogical(mask)
    mask = logical(mask);
end

if iscell(I)
    imgs = I;
    n = numel(imgs);
    maskedPixels = cell(n, 1);
    for i = 1:n
        I = imgs{i};
        maskedPixels{i} = GetMaskedPixelsInternal(I, mask);
    end
else
    [m, n, w] = size(I);
    IFlat = reshape(I, [m * n, w]);
    maskFlat = reshape(mask, [m * n, 1]);
    maskedPixels = IFlat(maskFlat, :);
end
end