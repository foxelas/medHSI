
%% Setup
Config.SetOpt();
Config.SetSetting('integrationTime', 200);
Config.SetSetting('normalization', 'byPixel');
Config.SetSetting('dataDate', 20201218);
Config.SetSetting('experiment', 'handsOnly');
Config.SetSetting('database', 'calib');

Config.SetSetting('saveFolder', fullfile('medHsi', Config.GetSetting('experiment')));

StartLogger;

%% Read h5 data
experiment = Config.GetSetting('experiment');
[~, targetIDs, outRows] = DB.Query({'hand', false});
integrationTimes = [outRows.IntegrationTime];
dates = [outRows.CaptureDate];
configurations = [outRows.Configuration];
for i = 1:length(targetIDs)
    target = DataUtility.GetValueFromTable(outRows, 'Target', i);
    content = DataUtility.GetValueFromTable(outRows, 'Content', i);
    Config.SetSetting('integrationTime', integrationTimes(i));
    Config.SetSetting('dataDate', num2str(dates(i)));
    Config.SetSetting('configuration', configurations{i});
    [spectralData] = HsiUtility.ReadHSIData(content, target, experiment);

end

EndLogger;