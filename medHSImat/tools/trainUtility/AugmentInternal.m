% ======================================================================
%> @brief AugmentInternal applies augmentation on the dataset
%>
%> The base dataset should be already saved before running augmentation.
%>
%> 'set1': applies vertical and horizontal flipping.
%> 'set2': applies random rotation.
%>
%> @b Usage
%>
%> @code
%> dataset = 'pslData';
%> hsiUtility.PrepareDataset(dataset, {'tissue', true});
%> augType = 'set1';
%> AugmentInternal(dataset, augType);
%> @endcode
%>
%> @param dataset [char] | The dataset
%> @param augType [char] | The augmentation type ('set1' or 'set2')
%>
% ======================================================================
function [] = AugmentInternal(dataset, augType)
% AugmentInternal applies augmentation on the dataset
%
% The base dataset should be already saved before running augmentation.
%
% 'set1': applies vertical and horizontal flipping.
% 'set2': applies random rotation.
%
% @b Usage
%
% @code
% dataset = 'pslData';
% hsiUtility.PrepareDataset(dataset, {'tissue', true});
% augType = 'set1';
% AugmentInternal(dataset, augType);
% @endcode
%
% @param dataset [char] | The dataset
% @param augType [char] | The augmentation type ('set1' or 'set2')
%

config.SetSetting('dataset', dataset);
if nargin < 2
    augType = 'set1';
end
config.SetSetting('augmentation', strcat(dataset, '-', augType));

%% Setup
fprintf('Starting augmentation for dataset: %s ...\n', dataset);

%% Read h5 data
[datanames, targetNames] = commonUtility.DatasetInfo();

if length(datanames) ~= length(targetNames)
    disp('Is the target dataset already augmented? You may want to check it.');
end

seed = 42;
rng(seed); %For reproducibility
for i = 1:length(targetNames)

    %% load HSI from .mat file to verify it is working and to prepare preview images
    targetName = targetNames{i};
    [spectralData, labelImg] = hsiUtility.LoadHSIAndLabel(targetName, 'dataset');

    if ~isempty(labelImg)
        switch augType
            case 'set0' % No augmentation
                folds = 0;
                AugmentAndSave([], spectralData, labelImg, folds, targetName);

            case 'set1' % Vertical and horizontal flip
                folds = 0;
                AugmentAndSave([], spectralData, labelImg, folds, targetName);

                folds = folds + 1;
                transFunc = @(x) flip(x, 1);
                AugmentAndSave(transFunc, spectralData, labelImg, folds, targetName);

                folds = folds + 1;
                transFunc = @(x) flip(x, 2);
                AugmentAndSave(transFunc, spectralData, labelImg, folds, targetName);

                folds = folds + 1;
                transFunc = @(x) flip(flip(x, 2), 1);
                AugmentAndSave(transFunc, spectralData, labelImg, folds, targetName);

            case 'set2' % 360 degree random rotation

                %% PENDING
                for j = 0:1
                    for k = 0:1
                        % use rnd generator
                        img0 = spectralData.Value;
                        img0 = imrotate3(img0, 180, [j, k, 0]);

                        %% rotate labels
                        labelImg = imrotate(img, 180);

                    end
                end
            case 'set3' % Brightness x[0.9,1.1]

        end
    end
end

%% preview of the entire dataset

path1 = strrep(commonUtility.GetFilename('augmentation', ...
    config.GetSetting('snapshotsFolderName')), '.mat', '');
plots.MontageFolderContents(1, path1, '*.jpg', 'Augmented Dataset');
close all;

fprintf('The augmented dataset is saved in folder %s \n', commonUtility.GetFilename('augmentation', '*'));
disp('Finished augmenting.');
end


function [] = AugmentAndSave(transFun, spectralData, labelImg, folds, targetName)

if ~isempty(transFun)
    data = spectralData;
    data.Value = transFun(spectralData.Value);
    data.FgMask = transFun(spectralData.FgMask);
    label = transFun(labelImg);
else
    data = spectralData;
    label = labelImg;
end
filename = commonUtility.GetFilename('augmentation', strcat(targetName, '_', num2str(folds)));
save(filename, 'data', 'label');
filename = commonUtility.GetFilename('augmentation', ...
    fullfile(config.GetSetting('snapshotsFolderName'), strcat(targetName, '_', num2str(folds))), 'jpg');
dispImageRgb = data.GetDisplayRescaledImage('rgb');
imwrite(dispImageRgb, filename, 'jpg');
end