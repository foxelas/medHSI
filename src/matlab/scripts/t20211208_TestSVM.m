%Date: 2021-12-08

Config.SetOpt();
Config.SetSetting('isTest', false);
Config.SetSetting('database', 'psl');
Config.SetSetting('normalization', 'byPixel');
Config.SetSetting('experiment', 'T20211215-SVM');
        
%% Read h5 data
[targetIDs, outRows] = DB.GetTargetIndexes({'tissue', true},  'fix');

labeldir = Config.DirMake(Config.GetSetting('matDir'), strcat(Config.GetSetting('database'), 'Labels\'));
imgadedir = Config.DirMake(Config.GetSetting('matDir'), strcat(Config.GetSetting('database'), 'Normalized\'));

% ApplyScriptToEacRhImage(@reshape, {'tissue', true},  'fix');

X = [];
y = [];
for i = 1:length(targetIDs)
    id = targetIDs(i);

    %% load HSI from .mat file
    targetName = num2str(id);
    I = Hsi;
    I.Value = HsiUtility.ReadStoredHSI(targetName, Config.GetSetting('normalization'));
    [m,n,z] = I.Size();
   
    labelfile =  fullfile(labeldir, strcat(num2str(id), '_label.mat'));
    if exist(labelfile, 'file')
        load(labelfile, 'labelMask');
        
        fgMask = I.GetFgMask();
        Xcol = I.GetPixelsFromMask(fgMask);
        X = [X ; Xcol];
        ycol = GetPixelsFromMaskInternal(labelMask(1:m, 1:n), fgMask);
        y = [y; ycol];
    end
end

rng(1);
SVMModel = fitcsvm(X,y,'KernelScale','auto','Standardize',false, 'Verbose', 1, 'NumPrint', 1000, 'IterationLimit', 10^5);

CVSVMModel = crossval(SVMModel);
classLoss = kfoldLoss(CVSVMModel)

savedir = Config.DirMake(Config.GetSetting('outputDir'), Config.GetSetting('experiment'), 'svm_model.mat');
effectiveDate = date();
save(savedir, 'SVMModel', 'classLoss', 'effectiveDate');