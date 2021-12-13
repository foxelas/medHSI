%Date: 2021-12-08

SetOpt();
SetSetting('isTest', false);
SetSetting('database', 'psl');
SetSetting('normalization', 'byPixel');
SetSetting('experiment', 'T20211208-SVM');
        
%% Read h5 data
[targetIDs, outRows] = GetTargetIndexes({'tissue', true},  'fix');

labeldir = DirMake(GetSetting('matDir'), strcat(GetSetting('database'), 'Labels\'));
imgadedir = DirMake(GetSetting('matDir'), strcat(GetSetting('database'), 'Normalized\'));

% ApplyScriptToEacRhImage(@reshape, {'tissue', true},  'fix');

X = [];
y = [];
for i = 1:length(targetIDs)
    id = targetIDs(i);

    %% load HSI from .mat file
    targetName = num2str(id);
    hsi = ReadStoredHSI(targetName, GetSetting('normalization'));
    [m,n,z] = size(hsi);
   
    labelfile =  fullfile(labeldir, strcat(num2str(id), '_label.mat'));
    if exist(labelfile, 'file')
        load(labelfile, 'labelMask');
        
        fgMask = GetFgMask(hsi);
        Xcol = GetPixelsFromMask(hsi, fgMask);
        X = [X ; Xcol];
        ycol = GetPixelsFromMask(labelMask(1:m, 1:n), fgMask);
        y = [y; ycol];
    end
end

rng(1);
SVMModel = fitcsvm(X,y,'KernelScale','auto','Standardize',false, 'Verbose', 1, 'NumPrint', 1000, 'IterationLimit', 10^5);

CVSVMModel = crossval(SVMModel);
classLoss = kfoldLoss(CVSVMModel)

savedir = DirMake(GetSetting('outputDir'), GetSetting('experiment'), 'svm_model.mat');
effectiveDate = date();
save(savedir, 'SVMModel', 'classLoss', 'effectiveDate');