function [segmentMask] = SegmentLeonInternal(hsIm)

    filePath = 'D:\temp\uni\mspi\matfiles\hsi\pslRaw\LeonReferences\LeonReferences.mat';

    load(filePath, 'references');
    r = numel(references);

    signatures = hsIm.GetMaskedPixels();
    k = 7;
    [clusterLabels, ~] = kmeans(signatures, 7);

    [m, n] = size(hsIm.FgMask);
    clusterLabelsImg = RecoverOriginalDimensionsInternal(clusterLabels, [m, n], hsIm.FgMask);

    segmentMask = zeros(m, n);
    for i = 1:k
       targetSignatures = signatures(clusterLabels == i, :);
       targetSignaturesImg = RecoverOriginalDimensionsInternal(targetSignatures, [m, n], clusterLabelsImg == i);

       sumOfSam = zeros(r, 1);
       for j=1:r
           sumOfSam(j) = sum(sam(targetSignaturesImg, references(j).Signature), "all");           
       end
       [~, minId] = min(sumOfSam);
       segmentMask(clusterLabelsImg == i) = references(minId).Label;
    end

    segmentMask = logical(segmentMask);
%     figure(1);
%     subplot(1,2,1);
%     imagesc(clusterLabelsImg)
%     subplot(1,2,2);
%     imagesc(segmentMask);
%    
end