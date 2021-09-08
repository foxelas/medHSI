function [] = SetSetting(parameter, value)
%     SETSETTING sets a parameter according to a value or by default
%
%     Usage:
%     SetSetting('saveDir', 'out\out')
%     SetSetting('saveDir')

settingsFile = DirMake('parameters', 'configuration.mat');
m = matfile(settingsFile, 'Writable', true);
if nargin < 2 %write default value
    v = m.options;
    m.(parameter) = v.(parameter);
    value = v.(parameter);
else
    m.(parameter) = value;
end
NotifySetting(parameter, value);
end
