function [coeff, scores, latent, explained, objective] = Dimred(X, method, q)
%Dimred reduces the dimensions of a dataset
%
%   Input arguments
%   X: input data as a matrix with M observations and N columns
%   methods: 'rica', 'pca'
%   q: number of components to be retained
%
%   Usage:
%   [coeff, scores, latent, explained, objective] = Dimred(X, method, q)
%   [coeff, scores, latent, explained, ~] = Dimred(X, 'pca', 10)
%   [coeff, scores, ~, ~, objective] = Dimred(X, 'rica', 40)

latent = [];
explained = [];
objective = [];

if nargin < 3
    q = 10;
end

%% PCA
if strcmp(method, 'pca')
    [coeff, scores, latent, tsquared, explained] = pca(X, 'NumComponents', q);
end

%% RICA
if strcmp(method, 'rica')
    rng default % For reproducibility
    Mdl = rica(X, q, 'IterationLimit', 100, 'Lambda', 1);
    coeff = Mdl.TransformWeights;
    scores = X * coeff;
    objective = Mdl.FitInfo.Objective;
end

end
