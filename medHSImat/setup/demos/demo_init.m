%%%%%%%%%%%%%%%%%%%%% Prepare Data %%%%%%%%%%%%%%%%%%%%%
% Update config.ini to adjust directory names etc.
config.SetOpt();
config.SetSetting('isTest', false);
config.SetSetting('database', 'demo');
config.SetSetting('normalization', 'byPixel');

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

% Read all .h5 files according to info in the DB
% Preprocessing is applied according to functions in hsi.Preprocessing
hsiUtility.InitializeDataGroup('', dbSelection);

%%%%%%%%%%%%%%%%%%%%% Export H5 %%%%%%%%%%%%%%%%%%%%%
% Export raw HSI images of tissue samples as a .h5 dataset with structure
% /hsi/samplexxx . Each sample data is 3D array of raw measurements.
config.SetSetting('normalization', 'raw');
hsiUtility.ExportH5Dataset(dbSelection);

% Export normalized HSI images of tissue samples as a .h5 dataset with structure
% /hsi/samplexxx . Each sample data is an instance of the hsi class with
% properties 'Value' (HSI image) and 'FgMask' (foreground mask).
config.SetSetting('normalization', 'byPixel');
hsiUtility.ExportH5Dataset(dbSelection);

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
hsIm = hsiUtility.LoadHSI(fileNum, 'preprocessed');

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
