%Date: 2021-12-07
% Remove last two images from Montage Folder Contents
Plots.MontageFolderContents(1, fullfile(Config.GetSetting('outputDir'), Config.GetSetting('labelsApplied'), '\'), [], 'Labels');
criteria = struct('TargetDir', 'subfolders', 'TargetName', 'pc1', 'TargetType', 'fix');

Plots.MontageFolderContents(3, fullfile(Config.GetSetting('outputDir'), Config.GetSetting('labelsManual'), '\'), [], 'LabelsManual');

Plots.MontageFolderContents(2, fullfile(Config.GetSetting('outputDir'), 'T20211104-SuperPCA', '\'), criteria, 'PC1 (fix)');
criteria = struct('TargetDir', 'subfolders', 'TargetName', 'pc2', 'TargetType', 'fix');
Plots.MontageFolderContents(2, fullfile(Config.GetSetting('outputDir'), 'T20211104-SuperPCA', '\'), criteria, 'PC2 (fix)');
criteria = struct('TargetDir', 'subfolders', 'TargetName', 'pc3', 'TargetType', 'fix');
Plots.MontageFolderContents(2, fullfile(Config.GetSetting('outputDir'), 'T20211104-SuperPCA', '\'), criteria, 'PC3 (fix)');


criteria = struct('TargetDir', 'subfolders', 'TargetName', 'kmeans-clustering', 'TargetType', 'fix');
Plots.MontageFolderContents(4, fullfile(Config.GetSetting('outputDir'), 'T20211104-Kmeans', '\'), criteria, 'kmeans-clustering (fix)');

criteria = struct('TargetDir', 'subfolders', 'TargetName', 'kmeans-clustering', 'TargetType', 'fix');
Plots.MontageFolderContents(4, fullfile(Config.GetSetting('outputDir'), 'T20211207-Kmeans', '\'), criteria, 'kmeans-clustering (fix)');
