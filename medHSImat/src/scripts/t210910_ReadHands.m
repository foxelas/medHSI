
%% Setup
config.SetOpt();
config.SetSetting('IntegrationTime', 200);
config.SetSetting('Normalization', 'byPixel');
config.SetSetting('DataDate', 20201218);
config.SetSetting('Experiment', 'handsOnly');
config.SetSetting('Database', 'calib');

config.SetSetting('SaveFolder', fullfile('medHsi', config.GetSetting('Experiment')));

StartLogger;

%% Read h5 data
experiment = config.GetSetting('Experiment');
[~, targetIDs, outRows] = databaseUtility.Query({'hand', false});
integrationTimes = [outRows.IntegrationTime];
dates = [outRows.CaptureDate];
configurations = [outRows.Configuration];
for i = 1:length(targetIDs)
    target = dataUtility.GetValueFromTable(outRows, 'Target', i);
    content = dataUtility.GetValueFromTable(outRows, 'Content', i);
    config.SetSetting('IntegrationTime', integrationTimes(i));
    config.SetSetting('DataDate', num2str(dates(i)));
    config.SetSetting('Configuration', configurations{i});
    [spectralData] = hsiUtility.ReadHSI(content, target, experiment);

end

EndLogger;