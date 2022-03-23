% ======================================================================
%> @brief trainUtility is a class that handles training of hyperspectral data.
%>
% ======================================================================
classdef trainUtility
    methods (Static)

        % ======================================================================
        %> @brief Augment applies augmentation on the dataset
        %>
        %> The base dataset should be already saved before running augmentation.
        %>
        %> 'set1': applies vertical and horizontal flipping.
        %> 'set2': applies random rotation.
        %>
        %> @b Usage
        %>
        %> @code
        %> baseDataset = 'pslData';
        %> hsiUtility.PrepareDataset(baseDataset, {'tissue', true});
        %> augType = 'set1';
        %> augmentedDataset = 'pslDataAug';
        %> AugmentInternal(baseDataset, augmentedDataset, augType);
        %> @endcode
        %>
        %> @param baseDataset [char] | The base dataset
        %> @param augmentedDataset [char] | The augmented dataset
        %> @param augType [char] | Optional: The augmentation type ('set1' or 'set2'). Default: 'set1'
        %>
        % ======================================================================
        function [] = Augment(varargin)
            % Augment applies augmentation on the dataset
            %
            % The base dataset should be already saved before running augmentation.
            %
            % 'set1': applies vertical and horizontal flipping.
            % 'set2': applies random rotation.
            %
            % @b Usage
            %
            % @code
            % baseDataset = 'pslData';
            % hsiUtility.PrepareDataset(baseDataset, {'tissue', true});
            % augType = 'set1';
            % augmentedDataset = 'pslDataAug';
            % AugmentInternal(baseDataset, augmentedDataset, augType);
            % @endcode
            %
            % @param baseDataset [char] | The base dataset
            % @param augmentedDataset [char] | The augmented dataset
            % @param augType [char] | Optional: The augmentation type ('set1' or 'set2'). Default: 'set1'
            %
            AugmentInternal(varargin{:});
        end

        % ======================================================================
        %> @brief SplitTrainTest splits the dataset to train and test.
        %>
        %> For data type 'image', the function rearranges pixels as a pixel (observation) by feature 2D array.
        %> For more details check @c function SplitTrainTestInternal .
        %> The base dataset should be already saved before running augmentation.
        %>
        %> @b Usage
        %>
        %> @code
        %>   dataset = 'pslBase';
        %>   testTargets = {'153'};
        %>   dataType = 'pixel';
        %>   [X, y, Xtest, ytest, cvp, sRGBs, fgMasks] = trainUtility.SplitTrainTest(dataset, testTargets, dataType);
        %>
        %>   hasLabels = true;
        %>   transformFun = @Dimred;
        %>   folds = 5;
        %>   [X, y, Xtest, ytest, cvp, sRGBs, fgMasks] = trainUtility.SplitTrainTest(dataset, testTargets, dataType, hasLabels, folds, transformFun);
        %> @endcode
        %>
        %> @param dataset [char] | The dataset
        %> @param testTargets [string array] | The targetIDs of test targets
        %> @param dataType [char] | The data type, either 'image' or 'pixel'
        %> @param hasLabels [boolean] | A flag to return labels
        %> @param folds [int] | The number of folds
        %> @param transformFun [function handle] | The function handle for the function to be applied
        %>
        %> @retval X [numeric array] | The train data
        %> @retval y [numeric array] | The train values
        %> @retval Xtest [numeric array] | The test data
        %> @retval ytest [numeric array] | The test values
        %> @retval cvp [cell array] | The cross validation index splits
        %> @retval sRGBs [cell array] | The array of sRGBs for test hsi data
        %> @retval fgMasks [cell array] | The foreground masks of sRGBs for test hsi data
        %>
        % ======================================================================
        function [X, y, Xtest, ytest, cvp, sRGBs, fgMasks] = SplitTrainTest(varargin)
            % SplitTrainTest splits the dataset to train and test.
            %
            % For data type 'image', the function rearranges pixels as a pixel (observation) by feature 2D array.
            % For more details check @c function SplitTrainTestInternal .
            % The base dataset should be already saved before running augmentation.
            %
            % @b Usage
            %
            % @code
            %   dataset = 'pslBase';
            %   testTargets = {'153'};
            %   dataType = 'pixel';
            %   [X, y, Xtest, ytest, cvp, sRGBs, fgMasks] = trainUtility.SplitTrainTest(dataset, testTargets, dataType);
            %
            %   hasLabels = true;
            %   transformFun = @Dimred;
            %   folds = 5;
            %   [X, y, Xtest, ytest, cvp, sRGBs, fgMasks] = trainUtility.SplitTrainTest(dataset, testTargets, dataType, hasLabels, folds, transformFun);
            % @endcode
            %
            % @param dataset [char] | The dataset
            % @param testTargets [string array] | The targetIDs of test targets
            % @param dataType [char] | The data type, either 'image' or 'pixel'
            % @param hasLabels [boolean] | A flag to return labels
            % @param folds [int] | The number of folds
            % @param transformFun [function handle] | The function handle for the function to be applied
            %
            % @retval X [numeric array] | The train data
            % @retval y [numeric array] | The train values
            % @retval Xtest [numeric array] | The test data
            % @retval ytest [numeric array] | The test values
            % @retval cvp [cell array] | The cross validation index splits
            % @retval sRGBs [cell array] | The array of sRGBs for test hsi data
            % @retval fgMasks [cell array] | The foreground masks of sRGBs for test hsi data
            %
            [X, y, Xtest, ytest, cvp, sRGBs, fgMasks] = SplitTrainTestInternal(varargin{:});
        end

        % ======================================================================
        %> @brief KfoldPartitions splits cross validation partitions.
        %>
        %> @b Usage
        %>
        %> @code
        %> folds = 5;
        %> [cvp] = trainUtility.KfoldPartitions(numData, folds);
        %> @endcode
        %>
        %> @param numData [int] | The number of data
        %> @param folds [int] | The number of folds
        %>
        %> @retval cvp [cell array] | The cross validation index splits
        % ======================================================================
        function [cvp] = KfoldPartitions(numData, folds)
            % KfoldPartitions splits cross validation partitions.
            %
            % @b Usage
            %
            % @code
            % folds = 5;
            % [cvp] = trainUtility.KfoldPartitions(numData, folds);
            % @endcode
            %
            % @param numData [int] | The number of data
            % @param folds [int] | The number of folds
            %
            % @retval cvp [cell array] | The cross validation index splits

            if nargin < 2
                folds = 10;
            end
            cvp = cvpartition(numData, 'kfold', folds);
        end

        % ======================================================================
        %> @brief SVM trains an RBF SVM classifier.
        %>
        %> You can alter the settings of the SVM classifier according to your specifications.
        %>
        %> @b Usage
        %>
        %> @code
        %> SVMModel = SVM(Xtrain, ytrain);
        %> @endcode
        %>
        %> @param Xtrain [numeric array] | The train data
        %> @param ytrain [numeric array] | The train labels
        %>
        %> @retval SVMModel [model] | The trained SVM model
        % ======================================================================
        function [SVMModel] = SVM(Xtrain, ytrain)
            % SVM trains an RBF SVM classifier.
            %
            % You can alter the settings of the SVM classifier according to your specifications.
            %
            % @b Usage
            %
            % @code
            % SVMModel = SVM(Xtrain, ytrain);
            % @endcode
            %
            % @param Xtrain [numeric array] | The train data
            % @param ytrain [numeric array] | The train labels
            %
            % @retval SVMModel [model] | The trained SVM model

            SVMModel = fitcsvm(Xtrain, ytrain, 'Standardize', true, 'KernelFunction', 'RBF', ...
                'KernelScale', 'auto', 'Cost', [0, 1; 3, 0]);
        end

        % ======================================================================
        %> @brief RunSVM trains and test an SVM classifier.
        %>
        %> @b Usage
        %>
        %> @code
        %> [accuracy, sensitivity, specificity, st, SVMModel] = trainUtility.RunSVM(Xtrain, ytrain, Xvalid, yvalid);
        %> @endcode
        %>
        %> @param Xtrain [numeric array] | The train data
        %> @param ytrain [numeric array] | The train labels
        %> @param Xvalid [numeric array] | The test data
        %> @param yvalid [numeric array] | The test labels
        %>
        %> @retval accuracy [numeric] | The model accuracy
        %> @retval sensitivity [numeric] | The model sensitivity
        %> @retval specificity [numeric] | The model specificity
        %> @retval st [double] | The train run time
        %> @retval SVMModel [model] | The trained SVM model
        % ======================================================================
        function [accuracy, sensitivity, specificity, st, SVMModel] = RunSVM(Xtrain, ytrain, Xvalid, yvalid)
            % RunSVM trains and test an SVM classifier.
            %
            % @b Usage
            %
            % @code
            % [accuracy, sensitivity, specificity, st, SVMModel] = trainUtility.RunSVM(Xtrain, ytrain, Xvalid, yvalid);
            % @endcode
            %
            % @param Xtrain [numeric array] | The train data
            % @param ytrain [numeric array] | The train labels
            % @param Xvalid [numeric array] | The test data
            % @param yvalid [numeric array] | The test labels
            %
            % @retval accuracy [numeric] | The model accuracy
            % @retval sensitivity [numeric] | The model sensitivity
            % @retval specificity [numeric] | The model specificity
            % @retval st [double] | The train run time
            % @retval SVMModel [model] | The trained SVM model
            tic;
            SVMModel = trainUtility.SVM(Xtrain, ytrain);
            st = toc;
            predlabels = predict(SVMModel, Xvalid);

            [accuracy, sensitivity, specificity] = commonUtility.Evaluations(yvalid, predlabels);
        end

        % ======================================================================
        %> @brief StackMultiscale trains a collection of stacked classifiers.
        %>
        %> @b Usage
        %>
        %> @code
        %> transformFun = @(x,i) x{i};
        %> [accuracy, sensitivity, specificity, st, SVMModel, XtrainTrans, XvalidTrans] = trainUtility.StackMultiscale(@trainUtility.SVM, transformFun, 5, 'voting', Xtrain, ytrain, Xvalid, yvalid);
        %> @endcode
        %>
        %> @param classifierFun [function handle] | The classifier function
        %> @param transformFun [function handle] | The transform function
        %> @param numScales [int] | The number of scales / stacked models
        %> @param fusionMethod [char] | The fusion method
        %> @param Xtrain [numeric array] | The train data
        %> @param ytrain [numeric array] | The train labels
        %> @param Xvalid [numeric array] | The test data
        %> @param yvalid [numeric array] | The test labels
        %>
        %> @retval accuracy [numeric] | The model accuracy
        %> @retval sensitivity [numeric] | The model sensitivity
        %> @retval specificity [numeric] | The model specificity
        %> @retval st [double] | The train run time
        %> @retval SVMModel [model] | The trained SVM model
        %> @retval XtrainTrans [numeric array] | The transformed train data
        %> @retval XvalidTrans [numeric array] | The transformed test data
        % ======================================================================
        function [accuracy, sensitivity, specificity, st, models, XtrainTrans, XvalidTrans] = StackMultiscale(classifierFun, transformFun, numScales, fusionMethod, Xtrain, ytrain, Xvalid, yvalid)
            % StackMultiscale trains a collection of stacked classifiers.
            %
            % @b Usage
            %
            % @code
            % transformFun = @(x,i) x{i};
            % [accuracy, sensitivity, specificity, st, SVMModel, XtrainTrans, XvalidTrans] = trainUtility.StackMultiscale(@trainUtility.SVM, transformFun, 5, 'voting', Xtrain, ytrain, Xvalid, yvalid);
            % @endcode
            %
            % @param classifierFun [function handle] | The classifier function
            % @param transformFun [function handle] | The transform function
            % @param numScales [int] | The number of scales / stacked models
            % @param fusionMethod [char] | The fusion method
            % @param Xtrain [numeric array] | The train data
            % @param ytrain [numeric array] | The train labels
            % @param Xvalid [numeric array] | The test data
            % @param yvalid [numeric array] | The test labels
            %
            % @retval accuracy [numeric] | The model accuracy
            % @retval sensitivity [numeric] | The model sensitivity
            % @retval specificity [numeric] | The model specificity
            % @retval st [double] | The train run time
            % @retval SVMModel [model] | The trained SVM model
            % @retval XtrainTrans [numeric array] | The transformed train data
            % @retval XvalidTrans [numeric array] | The transformed test data

            st = 0;
            models = cell(numScales, 1);
            XtrainTrans = cell(numScales, 1);
            XvalidTrans = cell(numScales, 1);
            for scale = 1:numScales

                XtrainScale = transformFun(Xtrain, scale);
                XvalidScale = transformFun(Xvalid, scale);

                tic;
                Mdl = classifierFun(XtrainScale, ytrain);
                tclassifiertemp = toc;
                st = st + tclassifiertemp;

                models{scale} = Mdl;
                XtrainTrans{scale} = XtrainScale;
                XvalidTrans{scale} = XvalidScale;
            end

            predLabels = trainUtility.Predict(models, XvalidTrans, fusionMethod);
            [accuracy, sensitivity, specificity] = commonUtility.Evaluations(yvalid, predLabels);
        end

        % ======================================================================
        %> @brief Predict returns the predicted labels from the model.
        %>
        %> @b Usage
        %>
        %> @code
        %> predLabels = trainUtility.Predict(Mdl, Xtest);
        %>
        %> predLabels = trainUtility.Predict(Mdl, Xtest, 'voting');
        %> @endcode
        %>
        %> @retval Mdl [model] | The trained model
        %> @param Xtest [numeric array] | The test data
        %> @param fusionMethod [char] | Optional: The fusion method. Default: 'voting'.
        %>
        %> @retval predLabels [numeric array] | The predicted labels
        % ======================================================================
        function predLabels = Predict(Mdl, Xtest, fusionMethod)
            % Predict returns the predicted labels from the model.
            %
            % @b Usage
            %
            % @code
            % predLabels = trainUtility.Predict(Mdl, Xtest);
            %
            % predLabels = trainUtility.Predict(Mdl, Xtest, 'voting');
            % @endcode
            %
            % @retval Mdl [model] | The trained model
            % @param Xtest [numeric array] | The test data
            % @param fusionMethod [char] | Optional: The fusion method. Default: 'voting'.
            %
            % @retval predLabels [numeric array] | The predicted labels

            if nargin < 3
                fusionMethod = 'voting';
            end

            if iscell(Mdl)
                models = Mdl;
                numModels = numel(models);
                preds = zeros(size(Xtest{1}, 1), numModels);
                for i = 1:numModels
                    Mdl = models{i};
                    scores = Xtest{i};
                    preds(:, i) = predict(Mdl, scores);
                end

                if strcmpi(fusionMethod, 'voting')
                    predLabels = round(sum(preds./size(preds, 2), 2));
                else
                    error('Not supported fusion method.')
                end

            else
                predLabels = predict(Mdl, Xtest);
            end
        end

        % ======================================================================
        %> @brief DimredAndTrain trains and test an SVM classifier after dimension reduction.
        %>
        %> @b Usage
        %>
        %> @code
        %> [accuracy, sensitivity, specificity, tdimred, st, Mdl, Xtrainscores, Xvalidscores] = trainUtility.DimredAndTrain(Xtrain, ytrain, Xvalid, yvalid, method, q);
        %> @endcode
        %>
        %> @param Xtrain [numeric array] | The train data
        %> @param ytrain [numeric array] | The train labels
        %> @param Xvalid [numeric array] | The test data
        %> @param yvalid [numeric array] | The test labels
        %> @param method [char] | The dimension reduction method
        %> @param q [int] | The reduced dimension
        %> @param varargin | Additional optional arguments
        %>
        %> @retval accuracy [numeric] | The model accuracy
        %> @retval sensitivity [numeric] | The model sensitivity
        %> @retval specificity [numeric] | The model specificity
        %> @retval tdimred [double] | The dimension reduction run time
        %> @retval st [double] | The train run time
        %> @retval SVMModel [model] | The trained SVM model
        %> @retval Xtrainscores [numeric array] | The dimension-reduced train data
        %> @retval Xvalidscores [numeric array] | The dimension-reduced test data
        % ======================================================================
        function [accuracy, sensitivity, specificity, tdimred, st, Mdl, Xtrainscores, Xvalidscores] = DimredAndTrain(Xtrain, ytrain, Xvalid, yvalid, method, q, varargin)
            % DimredAndTrain trains and test an SVM classifier after dimension reduction.
            %
            % @b Usage
            %
            % @code
            % [accuracy, sensitivity, specificity, st, SVMModel] = trainUtility.DimredAndTrain(Xtrain, ytrain, Xvalid, yvalid, method, q);
            % @endcode
            %
            % @param Xtrain [numeric array] | The train data
            % @param ytrain [numeric array] | The train labels
            % @param Xvalid [numeric array] | The test data
            % @param yvalid [numeric array] | The test labels
            % @param method [char] | The dimension reduction method
            % @param q [int] | The reduced dimension
            % @param varargin | Additional optional arguments
            %
            % @retval accuracy [numeric] | The model accuracy
            % @retval sensitivity [numeric] | The model sensitivity
            % @retval specificity [numeric] | The model specificity
            % @retval tdimred [double] | The dimension reduction run time
            % @retval st [double] | The train run time
            % @retval SVMModel [model] | The trained SVM model
            % @retval Xtrainscores [numeric array] | The dimension-reduced train data
            % @retval Xvalidscores [numeric array] | The dimension-reduced test data

            Xtrainscores = Xtrain;
            Xvalidscores = Xvalid;
            tdimred = 0;

            switch lower(method)
                case 'pca'
                    tic;
                    [coeff, Xtrainscores, latent, explained, objective] = Dimred(Xtrain, 'pca', q);
                    tdimred = toc;
                    Xvalidscores = Xvalid * coeff;
                    [accuracy, sensitivity, specificity, st, Mdl] = trainUtility.RunSVM(Xtrainscores, ytrain, Xvalidscores, yvalid);

                case 'rica'
                    tic;
                    warning('off', 'all');
                    [coeff, Xtrainscores, ~, ~, ~] = Dimred(Xtrain, 'rica', q);
                    warning('on', 'all');
                    tdimred = toc;
                    Xvalidscores = Xvalid * coeff;
                    [accuracy, sensitivity, specificity, st, Mdl] = trainUtility.RunSVM(Xtrainscores, ytrain, Xvalidscores, yvalid);

                case 'simple'
                    wavelengths = hsiUtility.GetWavelengths(311);
                    tic;
                    id1 = find(wavelengths == 540);
                    id2 = find(wavelengths == 650);
                    Xtrainscores = Xtrain(:, [id1, id2]);
                    tdimred = toc;
                    Xvalidscores = Xvalid(:, [id1, id2]);
                    [accuracy, sensitivity, specificity, st, Mdl] = trainUtility.RunSVM(Xtrainscores, ytrain, Xvalidscores, yvalid);

                case 'lda'
                    tic;
                    [~, ~, ~, ~, ~, LMdl] = Dimred(Xtrain, 'lda', q, ytrain);
                    tdimred = toc;
                    st = tdimred;
                    ypred1 = predict(LMdl, Xvalid);
                    [accuracy, sensitivity, specificity] = commonUtility.Evaluations(yvalid, ypred1);
                    Mdl = LMdl;

                case 'qda'
                    tic;
                    [~, ~, ~, ~, ~, LMdl] = Dimred(Xtrain, 'qda', q, ytrain);
                    tdimred = toc;
                    st = tdimred;
                    ypred1 = predict(LMdl, Xvalid);
                    [accuracy, sensitivity, specificity] = commonUtility.Evaluations(yvalid, ypred1);
                    Mdl = LMdl;

                case 'rfi'
                    [accuracy, sensitivity, specificity, st, Mdl] = trainUtility.RunSVM(Xtrain, ytrain, Xvalid, yvalid);

                case 'autoencoder'
                    tic;
                    autoenc = trainAutoencoder(Xtrain', q, 'MaxEpochs', 400, ...
                        'UseGPU', true);
                    tdimred = toc;
                    Xtrainscores = encode(autoenc, Xtrain')';
                    Xvalidscores = encode(autoenc, Xvalid')';
                    [accuracy, sensitivity, specificity, st, Mdl] = trainUtility.RunSVM(Xtrainscores, ytrain, Xvalidscores, yvalid);

                case 'msuperpca'
                    [accuracy, sensitivity, specificity, st, Mdl, Xtrainscores, Xvalidscores] = trainUtility.StackMultiscale(@trainUtility.SVM, varargin{1}, varargin{2}, 'voting', Xtrain, ytrain, Xvalid, yvalid);

                otherwise

                    [accuracy, sensitivity, specificity, st, Mdl] = trainUtility.RunSVM(Xtrain, ytrain, Xvalid, yvalid);
            end
        end

        % ======================================================================
        %> @brief RunKfoldValidation trains and tests an classifier with cross validation.
        %>
        %> @b Usage
        %>
        %> @code
        %> [accuracy, sensitivity, specificity, tdimred, tclassifier] = trainUtility.RunKfoldValidation(X, y, cvp, method, q);
        %> @endcode
        %>
        %> @param X [numeric array] | The data
        %> @param y [numeric array] | The labels
        %> @param cvp [cell array] | The cross validation index splits
        %> @param method [char] | The dimension reduction method
        %> @param q [int] | The reduced dimension
        %> @param varargin | Additional optional arguments
        %>
        %> @retval accuracy [numeric] | The model accuracy
        %> @retval sensitivity [numeric] | The model sensitivity
        %> @retval specificity [numeric] | The model specificity
        %> @retval tdimred [double] | The dimension reduction run time
        %> @retval tclassifier [double] | The train run time
        % ======================================================================
        function [accuracy, sensitivity, specificity, tdimred, tclassifier] = RunKfoldValidation(X, y, cvp, method, q, varargin)
            % RunKfoldValidation trains and tests an classifier with cross validation.
            %
            % @b Usage
            %
            % @code
            % [accuracy, sensitivity, specificity, tdimred, tclassifier] = trainUtility.RunKfoldValidation(X, y, cvp, method, q);
            % @endcode
            %
            % @param X [numeric array] | The data
            % @param y [numeric array] | The labels
            % @param cvp [cell array] | The cross validation index splits
            % @param method [char] | The dimension reduction method
            % @param q [int] | The reduced dimension
            % @param varargin | Additional optional arguments
            %
            % @retval accuracy [numeric] | The model accuracy
            % @retval sensitivity [numeric] | The model sensitivity
            % @retval specificity [numeric] | The model specificity
            % @retval tdimred [double] | The dimension reduction run time
            % @retval tclassifier [double] | The train run time
            numvalidsets = cvp.NumTestSets;
            acc = zeros(1, numvalidsets);
            sens = zeros(1, numvalidsets);
            spec = zeros(1, numvalidsets);
            st = zeros(1, numvalidsets);

            for k = 1:numvalidsets
                if iscell(X)
                    Xtrain = cellfun(@(x) x(cvp.training(k), :), X, 'un', 0);
                    Xvalid = cellfun(@(x) x(cvp.test(k), :), X, 'un', 0);
                else
                    Xtrain = X(cvp.training(k), :);
                    Xvalid = X(cvp.test(k), :);
                end

                if iscell(y)
                    ytrain = cellfun(@(x) y(cvp.training(k), :), X, 'un', 0);
                    yvalid = cellfun(@(x) y(cvp.test(k), :), X, 'un', 0);
                else
                    ytrain = y(cvp.training(k), :);
                    yvalid = y(cvp.test(k), :);
                end

                [acc(k), sens(k), spec(k), tdimred, st(k), ~, ~, ~] = trainUtility.DimredAndTrain(Xtrain, ytrain, Xvalid, yvalid, method, q, varargin{:});
            end

            accuracy = mean(acc);
            sensitivity = mean(sens);
            specificity = mean(spec);
            tclassifier = mean(st);
            fprintf('%d-fold validated - Accuracy: %.5f, Sensitivity: %.5f, Specificity: %.5f, DR Train time: %.5f, SVM Train time: %.5f \n\n', ...
                numvalidsets, accuracy, sensitivity, specificity, tdimred, tclassifier);
        end

        % ======================================================================
        %> @brief ValidateTest returns the results after cross validation of a classifier.
        %>
        %> @b Usage
        %>
        %> @code
        %> [valTrain, valTest] = trainUtility.ValidateTest(Xtrain, ytrain, Xtest, ytest, cvp, method, q);
        %> @endcode
        %>
        %> @param Xtrain [numeric array] | The train data
        %> @param ytrain [numeric array] | The train labels
        %> @param Xvalid [numeric array] | The test data
        %> @param yvalid [numeric array] | The test labels
        %> @param cvp [cell array] | The cross validation index splits
        %> @param method [char] | The dimension reduction method
        %> @param q [int] | The reduced dimension
        %>
        %> @retval valTrain [numeric array] | The train performance results
        %> @retval valTest [numeric array] | The validation performance results
        % ======================================================================
        function [valTrain, valTest] = ValidateTest(Xtrain, ytrain, Xvalid, yvalid, cvp, method, q)
            % ValidateTest returns the results after cross validation of a classifier.
            %
            % @b Usage
            %
            % @code
            % [valTrain, valTest] = trainUtility.ValidateTest(Xtrain, ytrain, Xtest, ytest, cvp, method, q);
            % @endcode
            %
            % @param Xtrain [numeric array] | The train data
            % @param ytrain [numeric array] | The train labels
            % @param Xvalid [numeric array] | The test data
            % @param yvalid [numeric array] | The test labels
            % @param cvp [cell array] | The cross validation index splits
            % @param method [char] | The dimension reduction method
            % @param q [int] | The reduced dimension
            %
            %> @retval valTrain [numeric array] | The train performance results
            %> @retval valTest [numeric array] | The validation performance results

            [accuracy, sensitivity, specificity, tdimred, tclassifier] = trainUtility.RunKfoldValidation(Xtrain, ytrain, cvp, method, q);
            valTrain = [accuracy, sensitivity, specificity, tdimred, tclassifier];
            fprintf('Train - Accuracy: %.5f, Sensitivity: %.5f, Specificity: %.5f, DR Train time: %.5f, SVM Train time: %.5f \n\n', ...
                accuracy, sensitivity, specificity, tdimred, tclassifier);
            [accuracy, sensitivity, specificity, tdimred, tclassifier, ~, ~, ~] = trainUtility.DimredAndTrain(Xtrain, ytrain, Xvalid, yvalid, method, q);
            fprintf('Test - Accuracy: %.5f, Sensitivity: %.5f, Specificity: %.5f, DR Train time: %.5f, SVM Train time: %.5f \n\n', ...
                accuracy, sensitivity, specificity, tdimred, tclassifier);
            valTest = [accuracy, sensitivity, specificity, tdimred, tclassifier];
        end

        % ======================================================================
        %> @brief ValidateTest2 returns the results after cross validation of a classifier.
        %>
        %> Need to set config::[saveFolder] for image output.
        %>
        %> @b Usage
        %>
        %> @code
        %> [valTrain, valTest] = trainUtility.ValidateTest2(Xtrain, ytrain, Xtest, ytest, sRGBs, fgMasks, cvp, method, q);
        %>
        %> transformFun = @(x, i) IndexCell(x, i);
        %> numScales = numel(pixelNumArray);
        %> [valTrain, valTest] = trainUtility.ValidateTest2(Xtrain, ytrain, Xtest, ytest, sRGBs, fgMasks, cvp, method, q, transformFun, numScales);
        %> @endcode
        %>
        %> @param Xtrain [numeric array] | The train data
        %> @param ytrain [numeric array] | The train labels
        %> @param Xvalid [numeric array] | The test data
        %> @param yvalid [numeric array] | The test labels
        %> @param sRGBs [cell array] | The sRGB images for test data
        %> @param fgMasks [cell array] | The foreground masks for test data
        %> @param cvp [cell array] | The cross validation index splits
        %> @param method [char] | The dimension reduction method
        %> @param q [int] | The reduced dimension
        %> @param varargin | Additional optional arguments
        %>
        %> @retval valTrain [numeric array] | The train performance results
        %> @retval valTest [numeric array] | The validation performance results
        % ======================================================================
        function [valTrain, valTest] = ValidateTest2(X, y, Xvalid, yvalid, sRGBs, fgMasks, cvp, method, q, varargin)
            % ValidateTest2 returns the results after cross validation of a classifier.
            %
            % Need to set config::[saveFolder] for image output.
            %
            % @b Usage
            %
            % @code
            % [valTrain, valTest] = trainUtility.ValidateTest2(Xtrain, ytrain, Xtest, ytest, sRGBs, fgMasks, cvp, method, q);
            %
            % transformFun = @(x, i) IndexCell(x, i);
            % numScales = numel(pixelNumArray);
            % [valTrain, valTest] = trainUtility.ValidateTest2(Xtrain, ytrain, Xtest, ytest, sRGBs, fgMasks, cvp, method, q, transformFun, numScales);
            % @endcode
            %
            % @param Xtrain [numeric array] | The train data
            % @param ytrain [numeric array] | The train labels
            % @param Xvalid [numeric array] | The test data
            % @param yvalid [numeric array] | The test labels
            % @param sRGBs [cell array] | The sRGB images for test data
            % @param fgMasks [cell array] | The foreground masks for test data
            % @param cvp [cell array] | The cross validation index splits
            % @param method [char] | The dimension reduction method
            % @param q [int] | The reduced dimension
            % @param varargin | Additional optional arguments
            %
            % @retval valTrain [numeric array] | The train performance results
            % @retval valTest [numeric array] | The validation performance results

            [accuracy, sensitivity, specificity, tdimred, tclassifier] = trainUtility.RunKfoldValidation(X, y, cvp, method, q, varargin{:});
            valTrain = [accuracy, sensitivity, specificity, tdimred, tclassifier];
            fprintf('Train - Accuracy: %.5f, Sensitivity: %.5f, Specificity: %.5f, DR Train time: %.5f, SVM Train time: %.5f \n\n', ...
                accuracy, sensitivity, specificity, tdimred, tclassifier);
            [accuracy, sensitivity, specificity, tdimred, tclassifier, Mdl, ~, testscores] = trainUtility.DimredAndTrain(X, y, Xvalid, yvalid, method, q, varargin{:});
            fprintf('Test - Accuracy: %.5f, Sensitivity: %.5f, Specificity: %.5f, DR Train time: %.5f, SVM Train time: %.5f \n\n', ...
                accuracy, sensitivity, specificity, tdimred, tclassifier);
            valTest = [accuracy, sensitivity, specificity, tdimred, tclassifier];

            predlabels = trainUtility.Predict(Mdl, testscores);
            origSizes = cellfun(@(x) size(x), fgMasks, 'un', 0);
            predLabels = hsi.RecoverSpatialDimensions(predlabels, origSizes, fgMasks);
            trueLabels = hsi.RecoverSpatialDimensions(yvalid, origSizes, fgMasks);
            for i = 1:numel(sRGBs)
                imgFilePath = commonUtility.GetFilename('output', fullfile(config.GetSetting('saveFolder'), ...
                    strcat('pred_', num2str(i), '_', method, '_', num2str(q))), 'png');
                jacsim = jaccard(predLabels{i}, trueLabels{i});
                figTitle = sprintf('%s', strcat(method, '-', num2str(q), ' (', sprintf('%.2f', jacsim*100), '%)'));
                plots.Overlay(4, imgFilePath, sRGBs{i}, predLabels{i}, figTitle);
            end
        end
    end
end