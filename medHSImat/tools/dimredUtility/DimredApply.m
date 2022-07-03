% ======================================================================
%> @brief Apply reduces the dimensions of the hyperspectral image.
%>
%> Currently available methods:
%> PCA, SuperPCA, MSuperPCA, ClusterPCA, MClusterPCA
%> ICA (FastICA), RICA, SuperRICA, Abundance,
%> LDA, QDA, PCA-LDA, MSelect, pretrained.
%> Methods autoencoder and RFI are available only for pre-trained models.
%>
%> Additionally, for pre-trained parameters RFI and Autoencoder are available.
%> For an unknown method, the input data is returned.
%>
%> @b Usage
%>
%> @code
%> q = 10;
%> [coeff, scores, latent, explained, objective] = dimredUtility.Apply(X,
%> method, q, fgMask);
%>
%> [coeff, scores, latent, explained, ~] = dimredUtility.Apply(X, 'pca', 10);
%>
%> [coeff, scores, ~, ~, objective] = dimredUtility.Apply(X, 'rica', 40);
%>
%> [~, scores, ~, ~, ~, Mdl] = dimredUtility.Apply(X, 'lda', 1, [], labelMask);
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
function [coeff, scores, latent, explained, objective, Mdl] = DimredApply(X, method, q, fgMask, labelMask, varargin)

    latent = [];
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
    flattenIn = ~(contains(lower(method), 'super') || contains(lower(method), 'cluster') || contains(lower(method), 'abundance'));
    if ndims(X) < 3
        flattenIn = false;
    end

    if flattenIn
        if hasFgMask
            Xcol = GetMaskedPixelsInternal(X, fgMask);
        else
            Xcol = reshape(X, [size(X, 1) * size(X, 2), size(X, 3)]);
        end
    else
        Xcol = X;
    end


    rng default % For reproducibility

    switch lower(method)

        case 'pca'
        %% PCA
            [coeff, scores, latent, ~, ~] = pca(Xcol, 'NumComponents', q);

        case 'ica'
        case 'fastica'
        %% FastICA
            [scores, ~, coeff] = fastica(Xcol', 'numOfIC', q);
            scores = scores';
            coeff = coeff';

        case 'rica'
        %% RICA
            warning('off', 'all');
            Mdl = rica(Xcol, q, 'IterationLimit', 100, 'Lambda', 1);
            coeff = Mdl.TransformWeights;
            scores = Xcol * coeff;
            objective = Mdl.FitInfo.Objective;
            warning('on', 'all');

        case 'pca-lda'
            %% PCA/LDA
            [coeff, scores1, latent, ~, ~] = pca(Xcol, 'NumComponents', q);
            if isempty(labelMask)
                error('A supervised method requires labels as argument');
            end
            if flattenIn
                if hasFgMask
                    labelMaskCol = GetMaskedPixelsInternal(labelMask, fgMask);
                else
                    labelMaskCol = reshape(labelMask, [size(labelMask, 1) * size(labelMask, 2), 1]);
                end
            else
                labelMaskCol = labelMask;
            end
            Mdl = fitcdiscr(scores1, labelMaskCol);
            scores = scores1 * Mdl.Coeffs(1, 2).Linear;  % scores = predict(Mdl, scores1);
            q = numel(Mdl.ClassNames) - 1;
            coeff = coeff * Mdl.Coeffs(1, 2).Linear;

        case 'lda'
            %% Discriminant Analysis (LDA)
            if isempty(labelMask)
                error('A supervised method requires labels as argument');
            end
            if flattenIn
                if hasFgMask
                    labelMaskCol = GetMaskedPixelsInternal(labelMask, fgMask);
                else
                    labelMaskCol = reshape(labelMask, [size(labelMask, 1) * size(labelMask, 2), 1]);
                end
            else
                labelMaskCol = labelMask;
            end

            Mdl = fitcdiscr(Xcol, labelMaskCol);
            scores = Xcol * Mdl.Coeffs(1, 2).Linear; %scores = predict(Mdl, Xcol);
            coeff = Mdl.Coeffs(1, 2).Linear;

        case 'qda'
            %% Discriminant Analysis (QDA)
            if isempty(labelMask)
                error('A supervised method requires labels as argument');
            end
            if flattenIn
                if hasFgMask
                    labelMaskCol = GetMaskedPixelsInternal(labelMask, fgMask);
                else
                    labelMaskCol = reshape(labelMask, [size(labelMask, 1) * size(labelMask, 2), 1]);
                end
            end
            Mdl = fitcdiscr(Xcol, labelMaskCol, 'DiscrimType', 'quadratic');
            scores = predict(Mdl, Xcol);

        case 'mselect'
            %% Wavelength Selection
            wavelengths = hsiUtility.GetWavelengths(311);
            id1 = find(wavelengths == 540);
            id2 = find(wavelengths == 650);
            scores = Xcol(:, [id1, id2]);
            coeff = zeros(numel(wavelengths), 1);
            coeff(id1) = 1;
            coeff(id2) = 1;

        case 'superrica'
            %% Superpixel RICA (SuperRICA)
            if isempty(varargin)
                pixelNum = 20;
            else
                pixelNum = varargin{1};
            end

            [m, n, ~] = size(X);
            superpixelLabels = cubseg(X, pixelNum);
            scores = dimredUtility.ApplySuperpixelBasedDimred(X, superpixelLabels, @(x) dimredUtility.RicaCoeffs(x, q));
            scores = reshape(scores, [m, n, q]);

        case 'superpca'
            %% SuperPCA
            if isempty(varargin)
                pixelNum = 20;
            else
                pixelNum = varargin{1};
            end

            superpixelLabels = cubseg(X, pixelNum);
            scores = SuperPCA(X, q, superpixelLabels);

        case 'msuperpca'
            %% Multiscale SuperPCA

            if isempty(varargin)
                endmemberNumArray = floor(20*sqrt(2).^[-2:2]);
            else
                endmemberNumArray = varargin{1};
            end

            N = numel(endmemberNumArray);
            scores = cell(N, 1);
            for i = 1:N
                pixelNum = endmemberNumArray(i);
                superpixelLabels = cubseg(X, pixelNum);
                scores{i} = SuperPCA(X, q, superpixelLabels);
            end

        case 'rfi'
            %% Random Forest Importance (RFI)
            if ~isempty(varargin) % Apply a pretrained dimension reduction
                impOOB = varargin{1};
                
            else % Train
                t = templateTree('NumVariablesToSample', 'all', 'Reproducible', true);
                RFtrainedModel = fitrensemble(Xcol, double(labelMask), 'Method', 'Bag', 'Learners', t, 'NPrint', 50); %,  'OptimizeHyperparameters',{'NumLearningCycles','LearnRate','MaxNumSplits'});   
                yHat = oobPredict(RFtrainedModel);
                R2 = corr(RFtrainedModel.Y, yHat)^2;
                fprintf('trainedModel explains %0.1f of the variability around the mean.\n', R2);
                options = statset('UseParallel', true);
                impOOB = oobPermutedPredictorImportance(RFtrainedModel, 'Options', options);
            end

            featImp = impOOB';
            [~, idx] = sort(featImp, 'descend');
            dropIdx = idx(q+1:end); % Drop the first and last wavelengths because they are noisy 
            featImp(dropIdx) = 0;
            coeff = diag(featImp);
            coeff(:, ~any(coeff, 1)) = []; % Drop zero columns

            scores = dimredUtility.Transform(Xcol, 'pretrained', q, coeff);
            
        case 'autoencoder'
            %% Autoencoder (AE)
            if ~isempty(varargin) % Apply a pretrained dimension reduction
                autoenc = varargin{1};
                scores = encode(autoenc, Xcol')';
                
            else % Train
                autoenc = trainAutoencoder(Xcol', q, 'MaxEpochs', 200);
                scores = dimredUtility.Transform(Xcol, method, q, autoenc);
                coeff = autoenc;
            end

        case 'clusterpca'
            %% ClusterPCA
            if isempty(varargin)
                numEndmembers = 5;
            else
                numEndmembers = varargin{1};
                if length(varargin) > 1 
                    spectralSimilarityFun = varargin{2};
                else
                    spectralSimilarityFun = @sam;
                end
            end

            endmembers = FindPurePixelsInternal(X, numEndmembers, fgMask, 'nfindr');
            clusterLabels = DistanceScoresInternal(X, endmembers, spectralSimilarityFun);
            scores = SuperPCA(X, q, clusterLabels);

        case 'mclusterpca'
            %% Multiscale ClusterPCA
            if isempty(varargin)
                endmemberNumArray = floor(20*sqrt(2).^[-2:2]);
            else
                endmemberNumArray = varargin{1};
                if length(varargin) > 1 
                    spectralSimilarityFun = varargin{2};
                else
                    spectralSimilarityFun = @sam;
                end
            end

            N = numel(endmemberNumArray);
            scores = cell(N, 1);
            for i = 1:N
                numEndmembers = endmemberNumArray(i);
                endmembers = FindPurePixelsInternal(X, numEndmembers, fgMask, 'nfindr');
                clusterLabels = DistanceScoresInternal(X, endmembers, spectralSimilarityFun);
                scores{i} = SuperPCA(X, q, clusterLabels);
            end
            
        case 'abundance'
            %% Abundance
            if isempty(varargin)
                numEndmembers = q;
                endmembers = FindPurePixelsInternal(X, numEndmembers, fgMask, 'nfindr');
            else
                pathName = commonUtility.GetFilename('dataset', 'EndMembers\endmembers-8');
                load(pathName, 'endmembers');
                q = size(endmembers, 1);
            end    
            scores = estimateAbundanceLS(X, endmembers);

        case 'pretrained'
            %% Pretrained
            if isempty(varargin)
                error('The pretrained transformation matrix is missing.');
            end
            coeff = varargin{1};
            scores = Xcol * coeff;
            q = size(coeff, 2);

        otherwise
            %% No dimension reduction
            scores = Xcol;
            q = size(Xcol, 2);
    end

    explained = dimredUtility.CalculateExplained(scores, Xcol, X, fgMask);

    if flattenIn
        if hasFgMask
            scores = hsi.RecoverSpatialDimensions(scores, size(X), fgMask);
        else
            scores = reshape(scores, [size(X, 1), size(X, 2), q]);
        end
    end

    scores = hsiUtility.AdjustDimensions(scores, q);
end