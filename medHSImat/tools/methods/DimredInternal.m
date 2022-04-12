% ======================================================================
%> @brief DimredInternal reduces the dimensions of the hyperspectral image.
%>
%> Currently available methods:
%> PCA, SuperPCA, MSuperPCA, ClusterSuperPCA, 
%> ICA (FastICA), RICA, SuperRICA, 
%> LDA, QDA, Wavelength-Selection.
%> Methods autoencoder and RFI are available only for pre-trained models. 
%>
%> Additionally, for pre-trained parameters RFI and Autoencoder are available.
%> For an unknown method, the input data is returned.
%>
%> @b Usage
%>
%> @code
%> q = 10;
%> [coeff, scores, latent, explained, objective] = DimredInternal(X,
%> method, q, fgMask);
%>
%> [coeff, scores, latent, explained, ~] = DimredInternal(X, 'pca', 10);
%>
%> [coeff, scores, ~, ~, objective] = DimredInternal(X, 'rica', 40);
%>
%> [~, scores, ~, ~, ~, Mdl] = DimredInternal(X, 'lda', 1, [], labelMask);
%> @endcode
%>
%> @param X [numeric array] | The input data as a matrix with MxN observations and Z columns
%> @param method [string] | The method for dimension reduction
%> @param q [int] | The number of components to be retained
%> @param fgMask [numerical array] | A 2D logical array marking pixels to be used in PCA calculation
%> @param labelMask [numerical array] | A 2D logical array marking pixels to be used in PCA calculation
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
function [coeff, scores, latent, explained, objective, Mdl] = DimredInternal(X, method, q, fgMask, labelMask, varargin)
% DimredInternal reduces the dimensions of the hyperspectral image.
%
% Currently available methods:
% PCA, SuperPCA, MSuperPCA, ClusterSuperPCA, 
% ICA (FastICA), RICA, SuperRICA, 
% LDA, QDA, Wavelength-Selection.
% Methods autoencoder and RFI are available only for pre-trained models. 
%
% Additionally, for pre-trained parameters RFI and Autoencoder are available.
% For an unknown method, the input data is returned.
%
% @b Usage
%
% @code
% q = 10;
% [coeff, scores, latent, explained, objective] = DimredInternal(X,
% method, q, fgMask);
%
% [coeff, scores, latent, explained, ~] = DimredInternal(X, 'pca', 10);
%
% [coeff, scores, ~, ~, objective] = DimredInternal(X, 'rica', 40);
%
% [~, scores, ~, ~, ~, Mdl] = DimredInternal(X, 'lda', 1, [], labelMask);
% @endcode
%
% @param X [numeric array] | The input data as a matrix with MxN observations and Z columns
% @param method [string] | The method for dimension reduction
% @param q [int] | The number of components to be retained
% @param fgMask [numerical array] | A 2D logical array marking pixels to be used in PCA calculation
% @param labelMask [numerical array] | A 2D logical array marking pixels to be used in PCA calculation
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
    fgMask = [];
end

if nargin < 5 
    labelMask = [];
end 
hasFgMask = ~isempty(fgMask);
flattenIn = ~contains(lower(method), 'super'); 

if flattenIn
    if hasFgMask 
        Xcol = GetMaskedPixelsInternal(X, fgMask);
    else 
        Xcol = reshape(X, [size(X, 1) * size(X, 2), size(X, 3)]);
    end
end


rng default % For reproducibility

switch lower(method)

    %% PCA
    case 'pca'
        [coeff, scores, latent, ~, explained] = pca(Xcol, 'NumComponents', q);

        %% FastICA
    case 'ica'
        [scores, ~, coeff] = fastica(Xcol', 'numOfIC', q);
        scores = scores';
        coeff = coeff';
        
        %% RICA
    case 'rica'
        Mdl = rica(Xcol, q, 'IterationLimit', 100, 'Lambda', 1);
        coeff = Mdl.TransformWeights;
        scores = Xcol * coeff;
        objective = Mdl.FitInfo.Objective;

        %% Discriminant Analysis (LDA)
    case 'lda'
        if isempty(mask)
            error('A supervised method requires labels as argument');
        end
        Mdl = fitcdiscr(Xcol, labelMask);
        scores = predict(Mdl, Xcol);
        
        %% Discriminant Analysis (QDA)
    case 'qda'
        if isempty(mask)
            error('A supervised method requires labels as argument');
        end
        Mdl = fitcdiscr(Xcol, labelMask, 'DiscrimType', 'quadratic');
        scores = predict(Mdl, Xcol);

        %% Wavelength Selection
    case 'wavelength-selection'
        wavelengths = hsiUtility.GetWavelengths(311);
        id1 = find(wavelengths == 540);
        id2 = find(wavelengths == 650);
        scores = Xcol(:, [id1, id2]);
        coeff = zeros(numel(wavelengths), 1);
        coeff(id1) = 1;
        coeff(id2) = 1;
    
        %% Superpixel RICA (SuperRICA)
    case 'superrica'
        if isempty(varargin)
            pixelNum = 20;
        else
            pixelNum = varargin{1};
        end

        %%super-pixels segmentation
        superpixelLabels = cubseg(X, pixelNum);
        
        scores = ApplySuperpixelBasedDimred(X, superpixelLabels, @(x) RicaCoeffs(x, q));
        scores = reshape(scores,M,N,q);
        
        %% SuperPCA
    case 'superpca'
        if isempty(varargin)
            pixelNum = 20;
        else
            pixelNum = varargin{1};
        end

        %%super-pixels segmentation
        superpixelLabels = cubseg(X, pixelNum);

        %%SupePCA based DR
        scores = SuperPCA(X, q, superpixelLabels);

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
            superpixelLabels = cubseg(X, pixelNum);

            %%SupePCA based DR
            scores{i} = SuperPCA(X, q, superpixelLabels);
        end

        %% Random Forest Importance (RFI)
    case 'rfi'
        if isempty(varargin)
            error('Missing imOOB object.Please train it beforehand and pass it as an argument');
        end
        impOOB = varargin{1};
        [~, idxOrder] = sort(impOOB, 'descend');
        ido = idxOrder(1:q);
        scores = Xcol(:, ido);

        %% Autoencoder (AE)
    case 'autoencoder'
        if isempty(varargin)
            error('Missing autoenc object.Please train it beforehand and pass it as an argument');
        end
        autoenc = varargin{1};
        scores = encode(autoenc, Xcol')';
        
        %% ClusterPCA 
    case 'clustersuperpca'   
        %%Find endmembers
        numEndmembers = 6;
        endmembers = NfindrInternal(X, numEndmembers, fgMask);
        
        %%Find discrepancy metrics
        clusterLabels = DistanceScoresInternal(X, endmembers, @sam);
        
        scores = SuperPCA(X, q, clusterLabels);

        %% No dimension reduction 
    otherwise
        scores = X;
end

if flattenIn
    if hasFgMask
        scores = hsi.RecoverSpatialDimensions(scores, size(X), fgMask);
    else
        scores = reshape(scores, [size(X, 1), size(X, 2), q]);
    end
end


end

% ======================================================================
%> @brief RicaCoeffs applies RICA and returns the coefficients vector.
%>
%> @b Usage
%>
%> @code
%> coeff = RicaCoeffs(X,q);
%> @endcode
%>
%> @param X [numeric array] | The input data as a matrix with MxN observations and Z columns
%> @param q [int] | The number of components to be retained
%>
%> @retval coeff [numeric array] | The transformation coefficients
% ======================================================================
function [coeff] = RicaCoeffs(target, q)
% RicaCoeffs applies RICA and returns the coefficients vector.
%
% @b Usage
%
% @code
% coeff = RicaCoeffs(X,q);
% @endcode
%
% @param X [numeric array] | The input data as a matrix with MxN observations and Z columns
% @param q [int] | The number of components to be retained
%
% @retval coeff [numeric array] | The transformation coefficients
    Mdl = rica(target, q, 'IterationLimit', 100, 'Lambda', 5);
    coeff = Mdl.TransformWeights;
end

% ======================================================================
%> @brief ApplySuperpixelBasedDimred applies a  target function on an hsi object's superpixels and returns the tranformed scores.
%>
%> @b Usage
%>
%> @code
%> coeff = ApplySuperpixelBasedDimred(X,superpixelLabels, @(x) RicaCoeffs(x, q));
%> @endcode
%>
%> @param X [numeric array] | The input data as a matrix with MxN observations and Z columns
%> @param superpixelLabels [numeric array] | The superpixel labels
%> @param funcHandle [function handle] | The function handle to be applied
%>
%> @retval scores [numeric array] | The transformed values
function [scores] = ApplySuperpixelBasedDimred(X, superpixelLabels, funcHandle)
% ApplySuperpixelBasedDimred applies a  target function on an hsi object's superpixels and returns the tranformed scores.
%
% @b Usage
%
% @code
% coeff = ApplySuperpixelBasedDimred(X,superpixelLabels, @(x) RicaCoeffs(x, q));
% @endcode
%
% @param X [numeric array] | The input data as a matrix with MxN observations and Z columns
% @param superpixelLabels [numeric array] | The superpixel labels
% @param funcHandle [function handle] | The function handle to be applied
%
% @retval scores [numeric array] | The transformed values
        [M,N,~]=size(X);
        Results_segment= seg_im_class(X,superpixelLabels);
        Num=size(Results_segment.Y,2);
        
        for i=1:Num
            P = funcHandle(Results_segment.Y{1,i});
            RIC = Results_segment.Y{1,i}*P;
            scores(Results_segment.index{1,i},:) = RIC;      
        end
        scores = reshape(scores,M,N,q);
end