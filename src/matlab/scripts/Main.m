%%%%%%%%%%%%%%%%%%%%% Initialization %%%%%%%%%%%%%%%%%%%%%
SetOpt();
StartLogger;

SetSetting('normalization', 'byPixel');
% SetSetting('dataDate', 20210706);
% SetSetting('integrationTime', 618);
SetSetting('saveDir', fullfile(GetSetting('saveDir'), '001-DataTest'));
SetSetting('cropBorders', true);

%%%%%%%%%%%%%%%%%%%%% Hands %%%%%%%%%%%%%%%%%%%%%
SetSetting('isTest', true);
SetSetting('database', 'calib');
InitializeDataGroup('handsOnly', {'hand', false});






%%%%%%%%%%%%%%%%%%%%% PSL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%% Prepare Data %%%%%%%%%%%%%%%%%%%%%
SetSetting('isTest', false);
SetSetting('database', 'psl');
SetSetting('normalization', 'byPixel');
CheckPSLData();

%%%%%%%%%%%%%%%%%%%%% Export RGB %%%%%%%%%%%%%%%%%%%%%
InitializeDataGroup('u20211119', {'tissue', true});

%%%%%%%%%%%%%%%%%%%%% Export H5 %%%%%%%%%%%%%%%%%%%%%
SetSetting('normalization', 'raw');
ExportH5Dataset({'tissue', true});

SetSetting('normalization', 'byPixel');
ExportH5Dataset({'tissue', true});

SetSetting('normalization', 'byPixel');
fileNum = 150;
SetSetting('fileName', num2str(fileNum));
hsi = ReadStoredHSI(fileNum, GetSetting('normalization'));
FindSuperpixelAutocorrelation(hsi, 10);

%%%%%%%%%%%%%%%%%%%%% SuperPCA %%%%%%%%%%%%%%%%%%%%%
demo_SuperPCA;
ApplySuperPCA;

t20211104_ApplyScriptToEachImage;
