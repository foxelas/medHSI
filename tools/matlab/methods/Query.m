function [filenames, tableIds, outRows] = Query(configuration, content, integrationTime, target, dataDate, id)

%% Query Gets the respective filename for configuration value
%   arguments are received in the order of
%     'configuration' [light source]
%     'content' [type of catpured object]
%     'integrationTime' [value of integration time]
%     'target' [details about captured object]
%     'dataDate' [catpureDate]
%     'id' [number value for id ]
%
%   Usage:
%   [filenames, tableIds, outRows] = Query(configuration, content, integrationTime, target, dataDate, id)

warning('off', 'MATLAB:table:ModifiedAndSavedVarnames');
dataTable = GetDB();

if nargin < 3
    integrationTime = [];
    target = [];
    dataDate = [];
    id = [];
end

setId = true(numel(dataTable.ID), 1);

if ~isempty(configuration)
    setId = setId & ismember(dataTable.Configuration, configuration);
end

if nargin >= 2 && ~isempty(content)
    [content, isMatchContent] = GetCondition(content);
    if isMatchContent
        setId = setId & ismember(dataTable.Content, content);
    else
        setId = setId & contains(lower(dataTable.Content), lower(content));
    end
end
if nargin >= 3 && ~isempty(integrationTime)
    setId = setId & ismember(dataTable.IntegrationTime, integrationTime);
end
if nargin >= 4 && ~isempty(target)
    [target, isMatchTarget] = GetCondition(target);
    if isMatchTarget
        setId = setId & ismember(dataTable.Target, target);
    else
        setId = setId & contains(lower(dataTable.Target), lower(target));
    end
end
if nargin >= 5 && ~isempty(dataDate)
    setId = setId & ismember(dataTable.CaptureDate, str2num(dataDate));
end
if nargin >= 6 && ~isempty(id)
    setId = setId & ismember(dataTable.ID, id);
end

outRows = dataTable(setId, :);
filenames = outRows.Filename;
tableIds = outRows.ID;

end

function [keyValue, isMatch] = GetCondition(value)
if iscell(value)
    isMatch = value{2};
    keyValue = value{1};
else
    isMatch = true;
    keyValue = value;
end
end