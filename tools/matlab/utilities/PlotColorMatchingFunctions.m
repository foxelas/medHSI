
%% Plots Color Matching Functions
close all;

filename = fullfile(Config.GetRunBaseDir(), Config.GetSetting('paramDir'), 'displayParam.mat');

z = 401;
lambdaIn = HsiUtility.GetWavelengths(z, 'raw');
load(filename, 'xyz');

%% Plots XYZ curve
figure(1);
hold on
plot(lambdaIn, xyz(:, 1), 'DisplayName', 'x');
plot(lambdaIn, xyz(:, 2), 'DisplayName', 'y');
plot(lambdaIn, xyz(:, 3), 'DisplayName', 'z');
hold off
legend();
Config.SetSetting('plotName', fullfile(Config.GetSetting('saveDir'), '1_Common', 'interpColorMatchingFunctions'));
title('Interpolated Color Matching Functions');
xlabel('Wavelength (nm)');
ylabel('Weight (a.u.)');
Plots.SavePlot(1);
