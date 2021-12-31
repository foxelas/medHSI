function [] = PlotSpectraAverage(spectra, wavelengths, figTitle, fig)
%%PlotSpectraAverage plots average spectra
%
%   Usage:
%   PlotSpectraAverage(spectra, wavelengths, figTitle, fig);
%   PlotSpectraAverage(spectra)

[~, n] = size(spectra);
if isempty(wavelengths)
    wavelengths = hsiUtility.GetWavelengths(n);
end

hold on
for i = 1:size(spectra, 1)
    plot(wavelengths, spectra(i, :)./divBy, 'g');
end
avg = mean(spectrumCurves);
h = plot(wavelengths, avg./divBy, 'b*', 'DisplayName', 'Mean', 'LineWidth', 2);
hold off

xlabel('Wavelength (nm)', 'FontSize', 15);
ylabel('Reflectance (a.u.)', 'FontSize', 15);
if ~isempty(figTitle)
    title(figTitle)
end
legend(h, 'Location', 'northwest', 'FontSize', 15);

ylim([0, 1]);
xlim([420, 750]);

%%To disable showing exponent power on the corner
ax = gca;
ax.YAxis.Exponent = 0;

plots.SavePlot(fig);

end