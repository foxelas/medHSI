function [redHsis] = ReconstructDimred(scores, imgSizes, masks)
% ReconstructDimred reconstructs reduced data to original dimension
%
%   Input arguments:
%   scores: reduced dimension data
%   imgSizes: cell array with original sizes of input data
%   masks: cell array of masks per data sample
%
%   Returns:
%   Reduced data with original spatial dimensions
%
%   Usage:
%   redHsis = ReconstructDimred(scores, imgSizes, masks);

sizeProd = cellfun(@(x) x(1)*x(2), imgSizes);
hasMask = size(scores, 1) ~= sum(sizeProd);

if ~hasMask % case where all image pixels are fed as input data
    splitIndexes = zeros(numel(sizeProd)-1, 1);
    splitIndexes(1) = sizeProd(1);
    for i = 2:numel(splitIndexes)
        splitIndexes(i) = sizeProd(i-1) + sizeProd(i) + 1 * (i - 1);
    end
else % case where only masked pixels are fed as input data
    splitIndexes = cellfun(@(x) size(x, 1), masks);
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

    if hasMask
        redHsi = RecoverReducedHsi(redHsi{i}, imgSizes{i}, masks{i});
    else
        redHsi = RecoverReducedHsi(redHsi{i}, imgSizes{i});
    end
    redHsis{i} = redHsi;
end


end