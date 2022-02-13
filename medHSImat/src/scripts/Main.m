%%%%%%%%%%%%%%%%%%%%% Initialization %%%%%%%%%%%%%%%%%%%%%
config.SetOpt();
StartLogger;

config.SetSetting('normalization', 'byPixel');
% config.SetSetting('dataDate', 20210706);
% config.SetSetting('integrationTime', 618);
config.SetSetting('saveDir', fullfile(config.GetSetting('saveDir'), '001-DataTest'));
config.SetSetting('cropBorders', true);

%%%%%%%%%%%%%%%%%%%%% Hands %%%%%%%%%%%%%%%%%%%%%
config.SetSetting('isTest', true);
config.SetSetting('database', 'calib');
hsiUtility.InitializeDataGroup('handsOnly', {'hand', false});


%%%%%%%%%%%%%%%%%%%%% PSL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%% Prepare Data %%%%%%%%%%%%%%%%%%%%%
config.SetSetting('isTest', false);
config.SetSetting('database', 'psl');
config.SetSetting('normalization', 'byPixel');
CheckImportData();

%%%%%%%%%%%%%%%%%%%%% Export RGB %%%%%%%%%%%%%%%%%%%%%
hsiUtility.InitializeDataGroup('', {'tissue', true});
