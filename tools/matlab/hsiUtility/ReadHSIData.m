function [spectralData] = ReadHSIData(content, target, experiment, blackIsCapOn)
%%ReadHSIData returns the three images necessary for data analysis
%
%   Usage:
%   [raw] = ReadHSIData(content, target, experiment, blackIsCapOn)

if nargin < 4
    blackIsCapOn = false;
end

baseDir = Config.DirMake(Config.GetSetting('matDir'), strcat(Config.GetSetting('database'), 'Triplets\'));

%% Target image
fcTarget = DB.GetFileConditions(content, target);
[filename, tableId] = DB.GetFilename(fcTarget{:});
saveName = fullfile(baseDir, num2str(tableId));
[spectralData, ~, ~] = HsiUtility.LoadH5Data(filename);
snapshotFolder = Config.GetSetting('snapshots');
plotBaseDir = fullfile(Config.GetSetting('saveDir'), snapshotFolder, Config.GetSetting('experiment'));

if ~exist(strcat(saveName, '_target.mat'), 'file') ...
        || ~exist(strcat(saveName, '_black.mat'), 'file') ...
        || ~exist(strcat(saveName, '_white.mat'), 'file')
    figure(1);
    imshow(HsiUtility.GetDisplayImage(spectralData, 'rgb'));
    Config.SetSetting('plotName', Config.DirMake(plotBaseDir, strcat(target, '_', num2str(Config.GetSetting('integrationTime')))));
    Plots.SavePlot(1);
    save(strcat(saveName, '_target.mat'), 'spectralData', '-v7.3');

    if ~strcmp(Config.GetSetting('normalization'), 'raw')

        %% White image
        if Config.GetSetting('isTest')
            fcWhite = DB.GetFileConditions('whiteReflectance', target);
        else
            fcWhite = DB.GetFileConditions('white', target);
        end
        filename = DB.GetFilename(fcWhite{:});
        [white, ~, wavelengths] = HsiUtility.LoadH5Data(filename);
        figure(2);
        imshow(HsiUtility.GetDisplayImage(white, 'rgb'));
        Config.SetSetting('plotName', Config.DirMake(plotBaseDir, strcat('0_white_', num2str(Config.GetSetting('integrationTime')))));
        SavePlot(2);

        %%UniSpectrum
        uniSpectrum = HsiUtility.GetSpectraFromMask(white);
        Config.SetSetting('plotName', Config.DirMake(plotBaseDir, strcat('0_white_unispectrum_', num2str(GetSetting('integrationTime')))));
        Plots.Spectra(4, uniSpectrum, wavelengths, '99%-white', 'Reflectance Spectrum of White Balance Sheet');

        %%BandMax
        [m, n, w] = size(white);
        bandmaxSpectrum = max(reshape(white, m*n, w), [], 1);
        Config.SetSetting('plotName', Config.DirMake(plotBaseDir, strcat('0_white_bandmax_', num2str(Config.GetSetting('integrationTime')))));
        Plots.Spectra(5, bandmaxSpectrum, wavelengths, 'Bandmax spectrum', 'Bandmax Spectrum for the current Image');

        fullReflectanceByPixel = white;
        save(strcat(saveName, '_white.mat'), 'fullReflectanceByPixel', 'uniSpectrum', 'bandmaxSpectrum', '-v7.3');

        %% Black Image
        if Config.GetSetting('isTest')
            if blackIsCapOn
                fcBlack = DB.GetFileConditions('capOn', target);
            else
                fcBlack = DB.GetFileConditions('lightsOff', target);
            end
        else
            fcBlack = DB.GetFileConditions('black', target);
        end
        filename = DB.GetFilename(fcBlack{:});
        [blackReflectance, ~, ~] = HsiUtility.LoadH5Data(filename);
        figure(3);
        imshow(HsiUtility.GetDisplayImage(blackReflectance, 'rgb'));
        Config.SetSetting('plotName', Config.DirMake(plotBaseDir, strcat('0_black_', num2str(Config.GetSetting('integrationTime')))));
        Plots.SavePlot(3);

        save(strcat(saveName, '_black.mat'), 'blackReflectance', '-v7.3');
    else
        disp('Read only capture data, ignore white and black images.');
    end
end

end