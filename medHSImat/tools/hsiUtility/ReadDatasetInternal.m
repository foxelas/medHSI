function [] = ReadDatasetInternal(experiment, condition)
    % ReadDataset reads a group of hsi data, prepares .mat files,
    % prepared normalized files and returns montage previews of contents
    % It also prepare labels. Data samples are saved in .mat files
    % so that each contains a 'spectralData' (class hsi) and a
    % 'label' (class logical array) variable. 
    %
    %   Usage:
    %   ReadDataset('handsOnly',{'hand', false})
    %   ReadDataset('sample001-tissue', {'tissue', true});

    %% Setup
    disp('Initializing [ReadLabeledDataset]...');

    config.SetSetting('experiment', experiment);
    config.SetSetting('cropBorders', true);
    config.SetSetting('saveFolder', fullfile(config.GetSetting('snapshots'), experiment));
    isTest = config.GetSetting('isTest');

    %% Read h5 data
    [filenames, targetIDs, outRows] = databaseUtility.Query(condition);

    integrationTimes = [outRows.IntegrationTime];
    dates = [outRows.CaptureDate];
    if isTest
        configurations = [outRows.configuration];
    end

    for i = 1:length(targetIDs)
        close all;

        id = targetIDs(i);
        fprintf('Running for data %d. \n', id);
        target = dataUtility.GetValueFromTable(outRows, 'Target', i);
        content = dataUtility.GetValueFromTable(outRows, 'Content', i);
        config.SetSetting('integrationTime', integrationTimes(i));
        config.SetSetting('dataDate', num2str(dates(i)));
        if isTest
            config.SetSetting('configuration', configurations{i});
        end

        saveName = dataUtility.StrrepAll(strcat(outRows{i, 'SampleID'}, '_', num2str(((str2double(outRows{i, 'IsUnfixed'}) + 2 \ 2) - 2)*(-1)), '-', filenames{i}));
        saveName = strcat(saveName, '.jpg');

        %% write triplet HSI in .mat file
        hsiUtility.ReadHSI(content, target, experiment);

        %% load HSI from .mat file to verify it is working and to prepare preview images
        targetName = num2str(id);
        config.SetSetting('fileName', targetName);

        hsIm = hsi(hsiUtility.LoadHSI(targetName, 'raw'));
        dispImageRaw = hsIm.GetDisplayRescaledImage('rgb');

        %% Preprocess HSI and save
        spectralData = hsiUtility.Preprocess(targetName, config.GetSetting('normalization'));
        dispImageRgb = spectralData.GetDisplayRescaledImage('rgb');

        %% Read Label 
        label = hsiUtility.ReadLabel(targetName);

        %% Save data info in a file 
        filename = dataUtility.GetFilename('dataset', targetName);
        save(filename, 'spectralData', 'label', '-v7.3');

        %% Plot images 
        close all;

        figure(1);
        imshow(dispImageRaw);
        config.SetSetting('plotName', config.DirMake(config.GetSetting('saveDir'), config.GetSetting('saveFolder'), 'rgb', saveName));
        plots.SavePlot(1);

        figure(2);
        imshow(dispImageRgb);
        config.SetSetting('plotName', config.DirMake(config.GetSetting('saveDir'), config.GetSetting('saveFolder'), config.GetSetting('dataset'), saveName));
        plots.SavePlot(2);

        pause(0.1);
    end

    %% preview of the entire dataset

    path1 = fullfile(config.GetSetting('saveDir'), config.GetSetting('saveFolder'), config.GetSetting('dataset'));
    plots.MontageFolderContents(1, path1, '*.jpg', 'Dataset');
    plots.MontageFolderContents(3, path1, '*raw.jpg', 'Dataset raw');
    plots.MontageFolderContents(4, path1, '*fix.jpg', 'Dataset fix');

    path2 = fullfile(config.GetSetting('saveDir'), config.GetSetting('saveFolder'), 'rgb');
    plots.MontageFolderContents(2, path2, '*.jpg', 'sRGB');
    plots.MontageFolderContents(5, path2, '*raw.jpg', 'sRGB raw');
    plots.MontageFolderContents(6, path2, '*fix.jpg', 'sRGB fix');

    close all;
    disp('Finish [ReadLabeledDataset].');
end
