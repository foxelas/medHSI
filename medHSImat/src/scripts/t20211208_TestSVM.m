%Date: 2021-12-08

rng(1); % For reproducibility

config.SetSetting('dataset', 'pslTest'); 
experiment = 'T20211215-SVM';
config.SetSetting('experiment', experiment);
config.SetSetting('saveFolder', experiment);

fprintf('Running for dataset %s\n', config.GetSetting('dataset'));
%%%%%%%%%%%%%%%%%%%%%% Fix %%%%%%%%%%%%%%%%%%%%%%%%%

%% Read h5 data
folds = 5;
testTargets = {'166'};
dataType = 'pixel';
hasLabels = true;

[X, y, Xtest, ytest, cvp, sRGBs, fgMasks] = trainUtility.SplitTrainTest(config.GetSetting('dataset'), testTargets, dataType, hasLabels, folds);

% factors = 2;
% kk = floor(decimate(1:size(X,1), factors));
% X = X(kk, :);
% y = y(kk, :);

SVMModel = fitcsvm(X, y,  'KernelFunction', 'RBF', 'KernelScale', 'auto', 'Standardize', false, 'Verbose', 1, 'NumPrint', 1000, 'IterationLimit', 10^5);

CVSVMModel = crossval(SVMModel);
classLoss = kfoldLoss(CVSVMModel)

modelFilename = dataUtility.GetFilename('model', 'svm_model');
effectiveDate = date();
save(modelFilename, 'SVMModel', 'classLoss', 'effectiveDate');