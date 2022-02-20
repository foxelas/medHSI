% ======================================================================
%> @brief DimredInternal reduces the dimensions of the hyperspectral image.
%>
%> Currently PCA, RICA, SuperPCA, LDA, QDA are available. For more
%> details check @c function Dimred.
%>
%> @b Usage
%>
%> @code
%> q = 10;
%> [coeff, scores, latent, explained, objective] = DimredInternal(hsIm.Value,
%> method, q, hsIm.FgMask);
%>
%> [coeff, scores, latent, explained, ~] = DimredInternal(hsIm.Value, 'pca', 10);
%>
%> [coeff, scores, ~, ~, objective] = DimredInternal(hsIm.Value, 'rica', 40);
%> @endcode
%>
%> @param X [numeric array] | The input data as a matrix with MxN observations and Z columns
%> @b Optional varargin
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
function [coeff, scores, latent, explained, objective] = DimredInternal(X, method, q, mask)
% DimredInternal reduces the dimensions of the hyperspectral image.
%
% Currently PCA, RICA, SuperPCA, LDA, QDA are available. For more
% details check @c function Dimred.
%
% @b Usage
%
% @code
% q = 10;
% [coeff, scores, latent, explained, objective] = DimredInternal(hsIm.Value,
% method, q, hsIm.FgMask);
%
% [coeff, scores, latent, explained, ~] = DimredInternal(hsIm.Value, 'pca', 10);
%
% [coeff, scores, ~, ~, objective] = DimredInternal(hsIm.Value, 'rica', 40);
% @endcode
%
% @param X [numeric array] | The input data as a matrix with MxN observations and Z columns
% @b Optional varargin
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

hasMask = nargin > 3;

keepSpatialDim = strcmpi(method, 'SuperPCA');

if keepSpatialDim
    [coeff, scores, latent, explained, objective] = Dimred(X, method, q);
    if hasMask
        scores = GetMaskedPixelsInternal(scores, mask);
    end

else
    if hasMask
        Xcol = GetMaskedPixelsInternal(X, mask);
    else
        Xcol = reshape(X, [size(X, 1) * size(X, 2), size(X, 3)]);
    end

    [coeff, scores, latent, explained, objective] = Dimred(Xcol, method, q);

    if hasMask
        scores = hsi.RecoverSpatialDimensions(scores, size(X), mask);
    else
        scores = reshape(scores, [size(X, 1), size(X, 2), q]);
    end
end
end