function [valTrain, valTest] = Basics_Dimred()

experiment = strcat('Dimred', date());
Basics_Init(experiment);

dataset = config.GetSetting('Dataset');
fprintf('Running for dataset %s\n', config.GetSetting('Dataset'));
%%%%%%%%%%%%%%%%%%%%%% Fix %%%%%%%%%%%%%%%%%%%%%%%%%

%% Read h5 data
folds = 5;
testTargets = {'163', '181'};
dataType = 'hsi';
qs = [10, 50, 100];
j = 1;

[trainData, testData, cvp] = trainUtility.SplitDataset(dataset, folds, testTargets, dataType);

%%%%%%%%%%%%%%%%%%%%% Super PCA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for q = qs
    fprintf('SuperPCA: %d \n\n', q);
    j = j + 1;
    [valTrain(j, :), valTest(j, :)] = trainUtility.ValidateTest2(trainData, testData, cvp, 'SuperPCA', q);
end

%%%%%%%%%%%%%%%%%%%%%% Baseline %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('Baseline: %d \n\n', 311);
[valTrain(j, :), valTest(j, :)] = trainUtility.ValidateTest2(trainData, testData, cvp, 'none', 311);

%%%%%%%%%%%%%%%%%%%%%% PCA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for q = qs
    fprintf('PCA: %d \n\n', q);
    j = j + 1;
    [valTrain(j, :), valTest(j, :)] = trainUtility.ValidateTest2(trainData, testData, cvp, 'pca', q);
end

%%%%%%%%%%%%%%%%%%%%%% RICA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for q = qs
    fprintf('RICA: %d \n\n', q);
    j = j + 1;
    [valTrain(j, :), valTest(j, :)] = trainUtility.ValidateTest2(trainData, testData, cvp, 'rica', q);
end

%%%%%%%%%%%%%%%%%%%%%% Wavelength Selection %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('Wavelength Selection: \n\n');
j = j + 1;
[valTrain(j, :), valTest(j, :)] = trainUtility.ValidateTest2(trainData, testData, cvp, 'wavelength-selection', 2);

%%%%%%%%%%%%%%%%%%%%%% LDA/QDA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('LDA: \n\n');
j = j + 1;
[valTrain(j, :), valTest(j, :)] = trainUtility.ValidateTest2(trainData, testData, cvp, 'lda', 1);

fprintf('QDA: \n\n');
j = j + 1;
[valTrain(j, :), valTest(j, :)] = trainUtility.ValidateTest2(trainData, testData, cvp, 'qda', 1);


%%%%%%%%%%%%%%%%%%%%% Multiscale Super PCA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pixelNumArray = floor(20*sqrt(2).^[-2:2]);

for q = qs
    fprintf('MSuperPCA: %d \n\n', q);

    transformFun = @(x, i) IndexCell(x, i);
    numScales = numel(pixelNumArray);

    j = j + 1;
    [valTrain(j, :), valTest(j, :)] = trainUtility.ValidateTest2(trainData, testData, cvp, 'MSuperPCA', q, transformFun, numScales);
end


%%%%%%%%%%%%%%%%%%%%% Autoencoder %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for q = qs
    fprintf('AE: %d \n\n', q);
    j = j + 1;
    [valTrain(j, :), valTest(j, :)] = trainUtility.ValidateTest2(trainData, testData, cvp, 'autoencoder', q);
end

%%%%%%%%%%%%%%%%%%%%% Random Forest Importance %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
for q = qs
    fprintf('RFI: %d \n\n', q);
    j = j + 1;
    [valTrain(j, :), valTest(j, :)] = trainUtility.ValidateTest2(trainData, testData, cvp, 'rfi', q, impOOB);
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
scores = x.Transform(true, 'SuperPCA', 100);
end

function [scores] = IndexCell(x, i)
scores = x{i};
end