%Date: 2022-01-21
clc; close all; 

rng(1); % For reproducibility
numSamples = 6;

config.SetOpt();
config.SetSetting('isTest', false);
config.SetSetting('database', 'psl');
config.SetSetting('normalization', 'byPixel');
config.SetSetting('experiment', 'T20220122-Dimred');
% 
% wavelengths = hsiUtility.GetWavelengths(311);
% labeldir = config.DirMake(config.GetSetting('matDir'), strcat(config.GetSetting('database'), config.GetSetting('labelsName'), '\'));
% imgadedir = config.DirMake(config.GetSetting('matDir'), strcat(config.GetSetting('database'), config.GetSetting('normalizedName'), '\'));
% 
% %%%%%%%%%%%%%%%%%%%%%% Fix %%%%%%%%%%%%%%%%%%%%%%%%%
% %% Read h5 data
% [targetIDs, outRows] = databaseUtility.GetTargetIndexes({'tissue', true}, 'fix');
% 
% X = [];
% y = [];
% for i = 1:numSamples %only 6 available labels else length(targetIDs)
%     
%     id = targetIDs(i);
% 
%     %% load HSI from .mat file
%     targetName = num2str(id);
%     I = hsi;
%     I.Value = hsiUtility.ReadStoredHSI(targetName, config.GetSetting('normalization'));
%     [~, fgMask] = apply.DisableFigures(@hsiUtility.RemoveBackground, I);
%     [mask, maskedPixels] = apply.DisableFigures(@hsiUtility.GetMaskFromFigure, I);
%     fgMask = mask & fgMask;
%     
%     imgFilename = fullfile(config.GetSetting('outputDir'), config.GetSetting('experiment'), strcat(num2str(id), '.png'));
%     config.SetSetting('plotName', imgFilename);
%     plots.Overlay(3, I.GetDisplayRescaledImage(), fgMask);
%     save(strrep(imgFilename, '.png', '.mat'), 'fgMask');
%     
%     [m, n, z] = I.Size();
% 
%     labelfile = fullfile(labeldir, strcat(num2str(id), '_label.mat'));
%     if exist(labelfile, 'file')
%         load(labelfile, 'labelMask');
% 
%         Xcol = I.GetPixelsFromMask(fgMask); 
%         ycol = GetPixelsFromMaskInternal(labelMask(1:m, 1:n), fgMask);
%         
%         if i ~= 5
%             X = [X; Xcol];
%             y = [y; ycol];
%         else
%             Xtest = [Xcol];
%             ytest = [ycol];
%         end
%     end
% end
% 
% cvp = trainUtility.KfoldPartitions(y, 5); 

%%%%%%%%%%%%%%%%%%%%% Recover Test Image %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i = 5;
id = targetIDs(i);
targetName = num2str(id);
I = hsi;
I.Value = hsiUtility.ReadStoredHSI(targetName, config.GetSetting('normalization'));

imgFilename = fullfile(config.GetSetting('outputDir'), config.GetSetting('experiment'), strcat(num2str(id), '.png'));
load(strrep(imgFilename, '.png', '.mat'), 'fgMask'); 
srgb = I.GetDisplayRescaledImage(); 


%%%%%%%%%%%%%%%%%%%%%% Train Validate %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('Baseline: %d \n\n', 311);
j = 1;
[valTrain(j,:), valTest(j,:)] = trainUtility.ValidateTest2(X, y, Xtest, ytest, srgb, fgMask, cvp, 'none', 311);   

qs = [5, 10, 20, 50, 100];
for q = qs
    fprintf('PCA: %d \n\n', q);
    j = j+1;
    [valTrain(j,:), valTest(j,:)] = trainUtility.ValidateTest2(X, y, Xtest, ytest, srgb, fgMask, cvp, 'pca', q);  
end

for q = qs
    fprintf('RICA: %d \n\n', q);
    j = j+1;
    [valTrain(j,:), valTest(j,:)] = trainUtility.ValidateTest2(X, y, Xtest, ytest, srgb, fgMask, cvp, 'rica', q);  
end

fprintf('Simple: \n\n');
j = j+1;
[valTrain(j,:), valTest(j,:)] = trainUtility.ValidateTest2(X, y, Xtest, ytest, srgb, fgMask, cvp, 'simple', 2);  

fprintf('LDA: \n\n');
j = j+1;
[valTrain(j,:), valTest(j,:)] = trainUtility.ValidateTest2(X, y, Xtest, ytest, srgb, fgMask, cvp, 'lda', 1);  

fprintf('QDA: \n\n');
j = j+1;
[valTrain(j,:), valTest(j,:)] = trainUtility.ValidateTest2(X, y, Xtest, ytest, srgb, fgMask, cvp, 'qda', 1);  

for q = qs
    fprintf('AE: %d \n\n', q);
    j = j+1;
    [valTrain(j,:), valTest(j,:)] = trainUtility.ValidateTest2(X, y, Xtest, ytest, srgb, fgMask, cvp, 'autoencoder', q);  
end

fprintf('RFI: \n\n');
% tic;
% t = templateTree('NumVariablesToSample','all',...
%     'PredictorSelection','allsplits','Surrogate','off', 'Reproducible',true);
% RFMdl = fitrensemble(X, y,'Method','Bag','NumLearningCycles',200, ...
%     'Learners',t, 'NPrint', 50);
% yHat = oobPredict(RFMdl);
% R2 = corr(RFMdl.Y,yHat)^2;
% fprintf('Mdl explains %0.1f of the variability around the mean.\n', R2);
% impOOB = oobPermutedPredictorImportance(RFMdl);
% tt = toc;
% fprintf('Runtime %.5f \n\n', tt); 
% 
% figure(1);
% bar(wavelengths, impOOB);
% title('Unbiased Predictor Importance Estimates');
% xlabel('Predictor variable');
% ylabel('Importance');
[sortedW, idxOrder] = sort(impOOB, 'descend');
for q = qs
    fprintf('RFI: %d \n\n', q);
    ido = idxOrder(1:q);
    scoresrf = X(:, ido);
    j = j+1;
    [valTrain(j,:), valTest(j,:)] = trainUtility.ValidateTest2(X, y, Xtest, ytest, srgb, fgMask, cvp, 'rfi', q);  
end

superX = [];
supery = [];
method = 'SuperPCA';
tic;
for i = 1:numSamples %only 6 available labels else length(targetIDs)
    
    id = targetIDs(i);

    %% load HSI from .mat file
    targetName = num2str(id);
    I = hsi;
    I.Value = hsiUtility.ReadStoredHSI(targetName, config.GetSetting('normalization'));    
    imgFilename = fullfile(config.GetSetting('outputDir'), config.GetSetting('experiment'), strcat(num2str(id), '.png'));
    load(strrep(imgFilename, '.png', '.mat'), 'fgMask');
    [~, scores, ~, ~, ~, ~] = Dimred(I.Value, method, 100);
    
    [m, n, z] = I.Size();

    labelfile = fullfile(labeldir, strcat(num2str(id), '_label.mat'));
    if exist(labelfile, 'file')
        load(labelfile, 'labelMask');

        Xcol = GetPixelsFromMaskInternal(scores, fgMask); 
        ycol = GetPixelsFromMaskInternal(labelMask(1:m, 1:n), fgMask);
        
        if i ~= 5
            superX = [superX; Xcol];
            supery = [supery; ycol];
        else
            superXtest = [Xcol];
            superytest = [ycol];
        end
    end
end
tdimred = toc; 
fprintf('Runtime %.5f \n\n', tdimred); 

%%%%%%%%%%%%%%%%%%%%% Recover Test Image %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i = 5;
id = targetIDs(i);
targetName = num2str(id);
I = hsi;
I.Value = hsiUtility.ReadStoredHSI(targetName, config.GetSetting('normalization'));

imgFilename = fullfile(config.GetSetting('outputDir'), config.GetSetting('experiment'), strcat(num2str(id), '.png'));
load(strrep(imgFilename, '.png', '.mat'), 'fgMask'); 
srgb = I.GetDisplayRescaledImage(); 

%%%%%%%%%%%%%%%%%%%%% Super PCA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for q = qs
    fprintf('SuperPCA: %d \n\n', q);
    j = j+1;
    [valTrain(j,:), valTest(j,:)] = trainUtility.ValidateTest2(superX(:,1:q), supery, superXtest(:,1:q), superytest, srgb, fgMask, cvp, 'SuperPCA', q);  
end

%%%%%%%%%%%%%%%%%%%%% SFS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% fprintf('SFS: \n\n');
% 
% for q = qs
%     fprintf('SFS: %d \n\n', q);
%     
%     tic;
%     maxdev = chi2inv(.95,1);     
%     opt = statset('display','iter',...
%                   'TolFun',maxdev,...
%                   'TolTypeFun','abs');
% 
%     inmodel = sequentialfs(@critfun,X, y,...
%                            'cv','none',...
%                            'nullmodel',true,...
%                            'options',opt,...
%                            'direction','forward',...
%                            'KeepIn', 1, ...
%                            'NFeatures', q);
%     tt = toc;
%     fprintf('Runtime %.5f \n\n', tt);
% 
%     imo = inmodel(1:q);
%     scoresrf = X(:, imo);
%     [accuracy, sensitivity, specificity] = RunKfoldValidation(scoresrf, y, cvp, 'rfi', q);
% end
% 
% 
% function [acc] = critfun(scores,labels)     
%     SVMModel =  fitcsvm(scores,labels, 'Standardize',true,'KernelFunction','RBF',...
%         'KernelScale','auto');
%     predlabels = predict(SVMModel,scores);  
%    [acc, ~, ~] = metrics.Evaluations(labels,predlabels);
% end