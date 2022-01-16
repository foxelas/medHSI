
%% apply script of each of the data
settingNum = 3;
RunSettings(settingNum);

%% Change to Relevant Script
if settingNum < 3
    apply.ScriptToEachImage(@apply.SuperpixelAnalysis);
elseif settingNum == 3
    apply.ScriptToEachImage(@apply.Kmeans, [], [], 5);
end

close all;

if settingNum < 3
    GetMontagetCollection('eigenvectors');
    GetMontagetCollection('superpixel_mask');
    GetMontagetCollection('pc1');
    GetMontagetCollection('pc2');
    GetMontagetCollection('pc3');

elseif settingNum == 3
    GetMontagetCollection('kmeans-clustering');
    GetMontagetCollection('kmeans-centroids');
end

%%%%%%%%%%%%%%%%%%%%%%%% Additional Functions %%%%%%%%%%%%%%%%%%%%%%%%
function GetMontagetCollection(target)
criteria = struct('TargetDir', 'subfolders', 'TargetName', target);
plots.MontageFolderContents(1, [], criteria);
criteria = struct('TargetDir', 'subfolders', 'TargetName', target, 'TargetType', 'fix');
plots.MontageFolderContents(2, [], criteria, strcat(target, ' for fix'));
criteria = struct('TargetDir', 'subfolders', 'TargetName', target, 'TargetType', 'raw');
plots.MontageFolderContents(3, [], criteria, strcat(target, ' for ex-vivo'));
end

function RunSettings(numVal)
close all;
switch numVal
    case 1

        %% Settings 1
        config.SetSetting('isTest', false);
        config.SetSetting('database', 'psl');
        config.SetSetting('normalization', 'byPixel');
        config.SetSetting('experiment', 'T20211104-SuperPCA-manual');
    case 2

        %% Settings 2
        config.SetSetting('isTest', false);
        config.SetSetting('database', 'psl');
        config.SetSetting('normalization', 'byPixel');
        config.SetSetting('experiment', 'T20211104-SuperPCA');
    case 3

        %% Settings 3
        config.SetSetting('isTest', false);
        config.SetSetting('database', 'psl');
        config.SetSetting('normalization', 'byPixel');
        config.SetSetting('experiment', 'T20211104-Kmeans');

    otherwise
end
end