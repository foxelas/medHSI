function Basics_Kmeans()    
    experiment = strcat('Kmeans', date());
    config.SetSetting('experiment', experiment);
    config.SetSetting('saveFolder', experiment);
    apply.ToEach(@CustomKmeans, 5);
    GetMontagetCollection('kmeans-clustering');
    GetMontagetCollection('kmeans-centroids');
end

function GetMontagetCollection(target)
    criteria = struct('TargetDir', 'subfolders', 'TargetName', target);
    plots.MontageFolderContents(1, [], criteria);
    criteria = struct('TargetDir', 'subfolders', 'TargetName', target, 'TargetType', 'fix');
    plots.MontageFolderContents(2, [], criteria, strcat(target, ' for fix'));
    criteria = struct('TargetDir', 'subfolders', 'TargetName', target, 'TargetType', 'raw');
    plots.MontageFolderContents(3, [], criteria, strcat(target, ' for ex-vivo'));
end