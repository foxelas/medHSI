function [] = PlotSpectra(spectra, wavelengths, names, figTitle, fig)
%%PLOTSPECTRA plots one or more spectra together
%
%   Usage:
%   PlotSpectra(spectra, wavelengths, names, figTitle, fig);
%   PlotSpectra(spectra)

[~, n] = size(spectra);
if isempty(wavelengths)
    wavelengths = hsiUtility.GetWavelengths(n);
end

if isempty(names)
    names = [];
end

if ~iscell(names)
    names = {names};
end

if isempty(figTitle)
    figTitle = 'Calculated Spectra';
end

lineColorMap = plots.GetLineColorMap('custom', names);
key = keys(lineColorMap);

hold on
for i = 1:length(names)
    h(i) = plot(wavelengths, spectra(i, :), 'DisplayName', key{i}, 'Color', lineColorMap(key{i}), 'LineWidth', 3);
end
hold off

legend(h, 'Location', 'northwest', 'FontSize', 15)
xlabel('Wavelength (nm)', 'FontSize', 15);
ylabel('Reflectance (a.u.)', 'FontSize', 15);
title(figTitle)

%%For hsi case only
ylim([0, 5 * 10^(-3)]);

%%To disable showing exponent power on the corner
ax = gca;
ax.YAxis.Exponent = 0;

plots.SavePlot(fig);

end