function Basics_PrintSampleHSI()
close all;

config.SetSetting('SaveFolder', 'Spectra-Example');

[~, targetNames] = commonUtility.DatasetInfo(true);

%%%%%%%%%%%%%%%%%%%%%%%%% Average Curves Per Sample %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:length(targetNames)

    % load HSI from .mat file to verify it is working and to prepare preview images
    targetName = targetNames{i};
    config.SetSetting('FileName', targetName);
    [Inorm, labelInfo] = hsiUtility.LoadHsiAndLabel(targetName);    
    
    plots.AverageSpectrum(1, [], Inorm, labelInfo);
end

%%%%%%%%%%%%%%%%%%%%%%%%% Total Average Curves %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
w = hsiUtility.GetWavelengths(311);
curves = zeros(length(targetNames) * 2, length(w));
names = cell(length(targetNames) * 2, 1);
markers = cell(length(targetNames) * 2, 1);

k = 0;
for i = 1:length(targetNames)

    % load HSI from .mat file to verify it is working and to prepare preview images
    targetName = targetNames{i};
    config.SetSetting('FileName', targetName);
    [hsIm, labelInfo] = hsiUtility.LoadHsiAndLabel(targetName);  
    
    maskROI = logical(labelInfo.Labels) & hsIm.FgMask;
    maskNonROI = ~logical(labelInfo.Labels) & hsIm.FgMask; 
    InormROI = hsIm.GetMaskedPixels(maskROI);
    InormNonROI  = hsIm.GetMaskedPixels(maskNonROI);

    diag = labelInfo.Diagnosis;
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

%%%%%%%%%%%%%%%%%%%%%%%%%% Average Correlation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

k = 0;
l = 0;
for i = 1:length(targetNames)

    %% load HSI from .mat file to verify it is working and to prepare preview images
    targetName = targetNames{i};
    config.SetSetting('FileName', targetName);
    [hsIm, labelInfo] = hsiUtility.LoadHsiAndLabel(targetName);  
    
    maskROI = logical(labelInfo.Labels) & hsIm.FgMask;
    maskNonROI = ~logical(labelInfo.Labels) & hsIm.FgMask; 
    InormROI = hsIm.GetMaskedPixels(maskROI);
    InormNonROI  = hsIm.GetMaskedPixels(maskNonROI);

    if strcmpi(labelInfo.Type, 'Malignant') 
        k = k + 1;
        mal{k} =  mean(reshape(InormROI, [size(InormROI, 1), size(InormROI, 2)]));
        ben{k} =  mean(reshape(InormNonROI, [size(InormNonROI, 1), size(InormNonROI, 2)]));
    else
        l = l + 1; 
        mal2{l} =  mean(reshape(InormROI, [size(InormROI, 1), size(InormROI, 2)]));
        ben2{l} =  mean(reshape(InormNonROI, [size(InormNonROI, 1), size(InormNonROI, 2)]));
    end

end
mal = cell2mat(mal');
ben = cell2mat(ben');
mal2 = cell2mat(mal2');
ben2 = cell2mat(ben2');
R1 = corrcoef(mal, ben)
R2 = corrcoef(mal2, ben2)
R3 = corrcoef(ben, ben2)

w = hsiUtility.GetWavelengths(311);

fig = figure(3); 
hold on
h(1) = plots.WithShadedArea(w, mal, 'Malignant Lesion', ':r');
h(2) = plots.WithShadedArea(w, ben, 'Malignant Healthy', '--m');
h(3) = plots.WithShadedArea(w, mal2, 'Benign Lesion', ':g');
h(4) = plots.WithShadedArea(w, ben2, 'Benign Healthy', '--b');
hold off 
xlim([420, 730]);
ylim([0,1]);
title('Mean(SD) of each Sample Category');
legend(h, 'Location', 'EastOutside');

plotPath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'), 'total_avarage'), 'png');
plots.SavePlot(fig, plotPath); 

end


