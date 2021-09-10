function [curDir] = GetRunBaseDir()

%% GETRUNBASEDIR returns the base dir for the current project

currentDir = pwd;
projectName = 'medHSI';
parts = strsplit(currentDir, 'medHSI');
curDir = fullfile(parts{1}, projectName);

end