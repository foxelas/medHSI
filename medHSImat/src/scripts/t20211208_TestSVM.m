%Date: 2021-12-08

config.SetOpt();
config.SetSetting('isTest', false);
config.SetSetting('database', 'psl');
config.SetSetting('normalization', 'byPixel');
config.SetSetting('experiment', 'T20211215-SVM');

%% Read h5 data
[targetIDs, outRows] = databaseUtility.GetTargetIndexes({'tissue', true}, 'fix');

labeldir = config.DirMake(config.GetSetting('matDir'), strcat(config.GetSetting('database'), 'Labels\'));
imgadedir = config.DirMake(config.GetSetting('matDir'), strcat(config.GetSetting('database'), 'Normalized\'));

% ApplyScriptToEacRhImage(@reshape, {'tissue', true},  'fix');

X = [];
y = [];
for i = 1:length(targetIDs)
    id = targetIDs(i);

    %% load HSI from .mat file
    targetName = num2str(id);
    I = hsi;
    I.Value = hsiUtility.ReadStoredHSI(targetName, config.GetSetting('normalization'));
    [m, n, z] = I.Size();

    labelfile = fullfile(labeldir, strcat(num2str(id), '_label.mat'));
    if exist(labelfile, 'file')
        load(labelfile, 'labelMask');

        fgMask = I.GetFgMask();
        Xcol = I.GetPixelsFromMask(fgMask);
        X = [X; Xcol];
        ycol = GetPixelsFromMaskInternal(labelMask(1:m, 1:n), fgMask);
        y = [y; ycol];
    end
end

rng(1);
SVMModel = fitcsvm(X, y, 'KernelScale', 'auto', 'Standardize', false, 'Verbose', 1, 'NumPrint', 1000, 'IterationLimit', 10^5);

CVSVMModel = crossval(SVMModel);
classLoss = kfoldLoss(CVSVMModel)

savedir = config.DirMake(config.GetSetting('outputDir'), config.GetSetting('experiment'), 'svm_model.mat');
effectiveDate = date();
save(savedir, 'SVMModel', 'classLoss', 'effectiveDate');