%Date: 2021-12-07
% Remove last two images from Montage Folder Contents
plots.MontageFolderContents(1, fullfile(config.GetSetting('outputDir'), config.GetSetting('labelsApplied'), '\'), [], 'Labels');
criteria = struct('TargetDir', 'subfolders', 'TargetName', 'pc1', 'TargetType', 'fix');

plots.MontageFolderContents(3, fullfile(config.GetSetting('outputDir'), config.GetSetting('labelsManual'), '\'), [], 'LabelsManual');

plots.MontageFolderContents(2, fullfile(config.GetSetting('outputDir'), 'T20211104-SuperPCA', '\'), criteria, 'PC1 (fix)');
criteria = struct('TargetDir', 'subfolders', 'TargetName', 'pc2', 'TargetType', 'fix');
plots.MontageFolderContents(2, fullfile(config.GetSetting('outputDir'), 'T20211104-SuperPCA', '\'), criteria, 'PC2 (fix)');
criteria = struct('TargetDir', 'subfolders', 'TargetName', 'pc3', 'TargetType', 'fix');
plots.MontageFolderContents(2, fullfile(config.GetSetting('outputDir'), 'T20211104-SuperPCA', '\'), criteria, 'PC3 (fix)');


criteria = struct('TargetDir', 'subfolders', 'TargetName', 'kmeans-clustering', 'TargetType', 'fix');
plots.MontageFolderContents(4, fullfile(config.GetSetting('outputDir'), 'T20211104-Kmeans', '\'), criteria, 'kmeans-clustering (fix)');

criteria = struct('TargetDir', 'subfolders', 'TargetName', 'kmeans-clustering', 'TargetType', 'fix');
plots.MontageFolderContents(4, fullfile(config.GetSetting('outputDir'), 'T20211207-Kmeans', '\'), criteria, 'kmeans-clustering (fix)');
