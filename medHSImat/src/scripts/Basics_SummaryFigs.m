function Basics_SummaryFigs()

baseDir = fullfile(config.GetSetting('outputDir'), config.GetSetting('dataset'));

% Remove last two images from Montage Folder Contents
plots.MontageFolderContents(1, fullfile(baseDir, config.GetSetting('labelsAppliedFolderName'), '\'), [], 'Labels');
criteria = struct('TargetDir', 'subfolders', 'TargetName', 'pc1', 'TargetType', 'fix');

plots.MontageFolderContents(3, fullfile(baseDir, config.GetSetting('labelsFolderName'), '\'), [], 'Label Masks');

pcaFolder = 'SuperPCA28-Feb-2022';
plots.MontageFolderContents(2, fullfile(baseDir, pcaFolder, '\'), criteria, 'PC1 (fix)');
criteria = struct('TargetDir', 'subfolders', 'TargetName', 'pc2', 'TargetType', 'fix');
plots.MontageFolderContents(2, fullfile(baseDir, pcaFolder, '\'), criteria, 'PC2 (fix)');
criteria = struct('TargetDir', 'subfolders', 'TargetName', 'pc3', 'TargetType', 'fix');
plots.MontageFolderContents(2, fullfile(baseDir, pcaFolder, '\'), criteria, 'PC3 (fix)');

kmeansFolder = 'Kmeans28-Feb-2022';
criteria = struct('TargetDir', 'subfolders', 'TargetName', 'kmeans-clustering', 'TargetType', 'fix');
plots.MontageFolderContents(4, fullfile(baseDir, kmeansFolder, '\'), criteria, 'kmeans-clustering (fix)');

criteria = struct('TargetDir', 'subfolders', 'TargetName', 'kmeans-clustering', 'TargetType', 'fix');
plots.MontageFolderContents(4, fullfile(baseDir, kmeansFolder, '\'), criteria, 'kmeans-clustering (fix)');


end