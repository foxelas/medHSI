function Basics_PrintSampleHSI()
close all;

config.SetSetting('SaveFolder', 'Spectra-Example');

[~, targetNames] = commonUtility.DatasetInfo(true);

for i = 1:length(targetNames)

    %% load HSI from .mat file to verify it is working and to prepare preview images
    targetName = targetNames{i};
    config.SetSetting('FileName', targetName);
    [Inorm, labelInfo] = hsiUtility.LoadHsiAndLabel(targetName);    
    
    plots.AverageSpectrum(1, [], Inorm, labelInfo);
end

w = hsiUtility.GetWavelengths(311);
curves = zeros(length(targetNames) * 2, length(w));
names = cell(length(targetNames) * 2, 1);
markers = cell(length(targetNames) * 2, 1);

k = 0;
for i = 1:length(targetNames)

    %% load HSI from .mat file to verify it is working and to prepare preview images
    targetName = targetNames{i};
    config.SetSetting('FileName', targetName);
    [hsIm, labelInfo] = hsiUtility.LoadHsiAndLabel(targetName);  
    
    maskROI = logical(labelInfo.Labels) & hsIm.FgMask;
    maskNonROI = ~logical(labelInfo.Labels) & hsIm.FgMask; 
    InormROI = hsIm.GetMaskedPixels(maskROI);
    InormNonROI  = hsIm.GetMaskedPixels(maskNonROI);

    diag = labelInfo.Diagnosis;
    parts = strsplit(diag, {' '});
    if numel(parts) > 2
        diag = strjoin(parts(1:2), {' '});
    end
    k = k + 1;
    curves(k,:) = mean(reshape(InormROI, [size(InormROI, 1), size(InormROI, 2)]));
    names{k} = strjoin({'Lesion', diag}, {' '});
    if strcmpi(labelInfo.Type, 'Malignant') 
        markers{k} = "--";
    else
        markers{k} = "-";
    end
    k = k + 1;
    curves(k,:) = mean(reshape(InormNonROI, [size(InormNonROI, 1), size(InormNonROI, 2)]));
    names{k} = strjoin({'Healthy', diag}, {' '}); 
    markers{k} = "-";
end
plotPath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'), 'average'), 'png');
plots.Spectra(2, plotPath, curves, w, names, 'Average Spectra', markers);

% criteria = struct('TargetDir', 'currentFolder', 'TargetName', '*_norm.jpg');
% filedir = fullfile(commonUtility.GetFilename('output', config.GetSetting('SaveFolder'), ''), '\');
% plots.MontageFolderContents(3, filedir, criteria, 'example');

end