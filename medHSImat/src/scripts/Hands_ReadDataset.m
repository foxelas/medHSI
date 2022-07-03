% ======================================================================
%> @brief Hands_ReadDataset prepares dataset of hsi samples of hands.
% ======================================================================
config.SetOpt();

config.SetSetting('Normalization', 'byPixel');
% config.SetSetting('DataDate', 20210706);
% config.SetSetting('IntegrationTime', 618);
config.SetSetting('CropBorders', true);

% Pending fix db
%%%%%%%%%%%%%%%%%%%%% Hands %%%%%%%%%%%%%%%%%%%%%
config.SetSetting('IsTest', true);
config.SetSetting('Database', 'calib');
config.SetSetting('DataDir', 'D:\elena\mspi\2_saitamaHSI\calib\');
config.SetSetting('OutputDir', fullfile(config.GetSetting('OutputDir'), '001-DataTest'));

readForeground = false;
hsiUtility.PrepareDataset('handsOnly', {'hand', false}, readForeground);
