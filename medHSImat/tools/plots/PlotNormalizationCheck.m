function PlotNormalizationCheck(Iin, Iblack, Iwhite, Inorm, fig)
%%PlotNormalizationCheck plots the values recovered after normalization
%   user needs to input a mask
%
%   Usage:
%   PlotsNormalizationCheck(Iin, Iblack, Iwhite, Inorm, fig)
%   plots.NormalizationCheck(fig, Iin, Iblack, Iwhite, Inorm)

%Need to draw mask
mask = Iin.GetCustomMask();
Iin_mask = Iin.GetMaskedPixels(mask);
Iblack_mask = GetMaskedPixelsInternal(Iblack, mask);
Iwhite_mask = GetMaskedPixelsInternal(Iwhite, mask);
Inorm_mask = Inorm.GetMaskedPixels(mask);
x = hsiUtility.GetWavelengths(size(Iin_mask, 2));

close all;
figure(fig);
clf;
hold on;
plot(x, mean(reshape(Iwhite_mask, [size(Iwhite_mask, 1), size(Iwhite_mask, 2)])), 'DisplayName', 'Average White', 'LineWidth', 2);
plot(x, mean(reshape(Iblack_mask, [size(Iblack_mask, 1), size(Iblack_mask, 2)])), 'DisplayName', 'Average Black', 'LineWidth', 2);
plot(x, mean(reshape(Iin_mask, [size(Iin_mask, 1), size(Iin_mask, 2)])), 'DisplayName', 'Average Tissue', 'LineWidth', 2);

plot(x, min(reshape(Iwhite_mask, [size(Iwhite_mask, 1), size(Iwhite_mask, 2)])), 'DisplayName', 'Min White', 'LineWidth', 2);
plot(x, min(reshape(Iblack_mask, [size(Iblack_mask, 1), size(Iblack_mask, 2)])), 'DisplayName', 'Min Black', 'LineWidth', 2);
plot(x, min(reshape(Iin_mask, [size(Iin_mask, 1), size(Iin_mask, 2)])), 'DisplayName', 'Min Tissue', 'LineWidth', 2);

minVal = min(Iwhite_mask(:)-Iblack_mask(:));
fids = find((Iwhite_mask(:) - Iblack_mask(:)) == minVal);
[row, col] = ind2sub(size(Iwhite_mask), fids(1));
ws = hsiUtility.GetWavelengths(401, 'raw');

hold off; legend;
fprintf('Min(I_w - I_b) is %.5f at row (pixel) %d and column %d (wavelength %d). \n', minVal, row, col, ws(col));
fprintf('If minVal is negative and wavelenth is at the extreme, then it is discarded later as noise. \n');
xlabel('Wavelength (nm)', 'FontSize', 15);
ylabel('Reflectance (a.u.)', 'FontSize', 15);

figure(fig+1);
clf;
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

fig3 = figure(fig+2);
rgb = Iin.GetDisplayImage();
plots.Overlay(fig3, rgb, mask);

baseFolder = config.DirMake(config.GetSetting('outputDir'), config.GetSetting('normCheck'), config.GetSetting('fileName'));
config.SetSetting('plotName', strcat(baseFolder, '_raw.jpg'));
plots.SavePlot(fig);
config.SetSetting('plotName', strcat(baseFolder, '_norm.jpg'));
plots.SavePlot(fig+1);
config.SetSetting('plotName', strcat(baseFolder, '_mask.jpg'));
plots.SavePlot(fig3);

close all;
end