function Basics_Dimred()

clc;
close all;

rng(1); % For reproducibility
% numSamples = 6;
% testingSample = 5;
% target = 'fix';

experiment = strcat('Dimred', date());
config.SetSetting('experiment', experiment);
config.SetSetting('saveFolder', experiment);

fprintf('Running for dataset %s\n', config.GetSetting('dataset'));
%%%%%%%%%%%%%%%%%%%%%% Fix %%%%%%%%%%%%%%%%%%%%%%%%%

%% Read h5 data
folds = 5;
content = {'tissue', true};
testTargets = {'166'};
dataType = 'pixel';
hasLabels = true;

[X, y, Xtest, ytest, cvp, sRGBs, fgMasks] = trainUtility.SplitTrainTest(config.GetSetting('dataset'), testTargets, dataType, hasLabels, folds);
filename = commonUtility.GetFilename('output', fullfile(config.GetSetting('saveFolder'), 'cvpInfo'));
save(filename, 'cvp', 'X', 'y', 'Xtest', 'ytest', 'sRGBs', 'fgMasks');

%%%%%%%%%%%%%%%%%%%%%% Train Validate %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('Baseline: %d \n\n', 311);
j = 1;
[valTrain(j, :), valTest(j, :)] = trainUtility.ValidateTest2(X, y, Xtest, ytest, sRGBs, fgMasks, cvp, 'none', 311);

qs = [5, 10, 20, 50, 100];
for q = qs
    fprintf('PCA: %d \n\n', q);
    j = j + 1;
    [valTrain(j, :), valTest(j, :)] = trainUtility.ValidateTest2(X, y, Xtest, ytest, sRGBs, fgMasks, cvp, 'pca', q);
end

for q = qs
    fprintf('RICA: %d \n\n', q);
    j = j + 1;
    [valTrain(j, :), valTest(j, :)] = trainUtility.ValidateTest2(X, y, Xtest, ytest, sRGBs, fgMasks, cvp, 'rica', q);
end

fprintf('Simple: \n\n');
j = j + 1;
[valTrain(j, :), valTest(j, :)] = trainUtility.ValidateTest2(X, y, Xtest, ytest, sRGBs, fgMasks, cvp, 'simple', 2);

fprintf('LDA: \n\n');
j = j + 1;
[valTrain(j, :), valTest(j, :)] = trainUtility.ValidateTest2(X, y, Xtest, ytest, sRGBs, fgMasks, cvp, 'lda', 1);

fprintf('QDA: \n\n');
j = j + 1;
[valTrain(j, :), valTest(j, :)] = trainUtility.ValidateTest2(X, y, Xtest, ytest, sRGBs, fgMasks, cvp, 'qda', 1);

for q = qs
    fprintf('AE: %d \n\n', q);
    j = j + 1;
    [valTrain(j, :), valTest(j, :)] = trainUtility.ValidateTest2(X, y, Xtest, ytest, sRGBs, fgMasks, cvp, 'autoencoder', q);
end

wavelengths = hsiUtility.GetWavelengths(311);
fprintf('RFI: \n\n');
tic;
t = templateTree('NumVariablesToSample', 'all', ...
    'PredictorSelection', 'allsplits', 'Surrogate', 'off', 'Reproducible', true);
RFMdl = fitrensemble(X, y, 'Method', 'Bag', 'NumLearningCycles', 200, ...
    'Learners', t, 'NPrint', 50);
yHat = oobPredict(RFMdl);
R2 = corr(RFMdl.Y, yHat)^2;
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
    j = j + 1;
    [valTrain(j, :), valTest(j, :)] = trainUtility.ValidateTest2(X, y, Xtest, ytest, sRGBs, fgMasks, cvp, 'rfi', q);
end

%%%%%%%%%%%%%%%%%%%%% SFS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('SFS: \n\n');

for q = qs
    fprintf('SFS: %d \n\n', q);

    tic;
    maxdev = chi2inv(.95, 1);
    opt = statset('display', 'iter', ...
        'TolFun', maxdev, ...
        'TolTypeFun', 'abs');

    inmodel = sequentialfs(@critfun, X, y, ...
        'cv', 'none', ...
        'nullmodel', true, ...
        'options', opt, ...
        'direction', 'forward', ...
        'KeepIn', 1, ...
        'NFeatures', q);
    tt = toc;
    fprintf('Runtime %.5f \n\n', tt);

    imo = inmodel(1:q);
    scoresrf = X(:, imo);
    [accuracy, sensitivity, specificity] = RunKfoldValidation(scoresrf, y, cvp, 'rfi', q);
end


%%%%%%%%%%%%%%%%%%%%% Super PCA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic;
[cvp, X, y, Xtest, ytest, sRGBs, fgMasks] = trainUtility.PrepareSpectralDataset(folds, testingSamples, numSamples, content, target, false, @transformSPCAFun);
tdimred = toc;
fprintf('Runtime %.5f \n\n', tdimred);

filename = fullfile(config.GetSetting('output'), config.GetSetting('experiment'), 'superPCA_cvpInfo.mat');
save(filename, 'cvp', 'X', 'y', 'Xtest', 'ytest', 'sRGBs', 'fgMasks');

for q = qs
    fprintf('SuperPCA: %d \n\n', q);
    j = j + 1;
    [valTrain(j, :), valTest(j, :)] = trainUtility.ValidateTest2(X(:, 1:q), y, Xtest(:, 1:q), ytest, sRGBs, fgMasks, cvp, 'SuperPCA', q);
end

end

%%%%%%%%%%%%%%%%%%%%% Assisting Functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [acc] = critfun(scores, labels)
SVMModel = fitcsvm(scores, labels, 'Standardize', true, 'KernelFunction', 'RBF', ...
    'KernelScale', 'auto');
predlabels = predict(SVMModel, scores);
[acc, ~, ~] = metrics.Evaluations(labels, predlabels);
end

function [scores] = transformSPCAFun(x)
scores = x.Transform('SuperPCA', 100);
end

