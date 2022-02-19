classdef hsiUtility
    methods (Static)
%======================================================================
%> @brief LoadHsiAndLabel loads both hsi and hsiInfo objects
%>
%> The hsi and hsiInfo objects should have been initialized beforehand with
%> hsiUtility.PrepareDataset().
%>
%> @b Usage
%> 
%> @code
%> [spectralData, labelInfo] = hsiUtility.LoadHsiAndLabel('150');
%> @endcode
%>
%> @param targetId [char] | The unique ID of the target sample
%>
%> @retval spectralData [hsi] | The initialized hsi object
%> @retval labelInfo [hsiInfo] | The initialized hsiInfo object
%======================================================================
        function [spectralData, labelInfo] = LoadHsiAndLabel(targetID)
%> @brief LoadHsiAndLabel loads both hsi and hsiInfo objects
%>
%> The hsi and hsiInfo objects should have been initialized beforehand with
%> hsiUtility.PrepareDataset().
%>
%> @b Usage
%> 
%> @code
%> [spectralData, labelInfo] = hsiUtility.LoadHsiAndLabel('150');
%> @endcode
%>
%> @param targetId [char] | The unique ID of the target sample
%>
%> @retval spectralData [hsi] | The initialized hsi object
%> @retval labelInfo [hsiInfo] | The initialized hsiInfo object
            targetFilename = dataUtility.GetFilename('dataset', targetID);
            
            if ~exist(targetFilename, 'file')
                error('There are no data for the requested ID = %s.', targetID);
            end
            
            variableInfo = who('-file', targetFilename);
            if ismember('labelInfo', variableInfo) % returns true
                load(targetFilename, 'spectralData', 'labelInfo');
            else
                load(targetFilename, 'spectralData');
                labelInfo = hsiInfo.Empty();
            end
        end

        %% System properties %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%======================================================================
%> @brief GetWavelengths returns the wavelengths of the hyperspectral image
%>
%> Depending on the option, it either returns the wavelengths or the
%> wavelength indexes of the spectral image.
%>
%> @b Usage
%>   x = hsiUtility.GetWavelengths(m) returns wavelengths as a vector of wavelengths
%>
%>   x = hsiUtility.GetWavelengths(m, 'raw') returns wavelengths as a vector of wavelengths
%>   
%>   x = hsiUtility.GetWavelengths(m, 'index') returns indexes respective to selected wavelengths
%>
%>   x = hsiUtility.GetWavelengths(m, 'babel') returns indexes respective to selected wavelengths for babel standard spectra
%> @code 
%>
%> @endcode
%>
%> @param m [int] | The total number of spectral channels
%> @param option [char] | The option for return value. Can be 'raw',
%> 'index', 'babel' or empty.
%>
%> @retval x [numeric array] | An array of wavelengths or wavelength
%> indexes 
%======================================================================
        function [x] = GetWavelengths(m, option)
%> @brief GetWavelengths returns the wavelengths of the hyperspectral image
%>
%> Depending on the option, it either returns the wavelengths or the
%> wavelength indexes of the spectral image.
%>
%> @b Usage
%>   x = hsiUtility.GetWavelengths(m) returns wavelengths as a vector of wavelengths
%>
%>   x = hsiUtility.GetWavelengths(m, 'raw') returns wavelengths as a vector of wavelengths
%>   
%>   x = hsiUtility.GetWavelengths(m, 'index') returns indexes respective to selected wavelengths
%>
%>   x = hsiUtility.GetWavelengths(m, 'babel') returns indexes respective to selected wavelengths for babel standard spectra
%> @code 
%>
%> @endcode
%>
%> @param m [int] | The total number of spectral channels
%> @param option [char] | The option for return value. Can be 'raw',
%> 'index', 'babel' or empty.
%>
%> @retval x [numeric array] | An array of wavelengths or wavelength
%> indexes 

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
%======================================================================
%> @brief ReadH5 loads the hyperspectral image from an .h5 file.
%>
%> The .h5 data are assumed to be saved in config::[dataDir]\*.h5
%> After reading, the image is saved in config::[matDir]\[database]\*.mat.
%>
%> @ Usage
%> @code
%> [spectralData, imageXYZ, wavelengths] = hsiUtility.ReadH5(filename);
%> @endcode
%>
%> @param filename [char] | The filename of the file to read
%>
%> @retval spectralData [numeric array] | The hyperspectral image
%> @retval imageXYZ [numeric array] | The XYZ image
%> @retval wavelengths [numeric array] | The spectral wavelengths
%======================================================================
        function [spectralData, imageXYZ, wavelengths] = ReadH5(filename)
%> @brief ReadH5 loads the hyperspectral image from an .h5 file.
%>
%> The .h5 data are assumed to be saved in config::[dataDir]\*.h5
%> After reading, the image is saved in config::[matDir]\[database]\*.mat.
%>
%> @ Usage
%> @code
%> [spectralData, imageXYZ, wavelengths] = hsiUtility.ReadH5(filename);
%> @endcode
%>
%> @param filename [char] | The filename of the file to read
%>
%> @retval spectralData [numeric array] | The hyperspectral image
%> @retval imageXYZ [numeric array] | The XYZ image
%> @retval wavelengths [numeric array] | The spectral wavelengths
            [spectralData, imageXYZ, wavelengths] = LoadH5Data(filename);
        end

        function [spectralData] = ReadTriplet(varargin)
            [spectralData] = ReadTriplet(varargin{:});
        end

        function [spectralData] = ReadRaw(targetID)
            load(dataUtility.GetFilename('target', targetID), 'spectralData');
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
        %======================================================================
        function [] = PrepareDataset(dataset, condition)
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
            ReadDataset(dataset, condition);
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
