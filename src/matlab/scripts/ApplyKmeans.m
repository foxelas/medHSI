function [labels] = ApplyKmeans(hsIm, targetName, clusterNum)
%%ApplyKmeans performs Kmeans clustering on the HSI
%
%   Usage:
%   labels = ApplyKmeans(hsi, '158', 5);

srgb = hsIm.GetDisplayImage('rgb');
fgMask = GetFgMaskInternal(srgb);

Xcol = hsIm.GetPixelsFromMask(fgMask);
[labelsCol, C] = kmeans(Xcol, clusterNum);

labels = HsiUtility.RecoverReducedHsi(labelsCol, size(fgMask), fgMask);

savedir = Config.DirMake(Config.GetSetting('saveDir'), Config.GetSetting('experiment'), targetName);
Config.SetSetting('plotName', fullfile(savedir, 'kmeans-clustering'));
Plots.Superpixels(1, srgb, labels, '', 'color', fgMask);

names = cell(clusterNum, 1);
for i = 1:clusterNum
    names{i} = strcat('Centroid', num2str(i));
end
Config.SetSetting('plotName', fullfile(savedir, 'kmeans-centroids'));
Plots.Spectra(2, C, GetWavelengths(size(hsIm.Value, 3)), names, 'Kmeans centroids');
ylim([0, 0.001]);
Plots.SavePlot(2);
end