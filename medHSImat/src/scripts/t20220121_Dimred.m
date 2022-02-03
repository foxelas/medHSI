%Date: 2022-01-21
clc; close all; 

config.SetSetting('experiment', 'T20220123-Dimred');

wavelengths = hsiUtility.GetWavelengths(311);
labeldir = config.DirMake(config.GetSetting('matDir'), strcat(config.GetSetting('database'), config.GetSetting('labelsName'), '\'));
imgadedir = config.DirMake(config.GetSetting('matDir'), strcat(config.GetSetting('database'), config.GetSetting('normalizedName'), '\'));

%%%%%%%%%%%%%%%%%%%%%%%% RAW %%%%%%%%%%%%%%%%%%%%%%

% [targetIDs, outRows] = databaseUtility.GetTargetIndexes({'tissue', true}, 'raw');
% 
% i = 6;
% id = targetIDs(i);
% targetName = num2str(id);
% I = hsi;
% I.Value = hsiUtility.ReadStoredHSI(targetName, config.GetSetting('normalization'));
% [~, fgMask] = apply.DisableFigures(@hsiUtility.RemoveBackground, I);
% [mask, maskedPixels] = apply.DisableFigures(@hsiUtility.GetMaskFromFigure, I);
% fgMask = mask & fgMask;
% 
% imgFilename = fullfile(config.GetSetting('outputDir'), config.GetSetting('experiment'), strcat(num2str(id), '.png'));
% config.SetSetting('plotName', imgFilename);
% plots.Overlay(3, I.GetDisplayRescaledImage(), fgMask);
% save(strrep(imgFilename, '.png', '.mat'), 'fgMask');
% Xcol = I.GetPixelsFromMask(fgMask);

q = 3; 
[coeff1, ~, latentFull, explainedFull, ~] = Dimred(Xcol, 'PCA', q);
explainedFull(1:3)
[coeff2, ~, latentFull, explainedFull, ~] = Dimred(X, 'PCA', q);
explainedFull(1:3)
coeff3 = SuperpixelAnalysisInternal(I, targetName, false, 10, q);
explainedFull(1:3)

%%%%%%%%%%%%%%%%%%%%%%%%%%% Fig 1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(1); clf;

subplot(1,3,1);
PlotEigenvectors(coeff2, wavelengths, q, 1);
ylim([-0.2, 0.2]);
title('Training across Dataset');

subplot(1,3,2);
PlotEigenvectors(coeff1, wavelengths, q, 1);
ylim([-0.2, 0.2]);
title('Training per Sample');

subplot(1,3,3);
PlotEigenvectors(coeff3, wavelengths, q, 1);
ylim([-0.2, 0.2]);
title('Training per Suprepixel');

figName = fullfile(config.GetSetting('outputDir'), config.GetSetting('experiment'), strcat(targetName, '_comparison_pca.png'));
config.SetSetting('plotName', figName);
plots.SavePlot(1);

return; 
targets = [6]; %[5, 6];
for i = targets
    id = targetIDs(i);

    %% load HSI from .mat file
    targetName = num2str(id);
    I = hsi;
    I.Value = hsiUtility.ReadStoredHSI(targetName, config.GetSetting('normalization'));

    [~, mask] = apply.DisableFigures(@hsiUtility.RemoveBackground, I);
    [coeff1, scores1, latent, explained, objective] = I.Dimred('pca', q, mask);
    
    srgb = I.GetDisplayRescaledImage();
    [coeff2, scores2, latent, explained, objective] = I.Dimred('rica', q, mask);
    
    figure(1); clf;
    
    subplot(1,3,1);
    imshow(srgb);
    title('Original');
    
    subplot(1,3,2);
    imshow(scores1);
    title('PCA');
    
    subplot(1,3,3);
    imshow(scores2);
    title('RICA');
    
    figure(2); clf;
    
    subplot(1,3,1);
    imshow(srgb);
    title('Original');
    
    subplot(1, 3, 2);
    PlotEigenvectors(coeff1, wavelengths, q, 2);
    ylim([-0.2, 0.2]);
    title('Transform Vectors (PCA)');
    
    subplot(1, 3, 3);
    PlotEigenvectors(coeff2, wavelengths, q, 2);
    ylim([-0.2, 0.2]);
    title('Transform Vectors (RICA)');

    
    
end

close all; 

for i = targets
    id = targetIDs(i);

    %% load HSI from .mat file
    targetName = num2str(id);
    I = hsi;
    I.Value = hsiUtility.ReadStoredHSI(targetName, config.GetSetting('normalization'));

    [~, mask] = apply.DisableFigures(@hsiUtility.RemoveBackground, I);
    [coeff, scores, latent, explained, objective] = I.Dimred(method, q, mask);
    
    xcol = I.GetPixelsFromMask(mask);
    scoresFull = xcol * coeffFull;
    scoresFull = hsiUtility.RecoverReducedHsi(scoresFull, size(I.Value), mask);

    srgb = I.GetDisplayRescaledImage();
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fig1

    figure(2); clf;
    
    subplot(1,3,1);
    imshow(srgb);
    
    subplot(1,3,2);
    imshow(scores);
    
    subplot(1,3,3);
    imshow(scoresFull);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fig2
    figure(3); clf;
    
    subplot(1,3,1);
    imshow(srgb);
    
    subplot(1,3,2);
    xy1 = reshape(scores, [size(scores, 1)* size(scores,2), size(scores, 3)]);
    scatter(xy1(:,1), xy1(:,2));
    xlabel('Projected Axis 1');
    ylabel('Projected Axis 2');
    title('Training per Sample');

    subplot(1,3,3);
    xy2 = reshape(scoresFull, [size(scoresFull, 1)* size(scoresFull,2), size(scoresFull, 3)]);
    scatter(xy2(:,1), xy2(:,2));
    xlabel('Projected Axis 1');
    ylabel('Projected Axis 2');
    title('Training across Dataset');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fig3 
    figure(4); clf;
    
    subplot(2,3,1);
    xy1 = reshape(scores, [size(scores, 1)* size(scores,2), size(scores, 3)]);
    scatter(xy1(:,1), xy1(:,2));
    xlabel('Projected Axis 1');
    ylabel('Projected Axis 2');
    title('Training per Sample');
    xlim([-6, 12]);
    ylim([-3, 6]);
    
    subplot(2,3,4);
    xy2 = reshape(scoresFull, [size(scoresFull, 1)* size(scoresFull,2), size(scoresFull, 3)]);
    scatter(xy2(:,1), xy2(:,2));
    xlabel('Projected Axis 1');
    ylabel('Projected Axis 2');
    title('Training across Dataset');
    xlim([-6, 12]);
    ylim([-3, 6]);
    
    wavelengths = hsiUtility.GetWavelengths(size(coeff, 1));
    subplot(2,3,[2,5]);
    PlotEigenvectors(coeff, wavelengths, q, 4);
    ylim([-0.1, 0.2]);
    title('Transform Vectors (per Sample)');
    
    subplot(2,3,[3,6]);
    PlotEigenvectors(coeffFull, wavelengths, q, 4);
    ylim([-0.1, 0.2]);
    title('Transform Vectors (across Dataset)');

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
        scatter(scoresVals(healthy,1), scoresVals(healthy,2), 'go');
        scatter(scoresVals(tumor,1), scoresVals(tumor,2), 'rd');
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
