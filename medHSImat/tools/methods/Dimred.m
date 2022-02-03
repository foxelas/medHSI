function [coeff, scores, latent, explained, objective, Mdl] = Dimred(X, method, q, labels)
%Dimred reduces the dimensions of a dataset
%
%   Input arguments
%   X: input data as a matrix with M observations and N columns
%   methods: 'rica', 'pca'
%   q: number of components to be retained
%   labels: needed for the case of supervised dimension reduction
%
%   Usage:
%   [coeff, scores, latent, explained, objective] = Dimred(X, method, q)
%   [coeff, scores, latent, explained, ~] = Dimred(X, 'pca', 10)
%   [coeff, scores, ~, ~, objective] = Dimred(X, 'rica', 40)
%   [~, scores, ~, ~, ~, Mdl] = Dimred(X, 'lda')


latent = [];
explained = [];
objective = [];
Mdl = []; 
coeff = [];

if nargin < 3
    q = 10;
end

if nargin < 4 
    labels = [];
end 

%% PCA
if strcmpi(method, 'pca')
    [coeff, scores, latent, tsquared, explained] = pca(X, 'NumComponents', q);
end

%% RICA
if strcmpi(method, 'rica')
    rng default % For reproducibility
    Mdl = rica(X, q, 'IterationLimit', 100, 'Lambda', 1);
    coeff = Mdl.TransformWeights;
    scores = X * coeff;
    objective = Mdl.FitInfo.Objective;
end

%% Discriminant Analysis (LDA / QDA)
if isempty(labels) && strcmpi(method, 'lda') && strcmpi(method, 'qda')
  error('A supervised method requires labels as argument');
else
    if strcmp(method, 'lda')
        Mdl = fitcdiscr(X,labels);
        scores = predict(Mdl, X);
    end
    
    if strcmp(method, 'qda')
        Mdl = fitcdiscr(X,labels,'DiscrimType','quadratic');
        scores = predict(Mdl, X);
    end
end 
 
%% SuperPCA
if strcmpi(method, 'superpca')
    pixelNum = 5;
    %%super-pixels segmentation
    superpixels = cubseg(X, pixelNum);

    %%SupePCA based DR
    scores = SuperPCA(X, q, superpixels);
end
end
