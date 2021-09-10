
%% Starts the logger and closes figures
close all;
clc;
diary off
if exist(GetSetting('logDir'), 'file') > 0
    delete(GetSetting('logDir'))
end
diary(GetSetting('logDir'))

disp('Starts log in output\log.txt');
datestr(now);