function Basics_Denoise()

close all;

targetDatabase = config.GetSetting('Dataset');
[~, targetNames] = commonUtility.DatasetInfo(true);
methods = {'smoothen'}; %'smile',
for j = 1:numel(methods)
    config.SetSetting('SaveFolder', strcat('Denoise-', methods{j}));

    for i = 1:length(targetNames)

        % load HSI from .mat file to verify it is working and to prepare preview images
        targetName = targetNames{i};
        config.SetSetting('FileName', targetName);
        [hsIm, labelInfo] = hsiUtility.LoadHsiAndLabel(targetName);
        spectralData = hsIm.Denoise(methods {j});
        savedir = strrep(commonUtility.GetFilename('dataset', targetName, 'mat'), targetDatabase, strcat(targetDatabase, '-', 'Denoise', methods{j}));
        savedir = config.DirMake(savedir);
        save(savedir, 'spectralData', 'labelInfo', '-v7.3');
        
%         savedir = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'), config.GetSetting('FileName')), '');
%         plotPath = fullfile(savedir, 'denoise_pair');
%         figure(1);
%         montage({hsIm.GetDisplayImage(), spectralData.GetDisplayImage()});
%         plots.SavePlot(1, plotPath);

        if false 
            w = hsiUtility.GetWavelengths(311);

            numEndmembers = 8;
            endmembers = nfindr(hsIm.Value, numEndmembers);
            figure(2);
            plot(w, endmembers);
            xlabel('Band Number')
            ylabel('Data Value')
            legend('Location', 'Bestoutside');
            title(sprintf('Endmembers (Num:%d)', numEndmembers));
            xlim([420, 730]);
            plotPath = fullfile(savedir, 'endmembers_before');
            plots.SavePlot(2, plotPath);

            numEndmembers = 8;
            endmembers = nfindr(corrIm.Value, numEndmembers);
            figure(3);
            plot(w, endmembers);
            xlabel('Band Number')
            ylabel('Data Value')
            legend('Location', 'Bestoutside');
            title(sprintf('Endmembers (Num:%d)', numEndmembers));
            xlim([420, 730]);
            plotPath = fullfile(savedir, 'endmembers_after');
            plots.SavePlot(3, plotPath);
        end
    end
end

end