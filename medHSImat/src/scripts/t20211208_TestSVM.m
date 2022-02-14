%Date: 2021-12-08

config.SetOpt();
config.SetSetting('isTest', false);
config.SetSetting('database', 'psl');
config.SetSetting('normalization', 'byPixel');
config.SetSetting('experiment', 'T20211215-SVM');

%% Read h5 data
[targetIDs, outRows] = databaseUtility.GetTargetIndexes({'tissue', true}, 'fix');

% imgadedir = config.DirMake(config.GetSetting('matDir'), strcat(config.GetSetting('database'), config.GetSetting('normalizedName'), '\'));

% ApplyScriptToEacRhImage(@reshape, {'tissue', true},  'fix');

X = [];
y = [];
for i = 1:length(targetIDs)
    id = targetIDs(i);

    %% load HSI from .mat file
    targetName = num2str(id);
    I = hsiUtility.LoadHSI(targetName, 'preprocessed');
    [m, n, z] = size(I.Value);

    targetName = num2str(id); 
    labelfile = dataUtility.GetFilename('label', targetName);    
    if exist(labelfile, 'file')
        load(labelfile, 'labelMask');

        fgMask = I.FgMask;
        Xcol = I.GetMaskedPixels(fgMask);
        X = [X; Xcol];
        ycol = GetMaskedPixelsInternal(labelMask(1:m, 1:n), fgMask);
        y = [y; ycol];
    end
end

rng(1);
SVMModel = fitcsvm(X, y, 'KernelScale', 'auto', 'Standardize', false, 'Verbose', 1, 'NumPrint', 1000, 'IterationLimit', 10^5);

CVSVMModel = crossval(SVMModel);
classLoss = kfoldLoss(CVSVMModel)

modelFilename = dataUtility.GetFilename('model', 'svm_model');
effectiveDate = date();
save(modelFilename, 'SVMModel', 'classLoss', 'effectiveDate');