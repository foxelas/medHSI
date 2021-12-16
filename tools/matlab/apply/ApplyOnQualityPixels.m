function [varargout] = ApplyOnQualityPixels(func, varargin)
% APPLYONQUALITYPIXELS Apply a function on only goog quality functions.
%
%   Usage:
%   [coeff] = ApplyOnQualityPixels(@doPixelPCA, colMsi);
%   applies function 'doPixelPCA' on good quality pixels of array colMsi

dataCol = varargin{1};
fullLength = size(dataCol, 1);
[goodDataCol, goodIdxs] = getQualityPixels(dataCol);
goodLength = size(goodDataCol, 1);
varargin{1} = goodDataCol;
[varargout{1:nargout}] = func(varargin{:});
for i = 1:length(varargout)
    target = varargout{i};
    fullLengthIdx = find(size(target) == goodLength);
    if ~isempty(fullLengthIdx) && length(fullLengthIdx) == 1 && ismatrix(target)
        newSize = size(target);
        newSize(fullLengthIdx) = fullLength;
        newTarget = zeros(newSize);
        if ndims(newTarget) == 1
            newTarget(goodIdxs) = target;
        elseif ndims(newTarget) == 2
            if fullLengthIdx == 1
                newTarget(goodIdxs, :) = target;
            else
                newTarget(:, goodIdxs) = target;
            end
        else
            if fullLengthIdx == 1
                newTarget(goodIdxs, :, :) = target;
            elseif fullLengthIdx == 2
                newTarget(:, goodIdxs, :) = target;
            else
                newTarget(:, :, goodIdxs) = target;
            end
        end
        varargout{i} = newTarget;
    end
end
end