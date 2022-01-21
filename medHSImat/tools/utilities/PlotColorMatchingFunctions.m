
%% Plots Color Matching Functions
close all;

filename = fullfile(config.GetRunBaseDir(), config.GetSetting('paramDir'), 'displayParam.mat');

z = 401;
lambdaIn = hsiUtility.GetWavelengths(z, 'raw');
load(filename, 'xyz');

%% Plots XYZ curve
figure(1);
hold on
plot(lambdaIn, xyz(:, 1), 'DisplayName', 'x');
plot(lambdaIn, xyz(:, 2), 'DisplayName', 'y');
plot(lambdaIn, xyz(:, 3), 'DisplayName', 'z');
hold off
legend();
config.SetSetting('plotName', fullfile(config.GetSetting('saveDir'), '1_Common', 'interpColorMatchingFunctions'));
title('Interpolated Color Matching Functions');
xlabel('Wavelength (nm)');
ylabel('Weight (a.u.)');
plots.SavePlot(1);
