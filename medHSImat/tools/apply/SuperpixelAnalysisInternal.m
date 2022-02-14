function [scores] = SuperpixelAnalysisInternal(hsIm, targetName, isManual, pixelNum, pcNum)
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
fgMask = hsIm.FgMask;

%% Calculate superpixels
if isManual
    %%Apply PCA to entire image
    [coeff, scores, latent, explained, ~] = hsIm.Dimred('pca', pcNum, fgMask);
    explained(1:pcNum);
    latent(1:pcNum);

    % Use the 1st PCA component for superpixel calculation
    redImage = rescale(squeeze(scores(:, :, 1)));
    [labels, ~] = superpixels(redImage, pixelNum);
    
    % Keep only pixels that belong to the tissue (Superpixel might assign
    % background pixels also). The last label is background label.
    [labels, validLabels] = CleanLabels(labels, fgMask, pixelNum);

else
    %%super-pixels segmentation
    labels = hsIm.Cubseg(pixelNum);
    
    % Keep only pixels that belong to the tissue (Superpixel might assign
    % background pixels also). The last label is background label.
    [labels, validLabels] = CleanLabels(labels, fgMask, pixelNum);

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

%% Plot eigenvectors
numComp = 3;

Xcol = hsIm.GetMaskedPixels(fgMask);
wavelengths = hsiUtility.GetWavelengths(size(Xcol, 2));
basename = fullfile(savedir, 'eigenvectors');
config.SetSetting('plotName', basename);
coeff = Dimred(Xcol, 'pca', numComp);
plots.Eigenvectors(6, coeff, wavelengths, numComp);
for i = validLabels
    superpixelMask = labels == i;
    Xcol = hsIm.GetMaskedPixels(superpixelMask);
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

for i = validLabels
    superpixelMask = labels == i;
    Xcol = hsIm.GetMaskedPixels(superpixelMask);
    config.SetSetting('plotName', strcat(basename, num2str(i)));
    plots.BandStatistics(7, Xcol, statistic);
    title(strcat('Covariance for Superpixel #', num2str(i)));
    plots.SavePlot(7);
    pause(0.5);   
end

end

function [cleanLabels, validLabels] = CleanLabels(labels, fgMask, pixelNum)
% Keep only pixels that belong to the tissue (Superpixel might assign
% background pixels also). The last label is background label.
labels(~fgMask) = pixelNum;
        
pixelLim = 10;
labelTags = unique(labels)';
labelTags = labelTags(labelTags ~= pixelNum); % Remove last label (background pixels)
validLabels = [];
k = 0;

for i = labelTags
    sumPixel = sum(labels == i, 'all');
    if sumPixel < pixelLim %Ignore superpixel labels with too few pixels
        labels(labels == i) = pixelNum;
    else
        k = k + 1;
        validLabels(k) = i;
    end
end

cleanLabels = labels;
end
