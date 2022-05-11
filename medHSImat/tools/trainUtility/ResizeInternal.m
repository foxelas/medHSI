% ======================================================================
%> @brief ResizeInternal applies resizing on the dataset.
%>
%> The base dataset should be already saved with @c hsiUtility.PrepareDataset before running ResizeInternal.
%>
%> If all arguments are not provided, they are fetched from the config file.
%> Target settings are: config::[HasResizeOptions], config::[ImageDimension] and config::[SplitToPatches].
%>
%> When splitting in patches all black patches are ignored.
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
%> ResizeInternal(baseDataset, resizedDataset);
%> @endcode
%>
%> @param baseDataset [char] | The base dataset
%> @param targetDataset [char] | The target dataset
%> @param hasResizeOptions [logical] | Optional: Flag to enable resizing. Default: config:[HasResizeOptions].
%> @param imageDimension [int] | Optional: The target image size. Default: config:[ImageDimension].
%> @param splitToPatches [logical] | Optional: Flag to enable split to patches. Default: config:[SplitToPatches].
% ======================================================================
function ResizeInternal(baseDataset, targetDataset, hasResizeOptions, imageDimension, splitToPatches)
% ResizeInternal applies resizing on the dataset.
%
% The base dataset should be already saved with @c hsiUtility.PrepareDataset before running ResizeInternal.
%
% If all arguments are not provided, they are fetched from the config file.
% Target settings are: config::[HasResizeOptions], config::[ImageDimension] and config::[SplitToPatches].
%
% When splitting in patches all black patches are ignored.
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
% ResizeInternal(baseDataset, resizedDataset);
% @endcode
%
% @param baseDataset [char] | The base dataset
% @param targetDataset [char] | The target dataset
% @param hasResizeOptions [logical] | Optional: Flag to enable resizing. Default: config:[HasResizeOptions].
% @param imageDimension [int] | Optional: The target image size. Default: config:[ImageDimension].
% @param splitToPatches [logical] | Optional: Flag to enable split to patches. Default: config:[SplitToPatches].

if nargin > 2
    config.SetSetting('HasResizeOptions', hasResizeOptions);
end
if nargin > 3
    config.SetSetting('ImageDimension', imageDimension);
end
if nargin > 4
    config.SetSetting('SplitToPatches', splitToPatches);
end

if config.GetSetting('HasResizeOptions')

    %% Setup
    fprintf('Starting to resize dataset: %s ...\n', baseDataset);
    if config.GetSetting('SplitToPatches')
        fprintf('Splitting each image into patches with dimensions %d by %d\n\n', config.GetSetting('ImageDimension'), config.GetSetting('ImageDimension'));
    else
        fprintf('Resizing each image to dimensions %d by %d\n\n', config.GetSetting('ImageDimension'), config.GetSetting('ImageDimension'));
    end

    %% Read h5 data
    config.SetSetting('Dataset', baseDataset);
    [datanames, targetNames] = commonUtility.DatasetInfo(true);

    if length(datanames) ~= length(targetNames)
        disp('Is the target dataset already augmented? You may want to check it.');
    end

    for i = 1:length(targetNames)

        %% load HSI from .mat file to verify it is working and to prepare preview images
        targetName = targetNames{i};
        config.SetSetting('Dataset', baseDataset);
        [spectralDataOrig, labelInfoOrig] = hsiUtility.LoadHsiAndLabel(targetName);

        %% Resize
        [spectralData, labelInfo, patchSubs] = hsiUtility.Resize(spectralDataOrig, labelInfoOrig);

        config.SetSetting('Dataset', targetDataset);
        if ~iscell(spectralData)
            SaveResizedData(spectralData, labelInfo, targetName)
        else
            spectralDatas = spectralData;
            labelInfos = labelInfo;
            k = 0;
            for j = 1:numel(spectralData)
                spectralData = spectralDatas{j};
                if sum(spectralData.FgMask(:)) > 0
                    labelInfo = labelInfos{j};
                    k = k + 1;
                    SaveResizedData(spectralData, labelInfo, targetName, k, patchSubs{j});
                end
            end
        end

    end

    %% preview of the entire dataset
    outputDir = commonUtility.GetFilename('output', fullfile(config.GetSetting('SnapshotsFolderName'), 'preprocessed'), '');
    plots.MontageFolderContents(1, outputDir, '*.png', 'Resized Dataset');
    close all;

    fprintf('Finished. The resized dataset is saved in folder %s \n', commonUtility.GetFilename('Dataset', 'none', ''));
else
    disp('Nothing to do here.');
end
end

function [] = SaveResizedData(spectralData, labelInfo, targetName, n, patchSubs)

if nargin < 4
    n = -1;
end

if nargin < 5
    patchSubs = [];
end

filename = commonUtility.GetFilename('dataset', targetName);
if n > 0
    filename = commonUtility.GetFilename('dataset', strcat(targetName, '_patch', num2str(n)));
end
if ~isempty(patchSubs)
    labelInfo.Comment = patchSubs;
end
save(filename, 'spectralData', 'labelInfo', '-v7.3');
fprintf('Saved new data sample at: %s \n', filename);

outputDir = commonUtility.GetFilename('output', fullfile(config.GetSetting('SnapshotsFolderName'), 'preprocessed'), '');
if n > 0
    filename = config.DirMake(outputDir, strcat(targetName, '_patch', num2str(n), '.png'));
else
    filename = config.DirMake(outputDir, strcat(targetName, '.png'));
end
dispImageRgb = spectralData.GetDisplayRescaledImage('rgb');
imwrite(dispImageRgb, filename, 'jpg');
fprintf('Saved image preview at: %s \n', filename);
end