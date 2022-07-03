% ======================================================================
%> @brief LeonAndShow applies applies Kmeans-based segmentation to an hsi and plots image results.
%>
%> Proposed by Leon et al (2020).
%>
%> Need to set config::[SaveFolder] for image output.
%>
%> @b Usage
%>
%> @code
%> segment.ApplyAndShow('Leon');
%>
%> prediction = LeonAndShow(hsIm, labelInfo);
%> @endcode
%>
%> @param hsIm [hsi] | An instance of the hsi class
%> @param labelInfo [hsiInfo] | An instance of the hsiInfo class
%>
%> @retval prediction [numeric array] | The predicted labels
% ======================================================================
function [prediction] = LeonAndShow(hsIm, labelInfo)

prediction = SegmentLeon(hsIm);

hasLabels = ~isempty(labelInfo);

srgb = hsIm.GetDisplayImage();
fgMask = hsIm.FgMask;
savedir = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'), config.GetSetting('FileName')), '');
plots.Superpixels(1, fullfile(savedir, 'clusters'), srgb, clusterLabelsImg, '', 'color', fgMask);


srgb = hsIm.GetDisplayImage();
fgMask = hsIm.FgMask;
plots.Superpixels(2, fullfile(savedir, 'leon'), srgb, prediction, '', 'color', fgMask);

if hasLabels
    jac = commonUtility.Jaccard(prediction, labelInfo.Labels);
    figTitle = {labelInfo.Diagnosis; sprintf('jac:%.2f%%', jac*100)};
    plots.Pair(3, fullfile(savedir, 'predLabel'), prediction, labelInfo.Labels, figTitle);
end

end