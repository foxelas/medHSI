function [recHsi] = RecoverOriginalDimensionsInternal(redIm, origSize, mask)
% RecoverOriginalDimensionsInternal returns an image that matches the 
% spatial dimensions of the original hsi
%
%   Input arguments:
%   redIm: reduced dimension data (array or cell of arrays)
%   origSize: cell array with original sizes of input data (array or cell of arrays)
%   mask: cell array of masks per data sample (array or cell of arrays)
%
%   Returns:
%   Data with original spatial dimensions and reduced spectral dimensions
%
%   Usage:
%   [recHsi] = RecoverOriginalDimensionsInternal(redIm, origSize, mask)
%   [recHsis] = RecoverOriginalDimensionsInternal(scores, imgSizes, masks)

if iscell(origSize)
    imgSizes = origSize;
    scores = redIm;
    masks = mask;
    
    sizeProd = cellfun(@(x) x(1)*x(2), imgSizes);
    hasMask = size(scores, 1) ~= sum(sizeProd);

    if ~hasMask % case where all image pixels are fed as input data
        splitIndexes = zeros(numel(sizeProd)-1, 1);
        splitIndexes(1) = sizeProd(1);
        for i = 2:numel(splitIndexes)
            splitIndexes(i) = sizeProd(i-1) + sizeProd(i) + 1 * (i - 1);
        end
    else % case where only masked pixels are fed as input data
        splitIndexes = cellfun(@(x) sum(x, 'all'), masks);
    end

    redHsis = cell(numel(sizeProd), 1);
    for i = 1:numel(sizeProd)
        if i == 1
            splitIndex = splitIndexes(i);
            redHsi = scores(1:splitIndex, :);
        elseif i == numel(sizeProd)
            splitIndex = splitIndexes(i-1);
            redHsi = scores((splitIndex + 1):end, :);
        else
            splitIndex = splitIndexes(i-1);
            splitIndex2 = splitIndexes(i);
            redHsi = scores((splitIndex + 1):(splitIndex2), :);
        end

        % Uses recursion
        if hasMask
            redHsi = RecoverOriginalDimensionsInternal(redHsi, imgSizes{i}, masks{i});
        else
            redHsi = RecoverOriginalDimensionsInternal(redHsi, imgSizes{i});
        end
        redHsis{i} = redHsi;
    end
    recHsi = redHsis;
    
else
    m = origSize(1);
    n = origSize(2);
    q = size(redIm, 2);

    isMasked = nargin >= 3;
    if isMasked
        recHsi = zeros(m, n, q);
        outHsiFlat = reshape(recHsi, [m * n, q]);
        maskFlat = reshape(mask, [m * n, 1]);
        outHsiFlat(maskFlat, :) = redIm;
    else
        outHsiFlat = redIm;
    end

    recHsi = reshape(outHsiFlat, [m, n, q]);
end
end 