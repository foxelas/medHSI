function [segmentMask] = SegmentLeonInternal(hsIm)

    filePath = commonUtility.GetFilename('dataset', 'LeonReference', 'mat');
    load(filePath, 'reflectances');
    n = numel(reflectances);

    signatures = hsIm.GetMaskedPixels();
    k = 7;
    [clusterLabels, ~] = kmeans(signatures, 7);

    segmentMask = zeros(size(hsIm.FgMask));
    for i = 1:7
       targetSignatures = signatures(clusterLabels == i, :);
       sumOfSam = zeros(n, 1);
       for j=1:n
           sumOfSam(j) = sum(sam(targetSignatures, reflectances(j).Signature));           
       end
       [~, minId] = min(sumOfSam);
       segmentMask(clusterLabels == i) = reflectances(minId).Label;
    end

end