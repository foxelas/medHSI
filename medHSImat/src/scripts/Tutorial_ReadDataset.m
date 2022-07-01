
%% Read settings from the file 
config.SetOpt();

%% Set initializattion folders 
dataset = 'pslRaw';
experiment = 'Test-Clustering';
initUtility.InitExperiment(experiment, dataset);

%% Check import data from pslDBDataInfoTable.xlsx
[flag, fileS] = InitUtility.CheckImportData();

%% Read values from raw,white,black .h5 files 
% These conditions read all data that in pslDBDataInfoTable.xlsx are set as
% 'tissue' and as 'raw', so all unfixed tissue samples. A foreground mask
% is also extracted. 
%
% These files are ready to use for unsupervised learning. 
%
% If label values already exist in config::[DataDir]/01-Measurements/, then
% labelInfo class files are read at the same time. 
%
% First check that function Preprocessing.m (in src/methods/) is according to your specifications.
%
targetDataset = 'Raw';
baseDataset = 'psl';
initUtility.MakeDataset(targetDataset, baseDataset);

% % Alternatively
% contentConditions = {'tissue', true};
% readForeground = true;
% targetConditions = {'raw', false};
% hsiUtility.PrepareDataset(dataset, contentConditions, readForeground, targetConditions);

%% Plot a montage of sRGBs of the read images 
folder = fullfile(config.GetSetting('SnapshotsFolderName'), 'preprocessed\');
outputDir = commonUtility.GetFilename('output', folder, '');
plots.MontageFolderContents(2, outputDir, [], 'sRGBs (only first 20 are shown)');

%% Prepare Labels with Labelme
% Use as base the sRGB images in config::[OutoutDir]/config::[Dataset]/00-Snapshots/
% Export JSON labels and files and save them in a folder.
% For this tutorial assume labelme files saved in config::[OutoutDir]/config::[Dataset]/02-Labels/

%% Save the label masks ini config::[DataDir]/01-Measurements/
init.PrepareLabels('02-Labels', dataset, contentConditions, targetConditions);

%% Update labels in the hsi class files and prepare labelInfo class files 
init.UpdateLabelInfos(dataset);

%% Export an .h5 database of all the preprocessed and labeled data   
% After reading, the database is saved in config::[OutputDir]\\config::[Dataset]\\*.h5.
hsiUtility.ExportH5Dataset();

%% Make subdatasets from the original dataset 
% Make 32x32 patches 
targetDataset = '32';
initUtility.MakeDataset(targetDataset, dataset);

% Make 512x512 padded squares 
targetDataset = '512';
initUtility.MakeDataset(targetDataset, dataset);

% Convert to 3 channels by PCA, from the 512x512 dataset 
targetDataset = 'pca';
baseDataset = 'psl512';
initUtility.MakeDataset(targetDataset, baseDataset);

% Augment the 32x32 patches 4-fold with flips 
baseDataset = 'psl32';
initUtility.MakeDataset('Augmented', baseDataset);

