function [solaxSpec, wavelengths] = GetSolaxSpectra(method, showImage)
%%GETSOLAXSPECTRA reconstructs values for Solax-IO illumination
%
%   Usage:
%   illum = GetSolaxSpectra();
%   illum = GetSolaxSpectra('reconstructed');

if nargin < 1
    method = 'real';
end
if nargin < 2
    showImage = false;
end

switch method
    case 'real'
        settingsDir = config.GetSetting('importDir');
        inTable = delimread(fullfile(settingsDir, 'LE-9ND55F.csv'), ',', 'num');
        wavelengths = inTable.num(:, 1);
        solaxSpec = inTable.num(:, 2);
        sunSpec = inTable.num(:, 3);

        if showImage
            PlotSolaxSpectra(wavelengths, solaxSpec, sunSpec);
        end

    case 'reconstructed'
        saveDir = config.GetSetting('saveDir');
        [solaxSpec, wavelengths] = ReconstructSolaxIoIlluminationSpectrum(saveDir);
    otherwise
        error('Unsupported case for solax-io spectra reconstruction');
end

end

function [solaxSpec, x] = ReconstructSolaxIoIlluminationSpectrum(saveDir)
%saveDir = "D:\temp\Google Drive\titech\research\experiments\output\5. Progress Reports\img";

x = [350, 360, 370, 380, 400, 410, 425, 450, 460, 480, 520, 525, 530, 575, 620, 625, 630, 640, 660, 690, 695, 700, 725, 750, 800]';
y = [0, 0, 0, 0, 20, 63, 40, 82, 80, 58, 80.5, 79.5, 80, 68, 73, 72, 73, 70, 60, 39.5, 40, 30, 15, 9, 0]';

f1 = fit(x, y, 'linearinterp');
options = fitoptions('Method', 'SmoothingSpline', ...
    'SmoothingParam', 0.1);
f2 = fit(x, y, 'smoothingspline', options);

fig1 = figure(1);
plot(x, y, 'x', 'MarkerEdgeColor', 'black')
hold on
%plot(x, v)
plot(f1, x, y)
hold off
grid on;
xlabel('Wavelength (nm)', 'FontSize', 15);
ylabel('Relative Spectrum (%)', 'FontSize', 15)
title('Using [linearinterp] fitting', 'FontSize', 15)

fig2 = figure(2);
plot(x, y, 'x', 'MarkerEdgeColor', 'black')
hold on
%plot(x, v)
plot(f2, x, y)
hold off
grid on;
xlabel('Wavelength (nm)', 'FontSize', 15);
ylabel('Relative Spectrum (%)', 'FontSize', 15)
title('Using [smoothingspline] fitting', 'FontSize', 15)

config.SetSetting('cropBorders', true);
config.SetSetting('plotName', fullfile(saveDir, 'solaxSpectrum_lininterp.png'));
plots.SavePlot(fig1);

config.SetSetting('plotName', fullfile(saveDir, 'solaxSpectrum_spline.png'));
plots.SavePlot(fig2);

wavelengths = [380:780]';
solaxSpec = f2(wavelengths);
solaxSpec = max(solaxSpec, 0);

fig3 = figure(3);
x = wavelengths;
TF = islocalmax(solaxSpec);
solaxLocalMaxWavelengths = double(x(TF));
plot(x, solaxSpec, x(TF), solaxSpec(TF), 'r*', 'LineWidth', 5);
ylim([0, 100]);
xlabel('Wavelength (nm)', 'FontSize', 15);
ylabel('Relative Illumination Spectrum (%)', 'FontSize', 15);
title('For Solax-iO light source', 'FontSize', 15);
config.SetSetting('plotName', fullfile(saveDir, 'solaxSpectrum_reconstructed.png'));
plots.SavePlot(fig3);

save('parameters/solax_reconstructed_spectrum.mat', 'solaxSpec', 'solaxLocalMaxWavelengths');

end


function [] = PlotSolaxSpectra(wavelengths, solaxSpec, sunSpec)

saveDir = config.GetSetting('saveDir');

fig4 = figure(4);
x = wavelengths;
h(1) = plot(x, solaxSpec, 'r', 'LineWidth', 3, 'DisplayName', 'Solax-iO');
hold on
h(2) = plot(x, sunSpec, 'b', 'LineWidth', 3, 'DisplayName', 'Sun');
hold off
ylim([0, 100]);
xlabel('Wavelength (nm)', 'FontSize', 15);
ylabel('Relative Illumination Spectrum (%)', 'FontSize', 15);
title('For Solax-iO light source', 'FontSize', 15);
legend(h, 'Location', 'northeast', 'FontSize', 15);
config.SetSetting('plotName', fullfile(saveDir, 'solaxSpectrum_reconstructed.png'));
plots.SavePlot(fig4);

end