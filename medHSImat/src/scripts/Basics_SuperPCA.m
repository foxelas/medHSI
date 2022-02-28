function Basics_SuperPCA()    
    experiment = strcat('SuperPCA-Manual', date());
    config.SetSetting('experiment', experiment);
    config.SetSetting('saveFolder', experiment);
    config.SetSetting('showFigures', true);
    
    %% Manual 
    isManual = true;
    pixelNum = 20;
    pcNum = 5;
    
    apply.ToEach(@SuperpixelAnalysis, isManual, pixelNum, pcNum);
    
    GetMontagetCollection('eigenvectors');
    GetMontagetCollection('superpixel_mask');
    GetMontagetCollection('pc1');
    GetMontagetCollection('pc2');
    GetMontagetCollection('pc3');
    
    %% From SuperPCA package 
    experiment = strcat('SuperPCA', date());
    config.SetSetting('experiment', experiment);
    config.SetSetting('saveFolder', experiment);
    
    isManual = false;
    apply.ToEach(@SuperpixelAnalysis, isManual, pixelNum, pcNum);
    
    GetMontagetCollection('eigenvectors');
    GetMontagetCollection('superpixel_mask');
    GetMontagetCollection('pc1');
    GetMontagetCollection('pc2');
    GetMontagetCollection('pc3');
end

function GetMontagetCollection(target)
    criteria = struct('TargetDir', 'subfolders', 'TargetName', target);
    plots.MontageFolderContents(1, [], criteria);
    criteria = struct('TargetDir', 'subfolders', 'TargetName', target, 'TargetType', 'fix');
    plots.MontageFolderContents(2, [], criteria, strcat(target, ' for fix'));
    criteria = struct('TargetDir', 'subfolders', 'TargetName', target, 'TargetType', 'raw');
    plots.MontageFolderContents(3, [], criteria, strcat(target, ' for ex-vivo'));
end