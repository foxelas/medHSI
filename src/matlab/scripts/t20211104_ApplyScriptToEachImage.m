
%% Apply script of each of the data
settingNum = 2;
RunSettings(settingNum);

%% Change to Relevant Script
if settingNum < 3
    Apply.ScriptToEachImage(@ApplySuperpixelAnalysis);
elseif settingNum == 3
    Apply.ScriptToEachImage(@ApplyKmeans, [], [], 5);
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
Plots.MontageFolderContents(1, [], criteria);
criteria = struct('TargetDir', 'subfolders', 'TargetName', target, 'TargetType', 'fix');
Plots.MontageFolderContents(2, [], criteria, strcat(target, ' for fix'));
criteria = struct('TargetDir', 'subfolders', 'TargetName', target, 'TargetType', 'raw');
Plots.MontageFolderContents(3, [], criteria, strcat(target, ' for ex-vivo'));
end

function RunSettings(numVal)
close all;
switch numVal
    case 1

        %% Settings 1
        Config.SetSetting('isTest', false);
        Config.SetSetting('database', 'psl');
        Config.SetSetting('normalization', 'byPixel');
        Config.SetSetting('experiment', 'T20211104-SuperPCA-manual');
    case 2

        %% Settings 2
        Config.SetSetting('isTest', false);
        Config.SetSetting('database', 'psl');
        Config.SetSetting('normalization', 'byPixel');
        Config.SetSetting('experiment', 'T20211104-SuperPCA');
    case 3

        %% Settings 3
        Config.SetSetting('isTest', false);
        Config.SetSetting('database', 'psl');
        Config.SetSetting('normalization', 'byPixel');
        Config.SetSetting('experiment', 'T20211104-Kmeans');
        
    otherwise
end
end