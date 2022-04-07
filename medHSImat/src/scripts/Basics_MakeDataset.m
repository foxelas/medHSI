%======================================================================
%> @brief Basics_MakeDataset prepares the target dataset.
%>
%> You can choose among:
%> -Core: the entire dataset
%> -Augmented: the augmented dataset (based on base dataset)
%> -Raw: the raw dataset
%> -Fix: the fix dataset
%> -512: the resized 512x512 dataset (based on base dataset)
%> -l32: the 32x32 patch dataset (based on base dataset)
%> Currently the base dataset is 'pslRaw'
%>
%> @b Usage
%>
%> @code
%> Basics_MakeDataset('Augmented');
%> %Returns dataset 'pslRawAugmented'
%> @endcode
%>
%> @param targetDataset [char] | Optional: The target dataset. Default: 'Core'.
%======================================================================
function [] = Basics_MakeDataset(targetDataset)
% Basics_MakeDataset prepares the target dataset.
%
% You can choose among:
% -Core: the entire dataset
% -Augmented: the augmented dataset (based on base dataset)
% -Raw: the raw dataset
% -Fix: the fix dataset
% -512: the resized 512x512 dataset (based on base dataset)
% -l32: the 32x32 patch dataset (based on base dataset)
% Currently the base dataset is 'pslRaw'
%
% @b Usage
%
% @code
% Basics_MakeDataset('Augmented');
% %Returns dataset 'pslRawAugmented'
% @endcode
%
% @param targetDataset [char] | Optional: The target dataset. Default: 'Core'.

clc;

if nargin < 1
    targetDataset = 'Core';
end

%%%%%%%%%%%%%%%%%%%%% Prepare Data %%%%%%%%%%%%%%%%%%%%%

config.SetOpt();
config.SetSetting('IsTest', false);
config.SetSetting('Database', 'psl');
config.SetSetting('Dataset', targetDataset);
config.SetSetting('Normalization', 'byPixel');

%% Change accordingly
prefix = config.GetSetting('Database');
baseDataset = 'pslRaw';
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

if strcmpi(targetDataset, 'Augmented')
    targetDataset = strcat(baseDataset, targetDataset);
    trainUtility.Augment(baseDataset, targetDataset, 'set1');
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

hsiUtility.ExportH5Dataset();
end
