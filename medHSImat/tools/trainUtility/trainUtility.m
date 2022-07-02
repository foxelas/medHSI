% ======================================================================
%> @brief trainUtility is a class that handles training of hyperspectral data.
%>
% ======================================================================
classdef trainUtility
    methods (Static)

        %======================================================================
        %> @brief FoldIndexes returns the sample ids for different folds. 
        %>
        %> @b Usage
        %>
        %> @code
        %> foldSampleIds = trainUtility.FoldIndexes(foldType);
        %>
        %> foldSampleIds = GetFolds(foldType);
        %> @endcode
        %>
        %> @param foldType [char] | Optional: The type for selecting sample ids for folds. Options: ['byPatient', 'bySample']. Default: 'bySample'. 
        %======================================================================
        function [foldSampleIds] = FoldIndexes(foldType)
            % FoldIndexes returns the sample ids for different folds. 
            %
            % @b Usage
            %
            % @code
            % foldSampleIds = trainUtility.FoldIndexes(foldType);
            %
            % foldSampleIds = GetFolds(foldType);
            % @endcode
            %
            % @param foldType [char] | Optional: The type for selecting sample ids for folds. Options: ['byPatient', 'bySample']. Default: 'bySample'. 

            foldSampleIds = GetFolds(foldType);
        end
        %======================================================================
        %> @brief TrainTestIndexes returns the indexes for train and test samples in the dataset.
        %>
        %> @b Usage
        %>
        %> @code
        %> baseDataset = 'pslRaw';
        %> testIds =  {'157', '251', '227'};
        %> [trainTargetIDs, testTargetIDs] = trainUtility.TrainTestIndexes(baseDataset, testIds);
        %> @endcode
        %>
        %> @param baseDataset [char] | The dataset
        %> @param testIds [cell array] | The ids of samples to be used for testing
        %>
        %> @retval trainTargetIDs [cell array] | The target IDs for train.
        %> @retval testTargetIDs [cell array] | The target IDs for test. 
        %> @retval trainTargetIndexes [cell array] | The logical indexes for train.
        %> @retval testTargetIndexes [cell array] | The logical indexes for test. 
        %======================================================================
        function [trainTargetIDs, testTargetIDs, trainTargetIndexes, testTargetIndexes] = TrainTestIndexes(baseDataset, testIds)
            % TrainTestIndexes returns the indexes for train and test samples in the dataset.
            %
            % @b Usage
            %
            % @code
            % baseDataset = 'pslRaw';
            % testIds =  {'157', '251', '227'};
            % [trainTargetIDs, testTargetIDs] = trainUtility.TrainTestIndexes(baseDataset, testIds);
            % @endcode
            %
            % @param baseDataset [char] | The dataset
            % @param testIds [cell array] | The ids of samples to be used for testing
            %
            % @retval trainTargetIDs [cell array] | The target IDs for train.
            % @retval testTargetIDs [cell array] | The target IDs for test. 
            % @retval trainTargetIndexes [cell array] | The logical indexes for train.
            % @retval testTargetIndexes [cell array] | The logical indexes for test. 
            
            config.SetSetting('Dataset', baseDataset);
            [~, targetIDs] = commonUtility.DatasetInfo();
            trainTargetIndexes = ~contains(targetIDs, testIds);
            testTargetIndexes = contains(targetIDs, testIds);
            trainTargetIDs = targetIDs(trainTargetIndexes);
            testTargetIDs = targetIDs(testTargetIndexes);
        end
        
        %======================================================================
        %> @brief LOOCVIndexes returns the indexes for train and test samples in the dataset according to leave-one-out cross validation (LOOCV).
        %>
        %> @b Usage
        %>
        %> @code
        %> baseDataset = 'pslRaw32Augmented';
        %> [trainTargetIDs, testTargetIDs, trainTargetIndexes, testTargetIndexes] = trainUtility.LOOCVIndexes(baseDataset);
        %>
        %> [trainTargetIDs, testTargetIDs, trainTargetIndexes, testTargetIndexes] = trainUtility.LOOCVIndexes(baseDataset, true);
        %> @endcode
        %>
        %> @param baseDataset [char] | The dataset
        %> @param isPatientBased [bool] | Optional: A flag for whether LOOCV is performed per patient or not (per sample). Default: false. 
        %>
        %> @retval trainTargetIDs [cell array] | The target IDs for each train fold.
        %> @retval testTargetIDs [cell array] | The target IDs for each test fold. 
        %> @retval trainTargetIndexes [cell array] | The logical indexes for each train fold.
        %> @retval testTargetIndexes [cell array] | The logical indexes for each test fold. 
        %======================================================================
        function [trainTargetIDs, testTargetIDs, trainTargetIndexes, testTargetIndexes] = LOOCVIndexes(baseDataset, isPatientBased)
        % LOOCVIndexes returns the indexes for train and test samples in the dataset according to leave-one-out cross validation (LOOCV).
        %
        % @b Usage
        %
        % @code
        % baseDataset = 'pslRaw32Augmented';
        % [trainTargetIDs, testTargetIDs, trainTargetIndexes, testTargetIndexes] = trainUtility.LOOCVIndexes(baseDataset);
        %
        % [trainTargetIDs, testTargetIDs, trainTargetIndexes, testTargetIndexes] = trainUtility.LOOCVIndexes(baseDataset, true);
        % @endcode
        %
        % @param baseDataset [char] | The dataset
        % @param isPatientBased [bool] | Optional: A flag for whether LOOCV is performed per patient or not (per sample). Default: false. 
        %
        % @retval trainTargetIDs [cell array] | The target IDs for each train fold.
        % @retval testTargetIDs [cell array] | The target IDs for each test fold. 
        % @retval trainTargetIndexes [cell array] | The logical indexes for each train fold.
        % @retval testTargetIndexes [cell array] | The logical indexes for each test fold. 

            if nargin < 2 
                isPatientBased = false;
            end
            
            config.SetSetting('Dataset', baseDataset);
            [~, targetIDs] = commonUtility.DatasetInfo();

            if isPatientBased
                foldSampleIds = trainUtility.FoldIndexes('byPatient');
            else
                foldSampleIds = trainUtility.FoldIndexes('bySample');
            end
            discardedPatches =  initUtility.DiscardedPatches();

            folds = numel(foldSampleIds);
            trainTargetIndexes = cell(folds, 1);
            testTargetIndexes = cell(folds, 1);
            trainTargetIDs = cell(folds, 1);
            testTargetIDs = cell(folds, 1);

            for k = 1:folds
                targetSampleIds = num2str(foldSampleIds{k});
                ids = cell2mat(cellfun(@(x) contains(x, targetSampleIds), targetIDs, 'UniformOutput', false));
                testIds = targetIDs(ids);
                
                if contains(baseDataset, 'Augmented')
                    cleanIds = ~contains(targetIDs, strcat(discardedPatches, '_'));
                else
                    cleanIds = ~contains(strcat(targetIDs, '.'), strcat(discardedPatches, '.'));
                end
                
                trainTargetIndexes{k} = ~contains(targetIDs, testIds) & cleanIds;
                testTargetIndexes{k} = contains(targetIDs, testIds) & cleanIds;

                trainTargetIDs{k} = targetIDs(trainTargetIndexes{k});
                testTargetIDs{k}  = targetIDs(testTargetIndexes{k});
            end

        end
        
        %=====================================================================
        %> @brief ExportTrainTest exports the train and test folds as individual .h5 datasets.
        %>
        %> The result is saved in
        %> config::[OutputDir]\\baseDataset\\config::[DatasetsFolderName]\\hsi_baseDataset_train.h5
        %> and
        %> config::[OutputDir]\\baseDataset\\config::[DatasetsFolderName]\\hsi_baseDataset_test.h5
        %>
        %> @b Usage
        %>
        %> @code
        %> baseDataset = 'pslRaw';
        %> testIds =  {'157', '251', '227'};
        %> trainUtility.ExportTrainTest(baseDataset, testIds);
        %> @endcode
        %>
        %> @param baseDataset [char] | The dataset
        %> @param testIds [cell array] | The ids of samples to be used for testing
        %======================================================================
        function [] = ExportTrainTest(baseDataset, testIds)
        % ExportTrainTest exports the train and test folds as individual .h5 datasets.
        %
        % The result is saved in
        % config::[OutputDir]\\baseDataset\\config::[DatasetsFolderName]\\hsi_baseDataset_train.h5
        % and
        % config::[OutputDir]\\baseDataset\\config::[DatasetsFolderName]\\hsi_baseDataset_test.h5
        %
        % @b Usage
        %
        % @code
        % baseDataset = 'pslRaw';
        % testIds =  {'157', '251', '227'};
        % trainUtility.ExportTrainTest(baseDataset, testIds);
        % @endcode
        %
        % @param baseDataset [char] | The dataset
        % @param testIds [cell array] | The ids of samples to be used for testing

           [trainTargetIDs, testTargetIDs] = trainUtility.TrainTestIndexes(baseDataset, testIds);

            fileName = commonUtility.GetFilename('output', ...
                fullfile(config.GetSetting('DatasetsFolderName'), strcat('hsi_', config.GetSetting('Dataset'), '_train')), 'h5');
            hsiUtility.SaveToH5(trainTargetIDs, fileName);

            fileName = commonUtility.GetFilename('output', ...
                fullfile(config.GetSetting('DatasetsFolderName'), strcat('hsi_', config.GetSetting('Dataset'), '_test')), 'h5');
            hsiUtility.SaveToH5(testTargetIDs, fileName);
        end


        %======================================================================
        %> @brief ExportLOOCV exports data for leave one out cross validation (LOOCV). 
        %>
        %> Data from one sample are saved as one fold in one .h5 dataset.
        %> Please not that some heavily stained patches or otherwise inappropriate patches/samples are discarderd. 
        %>
        %> The result for fold XX is saved in
        %> config::[OutputDir]\\baseDataset\\config::[DatasetsFolderName]\\XX\\hsi_baseDataset_train.h5
        %> and
        %> config::[OutputDir]\\baseDataset\\config::[DatasetsFolderName]\\XX\\hsi_baseDataset_test.h5
        %>
        %> @b Usage
        %>
        %> @code
        %> baseDataset = 'pslRaw32Augmented';
        %> trainUtility.ExportLOOCV(baseDataset);
        %>
        %> %LOOCV per patient
        %> trainUtility.ExportLOOCV(baseDataset, true);
        %> @endcode
        %>
        %> @param baseDataset [char] | The dataset
        %> @param isPatientBased [bool] | Optional: A flag for whether LOOCV is performed per patient or not (per sample). Default: false. 
        %======================================================================
        function [] = ExportLOOCV(baseDataset, isPatientBased)
        % ExportLOOCV exports data for leave one out cross validation (LOOCV). 
        %
        % Data from one sample are saved as one fold in one .h5 dataset.
        % Please not that some heavily stained patches or otherwise inappropriate patches/samples are discarderd. 
        %
        % The result for fold XX is saved in
        % config::[OutputDir]\\baseDataset\\config::[DatasetsFolderName]\\XX\\hsi_baseDataset_train.h5
        % and
        % config::[OutputDir]\\baseDataset\\config::[DatasetsFolderName]\\XX\\hsi_baseDataset_test.h5
        %
        % @b Usage
        %
        % @code
        % baseDataset = 'pslRaw32Augmented';
        % trainUtility.ExportLOOCV(baseDataset);
        %
        % %LOOCV per patient
        % trainUtility.ExportLOOCV(baseDataset, true);
        % @endcode
        %
        % @param baseDataset [char] | The dataset
        % @param isPatientBased [bool] | Optional: A flag for whether LOOCV is performed per patient or not (per sample). Default: false. 

            if nargin < 2 
                isPatientBased = false;
            end

            [trainTargetIDs, testTargetIDs, ~, ~] = trainUtility.LOOCVIndexes(baseDataset, isPatientBased);
            folds = numel(trainTargetIDs);

            for k = 1:folds
                fileName = commonUtility.GetFilename('output', ...
                    fullfile(config.GetSetting('DatasetsFolderName'), num2str(k), strcat('hsi_', config.GetSetting('Dataset'), '_train')), 'h5');
                hsiUtility.SaveToH5(trainTargetIDs{k}, fileName);

                fileName = commonUtility.GetFilename('output', ...
                    fullfile(config.GetSetting('DatasetsFolderName'), num2str(k), strcat('hsi_', config.GetSetting('Dataset'), '_test')), 'h5');
                hsiUtility.SaveToH5(testTargetIDs{k}, fileName);
            end

        end

        % ======================================================================
        %> @brief Augment applies augmentation on the dataset
        %>
        %> The base dataset should be already saved before running augmentation.
        %> For details check @c AugmentInternal.
        %>
        %> 'set1': applies vertical and horizontal flipping (4-fold augmentation).
        %> 'set2': applies random rotation. PENDING
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
            % For details check @c AugmentInternal.
            %
            % 'set1': applies vertical and horizontal flipping (4-fold augmentation).
            % 'set2': applies random rotation. PENDING
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
        %> @brief Format transforms the dataset into images or pixels as preparation for training.
        %>
        %> For data type 'image', the function rearranges pixels as a pixel (observation) by feature 2D array.
        %> For more details check @c function FormatInternal.
        %> This function can also handle multiscale transformations.
        %>
        %> @b Usage
        %>
        %> @code
        %> [hsiList, labelInfoList] = hsiUtility.LoadDataset();
        %> dataType = 'pixel';
        %> [X, y, sRGBs, fgMasks, labelImgs] = trainUtility.Format(hsiList, labelInfoList, dataType);
        %>
        %> transformFun = @Dimred;
        %> [X, y, sRGBs, fgMasks, labelImgs] = FormatInternal(hsiList, labelInfoList, dataType, transformFun);
        %> @endcode
        %>
        %> @param hsiList [cell array] | The list of hsi objects
        %> @param labelInfoList [cell array] | The list of hsiInfo objects
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
        function [X, y, sRGBs, fgMasks, labelImgs] = Format(hsiList, labelInfoList, varargin)
            % Format transforms the dataset into images or pixels as preparation for training.
            %
            % For data type 'image', the function rearranges pixels as a pixel (observation) by feature 2D array.
            % For more details check @c function FormatInternal.
            % This function can also handle multiscale transformations.
            %
            % @b Usage
            %
            % @code
            %   [X, y, sRGBs, fgMasks, labelImgs] = trainUtility.Format(hsiList, labelInfos, dataType);
            %
            %   transformFun = @Dimred;
            %   [X, y, sRGBs, fgMasks, labelImgs] = FormatInternal(hsiList, labelInfos, dataType, transformFun);
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
            [X, y, sRGBs, fgMasks, labelImgs] = FormatInternal(hsiList, labelInfoList, varargin{:});
        end

        % ======================================================================
        %> @brief TrainTest splits the dataset to train, test or prepares a cross validation setting.
        %>
        %> For more details check @c function SplitTrainTest.
        %>
        %> @b Usage
        %>
        %> @code
        %>  [trainData, testData] = trainUtility.TrainTest(dataset, 'pixel', 'custom', [], {'150', '132'});
        %>
        %>   [trainData, testData] = trainUtility.TrainTest(dataset, 'pixel', 'kfold', 5, []);
        %>
        %>   transformFun = @Dimred;
        %>   [trainData, testData] = SplitTrainTest(dataset, 'hsi', 'LOOCV-bySample', [], [], transformFun);
        %> @endcode
        %>
        %> @param dataset [char] | The target dataset
        %> @param dataType [char] | The target data type, either 'hsi', 'image' or 'pixel'
        %> @param splitType [char] | The type to split train/test data. Options: ['custom', 'kfold', 'LOOCV-byPatient', 'LOOCV-bySample'].
        %> @param folds [int] | The number of folds.
        %> @param testIds [cell array] | The ids of samples to be used for testing. Required when splitType is 'custom'. Can be empty otherwise.
        %> @param transformFun [function handle] | Optional: The function handle for the function to be applied. Default: None.
        %>
        %> @retval trainData [struct] | The train data
        %> @retval testData [struct] | The test data
        % ======================================================================
        function [trainData, testData] = TrainTest(dataset, dataType, splitType, folds, testIds, varargin)
        % TrainTest splits the dataset to train, test or prepares a cross validation setting.
        %
        % For more details check @c function SplitTrainTest.
        %
        % @b Usage
        %
        % @code
        %   [trainData, testData] = trainUtility.TrainTest(dataset, 'pixel', 'custom', [], {'150', '132'});
        %
        %   [trainData, testData] = trainUtility.TrainTest(dataset, 'pixel', 'kfold', 5, []);
        %
        %   transformFun = @Dimred;
        %   [trainData, testData] = SplitTrainTest(dataset, 'hsi', 'LOOCV-bySample', [], [], transformFun);
        % @endcode
        %
        % @param dataset [char] | The target dataset
        % @param dataType [char] | The target data type, either 'hsi', 'image' or 'pixel'
        % @param splitType [char] | The type to split train/test data. Options:['custom', 'kfold', 'LOOCV-byPatient', 'LOOCV-bySample'].
        % @param folds [int] | The number of folds.
        % @param testIds [cell array] | The ids of samples to be used for testing. Required when splitType is 'custom'. Can be empty otherwise.
        % @param transformFun [function handle] | Optional: The function handle for the function to be applied. Default: None.
        %
        % @retval trainData [struct] | The train data
        % @retval testData [struct] | The test data
        
            [trainData, testData] = SplitTrainTest(dataset, dataType, splitType, folds, testIds, varargin{:});
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
        function [SVMModel] = SVM(Xtrain, ytrain, svmSettings)
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

            iterLim = 10000;
            % TO REMOVE
            factors = 10;
            kk = ceil(decimate(1:size(Xtrain, 1), factors));
            Xtrain = Xtrain(kk, :);
            ytrain = ytrain(kk, :);
            % TO REMOVE

            hasOptimization = ~commonUtility.IsChild({'RunKfoldValidation', 'ValidateTest2', 'Basics_LOOCV', 'Basics_Test'});
            %             hasOptimization = ~commonUtility.IsChild({'RunKfoldValidation', 'ValidateTest2', 'Basics_Dimred2'});

            filePath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'), 'SVMModel'), 'mat');

            if hasOptimization
                optim = 'Bayesian'; %'Grid'
                textPath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'), 'optimizationStruct'), 'txt');
                diary(textPath);
                close all;

                if strcmpi(optim, 'Bayesian') %Use Bayesian optimization

                    %                 optimParams = {'BoxConstraint', 'KernelScale', 'Standardize', 'KernelFunction'};
                    optimParams = 'auto';
                    optimOptions = struct('AcquisitionFunctionName', 'expected-improvement-plus', 'MaxObjectiveEvaluations', 200);

                    SVMModel = fitcsvm(Xtrain, ytrain, 'IterationLimit', iterLim, ...
                        'Standardize', true, 'KernelFunction', 'rbf', ...
                        'OptimizeHyperparameters', optimParams, 'HyperparameterOptimizationOptions', optimOptions);


                    imgPath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'), 'optimizationObjective'), 'png');
                    plots.SavePlot(1, imgPath);
                    imgPath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'), 'optimizationParams'), 'png');
                    plots.SavePlot(2, imgPath);
                end

                if strcmpi(optim, 'Grid')

                    boxConstraints = linspace(1, 1000, 10);
                    kernelScales = linspace(1, 50, 10);

                    SVMModel = fitcsvm(Xtrain, ytrain, 'IterationLimit', iterLim, ...
                        'Standardize', true, 'KernelFunction', 'rbf', 'KernelScale', 'auto');

                    bestModel = SVMModel;
                    bestPerf = bestModel.ConvergenceInfo.Objective;
                    fprintf('First: BoxC %.5f, KernelScale %.5f\n', bestModel.BoxConstraints(1), bestModel.KernelParameters.Scale);

                    for boxVal = boxConstraints
                        for kernelVal = kernelScales
                            SVMModel = fitcsvm(Xtrain, ytrain, 'IterationLimit', iterLim, ...
                                'Standardize', true, 'KernelFunction', 'rbf', 'BoxConstraint', boxVal, 'KernelScale', kernelVal);
                            perf = SVMModel.ConvergenceInfo.Objective;
                            if (perf < bestPerf)
                                bestModel = SVMModel;
                                bestPerf = bestModel.ConvergenceInfo.Objective;
                                fprintf('Best: BoxC %.5f, KernelScale %.5f\n', bestModel.BoxConstraints(1), bestModel.KernelParameters.Scale);
                            end
                        end
                    end
                    fprintf('\nFinal: BoxC %.5f, KernelScale %.5f\n', bestModel.BoxConstraints(1), bestModel.KernelParameters.Scale);
                    SVMModel = bestModel;
                end
                diary off

            else
                if ~isempty(svmSettings)
                    SVMModel = fitcsvm(Xtrain, ytrain, 'Standardize', true, 'KernelFunction', 'rbf', ... %'RBF', 'linear', 'polynomial' |   'OutlierFraction', 0.1, | 'PolynomialOrder', 5
                        'BoxConstraint', svmSettings(1), 'KernelScale', svmSettings(2));
                else
                    SVMModel = fitcsvm(Xtrain, ytrain, 'Standardize', true, 'KernelFunction', 'rbf', ... %'RBF', 'linear', 'polynomial' |   'OutlierFraction', 0.1, | 'PolynomialOrder', 5
                        'KernelScale', 'auto');
                end

                %, 'OutlierFraction', 0.05);
                %'Cost', [0, 1; 3, 0], 'IterationLimit', 10000 | 'OutlierFraction', 0.05
                %'Standardize', true | 'BoxConstraint', 2, 'IterationLimit', iterLim,
            end

            save(filePath, 'SVMModel');
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
        function [predlabels, st, SVMModel] = RunSVM(Xtrain, ytrain, Xvalid, svmSettings)
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
            SVMModel = trainUtility.SVM(Xtrain, ytrain, svmSettings);
            st = toc;
            predlabels = predict(SVMModel, Xvalid);
        end

        % ======================================================================
        %> @brief StackMultiscale trains a collection of stacked classifiers.
        %>
        %> @b Usage
        %>
        %> @code
        %> [predLabels, st, SVMModels, XtrainTrans, XvalidTrans] = trainUtility.StackMultiscale(@trainUtility.SVM, 'voting', Xtrain, ytrain, Xvalid);
        %> @endcode
        %>
        %> @param classifierFun [function handle] | The classifier function
        %> @param fusionMethod [char] | The fusion method
        %> @param Xtrain [cell array] | The train data
        %> @param ytrain [numeric array] | The train labels
        %> @param Xvalid [cell array] | The test data
        %>
        %> @retval predLabels [numeric array] | The predicted labels
        %> @retval st [double] | The train run time
        %> @retval models [model] | The trained stacked models
        %> @retval XtrainTrans [numeric array] | The transformed train data
        %> @retval XvalidTrans [numeric array] | The transformed test data
        % ======================================================================
        function [predLabels, st, models, XtrainTrans, XvalidTrans] = StackMultiscale(classifierFun, fusionMethod, Xtrain, ytrain, Xvalid)
            % StackMultiscale trains a collection of stacked classifiers.
            %
            % @b Usage
            %
            % @code
            % [predLabels, st, SVMModels, XtrainTrans, XvalidTrans] = trainUtility.StackMultiscale(@trainUtility.SVM, 'voting', Xtrain, ytrain, Xvalid);
            % @endcode
            %
            % @param classifierFun [function handle] | The classifier function
            % @param fusionMethod [char] | The fusion method
            % @param Xtrain [cell array] | The train data
            % @param ytrain [numeric array] | The train labels
            % @param Xvalid [cell array] | The test data
            % @param yvalid [numeric array] | The test labels
            %
            % @retval predLabels [numeric array] | The predicted labels
            % @retval st [double] | The train run time
            % @retval models [model] | The trained stacked models
            % @retval XtrainTrans [numeric array] | The transformed train data
            % @retval XvalidTrans [numeric array] | The transformed test data

            st = 0;
            if ~iscell(Xtrain)
                error('Data should be in a cell format');
            end

            numScales = numel(Xtrain);

            models = cell(numScales, 1);
            XtrainTrans = cell(numScales, 1);
            XvalidTrans = cell(numScales, 1);
            for scale = 1:numScales
                XtrainScale = Xtrain{scale};
                XvalidScale = Xvalid{scale};

                tic;
                trainedModel = classifierFun(XtrainScale, ytrain);
                tclassifiertemp = toc;
                st = st + tclassifiertemp;

                models{scale} = trainedModel;
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
        %> predLabels = trainUtility.Predict(trainedModel, Xtest);
        %>
        %> predLabels = trainUtility.Predict(trainedModel, Xtest, 'voting');
        %> @endcode
        %>
        %> @retval trainedModel [model] | The trained model
        %> @param Xtest [numeric array] | The test data
        %> @param fusionMethod [char] | Optional: The fusion method. Default: 'voting'.
        %>
        %> @retval predLabels [numeric array] | The predicted labels
        % ======================================================================
        function predLabels = Predict(trainedModel, Xtest, fusionMethod, hasPosterior)
            % Predict returns the predicted labels from the model.
            %
            % @b Usage
            %
            % @code
            % predLabels = trainUtility.Predict(trainedModel, Xtest);
            %
            % predLabels = trainUtility.Predict(trainedModel, Xtest, 'voting');
            % @endcode
            %
            % @retval trainedModel [model] | The trained model
            % @param Xtest [numeric array] | The test data
            % @param fusionMethod [char] | Optional: The fusion method. Default: 'voting'.
            %
            % @retval predLabels [numeric array] | The predicted labels

            if nargin < 3
                fusionMethod = 'voting';
            end

            if nargin < 4
                hasPosterior = false;
            end

            if iscell(trainedModel) && numel(trainedModel) == 1
                trainedModel = trainedModel{1};
            end

            if iscell(trainedModel)
                models = trainedModel;
                numModels = numel(models);
                preds = zeros(size(Xtest{1}, 1), numModels);
                postProbs = zeros(size(Xtest{1}, 1), numModels);

                for i = 1:numModels
                    trainedModel = models{i};
                    scores = Xtest{i};
                    [preds(:, i), postProbs(:, i)] = predict(trainedModel, scores);
                end

                if strcmpi(fusionMethod, 'voting')
                    predLabels = round(sum(preds./size(preds, 2), 2));
                    postProbs = mean(postProbs, 2);

                else
                    error('Not supported fusion method.')
                end

            else
                [predLabels, postProbs] = predict(trainedModel, Xtest);
            end

            if hasPosterior
                predLabels = {predLabels, postProbs};
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

            isStack = iscell(cellArr{1});
            if isStack
                numStack = numel(cellArr{1});
                arr = cell(numStack, 1);
                for i = 1:numStack
                    cellStack = cellfun(@(x) x{i}', cellArr, 'un', 0);
                    stackArr = [cellStack{:}];
                    arr{i} = stackArr';
                end
            else
                cellArr = cellfun(@(x) x', cellArr, 'un', 0);
                arr = [cellArr{:}];
                arr = arr';
            end
        end

        % ======================================================================
        %> @brief DimredAndTrain trains and test an SVM classifier after dimension reduction.
        %>
        %> @b Usage
        %>
        %> @code
        %> [performanceStruct, trainedModel, Xvalid] = trainUtility.DimredAndTrain(trainData, testData, method, q);
        %> @endcode
        %>
        %> @param trainData [struct] | The train data
        %> @param testData [struct] | The test data
        %> @param method [char] | The dimension reduction method
        %> @param q [int] | The reduced dimension
        %> @param varargin | Additional optional arguments
        %>
        %> @retval performanceStruct [struct] | The model's performance
        %> @retval trainedModel [model] | The trained SVM model
        %> @retval Xvalid [numeric array] | The dimension-reduced test data
        % ======================================================================
        function [performanceStruct, trainedModel, XValid] = DimredAndTrain(trainData, testData, method, q, svmSettings, varargin)
            % DimredAndTrain trains and test an SVM classifier after dimension reduction.
            %
            % @b Usage
            %
            % @code
            % [performanceStruct, trainedModel, Xvalid] = trainUtility.DimredAndTrain(trainData, testData, method, q);
            % @endcode
            %
            % @param trainData [struct] | The train data
            % @param testData [struct] | The test data
            % @param method [char] | The dimension reduction method
            % @param q [int] | The reduced dimension
            % @param varargin | Additional optional arguments
            %
            % @retval performanceStruct [struct] | The model's performance
            % @retval trainedModel [model] | The trained SVM model
            % @retval Xvalid [numeric array] | The dimension-reduced test data

            if strcmpi(method, 'lda')
                method = 'LDA-all';
            end

            if strcmpi(method, 'pca-lda')
                method = 'PCA-LDA-all';
            end

            preTransMethod = method;
            if strcmpi(method, 'autoencoder') || strcmpi(method, 'rfi')
                preTransMethod = method; %'none'
                scope = 'all';
            elseif contains(lower(method), '-all')
                preTransMethod = strrep(method, '-all', '');
                scope = 'all';
            else
                scope = 'perSample';
            end

            if strcmpi(method, 'msuperpca') || strcmpi(method, 'mclusterpca')
                scope = 'stacked';
            end

            if strcmpi(scope, 'perSample')
                tic;
                transTrain = cellfun(@(x, y) x.Transform(true, preTransMethod, q, y, varargin{:}), {trainData.Values}, {trainData.ImageLabels}, 'un', 0);
                drTrainTime = toc;
                drTrainTime = drTrainTime / numel(transTrain);
                XValid = cellfun(@(x, y) x.Transform(true, preTransMethod, q, y, varargin{:}), {testData.Values}, {testData.ImageLabels}, 'un', 0);

                %Convert cell image data to concatenated array data
                XTrainscores = trainUtility.Cell2Mat(transTrain);
                XValidscores = trainUtility.Cell2Mat(XValid);
            end

            if strcmpi(scope, 'all')
                tic;
                dataCell = cellfun(@(x) x.GetMaskedPixels(), {trainData.Values}, 'un', 0);
                dataArray = cell2mat(dataCell');
                dataCell = cellfun(@(x, y) GetMaskedPixelsInternal(y, x), {trainData.Masks}, {trainData.ImageLabels}, 'un', 0);
                dataLabels = cell2mat(dataCell');
                [coeff, XTrainscores, ~, ~, ~] = dimredUtility.Apply(dataArray, preTransMethod, q, [], dataLabels, varargin{:});
                drTrainTime = toc;
                drTrainTime = drTrainTime / numel(trainData);

                dataCell = cellfun(@(x) x.GetMaskedPixels(), {testData.Values}, 'un', 0);
                dataArray = cell2mat(dataCell');
                if ~isempty(coeff) && ~isobject(coeff)

                    XValidscores = dataArray * coeff;
                    XValid = cellfun(@(x) x.Transform(true, 'pretrained', q, [], coeff), {testData.Values}, 'un', 0);

                elseif isobject(coeff)
                    dimredStruct = coeff;
                    XValidscores = dimredUtility.Transform(dataArray, preTransMethod, q, dimredStruct);
                    XValid = cellfun(@(x) x.Transform(true, preTransMethod, q, [], dimredStruct), {testData.Values}, 'un', 0);

                else
                    error('Incomplete arguments. Dimension reduction failed.')
                end

            end

            transyTrain = cellfun(@(x, y) GetMaskedPixelsInternal(x, y), {trainData.ImageLabels}, {trainData.Masks}, 'un', 0);
            yTrain = trainUtility.Cell2Mat(transyTrain);
            transyValid = cellfun(@(x, y) GetMaskedPixelsInternal(x, y), {testData.ImageLabels}, {testData.Masks}, 'un', 0);
            yValid = trainUtility.Cell2Mat(transyValid);

            switch lower(scope)
                case 'stacked'
                    [predLabels, modelTrainTime, trainedModel, ~, ~] = trainUtility.StackMultiscale(@trainUtility.SVM, 'voting', XTrainscores, yTrain, XValidscores);

                otherwise
                    [predLabels, modelTrainTime, trainedModel] = trainUtility.RunSVM(XTrainscores, yTrain, XValidscores, svmSettings);
            end

            [performanceStruct, trainedModel] = trainUtility.ModelEvaluation(method, q, yValid, predLabels, yTrain, trainedModel, ...
                drTrainTime, modelTrainTime, testData, XValid);
        end

        % ======================================================================
        %> @brief GetMeanAUC returns average AUC values.
        %>
        %> @b Usage
        %>
        %> @code
        %> [meanAucX, meanAucY] = trainUtility.GetMeanAUC(aucX, aucY);
        %> @endcode
        %>
        %> @param inScores [numeric array] | The target array
        %> @param method [char] | The dimension reduction method
        %> @param q [int] | The reduced dimension
        %> @param trainedObj [numeric array] | The trained dimension reduction object
        %>
        %> @retval transScores [numeric array] | The transformed scores
        % ======================================================================
        function [meanAucX, meanAucY] = GetMeanAUC(aucX, aucY)
            % GetMeanAUC returns average AUC values.
            %
            % @b Usage
            %
            % @code
            % [meanAucX, meanAucY] = trainUtility.GetMeanAUC(aucX, aucY);
            % @endcode
            %
            % @param inScores [numeric array] | The target array
            % @param method [char] | The dimension reduction method
            % @param q [int] | The reduced dimension
            % @param trainedObj [numeric array] | The trained dimension reduction object
            %
            % @retval transScores [numeric array] | The transformed scores
            n = numel(aucX);
            meanAucX = linspace(0, 1, 100);
            for i = 1:n
                aucXVals = aucX{i};
                aucYVals = aucY{i};
                [aucXVals, idxs, ~] = unique(aucXVals);
                if i == 1
                    meanAucY = (interp1(aucXVals, aucYVals(idxs), meanAucX)) / n;
                else
                    meanAucY = meanAucY + (interp1(aucXVals, aucYVals(idxs), meanAucX)) / n;
                end
            end
        end

        function [perfStr] = Evaluation(modelName, featNum, predLabels, gtLabels, predMasks, trueMasks, stackedModels, trainLabels, scoresVal)

            if nargin < 9
                scoresVal = [];
            end

            perfStr = struct('Name', [], 'Features', [], 'Accuracy', [], 'Sensitivity', [], 'Specificity', [], 'JaccardCoeff', [], 'AUC', [], ...
                'AUCX', [], 'AUCY', [], 'DRTrainTime', [], 'ModelTrainTime', [], 'Mahalanobis', [], 'JacDensity', []);

            %% Results evaluation
            [perfStr.Accuracy, perfStr.Sensitivity, perfStr.Specificity] = commonUtility.Evaluations(gtLabels, predLabels);

            n = numel(predMasks);
            jacsim = 0;
            %jacDensity = 0;
            mahalDist = 0;
            for i = 1:n
                predMask = predMasks{i};
                trueMask = trueMasks{i};
                jacsim = jacsim + commonUtility.Jaccard(predMask, trueMask);
                %jacDensity = jacDensity + MeasureDensity(predMask, trueMask);
                [h, w] = size(trueMask);
                mahalDist = mahalDist + mahal([1]', reshape(predMask, [h * w, 1]));
            end

            perfStr.JaccardCoeff = jacsim / n;
            %perfStr.JacDensity = jacDensity / n;
            perfStr.Mahalanobis = mahalDist / n;

            perfStr.Name = modelName;
            perfStr.Features = featNum;

            [perfStr.AUCX, perfStr.AUCY, perfStr.AUC] = trainUtility.GetAUC(stackedModels, trainLabels, scoresVal);
        end


        function [meanAucX, meanAucY, meanAucVal] = GetAUC(stackedModels, trainLabels, scoresVal)

            isTesting = commonUtility.IsChild({'RunKfoldValidation'}) || isempty(stackedModels);

            if nargin < 3
                scoresVal = [];
            end
            if isempty(stackedModels) && ~isempty(scoresVal)

                [aucX{1}, aucY{1}, ~, aucVal(1)] = perfcurve(trainLabels, scoresVal, 1);

                [meanAucX, meanAucY] = trainUtility.GetMeanAUC(aucX, aucY);
                meanAucVal = mean(aucVal);
            elseif ~isTesting
                % TO REMOVE
                factors = 10;
                kk = ceil(decimate(1:size(trainLabels, 1), factors));
                ytrainDecim = trainLabels(kk, :);
                % TO REMOVE

                modN = numel(stackedModels);
                aucX = cell(modN, 1);
                aucY = cell(modN, 1);
                aucVal = zeros(modN, 1);
                for i = 1:modN
                    singleModel = fitPosterior(stackedModels{i});
                    [~, score_svm] = resubPredict(singleModel);
                    [aucX{i}, aucY{i}, ~, aucVal(i)] = perfcurve(ytrainDecim, score_svm(:, stackedModels{i}.ClassNames), 1);
                end
                [meanAucX, meanAucY] = trainUtility.GetMeanAUC(aucX, aucY);
                meanAucVal = mean(aucVal);

            else
                meanAucX = [];
                meanAucY = [];
                meanAucVal = 0;
            end
        end
        % ======================================================================
        %> @brief ModelEvaluation returns the model evaluation results.
        %>
        %> @b Usage
        %>
        %> @code
        %> [perfStr, trainedModel] = trainUtility.ModelEvaluation(modelName, featNum, gtLabels, predLabels, trainLabels, trainedModel, stackedModels, drTrainTime, modelTrainTime);
        %> @endcode
        %>
        %> @param modelName [char] | The model name
        %> @param featNum [int] | The number of features
        %> @param gtLabels [numeric array] | The ground truth labels
        %> @param predLabels [numeric array] | The predicted labels
        %> @param trainLabels [numeric array] | The training set labels
        %> @param stackedModels [model or cell array] | The models
        %> @param drTrainTime [double] | The training time for dimension reduction
        %> @param modelTrainTime [double] | The time for model training
        %>
        %> @retval perfStr [struct] | The performance structure
        %> @retval trainedModel [model] | The trained model
        % ======================================================================
        function [perfStr, stackedModels] = ModelEvaluation(modelName, featNum, gtLabels, predLabels, trainLabels, ...
                stackedModels, drTrainTime, modelTrainTime, testData, testScores)
            % ModelEvaluation returns the model evaluation results.
            %
            % @b Usage
            %
            % @code
            % [perfStr, trainedModel] = trainUtility.ModelEvaluation(modelName, featNum, gtLabels, predLabels, trainLabels, trainedModel, stackedModels, drTrainTime, modelTrainTime);
            % @endcode
            %
            % @param modelName [char] | The model name
            % @param featNum [int] | The number of features
            % @param gtLabels [numeric array] | The ground truth labels
            % @param predLabels [numeric array] | The predicted labels
            % @param trainLabels [numeric array] | The training set labels
            % @param stackedModels [model or cell array] | The models
            % @param drTrainTime [double] | The training time for dimension reduction
            % @param modelTrainTime [double] | The time for model training
            %
            % @retval perfStr [struct] | The performance structure
            % @retval trainedModel [model] | The trained model

            if ~iscell(stackedModels)
                firstModel = stackedModels;
                clear stackedModels
                stackedModels{1} = firstModel;
            end

            fgMasks = {testData.Masks};
            sRGBs = {testData.RGBs};
            predLabelsCell = cellfun(@(x) trainUtility.Predict(stackedModels, x, 'voting'), testScores, 'un', 0);
            origSizes = cellfun(@(x) size(x), fgMasks, 'un', 0);

            predMasks = cell(numel(sRGBs), 1);
            trueMasks = cell(numel(sRGBs), 1);
            for i = 1:numel(sRGBs)
                predMasks{i} = logical(hsi.RecoverSpatialDimensions(predLabelsCell{i}, origSizes{i}, fgMasks{i}));
                trueMasks{i} = testData(i).ImageLabels;
            end

            [perfStr] = trainUtility.Evaluation(modelName, featNum, predLabels, gtLabels, predMasks, trueMasks, stackedModels, trainLabels);
            perfStr.DRTrainTime = drTrainTime;
            perfStr.ModelTrainTime = modelTrainTime;
        end

        % ======================================================================
        %> @brief RunKfoldValidation trains and tests an classifier with cross validation.
        %>
        %> @b Usage
        %>
        %> @code
        %> [peformanceStruct] = trainUtility.RunKfoldValidation(X, y, cvp, method, q);
        %> @endcode
        %>
        %> @param trainData [struct] | The train data
        %> @param cvp [cell array] | The cross validation index splits
        %> @param method [char] | The dimension reduction method
        %> @param q [int] | The reduced dimension
        %> @param varargin | Additional optional arguments
        %>
        %> @retval peformanceStruct [struct] | The model's performance
        % ======================================================================
        function [peformanceStruct] = RunKfoldValidation(trainData, cvp, method, q, varargin)
            % RunKfoldValidation trains and tests an classifier with cross validation.
            %
            % @b Usage
            %
            % @code
            % [peformanceStruct] = trainUtility.RunKfoldValidation(X, y, cvp, method, q);
            % @endcode
            %
            % @param trainData [struct] | The train data
            % @param cvp [cell array] | The cross validation index splits
            % @param method [char] | The dimension reduction method
            % @param q [int] | The reduced dimension
            % @param varargin | Additional optional arguments
            %
            % @retval peformanceStruct [struct] | The model's performance

            numValidSets = cvp.NumTestSets;
            perfStr = cell(numValidSets, 1);
            for k = 1:numValidSets
                trainDataFold = trainData(cvp.training(k));
                testDataFold = trainData(cvp.test(k));

                [perfStr(k), ~, ~] = trainUtility.DimredAndTrain(trainDataFold, testDataFold, method, q, varargin{:});
            end

            peformanceStruct = struct('Name', perfStr(1).Name, 'Features', perfStr(1).Features, ...
                'Accuracy', mean([perfStr.Accuracy]), 'Sensitivity', mean([perfStr.Sensitivity]), 'Specificity', mean([perfStr.Specificity]), ...
                'JaccardCoeff', mean([perfStr.JaccardCoeff]), 'AUC', 0, 'AUCX', [], 'AUCY', [], ...
                'DRTrainTime', mean([perfStr.DRTrainTime]), 'ModelTrainTime', mean([perfStr.ModelTrainTime]), ...
                'AccuracySD', std([perfStr.Accuracy]), 'SensitivitySD', std([perfStr.Sensitivity]), 'SpecificitySD', std([perfStr.Specificity]), ...
                'JaccardCoeffSD', std([perfStr.JaccardCoeff]), 'AUCSD', 0, ...
                'Mahalanobis', mean([perfStr.Mahalanobis]), 'MahalanobisSD', std([perfStr.Mahalanobis]), ...
                'JacDensity', mean([perfStr.JacDensity]), 'JacDensitySD', std([perfStr.JacDensity]));

            fprintf('%d-fold validated - Jaccard: %.3f %%, Accuracy: %.3f %%, Sensitivity: %.3f %%, Specificity: %.3f %%, DR Train time: %.5f, SVM Train time: %.5f \n\n', ...
                numValidSets, peformanceStruct.JaccardCoeff*100, peformanceStruct.Accuracy*100, peformanceStruct.Sensitivity*100, ... .
                peformanceStruct.Specificity*100, peformanceStruct.DRTrainTime, peformanceStruct.ModelTrainTime);
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
        %> [trainPerformance, testPerformance] = trainUtility.ValidateTest2(trainData, testData, cvp, method, q);
        %>
        %> numScales = numel(pixelNumArray);
        %> [trainPerformance, testPerformance] = trainUtility.ValidateTest2(trainData, testData, cvp, method, q, numScales);
        %> @endcode
        %>
        %> @param trainData [struct] | The train data
        %> @param testData [struct] | The test data
        %> @param cvp [cell array] | The cross validation index splits
        %> @param method [char] | The dimension reduction method
        %> @param q [int] | The reduced dimension
        %> @param varargin | Additional optional arguments
        %>
        %> @retval trainPerformance [numeric array] | The train performance results
        %> @retval testPerformance [numeric array] | The test performance results
        % ======================================================================
        function [trainPerformance, testPerformance] = ValidateTest2(trainData, testData, cvp, method, q, varargin)
            % ValidateTest2 returns the results after cross validation of a classifier.
            %
            % Need to set config::[SaveFolder] for image output.
            %
            % @b Usage
            %
            % @code
            % [trainPerformance, testPerformance] = trainUtility.ValidateTest2(trainData, testData, cvp, method, q);
            %
            % numScales = numel(pixelNumArray);
            % [trainPerformance, testPerformance] = trainUtility.ValidateTest2(trainData, testData, cvp, method, q, numScales);
            % @endcode
            %
            % @param trainData [struct] | The train data
            % @param testData [struct] | The test data
            % @param cvp [cell array] | The cross validation index splits
            % @param method [char] | The dimension reduction method
            % @param q [int] | The reduced dimension
            % @param varargin | Additional optional arguments
            %
            % @retval trainPerformance [numeric array] | The train performance results
            % @retval testPerformance [numeric array] | The test performance results

            [trainPerformance] = trainUtility.RunKfoldValidation(trainData, cvp, method, q, varargin{:});

            [testPerformance, trainedModel, testscores] = trainUtility.DimredAndTrain(trainData, testData, method, q, varargin{:});
            fprintf('Test - Jaccard: %.3f %%, AUC: %.3f, Accuracy: %.3f %%, Sensitivity: %.3f %%, Specificity: %.3f %%, DR Train time: %.5f, SVM Train time: %.5f \n\n', ...
                testPerformance.JaccardCoeff*100, testPerformance.AUC, testPerformance.Accuracy*100, testPerformance.Sensitivity*100, ... .
                testPerformance.Specificity*100, testPerformance.DRTrainTime, testPerformance.ModelTrainTime);
            ytest = cellfun(@(x, y) GetMaskedPixelsInternal(x.Labels, y.FgMask), {testData.Labels}, {testData.Values}, 'un', 0);

            fgMasks = {testData.Masks};
            sRGBs = {testData.RGBs};
            predlabels = cellfun(@(x) trainUtility.Predict(trainedModel, x, 'voting'), testscores, 'un', 0);
            origSizes = cellfun(@(x) size(x), fgMasks, 'un', 0);

            for i = 1:numel(sRGBs)

                %% without post-processing
                predMask = hsi.RecoverSpatialDimensions(predlabels{i}, origSizes{i}, fgMasks{i});
                trueMask = hsi.RecoverSpatialDimensions(ytest{i}, origSizes{i}, fgMasks{i});
                jacsim = commonUtility.Jaccard(predMask, trueMask);

                imgFilePath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'), num2str(i), ...
                    strcat('pred_', method, '_', num2str(q))), 'png');
                figTitle = sprintf('%s', strcat(method, '-', num2str(q), ' (', sprintf('%.2f', jacsim*100), '%)'));
                plots.Overlay(4, imgFilePath, sRGBs{i}, predMask, figTitle);

                %% with post processing
                seClose = strel('disk', 3);
                closeMask = imclose(predMask, seClose);
                seErode = strel('disk', 3);
                postPredMask = imerode(closeMask, seErode);
                jacsim = commonUtility.Jaccard(postPredMask, trueMask);

                imgFilePath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'), strcat(num2str(i), '_post'), ...
                    strcat('pred_', method, '_', num2str(q))), 'png');
                figTitle = sprintf('%s', strcat(method, '-', num2str(q), ' (', sprintf('%.2f', jacsim*100), '%)'));
                plots.Overlay(4, imgFilePath, sRGBs{i}, postPredMask, figTitle);
            end

        end

    end
end