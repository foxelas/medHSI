% ======================================================================
%> @brief SAMAnalysis applies SAM-based segmentation to an hsi and visualizes
%> the result.
%>
%> Need to set config::[saveFolder] for image output.
%>
%> @b Usage
%>
%> @code
%> SAMAnalysis(hsIm, labelInfo);
%>
%> apply.ToEach(@SAMAnalysis);
%> @endcode
%>
%> @param hsIm [hsi] | An instance of the hsi class
%> @param labelInfo [hsiInfo] | An instance of the  hsiInfo class
%>
%> @retval predImg [numeric array] | The predicted labels
% ======================================================================
function [predImg] = SAMAnalysis(hsIm, labelInfo)
% SAMAnalysis applies SAM-based segmentation to an hsi and visualizes
% the result.
%
% Need to set config::[saveFolder] for image output.
%
% @b Usage
%
% @code
% SAMAnalysis(hsIm, labelInfo);
%
% apply.ToEach(@SAMAnalysis);
% @endcode
%
% @param hsIm [hsi] | An instance of the hsi class
% @param labelInfo [hsiInfo] | An instance of the  hsiInfo class
%
% @retval predImg [numeric array] | The predicted labels

[scoreImg, predImg, argminImg] = hsIm.SAMscore();

figure(1);
clf;
% subplot 3
subplot(2, 2, 3);
imshow(double(predImg));
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

% subplot 4
subplot(2, 2, 4);
[ssimval, ~] = ssim(predImg, labelInfo.Labels);
imshowpair(predImg, labelInfo.Labels, 'Scaling', 'joint');
title(sprintf('SSIM: %.5f', ssimval));

plotPath = commonUtility.GetFilename('output', fullfile(config.GetSetting('saveFolder'), hsIm.ID, strcat('sam_', hsIm.ID)), 'jpg');
plots.SavePlot(1, plotPath);

plotPath = commonUtility.GetFilename('output', fullfile(config.GetSetting('saveFolder'), hsIm.ID, 'predLabel'), 'jpg');
figTitle = sprintf('ID:%s', hsIm.ID);
plots.Pair(2, plotPath, predImg, labelInfo.Labels, figTitle);

end