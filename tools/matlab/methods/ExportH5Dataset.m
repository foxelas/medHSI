function [] = ExportH5Dataset(condition)

%% EXPORTH5DATASET aggregates .mat files per sample to a large h5 dataset
%
%   Usage:
%   ExportH5Dataset({'tissue', true});

%% Setup
disp('Initializing [InitializeDataGroup]...');

normalization = GetSetting('normalization');
if strcmp(normalization, 'raw')
    fileName = DirMake(GetSetting('outputDir'), 'Datasets', strcat('hsi_raw_full', '.h5'));
else
    fileName = DirMake(GetSetting('outputDir'), 'Datasets', strcat('hsi_normalized_full', '.h5'));
end

%% Read h5 data
targetSuffix = 'raw';

[~, targetIDs, outRows] = Query(condition);

for i = 1:length(targetIDs)
    id = targetIDs(i);

    %% load HSI from .mat file
    targetName = num2str(id);
    spectralData = ReadStoredHSI(targetName, normalization);

    curName = strcat('/sample', num2str(id));
    h5create(fileName, curName, size(spectralData));
    h5write(fileName, curName, spectralData);
end

h5disp(fileName);

end