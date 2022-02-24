%======================================================================
%> @brief ReadTripletInternal reads and saves the three hyperspectral images
%>
%> The hyperspectral data are saved in .h5 format. The raw, white and black
%> (if exist) images are read one-by-one for the same target. Each HSI is
%> saved in config::[matDir]\\[database]\\[tripletsName]\\*_xxx.mat, where
%> xxx is either '_target', '_white' or '_black'.
%>
%> @b Usage
%>
%> @code
%> content = 'tissue';
%> target = '001_raw';
%> spectralData = ReadTripletInternal(content, target);
%>
%> spectralData = ReadTripletInternal(content, target, blackIsCapOn);
%> @endcode
%>
%> @param content [cell array] | Contains the content to be imported
%> @param target [char] | Contains the target to be imported
%> @param blackIsCapOn [logical] | Flag about the use of blackCap for dark image
%>
%> @retval spectralData [numeric array] | The target (tissue) hyperspectral image
%======================================================================
function [spectralData] = ReadTripletInternal(content, target, blackIsCapOn)
% ReadTripletInternal reads and saves the three hyperspectral images
%
% The hyperspectral data are saved in .h5 format. The raw, white and black
% (if exist) images are read one-by-one for the same target. Each HSI is
% saved in config::[matDir]\[database]\[tripletsName]\*_xxx.mat, where
% xxx is either '_target', '_white' or '_black'.
%
% @b Usage
%
% @code
% content = 'tissue';
% target = '001_raw';
% spectralData = ReadTripletInternal(content, target);
%
% spectralData = ReadTripletInternal(content, target, blackIsCapOn);
% @endcode
%
% @param content [cell array] | Contains the content to be imported
% @param target [char] | Contains the target to be imported
% @param blackIsCapOn [logical] | Flag about the use of blackCap for dark image
%
% @retval spectralData [numeric array] | The target (tissue) hyperspectral image

if nargin < 3
    blackIsCapOn = false;
end

%% Target image
fcTarget = databaseUtility.GetFileConditions(content, target);
[filename, tableId, ~] = databaseUtility.Query(fcTarget{:});
if iscell(filename)
    filename = filename{1};
end
targetName = num2str(tableId);
[spectralData, ~, ~] = hsiUtility.ReadH5(filename);

if ~exist(commonUtility.GetFilename('target', targetName), 'file') ...
        || ~exist(commonUtility.GetFilename('black', targetName), 'file') ...
        || ~exist(commonUtility.GetFilename('white', targetName), 'file')

    plotBaseDir = fullfile(config.GetSetting('outputDir'), config.GetSetting('snapshotsFolderName'), 'ReadTriplets', targetName);
    figure(1);
    title('Target Image');
    imshow(GetDisplayImageInternal(spectralData, 'rgb'));
    config.SetSetting('plotName', config.DirMake(plotBaseDir, strcat(target, '_', num2str(config.GetSetting('integrationTime')))));
    plots.SavePlot(1);
    filename = config.DirMake(commonUtility.GetFilename('target', targetName));
    fprintf('Target data [spectralData] is saved at %s.\n', filename);
    save(filename, 'spectralData', '-v7.3');

    if ~strcmp(config.GetSetting('normalization'), 'raw')

        %% White image
        if config.GetSetting('isTest')
            fcWhite = databaseUtility.GetFileConditions('whiteReflectance', target);
        else
            fcWhite = databaseUtility.GetFileConditions('white', target);
        end
        [filename, ~, ~] = databaseUtility.Query(fcWhite{:});
        if iscell(filename)
            filename = filename{1};
        end
        [white, ~, wavelengths] = hsiUtility.ReadH5(filename);
        figure(2);
        title('White Reference Image');
        imshow(GetDisplayImageInternal(white, 'rgb'));
        config.SetSetting('plotName', config.DirMake(plotBaseDir, strcat('0_white_', num2str(config.GetSetting('integrationTime')))));
        SavePlot(2);

        %%UniSpectrum
        uniMask = GetCustomMaskInternal(white);
        uniSpectrum = GetMaskedPixelsInternal(white, uniMask);
        config.SetSetting('plotName', config.DirMake(plotBaseDir, strcat('0_white_unispectrum_', num2str(config.GetSetting('integrationTime')))));
        plots.Spectra(4, uniSpectrum, wavelengths, '99%-white', 'Reflectance Spectrum of White Balance Sheet');

        %%BandMax
        [m, n, w] = size(white);
        bandmaxSpectrum = max(reshape(white, m*n, w), [], 1);
        config.SetSetting('plotName', config.DirMake(plotBaseDir, strcat('0_white_bandmax_', num2str(config.GetSetting('integrationTime')))));
        plots.Spectra(5, bandmaxSpectrum, wavelengths, 'Bandmax spectrum', 'Bandmax Spectrum for the current Image');

        fullReflectanceByPixel = white;
        filename = commonUtility.GetFilename('white', targetName);
        fprintf('White data [fullReflectanceByPixel] is saved at %s.\n', filename);
        save(filename, 'fullReflectanceByPixel', 'uniSpectrum', 'bandmaxSpectrum', '-v7.3');

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
        [filename, ~, ~] = databaseUtility.Query(fcBlack{:});
        if iscell(filename)
            filename = filename{1};
        end
        [blackReflectance, ~, ~] = hsiUtility.ReadH5(filename);
        figure(3);
        title('Black Reference Image');
        imshow(GetDisplayImageInternal(blackReflectance, 'rgb'));
        config.SetSetting('plotName', config.DirMake(plotBaseDir, strcat('0_black_', num2str(config.GetSetting('integrationTime')))));
        plots.SavePlot(3);

        filename = commonUtility.GetFilename('black', targetName);
        fprintf('Black data [blackReflectance] is saved at %s.\n', filename);
        save(filename, 'blackReflectance', '-v7.3');
    else
        disp('Read only capture data, ignore white and black images.');
    end
else
    disp('Triple files already exist.');
end

end