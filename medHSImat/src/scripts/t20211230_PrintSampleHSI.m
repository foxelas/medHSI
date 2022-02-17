
sampleIds = [150, 163, 175, 181]; %157, 160,
names = {'mucinous carcinoma', 'basal cell carcinoma', 'Bowen’s disease', 'basal cell carcinoma'};
divBy = 1;

close all;

clf;
for j = 1:4
    targetName = num2str(sampleIds(j));
    config.SetSetting('fileName', targetName);
    Inorm = hsiUtility.LoadHSI(targetName, 'dataset');
    plots.AverageSpectrum(1, Inorm, names{j});
end

criteria = struct('TargetDir', 'currentFolder', 'TargetName', '*_norm.jpg');
plots.MontageFolderContents(3, fullfile(config.GetSetting('saveDir'), config.GetSetting('spectraCheck')), criteria, 'spectra-example');
