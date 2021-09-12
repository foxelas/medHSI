function [] = FindSuperpixelAutocorrelation(hsi, sNum)
% FindSuperpixelAutocorrelation returns the autocorrelation among hsi bands per superpixel
%
%   Usage:
%   [] = FindSuperpixelAutocorrelation(hsi, 10);

srgb = GetDisplayImage(hsi, 'rgb');
fgMask = ~(squeeze(srgb(:, :, 1)) == 0 & squeeze(srgb(:, :, 1)) == 0 & squeeze(srgb(:, :, 1)) == 0);
[coeff, scores, latent, explained, ~] = DimredHSI(hsi, 'pca', 3, fgMask);
explained(1:3)
latent(1:3)

% Use the 1st PCA component for superpixel calculation
redImage = rescale(squeeze(scores(:, :, 1)));
[L, N] = superpixels(redImage, sNum);

Plots(1, @PlotSuperpixels, srgb, L);

figure(2);
imagesc(squeeze(scores(:, :, 1)));
title('PC1');
figure(3);
imagesc(squeeze(scores(:, :, 2)));
title('PC2');
figure(4);
imagesc(squeeze(scores(:, :, 3)));
title('PC3');

v = L(fgMask);
a = unique(v);
counts = histc(v(:), a);
specimenSuperpixelIds = a(counts > 300)';

figure(5);
B = labeloverlay(srgb, L, 'IncludedLabels', specimenSuperpixelIds);
imshow(B);

figure(6);
Xcol = GetPixelsFromMask(hsi, fgMask);
imCorr = PlotBandCorrelation(Xcol, 6);

for i = specimenSuperpixelIds
    superpixelMask = L == i;
    Xcol = GetPixelsFromMask(hsi, superpixelMask);
    imCorr = PlotBandCorrelation(Xcol, 6);
    pause(0.5);
end

end