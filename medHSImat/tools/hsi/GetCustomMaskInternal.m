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
% GetCustomMaskInternal returns a manually drawn polygon mask.
%
% If the mask is missing, a manually selected mask is assigned by
% a polygon selection prompt.
%
% @b Usage
%
% @code
% hsIm = GetCustomMaskInternal(spectralData);
% @endcode
%
% @param I [numeric array] | A 3D array of hyperspectral Data
%
% @retval customMask [numeric array] | A custom mask

[~, ~, w] = size(I);

%% Draw polygon mask
if w > 3
    Irgb = GetDisplayImageInternal(I);
else
    Irgb = I;
end

figure(1);
mask = roipoly(Irgb);
title('Draw polygon')

end