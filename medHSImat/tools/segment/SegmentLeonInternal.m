function [segmentMask] = SegmentLeonInternal(hsIm, labelInfo)

if nargin < 2 
    labelInfo = [];
end

filePath = commonUtility.GetFilename('dataset', fullfile('LeonReferences', 'LeonReferences'));

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
    for j = 1:r
        sumOfSam(j) = sum(sam(targetSignaturesImg, references(j).Signature), "all");
    end
    [~, minId] = min(sumOfSam);
    segmentMask(clusterLabelsImg == i) = references(minId).Label;
end

segmentMask = logical(segmentMask);

srgb = hsIm.GetDisplayImage();
fgMask = hsIm.FgMask;
savedir = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'), config.GetSetting('FileName')), '');
plots.Superpixels(1, fullfile(savedir, 'clusters'), srgb, clusterLabelsImg, '', 'color', fgMask);


srgb = hsIm.GetDisplayImage();
fgMask = hsIm.FgMask;
savedir = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'), config.GetSetting('FileName')), '');
plots.Superpixels(2, fullfile(savedir, 'leon'), srgb, segmentMask, '', 'color', fgMask);

end