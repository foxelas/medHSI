%======================================================================
%> @brief PlotSpectra plots multiple spectra together.
%>
%> @b Usage
%>
%> @code
%> plots.Spectra(fig, spectra, wavelengths, names, figTitle, markers);
%>
%> plots.Spectra(fig, spectra);
%>
%> PlotSpectra(spectra, wavelengths, names, figTitle, markers, fig);
%> @endcode
%>
%> @param fig [int] | The figure handle
%> @param spectra [numeric array] | The input vectors
%> @param wavelengths [numeric array] | The wavlength values
%> @param names [cell array] | The curve names
%> @param figTitle [char] | The figure title
%> @param markers [cell array] | The curve markers
%======================================================================
function [] = PlotSpectra(spectra, wavelengths, names, figTitle, markers, fig)

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
    ylim([0, 1]);
end


%%To disable showing exponent power on the corner
ax = gca;
ax.YAxis.Exponent = 0;

% fig = gcf;
% fig.WindowState = 'maximized';

plots.SavePlot(fig);

end