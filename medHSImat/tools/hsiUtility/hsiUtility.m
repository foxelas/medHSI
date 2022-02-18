classdef hsiUtility
    methods (Static)
        % Contents
        %
        %     Static:
        %         %% System properties
        %         [x] = GetWavelengths(m, option)
        %
        %         %% Input/Output
        %         [labelMask] = ReadLabel(targetName)
        %         [spectralData, imageXYZ, wavelengths] = LoadH5Data(filename)
        %         [hsIm] = ReadHSI(content, target, experiment, blackIsCapOn)
        %         [hsIm] = LoadHSI(targetName, dataType)
        %         [hsIm, label] = LoadHSIAndLabel(targetName, dataType)
        %         [hsIm] = Preprocess(targetName, option, saveFile)
        %
        %         %% Dataset
        %         [] = ExportH5Dataset()
        %         [] = ReadDataset(experiment, condition)
        %
        %         %% References
        %         [spectralData] = LoadHSIReference(targetName, refType)
        %         [refLib] = PrepareReferenceLibrary(targetIDs, disease)
        %         [refLib] = GetReferenceLibrary()

        %% System properties %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
                    splitWavelength = config.GetSetting('splitWavelength');
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
                    x = hsiUtility.GetWavelengths(m, 'raw');
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

        %% Input/Output %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function [labelMask] = ReadLabel(targetName)
            %ReadLabelImage returns the label image for each HSI
            %
            %   [labelMask] = ReadLabelImage(targetName);

            if isnumeric(targetName)
                targetName = num2str(targetName);
            end

            baseDir = fullfile(config.GetSetting('matDir'), ...
                strcat(config.GetSetting('database'), config.GetSetting('labelsName')), targetName);
            targetFilename = strcat(baseDir, '_label.mat');

            if exist(targetFilename, 'file')
                load(targetFilename, 'labelMask');
            else
                labelMask = [];
            end
        end

        function [spectralData, imageXYZ, wavelengths] = LoadH5Data(filename)
            %LOADH5DATA loads info from h5 file
            %
            %   Usage:
            %   [spectralData, imageXYZ, wavelengths] = LoadH5Data(filename)
            %   returns spectralData, XYZ image and capture wavelengths
            [spectralData, imageXYZ, wavelengths] = LoadH5Data(filename);
        end

        function [hsIm] = ReadHSI(varargin)
            %%ReadHSI returns the three images necessary for data analysis
            %
            %   Usage:
            %   [raw] = ReadHSI(target, experiment, blackIsCapOn)

            [hsIm] = ReadHSIInternal(varargin{:});
        end

        function [hsIm] = LoadHSI(varargin)
            % LoadHSI reads a stored HSI from a .mat file
            %
            %   Input
            %   targetName: a string with the target id
            %   dataType: 'raw', 'dataset' or 'preprocessed'
            %
            %   Usage:
            %   [spectralData] = LoadHSI(targetName)
            %   [spectralData] = LoadHSI(targetName)
            [hsIm, ~] = LoadHSIInternal(varargin{:});
        end
        
        function [hsIm, label] = LoadHSIAndLabel(varargin)
            % LoadHSIAndLabel reads a stored HSI and a label array from 
            % a .mat file 
            %
            %   Input
            %   targetName: a string with the target id
            %   dataType: 'raw', 'dataset' or 'preprocessed'
            %
            %   Usage:
            %   [spectralData, label] = LoadHSIAndLabel(targetName)
            %   [spectralData, label] = LoadHSIAndLabel(targetName)
            [hsIm, label] = LoadHSIInternal(varargin{:});
        end

        function [hsIm] = Preprocess(varargin)
            %LoadAndPreprocess returns spectral data from HSI image
            %
            %   Usage:
            %   spectralData = LoadAndPreprocess('sample2') returns a
            %   cropped HSI with 'byPixel' normalization
            %
            %   spectralData = LoadAndPreprocess('sample2', 'raw')
            %   spectralData = LoadAndPreprocess('sample2', 'byPixel', true)
            hsIm = LoadAndPreprocess(varargin{:});
        end

        %% Dataset %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [] = ExportH5Dataset()
            %% EXPORTH5DATASET aggregates .mat files per sample to a large h5 dataset
            %   Reads from the 'dataset' value in config.ini
            %
            %   Usage:
            %   ExportH5Dataset();

            %% Setup
            disp('Initializing [ExportH5Dataset]...');

            fileName = config.DirMake(config.GetSetting('outputDir'), config.GetSetting('datasets'), strcat('hsi_', config.GetSetting('dataset'), '_full', '.h5'));      
            [~, targetIDs] = dataUtility.DatasetInfo();
            
            for i = 1:length(targetIDs)
                %% load HSI from .mat file
                targetName = num2str(targetIDs{i});
                [spectralData, label] = hsiUtility.LoadHSIAndLabel(targetName, 'dataset');
                if isempty(label)
                    label = nan;
                end
                
                if (hsi.IsHsi(spectralData))
                    dataValue = spectralData.Value;
                    dataMask = uint8(spectralData.FgMask);
                    curName = strcat('/hsi/sample', targetName);
                    h5create(fileName, curName, size(dataValue));
                    h5write(fileName, curName, dataValue);

                    curName = strcat('/mask/sample', targetName);
                    h5create(fileName, curName, size(dataMask));
                    h5write(fileName, curName, dataMask);
                    
                    curName = strcat('/label/sample', targetName);
                    h5create(fileName, curName, size(label));
                    h5write(fileName, curName, uint8(label));

                else
                    dataValue = spectralData;
                    curName = strcat('/hsi/sample', targetName);
                    h5create(fileName, curName, size(dataValue));
                    h5write(fileName, curName, dataValue);
                end

            end

            h5disp(fileName);
            fprintf('Saved .h5 dataset at %s.\n\n', fileName);

        end
        
        function [] = ReadDataset(experiment, condition)
            % ReadDataset reads a group of hsi data, prepares .mat files,
            % prepared normalized files and returns montage previews of contents
            % It also prepare labels. Data samples are saved in .mat files
            % so that each contains a 'spectralData' (class hsi) and a
            % 'label' (class logical array) variable. 
            %
            %   Usage:
            %   ReadDataset('handsOnly',{'hand', false})
            %   ReadDataset('sample001-tissue', {'tissue', true});

            ReadDatasetInternal(experiment, condition);
        end
        
        %% References %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [spectralData] = LoadHSIReference(targetName, refType)
            % LoadHSIReferenceInternal reads a stored HSI reference according to refType
            %
            %   Usage:
            %   [spectralData] = LoadHSIReferenceInternal(targetName, 'white')
            %   [spectralData] = LoadHSIReferenceInternal(targetName, 'black')
            [spectralData] = LoadHSIReferenceInternal(targetName, refType);
        end

        function [refLib] = PrepareReferenceLibrary(targetIDs, disease)
            %     PrepareReferenceLibrary prepares reference spectra for SAM
            %     comparison
            %
            %     Usage:
            %     referenceIDs = {153, 166};
            %     referenceDisease = cellfun(@(x) disease{targetIDs == x}, referenceIDs, 'UniformOutput', false);
            %     refLib = hsiUtility.PrepareReferenceLibrary(referenceIDs, referenceDisease);

            refLib = struct('Data', [], 'Label', [], 'Disease', []);
            k = 0;
            for i = 1:length(targetIDs)
                targetName = num2str(targetIDs{i});
                labelImg = hsiUtility.ReadLabel(targetName);
                hsiIm = hsiUtility.LoadHSI(targetName, 'dataset');
                if ~hsi.IsHsi(hsiIm)
                    error('Needs preprocessed input. Change [normalization] in config.');
                end
                malLabel = hsiIm.FgMask & labelImg;
                malData = mean(hsiIm.GetMaskedPixels(malLabel));
                k = k + 1;
                refLib(k).Data = malData;
                refLib(k).Label = 1;
                refLib(k).Disease = disease{i};

                benLabel = hsiIm.FgMask & ~labelImg;
                benData = mean(hsiIm.GetMaskedPixels(benLabel));
                k = k + 1;
                refLib(k).Data = benData;
                refLib(k).Label = 0;
                refLib(k).Disease = disease{i};
            end

            saveName = dataUtility.GetFilename('referenceLib', config.GetSetting('referenceLibraryName'));
            save(saveName, 'refLib');

        end

        function [refLib] = GetReferenceLibrary()
            %     GetReferenceLibrary returns reference spectra for SAM
            %     comparison
            %
            %     Usage:
            %     refLib = hsiUtility.GetReferenceLibrary();

            saveName = dataUtility.GetFilename('referenceLib', config.GetSetting('referenceLibraryName'));
            load(saveName, 'refLib');
        end

    end
end
