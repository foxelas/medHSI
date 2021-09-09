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
InitializeDataGroup('handsOnly',{'hand', false});

SetSetting('isTest', false);
SetSetting('database', 'psl');
InitializeDataGroup('sample001-tissue', {'tissue', true});

sampleId = '001';
