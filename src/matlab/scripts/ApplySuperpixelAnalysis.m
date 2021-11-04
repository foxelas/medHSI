%% Apply superpixel analysis on HSI 
% prequisites: hsi, targetName

isManual = false;
savedir = DirMake(GetSetting('saveDir'), GetSetting('experiment'), targetName);

numPixel = 20; 
pcNum = 3;

%% Preparation 
srgb = GetDisplayImage(hsi, 'rgb');
fgMask = GetFgMask(srgb);

%% Calculate superpixels
if isManual
    %%Apply PCA to entire image 
    [coeff, scores, latent, explained, ~] = DimredHSI(hsi, 'pca', pcNum, fgMask);
    explained(1:pcNum);
    latent(1:pcNum);

    % Use the 1st PCA component for superpixel calculation
    redImage = rescale(squeeze(scores(:, :, 1)));
    [labels, ~] = superpixels(redImage, numPixel);
else
    %%super-pixels segmentation
    labels = cubseg(hsi,numPixel);

    %%SupePCA based DR
    scores = SuperPCA(hsi,pcNum,labels);
end 

SetSetting('plotName', fullfile(savedir, 'superpixel_segments'));
Plots(1, @PlotSuperpixels, srgb, labels);
SetSetting('plotName', fullfile(savedir, 'superpixel_mask'));
Plots(2, @PlotSuperpixels, srgb, labels, '', 'color', fgMask);
SetSetting('plotName', fullfile(savedir, 'pc'));
PlotComponents(scores, pcNum, 3);
    
pause(0.5);

%% Keep only specimen superpixels 
Xcol = GetPixelsFromMask(hsi, fgMask);
v = labels(fgMask);
a = unique(v);
counts = histc(v(:), a);
specimenSuperpixelIds = a(counts > 300)';

%% Plot eigenvectors 
basename = fullfile(savedir, 'eigenvector');
SetSetting('plotName', basename);
Plots(6, @PlotEigenvectors, coeff, 420:730, 3);
for i = specimenSuperpixelIds
    superpixelMask = labels == i;
    Xcol = GetPixelsFromMask(hsi, superpixelMask);
    coeff = pca(Xcol, 'NumComponents', 3);
    SetSetting('plotName', strcat(basename, num2str(i)));
    Plots(6, @PlotEigenvectors, coeff, 420:730, 3);
    title(strcat('Eigenvectors for Superpixel #', num2str(i)));
    SavePlot(6);
    pause(0.5);
end

%% Plot statistics 
statistic = 'covariance';
basename = fullfile(savedir, statistic);
SetSetting('plotName', basename);
Plots(7, @PlotBandStatistics, Xcol, statistic);

for i = specimenSuperpixelIds
    superpixelMask = labels == i;
    Xcol = GetPixelsFromMask(hsi, superpixelMask);
    SetSetting('plotName', strcat(basename, num2str(i)));
    Plots(7, @PlotBandStatistics, Xcol, statistic);
    title(strcat('Covariance for Superpixel #', num2str(i)));
    SavePlot(7);
    pause(0.5);
end

