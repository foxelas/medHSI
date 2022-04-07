clc;
%%%%%%%%%%%%%%%%%%%%% PSL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%% Prepare Data %%%%%%%%%%%%%%%%%%%%%
baseDataset = 'pslCore';

config.SetOpt();
config.SetSetting('IsTest', false);
config.SetSetting('Database', 'psl');
config.SetSetting('Dataset', baseDataset);
config.SetSetting('Normalization', 'byPixel');

CheckImportData();

dbSelection = {'tissue', true};

%%%%%%%%%%%%%%%%%%%%% Export RGB %%%%%%%%%%%%%%%%%%%%%
%Disable normalization check during data reading
config.SetSetting('DisableNormalizationCheck', true);
%Do no use mask for unispectrum calculation
config.SetSetting('UseCustomMask', false);
hsiUtility.PrepareDataset('pslCore', dbSelection);

%%%%%%%%%%%%%%%%%%%%% Prepare Raw Dataset %%%%%%%%%%%%%%%%%%%%%
baseDataset = 'pslRaw';
readForeground = true;
targetConditions = {'raw', false};
hsiUtility.PrepareDataset(baseDataset, dbSelection, readForeground, targetConditions);

%%%%%%%%%%%%%%%%%%%%% Prepare 512x512 Dataset %%%%%%%%%%%%%%%%%%%%%
dataset512 = 'psl512';
config.SetSetting('HasResizeOptions', true);
config.SetSetting('ImageDimension', 512);
config.SetSetting('SplitToPatches', false);
trainUtility.Resize(baseDataset, dataset512);

%%%%%%%%%%%%%%%%%%%%% Augment Dataset %%%%%%%%%%%%%%%%%%%%%
augDataset = 'pslCoreAugmented';
trainUtility.Augment(baseDataset, augDataset, 'set1');

%%%%%%%%%%%%%%%%%%%%% Export Dataset %%%%%%%%%%%%%%%%%%%%%
config.SetSetting('Dataset', baseDataset);
hsiUtility.ExportH5Dataset();

config.SetSetting('Dataset', augDataset);
hsiUtility.ExportH5Dataset();

% %%%%%%%%%%%%%%%%%%%%% Run Tests %%%%%%%%%%%%%%%%%%%%%
Basics_Kmeans;
Basics_SuperPCA;
Basics_PrintSampleHSI;
Basics_SummaryFigs;

% t20211207_PrepareLabels;
% t20211207_PrepareSummaryFigures
% t20211208_TestSVM
% t20211230_PrintSampleHSI
% t20220121_Dimred
% t20220122_Dimred
% t210910_ReadHands