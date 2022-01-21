function [] = SuperpixelAnalysisInternal(hsIm, targetName, isManual, pixelNum, pcNum)
%%SuperpixelAnalysis applies SuperPCA on an image
%
%   Usage:
%   SuperpixelAnalysisInternal(hsi, targetName);
%
%   ApplyScriptToEachImage(@SuperpixelAnalysis);

%% Apply superpixel analysis on HSI
% prequisites: hsi, targetName

if nargin < 3
    isManual = false;
end

if nargin < 4
    pixelNum = 20;
end

if nargin < 5
    pcNum = 3;
end
savedir = config.DirMake(config.GetSetting('saveDir'), config.GetSetting('experiment'), targetName);

%% Preparation
srgb = hsIm.GetDisplayImage('rgb');
fgMask = GetFgMaskInternal(srgb);

%% Calculate superpixels
if isManual
    %%Apply PCA to entire image
    [coeff, scores, latent, explained, ~] = hsIm.Dimred('pca', pcNum, fgMask);
    explained(1:pcNum);
    latent(1:pcNum);

    % Use the 1st PCA component for superpixel calculation
    redImage = rescale(squeeze(scores(:, :, 1)));
    [labels, ~] = superpixels(redImage, pixelNum);
else
    %%super-pixels segmentation
    labels = hsIm.Cubseg(pixelNum);

    %%SupePCA based DR
    scores = hsIm.SPCA(pcNum, labels);
end

config.SetSetting('plotName', fullfile(savedir, 'superpixel_segments'));
plots.Superpixels(1, srgb, labels);
config.SetSetting('plotName', fullfile(savedir, 'superpixel_mask'));
plots.Superpixels(2, srgb, labels, '', 'color', fgMask);
config.SetSetting('plotName', fullfile(savedir, 'pc'));
plots.Components(scores, pcNum, 3);

pause(0.5);

%% Keep only specimen superpixels
Xcol = hsIm.GetPixelsFromMask(fgMask);
v = labels(fgMask);
a = unique(v);
counts = histc(v(:), a);
specimenSuperpixelIds = a(counts > 300)';

%% Plot eigenvectors
numComp = 3;
wavelengths = hsiUtility.GetWavelengths(size(Xcol, 2));
basename = fullfile(savedir, 'eigenvectors');
config.SetSetting('plotName', basename);
coeff = Dimred(Xcol, 'pca', numComp);
plots.Eigenvectors(6, coeff, wavelengths, numComp);
for i = specimenSuperpixelIds
    superpixelMask = labels == i;
    Xcol = hsIm.GetPixelsFromMask(superpixelMask);
    coeff = Dimred(Xcol, 'pca', numComp);
    config.SetSetting('plotName', strcat(basename, num2str(i)));
    plots.Eigenvectors(6, coeff, wavelengths, numComp);
    title(strcat('Eigenvectors for Superpixel #', num2str(i)));
    plots.SavePlot(6);
    pause(0.5);
end

%% Plot statistics
statistic = 'covariance';
basename = fullfile(savedir, statistic);
config.SetSetting('plotName', basename);
plots.BandStatistics(7, Xcol, statistic);

for i = specimenSuperpixelIds
    superpixelMask = labels == i;
    Xcol = hsIm.GetPixelsFromMask(superpixelMask);
    config.SetSetting('plotName', strcat(basename, num2str(i)));
    plots.BandStatistics(7, Xcol, statistic);
    title(strcat('Covariance for Superpixel #', num2str(i)));
    plots.SavePlot(7);
    pause(0.5);
end

end
