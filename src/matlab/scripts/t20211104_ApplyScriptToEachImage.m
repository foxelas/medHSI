%% Apply script of each of the data
RunSettings(3);

%% Read h5 data
condition = {'tissue', true};
[~, targetIDs, outRows] = Query(condition);
isUnfixedCol = cell2mat([outRows.IsUnfixed]);
unfixedId = isUnfixedCol == '1';
targetIDs = targetIDs(unfixedId);

for i = 1:length(targetIDs)
    id = targetIDs(i);

    %% load HSI from .mat file
    targetName = num2str(id);
    hsi = ReadStoredHSI(targetName, GetSetting('normalization'));
    
    %% Change to Relevant Script
%     ApplySuperpixelAnalysis
    labels = ApplyKmeans(hsi, targetName, 5);
    
end 

close all;
% GetCollectiveMontage('eigenvector.jpg');
% GetCollectiveMontage('eigenvector.jpg');
% GetCollectiveMontage('superpixel_mask.jpg');
% GetCollectiveMontage('pc1.jpg');
% GetCollectiveMontage('pc2.jpg');
% GetCollectiveMontage('pc3.jpg');

GetCollectiveMontage('kmeans-clustering.jpg');
GetCollectiveMontage('kmeans-centroids.jpg');

function GetCollectiveMontage(target)
    dirBase = fullfile(GetSetting('saveDir'), GetSetting('experiment'));
    dirList = dir(dirBase);
    dirFlags = [dirList.isdir];
    dirList = dirList(dirFlags);
    imgList = cell(numel(dirList)-2, 1);
    for i = 3:numel(dirList)
        imgList{i-2} = imread(fullfile(dirList(i).folder, dirList(i).name, target));
    end 

    fig = figure(1);
    montage(imgList);
    SetSetting('plotName', fullfile(dirBase, target));
    SavePlot(fig);
end 

function RunSettings(numVal)

close all;
switch numVal
    case 1 
        %% Settings 1 
        SetSetting('isTest', false);
        SetSetting('database', 'psl');
        SetSetting('normalization', 'byPixel');
        SetSetting('experiment', 'T20211104-SuperPCA-manual');
    case 2 
        %% Settings 2
        SetSetting('isTest', false);
        SetSetting('database', 'psl');
        SetSetting('normalization', 'byPixel');
        SetSetting('experiment', 'T20211104-SuperPCA');
    case 3 
        %% Settings 3
        SetSetting('isTest', false);
        SetSetting('database', 'psl');
        SetSetting('normalization', 'byPixel');
        SetSetting('experiment', 'T20211104-Kmeans');
    otherwise
end 
end