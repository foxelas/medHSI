
%% Setup
StartLogger;
experiment = 'handsOnly';
dataDate = '20201218';
%configuration = 'singleLightClose';
integrationTime = 200;
normalization = 'byPixel';

Initialization;

%% Read h5 data
[~, targetIDs, outRows] = Query([], {'hand', false});
integrationTimes = [outRows.IntegrationTime];
dates = [outRows.CaptureDate];
configurations = [outRows.Configuration];
for i = 1:length(targetIDs)
    target = GetValueFromTable(outRows, 'Target', i);
    content = GetValueFromTable(outRows, 'Content', i);
    SetSetting('integrationTime', integrationTimes(i));
    SetSetting('dataDate', num2str(dates(i)));
    SetSetting('configuration', configurations{i});
    [spectralData] = ReadHSIData(content, target, experiment);
end