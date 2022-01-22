%Date: 2022-01-21
clc; close all; 

rng(1); % For reproducibility

config.SetOpt();
config.SetSetting('isTest', false);
config.SetSetting('database', 'psl');
config.SetSetting('normalization', 'byPixel');
config.SetSetting('experiment', 'T20220121-Dimred');

wavelengths = hsiUtility.GetWavelengths(311);
labeldir = config.DirMake(config.GetSetting('matDir'), strcat(config.GetSetting('database'), 'Labels\'));
imgadedir = config.DirMake(config.GetSetting('matDir'), strcat(config.GetSetting('database'), 'Normalized\'));

%%%%%%%%%%%%%%%%%%%%%% Fix %%%%%%%%%%%%%%%%%%%%%%%%%
%% Read h5 data
[targetIDs, outRows] = databaseUtility.GetTargetIndexes({'tissue', true}, 'fix');
% apply.ScriptToEachImage(@reshape, {'tissue', true},  'fix');

X = [];
y = [];
for i = 1:length(targetIDs)
    id = targetIDs(i);

    %% load HSI from .mat file
    targetName = num2str(id);
    I = hsi;
    I.Value = hsiUtility.ReadStoredHSI(targetName, config.GetSetting('normalization'));
    [~, fgMask] = apply.DisableFigures(@hsiUtility.RemoveBackground, I);
    [mask, maskedPixels] = apply.DisableFigures(@hsiUtility.GetMaskFromFigure, I);
    fgMask = mask & fgMask;
    
    config.SetSetting('plotName', fullfile(config.GetSetting('outputDir'), config.GetSetting('experiment'), strcat(num2str(id), '.png')));
    plots.Overlay(3, I.GetDisplayRescaledImage(), fgMask);
    
    [m, n, z] = I.Size();

    labelfile = fullfile(labeldir, strcat(num2str(id), '_label.mat'));
    if exist(labelfile, 'file')
        load(labelfile, 'labelMask');

        Xcol = I.GetPixelsFromMask(fgMask);
        X = [X; Xcol];
        ycol = GetPixelsFromMaskInternal(labelMask(1:m, 1:n), fgMask);
        y = [y; ycol];
    end
end

indLim = floor(size(X,1) * 0.8);
Xtrain = X(1:indLim,:);
ytrain = y(1:indLim);

Xtest = X(indLim+1:end,:);
ytest = y(indLim+1:end);

cvp = cvpartition(length(y),'kfold',10);

fprintf('Baseline: %d \n\n', 311);
[accuracy, sensitivity, specificity] = RunKfoldValidation(X, y, cvp, 'none', q);

qs = [5, 10, 20, 50, 100];
for q = qs
    fprintf('PCA: %d \n\n', q);
    [accuracy, sensitivity, specificity] = RunKfoldValidation(X, y, cvp, 'pca', q);
end

for q = qs
    fprintf('RICA: %d \n\n', q);
    [accuracy, sensitivity, specificity] = RunKfoldValidation(X, y, cvp, 'rica', q);
end

fprintf('Simple: \n\n');
[accuracy, sensitivity, specificity] = RunKfoldValidation(X, y, cvp, 'simple', q);

fprintf('LDA: \n\n');
[accuracy, sensitivity, specificity] = RunKfoldValidation(X, y, cvp, 'lda', q);

fprintf('QDA: \n\n');
[accuracy, sensitivity, specificity] = RunKfoldValidation(X, y, cvp, 'qda', q);

for q = qs
    fprintf('AE: %d \n\n', q);
    [accuracy, sensitivity, specificity] = RunKfoldValidation(X, y, cvp, 'autoencoder', q);
end

fprintf('RFI: \n\n');
tic;
%t = templateTree('Reproducible',true);
t = templateTree('NumVariablesToSample','all',...
    'PredictorSelection','allsplits','Surrogate','off', 'Reproducible',true);
RFMdl = fitrensemble(X, y,'Method','Bag','NumLearningCycles',200, ...
    'Learners',t, 'NPrint', 50);
yHat = oobPredict(RFMdl);
R2 = corr(RFMdl.Y,yHat)^2;
fprintf('Mdl explains %0.1f of the variability around the mean.\n', R2);
impOOB = oobPermutedPredictorImportance(RFMdl);
tt = toc;
fprintf('Runtime %.5f \n\n', tt); 

figure(1);
bar(wavelengths, impOOB);
title('Unbiased Predictor Importance Estimates');
xlabel('Predictor variable');
ylabel('Importance');
[sortedW, idxOrder] = sort(impOOB, 'descend');
for q = qs
    fprintf('RFI: %d \n\n', q);
    ido = idxOrder(1:q);
    scoresrf = X(:, ido);
    [accuracy, sensitivity, specificity] = RunKfoldValidation(scoresrf, y, cvp, 'rfi', q);
end


fprintf('SFS: \n\n');

for q = qs
    fprintf('SFS: %d \n\n', q);
    
    tic;
    maxdev = chi2inv(.95,1);     
    opt = statset('display','iter',...
                  'TolFun',maxdev,...
                  'TolTypeFun','abs');

    inmodel = sequentialfs(@critfun,X, y,...
                           'cv','none',...
                           'nullmodel',true,...
                           'options',opt,...
                           'direction','forward',...
                           'KeepIn', 1, ...
                           'NFeatures', q);
    tt = toc;
    fprintf('Runtime %.5f \n\n', tt);

    imo = inmodel(1:q);
    scoresrf = X(:, imo);
    [accuracy, sensitivity, specificity] = RunKfoldValidation(scoresrf, y, cvp, 'rfi', q);
end
                   

disable = true; 

%%%%%%%%%%%%%%%%%%%%%%%% Scatter Plot PCA and RICA %%%%%%%%%%%%%%%%%%%%%%
if ~disable 
    figure(1);

    subplot(1, 3, 1);  
    plotTwoAxes(scores1, ytrain, 'PCA');
    fprintf('PCA explains variance: 1st at %.3f and 2nd at %.3f \n\n', explained(1), explained(2));

    subplot(1, 3, 2);  
    plotTwoAxes(scores2, ytrain, 'RICA');

    subplot(1, 3, 3);  
    plotTwoAxes(scores3, ytrain, '540nm, 650nm');

end 
return; 





%%%%%%%%%%%%%%%%%%%%%%%%%%% Raw %%%%%%%%%%%%%%%%%%%%%%%%%%%%
[targetIDs, outRows] = databaseUtility.GetTargetIndexes({'tissue', true}, 'raw');

method = 'pca';
q = 3;

X = [];
for i = 1:length(targetIDs)
    id = targetIDs(i);
    I = hsi;
    I.Value = hsiUtility.ReadStoredHSI(targetName, config.GetSetting('normalization'));
    [~, mask] = apply.DisableFigures(@hsiUtility.RemoveBackground, I);
    xcol = I.GetPixelsFromMask(mask);
    X = [X; xcol];
end

[coeffFull, ~, latentFull, explainedFull, ~] = Dimred(X, method, q);

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

function [accuracy, sensitivity, specificity, st] = RunSVM(scores, labels, testscores, testlabels, tt)
% SVMModel = fitcsvm(X,Y,'Standardize',true,'KernelFunction','RBF',...
%     'KernelScale','auto');

%     SVMModel = fitcsvm(scores,labels);
    tic;
    SVMModel =  fitcsvm(scores,labels, 'Standardize',true,'KernelFunction','RBF',...
        'KernelScale','auto');
    st = toc;
    predlabels = predict(SVMModel,testscores);
    
   [accuracy, sensitivity, specificity] = metrics.Evaluations(testlabels,predlabels);
    
end 

function [accuracy, sensitivity, specificity] = RunKfoldValidation(X, y, cvp, method, q)   
    numvalidsets = cvp.NumTestSets;
    acc = zeros(1, numvalidsets);
    sens = zeros(1, numvalidsets);
    spec = zeros(1, numvalidsets);
    st = zeros(1, numvalidsets);

    for k = 1:numvalidsets
        Xtrain = X(cvp.training(k),:);
        ytrain = y(cvp.training(k),:);
        Xvalid = X(cvp.test(k),:);
        yvalid = y(cvp.test(k),:);

        switch method
            case 'pca'
                tic;
                [coeff, scores, latent, explained, objective] = Dimred(Xtrain, 'pca', q);
                tt = toc;
                [acc(k), sens(k), spec(k), st(k)] = RunSVM(scores, ytrain, Xvalid *coeff, yvalid, tt);
                
            case 'rica'
                tic;
                warning('off', 'all');
                [coeff, scores, ~, ~, ~] = Dimred(Xtrain, 'rica', q);
                warning('on', 'all');
                tt = toc;
                [acc(k), sens(k), spec(k), st(k)] = RunSVM(scores, ytrain, Xvalid *coeff, yvalid, tt); 
            
            case 'simple'
                wavelengths = hsiUtility.GetWavelengths(311);
                tic;
                id1 = find(wavelengths == 540);
                id2 = find(wavelengths == 650);
                scores = Xtrain(:, [id1, id2]);
                tt = toc;
                [acc(k), sens(k), spec(k), st(k)] =  RunSVM(scores, ytrain, Xvalid(:, [id1, id2]), yvalid, 0);
                
            case 'lda'
                tic;
                [~, scores, ~, ~, ~, LMdl] = Dimred(Xtrain, 'lda', q, ytrain);
                tt = toc;
                st(k) = tt;
                ypred1 = predict(LMdl, Xvalid);
                [acc(k), sens(k), spec(k)] = metrics.Evaluations(yvalid,ypred1);
            
            case 'qda'
                [~, scores, ~, ~, ~, LMdl] = Dimred(Xtrain, 'qda', q, ytrain);
                tt = toc;
                st(k) = tt;
                ypred1 = predict(LMdl, Xvalid);
                [acc(k), sens(k), spec(k)] = metrics.Evaluations(yvalid,ypred1);
            
            case 'rfi'
                tt = 0;
                [acc(k), sens(k), spec(k), st(k)] =  RunSVM(Xtrain, ytrain, Xvalid, yvalid, 0);
            
            case 'autoencoder'
                tic;
                autoenc = trainAutoencoder(Xtrain',q,'MaxEpochs',400,...
                    'UseGPU', true);
                tt = toc;
                scores = encode(autoenc,Xtrain')';
                testscores = encode(autoenc, Xvalid')';
                [acc(k), sens(k), spec(k), st(k)] = RunSVM(scores, ytrain, testscores, yvalid, tt);

            case 'none'
               tt = 0;
               [acc(k), sens(k), spec(k), st(k)] =  RunSVM(Xtrain, ytrain, Xvalid, yvalid, 0);
        end
         
    end
    
    accuracy = mean(acc);
    sensitivity = mean(sens);
    specificity = mean(spec);
    svmtime = mean(st);
    fprintf('10-fold validated - Accuracy: %.5f, Sensitivity: %.5f, Specificity: %.5f, DR Train time: %.5f, SVM Train time: %.5f \n\n', accuracy, sensitivity, specificity, tt, svmtime);

end

function [acc] = critfun(scores,labels)     
    SVMModel =  fitcsvm(scores,labels, 'Standardize',true,'KernelFunction','RBF',...
        'KernelScale','auto');
    predlabels = predict(SVMModel,scores);  
   [acc, ~, ~] = metrics.Evaluations(labels,predlabels);
end
