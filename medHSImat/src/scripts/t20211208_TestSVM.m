%Date: 2021-12-08

config.SetOpt();
config.SetSetting('isTest', false);
config.SetSetting('database', 'psl');
config.SetSetting('normalization', 'byPixel');
config.SetSetting('experiment', 'T20211215-SVM');

config.SetSetting('dataset', 'pslBase');
[X1, y1, ~, ~, ~, ~, ~] = trainUtility.SplitTrainTest(config.GetSetting('dataset'), {}, 'pixel', true);

rng(1);
SVMModel = fitcsvm(X, y, 'KernelScale', 'auto', 'Standardize', false, 'Verbose', 1, 'NumPrint', 1000, 'IterationLimit', 10^5);

CVSVMModel = crossval(SVMModel);
classLoss = kfoldLoss(CVSVMModel)

modelFilename = dataUtility.GetFilename('model', 'svm_model');
effectiveDate = date();
save(modelFilename, 'SVMModel', 'classLoss', 'effectiveDate');