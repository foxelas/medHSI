% ======================================================================
%> @brief CustomKmeans applies kmeans clustering to an hsi and visualizes
%> the result.
%>
%> Need to set config::[saveFolder] for image output.
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
% Need to set config::[saveFolder] for image output.
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

savedir = commonUtility.GetFilename('output', fullfile(config.GetSetting('saveFolder'), config.GetSetting('fileName')), '');
plots.Superpixels(1, fullfile(savedir, 'kmeans-clustering'), srgb, labels, '', 'color', fgMask);

names = cell(clusterNum, 1);
for i = 1:clusterNum
    names{i} = strcat('Centroid', num2str(i));
end

plots.Spectra(2, fullfile(savedir, 'kmeans-centroids'), C, hsiUtility.GetWavelengths(size(hsIm.Value, 3)), names, 'Kmeans centroids');

end