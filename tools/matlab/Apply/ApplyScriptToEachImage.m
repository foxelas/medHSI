function [varargout] = ApplyScriptToEachImage(functionName, condition, target, varargin)
%%ApplyScriptToEachImage applies a script on each of the data samples who
%%fullfill the condition
%
%   Usage:
%   ApplyScriptToEachImage(@ApplyKmeans);
%   ApplyScriptToEachImage(@ApplyKmeans, {'tissue', true}, []);

if nargin < 2
    condition = [];
    target = [];
    varargin = {};
end

%% Read h5 data
[targetIDs, ~] = databaseUtility.GetTargetIndexes(condition, target);

for i = 1:length(targetIDs)
    id = targetIDs(i);

    %% load HSI from .mat file
    targetName = num2str(id);
    hsIm = hsi;
    hsIm.Value = hsiUtility.ReadStoredHSI(targetName, config.GetSetting('normalization'));

    %% Change to Relevant Script
    if nargout(functionName) > 0
        varargout{:} = functionName(hsIm, targetName, varargin{:});
    else
        functionName(hsIm, targetName, varargin{:});
        varargout{:} = {};
    end
end

end