%Date: 2022-01-21
clc; close all; 

config.SetOpt();
config.SetSetting('isTest', false);
config.SetSetting('database', 'psl');
config.SetSetting('normalization', 'byPixel');
config.SetSetting('experiment', 'T20220121-Dimred');

%% Read h5 data
[targetIDs, outRows] = databaseUtility.GetTargetIndexes({'tissue', true}, 'raw');

labeldir = config.DirMake(config.GetSetting('matDir'), strcat(config.GetSetting('database'), 'Labels\'));
imgadedir = config.DirMake(config.GetSetting('matDir'), strcat(config.GetSetting('database'), 'Normalized\'));

% apply.ScriptToEachImage(@reshape, {'tissue', true},  'fix');

% apply.ScriptToEachImage(@apply.SuperpixelAnalysis);

% method = 'pca';
% q = 3;
% 
% X = [];
% for i = 1:length(targetIDs)
%     id = targetIDs(i);
%     I = hsi;
%     I.Value = hsiUtility.ReadStoredHSI(targetName, config.GetSetting('normalization'));
%     [~, mask] = apply.DisableFigures(@hsiUtility.RemoveBackground, I);
%     xcol = I.GetPixelsFromMask(mask);
%     X = [X; xcol];
% end
% 
% [coeffFull, ~, latentFull, explainedFull, ~] = Dimred(X, method, q);

targets = [6]; %[5, 6];
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


    
% X = [];
% y = [];
% for i = 1:length(targetIDs)
%     id = targetIDs(i);
% 
%     %% load HSI from .mat file
%     targetName = num2str(id);
%     I = hsi;
%     I.Value = hsiUtility.ReadStoredHSI(targetName, config.GetSetting('normalization'));
%     [m, n, z] = I.Size();
% 
%     labelfile = fullfile(labeldir, strcat(num2str(id), '_label.mat'));
%     if exist(labelfile, 'file')
%         load(labelfile, 'labelMask');
% 
%         fgMask = I.GetFgMask();
%         Xcol = I.GetPixelsFromMask(fgMask);
%         X = [X; Xcol];
%         ycol = GetPixelsFromMaskInternal(labelMask(1:m, 1:n), fgMask);
%         y = [y; ycol];
%     end
% end
