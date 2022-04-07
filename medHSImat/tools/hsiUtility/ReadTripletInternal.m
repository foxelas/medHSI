%======================================================================
%> @brief ReadTripletInternal reads and saves the three hyperspectral images
%>
%> The hyperspectral data are saved in .h5 format. The raw, white and black
%> (if exist) images are read one-by-one for the same target. Each HSI is
%> saved in config::[MatDir]\\[Database]\\[TripletsName]\\*_xxx.mat, where
%> xxx is either '_target', '_white' or '_black'.
%>
%> To chose a mask for uni spectrum normalization, set config::['UseCustomMask']
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
% saved in config::[MatDir]\[Database]\[TripletsName]\*_xxx.mat, where
% xxx is either '_target', '_white' or '_black'.
%
% To chose a mask for uni spectrum normalization, set config::['UseCustomMask']
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
if ~isempty(spectralData)

    if ~exist(commonUtility.GetFilename('target', targetName), 'file') ...
            || ~exist(commonUtility.GetFilename('black', targetName), 'file') ...
            || ~exist(commonUtility.GetFilename('white', targetName), 'file')

        plotBaseDir = commonUtility.GetFilename('output', fullfile(config.GetSetting('SnapshotsFolderName'), 'ReadTriplets', targetName), '');

        dispImageRgbPath = config.DirMake(plotBaseDir, strcat(target, '_', num2str(config.GetSetting('IntegrationTime'))));
        plots.Show(1, dispImageRgbPath, GetDisplayImageInternal(spectralData, 'rgb'), 'Target Image');

        filename = config.DirMake(commonUtility.GetFilename('target', targetName));
        fprintf('Target data [spectralData] is saved at %s.\n', filename);
        save(filename, 'spectralData', '-v7.3');

        if ~strcmp(config.GetSetting('Normalization'), 'raw')

            %% White image
            if config.GetSetting('IsTest')
                fcWhite = databaseUtility.GetFileConditions('whiteReflectance', target);
            else
                fcWhite = databaseUtility.GetFileConditions('white', target);
            end
            [filename, ~, ~] = databaseUtility.Query(fcWhite{:});
            if iscell(filename)
                filename = filename{1};
            end
            [white, ~, wavelengths] = hsiUtility.ReadH5(filename);
            savePath = config.DirMake(plotBaseDir, strcat('0_white_', num2str(config.GetSetting('IntegrationTime'))));
            plots.Show(2, savePath, GetDisplayImageInternal(white, 'rgb'), 'White Reference Image');

            fullReflectanceByPixel = white;
            filename = commonUtility.GetFilename('white', targetName);
            fprintf('White data [fullReflectanceByPixel] is saved at %s.\n', filename);

            if config.GetSetting('IsTest')
                %%UniSpectrum
                if config.GetSetting('UseCustomMask')
                    uniMask = GetCustomMaskInternal(white);
                else
                    uniMask = ones(size(white, 1), size(white, 2));
                end
                uniSpectrum = GetMaskedPixelsInternal(white, uniMask);
                plotPath = config.DirMake(plotBaseDir, strcat('0_white_unispectrum_', num2str(config.GetSetting('IntegrationTime'))));
                plots.Spectra(4, plotPath, uniSpectrum, wavelengths, '99%-white', 'Reflectance Spectrum of White Balance Sheet');

                %%BandMax
                [m, n, w] = size(white);
                bandmaxSpectrum = max(reshape(white, m*n, w), [], 1);
                plotPath = config.DirMake(plotBaseDir, strcat('0_white_bandmax_', num2str(config.GetSetting('IntegrationTime'))));
                plots.Spectra(5, plotPath, bandmaxSpectrum, wavelengths, 'Bandmax spectrum', 'Bandmax Spectrum for the current Image');
                save(filename, 'fullReflectanceByPixel', 'uniSpectrum', 'bandmaxSpectrum', '-v7.3');
            else
                save(filename, 'fullReflectanceByPixel', '-v7.3');
            end

            %% Black Image
            if config.GetSetting('IsTest')
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
            savePath = config.DirMake(plotBaseDir, strcat('0_black_', num2str(config.GetSetting('IntegrationTime'))));
            plots.Show(3, savePath, GetDisplayImageInternal(blackReflectance, 'rgb'), 'Black Reference Image');

            filename = commonUtility.GetFilename('black', targetName);
            fprintf('Black data [blackReflectance] is saved at %s.\n', filename);
            save(filename, 'blackReflectance', '-v7.3');
        else
            disp('Read only capture data, ignore white and black images.');
        end
    else
        disp('Triplet files already exist.');
    end
else
    spectralData = [];
end

end