function [] = NotifySetting(paramName, paramValue)
%     NOTIFYSETTING notifies about configuration parameter change
%
%     Usage:
%     NotifySetting('saveDir', '\out\dir\')

onOffOptions = {'OFF', 'ON'};
if islogical(paramValue)
    fprintf('--Setting [%s] to %s.\n', paramName, onOffOptions{paramValue+1});
elseif ischar(paramValue)
    fprintf('--Setting [%s] to %s.\n', paramName, paramValue);
elseif isnumeric(paramValue)
    fprintf('--Setting [%s] to %.2f.\n', paramName, paramValue);
else
    warning('Unsupported variable type.\n')
end
end
