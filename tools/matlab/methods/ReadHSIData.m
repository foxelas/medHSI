function [spectralData] = ReadHSIData(content, target, experiment, blackIsCapOn)
%%ReadHSIData returns the three images necessary for data analysis
%
%   Usage:
%   [raw] = ReadHSIData(target, experiment, blackIsCapOn)

if nargin < 4
    blackIsCapOn = false;
end

baseDir = DirMake(GetSetting('matDir'), strcat(GetSetting('database'), 'Triplets\'));

%% Target image
fcTarget = GetFileConditions(content, target);
[filename, tableId] = GetFilename(fcTarget{:});
saveName = fullfile(baseDir, num2str(tableId));
[spectralData, ~, ~] = LoadH5Data(filename);
snapshotFolder = GetSetting('snapshots');
plotBaseDir = fullfile(GetSetting('saveDir'), snapshotFolder, GetSetting('experiment'));

if ~exist(strcat(saveName, '_target.mat'), 'file') || ~exist(strcat(saveName, '_black.mat'), 'file') || ~exist(strcat(saveName, '_white.mat'), 'file')
    figure(1);
    imshow(GetDisplayImage(spectralData, 'rgb'));
    SetSetting('plotName', DirMake(plotBaseDir, strcat(target, '_', num2str(GetSetting('integrationTime')))));
    SavePlot(1);
    save(strcat(saveName, '_target.mat'), 'spectralData', '-v7.3');

    if ~strcmp(GetSetting('normalization'), 'raw')

        %% White image
        if GetSetting('isTest')
            fcWhite = GetFileConditions('whiteReflectance', target);
        else
            fcWhite = GetFileConditions('white', target);
        end 
        filename = GetFilename(fcWhite{:});
        [white, ~, wavelengths] = LoadH5Data(filename);
        figure(2);
        imshow(GetDisplayImage(white, 'rgb'));
        SetSetting('plotName', DirMake(plotBaseDir, strcat('0_white_', num2str(GetSetting('integrationTime')))));
        SavePlot(2);

        %%UniSpectrum
        uniSpectrum = GetSpectraFromMask(white);
        SetSetting('plotName', DirMake(plotBaseDir, strcat('0_white_unispectrum_', num2str(GetSetting('integrationTime')))));
        Plots(4, @PlotSpectra, uniSpectrum, wavelengths, '99%-white', 'Reflectance Spectrum of White Balance Sheet');

        %%BandMax
        [m, n, w] = size(white);
        bandmaxSpectrum = max(reshape(white, m*n, w), [], 1);
        SetSetting('plotName', DirMake(plotBaseDir, strcat('0_white_bandmax_', num2str(GetSetting('integrationTime')))));
        Plots(5, @PlotSpectra, bandmaxSpectrum, wavelengths, 'Bandmax spectrum', 'Bandmax Spectrum for the current Image');

        fullReflectanceByPixel = white;
        save(strcat(saveName, '_white.mat'), 'fullReflectanceByPixel', 'uniSpectrum', 'bandmaxSpectrum', '-v7.3');

        %% Black Image
        if GetSetting('isTest')
            if blackIsCapOn
                fcBlack = GetFileConditions('capOn', target);
            else
                fcBlack = GetFileConditions('lightsOff', target);
            end
        else
            fcBlack = GetFileConditions('black', target);
        end 
        filename = GetFilename(fcBlack{:});
        [blackReflectance, ~, ~] = LoadH5Data(filename);
        figure(3);
        imshow(GetDisplayImage(blackReflectance, 'rgb'));
        SetSetting('plotName', DirMake(plotBaseDir, strcat('0_black_', num2str(GetSetting('integrationTime')))));
        SavePlot(3);

        save(strcat(saveName, '_black.mat'), 'blackReflectance', '-v7.3');
    else
        disp('Read only capture data, ignore white and black images.');
    end
end

end