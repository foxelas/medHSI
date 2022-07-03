%======================================================================
%> @brief MakeDataset prepares the target dataset.
%> 
%> You can choose among:
%> -All: the entire dataset (reads from scratch)
%> -Raw: the raw dataset (reads from scratch)
%> -Fix: the fix dataset (reads from scratch)
%> -Augmented: the augmented dataset (based on base dataset)
%> -512: the resized 512x512 dataset (based on base dataset)
%> -32: the 32x32 patch dataset (based on base dataset)
%> -pca: the pca dataset (based on base dataset)
%>
%> @b Usage
%>
%> @code
%> config.SetSetting('Dataset', 'pslRaw');
%> initUtility.MakeDataset('Augmented');
%> %Returns dataset 'pslRawAugmented'
%>
%> initUtility.MakeDataset('Augmented', 'pslRaw');
%>
%> @endcode
%>
%> @param targetDataset [char] | Optional: The target dataset. Default: 'All'.
%> @param targetDataset [char] | Optional: The base dataset. Default: 'psl'.
%======================================================================
function [] = MakeDatasetInternal(targetDataset, baseDataset)

clc;

if nargin < 1
    targetDataset = 'All';
end

if nargin < 2
    baseDataset = 'psl';
end
%%%%%%%%%%%%%%%%%%%%% Prepare Data %%%%%%%%%%%%%%%%%%%%%

config.SetOpt();
config.SetSetting('IsTest', false);
config.SetSetting('Database', baseDataset);
config.SetSetting('Dataset', targetDataset);
config.SetSetting('Normalization', 'byPixel');

%% Change accordingly

prefix = config.GetSetting('Database');
readForeground = true;

CheckImportData();

%Disable normalization check during data reading
config.SetSetting('DisableNormalizationCheck', true);
%Do no use mask for unispectrum calculation
config.SetSetting('UseCustomMask', false);

if strcmpi(targetDataset, 'Core')
    targetDataset = strcat(prefix, targetDataset);
    dbSelection = {'tissue', true};
    hsiUtility.PrepareDataset(targetDataset, dbSelection);
end

if strcmpi(targetDataset, 'Raw')
    targetDataset = strcat(prefix, targetDataset);
    dbSelection = {'tissue', true};
    targetConditions = {'raw', false};
    hsiUtility.PrepareDataset(targetDataset, dbSelection, readForeground, targetConditions);
end

if strcmpi(targetDataset, 'Fix')
    targetDataset = strcat(prefix, targetDataset);
    dbSelection = {'tissue', true};
    targetConditions = {'fix', false};
    hsiUtility.PrepareDataset(targetDataset, dbSelection, readForeground, targetConditions);
end

if strcmpi(targetDataset, 'Augmented')
    targetDataset = strcat(baseDataset, targetDataset);
    trainUtility.Augment(baseDataset, targetDataset, 'set1');
end

if strcmpi(targetDataset, '512')
    targetDataset = strcat(baseDataset, targetDataset);
    config.SetSetting('HasResizeOptions', true);
    config.SetSetting('ImageDimension', 512);
    config.SetSetting('SplitToPatches', false);
    trainUtility.Resize(baseDataset, targetDataset);
    config.SetSetting('Dataset', targetDataset);
end

if strcmpi(targetDataset, '32')
    targetDataset = strcat(baseDataset, targetDataset);
    config.SetSetting('HasResizeOptions', true);
    config.SetSetting('ImageDimension', 32);
    config.SetSetting('SplitToPatches', true);
    trainUtility.Resize(baseDataset, targetDataset);
    config.SetSetting('Dataset', targetDataset);
end

if strcmpi(targetDataset, 'pca')

    config.SetSetting('Dataset', baseDataset);
    [~, targetNames] = commonUtility.DatasetInfo(false);
    targetDataset = strcat(baseDataset, targetDataset);

    for i = 1:length(targetNames)
        targetName = targetNames{i};
        config.SetSetting('Dataset', baseDataset);
        [hsIm, labelInfo] = hsiUtility.LoadHsiAndLabel(targetName);
        spectralData = hsIm;
        rescaledPCA = hsIm.Transform(false, 'pca', 3);
        [m, n, ~] = size(rescaledPCA);
        for j = 1:3
            colImg = reshape(rescaledPCA(:, :, j), [m * n, 1]);
            rescaledPCA(:, :, j) = reshape(rescale(colImg), [m, n]);
        end
        spectralData.Value = rescaledPCA;
        if size(spectralData.Value, 3) == 3 && ndims(spectralData.Value) == 3
            config.SetSetting('Dataset', targetDataset);
            targetFilename = commonUtility.GetFilename('dataset', targetName);
            save(targetFilename, 'spectralData', 'labelInfo', '-v7.3');
        end
    end
    
end

hsiUtility.ExportH5Dataset();
end
