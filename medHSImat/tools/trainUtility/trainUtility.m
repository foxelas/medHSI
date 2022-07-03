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
        %>  [trainData, testData, folds] = trainUtility.TrainTest(dataset, 'pixel', 'custom', [], {'150', '132'});
        %>
        %>   [trainData, testData, folds] = trainUtility.TrainTest(dataset, 'pixel', 'kfold', 5, []);
        %>
        %>   transformFun = @Dimred;
        %>   [trainData, testData, folds] = SplitTrainTest(dataset, 'hsi', 'LOOCV-bySample', [], [], transformFun);
        %> @endcode
        %>
        %> @param dataset [char] | The target dataset
        %> @param dataType [char] | The target data type, either 'hsi', 'image' or 'pixel'
        %> @param splitType [char] | The type to split train/test data. Options: ['custom', 'kfold', 'LOOCV-byPatient', 'LOOCV-bySample'].
        %> @param folds [int] | The number of folds.
        %> @param testIds [cell array] | The ids of samples to be used for testing. Required when splitType is 'custom'. Can be empty otherwise.
        %> @param transformFun [function handle] | Optional: The function handle for the function to be applied. Default: None.
        %> @param varargin [cell array] | The arguments necessary for the transformFun.
        %>
        %> @retval trainData [struct] | The train data
        %> @retval testData [struct] | The test data
        %> @retval folds [int] | The number of folds.
        % ======================================================================
        function [trainData, testData] = TrainTest(dataset, dataType, splitType, folds, testIds, varargin)
        % ======================================================================
        %> @brief TrainTest splits the dataset to train, test or prepares a cross validation setting.
        %>
        %> For more details check @c function SplitTrainTest.
        %>
        %> @b Usage
        %>
        %> @code
        %>  [trainData, testData, folds] = trainUtility.TrainTest(dataset, 'pixel', 'custom', [], {'150', '132'});
        %>
        %>   [trainData, testData, folds] = trainUtility.TrainTest(dataset, 'pixel', 'kfold', 5, []);
        %>
        %>   transformFun = @Dimred;
        %>   [trainData, testData, folds] = SplitTrainTest(dataset, 'hsi', 'LOOCV-bySample', [], [], transformFun);
        %> @endcode
        %>
        %> @param dataset [char] | The target dataset
        %> @param dataType [char] | The target data type, either 'hsi', 'image' or 'pixel'
        %> @param splitType [char] | The type to split train/test data. Options: ['custom', 'kfold', 'LOOCV-byPatient', 'LOOCV-bySample'].
        %> @param folds [int] | The number of folds.
        %> @param testIds [cell array] | The ids of samples to be used for testing. Required when splitType is 'custom'. Can be empty otherwise.
        %> @param transformFun [function handle] | Optional: The function handle for the function to be applied. Default: None.
        %> @param varargin [cell array] | The arguments necessary for the transformFun.
        %>
        %> @retval trainData [struct] | The train data
        %> @retval testData [struct] | The test data
        %> @retval folds [int] | The number of folds.
        % ======================================================================

            [trainData, testData] = SplitTrainTest(dataset, dataType, splitType, folds, testIds, varargin{:});
        end

        % ======================================================================
        %> @brief SVM trains an RBF SVM classifier.
        %>
        %> You can alter the settings of the SVM classifier according to your specifications.
        %> Optimization is not used on functions at @c initUtility.FunctionsWithoutSVMOptimization.
        %>
        %> The trained model is saved at  config::[OutputDir]\\config::[Dataset]\\config::['SaveFolder']\\SVMModel.mat
        %> Optimization performance is saved at config::[OutputDir]\\config::[Dataset]\\config::['SaveFolder']\\optimizationStruct.txt
        %> 
        %> @b Usage
        %>
        %> @code
        %> SVMModel = trainUtility.SVM(Xtrain, ytrain);
        %> 
        %> boxConstraint = 2.1;
        %> kernelScale = 4.3;
        %> SVMModel = trainUtility.SVM(Xtrain, ytrain, [boxConstraint, kernelScale]);
        %> @endcode
        %>
        %> @param Xtrain [numeric array] | The train data
        %> @param ytrain [numeric array] | The train labels
        %> @param svmSettings [numeric array] | The settings for the SVM. It is an array of two values, 'BoxConstraint' and 'KernelScale'. If no setting is given, the model is optimized with 'KernelScale' = 'auto'.
        %>
        %> @retval SVMModel [model] | The trained SVM model
        % ======================================================================
        function [SVMModel] = SVM(Xtrain, ytrain, svmSettings)
        % ======================================================================
        %> @brief SVM trains an RBF SVM classifier.
        %>
        %> You can alter the settings of the SVM classifier according to your specifications.
        %> Optimization is not used on functions at @c initUtility.FunctionsWithoutSVMOptimization.
        %>
        %> The trained model is saved at  config::[OutputDir]\\config::[Dataset]\\config::['SaveFolder']\\SVMModel.mat
        %> Optimization performance is saved at config::[OutputDir]\\config::[Dataset]\\config::['SaveFolder']\\optimizationStruct.txt
        %> 
        %> @b Usage
        %>
        %> @code
        %> SVMModel = trainUtility.SVM(Xtrain, ytrain);
        %> 
        %> boxConstraint = 2.1;
        %> kernelScale = 4.3;
        %> SVMModel = trainUtility.SVM(Xtrain, ytrain, [boxConstraint, kernelScale]);
        %> @endcode
        %>
        %> @param Xtrain [numeric array] | The train data
        %> @param ytrain [numeric array] | The train labels
        %> @param svmSettings [numeric array] | The settings for the SVM. It is an array of two values, 'BoxConstraint' and 'KernelScale'. If no setting is given, the model is optimized with 'KernelScale' = 'auto'.
        %>
        %> @retval SVMModel [model] | The trained SVM model
        % ======================================================================

            iterLim = 10000; % unused
            
            % Reduce to speed up performance when input observations are too many.
            hasDecimation = true;
            if hasDecimation
                factors = 10;
                kk = ceil(decimate(1:size(Xtrain, 1), factors));
                Xtrain = Xtrain(kk, :);
                ytrain = ytrain(kk, :);
            end
            
            functionNames = initUtility.FunctionsWithoutSVMOptimization();
            hasOptimization = ~commonUtility.IsChild(functionNames);
            filePath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'), 'SVMModel'), 'mat');

            if hasOptimization
                optim = 'Bayesian'; %'Grid'
                textPath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'), 'optimizationStruct'), 'txt');
                diary(textPath);
                close all;

                if strcmpi(optim, 'Bayesian') %Use Bayesian optimization
                    optimParams = 'auto'; % optimParams = {'BoxConstraint', 'KernelScale', 'Standardize', 'KernelFunction'};
                    optimOptions = struct('AcquisitionFunctionName', 'expected-improvement-plus', 'MaxObjectiveEvaluations', 200);

                    SVMModel = fitcsvm(Xtrain, ytrain, 'IterationLimit', iterLim, ...
                        'Standardize', true, 'KernelFunction', 'rbf', ...
                        'OptimizeHyperparameters', optimParams, 'HyperparameterOptimizationOptions', optimOptions);


                    imgPath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'), 'optimizationObjective'), 'png');
                    plots.SavePlot(1, imgPath);
                    imgPath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'), 'optimizationParams'), 'png');
                    plots.SavePlot(2, imgPath);
                end

                diary off

            else
                if ~isempty(svmSettings)
                    SVMModel = fitcsvm(Xtrain, ytrain, 'Standardize', true, 'KernelFunction', 'rbf', ... %'RBF', 'linear', 'polynomial' |   'OutlierFraction', 0.1, | 'PolynomialOrder', 5
                        'BoxConstraint', svmSettings(1), 'KernelScale', svmSettings(2));
                else
                    SVMModel = fitcsvm(Xtrain, ytrain, 'Standardize', true, 'KernelFunction', 'rbf', ... %'RBF', 'linear', 'polynomial' |   'OutlierFraction', 0.1, | 'PolynomialOrder', 5
                        'KernelScale', 'auto');
                        %'Cost', [0, 1; 3, 0], 'Standardize', true , 'BoxConstraint', 2, 'IterationLimit', iterLim, 'OutlierFraction', 0.05
                end
            end

            save(filePath, 'SVMModel');
        end

        % ======================================================================
        %> @brief RunSVM trains and test an SVM classifier.
        %>
        %> @b Usage
        %>
        %> @code
        %> [predlabels, st, SVMModel] = trainUtility.RunSVM(Xtrain, ytrain, Xvalid, svmSettings);
        %>
        %> boxConstraint = 2.1;
        %> kernelScale = 4.3;
        %> svmSettings = [boxConstraint, kernelScale];
        %> [predlabels, st, SVMModel] = trainUtility.RunSVM(Xtrain, ytrain, Xvalid, svmSettings);
        %> @endcode
        %>
        %> @param Xtrain [numeric array] | The train data
        %> @param ytrain [numeric array] | The train labels
        %> @param Xvalid [numeric array] | The test data
        %> @param svmSettings [numeric array] | The settings for the SVM. It is an array of two values, 'BoxConstraint' and 'KernelScale'. If no setting is given, the model is optimized with 'KernelScale' = 'auto'.
        %>
        %> @retval predlabels [numeric array] | The predicted labels
        %> @retval st [double] | The train run time
        %> @retval SVMModel [model] | The trained SVM model
        % ======================================================================
        function [predlabels, st, SVMModel] = RunSVM(Xtrain, ytrain, Xvalid, svmSettings)
        % ======================================================================
        %> @brief RunSVM trains and test an SVM classifier.
        %>
        %> @b Usage
        %>
        %> @code
        %> [predlabels, st, SVMModel] = trainUtility.RunSVM(Xtrain, ytrain, Xvalid, svmSettings);
        %>
        %> boxConstraint = 2.1;
        %> kernelScale = 4.3;
        %> svmSettings = [boxConstraint, kernelScale];
        %> [predlabels, st, SVMModel] = trainUtility.RunSVM(Xtrain, ytrain, Xvalid, svmSettings);
        %> @endcode
        %>
        %> @param Xtrain [numeric array] | The train data
        %> @param ytrain [numeric array] | The train labels
        %> @param Xvalid [numeric array] | The test data
        %> @param svmSettings [numeric array] | The settings for the SVM. It is an array of two values, 'BoxConstraint' and 'KernelScale'. If no setting is given, the model is optimized with 'KernelScale' = 'auto'.
        %>
        %> @retval predlabels [numeric array] | The predicted labels
        %> @retval st [double] | The train run time
        %> @retval SVMModel [model] | The trained SVM model
        % ======================================================================

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
        %> @param hasPosterior [bool]: Optional: A flag that shows if posterior probabilities are calculated. Default: false.
        %>
        %> @retval predLabels [numeric array] | The predicted labels. If hasPosterior is true, it is a cell array as {predLabels, postProbs}.
        % ======================================================================
        function predLabels = Predict(trainedModel, Xtest, fusionMethod, hasPosterior)
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
        %> @param hasPosterior [bool]: Optional: A flag that shows if posterior probabilities are calculated. Default: false.
        %>
        %> @retval predLabels [numeric array] | The predicted labels. If hasPosterior is true, it is a cell array as {predLabels, postProbs}.
        % ======================================================================

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
        %> @brief DimredAndTrain trains and test an SVM classifier after dimension reduction.
        %>
        %> Observations are processed with the SVM as individual spectrums per pixel.
        %> See @c dimredUtility for more information about additional arguments.
        %>
        %> How to change application scope of the dimension reduction method:
        %> Join '-all' on 'method' string to train dimred on all data.
        %> Otherwise, dimred is trained individually on each sample and according to the requirements of 'method'.
        %>
        %> @b Usage
        %>
        %> @code
        %> boxConstraint = 2.1;
        %> kernelScale = 4.3;
        %> svmSettings = [boxConstraint, kernelScale];
        %> [performanceStruct, trainedModel, Xvalid] = trainUtility.DimredAndTrain(trainData, testData, method, q, svmSettings);
        %>
        %> % Apply dimension reduction with additional settings. 
        %> superpixelNumber = 10;
        %> [performanceStruct, trainedModel, Xvalid] = trainUtility.DimredAndTrain(trainData, testData, 'SuperPCA', q, svmSettings, superpixelNumber);
        %> @endcode
        %>
        %> @param trainData [struct] | The train data
        %> @param testData [struct] | The test data
        %> @param method [char] | The dimension reduction method
        %> @param q [int] | The reduced dimension
        %> @param svmSettings [numeric array] | The settings for the SVM. It is an array of two values, 'BoxConstraint' and 'KernelScale'. If no setting is given, the model is optimized with 'KernelScale' = 'auto'.
        %> @param varargin [cell array] | The arguments necessary for the dimension reduction method
        %>
        %> @retval performanceStruct [struct] | The model's performance
        %> @retval trainedModel [model] | The trained SVM model
        %> @retval Xvalid [numeric array] | The dimension-reduced test data
        % ======================================================================
        function [performanceStruct, trainedModel, XValid] = DimredAndTrain(trainData, testData, method, q, svmSettings, varargin)
        % ======================================================================
        %> @brief DimredAndTrain trains and test an SVM classifier after dimension reduction.
        %>
        %> Observations are processed with the SVM as individual spectrums per pixel.
        %> See @c dimredUtility for more information about additional arguments.
        %>
        %> How to change application scope of the dimension reduction method:
        %> Join '-all' on 'method' string to train dimred on all data.
        %> Otherwise, dimred is trained individually on each sample and according to the requirements of 'method'.
        %>
        %> @b Usage
        %>
        %> @code
        %> boxConstraint = 2.1;
        %> kernelScale = 4.3;
        %> svmSettings = [boxConstraint, kernelScale];
        %> [performanceStruct, trainedModel, Xvalid] = trainUtility.DimredAndTrain(trainData, testData, method, q, svmSettings);
        %>
        %> % Apply dimension reduction with additional settings. 
        %> superpixelNumber = 10;
        %> [performanceStruct, trainedModel, Xvalid] = trainUtility.DimredAndTrain(trainData, testData, 'SuperPCA', q, svmSettings, superpixelNumber);
        %> @endcode
        %>
        %> @param trainData [struct] | The train data
        %> @param testData [struct] | The test data
        %> @param method [char] | The dimension reduction method
        %> @param q [int] | The reduced dimension
        %> @param svmSettings [numeric array] | The settings for the SVM. It is an array of two values, 'BoxConstraint' and 'KernelScale'. If no setting is given, the model is optimized with 'KernelScale' = 'auto'.
        %> @param varargin [cell array] | The arguments necessary for the dimension reduction method
        %>
        %> @retval performanceStruct [struct] | The model's performance
        %> @retval trainedModel [model] | The trained SVM model
        %> @retval Xvalid [numeric array] | The dimension-reduced test data
        % ======================================================================
            [performanceStruct, trainedModel, XValid] = DimredAndTrainInternal(trainData, testData, method, q, svmSettings, varargin{:});
        end

        % ======================================================================
        %> @brief GetMeanAUC returns average AUC values across folds.
        %>
        %> @b Usage
        %>
        %> @code
        %> [meanAucX, meanAucY] = trainUtility.GetMeanAUC(aucX, aucY);
        %> @endcode
        %>
        %> @param aucX [cell array] | The x-axis values of the auc per fold. 
        %> @param aucY [cell array] | The y-axis values of the auc per fold.
        %>
        %> @param meanAucX [cell array] | The average x-axis values for all folds. 
        %> @param meanAucY [cell array] | The average y-axis values for all folds. 
        % ======================================================================
        function [meanAucX, meanAucY] = GetMeanAUC(aucX, aucY)
        % ======================================================================
        %> @brief GetMeanAUC returns average AUC values across folds.
        %>
        %> @b Usage
        %>
        %> @code
        %> [meanAucX, meanAucY] = trainUtility.GetMeanAUC(aucX, aucY);
        %> @endcode
        %>
        %> @param aucX [cell array] | The x-axis values of the auc per fold. 
        %> @param aucY [cell array] | The y-axis values of the auc per fold.
        %>
        %> @param meanAucX [cell array] | The average x-axis values for all folds. 
        %> @param meanAucY [cell array] | The average y-axis values for all folds. 
        % ======================================================================
        
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
        
        % ======================================================================
        %> @brief GetAUC prepares the average AUC values across different folds.
        %>
        %> It can take considerable time and delay calculations.
        %> To disable, set config::[IsTest] to true.
        %>
        %> @b Usage
        %>
        %> @code
        %> [meanAucX, meanAucY, meanAucVal] = trainUtility.GetAUC(trainedModels, yTrain, XTest));
        %> @endcode
        %>
        %> @param trainedModels [cell array] | The stacked models. If only one model is used, then it has length 1.
        %> @param yTrain [numeric array] | The train labels.
        %> @param XTest [numeric array] | The train data.
        %>
        %> @param meanAucX [numeric array] | The average x-axis values for all folds. 
        %> @param meanAucY [numeric array] | The average y-axis values for all folds. 
        %> @param meanAucVal [double] | The average AUC value for all folds. 
        % ======================================================================
        function [meanAucX, meanAucY, meanAucVal] = GetAUC(trainedModels, yTrain, XTest)
        % ======================================================================
        %> @brief GetAUC prepares the average AUC values across different folds.
        %>
        %> It can take considerable time and delay calculations.
        %> To disable, set config::[IsTest] to true.
        %>
        %> @b Usage
        %>
        %> @code
        %> [meanAucX, meanAucY, meanAucVal] = trainUtility.GetAUC(trainedModels, yTrain, XTest));
        %> @endcode
        %>
        %> @param trainedModels [cell array] | The stacked models. If only one model is used, then it has length 1.
        %> @param yTrain [numeric array] | The train labels.
        %> @param XTest [numeric array] | The train data.
        %>
        %> @param meanAucX [numeric array] | The average x-axis values for all folds. 
        %> @param meanAucY [numeric array] | The average y-axis values for all folds. 
        %> @param meanAucVal [double] | The average AUC value for all folds. 
        % ======================================================================
        
            isTesting = config.GetSetting('IsTest') || commonUtility.IsChild({'RunKfoldValidation'}) || isempty(trainedModels);

            if nargin < 3
                XTest = [];
            end
            
            if isempty(trainedModels) && ~isempty(XTest)
                [aucX{1}, aucY{1}, ~, aucVal(1)] = perfcurve(yTrain, XTest, 1);
                [meanAucX, meanAucY] = trainUtility.GetMeanAUC(aucX, aucY);
                meanAucVal = mean(aucVal);
                
            elseif ~isTesting
                hasDecimation = true;
                if hasDecimation
                    factors = 10;
                    kk = ceil(decimate(1:size(yTrain, 1), factors));
                    ytrainDecim = yTrain(kk, :);
                end
            
                modN = numel(trainedModels);
                aucX = cell(modN, 1);
                aucY = cell(modN, 1);
                aucVal = zeros(modN, 1);
                for i = 1:modN
                    singleModel = fitPosterior(trainedModels{i});
                    [~, score_svm] = resubPredict(singleModel);
                    [aucX{i}, aucY{i}, ~, aucVal(i)] = perfcurve(ytrainDecim, score_svm(:, trainedModels{i}.ClassNames), 1);
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
        %> @brief Evaluation prepares a performance structure with various information.
        %>
        %> The returned values are: 
        %> -'Name'
        %> -'Features'
        %> -'Accuracy'
        %> -'Sensitivity'
        %> -'Specificity'
        %> -'JaccardCoeff'
        %> -'AUC'
        %> -'AUCX'
        %> -'AUCY'
        %> -'DRTrainTime'
        %> -'ModelTrainTime'
        %> -Mahalanobis'
        %> -'JacDensity' (Currently disabled)
        %>
        %> @b Usage
        %>
        %> @code
        %> performance = trainUtility.Evaluation(modelName, featNum, yPredict, yTest, masksPredict, masksTest, trainedModels, yTrain, XTest);
        %> @endcode
        %>
        %> @param modelName [char] | The name of the model. 
        %> @param featNum [int] | The number of features.
        %> @param yPredict [numeric array] | The predicted labels.
        %> @param yTest [numeric array] | The ground truth labels.
        %> @param masksPredict [numeric array] | The predicted masks. 
        %> @param masksTest [numeric array] | The ground truth masks. 
        %> @param trainedModels [cell array] | The stacked models. If only one model is used, then it has length 1.
        %> @param yTrain [numeric array] | The train labels.
        %> @param XTest [numeric array] | The train feature vectors.
        %>
        %> @param performance [struct] | The performance struct. 
        % ======================================================================
        function [performance] = Evaluation(modelName, featNum, yPredict, yTest, masksPredict, masksTest, trainedModels, yTrain, XTest)
        % ======================================================================
        %> @brief Evaluation prepares a performance structure with various information.
        %>
        %> The returned values are: 
        %> -'Name'
        %> -'Features'
        %> -'Accuracy'
        %> -'Sensitivity'
        %> -'Specificity'
        %> -'JaccardCoeff'
        %> -'AUC'
        %> -'AUCX'
        %> -'AUCY'
        %> -'DRTrainTime'
        %> -'ModelTrainTime'
        %> -Mahalanobis'
        %> -'JacDensity' (Currently disabled)
        %>
        %> @b Usage
        %>
        %> @code
        %> performance = trainUtility.Evaluation(modelName, featNum, yPredict, yTest, masksPredict, masksTest, trainedModels, yTrain, XTest);
        %> @endcode
        %>
        %> @param modelName [char] | The name of the model. 
        %> @param featNum [int] | The number of features.
        %> @param yPredict [numeric array] | The predicted labels.
        %> @param yTest [numeric array] | The ground truth labels.
        %> @param masksPredict [numeric array] | The predicted masks. 
        %> @param masksTest [numeric array] | The ground truth masks. 
        %> @param trainedModels [cell array] | The stacked models. If only one model is used, then it has length 1.
        %> @param yTrain [numeric array] | The train labels.
        %> @param XTest [numeric array] | The train feature vectors.
        %>
        %> @param performance [struct] | The performance struct. 
        % ======================================================================

            if nargin < 9
                XTest = [];
            end

            performance = struct('Name', [], 'Features', [], 'Accuracy', [], 'Sensitivity', [], 'Specificity', [], 'JaccardCoeff', [], 'AUC', [], ...
                'AUCX', [], 'AUCY', [], 'DRTrainTime', [], 'ModelTrainTime', [], 'Mahalanobis', [], 'JacDensity', []);

            %% Results evaluation
            [performance.Accuracy, performance.Sensitivity, performance.Specificity] = commonUtility.Evaluations(yTest, yPredict);

            n = numel(masksPredict);
            jacsim = 0;
            %jacDensity = 0;
            mahalDist = 0;
            for i = 1:n
                predMask = masksPredict{i};
                trueMask = masksTest{i};
                jacsim = jacsim + commonUtility.Jaccard(predMask, trueMask);
                %jacDensity = jacDensity + JacDensity(predMask, trueMask);
                [h, w] = size(trueMask);
                mahalDist = mahalDist + mahal([1]', reshape(predMask, [h * w, 1]));
            end

            performance.JaccardCoeff = jacsim / n;
            %perfStr.JacDensity = jacDensity / n;
            performance.Mahalanobis = mahalDist / n;

            performance.Name = modelName;
            performance.Features = featNum;

            [performance.AUCX, performance.AUCY, performance.AUC] = trainUtility.GetAUC(trainedModels, yTrain, XTest);
        end
        
        % ======================================================================
        %> @brief ModelEvaluation returns the model evaluation results.
        %>
        %> The returned values are: 
        %> -'Name'
        %> -'Features'
        %> -'Accuracy'
        %> -'Sensitivity'
        %> -'Specificity'
        %> -'JaccardCoeff'
        %> -'AUC'
        %> -'AUCX'
        %> -'AUCY'
        %> -'DRTrainTime'
        %> -'ModelTrainTime'
        %> -Mahalanobis'
        %> -'JacDensity' (Currently disabled)
        %>
        %> @b Usage
        %>
        %> @code
        %> [perfStr, trainedModel] = trainUtility.ModelEvaluation(modelName, featNum, yPredict, yTest, yTrain, ...
        %>        trainedModels, drTrainTime, modelTrainTime, testData, XTest);
        %> @endcode
        %>
        %> @param modelName [char] | The name of the model. 
        %> @param featNum [int] | The number of features.
        %> @param yPredict [numeric array] | The predicted labels.
        %> @param yTest [numeric array] | The ground truth labels.
        %> @param yTrain [numeric array] | The train labels.
        %> @param trainedModels [cell array] | The stacked models. If only one model is used, then it has length 1.
        %> @param drTrainTime [double] | The training time for dimension reduction.
        %> @param modelTrainTime [double] | The time for model training.
        %> @param testData [cell array] | The test data.
        %> @param XTestScores [numeric array] | The train feature vectors.
        %>
        %> @retval perfStr [struct] | The performance structure
        %> @retval trainedModel [model] | The trained model
        % ======================================================================
        function [performance, trainedModel] = ModelEvaluation(modelName, featNum, yPredict, yTest, yTrain, ...
                trainedModel, drTrainTime, modelTrainTime, testData, XTestScores)
        % ======================================================================
        %> @brief ModelEvaluation returns the model evaluation results.
        %>
        %> The returned values are: 
        %> -'Name'
        %> -'Features'
        %> -'Accuracy'
        %> -'Sensitivity'
        %> -'Specificity'
        %> -'JaccardCoeff'
        %> -'AUC'
        %> -'AUCX'
        %> -'AUCY'
        %> -'DRTrainTime'
        %> -'ModelTrainTime'
        %> -Mahalanobis'
        %> -'JacDensity' (Currently disabled)
        %>
        %> @b Usage
        %>
        %> @code
        %> [perfStr, trainedModel] = trainUtility.ModelEvaluation(modelName, featNum, yPredict, yTest, yTrain, ...
        %>        trainedModels, drTrainTime, modelTrainTime, testData, XTest);
        %> @endcode
        %>
        %> @param modelName [char] | The name of the model. 
        %> @param featNum [int] | The number of features.
        %> @param yPredict [numeric array] | The predicted labels.
        %> @param yTest [numeric array] | The ground truth labels.
        %> @param yTrain [numeric array] | The train labels.
        %> @param trainedModels [cell array] | The stacked models. If only one model is used, then it has length 1.
        %> @param drTrainTime [double] | The training time for dimension reduction.
        %> @param modelTrainTime [double] | The time for model training.
        %> @param testData [cell array] | The test data.
        %> @param XTestScores [numeric array] | The train feature vectors.
        %>
        %> @retval perfStr [struct] | The performance structure
        %> @retval trainedModel [model] | The trained model
        % ======================================================================

            if ~iscell(trainedModel)
                firstModel = trainedModel;
                clear trainedModel
                trainedModel{1} = firstModel;
            end

            fgMasks = {testData.Masks};
            sRGBs = {testData.RGBs};
            predLabelsCell = cellfun(@(x) trainUtility.Predict(trainedModel, x, 'voting'), XTestScores, 'un', 0);
            origSizes = cellfun(@(x) size(x), fgMasks, 'un', 0);

            masksPredict = cell(numel(sRGBs), 1);
            masksTest = cell(numel(sRGBs), 1);
            for i = 1:numel(sRGBs)
                masksPredict{i} = logical(hsi.RecoverSpatialDimensions(predLabelsCell{i}, origSizes{i}, fgMasks{i}));
                masksTest{i} = testData(i).ImageLabels;
            end

            [performance] = trainUtility.Evaluation(modelName, featNum, yPredict, yTest, masksPredict, masksTest, trainedModel, yTrain);
            performance.DRTrainTime = drTrainTime;
            performance.ModelTrainTime = modelTrainTime;
        end

        % ======================================================================
        %> @brief Validation trains and tests an SVM classifier with cross validation.
        %>
        %> Observations are processed with the SVM as individual spectrums per pixel.
        %> See @c SplitTrainTest for more information about preparing validation folds.
        %> See @c dimredUtility for more information about additional arguments about dimension reduction.
        %>
        %> SVM optimization is disabled. To use optimization, set
        %> svmSettings as empty and check @c initUtility.FunctionsWithoutSVMOptimization.
        %>
        %> @b Usage
        %>
        %> @code
        %> [peformanceStruct] = trainUtility.Validation(dataset, splitType, folds, testIds, method, q, svmSettings, varargin);
        %> @endcode
        %>
        %> @param dataset [char] | The target dataset.
        %> @param splitType [char] | The type to split train/test data. Options: ['custom', 'kfold', 'LOOCV-byPatient', 'LOOCV-bySample'].
        %> @param folds [int] | The number of folds.
        %> @param testIds [cell array] | The ids of samples to be used for testing. Required when splitType is 'custom'. Can be empty otherwise.
        %> @param method [char] | The dimension reduction method
        %> @param q [int] | The reduced dimension.
        %> @param svmSettings [numeric array] | The settings for the SVM. It is an array of two values, 'BoxConstraint' and 'KernelScale'. If no setting is given, the model is optimized with 'KernelScale' = 'auto'.
        %> @param varargin [cell array] | The arguments necessary for the dimension reduction method.
        %>
        %> @retval validatedPerformance [struct] | The model's validated performance.
        % ======================================================================
        function [validatedPerformance] = Validation(dataset, splitType, folds, testIds, method, q, svmSettings, varargin)
        % ======================================================================
        %> @brief Validation trains and tests an SVM classifier with cross validation.
        %>
        %> Observations are processed with the SVM as individual spectrums per pixel.
        %> See @c SplitTrainTest for more information about preparing validation folds.
        %> See @c dimredUtility for more information about additional arguments about dimension reduction.
        %>
        %> SVM optimization is disabled. To use optimization, set
        %> svmSettings as empty and check @c initUtility.FunctionsWithoutSVMOptimization.
        %>
        %> @b Usage
        %>
        %> @code
        %> [peformanceStruct] = trainUtility.Validation(dataset, splitType, folds, testIds, method, q, svmSettings, varargin);
        %> @endcode
        %>
        %> @param dataset [char] | The target dataset.
        %> @param splitType [char] | The type to split train/test data. Options: ['custom', 'kfold', 'LOOCV-byPatient', 'LOOCV-bySample'].
        %> @param folds [int] | The number of folds.
        %> @param testIds [cell array] | The ids of samples to be used for testing. Required when splitType is 'custom'. Can be empty otherwise.
        %> @param method [char] | The dimension reduction method
        %> @param q [int] | The reduced dimension.
        %> @param svmSettings [numeric array] | The settings for the SVM. It is an array of two values, 'BoxConstraint' and 'KernelScale'. If no setting is given, the model is optimized with 'KernelScale' = 'auto'.
        %> @param varargin [cell array] | The arguments necessary for the dimension reduction method.
        %>
        %> @retval validatedPerformance [struct] | The model's validated performance.
        % ======================================================================
        
            dataType = 'pixel';
            [trainData, testData, folds] = trainUtility.TrainTest(dataset, dataType, splitType, folds, testIds);

            if folds == 1 
                error('Cannot run cross-validation on a single fold');
            end
            
            performance = cell(numValidSets, 1);
            for k = 1:folds
                trainDataFold = trainData{k};
                testDataFold = testData{k};
                [performance(k), ~, ~] = trainUtility.DimredAndTrain(trainDataFold, testDataFold, method, q, svmSettings, varargin{:});
            end

            validatedPerformance = struct('Name', performance(1).Name, 'Features', performance(1).Features, ...
                'Accuracy', mean([performance.Accuracy]), 'Sensitivity', mean([performance.Sensitivity]), 'Specificity', mean([performance.Specificity]), ...
                'JaccardCoeff', mean([performance.JaccardCoeff]), 'AUC', 0, 'AUCX', [], 'AUCY', [], ...
                'DRTrainTime', mean([performance.DRTrainTime]), 'ModelTrainTime', mean([performance.ModelTrainTime]), ...
                'AccuracySD', std([performance.Accuracy]), 'SensitivitySD', std([performance.Sensitivity]), 'SpecificitySD', std([performance.Specificity]), ...
                'JaccardCoeffSD', std([performance.JaccardCoeff]), 'AUCSD', 0, ...
                'Mahalanobis', mean([performance.Mahalanobis]), 'MahalanobisSD', std([performance.Mahalanobis]), ...
                'JacDensity', mean([performance.JacDensity]), 'JacDensitySD', std([performance.JacDensity]));

            fprintf('%d-fold validated - Jaccard: %.3f %%, Accuracy: %.3f %%, Sensitivity: %.3f %%, Specificity: %.3f %%, DR Train time: %.5f, SVM Train time: %.5f \n\n', ...
                folds, validatedPerformance.JaccardCoeff*100, validatedPerformance.Accuracy*100, validatedPerformance.Sensitivity*100, ... .
                validatedPerformance.Specificity*100, validatedPerformance.DRTrainTime, validatedPerformance.ModelTrainTime);
        end

        % ======================================================================
        %> @brief ValidateAndTest validates an SVM classifier with cross validation and then tests it.
        %>
        %> Observations are processed with the SVM as individual spectrums per pixel.
        %> See @c SplitTrainTest for more information about preparing validation folds.
        %> See @c dimredUtility for more information about additional arguments about dimension reduction.
        %>
        %> SVM optimization is disabled. To use optimization, set
        %> svmSettings as empty and check @c initUtility.FunctionsWithoutSVMOptimization.
        %>
        %> 5-fold cross validation is used. 
        %> To update the output figures for testing evaluation, see @c EvaluateTestInternal.
        %>
        %> @b Usage
        %>
        %> @code
        %> validatedPerformance, testPerformance] = trainUtility.ValidateAndTest(dataset, testIds, method, q, svmSettings, varargin);
        %> @endcode
        %>
        %> @param dataset [char] | The target dataset.
        %> @param testIds [cell array] | The ids of samples to be used for testing. Required when splitType is 'custom'. Can be empty otherwise.
        %> @param method [char] | The dimension reduction method
        %> @param q [int] | The reduced dimension.
        %> @param svmSettings [numeric array] | The settings for the SVM. It is an array of two values, 'BoxConstraint' and 'KernelScale'. If no setting is given, the model is optimized with 'KernelScale' = 'auto'.
        %> @param varargin [cell array] | The arguments necessary for the dimension reduction method.
        %>
        %> @retval validatedPerformance [struct] | The model's validated performance.
        %> @retval testPerformance [struct] | The model's test performance.
        % ======================================================================
        function [validatedPerformance, testPerformance] = ValidateAndTest(dataset, testIds, method, q, svmSettings, varargin)
        % ======================================================================
        %> @brief ValidateAndTest validates an SVM classifier with cross validation and then tests it.
        %>
        %> Observations are processed with the SVM as individual spectrums per pixel.
        %> See @c SplitTrainTest for more information about preparing validation folds.
        %> See @c dimredUtility for more information about additional arguments about dimension reduction.
        %>
        %> SVM optimization is disabled. To use optimization, set
        %> svmSettings as empty and check @c initUtility.FunctionsWithoutSVMOptimization.
        %>
        %> 5-fold cross validation is used. 
        %> To update the output figures for testing evaluation, see @c EvaluateTestInternal.
        %>
        %> @b Usage
        %>
        %> @code
        %> validatedPerformance, testPerformance] = trainUtility.ValidateAndTest(dataset, testIds, method, q, svmSettings, varargin);
        %> @endcode
        %>
        %> @param dataset [char] | The target dataset.
        %> @param testIds [cell array] | The ids of samples to be used for testing. Required when splitType is 'custom'. Can be empty otherwise.
        %> @param method [char] | The dimension reduction method
        %> @param q [int] | The reduced dimension.
        %> @param svmSettings [numeric array] | The settings for the SVM. It is an array of two values, 'BoxConstraint' and 'KernelScale'. If no setting is given, the model is optimized with 'KernelScale' = 'auto'.
        %> @param varargin [cell array] | The arguments necessary for the dimension reduction method.
        %>
        %> @retval validatedPerformance [struct] | The model's validated performance.
        %> @retval testPerformance [struct] | The model's test performance.
        % ======================================================================
        
            splitType = 'kfold';
            folds = 5;
            [validatedPerformance] = trainUtility.Validation(dataset, splitType, folds, [], method, q, [], varargin{:});

            dataType = 'pixel';
            [trainData, testData, ~] = trainUtility.TrainTest(dataset, dataType, 'custom', [], testIds);
            [testPerformance, trainedModel, XTestScores] = trainUtility.DimredAndTrain(trainData, testData, method, q, svmSettings, varargin{:});
            
            fprintf('Test - Jaccard: %.3f %%, AUC: %.3f, Accuracy: %.3f %%, Sensitivity: %.3f %%, Specificity: %.3f %%, DR Train time: %.5f, SVM Train time: %.5f \n\n', ...
                testPerformance.JaccardCoeff*100, testPerformance.AUC, testPerformance.Accuracy*100, testPerformance.Sensitivity*100, ... .
                testPerformance.Specificity*100, testPerformance.DRTrainTime, testPerformance.ModelTrainTime);
            yTest = cellfun(@(x, y) GetMaskedPixelsInternal(x.Labels, y.FgMask), {testData.Labels}, {testData.Values}, 'un', 0);
            
            trainUtility.EvaluateTest(trainedModel, testData, XTestScores, yTest);
        end

        % ======================================================================
        %> @brief EvaluateTestInternal prepares figures of the predicted segments during testing.
        %>
        %> @b Usage
        %>
        %> @code
        %> EvaluateTestInternal(trainedModel, testData, XTestScores, yTest);
        %>
        %> trainUtility.EvaluateTestInternal(trainedModel, testData, XTestScores, yTest);
        %> @endcode
        %>
        %> @param trainedModel [cell array] | The stacked models. If only one model is used, then it has length 1.
        %> @param testData [cell array] | The test data.
        %> @param XTestScores [numeric array] | The train feature vectors.
        %> @param yTest [numeric array] | The ground truth labels.
        % ======================================================================
        function [] = EvaluateTest(trainedModel, testData, XTestScores, yTest)
        % ======================================================================
        %> @brief EvaluateTestInternal prepares figures of the predicted segments during testing.
        %>
        %> @b Usage
        %>
        %> @code
        %> EvaluateTestInternal(trainedModel, testData, XTestScores, yTest);
        %>
        %> trainUtility.EvaluateTestInternal(trainedModel, testData, XTestScores, yTest);
        %> @endcode
        %>
        %> @param trainedModel [cell array] | The stacked models. If only one model is used, then it has length 1.
        %> @param testData [cell array] | The test data.
        %> @param XTestScores [numeric array] | The train feature vectors.
        %> @param yTest [numeric array] | The ground truth labels.
        % ======================================================================
            EvaluateTestInternal(trainedModel, testData, XTestScores, yTest)
        end
        
    end
end