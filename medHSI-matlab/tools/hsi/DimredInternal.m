function [coeff, scores, latent, explained, objective] = DimredInternal(X, method, q, mask)
%Dimred reduces the dimensions of an image dataset
%
%   Input arguments
%   X: input data as a matrix with MxN observations and Z columns
%   methods: 'rica', 'pca'
%   q: number of components to be retained
%   mask: 2x2 logical array marking pixels to be used in PCA calculation
%
%   Usage:
%   [coeff, scores, latent, explained, objective] = Dimred(X, method, q, mask)
%   [coeff, scores, latent, explained, ~] = Dimred(X, 'pca', 10)
%   [coeff, scores, ~, ~, objective] = Dimred(X, 'rica', 40)


hasMask = nargin > 3;

if hasMask
    Xcol = GetPixelsFromMaskInternal(X, mask);
else
    Xcol = reshape(X, [size(X, 1) * size(X, 2), size(X, 3)]);
end


[coeff, scores, latent, explained, objective] = Dimred(Xcol, method, q);

if hasMask
    scores = hsiutility.RecoverReducedHsi(scores, size(X), mask);
else
    scores = reshape(scores, [size(X, 1), size(X, 2), q]);
end

end