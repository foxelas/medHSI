% ======================================================================
%> @brief SAMAndShow applies SAM-based segmentation to an hsi and plots image results.
%>
%> Need to set config::[SaveFolder] for image output.
%>
%> @b Usage
%>
%> @code
%> segment.ApplyAndShow('SAM', 'healthy', 13);
%>
%> prediction = SAMAndShow(hsIm, labelInfo, 'healthy', 13);
%> @endcode
%>
%> @param hsIm [hsi] | An instance of the hsi class
%> @param labelInfo [hsiInfo] | An instance of the hsiInfo class
%> @param option [char] | Optional: The option for application. Options: ['library', 'healthy']. Default: 'library'.
%> @param threshold [double] | Optional: The threshold. Required when 'option' is 'healthy'. Default: 15.
%>
%> @retval prediction [numeric array] | The predicted labels
% ======================================================================
function [prediction] = SAMAndShow(hsIm, labelInfo, option, threshold)
% SAMAndShow applies SAM-based segmentation to an hsi and plots image results.
%
% Need to set config::[SaveFolder] for image output.
%
% @b Usage
%
% @code
% segment.ApplyAndShow('SAM', 'healthy', 13);
%
% prediction = SAMAndShow(hsIm, labelInfo, 'healthy', 13);
% @endcode
%
% @param hsIm [hsi] | An instance of the hsi class
% @param labelInfo [hsiInfo] | An instance of the hsiInfo class
% @param option [char] | Optional: The option for application. Options: ['library', 'healthy']. Default: 'library'.
% @param threshold [double] | Optional: The threshold. Required when 'option' is 'healthy'. Default: 15.
%
% @retval prediction [numeric array] | The predicted labels

if nargin < 3
    option = 'library';
end

if nargin < 4
    threshold = 15;
end

[prediction, scoreImg, argminImg] = SegmentSAM(hsIm, option, threshold);

hasLabels = ~isempty(labelInfo);

if strcmpi(option, 'library')

    figure(1);
    clf;
    % subplot 3
    subplot(2, 2, 3);
    imshow(double(prediction));
    hold on;
    h(1) = scatter([], [], 1, 'k', 'filled', 'DisplayName', 'Benign');
    h(2) = scatter([], [], 1, 'k', 'o', 'DisplayName', 'Malignant');
    hold off;
    legend(h, 'Location', 'northeast');
    title('SAM-based segmentation');

    % subplot 1
    subplot(2, 2, 1);
    imagesc(scoreImg, [0, 1]);
    c = colorbar(gca, 'Ticks', [0, 0.2, 0.4, 0.6, 0.8, 1], ...
        'TickLabels', {'Min', '0.2', '0.4', '0.6', '0.8', 'Max'});
    title('Minimum SAM value');
    axis equal
    axis off;

    % subplot 2
    subplot(2, 2, 2);
    imagesc(argminImg);
    un_X = [0:4]; % unique(argminImg);
    colormap(gca, jet(length(un_X)));
    b = colorbar(gca);
    set(b, 'ytick', un_X);
    colorbar('Ticks', [0, 1, 2, 3, 4], ...
        'TickLabels', {'0', '1', '2', '3', '4'});
    title('Argmin SAM value');
    axis equal
    axis off;

    if hasLabels
        % subplot 4
        subplot(2, 2, 4);
        [ssimval, ~] = ssim(prediction, uint8(labelInfo.Labels));
        imshowpair(prediction, labelInfo.Labels, 'Scaling', 'joint');
        title(sprintf('SSIM: %.5f', ssimval));
    end

else

    figure(1);
    clf;

    % subplot 1
    subplot(1, 2, 1);
    imagesc(scoreImg);
    c = colorbar(gca);
    title('SAM value');
    axis equal
    axis off;

    if hasLabels
        % subplot 2
        subplot(1, 2, 2);
        [ssimval, ~] = ssim(prediction, uint8(labelInfo.Labels));
        imshowpair(prediction, labelInfo.Labels, 'Scaling', 'joint');
        title(sprintf('SSIM: %.5f', ssimval));
    end

end

plotPath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'), hsIm.ID, strcat('sam_', hsIm.ID)), 'png');
plots.SavePlot(1, plotPath);

if hasLabels
    jac = commonUtility.Jaccard(prediction, labelInfo.Labels);
    plotPath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'), hsIm.ID, 'predLabel'), 'png');
    figTitle = {labelInfo.Diagnosis; sprintf('jac:%.2f%%', jac*100)};
    plots.Pair(2, plotPath, prediction, labelInfo.Labels, figTitle);

    img = {hsIm.GetDisplayImage(), argminImg};
    names = {strjoin({'SampleID: ', hsIm.SampleID}, {' '}), 'Argmin SAM'};
    plotPath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'), hsIm.ID, 'sam_grouping'), 'png');
    plots.MontageWithLabel(3, plotPath, img, names, labelInfo.Labels, hsIm.FgMask);
end

end