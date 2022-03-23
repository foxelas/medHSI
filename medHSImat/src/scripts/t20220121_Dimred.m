%Date: 2022-01-21
clc;
close all;

% Need to copy .mat mask files from output\T20220122-Dimred\ to
% output\T20220123-Dimred\
config.SetSetting('experiment', 'T20220123-Dimred');

wavelengths = hsiUtility.GetWavelengths(311);
labeldir = config.DirMake(config.GetSetting('matDir'), strcat(config.GetSetting('database'), config.GetSetting('labelsName'), '\'));
imgadedir = config.DirMake(config.GetSetting('matDir'), strcat(config.GetSetting('database'), config.GetSetting('normalizedName'), '\'));

%%%%%%%%%%%%%%%%%%%%%%%% Read all %%%%%%%%%%%%%%%%%%%%%%

folds = 5;
testingSamples = [5];
numSamples = 6;
content = {'tissue', true};
target = 'raw';
[~, X, y, Xtest, ytest, ~, ~] = trainUtility.PrepareSpectralDataset(folds, testingSamples, numSamples, content, target, false);
X = [X; Xtest];

%%%%%%%%%%%%%%%%%%%%%%%% RAW %%%%%%%%%%%%%%%%%%%%%%

[targetIDs, outRows] = databaseUtility.GetTargetIndexes({'tissue', true}, 'raw');

i = 6;
id = targetIDs(i);
targetName = num2str(id);
I = hsiUtility.LoadHSI(targetName, 'dataset');
imgFilename = fullfile(config.GetSetting('outputDir'), config.GetSetting('experiment'), strcat(targetName, '.png'));
load(strrep(imgFilename, '.png', '.mat'), 'fgMask');

Xcol = I.GetMaskedPixels(fgMask);

q = 3;
[coeff1, ~, latentFull, explainedFull, ~] = Dimred(Xcol, 'PCA', q);
explainedFull(1:3)
[coeff2, ~, latentFull, explainedFull, ~] = Dimred(X, 'PCA', q);
explainedFull(1:3)
[scores3, labels, validLabels] = SuperpixelAnalysisInternal(I, targetName, false, 10, q);
mask3 = labels == validLabels(6);
X3 = I.GetMaskedPixels(mask3);
[coeff3, ~, latentFull, explainedFull, ~] = Dimred(X3, 'PCA', q);
explainedFull(1:3)

%%%%%%%%%%%%%%%%%%%%%%%%%%% Fig 1: Dimred with different training %%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all;

fig = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1]);

subplot(1, 3, 1);
PlotEigenvectors(coeff2, wavelengths, q);
ylim([-0.2, 0.2]);
title('Training across Dataset');

subplot(1, 3, 2);
PlotEigenvectors(coeff1, wavelengths, q);
ylim([-0.2, 0.2]);
title('Training per Sample');

subplot(1, 3, 3);
PlotEigenvectors(coeff3, wavelengths, q);
ylim([-0.2, 0.2]);
title('Training per Suprepixel');

figName = fullfile(config.GetSetting('outputDir'), config.GetSetting('experiment'), strcat(targetName, '_comparison_pca.png'));
plots.SavePlot(fig, figName);

%%%%%%%%%%%%%%%%%%%%%%%%%%% Fig 2: Display all Dimred %%%%%%%%%%%%%%%%%%%%%%%%%%%%

targets = [6]; %[5, 6];
for i = targets
    id = targetIDs(i);

    %% load HSI from .mat file
    targetName = num2str(id);
    I = hsiUtility.LoadHSI(targetName, 'dataset');
    imgFilename = fullfile(config.GetSetting('outputDir'), config.GetSetting('experiment'), strcat(targetName, '.png'));
    load(strrep(imgFilename, '.png', '.mat'), 'fgMask');
    mask = fgMask;

    [coeff1, scores1, latent, explained, objective] = I.Dimred('pca', q, mask);

    srgb = I.GetDisplayRescaledImage();
    [coeff2, scores2, latent, explained, objective] = I.Dimred('rica', q, mask);

    fig = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1]);

    subplot(1, 3, 1);
    imshow(srgb);
    title('Original');

    subplot(1, 3, 2);
    imshow(scores1);
    title('PCA');

    subplot(1, 3, 3);
    imshow(scores2);
    title('RICA');

    figName = fullfile(config.GetSetting('outputDir'), config.GetSetting('experiment'), strcat(targetName, '_comparison_img.png'));
    plots.SavePlot(fig, figName);

    fig2 = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1]);

    subplot(1, 3, 1);
    imshow(srgb);
    title('Original');

    subplot(1, 3, 2);
    PlotEigenvectors(coeff1, wavelengths, q, fig2);
    ylim([-0.2, 0.2]);
    title('Transform Vectors (PCA)');

    subplot(1, 3, 3);
    PlotEigenvectors(coeff2, wavelengths, q, fig2);
    ylim([-0.2, 0.2]);
    title('Transform Vectors (RICA)');

    figName = fullfile(config.GetSetting('outputDir'), config.GetSetting('experiment'), strcat(targetName, '_comparison_pcavsrica.png'));
    plots.SavePlot(fig2, figName);

end

close all;

coeffFull = coeff2;
method = 'pca';
for i = targets
    id = targetIDs(i);

    %% load HSI from .mat file
    targetName = num2str(id);
    I = hsiUtility.LoadHSI(targetName, 'dataset');
    imgFilename = fullfile(config.GetSetting('outputDir'), config.GetSetting('experiment'), strcat(targetName, '.png'));
    load(strrep(imgFilename, '.png', '.mat'), 'fgMask');
    mask = fgMask;

    [coeff, scores, latent, explained, objective] = I.Dimred(method, q, mask);

    xcol = I.GetMaskedPixels(mask);
    scoresFull = xcol * coeffFull;
    scoresFull = hsi.RecoverSpatialDimensions(scoresFull, size(I.Value), mask);

    srgb = I.GetDisplayRescaledImage();

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fig1

    figure(2);
    clf;

    subplot(1, 3, 1);
    imshow(srgb);

    subplot(1, 3, 2);
    imshow(scores);

    subplot(1, 3, 3);
    imshow(scoresFull);

    figName = config.DirMake(config.GetSetting('outputDir'), config.GetSetting('experiment'), targetName, strcat('scores.png'));
    plots.SavePlot(2, figName);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fig2
    figure(3);
    clf;

    subplot(1, 3, 1);
    imshow(srgb);

    subplot(1, 3, 2);
    xy1 = reshape(scores, [size(scores, 1) * size(scores, 2), size(scores, 3)]);
    scatter(xy1(:, 1), xy1(:, 2));
    xlabel('Projected Axis 1');
    ylabel('Projected Axis 2');
    title('Training per Sample');

    subplot(1, 3, 3);
    xy2 = reshape(scoresFull, [size(scoresFull, 1) * size(scoresFull, 2), size(scoresFull, 3)]);
    scatter(xy2(:, 1), xy2(:, 2));
    xlabel('Projected Axis 1');
    ylabel('Projected Axis 2');
    title('Training across Dataset');

    figName = config.DirMake(config.GetSetting('outputDir'), config.GetSetting('experiment'), targetName, strcat('projection.png'));
    plots.SavePlot(3, figName);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fig3
    figure(4);
    clf;

    subplot(2, 3, 1);
    xy1 = reshape(scores, [size(scores, 1) * size(scores, 2), size(scores, 3)]);
    scatter(xy1(:, 1), xy1(:, 2));
    xlabel('Projected Axis 1');
    ylabel('Projected Axis 2');
    title('Training per Sample');
    xlim([-6, 12]);
    ylim([-3, 6]);

    subplot(2, 3, 4);
    xy2 = reshape(scoresFull, [size(scoresFull, 1) * size(scoresFull, 2), size(scoresFull, 3)]);
    scatter(xy2(:, 1), xy2(:, 2));
    xlabel('Projected Axis 1');
    ylabel('Projected Axis 2');
    title('Training across Dataset');
    xlim([-6, 12]);
    ylim([-3, 6]);

    wavelengths = hsiUtility.GetWavelengths(size(coeff, 1));
    subplot(2, 3, [2, 5]);
    PlotEigenvectors(coeff, wavelengths, q);
    ylim([-0.1, 0.2]);
    title('Transform Vectors (per Sample)');

    subplot(2, 3, [3, 6]);
    PlotEigenvectors(coeffFull, wavelengths, q);
    ylim([-0.1, 0.2]);
    title('Transform Vectors (across Dataset)');

    figName = config.DirMake(config.GetSetting('outputDir'), config.GetSetting('experiment'), targetName, strcat('eigevecs.png'));
    plots.SavePlot(4, figName);

end

%
% %%%%%%%%%%%%%%%%%%%%%%%% Scatter Plot PCA and RICA %%%%%%%%%%%%%%%%%%%%%%
% figure(1);
%
% subplot(1, 3, 1);
% plotTwoAxes(scores1, ytrain, 'PCA');
% fprintf('PCA explains variance: 1st at %.3f and 2nd at %.3f \n\n', explained(1), explained(2));
%
% subplot(1, 3, 2);
% plotTwoAxes(scores2, ytrain, 'RICA');
%
% subplot(1, 3, 3);
% plotTwoAxes(scores3, ytrain, '540nm, 650nm');

function [] = plotTwoAxes(scoresVals, labels, methodName)
healthy = find(labels == 0);
tumor = find(labels == 1);

hold on;
if size(scoresVals, 2) > 1
    scatter(scoresVals(healthy, 1), scoresVals(healthy, 2), 'go');
    scatter(scoresVals(tumor, 1), scoresVals(tumor, 2), 'rd');
else
    scatter(1:length(healthy), scoresVals(healthy), 'go');
    scatter(1:length(tumor), scoresVals(tumor), 'rd');
end
hold off;

title(methodName)
if size(scoresVals, 2) > 1
    xlabel('Projected Axis 1');
    ylabel('Projected Axis 2');
else
    ylabel('Projected Axis');
    xlabel('Samples');
end
end
