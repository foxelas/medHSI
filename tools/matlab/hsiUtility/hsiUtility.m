classdef HsiUtility
    methods (Static)
        % Contents
        %
        %     Static:
        %         [x] = GetWavelengths(m, option)
        %         [] = ExportH5Dataset(condition)
        %         [] = InitializeDataGroup(experiment, condition)
        %         [spectralData] = NormalizeHSI(targetName, option, saveFile)
        %         [dispImage] = GetDisplayImage(varargin)
        %         [spectrumCurves] = GetSpectraFromMask(varargin)
        %         [spectralData, imageXYZ, wavelengths] = LoadH5Data(filename)
        %         [spectralData] = ReadHSIData(content, target, experiment, blackIsCapOn)
        %         [spectralData] = ReadStoredHSI(targetName, normalization)
        %         [redHsis] = ReconstructDimred(scores, imgSizes, masks)
        %         [outHsi] = RecoverReducedHsi(redHsi, origSize, mask)

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
                    splitWavelength = Config.GetSetting('splitWavelength');
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
                    x = HsiUtility.GetWavelengths(m, 'raw');
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

            normalization = Config.GetSetting('normalization');
            if strcmp(normalization, 'raw')
                fileName = Config.DirMake(Config.GetSetting('outputDir'), Config.GetSetting('datasets'), strcat('hsi_raw_full', '.h5'));
            else
                fileName = Config.DirMake(Config.GetSetting('outputDir'), Config.GetSetting('datasets'), strcat('hsi_normalized_full', '.h5'));
            end

            %% Read h5 data
            [~, targetIDs, ~] = DB.Query(condition);

            for i = 1:length(targetIDs)
                id = targetIDs(i);

                %% load HSI from .mat file
                targetName = num2str(id);
                spectralData = HsiUtility.ReadStoredHSI(targetName, normalization);

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

            Config.SetSetting('experiment', experiment);
            Config.SetSetting('cropBorders', true);
            Config.SetSetting('saveFolder', fullfile(Config.GetSetting('snapshots'), experiment));
            isTest = Config.GetSetting('isTest');
            saveMatFile = true;

            %% Read h5 data
            [filenames, targetIDs, outRows] = DB.Query(condition);

            integrationTimes = [outRows.IntegrationTime];
            dates = [outRows.CaptureDate];
            if isTest
                configurations = [outRows.Configuration];
            end

            for i = 19 %1:length(targetIDs)
                id = targetIDs(i);
                target = DataUtility.GetValueFromTable(outRows, 'Target', i);
                content = DataUtility.GetValueFromTable(outRows, 'Content', i);
                Config.SetSetting('integrationTime', integrationTimes(i));
                Config.SetSetting('dataDate', num2str(dates(i)));
                if isTest
                    Config.SetSetting('configuration', configurations{i});
                end

                saveName = DataUtility.StrrepAll(strcat(outRows{i, 'SampleID'}, '_', num2str(((str2double(outRows{i, 'IsUnfixed'}) + 2 \ 2) - 2)*(-1)), '-', filenames{i}));

                %% write HSI in .mat file
                DataUtility.ReadHSIData(content, target, experiment);

                %% load HSI from .mat file to verify it is working and to prepare preview images
                targetName = num2str(id);
                spectralData = Hsi;
                spectralData.Value = DataUtility.ReadStoredHSI(targetName);
                dispImage = spectralData.GetDisplayRescaledImage('rgb');
                figure(1);
                imshow(dispImage);
                SetSetting('plotName', Config.DirMake(Config.GetSetting('saveDir'), Config.GetSetting('saveFolder'), 'rgb', saveName));
                SavePlot(1);

                %% write normalized HSI in .mat file
                spectralData = HsiUtility.NormalizeHSI(targetName, Config.GetSetting('normalization'), saveMatFile);

                %% prepare preview from normalized HSI
                dispImage = spectralData.GetDisplayRescaledImage('rgb');
                figure(2);
                imshow(dispImage);
                SetSetting('plotName', Config.DirMake(Config.GetSetting('saveDir'), Config.GetSetting('saveFolder'), 'normalized', saveName));
                SavePlot(2);
            end

            %% preview of the entire dataset

            path1 = fullfile(Config.GetSetting('saveDir'), Config.GetSetting('saveFolder'), 'normalized');
            Plots(1, @MontageFolderContents, path1, '*.jpg', 'Normalized');
            Plots(3, @MontageFolderContents, path1, '*raw.jpg', 'Normalized raw');
            Plots(4, @MontageFolderContents, path1, '*fix.jpg', 'Normalized fix');

            path2 = fullfile(Config.GetSetting('saveDir'), Config.GetSetting('saveFolder'), 'rgb');
            Plots(2, @MontageFolderContents, path2, '*.jpg', 'sRGB');
            Plots(5, @MontageFolderContents, path2, '*raw.jpg', 'sRGB raw');
            Plots(6, @MontageFolderContents, path2, '*fix.jpg', 'sRGB fix');

            close all;
        end

        function [spectralData] = NormalizeHSI(varargin)
            %NormalizeHSI returns spectral data from HSI image
            %
            %   Usage:
            %   spectralData = NormalizeHSI('sample2') returns a
            %   cropped HSI with 'byPixel' normalization
            %
            %   spectralData = NormalizeHSI('sample2', 'raw')
            %   spectralData = NormalizeHSI('sample2', 'byPixel', true)
            spectralData = NormalizeHSI(varargin{:});
        end

        function [dispImage] = GetDisplayImage(varargin)
            dispImage = GetDisplayImageInternal(varargin{:});
        end

        function [spectrumCurves] = GetSpectraFromMask(varargin)
            %%GetSpectraFromMask returns the average spectrum of a specific ROI mask
            %
            %   Usage:
            %   spectrumCurves = GetSpectraFromMask(target, subMasks, targetMask)
            spectrumCurves = GetSpectraFromMaskInternal(varargin{:});
        end

        function [spectralData, imageXYZ, wavelengths] = LoadH5Data(filename)
            %LOADH5DATA loads info from h5 file
            %
            %   Usage:
            %   [spectralData, imageXYZ, wavelengths] = LoadH5Data(filename)
            %   returns spectralData, XYZ image and capture wavelengths
            [spectralData, imageXYZ, wavelengths] = LoadH5Data(filename);
        end

        function [spectralData] = ReadHSIData(varargin)
            %%ReadHSIData returns the three images necessary for data analysis
            %
            %   Usage:
            %   [raw] = ReadHSIData(target, experiment, blackIsCapOn)

            [spectralData] = ReadHSIData(varargin{:});
        end

        function [spectralData] = ReadStoredHSI(varargin)
            % ReadStoredHSI reads a stored HSI from a _target mat file
            %
            %   Usage:
            %   [spectralData] = ReadStoredHSI(targetName)
            %   [spectralData] = ReadStoredHSI(targetName, 'byPixel')
            [spectralData] = ReadStoredHSI(varargin{:});
        end

        function [redHsis] = ReconstructDimred(scores, imgSizes, masks)
            % ReconstructDimred reconstructs reduced data to original dimension
            %
            %   Input arguments:
            %   scores: reduced dimension data
            %   imgSizes: cell array with original sizes of input data
            %   masks: cell array of masks per data sample
            %
            %   Returns:
            %   Reduced data with original spatial dimensions
            %
            %   Usage:
            %   redHsis = ReconstructDimred(scores, imgSizes, masks);
            [redHsis] = ReconstructDimred(scores, imgSizes, masks);
        end

        function [outHsi] = RecoverReducedHsi(redHsi, origSize, mask)
            % RecoverReducedHsi returns an image that matches the spatial dimensions
            %   of the original hsi
            %
            %   Usage:
            %   [outHsi] = RecoverReducedHsi(redHsi, origSize, mask)
            [outHsi] = RecoverReducedHsi(redHsi, origSize, mask);
        end
    end
end
