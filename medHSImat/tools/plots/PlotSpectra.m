function [] = PlotSpectra(spectra, wavelengths, names, figTitle, markers, fig)
%%PLOTSPECTRA plots one or more spectra together
%
%   Usage:
%   PlotSpectra(spectra, wavelengths, names, figTitle, markers, fig);
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

if isempty(markers)
    markers = cellfun(@(x) "-", names); 
end

hold on
for i = 1:length(names)
    h(i) = plot(wavelengths, spectra(i, :), 'DisplayName', names{i}, ...
        'Color', lineColorMap(names{i}), 'LineWidth', 3, 'LineStyle', markers{i});
end
hold off

legend(h, 'Location', 'northwest', 'FontSize', 15)
xlabel('Wavelength (nm)', 'FontSize', 15);
ylabel('Reflectance (a.u.)', 'FontSize', 15);
title(figTitle)

% datamin = min(spectra(:));
datamax = max(spectra(:));

if datamax < 0.1
    ylim([0, 5 * 10^(-3)]);
else
    ylim([0,1]);
end
    

%%To disable showing exponent power on the corner
ax = gca;
ax.YAxis.Exponent = 0;

plots.SavePlot(fig);

end