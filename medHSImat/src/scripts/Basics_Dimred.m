function [valTrain, valTest] = Basics_Dimred()

experiment = strcat('Dimred', date());
Basics_Init(experiment);

fprintf('Running for dataset %s\n', config.GetSetting('dataset'));
%%%%%%%%%%%%%%%%%%%%%% Fix %%%%%%%%%%%%%%%%%%%%%%%%%

%% Read h5 data
folds = 5;
testTargets = {'166'};
dataType = 'pixel';
hasLabels = true;
qs = [5, 10, 20, 50, 100];

[X, y, Xtest, ytest, cvp, sRGBs, fgMasks] = trainUtility.SplitTrainTest(config.GetSetting('dataset'), testTargets, dataType, hasLabels, folds);
filename = commonUtility.GetFilename('output', fullfile(config.GetSetting('saveFolder'), 'cvpInfo'));
save(filename, 'cvp', 'X', 'y', 'Xtest', 'ytest', 'sRGBs', 'fgMasks');

%%%%%%%%%%%%%%%%%%%%%% Train Validate %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('Baseline: %d \n\n', 311);
j = 1;
[valTrain(j, :), valTest(j, :)] = trainUtility.ValidateTest2(X, y, Xtest, ytest, sRGBs, fgMasks, cvp, 'none', 311);

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


%%%%%%%%%%%%%%%%%%%%% Super PCA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic;
[X, y, Xtest, ytest, ~, sRGBs, fgMasks] = trainUtility.SplitTrainTest(config.GetSetting('dataset'), testTargets, dataType, hasLabels, folds, @transformSPCAFun);
tdimred = toc;
fprintf('Runtime %.5f \n\n', tdimred);

filename = commonUtility.GetFilename('output', fullfile(config.GetSetting('saveFolder'), 'superPCA_cvpInfo'));
save(filename, 'cvp', 'X', 'y', 'Xtest', 'ytest', 'sRGBs', 'fgMasks');

for q = qs
    fprintf('SuperPCA: %d \n\n', q);
    j = j + 1;
    [valTrain(j, :), valTest(j, :)] = trainUtility.ValidateTest2(X(:, 1:q), y, Xtest(:, 1:q), ytest, sRGBs, fgMasks, cvp, 'SuperPCA', q);
end

%%%%%%%%%%%%%%%%%%%%% Multiscale Super PCA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pixelNumArray = floor(20*sqrt(2).^[-2:2]);

for q = qs
    fprintf('MSuperPCA: %d \n\n', q);

    tic;
    [X, y, Xtest, ytest, ~, sRGBs, fgMasks] = trainUtility.SplitTrainTest(config.GetSetting('dataset'), testTargets, dataType, hasLabels, folds, @(x) x.Transform('MSuperPCA', q, [], pixelNumArray));
    tdimred = toc;
    fprintf('Runtime %.5f \n\n', tdimred);

    transformFun = @(x, i) IndexCell(x, i);
    numScales = numel(pixelNumArray);

    j = j + 1;
    [valTrain(j, :), valTest(j, :)] = trainUtility.ValidateTest2(X, y, Xtest, ytest, sRGBs, fgMasks, cvp, 'MSuperPCA', q, transformFun, numScales);
end

filename = commonUtility.GetFilename('output', fullfile(config.GetSetting('saveFolder'), strcat('msuperPCA_cvpInfo')));
save(filename, 'cvp', 'X', 'y', 'Xtest', 'ytest', 'sRGBs', 'fgMasks');


[X, y, Xtest, ytest, ~, sRGBs, fgMasks] = trainUtility.SplitTrainTest(config.GetSetting('dataset'), testTargets, dataType, hasLabels, folds);
filename = commonUtility.GetFilename('output', fullfile(config.GetSetting('saveFolder'), 'cvpInfo'));
save(filename, 'cvp', 'X', 'y', 'Xtest', 'ytest', 'sRGBs', 'fgMasks');

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

% %%%%%%%%%%%%%%%%%%%%% SFS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% fprintf('SFS: \n\n');
%
% for q = qs
%     fprintf('SFS: %d \n\n', q);
%
%     tic;
%     maxdev = chi2inv(.95, 1);
%     opt = statset('display', 'iter', ...
%         'TolFun', maxdev, ...
%         'TolTypeFun', 'abs');
%
%     inmodel = sequentialfs(@critfun, X, y, ...
%         'cv', 'none', ...
%         'nullmodel', true, ...
%         'options', opt, ...
%         'direction', 'forward', ...
%         'KeepIn', 1, ...
%         'NFeatures', q);
%     tt = toc;
%     fprintf('Runtime %.5f \n\n', tt);
%
%     imo = inmodel(1:q);
%     scoresrf = X(:, imo);
%     [accuracy, sensitivity, specificity] = RunKfoldValidation(scoresrf, y, cvp, 'rfi', q);
% end


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

function [scores] = IndexCell(x, i)
scores = x{i};
end