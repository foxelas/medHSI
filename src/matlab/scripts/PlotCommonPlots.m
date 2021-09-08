
%% Plots some basic plots
close all;

%% Plots XYZ curve
figure(1);
hold on
plot(lambdaIn, xyz(:, 1), 'DisplayName', 'x');
plot(lambdaIn, xyz(:, 2), 'DisplayName', 'y');
plot(lambdaIn, xyz(:, 3), 'DisplayName', 'z');
hold off
legend();
SetSetting('plotName', fullfile(GetSetting('saveDir'), '1_Common', 'interpColorMatchingFunctions'));
title('Interpolated Color Matching Functions');
xlabel('Wavelength (nm)');
ylabel('Weight (a.u.)');
SavePlot(1);

%% Plots Solax-iO illumination spectrum
figure(2);
plot(lambdaIn, illumination, 'DisplayName', 'Solax-iO');
SetSetting('plotName', fullfile(GetSetting('saveDir'), '1_Common', 'illumination'));
title('Illumination');
xlabel('Wavelength (nm)');
ylabel('Radiant Intensity (a.u.)');
legend();
SavePlot(2);
