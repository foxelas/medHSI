function [] = MontageFolderContents(path, criteria, figTitle, fig)
% MontageFolderContents returns the images in a path as a montage
%
%   Usage:
%   MontageFolderContents(path, criteria, figTitle, fig)
%
%   criteria = struct('TargetDir', 'subfolders', ...
%       'TargetName', strcat(target, '.jpg'), ...
%       'TargetType', 'fix');
%   Plots(1, @MontageFolderContents, [], criteria);

if isempty(path)
    path = fullfile(GetSetting('saveDir'), GetSetting('experiment'));
end

if nargin < 2
    criteria = [];
end

if isempty(criteria)
    criteria = '*.jpg';
end

if nargin < 3
    figTitle = [];
end

[pathstr, ~, ~] = fileparts(path);
isOneFolder = ~(isstruct(criteria) && strcmpi(criteria.TargetDir, 'subfolders'));
if ~isOneFolder
    target = criteria.TargetName;
    dirBase = path;
    fileList = dir(dirBase);
    dirFlags = [fileList.isdir];
    fileList = fileList(dirFlags);
    hasTargetType = isfield(criteria, 'TargetType');
    imageList = cell(numel(fileList)-2, 1);
    if hasTargetType
        [targetIDs, ~] = GetTargetIndexes([], criteria.TargetType);
        imageList = cell(numel(targetIDs), 1);
    end
    c = 1;
    for i = 3:numel(fileList)
        if (hasTargetType & find(targetIDs == str2double(fileList(i).name)) ) | ~hasTargetType
            imageList{c} = imread(fullfile(fileList(i).folder, fileList(i).name, strcat(target, '.jpg')));
            c = c + 1;
        end 
    end
    if ~isempty(figTitle) 
        saveName = figTitle;
    else
        saveName = target;
    end
    pathstr = path;
    
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

% imageList = imageList(1:end-2);

r = ceil(numel(imageList)/4);
montage(imageList, 'Size', [r, 4]);
if ~isempty(figTitle)
    title(strrep(figTitle, '_', ' '));
end

%save in parent dir 
SetSetting('plotName', fullfile(pathstr, strcat(lower(saveName), '.jpg')));
SavePlot(fig);
end