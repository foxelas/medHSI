% ======================================================================
%> @brief FindPurePixelsInternal applies the algorithm on an hsi object.
%>
%> When a foreground mask is provided, then pure pixels are calculated using only the specimen pixels of the hsi, while ignoring the bakcground.
%>
%> @b Usage
%>
%> @code
%> [endmembers] = hsIm.FindPurePixels(8, 'nfindr', reductionMethod);
%>
%> [endmembers] = FindPurePixelsInternal(hsIm.Value, 8, hsIm.FgMask, 'nfindr', reductionMethod);
%> @endcode
%>
%> @param target [numeric array] | An 3d array of the hsi value
%> @param numEndmembers [int] | The number of endmembers to calculate
%> @param fgMask [numeric array] | The foregound mask
%> @param method [char] | Optional: The method to find pure pixels. Options: ['NFindr', 'ppi', 'fippi']. Default: 'NFindr'.
%> @param reductionMethod [char] | Optional: The reduction method. Options: ['PCA', 'MNF']. Default: 'MNF'.
%>
%> @retval endmembers [numeric array] |The calculated endmembers.
% ======================================================================
function [endmembers] = FindPurePixelsInternal(target, numEndmembers, fgMask, method, reductionMethod)

if ndims(target) < 3
    error('Needs more than 3 dimensions.');
end

if nargin < 3 
    fgMask  = []; 
end 

if nargin < 4
    method = 'NFindr';
end

if nargin < 5
    reductionMethod = 'MNF';
end

hasFgMask = ~isempty(fgMask);

rtarget = target;

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
end

switch lower(method)
    case lower('Nfindr')
        endmembers = nfindr(rtarget, numEndmembers, 'ReductionMethod', reductionMethod);
    case lower('ppi')
        endmembers = ppi(rtarget, numEndmembers, 'ReductionMethod', reductionMethod);
    case lower('fippi')
        endmembers = fippi(rtarget, numEndmembers, 'ReductionMethod', reductionMethod);
    otherwise 
        error('Unavailable method for pure pixel calculation.');
end

end