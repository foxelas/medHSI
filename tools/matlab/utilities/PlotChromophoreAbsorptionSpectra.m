function [extCoeffEumelanin2, extCoeffHbO, extCoeffHbR] = PlotChromophoreAbsorptionSpectra()
%%PlotChromophoreAbsorptionSpectra returns spectra for the main skin
%   chromophores
%
%   Usage:
%   [extCoeffEumelanin2, extCoeffHbO, extCoeffHbR] = PlotChromophoreAbsorptionSpectra();

importDir = config.GetSetting('importDir');
pheomelaninFilename = 'pheomelanin_absroption.csv';
eumelaninFilename = 'eumelanin_absroption.csv';
hbFilename = 'hb_absorption_spectra_prahl.csv';
eumelaninData = delimread(fullfile(importDir, eumelaninFilename), ',', 'num');
eumelaninData = eumelaninData.num;
hbData = delimread(fullfile(importDir, hbFilename), ',', 'num');
hbData = hbData.num;
pheomelaninData = delimread(fullfile(importDir, pheomelaninFilename), ',', 'num');
pheomelaninData = pheomelaninData.num;

eumelaninLambda = eumelaninData(:, 1);
% extCoeffEumelanin1 = eumelaninData(:, 2);
extCoeffEumelanin2 = eumelaninData(:, 3);

pheomelaninLambda = pheomelaninData(:, 1);
% extCoeffPheomelanin1 = pheomelaninData(:, 2);
extCoeffPheomelanin2 = pheomelaninData(:, 3);

% hbAmount = 150; %   A typical value of x for whole blood is x=150 g Hb/liter.
% convertHbfun = @(x) 2.303 * hbAmount * x / 64500;
hbLambda = hbData(:, 1);
extCoeffHbO = hbData(:, 2);
extCoeffHbR = hbData(:, 3);
% absCoeffHbO = convertHbfun(extCoeffHbO);
% absCoeffHbR = convertHbfun(extCoeffHbR);

% (moles/liter) = M

fig = figure(1);
clf;
hold on;
%plot(eumelaninLambda, extCoeffEumelanin1, 'DisplayName', 'Eumelanin1', 'LineWidth', 2); %cm-1 / (mg/ml)
plot(eumelaninLambda, extCoeffEumelanin2, 'DisplayName', 'Eumelanin', 'LineWidth', 2); %cm-1 / (moles/liter)
plot(pheomelaninLambda, extCoeffPheomelanin2, 'DisplayName', 'Pheomelanin', 'LineWidth', 2); %cm-1 / (moles/liter)
plot(hbLambda, extCoeffHbR, 'DisplayName', 'Hb', 'LineWidth', 2); %cm-1/M
plot(hbLambda, extCoeffHbO, 'DisplayName', 'HbO_2', 'LineWidth', 2); %cm-1/M

hold off
% xlim([300, 800]);
xlabel('Wavelength (nm)', 'FontSize', 15);
ylabel('Extinction Coefficient (cm^{-1}/ M)', 'FontSize', 15);
l = legend('Location', 'northeast');
l.FontSize = 13;

set(gca, 'yscale', 'log');
%set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0, 1, 1]);

% config.SetSetting('saveEps', false);
config.SetSetting('plotName', fullfile(config.GetSetting('outputDir'), config.GetSetting('common'), 'skinChromophoreExtinctionCoeff'));
plots.SavePlot(fig);

save(fullfile(config.GetSetting('paramDir'), 'extinctionCoefficients.mat'), 'extCoeffEumelanin2', 'extCoeffHbO', 'extCoeffHbR', 'eumelaninLambda', 'hbLambda');

end