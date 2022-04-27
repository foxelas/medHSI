% ======================================================================
%> @brief Nfindr applies the algorithm on an hsi object.
%>
%> When a foreground mask is provided, then nfindr is calculated using only the specimen pixels of the hsi, while ignoring the bakcground.
%>
%> @b Usage
%>
%> @code
%>  [endmembers] = NfindrInternal(hsIm.Value, 8, hsIm.FgMask);
%> @endcode
%>
%> @param target [numeric array] | An 3d array of the hsi value
%> @param numEndmembers [int] | The number of endmembers to calculate
%> @param fgMask [numeric array] | The foregound mask
%>
%> @retval endmembers [numeric array] |The calculated endmembers.
% ======================================================================
function [endmembers] = NfindrInternal(target, numEndmembers, fgMask)
% Nfindr applies the algorithm on an hsi object.
%
% When a foreground mask is provided, then nfindr is calculated using only the specimen pixels of the hsi, while ignoring the bakcground.
%
% @b Usage
%
% @code
%  [endmembers] = NfindrInternal(hsIm.Value, 8, hsIm.FgMask);
% @endcode
%
% @param target [numeric array] | An 3d array of the hsi value
% @param numEndmembers [int] | The number of endmembers to calculate
% @param fgMask [numeric array] | The foregound mask
%
% @retval endmembers [numeric array] |The calculated endmembers.

if ndims(target) < 3
    error('Needs more than 3 dimensions.');
end

hasFgMask = nargin > 2;

if hasFgMask
    n = sum(fgMask(:));
    F = factor(n);
    fgMask2 = fgMask;
    if ~(F(1) > 0 && F(1) ~= n)
        %%Add one pixels in the mask to enable a 3D structure so that nfindr can run
        fgMask2(1, 1) = 1;
        n = n + 1;
        F = factor(n);
    end
    colTarget = GetMaskedPixelsInternal(target, fgMask2);
    rtarget = reshape(colTarget, [n / F(1), F(1), size(colTarget, 2)]);
    endmembers = nfindr(rtarget, numEndmembers);
else
    endmembers = nfindr(target, numEndmembers);
end

end