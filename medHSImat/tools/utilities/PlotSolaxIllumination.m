
%% Plots Color Matching Functions
close all;

filename = fullfile(config.GetRunBaseDir(), config.GetSetting('paramDir'), 'displayParam.mat');

z = 401;
lambdaIn = hsiUtility.GetWavelengths(z, 'raw');
load(filename, 'illumination');

%% Plots Solax-iO illumination spectrum
figure(1);
plot(lambdaIn, illumination, 'DisplayName', 'Solax-iO');
config.SetSetting('plotName', fullfile(config.GetSetting('saveDir'), '1_Common', 'illumination'));
title('Illumination');
xlabel('Wavelength (nm)');
ylabel('Radiant Intensity (a.u.)');
legend();
plots.SavePlot(1);