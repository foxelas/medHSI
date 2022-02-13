function PlotAverageSpectrum(Inorm, fig)
%%PlotAverageSpectrum plots the values recovered after normalization
%   user needs to input a mask
%
%   Usage:
%   PlotsNormalizationCheck(Inorm, fig)
%   plots.NormalizationCheck(fig, Inorm)

%Need to draw mask
mask = Inorm.GetCustomMask();
Inorm_mask = Inorm.GetMaskedPixels(mask);
x = hsiUtility.GetWavelengths(size(Inorm_mask, 2));

close all;
figure(fig);

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

fig2 = figure(fig+1);
rgb = Inorm.GetDisplayImage();
plots.Overlay(fig2, rgb, mask);

baseFolder = config.DirMake(config.GetSetting('saveDir'), config.GetSetting('normCheck'), config.GetSetting('fileName'));
config.SetSetting('plotName', strcat(baseFolder, '_norm.jpg'));
plots.SavePlot(fig);
config.SetSetting('plotName', strcat(baseFolder, '_mask.jpg'));
plots.SavePlot(fig2);

end