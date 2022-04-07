% ======================================================================
%> @brief CustomKmeans applies kmeans clustering to an hsi and visualizes
%> the result.
%>
%> Need to set config::[SaveFolder] for image output.
%>
%> @b Usage
%>
%> @code
%> CustomKmeans(hsIm, [], 5);
%>
%> apply.ToEach(@CustomKmeans, 5);
%> @endcode
%>
%> @param hsIm [hsi] | An instance of the hsi class
%> @retval labels [numeric array] | The labels of the superpixels
%> @param clusterNum [int] | The number of clusters
%>
%> @retval labels [numeric array] | The cluster labels
% ======================================================================
function [labels] = CustomKmeans(hsIm, labelInfo, clusterNum)
% CustomKmeans applies kmeans clustering to an hsi and visualizes
% the result.
%
% Need to set config::[SaveFolder] for image output.
%
% @b Usage
%
% @code
% CustomKmeans(hsIm, [], 5);
%
% apply.ToEach(@CustomKmeans, 5);
% @endcode
%
% @param hsIm [hsi] | An instance of the hsi class
% @retval labels [numeric array] | The labels of the superpixels
% @param clusterNum [int] | The number of clusters
%
% @retval labels [numeric array] | The cluster labels
if nargin < 2
    labelInfo = [];
end

srgb = hsIm.GetDisplayImage();
fgMask = hsIm.FgMask;

Xcol = hsIm.GetMaskedPixels(fgMask);
[labelsCol, C] = kmeans(Xcol, clusterNum);

labels = hsi.RecoverSpatialDimensions(labelsCol, size(fgMask), fgMask);

savedir = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'), config.GetSetting('FileName')), '');
plots.Superpixels(1, fullfile(savedir, 'kmeans-clustering'), srgb, labels, '', 'color', fgMask);

names = cell(clusterNum, 1);
for i = 1:clusterNum
    names{i} = strcat('Centroid', num2str(i));
end

plots.Spectra(2, fullfile(savedir, 'kmeans-centroids'), C, hsiUtility.GetWavelengths(size(hsIm.Value, 3)), names, 'Kmeans centroids');

img = {srgb, labels};
names = {labelInfo.Diagnosis, 'Clustering'};
plotPath = fullfile(savedir, 'kmeans');
plots.MontageWithLabel(3, plotPath, img, names, labelInfo.Labels, hsIm.FgMask);

pause(0.5);
end