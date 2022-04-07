% ======================================================================
%> @brief Dimred reduces the dimensions of the hyperspectral image.
%>
%> Currently PCA, ICA (FastICA), RICA, SuperPCA, MSuperPCA, LDA, QDA, Wavelength-Selection are available.
%> Additionally, for pre-trained parameters RFI and Autoencoder are available.
%> For an unknown method, the input data is returned.
%> For more details check @c function Dimred.
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
%> @param mask [numerical array] | A 2D logical array marking pixels to be used in PCA calculation
%> @param varargin [cell array] | Optional additional arguments for methods that require them
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

function [coeff, scores, latent, explained, objective, Mdl] = Dimred(X, method, q, mask, varargin)
% Dimred reduces the dimensions of the hyperspectral image.
%
% Currently PCA, ICA (FastICA), RICA, SuperPCA, MSuperPCA, LDA, QDA, Wavelength-Selection are available.
% Additionally, for pre-trained parameters RFI and Autoencoder are available.
% For an unknown method, the input data is returned.
% For more details check @c function Dimred.
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
% @param mask [numerical array] | A 2D logical array marking pixels to be used in PCA calculation
% @param varargin [cell array] | Optional additional arguments for methods that require them
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

rng default % For reproducibility

switch lower(method)

    %% PCA
    case 'pca'
        [coeff, scores, latent, ~, explained] = pca(X, 'NumComponents', q);

        %% FastICA
    case 'ica'
        [scores, ~, coeff] = fastica(X', 'numOfIC', q);

        %% RICA
    case 'rica'
        Mdl = rica(X, q, 'IterationLimit', 100, 'Lambda', 1);
        coeff = Mdl.TransformWeights;
        scores = X * coeff;
        objective = Mdl.FitInfo.Objective;

        %% Discriminant Analysis (LDA / QDA)
    case 'lda'
        if isempty(mask)
            error('A supervised method requires labels as argument');
        end
        Mdl = fitcdiscr(X, mask);
        scores = predict(Mdl, X);

    case 'qda'
        if isempty(mask)
            error('A supervised method requires labels as argument');
        end
        Mdl = fitcdiscr(X, mask, 'DiscrimType', 'quadratic');
        scores = predict(Mdl, X);

        %% Wavelength Selection
    case 'wavelength-selection'
        wavelengths = hsiUtility.GetWavelengths(311);
        id1 = find(wavelengths == 540);
        id2 = find(wavelengths == 650);
        scores = X(:, [id1, id2]);
        coeff = zeros(wavelegths);
        coeff(id1) = 1;
        coeff(id2) = 1;

        %% SuperPCA
    case 'superpca'
        if isempty(varargin)
            pixelNum = 20;
        else
            pixelNum = varargin{1};
        end

        %%super-pixels segmentation
        superpixels = cubseg(X, pixelNum);

        %%SupePCA based DR
        scores = SuperPCA(X, q, superpixels);

        %% Multiscale SuperPCA
    case 'msuperpca'

        if isempty(varargin)
            pixelNumArray = floor(20*sqrt(2).^[-2:2]);
        else
            pixelNumArray = varargin{1};
        end

        N = numel(pixelNumArray);
        scores = cell(N, 1);
        for i = 1:N
            pixelNum = pixelNumArray(i);

            %%super-pixels segmentation
            superpixels = cubseg(X, pixelNum);

            %%SupePCA based DR
            scores{i} = SuperPCA(X, q, superpixels);
        end

    case 'rfi'
        impOOB = varargin{1};
        [~, idxOrder] = sort(impOOB, 'descend');
        ido = idxOrder(1:q);
        scores = X(:, ido);

    case 'autoencoder'
        autoenc = varargin{1};
        scores = encode(autoenc, X')';

    otherwise
        scores = X;
end


end
