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
%> The save location is config::[Matdir]\\[Dataset]\\*.mat.
%> Snapshot images are saved in config::[OutputDir]\\[SnapshotsFolderName]\\[Dataset]\\.
%>
%> If it fails during writing in config.mat, consider running MATLAB as administrator.
%> Alternatively, in Windows 10 go to Settings > Update & Security > Windows Security >
%> Virus and Threat protection > Manage Ransomware Protection > Allow an app through controlled folder access > Add Matlab.
%>
%> @b Usage
%>
%> @code
%> ReadDataset('handsDataset',{'hand', false});
%>
%> ReadDataset('pslData', {'tissue', true});
%>
%> ReadDataset('pslData', {'tissue', true}, true, {'raw', false});
%> @endcode
%>
%> @param dataset [char] | The dataset
%> @param contentConditions [cell array] | The content conditions for reading files
%> @param readForeground [boolean] | Optional: Flag to read the foreground mask for an hsi instance. Default: true.
%> @param targetConditions [cell array] | Optional: The target conditions for reading files. Default: none.
%======================================================================
function [] = ReadDataset(dataset, contentConditions, readForeground, targetConditions)
% ReadDataset reads the dataset.
%
% ReadDataset reads a group of hsi data according to condition, prepares
% .mat files for the raw spectral data, applies preprocessing and returns
% montage previews of the results. It also prepares labels, when
% available.
%
%  Data samples are saved in .mat files so that one contains a
% 'spectralData' (class hsi) and another contains a 'labelInfo' (class
% hsiInfo) variable.
% The save location is config::[Matdir]\\[Dataset]\\*.mat.
% Snapshot images are saved in config::[OutputDir]\\[SnapshotsFolderName]\\[Dataset]\\.
%
% If it fails during writing in config.mat, consider running MATLAB as administrator.
% Alternatively, in Windows 10 go to Settings > Update & Security > Windows Security >
% Virus and Threat protection > Manage Ransomware Protection > Allow an app through controlled folder access > Add Matlab.
%
% @b Usage
%
% @code
% ReadDataset('handsDataset',{'hand', false});
%
% ReadDataset('pslData', {'tissue', true});
%
% ReadDataset('pslData', {'tissue', true}, true, {'raw', false});
% @endcode
%
% @param dataset [char] | The dataset
% @param contentConditions [cell array] | The content conditions for reading files
% @param readForeground [boolean] | Optional: Flag to read the foreground mask for an hsi instance. Default: true.
% @param targetConditions [cell array] | Optional: The target conditions for reading files. Default: none.

if nargin < 3
    readForeground = true;
end

%% Setup
disp('');
disp('Initializing [ReadLabeledDataset]...');

config.SetSetting('Dataset', dataset);
experiment = dataset;
config.SetSetting('Experiment', experiment);
config.SetSetting('CropBorders', true);
isTest = config.GetSetting('IsTest');

basedir = commonUtility.GetFilename('output', config.GetSetting('SnapshotsFolderName'), '');

%% Read h5 data
if nargin < 4
    [filenames, targetIDs, outRows] = databaseUtility.Query(contentConditions);
else
    [filenames, targetIDs, outRows] = databaseUtility.Query(contentConditions, [], [], [], [], targetConditions);
end

integrationTimes = [outRows.IntegrationTime];
dates = [outRows.CaptureDate];
if isTest
    configurations = [outRows.Configuration];
end

for i = 1:length(targetIDs)
    close all;

    id = targetIDs(i);
    fprintf('\nRunning for data %d. \n', id);
    targetConditions = databaseUtility.GetValueFromTable(outRows, 'Target', i);
    content = databaseUtility.GetValueFromTable(outRows, 'Content', i);
    config.SetSetting('IntegrationTime', integrationTimes(i));
    config.SetSetting('DataDate', num2str(dates(i)));
    if isTest
        config.SetSetting('Configuration', configurations{i});
    end
    targetID = num2str(id);
    sampleID = databaseUtility.GetValueFromTable(outRows, 'SampleID', i);
    isUnfixed = databaseUtility.GetValueFromTable(outRows, 'IsUnfixed', i);
    if strcmp(isUnfixed, '1')
        tissueType = 'Unfixed';
    else
        tissueType = 'Fixed';
    end

    if isTest
        saveName = StrrepAll(filenames{i});
    else
        saveName = StrrepAll(strcat(sampleID, '_', num2str(((str2double(isUnfixed) + 2 \ 2) - 2)*(-1)), '-', filenames{i}));
    end
    saveName = strcat(saveName, '.jpg');

    %% write triplet HSI in .mat file
    rawImg = hsiUtility.ReadTriplet(content, targetConditions);

    if ~isempty(rawImg)

        %% load HSI from .mat file to verify it is working and to prepare preview images
        config.SetSetting('FileName', targetID);

        rawIm = hsi(rawImg, readForeground, targetID, sampleID, tissueType);

        %% Preprocess HSI and save
        spectralData = Preprocessing(rawIm, targetID);

        %% Read Label
        labelInfo = hsiInfo.ReadHsiInfoFromHsi(spectralData);

        %% Save data info in a file
        filename = commonUtility.GetFilename('dataset', targetID);
        save(filename, 'spectralData', 'labelInfo', '-v7.3');

        %% Plot images
        dispImageRaw = rawIm.GetDisplayRescaledImage('rgb');
        dispImageRgb = spectralData.GetDisplayRescaledImage('rgb');

        close all;

        dispImageRawPath = config.DirMake(basedir, 'rgb', saveName);
        plots.Show(1, dispImageRawPath, dispImageRaw);

        dispImageRgbPath = config.DirMake(basedir, 'preprocessed', saveName);
        plots.Show(2, dispImageRgbPath, dispImageRgb);

        subImagePath = config.DirMake(basedir, 'preprocessed_channels', saveName);
        spectralData.SubimageMontage(3, subImagePath);
    end
end

%% preview of the entire dataset

path1 = fullfile(basedir, 'preprocessed');
plots.MontageFolderContents(1, path1, '*.jpg', 'Dataset');
plots.MontageFolderContents(3, path1, '*raw.jpg', 'Dataset raw');
plots.MontageFolderContents(4, path1, '*fix.jpg', 'Dataset fix');

path2 = fullfile(basedir, 'rgb');
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