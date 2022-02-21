%======================================================================
%> @brief ReadDataset reads the dataset.
%>
%> ReadDataset reads a group of hsi data according to condition, prepares
%> .mat files for the raw spectral data, applies preprocessing and returns
%> montage previews of the results. It also prepares labels, when
%> available.
%>
%>  Data samples are saved in .mat files so that one contains a
%> 'spectralData' (class hsi) and another contains a 'labelInfo' (class
%> hsiInfo) variable.
%> The save location is config::[matDir]\\[dataset]\\*.mat.
%> Snapshot images are saved in config::[outputDir]\\[snapshots]\\[dataset]\\.
%>
%> @b Usage
%>
%> @code
%> ReadDataset('handsDataset',{'hand', false});
%>
%> ReadDataset('pslData', {'tissue', true});
%> @endcode
%>
%> @param dataset [char] | The dataset
%> @param condition [cell array] | The conditions for reading files
%>
%======================================================================
function [] = ReadDataset(dataset, condition)
%> @brief ReadDataset reads the dataset.
%>
%> ReadDataset reads a group of hsi data according to condition, prepares
%> .mat files for the raw spectral data, applies preprocessing and returns
%> montage previews of the results. It also prepares labels, when
%> available.
%>
%>  Data samples are saved in .mat files so that one contains a
%> 'spectralData' (class hsi) and another contains a 'labelInfo' (class
%> hsiInfo) variable.
%> The save location is config::[matDir]\[dataset]\*.mat.
%> Snapshot images are saved in config::[outputDir]\[snapshots]\[dataset]\.
%>
%> @b Usage
%> @code
%> ReadDataset('handsDataset',{'hand', false});
%>
%> ReadDataset('pslData', {'tissue', true});
%> @endcode
%>
%> @param dataset [char] | The dataset
%> @param condition [cell array] | The conditions for reading files
%>

%% Setup
disp('Initializing [ReadLabeledDataset]...');

config.SetSetting('dataset', dataset);
experiment = dataset;
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
    target = databaseUtility.GetValueFromTable(outRows, 'Target', i);
    content = databaseUtility.GetValueFromTable(outRows, 'Content', i);
    config.SetSetting('integrationTime', integrationTimes(i));
    config.SetSetting('dataDate', num2str(dates(i)));
    if isTest
        config.SetSetting('configuration', configurations{i});
    end

    saveName = StrrepAll(strcat(outRows{i, 'SampleID'}, '_', num2str(((str2double(outRows{i, 'IsUnfixed'}) + 2 \ 2) - 2)*(-1)), '-', filenames{i}));
    saveName = strcat(saveName, '.jpg');

    %% write triplet HSI in .mat file
    rawImg = hsiUtility.ReadTriplet(content, target, experiment);

    %% load HSI from .mat file to verify it is working and to prepare preview images
    targetID = num2str(id);
    sampleID = databaseUtility.GetValueFromTable(outRows, 'SampleID', i);
    isUnfixed = databaseUtility.GetValueFromTable(outRows, 'IsUnfixed', i);
    if strcmp(isUnfixed, '1')
        tissueType = 'Unfixed';
    else
        tissueType = 'Fixed';
    end

    config.SetSetting('fileName', targetID);
    rawIm = hsi(rawImg, true, targetID, sampleID, tissueType);
    dispImageRaw = rawIm.GetDisplayRescaledImage('rgb');

    %% Preprocess HSI and save
    spectralData = Preprocessing(rawIm, targetID);
    dispImageRgb = spectralData.GetDisplayRescaledImage('rgb');

    %% Read Label
    labelInfo = hsiInfo.ReadHsiInfoFromHsi(spectralData);

    %% Save data info in a file
    filename = commonUtility.GetFilename('dataset', targetID);
    save(filename, 'spectralData', 'labelInfo', '-v7.3');

    %% Plot images
    close all;

    figure(1);
    imshow(dispImageRaw);
    config.SetSetting('plotName', config.DirMake(config.GetSetting('outputDir'), config.GetSetting('saveFolder'), 'rgb', saveName));
    plots.SavePlot(1);

    figure(2);
    imshow(dispImageRgb);
    config.SetSetting('plotName', config.DirMake(config.GetSetting('outputDir'), config.GetSetting('saveFolder'), 'preprocessed', saveName));
    plots.SavePlot(2);

    pause(0.1);
end

%% preview of the entire dataset

path1 = fullfile(config.GetSetting('outputDir'), config.GetSetting('saveFolder'), 'preprocessed');
plots.MontageFolderContents(1, path1, '*.jpg', 'Dataset');
plots.MontageFolderContents(3, path1, '*raw.jpg', 'Dataset raw');
plots.MontageFolderContents(4, path1, '*fix.jpg', 'Dataset fix');

path2 = fullfile(config.GetSetting('outputDir'), config.GetSetting('saveFolder'), 'rgb');
plots.MontageFolderContents(2, path2, '*.jpg', 'sRGB');
plots.MontageFolderContents(5, path2, '*raw.jpg', 'sRGB raw');
plots.MontageFolderContents(6, path2, '*fix.jpg', 'sRGB fix');

close all;
disp('Finish [ReadLabeledDataset].');
end

function [outname] = StrrepAll(inname, isLegacy)
    %     StrrepAll formats an inname to outname
    %
    %     Usage:
    %     [outname] = StrrepAll(inname)

    if nargin < 2
        isLegacy = false;
    end

    [~, outname] = fileparts(inname);

    str = '_';
    if isLegacy
        str = ' ';
    end

    outname = strrep(outname, '\', str);
    outname = strrep(outname, '_', str);
    outname = strrep(outname, ' ', str);

    outname = strrep(outname, '.csv', '');
    outname = strrep(outname, '.mat', '');

end