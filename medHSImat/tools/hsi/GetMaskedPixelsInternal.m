% ======================================================================
%> @brief GetMaskedPixelsInternal gets all spectral values included in a mask.
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
%> @param I [numeric array] | A 3D array of hyperspectral Data
%> @param inMask [numeric array] | A target mask
%>
%> @retval maskedPixels [numeric array] | A 2D array of pixel
%> spectra aligned vertically. One row is one pixel's spectrum
% ======================================================================
function [maskedPixels] = GetMaskedPixelsInternal(I, mask)
% GetMaskedPixelsInternal gets all spectral values included in a mask.
%
% If the mask is missing, a manually selected mask is assigned by
% a polygon selection prompt.
%
% @b Usage
%
% @code
% hsIm = GetMaskedPixelsInternal(I, mask);
% @endcode
%
% @param I [numeric array] | A 3D array of hyperspectral Data
% @param inMask [numeric array] | A target mask
%
% @retval maskedPixels [numeric array] | A 2D array of pixel
% spectra aligned vertically. One row is one pixel's spectrum

[m, n, w] = size(I);
IFlat = reshape(I, [m * n, w]);
maskFlat = reshape(mask, [m * n, 1]);
maskedPixels = IFlat(maskFlat, :);
end