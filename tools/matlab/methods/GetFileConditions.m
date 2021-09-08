function [fileConditions] = GetFileConditions(content, target, id)
%%GETFILECONDITIONS returns the conditions necessary for finding the
%%filename of the file to be read
%
%   Usage:
%   fileConditions = GetFileConditions(content, target)

fileConditions = {GetSetting('configuration'), [], ...
    GetSetting('integrationTime'), target, GetSetting('dataDate')};

if nargin > 1
    fileConditions = {GetSetting('configuration'), content, ...
        GetSetting('integrationTime'), target, GetSetting('dataDate')};
end

if nargin > 2
    fileConditions = [fileConditions, id];
end
end