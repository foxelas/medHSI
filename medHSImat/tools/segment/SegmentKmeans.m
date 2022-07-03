% ======================================================================
%> @brief SegmentKmeans applies Kmeans-based segmentation to an hsi.
%>
%> @b Usage
%>
%> @code
%> [prediction, centroids] = segment.Apply(hsIm, 'Kmeans', 5);
%>
%> [prediction, centroids] = SegmentKmeans(hsIm, 5);
%> @endcode
%>
%> @param hsIm [hsi] | An instance of the hsi class
%> @param clusters [int] | The number of clusters
%>
%> @retval prediction [numeric array] | The predicted labels
%> @retval centroids [numeric array] | The cluster centroids
% ======================================================================
function [prediction, centroids] = SegmentKmeans(hsIm, clusters)
fgMask = hsIm.FgMask;
Xcol = hsIm.GetMaskedPixels(fgMask);
[labelsCol, centroids] = kmeans(Xcol, clusters);
prediction = hsi.RecoverSpatialDimensions(labelsCol, size(fgMask), fgMask);
end
