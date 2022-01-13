function [Inorm, srgb] = GetAverageSpectraInROI(sampleId)
load(strcat('D:\elena\mspi\matfiles\hsi\pslTriplets\', num2str(sampleId), '_target.mat'), 'spectralData');
Iin = spectralData;
load(strcat('D:\elena\mspi\matfiles\hsi\pslTriplets\', num2str(sampleId), '_black.mat'), 'blackReflectance');
Iblack = blackReflectance;
load(strcat('D:\elena\mspi\matfiles\hsi\pslTriplets\', num2str(sampleId), '_white.mat'), 'fullReflectanceByPixel');
Iwhite = fullReflectanceByPixel;

srgb = GetDisplayImageInternal(Iin);
denom = Iwhite - Iblack;
denom(denom <= 0) = 0.000000001;
Inorm = (Iin - Iblack) ./ denom;

close all;
fig = 1;
plots.NormalizationCheck(fig, Iin, Iblack, Iwhite, Inorm);
plots.SavePlot(fig);
end
