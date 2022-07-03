% ======================================================================
%> @brief KmeansAndShow applies Kmeans-based segmentation to an hsi and plots image results.
%>
%> Need to set config::[SaveFolder] for image output.
%>
%> @b Usage
%>
%> @code
%> segment.ApplyAndShow('Kmeans', 5);
%>
%> prediction = KmeansAndShow(hsIm, labelInfo, 5);
%> @endcode
%>
%> @param hsIm [hsi] | An instance of the hsi class
%> @param labelInfo [hsiInfo] | An instance of the hsiInfo class
%> @param clusters [int] | The number of clusters
%>
%> @retval prediction [numeric array] | The predicted labels
% ======================================================================
function [prediction] = KmeansAndShow(hsIm, labelInfo, clusters)


[prediction, centroids] = SegmentKmeans(hsIm, clusters);

hasLabels = ~isempty(labelInfo);

srgb = hsIm.GetDisplayImage();
fgMask = hsIm.FgMask;

savedir = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'), config.GetSetting('FileName')), '');
plots.Superpixels(1, fullfile(savedir, 'kmeans-clustering'), srgb, prediction, '', 'color', fgMask);

names = cell(clusterNum, 1);
for i = 1:clusterNum
    names{i} = strcat('Centroid', num2str(i));
end
plots.Spectra(2, fullfile(savedir, 'kmeans-centroids'), centroids, hsiUtility.GetWavelengths(size(hsIm.Value, 3)), names, 'Kmeans centroids');

if hasLabels
    img = {srgb, prediction};
    names = {labelInfo.Diagnosis, 'Clustering'};
    plotPath = fullfile(savedir, 'kmeans');
    plots.MontageWithLabel(3, plotPath, img, names, labelInfo.Labels, hsIm.FgMask);
end

pause(0.5);

end