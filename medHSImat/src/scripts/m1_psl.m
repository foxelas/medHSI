clc;
%%%%%%%%%%%%%%%%%%%%% PSL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%% Prepare Data %%%%%%%%%%%%%%%%%%%%%
baseDataset = 'pslCore';

config.SetOpt();
config.SetSetting('isTest', false);
config.SetSetting('database', 'psl');
config.SetSetting('dataset', baseDataset);
config.SetSetting('normalization', 'byPixel');
%
% CheckImportData();
%
% dbSelection = {'tissue', true};
%
% %%%%%%%%%%%%%%%%%%%%% Export RGB %%%%%%%%%%%%%%%%%%%%%
% %Disable normalization check during data reading
% config.SetSetting('disableNormalizationCheck', true);
% %Do no use mask for unispectrum calculation
% config.SetSetting('useCustomMask', false);
% hsiUtility.PrepareDataset('pslCore', dbSelection);
%
% %%%%%%%%%%%%%%%%%%%%% Augment Dataset %%%%%%%%%%%%%%%%%%%%%
% augDataset = 'pslCoreAugmented';
% trainUtility.Augment(baseDataset, augDataset, 'set1');
%
% %%%%%%%%%%%%%%%%%%%%% Export Dataset %%%%%%%%%%%%%%%%%%%%%
% config.SetSetting('dataset', baseDataset);
% hsiUtility.ExportH5Dataset();
%
% config.SetSetting('dataset', augDataset);
% hsiUtility.ExportH5Dataset();

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