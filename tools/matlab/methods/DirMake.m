function [filepath] = DirMake(varargin)
%     DirMake creates a new directory
%
%     Usage:
%     [filepath] = DirMake(filepath)

if nargin == 1
    filepath = varargin{1};
else
    filepath = fullfile(varargin{:});
end
fileDir = fileparts(filepath);
if ~exist(fileDir, 'dir')
    mkdir(fileDir);
    if ~contains(fileDir, GetSetting('saveDir'))
        addpath(fileDir);
    end
end
end