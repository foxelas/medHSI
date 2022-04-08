function Basics_Denoise()

close all;

[~, targetNames] = commonUtility.DatasetInfo(true);
methods = {'smile', 'smoothen'};
for j = 2:2
    config.SetSetting('SaveFolder', strcat('Denoise-', methods{j}));

    for i = 1:length(targetNames)

        % load HSI from .mat file to verify it is working and to prepare preview images
        targetName = targetNames{i};
        config.SetSetting('FileName', targetName);
        [hsIm, ~] = hsiUtility.LoadHsiAndLabel(targetName);    
        corrIm = hsIm.Denoise(methods{j});
        savedir = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'), config.GetSetting('FileName')), '');
        plotPath = fullfile(savedir, 'denoise_pair');
        figure(1);
        montage({hsIm.GetDisplayImage(), corrIm.GetDisplayImage()});
        plots.SavePlot(1, plotPath);

        w = hsiUtility.GetWavelengths(311);

        numEndmembers = 8;
        endmembers = nfindr(hsIm.Value,numEndmembers);
        figure(2);
        plot(w, endmembers);   
        xlabel('Band Number')
        ylabel('Data Value')
        legend('Location','Bestoutside');
        title(sprintf('Endmembers (Num:%d)', numEndmembers));
        xlim([420, 730]);
        plotPath = fullfile(savedir, 'endmembers_before');
        plots.SavePlot(2, plotPath);

        numEndmembers = 8;
        endmembers = nfindr(corrIm.Value,numEndmembers);
        figure(3);
        plot(w, endmembers);   
        xlabel('Band Number')
        ylabel('Data Value')
        legend('Location','Bestoutside');
        title(sprintf('Endmembers (Num:%d)', numEndmembers));
        xlim([420, 730]);
        plotPath = fullfile(savedir, 'endmembers_after');
        plots.SavePlot(3, plotPath);
    end
end 
end