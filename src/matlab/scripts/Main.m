%%%%%%%%%%%%%%%%%%%%% Initialization %%%%%%%%%%%%%%%%%%%%%
Config.SetOpt();
StartLogger;

Config.SetSetting('normalization', 'byPixel');
% Config.SetSetting('dataDate', 20210706);
% Config.SetSetting('integrationTime', 618);
Config.SetSetting('saveDir', fullfile(Config.GetSetting('saveDir'), '001-DataTest'));
Config.SetSetting('cropBorders', true);

%%%%%%%%%%%%%%%%%%%%% Hands %%%%%%%%%%%%%%%%%%%%%
Config.SetSetting('isTest', true);
Config.SetSetting('database', 'calib');
HsiUtility.InitializeDataGroup('handsOnly', {'hand', false});


%%%%%%%%%%%%%%%%%%%%% PSL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%% Prepare Data %%%%%%%%%%%%%%%%%%%%%
Config.SetSetting('isTest', false);
Config.SetSetting('database', 'psl');
Config.SetSetting('normalization', 'byPixel');
CheckPSLData();

%%%%%%%%%%%%%%%%%%%%% Export RGB %%%%%%%%%%%%%%%%%%%%%
HsiUtility.InitializeDataGroup('', {'tissue', true});

%%%%%%%%%%%%%%%%%%%%% Export H5 %%%%%%%%%%%%%%%%%%%%%
Config.SetSetting('normalization', 'raw');
HsiUtility.ExportH5Dataset({'tissue', true});

Config.SetSetting('normalization', 'byPixel');
HsiUtility.ExportH5Dataset({'tissue', true});

Config.SetSetting('normalization', 'byPixel');
fileNum = 150;
Config.SetSetting('fileName', num2str(fileNum));
hsi = HsiUtility.ReadStoredHSI(fileNum, Config.GetSetting('normalization'));
