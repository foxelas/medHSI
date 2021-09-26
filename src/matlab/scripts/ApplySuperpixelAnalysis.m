%% Apply superpixel analysis on HSI 
% prequisites: hsi

sNum = 20; 

%% Preparation 
srgb = GetDisplayImage(hsi, 'rgb');
fgMask = ~(squeeze(srgb(:, :, 1)) == 0 & squeeze(srgb(:, :, 1)) == 0 & squeeze(srgb(:, :, 1)) == 0);

%% Apply PCA to entire image 
[coeff, scores, latent, explained, ~] = DimredHSI(hsi, 'pca', 3, fgMask);
explained(1:3)
latent(1:3)

%% Calculate superpixels
% Use the 1st PCA component for superpixel calculation
redImage = rescale(squeeze(scores(:, :, 1)));
[labels, ~] = superpixels(redImage, sNum);

Plots(1, @PlotSuperpixels, srgb, labels);
PlotComponents(scores, 3, 2);
Plots(5, @PlotSuperpixels, srgb, labels, '', 'color', fgMask);

%% Keep only specimen superpixels 
Xcol = GetPixelsFromMask(hsi, fgMask);
v = labels(fgMask);
a = unique(v);
counts = histc(v(:), a);
specimenSuperpixelIds = a(counts > 300)';

%% Plot eigenvectors 
Plots(6, @PlotEigenvectors, coeff, 420:730, 3);
for i = specimenSuperpixelIds
    superpixelMask = labels == i;
    Xcol = GetPixelsFromMask(hsi, superpixelMask);
    coeff = pca(Xcol, 'NumComponents', 3);
    Plots(6, @PlotEigenvectors, coeff, 420:730, 3);
    title(strcat('Eigenvectors for Superpixel #', num2str(i)));
    pause(0.5);
end

%% Plot statistics 
statistic = 'covariance';
Plots(7, @PlotBandStatistics, Xcol, statistic);
for i = specimenSuperpixelIds
    superpixelMask = labels == i;
    Xcol = GetPixelsFromMask(hsi, superpixelMask);
    Plots(7, @PlotBandStatistics, Xcol, statistic);
    title(strcat('Covariance for Superpixel #', num2str(i)));
    pause(0.5);
end

