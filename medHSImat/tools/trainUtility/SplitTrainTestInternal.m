% ======================================================================
%> @brief SplitTrainTestInternal splits the dataset to train and test.
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
%>   [X, y, Xtest, ytest, cvp, sRGBs, fgMasks] = SplitTrainTestInternal(dataset, testTargets, dataType);
%>
%>   hasLabels = true;
%>   transformFun = @Dimred;
%>   folds = 5;
%>   [X, y, Xtest, ytest, cvp, sRGBs, fgMasks] = SplitTrainTestInternal(dataset, testTargets, dataType, hasLabels, folds, transformFun);
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
function [X, y, Xtest, ytest, cvp, sRGBs, fgMasks] = SplitTrainTestInternal(dataset, testTargets, dataType, hasLabels, folds, transformFun)
% SplitTrainTestInternal splits the dataset to train and test.
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
%   [X, y, Xtest, ytest, cvp, sRGBs, fgMasks] = SplitTrainTestInternal(dataset, testTargets, dataType);
%
%   hasLabels = true;
%   transformFun = @Dimred;
%   folds = 5;
%   [X, y, Xtest, ytest, cvp, sRGBs, fgMasks] = SplitTrainTestInternal(dataset, testTargets, dataType, hasLabels, folds, transformFun);
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
hasTest = ~isempty(testTargets);
if nargin < 4
    hasLabels = true;
end
if nargin < 5
    folds = 5;
end

useTransform = ~(nargin < 6);

%% Read h5 data
config.SetSetting('dataset', dataset);
[datanames, targetIDs] = commonUtility.DatasetInfo();

X = [];
y = [];
Xtest = [];
ytest = [];
if hasTest
    sRGBs = cell(length(testTargets), 1);
    fgMasks = cell(length(testTargets), 1);
else
    sRGBs = {};
    fgMasks = {};
end

k = 0;
numData = 0;
for i = 1:length(targetIDs)

    baseTargetName = targetIDs{i};
    targetNames = datanames(contains(datanames, baseTargetName));

    for j = 1:numel(targetNames)
        targetName = targetNames{j};

        %% load HSI from .mat file
        [I, label] = hsiUtility.LoadHSIAndLabel(targetName, 'dataset');

        fgMask = I.FgMask;
        if ~isempty(label) %% TOREMOVE
            numData = numData + 1;

            if strcmp(dataType, 'image')
                xdata = I.Value;
                if hasLabels
                    ydata = label;
                else
                    ydata = [];
                end

            elseif strcmp(dataType, 'pixel')
                if useTransform
                    scores = transformFun(I);
                    Xcol = GetMaskedPixelsInternal(scores, fgMask);
                else
                    Xcol = I.GetMaskedPixels(fgMask);
                end
                xdata = Xcol;
                if hasLabels
                    ydata = GetMaskedPixelsInternal(label, fgMask);
                else
                    ydata = [];
                end

            else
                error('Incorrect data type');
            end

            if isempty(find(contains(testTargets, targetName), 1))
                if strcmp(dataType, 'image')
                    X = {X; xdata};
                    y = {y; ydata};
                else
                    X = [X; xdata];
                    y = [y; ydata];
                end

            else

                if strcmp(dataType, 'image')
                    Xtest = {Xtest; xdata};
                    ytest = {ytest; ydata};
                else
                    Xtest = [Xtest; xdata];
                    ytest = [ytest; ydata];
                end

                %%Recover Test Image
                k = k + 1;
                sRGBs{k} = I.GetDisplayRescaledImage();
                fgMasks{k} = fgMask;
            end
        end

    end
end

if numData >= folds
    cvp = trainUtility.KfoldPartitions(numData, folds);
end

end
