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
%> baseDataset = 'pslData';
%> hsiUtility.PrepareDataset(baseDataset, {'tissue', true});
%> augType = 'set1';
%> targetDataset = 'pslDataAug';
%> AugmentInternal(baseDataset, targetDataset, augType);
%> @endcode
%>
%> @param baseDataset [char] | The base dataset
%> @param targetDataset [char] | The augmented dataset
%> @param augType [char] | Optional: The augmentation type ('set1' or 'set2'). Default: 'set1'
%>
% ======================================================================
function [] = AugmentInternal(baseDataset, targetDataset, augType)

if nargin < 2
    targetDataset = strcat(baseDataset, 'Augmented');
end

if nargin < 3
    augType = 'set1';
end

%% Setup
fprintf('Starting augmentation for dataset: %s ...\n', baseDataset);

%% Read h5 data
config.SetSetting('Dataset', baseDataset);
[datanames, targetNames] = commonUtility.DatasetInfo(false);

if length(datanames) ~= length(targetNames)
    disp('Is the target dataset already augmented? You may want to check it.');
end

seed = 42;
rng(seed); %For reproducibility
for i = 1:length(targetNames)

    %% load HSI from .mat file to verify it is working and to prepare preview images
    targetName = targetNames{i};
    config.SetSetting('Dataset', baseDataset);
    [spectralData, labelInfo] = hsiUtility.LoadHsiAndLabel(targetName);

    config.SetSetting('Dataset', targetDataset);
    if ~isempty(labelInfo)
        switch augType
            case 'set0' % No augmentation
                folds = 0;
                TransformAndSave([], spectralData, labelInfo, folds, targetName);

            case 'set1' % Vertical and horizontal flip
                folds = 0;
                TransformAndSave([], spectralData, labelInfo, folds, targetName);

                folds = folds + 1;
                transFunc = @(x) flip(x, 1);
                TransformAndSave(transFunc, spectralData, labelInfo, folds, targetName);

                folds = folds + 1;
                transFunc = @(x) flip(x, 2);
                TransformAndSave(transFunc, spectralData, labelInfo, folds, targetName);

                folds = folds + 1;
                transFunc = @(x) flip(flip(x, 2), 1);
                TransformAndSave(transFunc, spectralData, labelInfo, folds, targetName);

            case 'set2' % 360 degree random rotation

                %% PENDING
                for j = 0:1
                    for k = 0:1
                        % use rnd generator
                        img0 = spectralData.Value;
                        img0 = imrotate3(img0, 180, [j, k, 0]);

                        %% rotate labels
                        labelInfo = imrotate(img, 180);

                    end
                end
            case 'set3' % Brightness x[0.9,1.1]

        end
    end
end

%% preview of the entire dataset
outputDir = commonUtility.GetFilename('output', fullfile(config.GetSetting('SnapshotsFolderName'), 'preprocessed'), '');
plots.MontageFolderContents(1, outputDir, '*.png', 'Augmented Dataset');
close all;

fprintf('Finished. The augmented dataset is saved in folder %s \n', commonUtility.GetFilename('Dataset', 'none', ''));
end

% ======================================================================
%> @brief TransformAndSave transforms and saves a sample.
%>
%> @b Usage
%>
%> @code
%> folds = folds + 1;
%> transFunc = @(x) flip(x, 1);
%> TransformAndSave(transFunc, spectralData, labelInfo, folds, targetName);
%> @endcode
%>
%> @param transFunc [function handle] | The transformation function
%> @param spectralData [hsi] | An instance of the hsi class
%> @param labelInfo [hsiInfom] | An instance of the hsiInfo class
%> @param folds [int] | The current augmentation fold
%> @param targetName [str] | The target name
%>
% ======================================================================
function [] = TransformAndSave(transFun, spectralData, labelInfo, folds, targetName)
% TransformAndSave transforms and saves a sample.
%
% @b Usage
%
% @code
% folds = folds + 1;
% transFunc = @(x) flip(x, 1);
% TransformAndSave(transFunc, spectralData, labelInfo, folds, targetName);
% @endcode
%
% @param transFunc [function handle] | The transformation function
% @param spectralData [hsi] | An instance of the hsi class
% @param labelInfo [hsiInfom] | An instance of the hsiInfo class
% @param folds [int] | The current augmentation fold
% @param targetName [str] | The target name

if ~isempty(transFun)
    spectralData.Value = transFun(spectralData.Value);
    spectralData.FgMask = transFun(spectralData.FgMask);
    labelInfo.Labels = transFun(labelInfo.Labels);
end
filename = commonUtility.GetFilename('dataset', strcat(targetName, '_', num2str(folds)));
save(filename, 'spectralData', 'labelInfo', '-v7.3');
fprintf('Saved new data sample at: %s \n', filename);

if (size(spectralData.Value, 3) > 3)
    outputDir = commonUtility.GetFilename('output', fullfile(config.GetSetting('SnapshotsFolderName'), 'preprocessed'), '');
    filename = config.DirMake(outputDir, strcat(targetName, '_', num2str(folds), '.png'));
    dispImageRgb = spectralData.GetDisplayRescaledImage('rgb');
    imwrite(dispImageRgb, filename, 'jpg');
    fprintf('Saved image preview at: %s \n', filename);
end

end