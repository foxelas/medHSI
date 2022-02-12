function [Inorm, srgb] = GetAverageSpectraInROI(sampleId)
    %% REMOVELATER
    load(dataUtility.GetFilename('target', num2str(sampleId)), 'spectralData');
    Iin = spectralData;
    load(dataUtility.GetFilename('black', num2str(sampleId)), 'blackReflectance');
    Iblack = blackReflectance;
    load(dataUtility.GetFilename('white', num2str(sampleId)), 'fullReflectanceByPixel');
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
