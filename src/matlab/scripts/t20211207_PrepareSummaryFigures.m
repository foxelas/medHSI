%Date: 2021-12-07
% Remove last two images from Montage Folder Contents
Plots(1, @MontageFolderContents, fullfile(GetSetting('outputDir'), GetSetting('labelsApplied'), '\'), [], 'Labels');
criteria = struct('TargetDir', 'subfolders', 'TargetName', 'pc1', 'TargetType', 'fix');

Plots(3, @MontageFolderContents, fullfile(GetSetting('outputDir'), GetSetting('labelsManual'), '\'), [], 'LabelsManual');

Plots(2, @MontageFolderContents, fullfile(GetSetting('outputDir'), 'T20211104-SuperPCA', '\'), criteria, 'PC1 (fix)');
criteria = struct('TargetDir', 'subfolders', 'TargetName', 'pc2', 'TargetType', 'fix');
Plots(2, @MontageFolderContents, fullfile(GetSetting('outputDir'), 'T20211104-SuperPCA', '\'), criteria, 'PC2 (fix)');
criteria = struct('TargetDir', 'subfolders', 'TargetName', 'pc3', 'TargetType', 'fix');
Plots(2, @MontageFolderContents, fullfile(GetSetting('outputDir'), 'T20211104-SuperPCA', '\'), criteria, 'PC3 (fix)');


criteria = struct('TargetDir', 'subfolders', 'TargetName', 'kmeans-clustering', 'TargetType', 'fix');
Plots(4, @MontageFolderContents, fullfile(GetSetting('outputDir'), 'T20211104-Kmeans', '\'), criteria, 'kmeans-clustering (fix)');

criteria = struct('TargetDir', 'subfolders', 'TargetName', 'kmeans-clustering', 'TargetType', 'fix');
Plots(4, @MontageFolderContents, fullfile(GetSetting('outputDir'), 'T20211207-Kmeans', '\'), criteria, 'kmeans-clustering (fix)');
