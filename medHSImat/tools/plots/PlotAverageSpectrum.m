%======================================================================
%> @brief PlotAverageSpectrum plots average spectra using a promt for custom mask selection.
%>
%> Need to set config::[SaveFolder] for saving purposes.
%>
%> @b Usage
%>
%> @code
%> config.SetSetting([SaveFolder], 'Spectra-Example');
%> plots.AverageSpectrum(fig, hsIm, figTitle);
%> @endcode
%>
%> @param fig [int] | The figure handle
%> @param hsIm [hsi] | An instance of the hsi class
%> @param figTitle [char] | The figure title
%======================================================================
function PlotAverageSpectrum(hsIm, hsImInfo, fig)
% PlotAverageSpectrum plots average spectra using a promt for custom mask selection.
%
% Need to set config::[SaveFolder] for saving purposes.
%
% @b Usage
%
% @code
% config.SetSetting([SaveFolder], 'Spectra-Example');
% plots.AverageSpectrum(fig, hsIm, figTitle);
% @endcode
%
% @param fig [int] | The figure handle
% @param hsIm [hsi] | An instance of the hsi class
% @param figTitle [char] | The figure title

maskROI = logical(hsImInfo.Labels) & hsIm.FgMask;
maskNonROI = ~logical(hsImInfo.Labels) & hsIm.FgMask;

InormROI = hsIm.GetMaskedPixels(maskROI);
x = hsiUtility.GetWavelengths(size(InormROI, 2));
rgb = hsIm.GetDisplayImage();

close all;
fig = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1]);

subplot(1, 3, 1:2);
hold on
InormNonROI = hsIm.GetMaskedPixels(maskNonROI);
for i = 1:size(InormNonROI, 1)
    plot(x, InormNonROI(i, :), 'b');
end

for i = 1:size(InormROI, 1)
    plot(x, InormROI(i, :), 'g');
end

h(1) = plot(x, mean(reshape(InormROI, [size(InormROI, 1), size(InormROI, 2)])), 'r--', 'DisplayName', 'Lesion', 'LineWidth', 3);
h(2) = plot(x, mean(reshape(InormNonROI, [size(InormNonROI, 1), size(InormNonROI, 2)])), 'm--', 'DisplayName', 'Healthy', 'LineWidth', 3);
hold off
xlabel('Wavelength (nm)', 'FontSize', 15);
ylabel('Reflectance (a.u.)', 'FontSize', 15);

ylim([0, 1]);
xlim([420, 750]);
legend(h, 'Location', 'northwest', 'FontSize', 15);

%%To disable showing exponent power on the corner
ax = gca;
ax.YAxis.Exponent = 0;

subplot(1, 3, 3);
figTitle = hsImInfo.Diagnosis;
imshow(rgb);
title(figTitle);

plotPath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'), strcat(config.GetSetting('FileName'), '_values')), 'png');
plots.SavePlot(fig, plotPath);

end