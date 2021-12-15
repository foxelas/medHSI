classdef hsiUtility  
    methods (Static)
% Contents
% 
%     Static:
%         GetWavelengths
%         ExportH5Dataset
%         InitializeDataGroup
%         NormalizeHSI
%         LoadH5Data
%         ReadHSIData
%         ReadStoredHSI
%         ReconstructDimred
%         RecoverReducedHsi
        
        function [x] = GetWavelengths(m, option)
        %GETWAVELENGTHS returns the wavelengths
        %
        %   Usage:
        %   x = GetWavelengths(m) returns wavelengths as a vector of wavelengths
        %   x = GetWavelengths(m, 'raw') returns wavelengths as a vecrtor of
        %   wavelengths
        %   x = GetWavelengths(m, 'index') returns indexes respective to selected
        %   wavelengths
        %   x = GetWavelengths(m, 'babel') returns indexes respective to selected
        %   wavelengths for babel standard spectra
        %

        if nargin < 2
            option = 'raw';
        end

        switch option
            case 'raw'
                splitWavelength = GetSetting('splitWavelength');
                if m == 401
                    x = 380:780;
                elseif m == 36
                    x = 380:10:730;
                elseif m == 32
                    x = 420:10:730; % range [420,730];
                elseif m == 17
                    x = 380:10:splitWavelength;
                elseif m == 19
                    x = (splitWavelength + 1):10:730;
                elseif m == 161
                    x = 380:splitWavelength;
                elseif m == 240
                    x = (splitWavelength + 1):780;
                elseif m == 311
                    x = 420:730;
                else
                    error('Unsupported wavelength range');
                end

            case 'index'
                x = GetWavelengths(m, 'raw');
                x = x - 380 + 1;

            case 'babel'
                if m == 36
                    x = 1:36;
                elseif m == 17
                    x = 1:17;
                elseif m == 19
                    x = 18:36;
                else
                    error('Unsupported wavelengths range');
                end

            otherwise
                error('Unsupported option.')

        end

        end
        
        function [] = ExportH5Dataset(condition)
            %% EXPORTH5DATASET aggregates .mat files per sample to a large h5 dataset
            %
            %   Usage:
            %   ExportH5Dataset({'tissue', true});

            %% Setup
            disp('Initializing [InitializeDataGroup]...');

            normalization = GetSetting('normalization');
            if strcmp(normalization, 'raw')
                fileName = DirMake(GetSetting('outputDir'), GetSetting('datasets'), strcat('hsi_raw_full', '.h5'));
            else
                fileName = DirMake(GetSetting('outputDir'), GetSetting('datasets'), strcat('hsi_normalized_full', '.h5'));
            end

            %% Read h5 data
            [~, targetIDs, ~] = Query(condition);

            for i = 1:length(targetIDs)
                id = targetIDs(i);

                %% load HSI from .mat file
                targetName = num2str(id);
                spectralData = ReadStoredHSI(targetName, normalization);

                curName = strcat('/sample', targetName);
                h5create(fileName, curName, size(spectralData));
                h5write(fileName, curName, spectralData);
            end

            h5disp(fileName);

        end
        
        function [] = InitializeDataGroup(experiment, condition)
        % InitializeDataGroup reads a group of hsi data, prepares .mat files,
        % prepared normalized files and returns montage previews of contents
        %
        %   Usage:
        %   InitializeDataGroup('handsOnly',{'hand', false})
        %   InitializeDataGroup('sample001-tissue', {'tissue', true});

        %% Setup
        disp('Initializing [InitializeDataGroup]...');

        SetSetting('experiment', experiment);
        SetSetting('cropBorders', true);
        SetSetting('saveFolder', fullfile(GetSetting('snapshots'), experiment));
        isTest = GetSetting('isTest');
        saveMatFile = true;

        %% Read h5 data
        [filenames, targetIDs, outRows] = Query(condition);

        integrationTimes = [outRows.IntegrationTime];
        dates = [outRows.CaptureDate];
        if isTest
            configurations = [outRows.Configuration];
        end

        for i = 19 %1:length(targetIDs)
            id = targetIDs(i);
            target = GetValueFromTable(outRows, 'Target', i);
            content = GetValueFromTable(outRows, 'Content', i);
            SetSetting('integrationTime', integrationTimes(i));
            SetSetting('dataDate', num2str(dates(i)));
            if isTest
                SetSetting('configuration', configurations{i});
            end

            saveName = StrrepAll(strcat(outRows{i, 'SampleID'}, '_', num2str(((str2double(outRows{i, 'IsUnfixed'}) + 2 \ 2) - 2)*(-1)), '-', filenames{i}));

            %% write HSI in .mat file
            ReadHSIData(content, target, experiment);

            %% load HSI from .mat file to verify it is working and to prepare preview images
            targetName = num2str(id);
            spectralData = ReadStoredHSI(targetName);
            dispImage = GetDisplayImage(rescale(spectralData), 'rgb');
            figure(1);
            imshow(dispImage);
            SetSetting('plotName', DirMake(GetSetting('saveDir'), GetSetting('saveFolder'), 'rgb', saveName));
            SavePlot(1);

            %% write normalized HSI in .mat file
            spectralData = NormalizeHSI(targetName, GetSetting('normalization'), saveMatFile);

            %% prepare preview from normalized HSI
            dispImage = GetDisplayImage(rescale(spectralData), 'rgb');
            figure(2);
            imshow(dispImage);
            SetSetting('plotName', DirMake(GetSetting('saveDir'), GetSetting('saveFolder'), 'normalized', saveName));
            SavePlot(2);
        end

        %% preview of the entire dataset

        path1 = fullfile(GetSetting('saveDir'), GetSetting('saveFolder'), 'normalized');
        Plots(1, @MontageFolderContents, path1, '*.jpg', 'Normalized');
        Plots(3, @MontageFolderContents, path1, '*raw.jpg', 'Normalized raw');
        Plots(4, @MontageFolderContents, path1, '*fix.jpg', 'Normalized fix');

        path2 = fullfile(GetSetting('saveDir'), GetSetting('saveFolder'), 'rgb');
        Plots(2, @MontageFolderContents, path2, '*.jpg', 'sRGB');
        Plots(5, @MontageFolderContents, path2, '*raw.jpg', 'sRGB raw');
        Plots(6, @MontageFolderContents, path2, '*fix.jpg', 'sRGB fix');

        close all;
        end
        
        function spectralData = NormalizeHSI(targetName, option, saveFile)
             spectralData = NormalizeHSI(targetName, option, saveFile);
        end
        
        function [spectralData, imageXYZ, wavelengths] = LoadH5Data(filename)
            [spectralData, imageXYZ, wavelengths] = LoadH5Data(filename);
        end
        
        function [spectralData] = ReadHSIData(content, target, experiment, blackIsCapOn)
            [spectralData] = ReadHSIData(content, target, experiment, blackIsCapOn);
        end
        
        function [spectralData] = ReadStoredHSI(targetName, normalization)
            [spectralData] = ReadStoredHSI(targetName, normalization);
        end
        
        function [redHsis] = ReconstructDimred(scores, imgSizes, masks)
            [redHsis] = ReconstructDimred(scores, imgSizes, masks);
        end
        
        function [outHsi] = RecoverReducedHsi(redHsi, origSize, mask)
            [outHsi] = RecoverReducedHsi(redHsi, origSize, mask);
        end
    end
end
