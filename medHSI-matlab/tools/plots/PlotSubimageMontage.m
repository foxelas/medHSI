function [] = PlotSubimageMontage(hsi, figTitle, limit, fig)
% PlotSubimageMontage plots all or selected members of an hsi
% as a montage figure
%
%   Usage:
%   PlotSubimageMontage(hsi, figTitle, limit, fig);

if nargin < 3
    limit = size(hsi, 3);
end

if isempty(limit)
    limit = size(hsi, 3);
end

imageList = cell(limit, 1);
for i = 1:limit
    imageList{i} = squeeze(hsi(:, :, i));
end

montage(imageList)
title(figTitle);
colorbar();
colormap('jet');

SavePlot(fig);
end