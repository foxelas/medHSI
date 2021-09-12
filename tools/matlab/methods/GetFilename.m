function [filename, tableId, outRow] = GetFilename(content, sampleId, captureDate, id, integrationTime, target, configuration, specialTarget)

%% GetFilename Gets the respective filename for configuration value
%   arguments are received in the order of
%     'content' [type of captured object]
%     'sampleId' [number value for sample id]
%     'captureDate' [captureDate for object]
%     'id' [number value for id ]
%     'integrationTime' [value of integration time]
%     'target' [details about captured object]
%     'configuration' [light source]
%
%   Usage:
%   [filename, tableId, outRow] = GetFilename(content, sampleId,
%   captureDate, id, integrationTime, target, configuration, specialTarget)

if nargin < 8
    specialTarget = '';
end

if ~isempty(integrationTime)
    initialIntegrationTime = integrationTime;
end

[~, ~, outRow] = Query(content, sampleId, captureDate, id, integrationTime, target, configuration);
outRow = CheckOutRow(outRow, content, sampleId, captureDate, id, integrationTime, target, configuration, specialTarget);

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

function [outR] = CheckOutRow(inR, content, sampleId, captureDate, id, integrationTime, target, configuration, specialTarget)
outR = inR;
if isempty(inR.ID) && ~isempty(specialTarget)
    if strcmp(specialTarget, 'black')
        configuration = 'noLight';
    end
    [~, ~, outR] = Query(content, sampleId, captureDate, id, integrationTime, target, configuration);
    if isempty(outR.ID) && strcmp(specialTarget, 'black')
        [~, ~, outR] = Query('capOn', sampleId, '20210107', id, integrationTime, target, configuration);
    end
end

if numel(outR.ID) > 1
    warning('Taking the first from multiple rows that satisfy the conditions.');
    outR = outR(1, :);
end
end