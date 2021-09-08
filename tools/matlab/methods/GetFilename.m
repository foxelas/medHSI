function [filename, tableId, outRow] = GetFilename(configuration, content, integrationTime, target, dataDate, id, specialTarget)

%% GetFilename Gets the respective filename for configuration value
%   arguments are received in the order of
%     'configuration' [light source]
%     'content' [type of catpured object]
%     'integrationTime' [value of integration time]
%     'target' [details about captured object]
%     'dataDate' [catpureDate]
%     'id' [number value for id ]
%
%   Usage:
%   [filename, tableId, outRow] = GetFilename(configuration, content,
%       integrationTime, target, dataDate, id, specialTarget)

if nargin < 6
    id = [];
end

if ~isempty(id) && id < 0
    id = [];
end

if nargin < 7
    specialTarget = '';
end

if ~isempty(integrationTime)
    initialIntegrationTime = integrationTime;
end

[~, ~, outRow] = Query(configuration, content, integrationTime, target, dataDate, id);
outRow = CheckOutRow(outRow, configuration, content, integrationTime, specialTarget, dataDate, id);

filename = outRow.Filename{1};
tableId = outRow.ID;

if outRow.IntegrationTime ~= initialIntegrationTime
    setSetting('integrationTime', integrationTime);
end

if nargin >= 3 && ~isempty(integrationTime) && integrationTime ~= outRow.IntegrationTime
    warning('Integration time in the settings and in the retrieved file differs.');
    %     setSetting('integrationTime', integrationTime);
end

end

function [outR] = CheckOutRow(inR, configuration, content, integrationTime, specialTarget, dataDate, id)
outR = inR;
if isempty(inR.ID) && ~isempty(specialTarget)
    if strcmp(specialTarget, 'black')
        configuration = 'noLight';
    end
    [~, ~, outR] = Query(configuration, content, integrationTime, specialTarget, dataDate, id);
    if isempty(outR.ID) && strcmp(specialTarget, 'black')
        [~, ~, outR] = Query(configuration, 'capOn', integrationTime, specialTarget, '20210107', id);
    end
end

if numel(outR.ID) > 1
    warning('Taking the first from multiple rows that satisfy the conditions.');
    outR = outR(1, :);
end
end