% ======================================================================
%> @brief SplitTrainTest splits the dataset to train, test or prepares a cross validation setting.
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
% @retval folds [int] | The number of folds.
% ======================================================================
function [trainData, testData, folds] = SplitTrainTest(baseDataset, dataType, splitType, folds, testIds, varargin)

config.SetSetting('Dataset', baseDataset);

[hsiList, labelInfoList] = hsiUtility.LoadDataset();

if strcmpi(splitType, 'custom')
    [~, ~, trainTargetIndexes, testTargetIndexes] = trainUtility.TrainTestIndexes(baseDataset, testIds);
    folds = 1;

elseif strcmpi(splitType, 'kfold')
    rng('default') % For reproducibility
    cvp = cvpartition(numel(hsiList), 'kfold', folds);
    trainTargetIndexes = {};
    testTargetIndexes = {};
    for k = 1:folds
        trainTargetIndexes{k} = training(cvp, k);
        testTargetIndexes{k} = test(cvp, k);
    end

elseif strcmpi(splitType, 'LOOCV-byPatient')
    [~, ~, trainTargetIndexes, testTargetIndexes] = trainUtility.LOOCVIndexes(baseDataset, true);
    folds = numel(trainTargetIndexes);

elseif strcmpi(splitType, 'LOOCV-bySample')
    [~, ~, trainTargetIndexes, testTargetIndexes] = trainUtility.LOOCVIndexes(baseDataset, false);
    folds = numel(trainTargetIndexes);
end


for k = 1:folds
    if folds > 1
        trainIds = trainTargetIndexes{k};
        testIds = testTargetIndexes{k};
    else
        trainIds = trainTargetIndexes;
        testIds = testTargetIndexes;
    end

    hsiX = hsiList(trainIds);
    labelsX = labelInfoList(trainIds);
    [train_X, train_y, train_sRGBs, train_fgMasks, train_labelImgs] = trainUtility.Format(hsiX, labelsX, dataType, varargin{:});
    foldTrainData = struct('Values', train_X, 'Labels', train_y, 'RGBs', train_sRGBs, 'Masks', train_fgMasks, 'ImageLabels', train_labelImgs);

    hsiX = hsiList(testIds);
    labelsX = labelInfoList(testIds);
    [test_X, test_y, test_sRGBs, test_fgMasks, test_labelImgs] = trainUtility.Format(hsiX, labelsX, dataType, varargin{:});
    foldTestData = struct('Values', test_X, 'Labels', test_y, 'RGBs', test_sRGBs, 'Masks', test_fgMasks, 'ImageLabels', test_labelImgs);

    if folds > 1
        trainData{k} = foldTrainData;
        testData{k} = foldTestData;
    else
        trainData = foldTrainData;
        testData = foldTestData;
    end
end

end