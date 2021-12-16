
%% Plots Color Matching Functions
close all;

filename = fullfile(Config.GetRunBaseDir(), Config.GetSetting('paramDir'), 'displayParam.mat');

z = 401;
lambdaIn = HsiUtility.GetWavelengths(z, 'raw');
load(filename, 'illumination');

%% Plots Solax-iO illumination spectrum
figure(1);
plot(lambdaIn, illumination, 'DisplayName', 'Solax-iO');
Config.SetSetting('plotName', fullfile(Config.GetSetting('saveDir'), '1_Common', 'illumination'));
title('Illumination');
xlabel('Wavelength (nm)');
ylabel('Radiant Intensity (a.u.)');
legend();
Plots.SavePlot(1);