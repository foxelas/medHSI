function [] = MontageFolderContents(path, criteria, figTitle, fig)
% MontageFolderContents returns the images in a path as a montage
%
%   Usage:
%   MontageFolderContents(path, criteria, figTitle, fig)

if ~isempty(path)
    pathCriteria = fullfile(path, criteria);
else
    pathCriteria = fullfile(path, '*');
end
fileList = dir(pathCriteria);
imageList = cell(numel(fileList), 1);
for i = 1:numel(fileList)
    imageList{i} = imread(fullfile(fileList(i).folder, fileList(i).name));
end

montage(imageList);
title(figTitle);

SetSetting('plotName', fullfile(path, strcat(lower(figTitle), '.jpg')));
savePlot(fig);
end