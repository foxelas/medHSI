function Basics_PrintSampleHSI()
close all;

sampleIds = [150, 163, 175, 181]; %157, 160,

config.SetSetting('saveFolder', 'Spectra-Example');

for j = 1:4
    targetName = num2str(sampleIds(j));
    config.SetSetting('fileName', targetName);
    [Inorm, labelInfo] = hsiUtility.LoadHsiAndLabel(targetName);
    plots.AverageSpectrum(1, Inorm, labelInfo.Diagnosis);
end

criteria = struct('TargetDir', 'currentFolder', 'TargetName', '*_norm.jpg');
filedir = fullfile(commonUtility.GetFilename('output', config.GetSetting('saveFolder'), ''), '\');
plots.MontageFolderContents(3, filedir, criteria, 'example');

end