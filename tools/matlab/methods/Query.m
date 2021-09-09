function [filenames, tableIds, outRows] = Query(content, sampleId, captureDate, id, integrationTime, target, configuration)

%% Query Gets the respective filename for configuration value
%   arguments are received in the order of
%     'configuration' [light source]
%     'content' [type of captured object]
%     'integrationTime' [value of integration time]
%     'target' [details about captured object]
%     'dataDate' [captureDate]
%     'id' [number value for id ]
%
%   Usage:
%   [filenames, tableIds, outRows] = Query(content, sampleId, captureDate, id, integrationTime, target, configuration)

warning('off', 'MATLAB:table:ModifiedAndSavedVarnames');
dataTable = GetDB();

if nargin < 7 
    configuration = []; 
end 
if nargin < 6 
    target = [];
end 
if nargin < 5 
    integrationTime = [];
end 
if nargin < 4 
    id = [];
end 
if nargin < 3 
    captureDate = [];
end 

if nargin < 2 
    sampleId = [];
end 

setId = true(numel(dataTable.ID), 1);

if ~isempty(configuration)
    setId = setId & ismember(dataTable.Configuration, configuration);
end

if ~isempty(content)
    [content, isMatchContent] = GetCondition(content);
    if isMatchContent %whether content is exact match or just contains 
        setId = setId & ismember(dataTable.Content, content);
    else
        setId = setId & contains(lower(dataTable.Content), lower(content));
    end
end

if ~isempty(integrationTime)
    setId = setId & ismember(dataTable.IntegrationTime, integrationTime);
end

if ~isempty(target)
    [target, isMatchTarget] = GetCondition(target);
    if isMatchTarget
        setId = setId & ismember(dataTable.Target, target);
    else
        setId = setId & contains(lower(dataTable.Target), lower(target));
    end
end

if ~isempty(captureDate)
    setId = setId & ismember(dataTable.CaptureDate, str2double(captureDate));
end

if ~isempty(id)
    setId = setId & ismember(dataTable.ID, id);
end

if ~isempty(sampleId)
    setId = setId & ismember(dataTable.SampleID, sampleId);
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