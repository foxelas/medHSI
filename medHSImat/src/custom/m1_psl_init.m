% %% Delete labels from 02-Labels in raw data folder
%
% %% Make labels with labelme, save at 'pslRaw' \ '00-Labelme'
%
% %% Prepare Datasets
% Basics_MakeDataset('Raw');
% Basics_MakeDataset('512');
% Basics_MakeDataset('32');

%% Make denoised Dataset
baseDataset = 'pslRaw';

methods = {'smoothen'};
config.SetSetting('Dataset', baseDataset);
[~, targetNames] = commonUtility.DatasetInfo(true);
config.SetSetting('SaveFolder', 'PCA'); %''Endmembers');

for j = 1:numel(methods)
    targetDataset = strcat(baseDataset, '-Denoise', methods{j});

    for i = 1:length(targetNames)
        targetName = targetNames{i};
        config.SetSetting('FileName', targetName);
        config.SetSetting('Dataset', baseDataset);
        [hsIm, labelInfo] = hsiUtility.LoadHsiAndLabel(targetName);
        corrIm = hsIm.Denoise(methods {j});

        config.SetSetting('Dataset', targetDataset);
        savedir = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'), config.GetSetting('FileName')), '');
        w = hsiUtility.GetWavelengths(311);

        numEndmembers = 8;
        endmembers = NfindrInternal(hsIm.Value, numEndmembers, hsIm.FgMask);

        figure(2);
        plot(w, endmembers);
        xlabel('Band Number')
        ylabel('Data Value')
        legend('Location', 'Bestoutside');
        title(sprintf('Endmembers (Num:%d)', numEndmembers));
        xlim([420, 730]);
        ylim([0, 1]);
        plotPath = fullfile(savedir, 'endmembers_1before');
        plots.SavePlot(2, plotPath);

        endmembers = NfindrInternal(corrIm.Value, numEndmembers, corrIm.FgMask);

        figure(3);
        plot(w, endmembers);
        xlabel('Band Number')
        ylabel('Data Value')
        legend('Location', 'Bestoutside');
        title(sprintf('Endmembers (Num:%d)', numEndmembers));
        xlim([420, 730]);
        ylim([0, 1]);
        plotPath = fullfile(savedir, 'endmembers_2after');
        plots.SavePlot(3, plotPath);

        spectralData = corrIm;
        config.SetSetting('Dataset', targetDataset);
        targetFilename = commonUtility.GetFilename('dataset', targetName);
        save(targetFilename, 'spectralData', 'labelInfo', '-v7.3');
    end
end

%% Get Example Values
config.SetSetting('Dataset', 'pslRaw');
Basics_PrintSampleHSI();
config.SetSetting('Dataset', 'psl32');
Basics_PrintSampleHSI();

config.SetSetting('Dataset', 'pslRaw');
segment.By_HyperspectralToolbox
segment.ByPCA
segment.ByRICA
segment.BySAM
segment.BySuperPCA