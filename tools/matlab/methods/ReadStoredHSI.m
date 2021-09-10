function [spectralData] = ReadStoredHSI(targetName, normalization)
% ReadStoredHSI reads a stored HSI from a _target mat file
%
%   Usage:
%   [spectralData] = ReadStoredHSI(targetName)
%   [spectralData] = ReadStoredHSI(targetName, 'byPixel')

if nargin < 2
    normalization = 'raw';
end

if strcmp(normalization, 'raw')
    baseDir = fullfile(GetSetting('matDir'), ...
        strcat(GetSetting('database'), 'Triplets'), targetName);
    targetFilename = strcat(baseDir, '_target.mat');
else
    baseDir = fullfile(GetSetting('matDir'), ...
        strcat(GetSetting('database'), 'Normalized'), targetName);
    targetFilename = strcat(baseDir, '_', normalization, '.mat');
end

load(targetFilename, 'spectralData');
end