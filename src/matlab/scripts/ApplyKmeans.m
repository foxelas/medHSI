function [labels] = ApplyKmeans(hsi, targetName, clusterNum)
%%ApplyKmeans performs Kmeans clustering on the HSI
%
%   Usage:
%   labels = ApplyKmeans(hsi, '158', 5);

srgb = GetDisplayImage(hsi, 'rgb');
fgMask = GetFgMask(srgb);

Xcol = GetPixelsFromMask(hsi, fgMask);
[labelsCol, C] = kmeans(Xcol, clusterNum);

labels = RecoverReducedHsi(labelsCol, size(fgMask), fgMask);

savedir = DirMake(GetSetting('saveDir'), GetSetting('experiment'), targetName);
SetSetting('plotName', fullfile(savedir, 'kmeans-clustering'));
Plots(1, @PlotSuperpixels, srgb, labels, '', 'color', fgMask);

names = cell(clusterNum, 1);
for i = 1:clusterNum
    names{i} = strcat('Centroid', num2str(i));
end
SetSetting('plotName', fullfile(savedir, 'kmeans-centroids'));
Plots(2, @PlotSpectra, C, GetWavelengths(size(hsi, 3)), names, 'Kmeans centroids');
ylim([0, 0.001]);
SavePlot(2);
end