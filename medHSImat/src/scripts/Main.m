%%%%%%%%%%%%%%%%%%%%% Initialization %%%%%%%%%%%%%%%%%%%%%
config.SetOpt();
StartLogger;

config.SetSetting('normalization', 'byPixel');
% config.SetSetting('dataDate', 20210706);
% config.SetSetting('integrationTime', 618);
config.SetSetting('outputDir', fullfile(config.GetSetting('outputDir'), '001-DataTest'));
config.SetSetting('cropBorders', true);

%%%%%%%%%%%%%%%%%%%%% Hands %%%%%%%%%%%%%%%%%%%%%
config.SetSetting('isTest', true);
config.SetSetting('database', 'calib');
hsiUtility.ReadDataset('handsOnly', {'hand', false});


%%%%%%%%%%%%%%%%%%%%% PSL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%% Prepare Data %%%%%%%%%%%%%%%%%%%%%
config.SetOpt();
config.SetSetting('isTest', false);
config.SetSetting('database', 'psl');
config.SetSetting('normalization', 'byPixel');
CheckImportData();

dbSelection = {'tissue', true};

%%%%%%%%%%%%%%%%%%%%% Export RGB %%%%%%%%%%%%%%%%%%%%%
hsiUtility.PrepareDataset('', dbSelection);

%%%%%%%%%%%%%%%%%%%%% Run Tests %%%%%%%%%%%%%%%%%%%%%
t20211104_ApplyScriptToEachImage;
t20211207_PrepareLabels;
t20211207_PrepareSummaryFigures
t20211208_TestSVM
t20211230_PrintSampleHSI
t20220121_Dimred
t20220122_Dimred
t210910_ReadHands

baseDataset = 'pslBase';
trainUtility.Augment(baseDataset, 'set1');