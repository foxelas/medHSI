% ======================================================================
%> @brief CustomKmeans applies kmeans clustering to an hsi and visualizes
%> the result.
%>
%> @b Usage
%>
%> @code
%> CustomKmeans(hsIm, 5);
%>
%> apply.ToEach(@CustomKmeans, 5);
%> @endcode
%>
%> @param hsIm [hsi] | An instance of the hsi class
%> @param clusterNum [int] | The number of clusters
%>
%> @retval labels [numeric array] | The cluster labels
% ======================================================================
function [labels] = CustomKmeans(hsIm, clusterNum)
% CustomKmeans applies kmeans clustering to an hsi and visualizes
% the result.
%
% @b Usage
%
% @code
% CustomKmeans(hsIm, 5);
%
% apply.ToEach(@CustomKmeans, 5);
% @endcode
%
% @param hsIm [hsi] | An instance of the hsi class
% @param clusterNum [int] | The number of clusters
%
% @retval labels [numeric array] | The cluster labels

srgb = hsIm.GetDisplayImage('rgb');
fgMask = hsIm.FgMask;

Xcol = hsIm.GetMaskedPixels(fgMask);
[labelsCol, C] = kmeans(Xcol, clusterNum);

labels = hsi.RecoverSpatialDimensions(labelsCol, size(fgMask), fgMask);

savedir = config.DirMake(config.GetSetting('saveDir'), config.GetSetting('experiment'), config.GetSetting('fileName'));
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