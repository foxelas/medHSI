function [spectralData, label] = LoadHSIInternal(targetName, dataType)
% LoadHSIInternal reads a stored HSI from a .mat file
%
%   Usage:
%   config.SetSetting('normalization', 'raw');
%   [spectralData, v] = LoadHSIInternal(targetName)
%
%   [spectralData, label] = LoadHSIInternal(targetName, 'dataset')
%
%   config.SetSetting('normalization', 'byPixel');
%   [spectralData, label] = LoadHSIInternal(targetName, 'preprocessed')

if nargin < 2
    dataType = 'raw';
end

if isnumeric(targetName)
    targetName = num2str(targetName);
end
targetFilename = dataUtility.GetFilename(dataType, targetName);

variableInfo = who('-file', targetFilename);
if ismember('label', variableInfo) % returns true
    load(targetFilename, 'spectralData', 'label');
else
    load(targetFilename, 'spectralData');
    label = [];
end

end