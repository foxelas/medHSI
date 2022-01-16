function [spectralData] = ReadHSIDataInternal(content, target, experiment, blackIsCapOn)
%%ReadHSIDataInternal returns the three images necessary for data analysis
%
%   Usage:
%   [raw] = ReadHSIDataInternal(content, target, experiment, blackIsCapOn)

if nargin < 4
    blackIsCapOn = false;
end

baseDir = config.DirMake(config.GetSetting('matDir'), strcat(config.GetSetting('database'), 'Triplets\'));

%% Target image
fcTarget = databaseUtility.GetFileConditions(content, target);
[filename, tableId] = databaseUtility.GetFilename(fcTarget{:});
saveName = fullfile(baseDir, num2str(tableId));
[spectralData, ~, ~] = hsiUtility.LoadH5Data(filename);
snapshotFolder = config.GetSetting('snapshots');
plotBaseDir = fullfile(config.GetSetting('saveDir'), snapshotFolder, config.GetSetting('experiment'));

if ~exist(strcat(saveName, '_target.mat'), 'file') ...
        || ~exist(strcat(saveName, '_black.mat'), 'file') ...
        || ~exist(strcat(saveName, '_white.mat'), 'file')
    figure(1);
    imshow(hsiUtility.GetDisplayImage(spectralData, 'rgb'));
    config.SetSetting('plotName', config.DirMake(plotBaseDir, strcat(target, '_', num2str(config.GetSetting('integrationTime')))));
    plots.SavePlot(1);
    save(strcat(saveName, '_target.mat'), 'spectralData', '-v7.3');

    if ~strcmp(config.GetSetting('normalization'), 'raw')

        %% White image
        if config.GetSetting('isTest')
            fcWhite = databaseUtility.GetFileConditions('whiteReflectance', target);
        else
            fcWhite = databaseUtility.GetFileConditions('white', target);
        end
        filename = databaseUtility.GetFilename(fcWhite{:});
        [white, ~, wavelengths] = hsiUtility.LoadH5Data(filename);
        figure(2);
        imshow(hsiUtility.GetDisplayImage(white, 'rgb'));
        config.SetSetting('plotName', config.DirMake(plotBaseDir, strcat('0_white_', num2str(config.GetSetting('integrationTime')))));
        SavePlot(2);

        %%UniSpectrum
        uniSpectrum = hsiUtility.GetSpectraFromMask(white);
        config.SetSetting('plotName', config.DirMake(plotBaseDir, strcat('0_white_unispectrum_', num2str(config.GetSetting('integrationTime')))));
        plots.Spectra(4, uniSpectrum, wavelengths, '99%-white', 'Reflectance Spectrum of White Balance Sheet');

        %%BandMax
        [m, n, w] = size(white);
        bandmaxSpectrum = max(reshape(white, m*n, w), [], 1);
        config.SetSetting('plotName', config.DirMake(plotBaseDir, strcat('0_white_bandmax_', num2str(config.GetSetting('integrationTime')))));
        plots.Spectra(5, bandmaxSpectrum, wavelengths, 'Bandmax spectrum', 'Bandmax Spectrum for the current Image');

        fullReflectanceByPixel = white;
        save(strcat(saveName, '_white.mat'), 'fullReflectanceByPixel', 'uniSpectrum', 'bandmaxSpectrum', '-v7.3');

        %% Black Image
        if config.GetSetting('isTest')
            if blackIsCapOn
                fcBlack = databaseUtility.GetFileConditions('capOn', target);
            else
                fcBlack = databaseUtility.GetFileConditions('lightsOff', target);
            end
        else
            fcBlack = databaseUtility.GetFileConditions('black', target);
        end
        filename = databaseUtility.GetFilename(fcBlack{:});
        [blackReflectance, ~, ~] = hsiUtility.LoadH5Data(filename);
        figure(3);
        imshow(hsiUtility.GetDisplayImage(blackReflectance, 'rgb'));
        config.SetSetting('plotName', config.DirMake(plotBaseDir, strcat('0_black_', num2str(config.GetSetting('integrationTime')))));
        plots.SavePlot(3);

        save(strcat(saveName, '_black.mat'), 'blackReflectance', '-v7.3');
    else
        disp('Read only capture data, ignore white and black images.');
    end
end

end