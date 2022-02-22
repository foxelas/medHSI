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
config.SetOpt();
config.SetSetting('isTest', false);
config.SetSetting('database', 'psl');
config.SetSetting('normalization', 'byPixel');
CheckImportData();

dbSelection = {'tissue', true};
%%%%%%%%%%%%%%%%%%%%% Export RGB %%%%%%%%%%%%%%%%%%%%%
hsiUtility.PrepareDataset('pslCore', dbSelection);