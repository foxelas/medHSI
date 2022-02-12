function [spectralData] = LoadHSIInternal(targetName, dataType)
% LoadHSIInternal reads a stored HSI from a _target mat file
%
%   Usage:
%   config.SetSetting('normalization', 'raw');
%   [spectralData] = LoadHSIInternal(targetName)
%
%   config.SetSetting('normalization', 'preprocessed');
%   [spectralData] = LoadHSIInternal(targetName)

if nargin < 2
    dataType = 'raw';
end

if isnumeric(targetName)
    targetName = num2str(targetName);
end
targetFilename = dataUtility.GetFilename(dataType, targetName);
load(targetFilename, 'spectralData');

end