classdef dimredUtility
    methods (Static)
        % ======================================================================
        %> @brief Apply reduces the dimensions of the hyperspectral image.
        %>
        %> Currently available methods:
        %> PCA, SuperPCA, MSuperPCA, ClusterPCA, MClusterPCA
        %> ICA (FastICA), RICA, SuperRICA,
        %> LDA, QDA, MSelect.
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
        function [coeff, scores, latent, explained, objective, Mdl] = Apply(X, method, q, fgMask, labelMask, varargin)
            % Apply reduces the dimensions of the hyperspectral image.
            %
            % Currently available methods:
            % PCA, SuperPCA, MSuperPCA, ClusterPCA, MClusterPCA,
            % ICA (FastICA), RICA, SuperRICA,
            % LDA, QDA, MSelect.
            % Methods autoencoder and RFI are available only for pre-trained models.
            %
            % Additionally, for pre-trained parameters RFI and Autoencoder are available.
            % For an unknown method, the input data is returned.
            %
            % @b Usage
            %
            % @code
            % q = 10;
            % [coeff, scores, latent, explained, objective] = dimredUtility.Apply(X,
            % method, q, fgMask);
            %
            % [coeff, scores, latent, explained, ~] = dimredUtility.Apply(X, 'pca', 10);
            %
            % [coeff, scores, ~, ~, objective] = dimredUtility.Apply(X, 'rica', 40);
            %
            % [~, scores, ~, ~, ~, Mdl] = dimredUtility.Apply(X, 'lda', 1, [], labelMask);
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
            flattenIn = ~(contains(lower(method), 'super') || contains(lower(method), 'cluster') || contains(lower(method), 'autoencoder') || contains(lower(method), 'rfi'));
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

                %% PCA
                case 'pca'
                    [coeff, scores, latent, ~, ~] = pca(Xcol, 'NumComponents', q);

                    %% FastICA
                case 'ica'
                case 'fastica'
                    [scores, ~, coeff] = fastica(Xcol', 'numOfIC', q);
                    scores = scores';
                    coeff = coeff';

                    %% RICA
                case 'rica'
                    warning('off', 'all');
                    Mdl = rica(Xcol, q, 'IterationLimit', 100, 'Lambda', 1);
                    coeff = Mdl.TransformWeights;
                    scores = Xcol * coeff;
                    objective = Mdl.FitInfo.Objective;
                    warning('on', 'all');

                    %% Discriminant Analysis (LDA)
                case 'lda'
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
                    Mdl = fitcdiscr(Xcol, labelMaskCol);
                    scores = predict(Mdl, Xcol);

                    %% Discriminant Analysis (QDA)
                case 'qda'
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

                    %% Wavelength Selection
                case 'mselect'
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

                    [m, n, ~] = size(X);
                    %%super-pixels segmentation
                    superpixelLabels = cubseg(X, pixelNum);

                    scores = dimredUtility.ApplySuperpixelBasedDimred(X, superpixelLabels, @(x) dimredUtility.RicaCoeffs(x, q));
                    scores = reshape(scores, [m, n, q]);

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
                        endmemberNumArray = floor(20*sqrt(2).^[-2:2]);
                    else
                        endmemberNumArray = varargin{1};
                    end

                    N = numel(endmemberNumArray);
                    scores = cell(N, 1);
                    for i = 1:N
                        pixelNum = endmemberNumArray(i);

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
                    scores = X(:, ido);

                    %% Autoencoder (AE)
                case 'autoencoder'
                    if isempty(varargin)
                        error('Missing autoenc object.Please train it beforehand and pass it as an argument');
                    end
                    autoenc = varargin{1};
                    scores = encode(autoenc, X')';

                    %% ClusterPCA
                case 'clusterpca'
                    %%Find endmembers
                    numEndmembers = 5;%6;
                    endmembers = NfindrInternal(X, numEndmembers, fgMask);

                    %%Find discrepancy metrics
                    clusterLabels = DistanceScoresInternal(X, endmembers, @sam);

                    scores = SuperPCA(X, q, clusterLabels);

                    %% Multiscale ClusterPCA
                case 'mclusterpca'

                    if isempty(varargin)
                        endmemberNumArray = floor(20*sqrt(2).^[-2:2]);
                    else
                        endmemberNumArray = varargin{1};
                    end

                    N = numel(endmemberNumArray);
                    scores = cell(N, 1);
                    for i = 1:N
                        numEndmembers = endmemberNumArray(i);

                        %%Find endmembers
                        endmembers = NfindrInternal(X, numEndmembers, fgMask);

                        %%Find discrepancy metrics
                        clusterLabels = DistanceScoresInternal(X, endmembers, @sam);

                        %%SupePCA based DR
                        scores{i} = SuperPCA(X, q, clusterLabels);
                    end

                    %% No dimension reduction
                otherwise
                    scores = Xcol;
            end

            explained = dimredUtility.CalculateExplained(scores, Xcol, X, fgMask);

            if flattenIn
                if hasFgMask
                    scores = hsi.RecoverSpatialDimensions(scores, size(X), fgMask);
                else
                    scores = reshape(scores, [size(X, 1), size(X, 2), q]);
                end
            end
        end

        % ======================================================================
        %> @brief Transform applies a pretrained dimension reduction method.
        %>
        %> @b Usage
        %>
        %> @code
        %> [peformanceStruct] = dimredUtility.Transform(inScores, method, qNum, trainedObj);
        %> @endcode
        %>
        %> @param inScores [numeric array] | The target array
        %> @param method [char] | The dimension reduction method
        %> @param q [int] | The reduced dimension
        %> @param trainedObj [numeric array] | The trained dimension reduction object
        %>
        %> @retval transScores [numeric array] | The transformed scores
        % ======================================================================        
        function [transScores] = Transform(inScores, method, q, trainedObj)
        % Transform applies a pretrained dimension reduction method.
        %
        % @b Usage
        %
        % @code
        % [peformanceStruct] = trainUtility.Transform(inScores, method, qNum, trainedObj);
        % @endcode
        %
        % @param inScores [numeric array] | The target array
        % @param method [char] | The dimension reduction method
        % @param q [int] | The reduced dimension
        % @param trainedObj [numeric array] | The trained dimension reduction object
        %
        % @retval transScores [numeric array] | The transformed scores
            [~, transScores, ~, ~, ~] = dimredUtility.Apply(inScores, method, q, [], [], trainedObj);
        end
        
        % ======================================================================
        %> @brief Analysis reduces the dimensions of the hyperspectral image and produces evidence graphs.
        %>
        %> Currently available methods:
        %> PCA, SuperPCA, MSuperPCA, ClusterPCA, MClusterPCA
        %> ICA (FastICA), RICA, SuperRICA,
        %> LDA, QDA, MSelect.
        %> Methods autoencoder and RFI are available only for pre-trained models.
        %>
        %> Additionally, for pre-trained parameters RFI and Autoencoder are available.
        %> For an unknown method, the input data is returned.
        %>
        %> @b Usage
        %>
        %> @code
        %> q = 10;
        %> [scores] = dimredUtility.Analysis(hsIm, labelInfo, 'pca', q);
        %> @endcode
        %>
        %> @param hsIm [hsi] | An instance of the hsi class
        %> @param labelInfo [hsiInfo] | An instance of the hsiInfo class
        %> @param method [string] | The method for dimension reduction
        %> @param q [int] | The number of components to be retained
        %> @param fgMask [numerical array] | A 2D logical array marking pixels to be used in PCA calculation
        %> @param labelMask [numerical array] | A 2D logical array marking pixels to be used in PCA calculation
        %> @param varargin [cell array] | Optional additional arguments for methods that require them
        %>
        %> @retval scores [numeric array] | The transformed values
        % ======================================================================
        function [scores] = Analysis(hsIm, labelInfo, method, varargin)
            % Analysis reduces the dimensions of the hyperspectral image and produces evidence graphs.
            %
            % Currently available methods:
            % PCA, SuperPCA, MSuperPCA, ClusterPCA, MClusterPCA
            % ICA (FastICA), RICA, SuperRICA,
            % LDA, QDA, MSelect.
            % Methods autoencoder and RFI are available only for pre-trained models.
            %
            % Additionally, for pre-trained parameters RFI and Autoencoder are available.
            % For an unknown method, the input data is returned.
            %
            % @b Usage
            %
            % @code
            % q = 10;
            % [scores] = dimredUtility.Analysis(hsIm, labelInfo, 'pca', q);
            % @endcode
            %
            % @param hsIm [hsi] | An instance of the hsi class
            % @param labelInfo [hsiInfo] | An instance of the hsiInfo class
            % @param method [string] | The method for dimension reduction
            % @param q [int] | The number of components to be retained
            % @param fgMask [numerical array] | A 2D logical array marking pixels to be used in PCA calculation
            % @param labelMask [numerical array] | A 2D logical array marking pixels to be used in PCA calculation
            % @param varargin [cell array] | Optional additional arguments for methods that require them
            %
            % @retval scores [numeric array] | The transformed values

            if nargin < 2
                labelInfo = [];
            end

            close all;

            %% Preparation
            srgb = hsIm.GetDisplayImage('rgb');

            if strcmpi(method, 'ica')
                [coeff, scores, ~, explained, ~] = hsIm.Dimred('ica', varargin{:});
                subName = 'Independent Component';
                limitVal = [];
            end

            if strcmpi(method, 'rica')
                [coeff, scores, ~, explained, ~] = hsIm.Dimred('rica', varargin{:});
                subName = 'Reconstructed Component';
                limitVal = [[0, 0]; [-3, 3]; [-1, 1]; [-15, 0]];
            end

            if strcmpi(method, 'pca')
                [coeff, scores, ~, explained, ~] = hsIm.Dimred('pca', varargin{:});
                subName = 'Principal Component';
                limitVal = [[0, 0]; [-3, 10]; [-3, 3]; [-1, 1]];
            end


            img = {srgb, squeeze(scores(:, :, 1)), squeeze(scores(:, :, 2)), squeeze(scores(:, :, 3))};
            names = {labelInfo.Diagnosis, strjoin({subName, '1'}, {' '}), strjoin({subName, '2'}, {' '}), strjoin({subName, '3'}, {' '})};
            plotPath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'), hsIm.ID, 'ca'), 'png');
            plots.MontageCmap(1, plotPath, img, names, false, limitVal);

            img = {srgb, squeeze(scores(:, :, 1)), squeeze(scores(:, :, 2)), squeeze(scores(:, :, 3))};
            names = {labelInfo.Diagnosis, strjoin({subName, '1'}, {' '}), strjoin({subName, '2'}, {' '}), strjoin({subName, '3'}, {' '})};
            plotPath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'), hsIm.ID, 'ca_overlay'), 'png');
            plots.MontageWithLabel(2, plotPath, img, names, labelInfo.Labels, hsIm.FgMask);

            fig = figure(3);
            w = hsiUtility.GetWavelengths(311);
            hold on
            for i = 1:3
                v = explained(i);
                name = strcat('TransVector', num2str(i), '(', sprintf('%.2f%%', v), ')');
                plot(w, coeff(:, i), 'DisplayName', name, 'LineWidth', 2);
            end
            hold off
            xlabel('Wavelength (nm)');
            ylabel('Coefficient (a.u.)');
            legend('Location', 'northwest');
            plotPath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'), hsIm.ID, 'ca_vectors'), 'png');
            plots.SavePlot(fig, plotPath);
        end

        % ======================================================================
        %> @brief Explained returns the explained percentage for each component after dimension reduction.
        %>
        %> @b Usage
        %>
        %> @code
        %> [explained] = dimredUtility.Explained( Xcol_, scores_);
        %> @endcode
        %>
        %> @param scores [cell array] | The dimension reduction scores in a 2D format.
        %> @param Xcol_ [numeric array] | The original data in a 2D format
        %>
        %> @retval explained [numeric array] | The explained values.
        % ======================================================================
        function [explained] = Explained(originalData, transData)
            % Explained returns the explained percentage for each component after dimension reduction.
            %
            % @b Usage
            %
            % @code
            % [explained] = dimredUtility.Explained( Xcol_, scores_);
            % @endcode
            %
            % @param scores [cell array] | The dimension reduction scores in a 2D format.
            % @param Xcol_ [numeric array] | The original data in a 2D format
            %
            % @retval explained [numeric array] | The explained values.
            explained = var(transData) / sum(var(originalData));
        end

        % ======================================================================
        %> @brief CalculateExplained calculates the explained percentage for each component of dimension reduction.
        %>
        %> @b Usage
        %>
        %> @code
        %> [explained] = dimredUtility.CalculateExplained(scores_, Xcol_, X_, mask_, explained_);
        %> @endcode
        %>
        %> @param scores [cell array] | The dimension reduction scores
        %> @param Xcol_ [numeric array] | The original data in a column format.
        %> @param X_ [numeric array] | The original data in a 3D format.
        %> @param mask_ [numeric array] | The foreground mask.
        %>
        %> @retval explained [numeric array] | The explained values.
        % ======================================================================
        function [explained] = CalculateExplained(scores_, Xcol_, X_, mask_)
            % CalculateExplained calculates the explained percentage for each component of dimension reduction.
            %
            % @b Usage
            %
            % @code
            % [explained] = dimredUtility.CalculateExplained(scores_, Xcol_, X_, mask_, explained_);
            % @endcode
            %
            % @param scores [cell array] | The dimension reduction scores
            % @param Xcol_ [numeric array] | The original data in a column format.
            % @param X_ [numeric array] | The original data in a 3D format.
            % @param mask_ [numeric array] | The foreground mask.
            %
            % @retval explained [numeric array] | The explained values.

            if ~iscell(scores_) && ndims(scores_) == 2
                explained = dimredUtility.Explained(Xcol_, scores_);

            elseif ~iscell(scores_) && ndims(scores_) == 3
                scoresCol = GetMaskedPixelsInternal(scores_, mask_);
                Xcol_ = GetMaskedPixelsInternal(X_, mask_);
                explained = dimredUtility.Explained(Xcol_, scoresCol);

            elseif iscell(scores_)
                explained = cell(numel(scores_), 1);
                for i = 1:numel(scores_)
                    explained{i} = dimredUtility.CalculateExplained(scores_{i}, Xcol_, X_, mask_);
                end
            else
                explained = [];
            end
        end

        % ======================================================================
        %> @brief RicaCoeffs applies RICA and returns the coefficients vector.
        %>
        %> @b Usage
        %>
        %> @code
        %> coeff = dimredUtility.RicaCoeffs(X,q);
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
            % coeff = dimredUtility.RicaCoeffs(X,q);
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
        %> coeff = dimredUtility.ApplySuperpixelBasedDimred(X,superpixelLabels, @(x) RicaCoeffs(x, q));
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
            % coeff = dimredUtility.ApplySuperpixelBasedDimred(X,superpixelLabels, @(x) RicaCoeffs(x, q));
            % @endcode
            %
            % @param X [numeric array] | The input data as a matrix with MxN observations and Z columns
            % @param superpixelLabels [numeric array] | The superpixel labels
            % @param funcHandle [function handle] | The function handle to be applied
            %
            % @retval scores [numeric array] | The transformed values
            [M, N, ~] = size(X);
            Results_segment = seg_im_class(X, superpixelLabels);
            Num = size(Results_segment.Y, 2);

            for i = 1:Num
                P = funcHandle(Results_segment.Y{1, i});
                RIC = Results_segment.Y{1, i} * P;
                scores(Results_segment.index{1, i}, :) = RIC;
            end
            scores = reshape(scores, M, N, q);
        end

        % ======================================================================
        %> @brief MultiscaleSuperPCA applies multiscale SuperPCA to an hsi object.
        %>
        %> Needs SuperPCA package to work https://github.com/junjun-jiang/SuperPCA .
        %>
        %> @b Usage
        %>
        %> @code
        %> [scores, labels, validLabels] = dimredUtility.MultiscaleSuperPCA(hsIm);
        %>
        %> [scores, labels, validLabels] = dimredUtility.MultiscaleSuperPCA(hsIm, isManual, pixelNum, pcNum);
        %> @endcode
        %>
        %> @param hsIm [hsi] | An instance of the hsi class
        %> @param pixelNumArray [numeric array] | Optional: An array of the number of superpixels. Default: [ 9, 14, 20, 28, 40]..
        %> @param pcNum [int] | Otional: The number of PCA components. Default: 3.
        %>
        %> @retval scores [cell array] | The PCA scores
        %> @retval labels [cell array] | The labels of the superpixels
        %> @retval validLabels [cell array] | The superpixel labels that refer
        %> to tissue pixels
        % ======================================================================
        function [scores, labels, validLabels] = MultiscaleSuperPCA(obj, pixelNumArray, pcNum)
            % MultiscaleSuperPCA applies multiscale SuperPCA to an hsi object.
            %
            % Needs SuperPCA package to work https://github.com/junjun-jiang/SuperPCA .
            %
            % @b Usage
            %
            % @code
            % [scores, labels, validLabels] = dimredUtility.MultiscaleSuperPCA(hsIm);
            %
            % [scores, labels, validLabels] = dimredUtility.MultiscaleSuperPCA(hsIm, isManual, pixelNum, pcNum);
            % @endcode
            %
            % @param hsIm [hsi] | An instance of the hsi class
            % @param pixelNumArray [numeric array] | Optional: An array of the number of superpixels. Default: [ 9, 14, 20, 28, 40]..
            % @param pcNum [int] | Otional: The number of PCA components. Default: 3.
            %
            % @retval scores [cell array] | The PCA scores
            % @retval labels [cell array] | The labels of the superpixels
            % @retval validLabels [cell array] | The superpixel labels that refer
            % to tissue pixels
            if nargin < 2
                pixelNumArray = floor(20*sqrt(2).^[-2:2]);
            end

            if nargin < 3
                pcNum = 3;
            end

            N = numel(pixelNumArray);
            scores = cell(N, 1);
            labels = cell(N, 1);
            validLabels = cell(N, 1);
            for i = 1:N
                pixelNum = pixelNumArray(i);
                [scores{i}, labels{i}, validLabels{i}] = dimredUtility.SuperPCA(obj, false, pixelNum, pcNum);
            end
        end

        % ======================================================================
        %> @brief SuperPCA applies SuperPCA to an hsi object.
        %>
        %> Needs SuperPCA package to work https://github.com/junjun-jiang/SuperPCA .
        %>
        %> @b Usage
        %>
        %> @code
        %> [scores, labels, validLabels] = dimredUtility.SuperPCA(hsIm);
        %>
        %> [scores, labels, validLabels] = dimredUtility.SuperPCA(hsIm, isManual, pixelNum, pcNum);
        %> @endcode
        %>
        %> @param hsIm [hsi] | An instance of the hsi class
        %> @param isManual [boolean] | A  flag to show whether is manual (local)
        %> implementation or by SuperPCA package. Default: false.
        %> @param pixelNum [int] | The number of superpixels. Default: 20.
        %> @param pcNum [int] | The number of PCA components. Default: 3.
        %>
        %> @retval scores [numeric array] | The PCA scores
        %> @retval labels [numeric array] | The labels of the superpixels
        %> @retval validLabels [numeric array] | The superpixel labels that refer
        %> to tissue pixels
        % ======================================================================
        function [scores, labels, validLabels] = SuperPCA(obj, isManual, pixelNum, pcNum)
            % SuperPCA applies SuperPCA to an hsi object.
            %
            % Needs SuperPCA package to work https://github.com/junjun-jiang/SuperPCA .
            %
            % @b Usage
            %
            % @code
            % [scores, labels, validLabels] = dimredUtility.SuperPCA(hsIm);
            %
            % [scores, labels, validLabels] = dimredUtility.SuperPCA(hsIm, isManual, pixelNum, pcNum);
            % @endcode
            %
            % @param hsIm [hsi] | An instance of the hsi class
            % @param isManual [boolean] | A  flag to show whether is manual (local)
            % implementation or by SuperPCA package. Default: false.
            % @param pixelNum [int] | The number of superpixels. Default: 20.
            % @param pcNum [int] | The number of PCA components. Default: 3.
            %
            % @retval scores [numeric array] | The PCA scores
            % @retval labels [numeric array] | The labels of the superpixels
            % @retval validLabels [numeric array] | The superpixel labels that refer
            % to tissue pixels
            if nargin < 2
                isManual = false;
            end

            if nargin < 3
                pixelNum = 20;
            end

            if nargin < 4
                pcNum = 3;
            end

            fgMask = obj.FgMask;

            %% Calculate superpixels
            if isManual
                %%Apply PCA to entire image
                [~, scores, latent, explained, ~] = obj.Dimred('pca', pcNum, fgMask);
                %                 explained(1:pcNum);
                %                 latent(1:pcNum);

                % Use the 1st PCA component for superpixel calculation
                redImage = rescale(squeeze(scores(:, :, 1)));
                [labels, ~] = superpixels(redImage, pixelNum);

                scores = SuperPCA(obj.Value, pcNum, labels);

                % Keep only pixels that belong to the tissue (Superpixel might assign
                % background pixels also). The last label is background label.
                [labels, validLabels] = hsiUtility.CleanLabels(labels, fgMask, pixelNum);

            else
                %%super-pixels segmentation
                labels = cubseg(obj.Value, pixelNum);

                % Keep only pixels that belong to the tissue (Superpixel might assign
                % background pixels also). The last label is background label.
                [labels, validLabels] = hsiUtility.CleanLabels(labels, fgMask, pixelNum);

                %%SupePCA based DR
                scores = SuperPCA(obj.Value, pcNum, labels);
            end

        end

        % ======================================================================
        %> @brief ByICA applies FastICA.
        %>
        %> The method is applied on each image in the dataset. The results are saved in the output folder.
        %>
        %> @b Usage
        %>
        %> @code
        %> dimredUtility.ByICA();
        %> @endcode
        % ======================================================================
        function ByICA()
            % ByICA applies FastICA.
            %
            % The method is applied on each image in the dataset. The results are saved in the output folder.
            %
            % @b Usage
            %
            % @code
            % dimredUtility.ByICA();
            % @endcode

            experiment = strcat('FastICA');
            Basics_Init(experiment);
            icNum = 3;
            apply.ToEach(@dimredUtility.Analysis, 'ica', icNum);
        end

        % ======================================================================
        %> @brief ByRICA applies Reconstructed Independent Component Analysis.
        %>
        %> The method is applied on each image in the dataset. The results are saved in the output folder.
        %>
        %> @b Usage
        %>
        %> @code
        %> dimredUtility.ByRICA();
        %> @endcode
        % ======================================================================
        function ByRICA()
            % ByRICA applies Reconstructed Independent Component Analysis.
            %
            % The method is applied on each image in the dataset. The results are saved in the output folder.
            %
            % @b Usage
            %
            % @code
            % dimredUtility.ByRICA();
            % @endcode

            experiment = strcat('RICA');
            Basics_Init(experiment);
            icNum = 3;
            apply.ToEach(@dimredUtility.Analysis, 'rica', icNum);
        end

        % ======================================================================
        %> @brief ByPCA applies Principal Component Analysis.
        %>
        %> The method is applied on each image in the dataset. The results are saved in the output folder.
        %>
        %> @b Usage
        %>
        %> @code
        %> dimredUtility.ByPCA();
        %> @endcode
        % ======================================================================
        function ByPCA()
            % ByPCA applies Principal Component Analysis.
            %
            % The method is applied on each image in the dataset. The results are saved in the output folder.
            %
            % @b Usage
            %
            % @code
            % dimredUtility.ByPCA();
            % @endcode

            experiment = strcat('PCA');
            Basics_Init(experiment);
            pcNum = 3;
            apply.ToEach(@dimredUtility.Analysis, 'pca', pcNum);
        end

        % ======================================================================
        %> @brief BySuperPCA applies Superpixel-wise Principal Component Analysis.
        %>
        %> The method is applied on each image in the dataset. The results are saved in the output folder.
        %>
        %> @b Usage
        %>
        %> @code
        %> dimredUtility.BySuperPCA();
        %> @endcode
        % ======================================================================
        function BySuperPCA()
            % BySuperPCA applies Superpixel-wise Principal Component Analysis.
            %
            % The method is applied on each image in the dataset. The results are saved in the output folder.
            %
            % @b Usage
            %
            % @code
            % dimredUtility.BySuperPCA();
            % @endcode

            %% SuperPCA
            pixelNum = 30;
            pcNum = 5;

            %% Manual
            experiment = strcat('SuperPCA-Manual', '-Superpixels', num2str(pixelNum));
            Basics_Init(experiment);

            isManual = true;
            apply.ToEach(@SuperpixelAnalysis, isManual, pixelNum, pcNum);

            close all;
            if config.GetSetting('IsTest')
                plots.GetMontagetCollection(1, 'eigenvectors');
            end
            plots.GetMontagetCollection(2, 'superpixel_mask');
            plots.GetMontagetCollection(3, 'pc1');
            plots.GetMontagetCollection(4, 'pc2');
            plots.GetMontagetCollection(5, 'pc3');

            %% From SuperPCA package
            experiment = strcat('SuperPCA', '-Superpixels', num2str(pixelNum));
            Basics_Init(experiment);

            isManual = false;
            apply.ToEach(@SuperpixelAnalysis, isManual, pixelNum, pcNum);

            close all;
            if config.GetSetting('IsTest')
                plots.GetMontagetCollection(1, 'eigenvectors');
            end
            plots.GetMontagetCollection(2, 'superpixel_mask');
            plots.GetMontagetCollection(3, 'pc1');
            plots.GetMontagetCollection(4, 'pc2');
            plots.GetMontagetCollection(5, 'pc3');
        end

        % ======================================================================
        %> @brief ByMSuperPCA applies Multiscale Superpixel-wise Principal Component Analysis.
        %>
        %> The method is applied on each image in the dataset. The results are saved in the output folder.
        %>
        %> @b Usage
        %>
        %> @code
        %> dimredUtility.ByMSuperPCA();
        %> @endcode
        % ======================================================================
        function ByMSuperPCA()
            % ByMSuperPCA applies Multiscale Superpixel-wise Principal Component Analysis.
            %
            % The method is applied on each image in the dataset. The results are saved in the output folder.
            %
            % @b Usage
            %
            % @code
            % dimredUtility.ByMSuperPCA();
            % @endcode

            %% Multiscale SuperPCA
            experiment = strcat('MultiscaleSuperPCA-Manual');
            Basics_Init(experiment);

            pixelNumArray = floor(50*sqrt(2).^[-2:2]);
            apply.ToEach(@MultiscaleSuperpixelAnalysis, pixelNumArray);
        end
    end
end