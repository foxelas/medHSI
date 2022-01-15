
%% Setup
config.SetOpt();
config.SetSetting('integrationTime', 200);
config.SetSetting('normalization', 'byPixel');
config.SetSetting('dataDate', 20201218);
config.SetSetting('experiment', 'handsOnly');
config.SetSetting('database', 'calib');

config.SetSetting('saveFolder', fullfile('medHsi', config.GetSetting('experiment')));

StartLogger;

%% Read h5 data
experiment = config.GetSetting('experiment');
[~, targetIDs, outRows] = databaseUtility.Query({'hand', false});
integrationTimes = [outRows.IntegrationTime];
dates = [outRows.CaptureDate];
configurations = [outRows.configuration];
for i = 1:length(targetIDs)
    target = dataUtility.GetValueFromTable(outRows, 'Target', i);
    content = dataUtility.GetValueFromTable(outRows, 'Content', i);
    config.SetSetting('integrationTime', integrationTimes(i));
    config.SetSetting('dataDate', num2str(dates(i)));
    config.SetSetting('configuration', configurations{i});
    [spectralData] = hsiUtility.ReadHSIData(content, target, experiment);

end

EndLogger;