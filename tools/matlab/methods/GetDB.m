function dataTable = GetDB()
%GetDB returns the db structure as a table
%
%   Usage:
%   dataTable = GetDB()

dataTable = readtable(fullfile(GetSetting('importDir'), strcat(GetSetting('database'), 'DB.xlsx')), 'Sheet', 'capturedData');
end
