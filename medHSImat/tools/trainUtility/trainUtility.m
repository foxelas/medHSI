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
        %> @brief PreprocessInternal transforms the dataset into images or pixels as preparation for training.
        %>
        %> For data type 'image', the function rearranges pixels as a pixel (observation) by feature 2D array.
        %> For more details check @c function PreprocessInternal .
        %> This function can also handle multiscale transformations.
        %>
        %> @b Usage
        %>
        %> @code
        %>   [X, y, sRGBs, fgMasks, labelImgs] = trainUtility.Preprocess(hsiList, labelInfos, dataType);
        %>
        %>   transformFun = @Dimred;
        %>   [X, y, sRGBs, fgMasks, labelImgs] = PreprocessInternal(hsiList, labelInfos, dataType, transformFun);
        %> @endcode
        %>
        %> @param hsiList [cell array] | The list of hsi objects
        %> @param labelInfos [cell array] | The list of hsiInfo objects
        %> @param dataType [char] | The target data type, either 'hsi', 'image' or 'pixel'
        %> @param transformFun [function handle] | Optional: The function handle for the function to be applied. Default: None.
        %>
        %> @retval X [numeric array or cell array] | The processed data
        %> @retval y [numeric array or cell array] | The processed values
        %> @retval sRGBs [cell array] | The array of sRGBs for the data
        %> @retval fgMasks [cell array] | The foreground masks of sRGBs for the data
        %> @retval labelImgs [cell array] | The label masks for the data
        %>
        % ======================================================================
        function [X, y, sRGBs, fgMasks, labelImgs] = Preprocess(hsiList, labelInfos, varargin)
        % PreprocessInternal transforms the dataset into images or pixels as preparation for training.
        %
        % For data type 'image', the function rearranges pixels as a pixel (observation) by feature 2D array.
        % For more details check @c function PreprocessInternal .
        % This function can also handle multiscale transformations.
        %
        % @b Usage
        %
        % @code
        %   [X, y, sRGBs, fgMasks, labelImgs] = trainUtility.Preprocess(hsiList, labelInfos, dataType);
        %
        %   transformFun = @Dimred;
        %   [X, y, sRGBs, fgMasks, labelImgs] = PreprocessInternal(hsiList, labelInfos, dataType, transformFun);
        % @endcode
        %
        % @param hsiList [cell array] | The list of hsi objects
        % @param labelInfos [cell array] | The list of hsiInfo objects
        % @param dataType [char] | The target data type, either 'hsi', 'image' or 'pixel'
        % @param transformFun [function handle] | Optional: The function handle for the function to be applied. Default: None.
        %
        % @retval X [numeric array or cell array] | The processed data
        % @retval y [numeric array or cell array] | The processed values
        % @retval sRGBs [cell array] | The array of sRGBs for the data
        % @retval fgMasks [cell array] | The foreground masks of sRGBs for the data
        % @retval labelImgs [cell array] | The label masks for the data
        %
            [X, y, sRGBs, fgMasks, labelImgs] = PreprocessInternal(hsiList, labelInfos, varargin{:});
        end
        
        % ======================================================================
        %> @brief SplitDatasetInternalsplits the dataset to train, test and prepares a cross validation setting.
        %>
        %> For more details check @c function SplitDatasetInternal .
        %>
        %> @b Usage
        %>
        %> @code
        %>   [trainData, testData, cvp] = trainUtility.SplitDataset(dataset, folds, testTargets, dataType);
        %>
        %>   transformFun = @Dimred;
        %>   [trainData, testData, cvp] = SplitDatasetInternal(dataset, folds, testTargets, dataType, transformFun);
        %> @endcode
        %>
        %> @param dataset [char] | The target dataset
        %> @param folds [numeric] | The number of folds
        %> @param testTargets [cell array] | The IDs of the test targets 
        %> @param dataType [char] | The target data type, either 'hsi', 'image' or 'pixel'
        %> @param transformFun [function handle] | Optional: The function handle for the function to be applied. Default: None.
        %>
        %> @retval trainData [struct] | The train data
        %> @retval testData [struct] | The test data
        %> @retval cvp [struct] | The cross validation settings
        %>
        % ======================================================================
        function [trainData, testData, cvp] = SplitDataset(dataset, folds, testTargets, dataType, varargin)
            % SplitDatasetInternalsplits the dataset to train, test and prepares a cross validation setting.
            %
            % For more details check @c function SplitDatasetInternal .
            %
            % @b Usage
            %
            % @code
            %   [trainData, testData, cvp] = trainUtility.SplitDataset(dataset, folds, testTargets, dataType);
            %
            %   transformFun = @Dimred;
            %   [trainData, testData, cvp] = SplitDatasetInternal(dataset, folds, testTargets, dataType, transformFun);
            % @endcode
            %
            % @param dataset [char] | The target dataset
            % @param folds [numeric] | The number of folds
            % @param testTargets [cell array] | The IDs of the test targets 
            % @param dataType [char] | The target data type, either 'hsi', 'image' or 'pixel'
            % @param transformFun [function handle] | Optional: The function handle for the function to be applied. Default: None.
            %
            % @retval trainData [struct] | The train data
            % @retval testData [struct] | The test data
            % @retval cvp [struct] | The cross validation settings
            %
            [trainData, testData, cvp] = SplitDatasetInternal(dataset, folds, testTargets, dataType, varargin{:});
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
                'KernelScale', 'auto', 'IterationLimit', 10000); %'Cost', [0, 1; 3, 0],
            numIter = SVMModel.NumIterations;
            % TO REMOVE
            if numIter == 10000 
                disp('SVM finished because of MaxIter reached.')
            end
            % TO REMOVE
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
        %>
        %> @retval accuracy [numeric] | The model accuracy
        %> @retval sensitivity [numeric] | The model sensitivity
        %> @retval specificity [numeric] | The model specificity
        %> @retval st [double] | The train run time
        %> @retval SVMModel [model] | The trained SVM model
        % ======================================================================
        function [predlabels, st, SVMModel] = RunSVM(Xtrain, ytrain, Xvalid)
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
            %
            % @retval accuracy [numeric] | The model accuracy
            % @retval sensitivity [numeric] | The model sensitivity
            % @retval specificity [numeric] | The model specificity
            % @retval st [double] | The train run time
            % @retval SVMModel [model] | The trained SVM model
            
            % TO REMOVE
            factors = 5;
            kk = ceil(decimate(1:size(Xtrain,1), factors));
            Xtrain = Xtrain(kk, :);
            ytrain = ytrain(kk, :);
            % TO REMOVE 
            
            tic;
            SVMModel = trainUtility.SVM(Xtrain, ytrain);
            st = toc;
            predlabels = predict(SVMModel, Xvalid);
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
        function [predLabels, st, Mdl, XtrainTrans, XvalidTrans] = StackMultiscale(classifierFun, transformFun, numScales, fusionMethod, Xtrain, ytrain, Xvalid)
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
        %> @brief Cell2Mat concatenates the contents of a cell array of values to a matrix.
        %>
        %> @b Usage
        %>
        %> @code
        %> [matArr] = trainUtility.Cell2Mat(cellArr);
        %> @endcode
        %>
        %> @param cellArr [cell array] | The cell array
        %>
        %> @retval arr [numeric array] | The array
        % ======================================================================
        function [arr] = Cell2Mat(cellArr)
        % Cell2Mat concatenates the contents of a cell array of values to a matrix.
        %
        % @b Usage
        %
        % @code
        % [matArr] = trainUtility.Cell2Mat(cellArr);
        % @endcode
        %
        % @param cellArr [cell array] | The cell array
        %
        % @retval arr [numeric array] | The array
        
            cellArr = cellfun(@(x) x', cellArr, 'un', 0);
            arr = [cellArr{:}];
            arr = arr';              
        end 
        
        % ======================================================================
        %> @brief DimredAndTrain trains and test an SVM classifier after dimension reduction.
        %>
        %> @b Usage
        %>
        %> @code
        %> [accuracy, sensitivity, specificity, jac, tdimred, st, Mdl, Xtrainscores, Xvalidscores] = trainUtility.DimredAndTrain(trainData, testData, method, q);
        %> @endcode
        %>
        %> @param trainData [struct] | The train data
        %> @param testData [struct] | The test data
        %> @param method [char] | The dimension reduction method
        %> @param q [int] | The reduced dimension
        %> @param varargin | Additional optional arguments
        %>
        %> @retval accuracy [numeric] | The model's accuracy
        %> @retval sensitivity [numeric] | The model's sensitivity
        %> @retval specificity [numeric] | The model's specificity
        %> @retval jac [numeric] | The model's jaccard coefficient
        %> @retval tdimred [double] | The dimension reduction run time
        %> @retval st [double] | The train run time
        %> @retval SVMModel [model] | The trained SVM model
        %> @retval Xvalid [numeric array] | The dimension-reduced test data
        % ======================================================================
        function [accuracy, sensitivity, specificity, jac, tdimred, st, Mdl, Xvalid] = DimredAndTrain(trainData, testData, method, q, varargin)
        % DimredAndTrain trains and test an SVM classifier after dimension reduction.
        %
        % @b Usage
        %
        % @code
        % [accuracy, sensitivity, specificity, jac, tdimred, st, Mdl, Xtrainscores, Xvalidscores] = trainUtility.DimredAndTrain(trainData, testData, method, q);
        % @endcode
        %
        % @param trainData [struct] | The train data
        % @param testData [struct] | The test data
        % @param method [char] | The dimension reduction method
        % @param q [int] | The reduced dimension
        % @param varargin | Additional optional arguments
        %
        % @retval accuracy [numeric] | The model's accuracy
        % @retval sensitivity [numeric] | The model's sensitivity
        % @retval specificity [numeric] | The model's specificity
        % @retval jac [numeric] | The model's jaccard coefficient
        % @retval tdimred [double] | The dimension reduction run time
        % @retval st [double] | The train run time
        % @retval SVMModel [model] | The trained SVM model
        % @retval Xvalid [numeric array] | The dimension-reduced test data

            tic;
            transTrain = cellfun(@(x) x.Transform(method, q, varargin{:}), {trainData.Values}, 'un', 0);
            tdimred = toc;
            tdimred = tdimred / numel(transTrain);
            transTest = cellfun(@(x) x.Transform(method, q, varargin{:}), {testData.Values}, 'un', 0);

            Xtrainscores = trainUtility.Cell2Mat(transTrain);
            transyTrain = cellfun(@(x,y) GetMaskedPixelsInternal(x.Labels, y.FgMask), {trainData.Labels}, {trainData.Values}, 'un', 0);
            ytrain = trainUtility.Cell2Mat(transyTrain);
            
            Xvalidscores = trainUtility.Cell2Mat(transTest);
            Xvalid = transTest;
            transyValid = cellfun(@(x,y) GetMaskedPixelsInternal(x.Labels, y.FgMask), {testData.Labels}, {testData.Values}, 'un', 0);
            yvalid = trainUtility.Cell2Mat(transyValid);
            
            switch lower(method)
                case 'pca-all'
                    tic;
                    [coeff, Xtrainscores, ~, ~, ~] = Dimred(Xtrainscores, 'pca', q);
                    tdimred = toc;
                    Xvalidscores = Xvalidscores * coeff;
                    Xvalid = cellfun(@(x) x * coeff, Xvalid, 'un', 0);
                    [predlabels, st, Mdl] = trainUtility.RunSVM(Xtrainscores, ytrain, Xvalidscores);
                                        
                case 'rica-all'
                    tic;
                    warning('off', 'all');
                    [coeff, Xtrainscores, ~, ~, ~] = Dimred(Xtrainscores, 'rica', q);
                    warning('on', 'all');
                    tdimred = toc;
                    Xvalidscores = Xvalidscores * coeff;
                    Xvalid = cellfun(@(x) x * coeff, Xvalid, 'un', 0);
                    [predlabels, st, Mdl] = trainUtility.RunSVM(Xtrainscores, ytrain, Xvalidscores);                 

                case 'autoencoder'
                    tic;
                    autoenc = trainAutoencoder(Xtrainscores', q, 'MaxEpochs', 400, ...
                        'UseGPU', true);
                    tdimred = toc;
                    Xtrainscores = Dimred(Xtrainscores, 'autoencoder', q, autoenc);
                    Xvalidscores = Dimred(Xvalidscores, 'autoencoder', q, autoenc);
                    Xvalid = cellfun(@(x) Dimred(x, 'autoencoder', q, autoenc), Xvalid, 'un', 0);
                    [predlabels, st, Mdl] = trainUtility.RunSVM(Xtrainscores, ytrain, Xvalidscores);

                case 'msuperpca'
                    [predlabels, st, Mdl, Xtrainscores, Xvalidscores] = trainUtility.StackMultiscale(@trainUtility.SVM, varargin{1}, varargin{2}, 'voting', Xtrainscores, ytrain, Xvalidscores);

                otherwise
                    [predlabels, st, Mdl] = trainUtility.RunSVM(Xtrainscores, ytrain, Xvalidscores);
            end
            
            [accuracy, sensitivity, specificity] = commonUtility.Evaluations(yvalid, predlabels);
            jac = commonUtility.Jaccard(yvalid, predlabels);
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
        %> @param trainData [struct] | The train data
        %> @param cvp [cell array] | The cross validation index splits
        %> @param method [char] | The dimension reduction method
        %> @param q [int] | The reduced dimension
        %> @param varargin | Additional optional arguments
        %>
        %> @retval accuracy [numeric] | The model accuracy
        %> @retval sensitivity [numeric] | The model sensitivity
        %> @retval specificity [numeric] | The model specificity
        %> @retval jac [numeric] | The model's jaccard coefficient
        %> @retval tdimred [double] | The dimension reduction run time
        %> @retval tclassifier [double] | The train run time
        % ======================================================================
        function [accuracy, sensitivity, specificity, jacCoeff, tdimred, tclassifier] = RunKfoldValidation(trainData, cvp, method, q, varargin)
            % RunKfoldValidation trains and tests an classifier with cross validation.
            %
            % @b Usage
            %
            % @code
            % [accuracy, sensitivity, specificity, tdimred, tclassifier] = trainUtility.RunKfoldValidation(X, y, cvp, method, q);
            % @endcode
            %
            % @param trainData [struct] | The train data
            % @param cvp [cell array] | The cross validation index splits
            % @param method [char] | The dimension reduction method
            % @param q [int] | The reduced dimension
            % @param varargin | Additional optional arguments
            %
            % @retval accuracy [numeric] | The model accuracy
            % @retval sensitivity [numeric] | The model sensitivity
            % @retval specificity [numeric] | The model specificity
            % @retval jac [numeric] | The model's jaccard coefficient
            % @retval tdimred [double] | The dimension reduction run time
            % @retval tclassifier [double] | The train run time
            numvalidsets = cvp.NumTestSets;   
            acc = zeros(1, numvalidsets);
            sens = zeros(1, numvalidsets);
            spec = zeros(1, numvalidsets);
            st = zeros(1, numvalidsets);
            jac = zeros(1, numvalidsets);

            for k = 1:numvalidsets
                trainDataFold = trainData(cvp.training(k));
                testDataFold = trainData(cvp.test(k));

                [acc(k), sens(k), spec(k), jac(k), tdimred, st(k), ~, ~] = trainUtility.DimredAndTrain(trainDataFold, testDataFold, method, q, varargin{:});
            end

            accuracy = mean(acc);
            sensitivity = mean(sens);
            specificity = mean(spec);
            tclassifier = mean(st);
            jacCoeff = mean(jac);
            fprintf('%d-fold validated - Jaccard: %.3f %% Accuracy: %.3f %%, Sensitivity: %.3f %%, Specificity: %.3f %%, DR Train time: %.5f, SVM Train time: %.5f \n\n', ...
                numvalidsets, jacCoeff * 100, accuracy *100, sensitivity *100, specificity * 100, tdimred, tclassifier);
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
        %> [valTrain, valTest] = trainUtility.ValidateTest2(trainData, testData, cvp, method, q);
        %>
        %> transformFun = @(x, i) IndexCell(x, i);
        %> numScales = numel(pixelNumArray);
        %> [valTrain, valTest] = trainUtility.ValidateTest2(trainData, testData, cvp, method, q, transformFun, numScales);
        %> @endcode
        %>
        %> @param trainData [struct] | The train data
        %> @param testData [struct] | The test data
        %> @param cvp [cell array] | The cross validation index splits
        %> @param method [char] | The dimension reduction method
        %> @param q [int] | The reduced dimension
        %> @param varargin | Additional optional arguments
        %>
        %> @retval valTrain [numeric array] | The train performance results
        %> @retval valTest [numeric array] | The validation performance results
        % ======================================================================
        function [valTrain, valTest] = ValidateTest2(trainData, testData, cvp, method, q, varargin)
        % ValidateTest2 returns the results after cross validation of a classifier.
        %
        % Need to set config::[saveFolder] for image output.
        %
        % @b Usage
        %
        % @code
        % [valTrain, valTest] = trainUtility.ValidateTest2(trainData, testData, cvp, method, q);
        %
        % transformFun = @(x, i) IndexCell(x, i);
        % numScales = numel(pixelNumArray);
        % [valTrain, valTest] = trainUtility.ValidateTest2(trainData, testData, cvp, method, q, transformFun, numScales);
        % @endcode
        %
        % @param trainData [struct] | The train data
        % @param testData [struct] | The test data
        % @param cvp [cell array] | The cross validation index splits
        % @param method [char] | The dimension reduction method
        % @param q [int] | The reduced dimension
        % @param varargin | Additional optional arguments
        %
        % @retval valTrain [numeric array] | The train performance results
        % @retval valTest [numeric array] | The validation performance results
            
            
            [accuracy, sensitivity, specificity, jacCoeff, tdimred, tclassifier] = trainUtility.RunKfoldValidation(trainData, cvp, method, q, varargin{:});
            valTrain = [jacCoeff, accuracy, sensitivity, specificity, tdimred, tclassifier];

            
            [accuracy, sensitivity, specificity, jacCoeff, tdimred, tclassifier, Mdl, testscores] = trainUtility.DimredAndTrain(trainData, testData, method, q, varargin{:});
            fprintf('Test - Jaccard: %.3f %%, Accuracy: %.3f %%, Sensitivity: %.3f %%, Specificity: %.3f %%, DR Train time: %.5f, SVM Train time: %.5f \n\n', ...
                jacCoeff * 100, accuracy * 100, sensitivity * 100, specificity * 100, tdimred, tclassifier);
            valTest = [jacCoeff, accuracy, sensitivity, specificity, tdimred, tclassifier];
            
            ytest = cellfun(@(x,y) GetMaskedPixelsInternal(x.Labels, y.FgMask), {testData.Labels}, {testData.Values}, 'un', 0);
            
            fgMasks = {testData.Masks};
            sRGBs = {testData.RGBs};
            predlabels = cellfun(@(x) trainUtility.Predict(Mdl, x), testscores, 'un', 0);
            origSizes = cellfun(@(x) size(x), fgMasks, 'un', 0);

            for i = 1:numel(sRGBs)
                predLabels = hsi.RecoverSpatialDimensions(predlabels{i}, origSizes{i}, fgMasks{i});
                trueLabels = hsi.RecoverSpatialDimensions(ytest{i}, origSizes{i}, fgMasks{i});
                jacsim = commonUtility.Jaccard(predLabels{i}, trueLabels{i});

                imgFilePath = commonUtility.GetFilename('output', fullfile(config.GetSetting('saveFolder'), ...
                    strcat('pred_', num2str(i), '_', method, '_', num2str(q))), 'png');
                figTitle = sprintf('%s', strcat(method, '-', num2str(q), ' (', sprintf('%.2f', jacsim*100), '%)'));
                plots.Overlay(4, imgFilePath, sRGBs{i}, predLabels{i}, figTitle);
            end
        end
    end
end