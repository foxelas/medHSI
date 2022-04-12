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
        %> For details check @c AugmentInternal .
        %>
        %> 'set1': applies vertical and horizontal flipping.
        %> 'set2': applies random rotation.
        %>
        %> @b Usage
        %>
        %> @code
        %> baseDataset = 'pslData';
        %> hsiUtility.PrepareDataset(baseDataset, {'tissue', true});
        %>
        %> augType = 'set1';
        %> augmentedDataset = 'pslDataAug';
        %> trainUtility.Augment(baseDataset, augmentedDataset, augType);
        %> @endcode
        %>
        %> @param baseDataset [char] | The base dataset
        %> @param targetDataset [char] | The target dataset
        %> @param augType [char] | Optional: The augmentation type ('set1' or 'set2'). Default: 'set1'
        %>
        % ======================================================================
        function [] = Augment(varargin)
            % Augment applies augmentation on the dataset
            %
            % The base dataset should be already saved before running augmentation.
            % For details check @c AugmentInternal .
            %
            % 'set1': applies vertical and horizontal flipping.
            % 'set2': applies random rotation.
            %
            % @b Usage
            %
            % @code
            % baseDataset = 'pslData';
            % hsiUtility.PrepareDataset(baseDataset, {'tissue', true});
            %
            % augType = 'set1';
            % augmentedDataset = 'pslDataAug';
            % trainUtility.Augment(baseDataset, augmentedDataset, augType);
            % @endcode
            %
            % @param baseDataset [char] | The base dataset
            % @param targetDataset [char] | The target dataset
            % @param augType [char] | Optional: The augmentation type ('set1' or 'set2'). Default: 'set1'
            %
            AugmentInternal(varargin{:});
        end

        % ======================================================================
        %> @brief ResizeInternal applies resizing on the dataset.
        %>
        %> The base dataset should be already saved with @c hsiUtility.PrepareDataset before running ResizeInternal.
        %>
        %> If all arguments are not provided, they are fetched from the config file.
        %> Target settings are: config::[HasResizeOptions], config::[ImageDimension] and config::[SplitToPatches].
        %>
        %> For details check @c ResizeInternal .
        %>
        %> @b Usage
        %>
        %> @code
        %> baseDataset = 'pslData';
        %> hsiUtility.PrepareDataset(baseDataset, {'tissue', true});
        %> config.SetSetting('HasResizeOptions', true);
        %> config.SetSetting('ImageDimension', 512);
        %> config.SetSetting('SplitToPatches', false);
        %> resizedDataset = 'psl512';
        %> trainUtility.Resize(baseDataset, resizedDataset);
        %>
        %> resizedDataset = 'psl-patches';
        %> trainUtility.Resize(baseDataset, resizedDataset, true, 32, true);
        %> @endcode
        %>
        %> @param baseDataset [char] | The base dataset
        %> @param targetDataset [char] | The target dataset
        %> @param hasResizeOptions [logical] | Optional: Flag to enable resizing. Default: config:[HasResizeOptions].
        %> @param imageDimension [int] | Optional: The target image size. Default: config:[ImageDimension].
        %> @param splitToPatches [logical] | Optional: Flag to enable split to patches. Default: config:[SplitToPatches].
        % ======================================================================
        function [] = Resize(varargin)
            % ResizeInternal applies resizing on the dataset.
            %
            % The base dataset should be already saved with @c hsiUtility.PrepareDataset before running ResizeInternal.
            %
            % If all arguments are not provided, they are fetched from the config file.
            % Target settings are: config::[HasResizeOptions], config::[ImageDimension] and config::[SplitToPatches].
            %
            % For details check @c ResizeInternal .
            %
            % @b Usage
            %
            % @code
            % baseDataset = 'pslData';
            % hsiUtility.PrepareDataset(baseDataset, {'tissue', true});
            % config.SetSetting('HasResizeOptions', true);
            % config.SetSetting('ImageDimension', 512);
            % config.SetSetting('SplitToPatches', false);
            % resizedDataset = 'psl512';
            % trainUtility.Resize(baseDataset, resizedDataset);
            %
            % resizedDataset = 'psl-patches';
            % trainUtility.Resize(baseDataset, resizedDataset, true, 32, true);
            % @endcode
            %
            % @param baseDataset [char] | The base dataset
            % @param targetDataset [char] | The target dataset
            % @param hasResizeOptions [logical] | Optional: Flag to enable resizing. Default: config:[HasResizeOptions].
            % @param imageDimension [int] | Optional: The target image size. Default: config:[ImageDimension].
            % @param splitToPatches [logical] | Optional: Flag to enable split to patches. Default: config:[SplitToPatches].
            ResizeInternal(varargin{:});
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

            iterLim = 100000;
            % TO REMOVE
            factors = 5;
            kk = ceil(decimate(1:size(Xtrain, 1), factors));
            Xtrain = Xtrain(kk, :);
            ytrain = ytrain(kk, :);
            % TO REMOVE
            
            SVMModel = fitcsvm(Xtrain, ytrain, 'Standardize', true, 'KernelFunction', 'RBF', ...
                'KernelScale', 'auto', 'IterationLimit', iterLim); %'Cost', [0, 1; 3, 0], 'IterationLimit', 10000
            numIter = SVMModel.NumIterations;
            % TO REMOVE
            if numIter == iterLim
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

            preTransMethod = method;
            if strcmpi(method, 'autoencoder') || strcmpi(method, 'rfi')
                preTransMethod = 'none';
            end
            tic;
            transTrain = cellfun(@(x,y, z) x.Transform(true, preTransMethod, q, y, z, varargin{:}), {trainData.Values}, {trainData.ImageLabels}, {trainData.Masks}, 'un', 0);
            tdimred = toc;
            tdimred = tdimred / numel(transTrain);
            transTest = cellfun(@(x,y,z) x.Transform(true, preTransMethod, q, y, z, varargin{:}), {testData.Values}, {testData.ImageLabels}, {testData.Masks}, 'un', 0);

            Xtrainscores = trainUtility.Cell2Mat(transTrain);
            transyTrain = cellfun(@(x, y) GetMaskedPixelsInternal(x, y), {trainData.ImageLabels}, {trainData.Masks}, 'un', 0);
            ytrain = trainUtility.Cell2Mat(transyTrain);

            Xvalidscores = trainUtility.Cell2Mat(transTest);
            Xvalid = transTest;
            transyValid = cellfun(@(x, y) GetMaskedPixelsInternal(x, y), {testData.ImageLabels}, {testData.Masks}, 'un', 0);
            yvalid = trainUtility.Cell2Mat(transyValid);

            switch lower(method)
                case 'pca-all'
                    tic;
                    [coeff, Xtrainscores, ~, ~, ~] = Dimred(Xtrainscores, 'pca', q);
                    tdimred = toc;
                    Xvalidscores = Xvalidscores * coeff;
                    Xvalid = cellfun(@(x) x*coeff, Xvalid, 'un', 0);
                    [predlabels, st, Mdl] = trainUtility.RunSVM(Xtrainscores, ytrain, Xvalidscores);

                case 'rica-all'
                    tic;
                    warning('off', 'all');
                    [coeff, Xtrainscores, ~, ~, ~] = Dimred(Xtrainscores, 'rica', q);
                    warning('on', 'all');
                    tdimred = toc;
                    Xvalidscores = Xvalidscores * coeff;
                    Xvalid = cellfun(@(x) x*coeff, Xvalid, 'un', 0);
                    [predlabels, st, Mdl] = trainUtility.RunSVM(Xtrainscores, ytrain, Xvalidscores);

                case 'autoencoder'
%                     parallel.gpu.enableCUDAForwardCompatibility(true)
% % Warning: The CUDA driver must recompile the GPU libraries because your device is more
% % recent than the libraries. Recompiling can take several minutes. Learn more. 
%                     gpuDevice(1);
                    tic;
                    autoenc = trainAutoencoder(Xtrainscores', q, 'MaxEpochs', 200);
%                         'UseGPU', true );
                    tdimred = toc;
                    [~, Xtrainscores, ~, ~, ~] = Dimred(Xtrainscores, 'autoencoder', q, [], autoenc);
                    [~, Xvalidscores, ~, ~, ~] = Dimred(Xvalidscores, 'autoencoder', q, [], autoenc);
                    Xvalid = cellfun(@(x) trainUtility.ApplyAutoencoder(x,'autoencoder', q, autoenc), Xvalid, 'un', 0);
                    [predlabels, st, Mdl] = trainUtility.RunSVM(Xtrainscores, ytrain, Xvalidscores);

                case 'rfi'
%                     tic; 
%                     wavelengths = hsiUtility.GetWavelengths(311);
%                     t = templateTree('NumVariablesToSample', 'all', ...
%                         'PredictorSelection', 'allsplits', 'Surrogate', 'off', 'Reproducible', true);
%                     RFMdl = fitrensemble(Xtrainscores, double(ytrain), 'Method', 'Bag', 'NumLearningCycles', 200, ...
%                          'NumBins', 50, 'Learners', t, 'NPrint', 50);
%                     yHat = oobPredict(RFMdl);
%                     R2 = corr(RFMdl.Y, yHat)^2;
%                     fprintf('Mdl explains %0.1f of the variability around the mean.\n', R2);
%                     impOOB = oobPermutedPredictorImportance(RFMdl);
%                     tdimred = toc;
%                     fprintf('Dimension Reduction Runtime %.5f \n\n', tdimred);
% 
%                     figure(1);
%                     bar(wavelengths, impOOB);
%                     title('Unbiased Predictor Importance Estimates');
%                     xlabel('Predictor variable');
%                     ylabel('Importance');
%                     plotPath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'),  strcat('rfimportance', num2str(now()))), '');
%                     plots.SavePlot(1, plotPath);
                    plotPath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'), 'rfi'), 'mat');
                    load(plotPath, 'impOOB');
                    tdimred = 19722.50930;

                    [~, Xtrainscores, ~, ~, ~] = Dimred(Xtrainscores, 'rfi', q, [], impOOB);
                    [~, Xvalidscores, ~, ~, ~] = Dimred(Xvalidscores, 'rfi', q, [], impOOB);
                    Xvalid = cellfun(@(x) trainUtility.ApplyAutoencoder(x, 'rfi', q, impOOB), Xvalid, 'un', 0);
                    [predlabels, st, Mdl] = trainUtility.RunSVM(Xtrainscores, ytrain, Xvalidscores);
                    
                case 'msuperpca'
                    [predlabels, st, Mdl, Xtrainscores, Xvalidscores] = trainUtility.StackMultiscale(@trainUtility.SVM, varargin{1}, varargin{2}, 'voting', Xtrainscores, ytrain, Xvalidscores);

                otherwise
                    [predlabels, st, Mdl] = trainUtility.RunSVM(Xtrainscores, ytrain, Xvalidscores);
            end

            [accuracy, sensitivity, specificity] = commonUtility.Evaluations(yvalid, predlabels);
            jac = commonUtility.Jaccard(yvalid, predlabels);
        end
        
        function [funScores] = ApplyAutoencoder(inScores, method, qNum, trainedObj )
            [~, funScores, ~, ~, ~] = Dimred(inScores, method, qNum, [], trainedObj);
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
                numvalidsets, jacCoeff*100, accuracy*100, sensitivity*100, specificity*100, tdimred, tclassifier);
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
        %> Need to set config::[SaveFolder] for image output.
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
            % Need to set config::[SaveFolder] for image output.
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
                jacCoeff*100, accuracy*100, sensitivity*100, specificity*100, tdimred, tclassifier);
            valTest = [jacCoeff, accuracy, sensitivity, specificity, tdimred, tclassifier];

            ytest = cellfun(@(x, y) GetMaskedPixelsInternal(x.Labels, y.FgMask), {testData.Labels}, {testData.Values}, 'un', 0);

            fgMasks = {testData.Masks};
            sRGBs = {testData.RGBs};
            predlabels = cellfun(@(x) trainUtility.Predict(Mdl, x), testscores, 'un', 0);
            origSizes = cellfun(@(x) size(x), fgMasks, 'un', 0);

            for i = 1:numel(sRGBs)
                predMask = hsi.RecoverSpatialDimensions(predlabels{i}, origSizes{i}, fgMasks{i});
                trueMask = hsi.RecoverSpatialDimensions(ytest{i}, origSizes{i}, fgMasks{i});
                jacsim = commonUtility.Jaccard(predMask, trueMask);

                imgFilePath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'),  num2str(i), ...
                    strcat('pred_', method, '_', num2str(q))), 'png');
                figTitle = sprintf('%s', strcat(method, '-', num2str(q), ' (', sprintf('%.2f', jacsim*100), '%)'));
                plots.Overlay(4, imgFilePath, sRGBs{i}, predMask, figTitle);
            end
        end
    end
end