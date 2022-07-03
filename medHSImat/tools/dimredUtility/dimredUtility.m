% ======================================================================
%> @brief dimredUtility is a class that handles dimension reduction.
%
% For details check https://foxelas.github.io/medHSIdocs/classdimred_utility.html
% ======================================================================
classdef dimredUtility
    methods (Static)
        % ======================================================================
        %> @brief dimredUtility.Apply reduces the dimensions of the hyperspectral image.
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
        function [coeff, scores, latent, explained, objective, Mdl] = Apply(X, method, q, fgMask, labelMask, varargin)
            [coeff, scores, latent, explained, objective, Mdl] = DimredApply(X, method, q, fgMask, labelMask, varargin{:});
        end

        % ======================================================================
        %> @brief dimredUtility.Transform applies a pretrained dimension reduction method.
        %>
        %> @b Usage
        %>
        %> @code
        %> [transScores] = dimredUtility.Transform(inScores, method, qNum, trainedObj);
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
            [~, transScores, ~, ~, ~] = dimredUtility.Apply(inScores, method, q, [], [], trainedObj);
        end

        % ======================================================================
        %> @brief dimredUtility.Analysis reduces the dimensions of the hyperspectral image and produces evidence graphs.
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
            [scores] = DimredAnalysis(hsIm, labelInfo, method, varargin{:});
        end

        % ======================================================================
        %> @brief dimredUtility.Explained returns the explained percentage for each component after dimension reduction.
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
            explained = var(transData) ./ sum(var(originalData));
        end

        % ======================================================================
        %> @brief dimredUtility.CalculateExplained calculates the explained percentage for each component of dimension reduction.
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
        %> @brief dimredUtility.RicaCoeffs applies RICA and returns the coefficients vector.
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
            Mdl = rica(target, q, 'IterationLimit', 100, 'Lambda', 5);
            coeff = Mdl.TransformWeights;
        end

        % ======================================================================
        %> @brief dimredUtility.ApplySuperpixelBasedDimred applies a  target function on an hsi object's superpixels and returns the tranformed scores.
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
        % ======================================================================
        function [scores] = ApplySuperpixelBasedDimred(X, superpixelLabels, funcHandle)
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
        %> @brief dimredUtility.MultiscaleSuperPCA applies multiscale SuperPCA to an hsi object.
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
        %> @brief dimredUtility.SuperPCA applies SuperPCA to an hsi object.
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
        %> @param isManual [boolean] | Optional: A  flag to show whether is manual (local)
        %> implementation or by SuperPCA package. Default: false.
        %> @param pixelNum [int] | Optional: The number of superpixels. Default: 20.
        %> @param pcNum [int] | Optional: The number of PCA components. Default: 3.
        %>
        %> @retval scores [numeric array] | The PCA scores
        %> @retval labels [numeric array] | The labels of the superpixels
        %> @retval validLabels [numeric array] | The superpixel labels that refer
        %> to tissue pixels
        % ======================================================================
        function [scores, labels, validLabels] = SuperPCA(obj, varargin)
            [scores, labels, validLabels] = SuperPCAInternal(obj, varargin{:});
        end

        % ======================================================================
        %> @brief dimredUtility.ApplyAndShow applies a dimension reduction and produces evidence.
        %>
        %> The method is applied on each image in the dataset. The results are saved in the output folder.
        %>
        %> @b Usage
        %>
        %> @code
        %> dimredUtility.ApplyAndShow('FastICA');
        %> @endcode
        %>
        %> @param method [char] | The dimension reduction method. Options: ['ICA', 'RICA', 'PCA', 'SuperPCA', 'MSuperPCA'].
        %> @param varargin [cell array] | Optional: The arguments necessary for the target function
        % ======================================================================
        function [] = ApplyAndShow(method, varargin)
            switch lower(method)

                case lower('ICA')
                    experiment = strcat('FastICA');
                    initUtility.InitExperiment(experiment);
                    icNum = 3;
                    apply.ToEach(@dimredUtility.Analysis, 'ica', icNum);

                case lower('RICA')
                    experiment = strcat('RICA');
                    initUtility.InitExperiment(experiment);
                    icNum = 3;
                    apply.ToEach(@dimredUtility.Analysis, 'rica', icNum);

                case lower('PCA')
                    experiment = strcat('PCA');
                    initUtility.InitExperiment(experiment);
                    pcNum = 3;
                    apply.ToEach(@dimredUtility.Analysis, 'pca', pcNum);

                case lower('SuperPCA')
                    % SuperPCA
                    pixelNum = 30;
                    pcNum = 5;

                    % Manual
                    experiment = strcat('SuperPCA-Manual', '-Superpixels', num2str(pixelNum));
                    initUtility.InitExperiment(experiment);

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

                    % From SuperPCA package
                    experiment = strcat('SuperPCA', '-Superpixels', num2str(pixelNum));
                    initUtility.InitExperiment(experiment);

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

                case lower('MSuperPCA')
                    experiment = strcat('MultiscaleSuperPCA-Manual');
                    initUtility.InitExperiment(experiment);

                    pixelNumArray = floor(50*sqrt(2).^[-2:2]);
                    apply.ToEach(@MultiscaleSuperpixelAnalysis, pixelNumArray);

                otherwise
                    disp('Incorrect dimention reduction method.');
            end
        end

    end
end