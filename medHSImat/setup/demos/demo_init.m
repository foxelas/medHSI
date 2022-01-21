%%%%%%%%%%%%%%%%%%%%% Prepare Data %%%%%%%%%%%%%%%%%%%%%
config.SetOpt();
config.SetSetting('isTest', false);
config.SetSetting('database', 'demo');
config.SetSetting('normalization', 'byPixel');

%%%%%%%%%%%%%%%%%%%% Check Data %%%%%%%%%%%%%%%%%%%%%
CheckImportData();

%%%%%%%%%%%%%%%%%%%%% Export RGB %%%%%%%%%%%%%%%%%%%%%
hsiUtility.InitializeDataGroup('', {'tissue', true});

%%%%%%%%%%%%%%%%%%%%% Export H5 %%%%%%%%%%%%%%%%%%%%%
config.SetSetting('normalization', 'raw');
hsiUtility.ExportH5Dataset({'tissue', true});

config.SetSetting('normalization', 'byPixel');
hsiUtility.ExportH5Dataset({'tissue', true});

%%%%%%%%%%%%%%%%%%%%% Read Specific Data %%%%%%%%%%%%%%%%%%%%%
config.SetSetting('normalization', 'byPixel');
fileNum = 150;
config.SetSetting('fileName', num2str(fileNum));
hsi = hsiUtility.ReadStoredHSI(fileNum, config.GetSetting('normalization'));