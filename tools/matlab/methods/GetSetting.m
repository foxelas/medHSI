function [value] = GetSetting(parameter)
%     GETSETTING returns the value of a configurationParameter
%
%     Usage:
%     value = getSetting('saveDir')

settingsFile = fullfile(GetConfDir(), 'config.mat');
variableInfo = who('-file', settingsFile);
if ismember(parameter, variableInfo)
    m = matfile(settingsFile);
    value = m.(parameter);
else
    fprintf('Parameter %s does not exist in the configuration file.\n', parameter);
end
end
