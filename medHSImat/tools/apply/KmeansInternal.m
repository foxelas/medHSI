function [labels] = KmeansInternal(hsIm, targetName, clusterNum)
%%KmeansClustering performs Kmeans clustering on the HSI
%
%   Usage:
%   labels = KmeansInternal(hsi, '158', 5);

srgb = hsIm.GetDisplayImage('rgb');
fgMask = hsIm.FgMask;

Xcol = hsIm.GetMaskedPixels(fgMask);
[labelsCol, C] = kmeans(Xcol, clusterNum);

labels = hsi.RecoverSpatialDimensions(labelsCol, size(fgMask), fgMask);

savedir = config.DirMake(config.GetSetting('saveDir'), config.GetSetting('experiment'), targetName);
config.SetSetting('plotName', fullfile(savedir, 'kmeans-clustering'));
plots.Superpixels(1, srgb, labels, '', 'color', fgMask);

names = cell(clusterNum, 1);
for i = 1:clusterNum
    names{i} = strcat('Centroid', num2str(i));
end
config.SetSetting('plotName', fullfile(savedir, 'kmeans-centroids'));
plots.Spectra(2, C, hsiUtility.GetWavelengths(size(hsIm.Value, 3)), names, 'Kmeans centroids');
ylim([0, 1]);
plots.SavePlot(2);
end