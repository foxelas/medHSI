%======================================================================
%> @brief PlotAverageSpectrum plots average spectra using a promt for custom mask selection.
%>
%> Need to set config::'saveFolder' for saving purposes.
%>
%> @b Usage
%>
%> @code
%> config.SetSetting('saveFolder', 'Spectra-Example');
%> plots.AverageSpectrum(fig, hsIm, figTitle);
%> @endcode
%>
%> @param fig [int] | The figure handle
%> @param hsIm [hsi] | An instance of the hsi class
%> @param figTitle [char] | The figure title
%======================================================================
function PlotAverageSpectrum(hsIm, figTitle, fig)
% PlotAverageSpectrum plots average spectra using a promt for custom mask selection.
%
% Need to set config::'saveFolder' for saving purposes.
%
% @b Usage
%
% @code
% config.SetSetting('saveFolder', 'Spectra-Example');
% plots.AverageSpectrum(fig, hsIm, figTitle);
% @endcode
%
% @param fig [int] | The figure handle
% @param hsIm [hsi] | An instance of the hsi class
% @param figTitle [char] | The figure title

% Draw mask
mask = hsIm.GetCustomMask();
Inorm_mask = hsIm.GetMaskedPixels(mask);
x = hsiUtility.GetWavelengths(size(Inorm_mask, 2));
rgb = hsIm.GetDisplayImage();

close all;
fig = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1]);

subplot(1, 3, 1:2);
hold on
for i = 1:size(Inorm_mask, 1)
    plot(x, Inorm_mask(i, :), 'g');
end
h = plot(x, mean(reshape(Inorm_mask, [size(Inorm_mask, 1), size(Inorm_mask, 2)])), 'DisplayName', 'Average Normalized', 'LineWidth', 3);
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
imshow(rgb);
title(figTitle);

baseFolder = commonUtility.GetFilename('output', fullfile(config.GetSetting('saveFolder'), config.GetSetting('fileName')), '');
plots.SavePlot(fig, strcat(baseFolder, '_norm.jpg'));

fig2 = figure;
plots.Overlay(fig2, strcat(baseFolder, '_mask.jpg'), rgb, mask);

end