function [fileConditions] = GetFileConditions(content, target, id)
%%GETFILECONDITIONS returns the conditions necessary for finding the
%%filename of the file to be read
%
%   Usage:
%   fileConditions = GetFileConditions(content, target)

if nargin < 2
    target = [];
end
if nargin < 3
    id = [];
end


if GetSetting('isTest')
    fileConditions = {content, [], GetSetting('dataDate'), id, ...
        GetSetting('integrationTime'), target, GetSetting('configuration')};
else
    fileConditions = {content, [], GetSetting('dataDate'), id, ...
        GetSetting('integrationTime'), target, []};
end

end