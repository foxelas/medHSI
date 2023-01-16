% ======================================================================
%> @brief GetFgMaskInternal gets the foreground mask for an hsi cube.
%>
%> The background pixels are set with uniform value 0.
%>
%> If the mask is missing, a manually selected mask is assigned by
%> a polygon selection prompt.
%>
%> @b Usage
%>
%> @code
%> fgMask = GetFgMaskInternal(hsIm);
%> @endcode
%>
%> @param hsIm [hsi] | An instance of the hsi class
%>
%> @rertval fgMask [numerical array] | A 2D logical array marking pixels to be used in PCA calculation
% ======================================================================
function fgMask = GetFgMaskInternal(hsIm)

if ndims(hsIm) > 3
    srgb = GetDisplayImage(hsIm, 'rgb');
else
    srgb = hsIm;
end
fgMask = ~(squeeze(srgb(:, :, 1)) == 0 & squeeze(srgb(:, :, 1)) == 0 & squeeze(srgb(:, :, 1)) == 0);

end