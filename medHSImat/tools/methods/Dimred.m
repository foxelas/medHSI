% ======================================================================
%> @brief Dimred reduces the dimensions of the hyperspectral image.
%>
%> Currently PCA, RICA, SuperPCA, LDA, QDA are available. For more
%> details check @c function Dimred.
%>
%> @b Usage
%>
%> @code
%> q = 10;
%> [coeff, scores, latent, explained, objective] = Dimred(X,
%> method, q, mask);
%>
%> [coeff, scores, latent, explained, ~] = Dimred(X, 'pca', 10);
%>
%> [coeff, scores, ~, ~, objective] = Dimred(X, 'rica', 40);
%>
%> [~, scores, ~, ~, ~, Mdl] = Dimred(X, 'lda')
%> @endcode
%>
%> @param X [numeric array] | The input data as a matrix with MxN observations and Z columns
%> @param method [string] | The method for dimension reduction
%> @param q [int] | The number of components to be retained
%> @param mask [numerical array] | A 2x2 logical array marking pixels to be used in PCA calculation
%>
%> @retval coeff [numeric array] | The transformation coefficients
%> @retval scores [numeric array] | The transformed values
%> @retval latent [numeric array] | The latent values
%> @retval explained [numeric array] | The percentage of explained
%> variance
%> @retval objective [numeric array] | The objective function
%> values
%> @retval Mdl [model] | The dimension reduction model
% ======================================================================

function [coeff, scores, latent, explained, objective, Mdl] = Dimred(X, method, q, mask)
% Dimred reduces the dimensions of the hyperspectral image.
%
% Currently PCA, RICA, SuperPCA, LDA, QDA are available. For more
% details check @c function Dimred.
%
% @b Usage
%
% @code
% q = 10;
% [coeff, scores, latent, explained, objective] = Dimred(X,
% method, q, mask);
%
% [coeff, scores, latent, explained, ~] = Dimred(X, 'pca', 10);
%
% [coeff, scores, ~, ~, objective] = Dimred(X, 'rica', 40);
%
% [~, scores, ~, ~, ~, Mdl] = Dimred(X, 'lda')
% @endcode
%
% @param X [numeric array] | The input data as a matrix with MxN observations and Z columns
% @param method [string] | The method for dimension reduction
% @param q [int] | The number of components to be retained
% @param mask [numerical array] | A 2x2 logical array marking pixels to be used in PCA calculation
%
% @retval coeff [numeric array] | The transformation coefficients
% @retval scores [numeric array] | The transformed values
% @retval latent [numeric array] | The latent values
% @retval explained [numeric array] | The percentage of explained
% variance
% @retval objective [numeric array] | The objective function
% values
% @retval Mdl [model] | The dimension reduction model

latent = [];
explained = [];
objective = [];
Mdl = [];
coeff = [];

if nargin < 3
    q = 10;
end

if nargin < 4
    mask = [];
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
if isempty(mask) && strcmpi(method, 'lda') && strcmpi(method, 'qda')
    error('A supervised method requires labels as argument');
else
    if strcmp(method, 'lda')
        Mdl = fitcdiscr(X, mask);
        scores = predict(Mdl, X);
    end

    if strcmp(method, 'qda')
        Mdl = fitcdiscr(X, mask, 'DiscrimType', 'quadratic');
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
