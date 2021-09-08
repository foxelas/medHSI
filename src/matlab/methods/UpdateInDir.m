function [updInDir] = UpdateInDir(inDirDate, inDirFolder)

%% UPDATEINDIR Updates the data input folder directory

if nargin < 2
    inDirFolder = [];
end
parentDataDir = GetSetting('parentDataDir');

if isempty(inDirFolder)
    updInDir = fullfile(parentDataDir, '2_saitamaHSI', strcat('saitama', inDirDate, '_test'), 'h5');
else
    updInDir = fullfile(parentDataDir, '2_saitamaHSI', strcat('saitama', inDirDate, '_test'), inDirFolder, 'h5');
end

SetSetting('inDir', updInDir);
end