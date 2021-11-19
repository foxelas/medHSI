function [] = MontageFolderContents(path, criteria, figTitle, fig)
% MontageFolderContents returns the images in a path as a montage
%
%   Usage:
%   MontageFolderContents(path, criteria, figTitle, fig)
%
%   criteria = struct('TargetDir', 'subfolders', 'TargetName', strcat(target, '.jpg'));
%   Plots(1, @MontageFolderContents, [], criteria);

if isempty(path)
    path = fullfile(GetSetting('saveDir'), GetSetting('experiment'));
end

if nargin < 2
    criteria = [];
end

if isempty(criteria)
    criteria = '*';
end

if nargin < 3
    figTitle = [];
end


isOneFolder = ~(isstruct(criteria) && strcmpi(criteria.TargetDir, 'subfolders'));
if ~isOneFolder
    target = criteria.TargetName;
    dirBase = path;
    fileList = dir(dirBase);
    dirFlags = [fileList.isdir];
    fileList = fileList(dirFlags);
    imageList = cell(numel(fileList)-2, 1);
    for i = 3:numel(fileList)
        imageList{i-2} = imread(fullfile(fileList(i).folder, fileList(i).name, target));
    end
    saveName = target;
else
    if isstruct(criteria) && strcmpi(criteria.TargetDir, 'currentFolder')
        target = criteria.TargetName;
    elseif ~isstruct(criteria)
        target = criteria;
    end
    pathCriteria = fullfile(path, target);

    fileList = dir(pathCriteria);
    imageList = cell(numel(fileList), 1);
    for i = 1:numel(fileList)
        imageList{i} = imread(fullfile(fileList(i).folder, fileList(i).name));
    end
    saveName = figTitle;
end


r = ceil(numel(imageList)/4);
montage(imageList, 'Size', [r, 4]);
if ~isempty(figTitle)
    title(figTitle);
end

%save in parent dir 
[pathstr, ~, ~] = fileparts(path);
SetSetting('plotName', fullfile(pathstr, strcat(lower(saveName), '.jpg')));
SavePlot(fig);
end