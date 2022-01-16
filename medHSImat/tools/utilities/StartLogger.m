
%% Starts the logger and closes figures
close all;
clc;
diary off
if exist(config.GetSetting('logDir'), 'file') > 0
    delete(config.GetSetting('logDir'))
end
diary(config.GetSetting('logDir'))

disp('Starts log in output\log.txt');
datestr(now);