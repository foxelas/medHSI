%% Apply script of each of the data
settingNum = 3;
RunSettings(settingNum);

%% Change to Relevant Script
if settingNum < 3
    ApplyScriptToEachImage(@ApplySuperpixelAnalysis, []);
elseif settingNum == 3
    ApplyScriptToEachImage(@ApplyKmeans, [], 5);
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
    criteria = struct('TargetDir', 'subfolders', 'TargetName', strcat(target, '.jpg'));
    Plots(1, @MontageFolderContents, [], criteria);
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