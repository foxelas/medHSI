function [varargout] = ApplyScriptToEachImage(functionName, condition, varargin)
%%ApplyScriptToEachImage applys a script on each of the data samples who
%%fullfill the condition
%
%   Usage:
%   ApplyScriptToEachImage(@ApplyKmeans);
%   ApplyScriptToEachImage(@ApplyKmeans, {'tissue', true});

if nargin < 2 || isempty(condition)
    condition = {'tissue', true};
end

%% Read h5 data
[~, targetIDs, outRows] = Query(condition);
sType = 'all'; %'all', 'fix', 'raw'
if strcmp(sType, 'raw')
    isUnfixedCol = cell2mat([outRows.IsUnfixed]);
    unfixedId = isUnfixedCol == '1';
    targetIDs = targetIDs(unfixedId);
elseif strcmp(sType, 'fix')
    isUnfixedCol = cell2mat([outRows.IsUnfixed]);
    unfixedId = isUnfixedCol == '0';
    targetIDs = targetIDs(unfixedId);
end

for i = 1:length(targetIDs)
    id = targetIDs(i);

    %% load HSI from .mat file
    targetName = num2str(id);
    hsi = ReadStoredHSI(targetName, GetSetting('normalization'));

    %% Change to Relevant Script
    if nargout(functionName) > 0
        varargout{:} = functionName(hsi, targetName, varargin{:});
    else
        functionName(hsi, targetName, varargin{:});
    end
end

end