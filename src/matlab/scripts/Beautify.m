clear all;
close all;

%% Apply beautifier
basedir = fullfile(config.GetSetting('parentDir'), 'medHSI\');
MBeautify.formatFiles(fullfile(basedir, 'src\matlab\plots\'), '*.m');
MBeautify.formatFiles(fullfile(basedir, 'src\matlab\scripts\'), '*.m');
MBeautify.formatFiles(fullfile(basedir, 'src\matlab\methods\'), '*.m');

toolsdir = fullfile(basedir, 'tools\matlab\');
dirList = dir(toolsdir);
for i = 3:numel(dirList)
    MBeautify.formatFiles(fullfile(toolsdir, dirList(i).name), '*.m');
end

clear all;