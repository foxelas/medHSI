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
function [trainData, testData, cvp] = SplitDatasetInternal(dataset, folds, testTargets, dataType, varargin)
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

[hsiList, labelInfoList] = hsiUtility.LoadDataset(dataset);
[~, targetNames] = commonUtility.DatasetInfo(false);
% TO REMOVE
targetNames = targetNames(1:end-1);

testIds = cellfun(@(x) find(contains(targetNames, x)), testTargets, 'un', 0);
testIds = cell2mat(testIds);
testIds = testIds(:);

trainIds = true(numel(targetNames), 1);
trainIds(testIds) = false;

hsiX = hsiList(trainIds);
labelsX = labelInfoList(trainIds);
[train_X, train_y, train_sRGBs, train_fgMasks, train_labelImgs] = trainUtility.Preprocess(hsiX, labelsX, dataType, varargin{:});
trainData = struct('Values', train_X, 'Labels', train_y, 'RGBs', train_sRGBs, 'Masks', train_fgMasks, 'ImageLabels', train_labelImgs);

hsiX = hsiList(testIds);
labelsX = labelInfoList(testIds);
[test_X, test_y, test_sRGBs, test_fgMasks, test_labelImgs] = trainUtility.Preprocess(hsiX, labelsX, dataType, varargin{:});
testData = struct('Values', test_X, 'Labels', test_y, 'RGBs', test_sRGBs, 'Masks', test_fgMasks, 'ImageLabels', test_labelImgs);

numData = numel(train_X);

if numData >= folds
    cvp = trainUtility.KfoldPartitions(numData, folds);
else
    cvp = [];
end

filename = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'), 'cvpInfo'));
save(filename, '-v7.3');

end