%%%%%%%%%%%%%%%%%%%%% Initialization %%%%%%%%%%%%%%%%%%%%%
SetOpt();
StartLogger;

SetSetting('normalization', 'byPixel');
% SetSetting('dataDate', 20210706);
% SetSetting('integrationTime', 618);
SetSetting('saveDir', fullfile(GetSetting('saveDir'), '001-DataTest'));
SetSetting('cropBorders', true);

%%%%%%%%%%%%%%%%%%%%% Prepare Data %%%%%%%%%%%%%%%%%%%%%
SetSetting('isTest', true);
SetSetting('database', 'calib');
% InitializeDataGroup('handsOnly',{'hand', false});

SetSetting('isTest', false);
SetSetting('database', 'psl');
% InitializeDataGroup('sample001-tissue', {'tissue', true});

SetSetting('normalization', 'raw');
ExportH5Dataset({'tissue', true});

SetSetting('normalization', 'byPixel');
ExportH5Dataset({'tissue', true});

SetSetting('normalization', 'byPixel');
fileNum = 150;
SetSetting('fileName', num2str(fileNum));
hsi = ReadStoredHSI(fileNum, GetSetting('normalization'));
FindSuperpixelAutocorrelation(hsi, 10);

%%%%%%%%%%%%%%%%%%%%% Prepare Data %%%%%%%%%%%%%%%%%%%%%
demo_SuperPCA;
ApplySuperPCA; 