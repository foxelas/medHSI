% ======================================================================
%> @brief Tutorial_ReadDataset is a tutorial on how to initialize and process the dataset.
% ======================================================================
%% Read settings from the file
% Update config.ini to adjust directory names etc.
config.SetOpt();

%% Set initializattion folders
dataset = 'pslRaw';
experiment = 'Test-Clustering';
initUtility.InitExperiment(experiment, dataset);

%% Check import data from pslDBDataInfoTable.xlsx
% Files are saved as .h5 files in directory config.GetSetting('DataDir')
%
% For each data sample, three HSI images are saved as:
% xxx_raw.h5 or xxx_fix.h5 (the tissue sample image)
% xxx_raw_white.h5 or xxx_fix_white.h5 (the white reference image)
% xxx_raw_black.h5 or xxx_fix_black.h5 (dark image with lights off)
% All images are captured in a dark container, saved as .hsm
% and manually exported to .h5 using software for
% 2D Spectrorardiomerter ver 1.15.0.0., TOPCON TECHNOHOUSE c2015
[flag, fileS] = InitUtility.CheckImportData();

%% Read values from raw,white,black .h5 files
% Sample information is saved in importDir (input\xxxDBDataInfoTable.xlsx)
% xxx is the DB name in config.GetSetting('Database'), now set as 'psl'

% Select entries from the db so that Content = 'tissue' (exact match)
dbSelection = {'tissue', true};
% Validate the details of each data sample
[filenames, targetIDs, outRows] = databaseUtility.Query(dbSelection);

% These conditions read all data that in pslDBDataInfoTable.xlsx are set as
% 'tissue' and as 'raw', so all unfixed tissue samples. A foreground mask
% is also extracted.
%
% These files are ready to use for unsupervised learning.
%
% If label values already exist in config::[DataDir]/01-Measurements/, then
% labelInfo class files are read at the same time.
%
% Read all .h5 files according to info in the DB
% Normalization according to config.GetSetting('Normalization') is applied
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

%% Get the Diagnosis info from the excel file 
% Returns information from the Diagnosis DB saved in is saved in config::[ImportDir]
% (input\xxxDBDiagnosisInfoTable.xlsx)
[filenames, targetIDs, outRows, diagnosis, stage] = databaseUtility.GetDiagnosisQuery(dbSelection);


%% Prepare Labels with Labelme
% Use as base the sRGB images in config::[OutoutDir]/config::[Dataset]/00-Snapshots/
% Export JSON labels and files and save them in a folder.
% For this tutorial assume labelme files saved in config::[OutoutDir]/config::[Dataset]/02-Labels/

%% Save the label masks ini config::[DataDir]/01-Measurements/
initUtility.PrepareLabels('02-Labels', dataset, contentConditions, targetConditions);

%% Update labels in the hsi class files and prepare labelInfo class files
initUtility.UpdateLabelInfos(dataset);

%% Load the entire dataset as a list of hsi and hsiInfo classes
[hsiList, labelInfoList] = hsiUtility.LoadDataset();

%% Export an .h5 database of all the preprocessed and labeled data
% Export normalized HSI images of tissue samples as a .h5 dataset with
% structure /hsi/samplexxx , /mask/samplexxx, /label/samplexxx. Each
% sample data is an instance of the hsi class with properties 'Value' (HSI
% image) and 'FgMask' (foreground mask), among others. Data is fetched from the dataset
% mentioned in .config and the result is exported in output\000-Datasets.
% Used for easy input to python or other environments.
%
% After export, the database is saved in config::[OutputDir]\\config::[Dataset]\\*.h5.
% You can view the contents with h5info
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

%% Export .h5 datasets of train/test folds
% The result is saved in
% config::[OutputDir]\\baseDataset\\config::[DatasetsFolderName]\\hsi_baseDataset_train.h5
% and
% config::[OutputDir]\\baseDataset\\config::[DatasetsFolderName]\\hsi_baseDataset_test.h5

baseDataset = 'pslRaw';
testIds = {'157', '251', '227'};
trainUtility.ExportTrainTest(baseDataset, testIds);

%% Export .h5 datasets of LOOCV folds
% The result for fold XX is saved in
% config::[OutputDir]\\baseDataset\\config::[DatasetsFolderName]\\XX\\hsi_baseDataset_train.h5
% and
% config::[OutputDir]\\baseDataset\\config::[DatasetsFolderName]\\XX\\hsi_baseDataset_test.h5

%By patient
baseDataset = 'pslRaw32Augmented';
trainUtility.ExportLOOCV(baseDataset, true);

%By sample
baseDataset = 'pslRaw32Augmented';
trainUtility.ExportLOOCV(baseDataset);

%% Prepare a reference library with reference spectra 
% Select samples with ID 153 and 166 to be used as references for the
% library for SAM calculation
referenceIDs = {153, 166};
refLib = hsiUtility.PrepareReferenceLibrary(referenceIDs);

%% Apply Kmeans segmentation on all images of the dataset and produce evidence 
config.SetSetting('Dataset', 'pslRaw');
segment.ApplyAndShow('Kmeans');

%% Apply Leon segmentation on all images of the dataset and produce evidence 
config.SetSetting('Dataset', 'pslRaw');
segment.ApplyAndShow('Leon');

%% Apply ICA dimension reduction on all images of the dataset and produce evidence 
config.SetSetting('Dataset', 'pslRaw');
dimredUtility.ApplyAndShow('ICA');

%% Format data as arrays of tissue pixels instead of HSI cubes
config.SetSetting('Dataset', 'pslRaw');

[hsiList, labelInfoList] = hsiUtility.LoadDataset();
dataType = 'pixel';
[X, y, sRGBs, fgMasks, labelImgs] = trainUtility.Format(hsiList, labelInfoList, dataType);

%% Format data as only image and label values, ignore the hsi class and hsiInfo class
config.SetSetting('Dataset', 'pslRaw');

[hsiList, labelInfoList] = hsiUtility.LoadDataset();
dataType = 'image';
[X, y, sRGBs, fgMasks, labelImgs] = trainUtility.Format(hsiList, labelInfoList, dataType);

%% Custom format to reduce the spectral dimension for all HSI cubes
config.SetSetting('Dataset', 'pslRaw');

[hsiList, labelInfoList] = hsiUtility.LoadDataset();
dataType = 'hsi';
transformFun = @(x) x(:, :, 30:50); %@Dimred
[X, y, sRGBs, fgMasks, labelImgs] = trainUtility.Format(hsiList, labelInfoList, dataType, transformFun);

%% Reduce data with PCA and then cross validate with 5-fold cross validation
dataset = 'pslRaw';
splitType = 'kfold';
folds = 5;
testIds = [];
svmSettings = [];
validationPerformance = trainUtility.Validation(dataset, splitType, folds, testIds, 'PCA', 10, svmSettings);

%% Reduce data with PCA and then cross validate with LOOCV cross validation
dataset = 'pslRaw';
splitType = 'LOOCV-bySample';
folds = [];
testIds = [];
svmSettings = [];
validationPerformance = trainUtility.Validation(dataset, splitType, folds, testIds, 'PCA', 10, svmSettings);

%% Reduce data with Multiscale ClusterPCA and then cross validate with 5-fold cross validation and test
testIds = {'157', '251', '227'};
method = 'MClusterPCA';
q = 10;
endmemberNumArray = floor(20*sqrt(2).^[-2:2]);
svmSettings = [];
[validatedPerformance, testPerformance] = trainUtility.ValidateAndTest(dataset, testIds, method, q, svmSettings, endmemberNumArray);
