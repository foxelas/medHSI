
%% Starts the logger and closes figures
close all;
clc;
diary off
if exist(Config.GetSetting('logDir'), 'file') > 0
    delete(Config.GetSetting('logDir'))
end
diary(Config.GetSetting('logDir'))

disp('Starts log in output\log.txt');
datestr(now);