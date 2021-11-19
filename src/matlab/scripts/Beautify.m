
%% Apply beautifier
basedir = fullfile(GetSetting('parentDir'), 'medHSI\');
MBeautify.formatFiles(fullfile(basedir, 'src\matlab\plots\'), '*.m')
MBeautify.formatFiles(fullfile(basedir, 'src\matlab\scripts\'), '*.m')
MBeautify.formatFiles(fullfile(basedir, 'src\matlab\methods\'), '*.m')

MBeautify.formatFiles(fullfile(basedir, 'tools\matlab\plots\'), '*.m')
MBeautify.formatFiles(fullfile(basedir, 'tools\matlab\methods\'), '*.m')