% ======================================================================
%> @brief SegmentLeon applies Kmeans-based segmentation to an hsi.
%>
%> Proposed by Leon et al (2020).
%> Leon, R., Martinez-Vega, B., Fabelo, H., Ortega, S., Melian, V., Castaño, I., Carretero, G., Almeida, P., Garcia, A., Quevedo, E., Hernandez, J. A., Clavo, B., & M. Callico, G. (2020). Non-Invasive Skin Cancer Diagnosis Using Hyperspectral Imaging for In-Situ Clinical Support. Journal of Clinical Medicine, 9(6), 1662. https://doi.org/10.3390/jcm9061662
%>
%> @b Usage
%>
%> @code
%> [prediction] = segment.Apply(hsIm, 'Leon');
%>
%> [prediction] = SegmentLeon(hsIm);
%> @endcode
%>
%> @param hsIm [hsi] | An instance of the hsi class
%>
%> @retval prediction [numeric array] | The predicted labels
% ======================================================================
function [prediction] = SegmentLeon(hsIm)

filePath = commonUtility.GetFilename('dataset', fullfile('LeonReferences', 'LeonReferences'));

load(filePath, 'references');
r = numel(references);

signatures = hsIm.GetMaskedPixels();
clusters = 7;
[clusterLabels, ~] = kmeans(signatures, 7);

[m, n] = size(hsIm.FgMask);
clusterLabelsImg = RecoverOriginalDimensionsInternal(clusterLabels, [m, n], hsIm.FgMask);

prediction = zeros(m, n);
for i = 1:clusters
    targetSignatures = signatures(clusterLabels == i, :);
    targetSignaturesImg = RecoverOriginalDimensionsInternal(targetSignatures, [m, n], clusterLabelsImg == i);

    sumOfSam = zeros(r, 1);
    for j = 1:r
        sumOfSam(j) = sum(sam(targetSignaturesImg, references(j).Signature), "all");
    end
    [~, minId] = min(sumOfSam);
    prediction(clusterLabelsImg == i) = references(minId).Label;
end

prediction = logical(prediction);
end