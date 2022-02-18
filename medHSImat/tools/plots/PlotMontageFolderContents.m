function [] = PlotMontageFolderContents(path, criteria, figTitle, standardDim, imageLimit, fig)
% PlotMontageFolderContents returns the images in a path as a montage
%
%   Usage:
%   PlotMontageFolderContents(path, criteria, figTitle, standardDim, imageLimit, fig)
%
%   criteria = struct('TargetDir', 'subfolders', ...
%       'TargetName', strcat(target, '.jpg'), ...
%       'TargetType', 'fix');
%  plots.MontageFolderContents(1, [], criteria, [500, 500], 20);

if isempty(path)
    path = fullfile(config.GetSetting('saveDir'), config.GetSetting('experiment'));
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

if nargin < 4 || isempty(standardDim)
    standardDim = [200, 200];
end

if nargin < 5 || isempty(imageLimit)
    imageLimit = 20;
end
numrows = standardDim(1);
numcols = standardDim(2);

[pathstr, ~, ~] = fileparts(path);
isOneFolder = ~(isstruct(criteria) && strcmpi(criteria.TargetDir, 'subfolders'));
if ~isOneFolder
    target = criteria.TargetName;
    dirBase = path;
    fileList = dir(dirBase);
    dirFlags = [fileList.isdir];
    fileList = fileList(dirFlags);
    hasTargetType = isfield(criteria, 'TargetType');
    imageNum = numel(fileList) - 2;
    if imageNum > imageLimit
        imageNum = imageLimit + 2;
    end

    imageList = cell(imageNum, 1);
    if hasTargetType
        [targetIDs, ~] = databaseUtility.GetTargetIndexes([], criteria.TargetType);
        imageList = cell(numel(targetIDs), 1);
    end
    c = 1;
    for i = 3:imageNum
        if (hasTargetType & find(targetIDs == str2double(fileList(i).name))) | ~hasTargetType
            img = imread(fullfile(fileList(i).folder, fileList(i).name, strcat(target, '.jpg')));
            imageList{c} = imresize(img, [numrows, numcols]);
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
    imageNum = numel(fileList);
    if imageNum > imageLimit
        imageNum = imageLimit;
    end
    imageList = cell(numel(imageNum), 1);

    for i = 1:imageNum
        img = imread(fullfile(fileList(i).folder, fileList(i).name));
        imageList{i} = imresize(img, [numrows, numcols]);
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
config.SetSetting('plotName', fullfile(pathstr, strcat(lower(saveName), '.jpg')));
SavePlot(fig);
end