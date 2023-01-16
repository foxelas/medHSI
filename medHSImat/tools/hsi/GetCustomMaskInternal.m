% ======================================================================
%> @brief GetCustomMaskInternal returns a manually drawn polygon mask.
%>
%> If the mask is missing, a manually selected mask is assigned by
%> a polygon selection prompt.
%>
%> @b Usage
%>
%> @code
%> hsIm = GetCustomMaskInternal(spectralData);
%> @endcode
%>
%> @param I [numeric array] | A 3D array of hyperspectral Data
%>
%> @retval customMask [numeric array] | A custom mask
% ======================================================================
function [mask] = GetCustomMaskInternal(I)

[~, ~, w] = size(I);

%% Draw polygon mask
if w > 3
    Irgb = GetDisplayImageInternal(I);
else
    Irgb = I;
end

fig = figure;
title('Draw a polygon on the figure');
mask = roipoly(Irgb);
title('Draw a polygon on the figure');

if ~islogical(mask)
    mask = logical(mask);
end
close(fig);
end