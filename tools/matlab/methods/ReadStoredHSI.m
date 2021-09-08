function [spectralData] = ReadStoredHSI(targetName)
% ReadStoredHSI reads a stored HSI from a _target mat file
%
%   Usage:
%   [spectralData] = ReadStoredHSI(targetName)

baseDir = fullfile(GetSetting('matDir'), ...
    strcat(GetSetting('database'), 'Triplets'), targetName);

targetFilename = strcat(baseDir, '_target.mat');
load(targetFilename, 'spectralData');
end