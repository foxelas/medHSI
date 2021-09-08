function dataTable = GetDB()
%GetDB returns the db structure as a table
%
%   Usage:
%   dataTable = GetDB()

dataTable = readtable(fullfile(GetSetting('datasetSettingsDir'), strcat(GetSetting('database'), 'DB.xlsx')), 'Sheet', 'capturedData');
end
