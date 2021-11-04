function [] = InitializeDataGroup(experiment, condition)
% InitializeDataGroup reads a group of hsi data, prepares .mat files,
% prepared normalized files and returns montage previews of contents
%
%   Usage:
%   InitializeDataGroup('handsOnly',{'hand', false})
%   InitializeDataGroup('sample001-tissue', {'tissue', true});

%% Setup
disp('Initializing [InitializeDataGroup]...');

SetSetting('experiment', experiment);
SetSetting('cropBorders', true);
SetSetting('saveFolder', fullfile(GetSetting('snapshots'), experiment));
isTest = GetSetting('isTest');
saveMatFile = true;

%% Read h5 data
[filenames, targetIDs, outRows] = Query(condition);

% Sort by sampleID 
[outRows,sortId] = sortrows(outRows,{'SampleID', 'IsUnfixed'},{'ascend', 'descend'});
filenames = filenames(sortId);
targetIDs = targetIDs(sortId);

integrationTimes = [outRows.IntegrationTime];
dates = [outRows.CaptureDate];
if isTest;
    configurations = [outRows.Configuration];
end

for i = 1:length(targetIDs)
    id = targetIDs(i);
    target = GetValueFromTable(outRows, 'Target', i);
    content = GetValueFromTable(outRows, 'Content', i);
    SetSetting('integrationTime', integrationTimes(i));
    SetSetting('dataDate', num2str(dates(i)));
    if isTest;
        SetSetting('configuration', configurations{i});
    end
    
    saveName =  StrrepAll(strcat(outRows{i, 'SampleID'}, '_', num2str(((str2double(outRows{i, 'IsUnfixed'})+2\2)-2)*(-1)), '-', filenames{i}));

    %% write HSI in .mat file
    spectralData = ReadHSIData(content, target, experiment);

    %% load HSI from .mat file to verify it is working and to prepare preview images
    targetName = num2str(id);
    spectralData = ReadStoredHSI(targetName);
    dispImage = GetDisplayImage(rescale(spectralData), 'rgb');
    figure(1);
    imshow(dispImage);
    SetSetting('plotName', DirMake(GetSetting('saveDir'), GetSetting('saveFolder'), 'rgb',saveName));
    SavePlot(1);

    %% write normalized HSI in .mat file
    spectralData = NormalizeHSI(targetName, GetSetting('normalization'), saveMatFile);

    %% prepare preview from normalized HSI
    dispImage = GetDisplayImage(rescale(spectralData), 'rgb');
    figure(2);
    imshow(dispImage);
    SetSetting('plotName', DirMake(GetSetting('saveDir'), GetSetting('saveFolder'), 'normalized', saveName));
    SavePlot(2);
end

%% preview of the entire dataset
figure(1);
clf;
path1 = fullfile(GetSetting('saveDir'), GetSetting('saveFolder'), 'normalized');
if exist(fullfile(path1, lower('normalized.jpg')), 'file')
    delete(fullfile(path1, lower('normalized.jpg')));
end
Plots(1, @MontageFolderContents, path1, '*.jpg', 'Normalized');
figure(2);
clf;
path1 = fullfile(GetSetting('saveDir'), GetSetting('saveFolder'), 'rgb');
if exist(fullfile(path1, lower('sRGB.jpg')), 'file')
    delete(fullfile(path1, lower('sRGB.jpg')));
end
Plots(2, @MontageFolderContents, path1, '*.jpg', 'sRGB');

end