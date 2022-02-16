clear all;
close all;

%% Apply beautifier
basedir = fullfile(config.GetSetting('parentDir'), 'medHSI\');

subdirName = {'setup', 'tools', 'src'};
for j = 1:numel(subdirName)
    MBeautify.formatFiles(fullfile(basedir, 'medHSIma', subdirName{j}, '\'), '*.m');
    toolsdir = fullfile(basedir, 'medHSImat', subdirName{j});
    dirList = dir(toolsdir);
    for i = 3:numel(dirList)
        MBeautify.formatFiles(fullfile(toolsdir, dirList(i).name), '*.m');
    end
end
clear all;