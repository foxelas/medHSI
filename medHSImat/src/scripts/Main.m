clc;

% %%%%%%%%%%%%%%%%%%%%% Initialization %%%%%%%%%%%%%%%%%%%%%
% config.SetOpt();
%
% config.SetSetting('normalization', 'byPixel');
% % config.SetSetting('dataDate', 20210706);
% % config.SetSetting('integrationTime', 618);
% config.SetSetting('cropBorders', true);
%
% % Pending fix db
% %%%%%%%%%%%%%%%%%%%%% Hands %%%%%%%%%%%%%%%%%%%%%
% config.SetSetting('isTest', true);
% config.SetSetting('database', 'calib');
% config.SetSetting('dataDir', 'D:\elena\mspi\2_saitamaHSI\calib\');
% config.SetSetting('outputDir', fullfile(config.GetSetting('outputDir'), '001-DataTest'));
%
% readForeground = false;
% hsiUtility.PrepareDataset('handsOnly', {'hand', false}, readForeground);

%%%%%%%%%%%%%%%%%%%%% PSL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%% Prepare Data %%%%%%%%%%%%%%%%%%%%%
baseDataset = 'pslCore';

config.SetOpt();
config.SetSetting('isTest', false);
config.SetSetting('database', 'psl');
config.SetSetting('dataset', baseDataset);
config.SetSetting('normalization', 'byPixel');

CheckImportData();

dbSelection = {'tissue', true};

%%%%%%%%%%%%%%%%%%%%% Export RGB %%%%%%%%%%%%%%%%%%%%%
% hsiUtility.PrepareDataset('pslCore', dbSelection);


% %%%%%%%%%%%%%%%%%%%%% Run Tests %%%%%%%%%%%%%%%%%%%%%
% t20211104_ApplyScriptToEachImage;
% t20211207_PrepareLabels;
% t20211207_PrepareSummaryFigures
% t20211208_TestSVM
% t20211230_PrintSampleHSI
% t20220121_Dimred
% t20220122_Dimred
% t210910_ReadHands

augDataset = 'pslCoreAugmented';
trainUtility.Augment(baseDataset, augDataset, 'set1');