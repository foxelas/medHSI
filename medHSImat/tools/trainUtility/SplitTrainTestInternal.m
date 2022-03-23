% ======================================================================
%> @brief SplitTrainTestInternal splits the dataset to train and test.
%>
%> For data type 'image', the function rearranges pixels as a pixel (observation) by feature 2D array.
%> For more details check @c function SplitTrainTestInternal .
%> The base dataset should be already saved before running augmentation.
%> This function can also handle multiscale transformations.
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
%> @param dataType [char] | The data type, either 'hsi', 'image' or 'pixel'
%> @param hasLabels [boolean] | A flag to return labels
%> @param folds [int] | The number of folds
%> @param transformFun [function handle] | The function handle for the function to be applied
%>
%> @retval X [numeric array or cell array] | The train data
%> @retval y [numeric array or cell array] | The train values
%> @retval Xtest [numeric array or cell array] | The test data
%> @retval ytest [numeric array or cell array] | The test values
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
% This function can also handle multiscale transformations.
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
% @param dataType [char] | The data type, either 'hsi', 'image' or 'pixel'
% @param hasLabels [boolean] | A flag to return labels
% @param folds [int] | The number of folds
% @param transformFun [function handle] | The function handle for the function to be applied
%
% @retval X [numeric array or cell array] | The train data
% @retval y [numeric array or cell array] | The train values
% @retval Xtest [numeric array or cell array] | The test data
% @retval ytest [numeric array or cell array] | The test values
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
[~, targetIDs] = commonUtility.DatasetInfo();

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
for i = 1:length(targetIDs)

    baseTargetName = targetIDs{i};
    targetNames = targetIDs(contains(targetIDs, baseTargetName));

    for j = 1:numel(targetNames)
        targetName = targetNames{j};

        %% load HSI from .mat file
        [I, labelInfo] = hsiUtility.LoadHsiAndLabel(targetName);

        fgMask = I.FgMask;
        if ~isempty(labelInfo) %% TOREMOVE

            if strcmp(dataType, 'image')
                xdata = I.Value;
                if hasLabels
                    ydata = double(labelInfo.Labels);
                else
                    ydata = [];
                end

            elseif strcmp(dataType, 'hsi')
                xdata = I;
                if hasLabels
                    ydata = labelInfo;
                else
                    ydata = [];
                end

            elseif strcmp(dataType, 'pixel')
                if useTransform
                    scores = transformFun(I);
                    xdata = GetMaskedPixelsInternal(scores, fgMask);
                else
                    xdata = I.GetMaskedPixels(fgMask);
                end
                if hasLabels
                    ydata = double(GetMaskedPixelsInternal(labelInfo.Labels, fgMask));
                else
                    ydata = [];
                end

            else
                error('Incorrect data type');
            end

            if isempty(find(contains(testTargets, targetName), 1))
                if strcmp(dataType, 'image') || strcmp(dataType, 'hsi')
                    jj = numel(X) + 1;
                    X{jj} = xdata;
                    y{jj} = ydata;

                elseif iscell(xdata)
                    if ~iscell(X)
                        X = cell(numel(xdata), 1);
                    end
                    X = cellfun(@(x, i) [x; xdata{i}], X, num2cell(1:numel(xdata))', 'un', 0);
                    y = [y; ydata];

                else
                    X = [X; xdata];
                    y = [y; ydata];
                end

            else

                if strcmp(dataType, 'image') || strcmp(dataType, 'hsi')
                    jj = numel(Xtest) + 1;
                    Xtest{jj} = xdata;
                    ytest{jj} = ydata;

                elseif iscell(xdata)
                    if ~iscell(Xtest)
                        Xtest = cell(numel(xdata), 1);
                    end
                    Xtest = cellfun(@(x, i) [x; xdata{i}], Xtest, num2cell(1:numel(xdata))', 'un', 0);
                    ytest = [ytest; ydata];

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

if strcmp(dataType, 'image')
    numData = numel(X);
else
    numData = size(X, 1);
end
if numData >= folds
    cvp = trainUtility.KfoldPartitions(numData, folds);
else
    cvp = [];
end

% %TOREMOVE
% factors = 2;
% kk = floor(decimate(1:size(X,1), factors));
% X = X(kk, :);
% y = y(kk, :);
% numData = size(X,1);
% cvp = trainUtility.KfoldPartitions(numData, folds);

end
