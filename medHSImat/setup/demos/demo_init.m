%%%%%%%%%%%%%%%%%%%%% Prepare Data %%%%%%%%%%%%%%%%%%%%%
% Update config.ini to adjust directory names etc.
config.SetOpt();

%%%%%%%%%%%%%%%%%%%% Check Data %%%%%%%%%%%%%%%%%%%%%
% Files are saved as .h5 files in directory config.GetSetting('dataDir')
%
% For each data sample, three HSI images are saved as:
% xxx_raw.h5 or xxx_fix.h5 (the tissue sample image)
% xxx_raw_white.h5 or xxx_fix_white.h5 (the white reference image)
% xxx_raw_black.h5 or xxx_fix_black.h5 (dark image with lights off)
% All images are captured in a dark container, saved as .hsm
% and manually exported to .h5 using software for
% 2D Spectrorardiomerter ver 1.15.0.0., TOPCON TECHNOHOUSE c2015
[flag, fileS] = CheckImportData();

%%%%%%%%%%%%%%%%%%%%% Export RGB and Read .h5 files %%%%%%%%%%%%%%%%%%%%%
% Sample information is saved in importDir (input\xxxDBDataInfoTable.xlsx)
% xxx is the DB name in config.GetSetting('database'), now set as 'demo'

% Select entries from the db so that Content = 'tissue' (exact match)
dbSelection = {'tissue', true};
% Validate the details of each data sample
[filenames, targetIDs, outRows] = databaseUtility.Query(dbSelection);

%Set settings for database preparation
config.SetSetting('isTest', false);
config.SetSetting('database', 'demo');
config.SetSetting('normalization', 'byPixel');

% Read all .h5 files according to info in the DB
% Normalization according to config.GetSetting('normalization') is applied
% Consider modifying methods\Preprocessing.m first 
% The dataset name is set according to config (now 'demo')
experiment = '';
hsiUtility.ReadDataset(experiment, dbSelection);

% Export normalized HSI images of tissue samples as a .h5 dataset with 
% structure /hsi/samplexxx , /mask/samplexxx, /label/samplexxx. Each 
% sample data is an instance of the hsi class with properties 'Value' (HSI 
% image) and 'FgMask' (foreground mask). Data is fetched from the dataset
% mentioned in .config and the result is exported in output\000-Datasets.
% Used for easy input to python or other environments.
hsiUtility.ExportH5Dataset();

%%%%%%%%%%%%%%%%%%%%% Read Specific Data %%%%%%%%%%%%%%%%%%%%%
% Reads file with DB ID = 150 and no preprocessing
config.SetSetting('normalization', 'raw');
fileNum = 150;
config.SetSetting('fileName', num2str(fileNum));
hsIm = hsiUtility.LoadHSI(fileNum);

% Reads file with DB ID = 150 and preprocessed with 'byPixel'
config.SetSetting('normalization', 'byPixel');
fileNum = 150;
config.SetSetting('fileName', num2str(fileNum));
hsIm = hsiUtility.LoadHSI(fileNum, 'dataset');

%%%%%%%%%%%%%%%%%%%%% Get Disease Info %%%%%%%%%%%%%%%%%%%%%
% Returns information from the disease DB saved in is saved in importDir
% (input\xxxDBDiagnosisInfoTable.xlsx)
[filenames, targetIDs, outRows, disease, stage] = databaseUtility.GetDiseaseQuery(dbSelection);

%%%%%%%%%%%%%%%%%%%%% Get SAM library %%%%%%%%%%%%%%%%%%%%
% Select samples with ID 153 and 166 to be used as references for the
% library for SAM calculation
referenceIDs = {153, 166};
referenceDisease = cellfun(@(x) disease{targetIDs == x}, referenceIDs, 'UniformOutput', false);
refLib = hsiUtility.PrepareReferenceLibrary(referenceIDs, referenceDisease);

%%%%%%%%%%%%%%%%%%%%% Plot Mean Spectra %%%%%%%%%%%%%%%%%%%%
% Plot average spectra for an ROI on the sample
fig = 1;
plots.AverageSpectrum(fig, hsIm);

%%%%%%%%%%%%%%%%%%%%% Prepare an augmented dataset %%%%%%%%%%%%%%%%%%%%
baseDataset = 'demo';
trainUtility.Augment(baseDataset, 'set1');

%%%%%%%%%%%%%%%%%%%% Prepare train/test set %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Read h5 data
folds = 5;
testingSamples = [5];
numSamples = 6;
content = {'tissue', true};
target = 'fix';
useCustomMask = true;
[cvp, X, y, Xtest, ytest, sRGBs, fgMasks] = trainUtility.PrepareSpectralDataset(folds, testingSamples, numSamples, content, target, useCustomMask);
filename = fullfile(config.GetSetting('output'), config.GetSetting('experiment'), 'cvpInfo.mat');
save(filename, 'cvp', 'X', 'y', 'Xtest', 'ytest', 'sRGBs', 'fgMasks');
