% ======================================================================
%> @brief hsiUtility is a class that holds all utility static functions
%> that handle hsi objects.
%
%> It is used to import, export and process hsi information.
%> It works in tandem with the hsi and hsiInfo classes.
%>
% ======================================================================
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
        
            targetFilename = commonUtility.GetFilename('dataset', targetID);

            spectralData = [];
            labelInfo = [];
            if ~exist(targetFilename, 'file')
                warning('There are no data for the requested ID = %s.', targetID);
            else
                variableInfo = who('-file', targetFilename);
                fprintf('Loads from dataset %s with normalization %s.\n', config.GetSetting('Dataset'), config.GetSetting('Normalization'));
                fprintf('Filename: %s.\n', targetFilename);
                if ismember('labelInfo', variableInfo) % returns true
                    load(targetFilename, 'spectralData', 'labelInfo');
                else
                    load(targetFilename, 'spectralData');
                    labelInfo = hsiInfo();
                end
            end

        end

        %======================================================================
        %> @brief LoadDataset loads both hsi and hsiInfo objects in the dataset.
        %>
        %> The hsi and hsiInfo objects should have been initialized beforehand with
        %> hsiUtility.PrepareDataset().
        %>
        %> @b Usage
        %>
        %> @code
        %> [hsiList, labelInfoList] = hsiUtility.LoadDataset();
        %> @endcode
        %>
        %> @param dataset [char] | Optional: The target datset. Default: config::[Dataset].
        %>
        %> @retval hsiList [cell array] | The cell array of hsi objects
        %> @retval labelInfoList [cell array] | The cell array of hsiInfo objects
        %======================================================================
        function [hsiList, labelInfoList] = LoadDataset(dataset)
        %======================================================================
        %> @brief LoadDataset loads both hsi and hsiInfo objects in the dataset.
        %>
        %> The hsi and hsiInfo objects should have been initialized beforehand with
        %> hsiUtility.PrepareDataset().
        %>
        %> @b Usage
        %>
        %> @code
        %> [hsiList, labelInfoList] = hsiUtility.LoadDataset();
        %> @endcode
        %>
        %> @param dataset [char] | Optional: The target datset. Default: config::[Dataset].
        %>
        %> @retval hsiList [cell array] | The cell array of hsi objects
        %> @retval labelInfoList [cell array] | The cell array of hsiInfo objects
        %======================================================================

            if nargin < 1
                dataset = config.GetSetting('Dataset');
            end
            config.SetSetting('Dataset', dataset);

            [~, targetIDs] = commonUtility.DatasetInfo(false);

            n = length(targetIDs);
            hsiList = cell(n, 1);
            labelInfoList = cell(n, 1);
            for i = 1:n
                targetName = targetIDs{i};
                [hsiList{i}, labelInfoList{i}] = hsiUtility.LoadHsiAndLabel(targetName);
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
        %>
        %> @code
        %>   x = hsiUtility.GetWavelengths(m) returns wavelengths as a vector of wavelengths
        %>
        %>   x = hsiUtility.GetWavelengths(m, 'raw') returns wavelengths as a vector of wavelengths
        %>
        %>   x = hsiUtility.GetWavelengths(m, 'index') returns indexes respective to selected wavelengths
        %>
        %>   x = hsiUtility.GetWavelengths(m, 'babel') returns indexes respective to selected wavelengths for babel standard spectra
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
        %======================================================================
        %> @brief GetWavelengths returns the wavelengths of the hyperspectral image
        %>
        %> Depending on the option, it either returns the wavelengths or the
        %> wavelength indexes of the spectral image.
        %>
        %> @b Usage
        %>
        %> @code
        %>   x = hsiUtility.GetWavelengths(m) returns wavelengths as a vector of wavelengths
        %>
        %>   x = hsiUtility.GetWavelengths(m, 'raw') returns wavelengths as a vector of wavelengths
        %>
        %>   x = hsiUtility.GetWavelengths(m, 'index') returns indexes respective to selected wavelengths
        %>
        %>   x = hsiUtility.GetWavelengths(m, 'babel') returns indexes respective to selected wavelengths for babel standard spectra
        %> @endcode
        %>
        %> @param m [int] | The total number of spectral channels
        %> @param option [char] | The option for return value. Can be 'raw',
        %> 'index', 'babel' or empty.
        %>
        %> @retval x [numeric array] | An array of wavelengths or wavelength
        %> indexes
        %======================================================================

            if nargin < 2
                option = 'raw';
            end

            switch option
                case 'raw'
                    splitWavelength = config.GetSetting('SplitWavelength');
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
        %> The .h5 data are assumed to be saved in config::[DataDir]\\*.h5.
        %> After reading, the image is saved in config::[MatDir]\\[Database]\\*.mat.
        %>
        %> @b Usage
        %>
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
        %======================================================================
        %> @brief ReadH5 loads the hyperspectral image from an .h5 file.
        %>
        %> The .h5 data are assumed to be saved in config::[DataDir]\\*.h5.
        %> After reading, the image is saved in config::[MatDir]\\[Database]\\*.mat.
        %>
        %> @b Usage
        %>
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
        
            [spectralData, imageXYZ, wavelengths] = LoadH5Data(filename);
        end

        %======================================================================
        %> @brief ReadTriplet reads and saves the three hyperspectral images
        %>
        %> The hyperspectral data are saved in .h5 format. The raw, white and black
        %> (if exist) images are read one-by-one for the same target. Each HSI is
        %> saved in config::[MatDir]\\[Database]\\[TripletsName]\\*_xxx.mat, where
        %> xxx is either '_target', '_white' or '_black'.
        %>
        %> To chose a mask for uni spectrum normalization, set config::[UseCustomMask]
        %>
        %> @b Usage
        %>
        %> @code
        %> content = 'tissue';
        %> target = '001_raw';
        %> spectralData = hsiUtility.ReadTriplet(content, target);
        %>
        %> spectralData = hsiUtility.ReadTriplet(content, target, blackIsCapOn);
        %> @endcode
        %>
        %> @param content [cell array] | Contains the content to be imported
        %> @param target [char] | Contains the target to be imported
        %> @param blackIsCapOn [logical] | Flag about the use of blackCap for dark image
        %>
        %> @retval spectralData [numeric array] | The target (tissue) hyperspectral image
        %======================================================================
        function [spectralData] = ReadTriplet(varargin)
        %======================================================================
        %> @brief ReadTriplet reads and saves the three hyperspectral images
        %>
        %> The hyperspectral data are saved in .h5 format. The raw, white and black
        %> (if exist) images are read one-by-one for the same target. Each HSI is
        %> saved in config::[MatDir]\\[Database]\\[TripletsName]\\*_xxx.mat, where
        %> xxx is either '_target', '_white' or '_black'.
        %>
        %> To chose a mask for uni spectrum normalization, set config::[UseCustomMask]
        %>
        %> @b Usage
        %>
        %> @code
        %> content = 'tissue';
        %> target = '001_raw';
        %> spectralData = hsiUtility.ReadTriplet(content, target);
        %>
        %> spectralData = hsiUtility.ReadTriplet(content, target, blackIsCapOn);
        %> @endcode
        %>
        %> @param content [cell array] | Contains the content to be imported
        %> @param target [char] | Contains the target to be imported
        %> @param blackIsCapOn [logical] | Flag about the use of blackCap for dark image
        %>
        %> @retval spectralData [numeric array] | The target (tissue) hyperspectral image
        %======================================================================
        
            [spectralData] = ReadTripletInternal(varargin{:});
        end
        
        %======================================================================
        %> @brief LoadRaw loads the raw hyperspectral image.
        %>
        %> The raw image is loaded from config::[MatDir]\\[TripletsName]\\*_target.mat.
        %>
        %> @b Usage
        %>
        %> @code
        %> [spectralData] = hsiUtility.LoadRaw(targetID);
        %> @endcode
        %>
        %> @param targetId [char] | The unique ID of the target sample
        %>
        %> @retval spectralData [numeric array] | A 3D array of the
        %> hyperspectral image reference
        %======================================================================
        function [spectralData] = LoadRaw(targetID)
        %======================================================================
        %> @brief LoadRaw loads the raw hyperspectral image.
        %>
        %> The raw image is loaded from config::[MatDir]\\[TripletsName]\\*_target.mat.
        %>
        %> @b Usage
        %>
        %> @code
        %> [spectralData] = hsiUtility.LoadRaw(targetID);
        %> @endcode
        %>
        %> @param targetId [char] | The unique ID of the target sample
        %>
        %> @retval spectralData [numeric array] | A 3D array of the
        %> hyperspectral image reference
        %======================================================================
        
            load(commonUtility.GetFilename('target', targetID), 'spectralData');
        end

        %% Dataset %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %======================================================================
        %> @brief ExportH5Dataset exports the entire selected dataset in .hdf5
        %> format.
        %>
        %> This function aggregates all small .mat files in a large .hdf5 dataset.
        %> The dataset is assumed from config::[MatDir]\\config::[Dataset]\\*.mat.
        %> After reading, the database is saved in config::[OutputDir]\\config::[Dataset]\\*.h5.
        %>
        %> @b Usage
        %>
        %> @code
        %> config.SetSetting('Dataset', 'coreDataset');
        %> hsiUtility.ExportH5Dataset();
        %> @endcode
        %>
        %======================================================================
        function [] = ExportH5Dataset(fileName, targetIDs)
        %======================================================================
        %> @brief ExportH5Dataset exports the entire selected dataset in .hdf5
        %> format.
        %>
        %> This function aggregates all small .mat files in a large .hdf5 dataset.
        %> The dataset is assumed from config::[MatDir]\\config::[Dataset]\\*.mat.
        %> After reading, the database is saved in config::[OutputDir]\\config::[Dataset]\\*.h5.
        %>
        %> @b Usage
        %>
        %> @code
        %> config.SetSetting('Dataset', 'coreDataset');
        %> hsiUtility.ExportH5Dataset();
        %> @endcode
        %>
        %======================================================================

            disp('Initializing [ExportH5Dataset]...');

            if nargin < 1
                fileName = commonUtility.GetFilename('output', ...
                    fullfile(config.GetSetting('DatasetsFolderName'), strcat('hsi_', config.GetSetting('Dataset'), '_full')), 'h5');
            end

            if nargin < 2
                [~, targetIDs] = commonUtility.DatasetInfo();
            end

            hsiUtility.SaveToH5(targetIDs, fileName);

        end

        
        %======================================================================
        %> @brief SaveToH5 saves the data of a set of target ids as a dataset in .hdf5
        %> format.
        %>
        %> This function aggregates all small .mat files in a large .hdf5 dataset.
        %> The dataset is assumed from config::[MatDir]\\config::[Dataset]\\*.mat.
        %>
        %> If the data is not instances of the hsi class, then only the hsi cube values are saved.
        %>
        %> @b Usage
        %>
        %> @code
        %> config.SetSetting('Dataset', 'pslRaw');
        %> [~, targetIDs] = commonUtility.DatasetInfo();
        %> targetIDs = targetIDs(contains(targetIDs, '15'));
        %> saveName = '150_set.h5';
        %> hsiUtility.SaveToH5(targetIDs, saveName);
        %> @endcode
        %>
        %> @param targetIDs [cell array] | The target IDs of target hsi cubes.
        %> @param saveName [char] | The save name for the .h5 file. 
        %======================================================================
        function [] = SaveToH5Internal(targetIDs, saveName)
                %======================================================================
        %> @brief SaveToH5 saves the data of a set of target ids as a dataset in .hdf5
        %> format.
        %>
        %> This function aggregates all small .mat files in a large .hdf5 dataset.
        %> The dataset is assumed from config::[MatDir]\\config::[Dataset]\\*.mat.
        %>
        %> If the data is not instances of the hsi class, then only the hsi cube values are saved.
        %>
        %> @b Usage
        %>
        %> @code
        %> config.SetSetting('Dataset', 'pslRaw');
        %> [~, targetIDs] = commonUtility.DatasetInfo();
        %> targetIDs = targetIDs(contains(targetIDs, '15'));
        %> saveName = '150_set.h5';
        %> hsiUtility.SaveToH5(targetIDs, saveName);
        %> @endcode
        %>
        %> @param targetIDs [cell array] | The target IDs of target hsi cubes.
        %> @param saveName [char] | The save name for the .h5 file. 
        %======================================================================
        
            SaveToH5(targetIDs, saveName)
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
        %> The save location is config::[MatDir]\\[Dataset]\\*.mat.
        %> Snapshot images are saved in config::[OutputDir]\\[SnapshotsFolderName]\\[Dataset]\\*.jpg.
        %>
        %> @b Usage
        %>
        %> @code
        %> hsiUtility.PrepareDataset('handsDataset',{'hand', false});
        %>
        %> hsiUtility.PrepareDataset('pslData', {'tissue', true});
        %> @endcode
        %>
        %> @param dataset [char] | The dataset
        %> @param condition [cell array] | The conditions for reading files
        %> @param readForeground [boolean] | Optional: Flag to read the foreground mask for an hsi instance. Default: true
        %======================================================================
        function [] = PrepareDataset(varargin)
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
        %> The save location is config::[MatDir]\\[Dataset]\\*.mat.
        %> Snapshot images are saved in config::[OutputDir]\\[SnapshotsFolderName]\\[Dataset]\\*.jpg.
        %>
        %> @b Usage
        %>
        %> @code
        %> hsiUtility.PrepareDataset('handsDataset',{'hand', false});
        %>
        %> hsiUtility.PrepareDataset('pslData', {'tissue', true});
        %> @endcode
        %>
        %> @param dataset [char] | The dataset
        %> @param condition [cell array] | The conditions for reading files
        %> @param readForeground [boolean] | Optional: Flag to read the foreground mask for an hsi instance. Default: true
        %======================================================================
            ReadDataset(varargin{:});
        end

        %% References %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %======================================================================
        %> @brief LoadHSIReference reads the reference hyperspectral image (white or black).
        %>
        %> It is valid for hyperspectral data already saved as .mat files
        %> in config::[MatDir]\\[TripletsName]\\*_white.mat or *_black.mat.
        %> The returned reference image is a 3D array, not an hsi instance.
        %>
        %> @b Usage
        %>
        %> @code
        %> [spectralData] = hsiUtility.LoadHSIReference('150', 'white');
        %>
        %> [spectralData] = hsiUtility.LoadHSIReference('150', 'black');
        %> @endcode
        %>
        %> @param targetId [char] | The unique ID of the target sample
        %> @param refType [char] | The reference type, either 'white' or
        %> 'black'
        %>
        %> @retval spectralData [numeric array] | A 3D array of the
        %> hyperspectral image reference
        %======================================================================
        function [spectralData] = LoadHSIReference(targetId, refType)
        %======================================================================
        %> @brief LoadHSIReference reads the reference hyperspectral image (white or black).
        %>
        %> It is valid for hyperspectral data already saved as .mat files
        %> in config::[MatDir]\\[TripletsName]\\*_white.mat or *_black.mat.
        %> The returned reference image is a 3D array, not an hsi instance.
        %>
        %> @b Usage
        %>
        %> @code
        %> [spectralData] = hsiUtility.LoadHSIReference('150', 'white');
        %>
        %> [spectralData] = hsiUtility.LoadHSIReference('150', 'black');
        %> @endcode
        %>
        %> @param targetId [char] | The unique ID of the target sample
        %> @param refType [char] | The reference type, either 'white' or
        %> 'black'
        %>
        %> @retval spectralData [numeric array] | A 3D array of the
        %> hyperspectral image reference
        %======================================================================
        
            [spectralData] = LoadHSIReferenceInternal(targetId, refType);
        end

        %======================================================================
        %> @brief ResizeArray resizes an irray to a target image size.
        %>
        %> Depending on the input array's size and the target size, it will be cropped or zero-padded.
        %>
        %> @b Usage
        %>
        %> @code
        %> resizedValue = hsiUtility.ResizeArray(hsIm.Value, 512);
        %> @endcode
        %>
        %> @param oldValue [numeric array] | The input array
        %> @param imgSize [int] | The target image size
        %>
        %> @retval newValue [numeric array] | The resized array
        %======================================================================
        function [newValue] = ResizeArray(oldValue, imgSize)
        %======================================================================
        %> @brief ResizeArray resizes an irray to a target image size.
        %>
        %> Depending on the input array's size and the target size, it will be cropped or zero-padded.
        %>
        %> @b Usage
        %>
        %> @code
        %> resizedValue = hsiUtility.ResizeArray(hsIm.Value, 512);
        %> @endcode
        %>
        %> @param oldValue [numeric array] | The input array
        %> @param imgSize [int] | The target image size
        %>
        %> @retval newValue [numeric array] | The resized array
        %======================================================================
        
            [m, n, s] = size(oldValue);
            newValue = zeros(imgSize, imgSize, s);
            if imgSize < m
                x1 = floor(m/2-imgSize/2);
                x2 = floor(m/2+imgSize/2);
                p1 = double(imgSize-length(x1:x2));
                x2 = x2 + p1;
            else
                x1 = floor(imgSize/2-m/2);
                x2 = floor(imgSize/2+m/2);
                p1 = double(m - length(x1:x2));
                x2 = x2 + p1;
            end

            if imgSize < n
                y1 = floor(n/2-imgSize/2);
                y2 = floor(n/2+imgSize/2);
                p2 = double(imgSize-length(y1:y2));
                y2 = y2 + p2;
            else
                y1 = floor(imgSize/2-n/2);
                y2 = floor(imgSize/2+n/2);
                p2 = double(n-length(y1:y2));
                y2 = y2 + p2;
            end

            if imgSize < m && imgSize < n
                newValue(:, :, :) = oldValue(x1:x2, y1:y2, :);
            elseif imgSize < n
                newValue(x1:x2, :, :) = oldValue(:, y1:y2, :);
            elseif imgSize < m
                newValue(:, y1:y2, :) = oldValue(x1:x2, :, :);
            else
                newValue(x1:x2, y1:y2, :) = oldValue(:, :, :);
            end
        end

        %======================================================================
        %> @brief SplitToPatches splits an image into patches.
        %>
        %> The patches are saved in a cell array. The number of patches depends on the ratio between the input array size and the target patch size.
        %>
        %> @b Usage
        %>
        %> @code
        %> resizedValue = hsiUtility.ResizeArray(hsIm.Value, 512);
        %> @endcode
        %>
        %> @param oldValue [numeric array] | The input array
        %> @param patchSize [int] | The target patch size
        %>
        %> @retval patches [cell array] | The patches
        %> @retval patchesIdx [cell array] | The subscripts of each patch
        %======================================================================
        function [patches, patchesIdx] = SplitToPatches(oldValue, patchSize)
        %======================================================================
        %> @brief SplitToPatches splits an image into patches.
        %>
        %> The patches are saved in a cell array. The number of patches depends on the ratio between the input array size and the target patch size.
        %>
        %> @b Usage
        %>
        %> @code
        %> resizedValue = hsiUtility.ResizeArray(hsIm.Value, 512);
        %> @endcode
        %>
        %> @param oldValue [numeric array] | The input array
        %> @param patchSize [int] | The target patch size
        %>
        %> @retval patches [cell array] | The patches
        %> @retval patchesIdx [cell array] | The subscripts of each patch
        %======================================================================

            [m, n, ~] = size(oldValue);
            a = floor(m / patchSize);
            b = floor(n/patchSize);
            numPatch = a * b;
            patches = cell(numPatch, 1);
            patchesIdx = cell(numPatch, 1);
            c = 0;

            for i = 1:a
                for j = 1:b
                    c = c + 1;
                    patchesIdx{c} = [i, j];
                    patches{c} = oldValue((i - 1)*patchSize+1:i*patchSize, (j - 1)*patchSize+1:j*patchSize, :);
                end
            end
        end

        %======================================================================
        %> @brief Resize resizes or splits in patches the values of an hsi object and the associated hsiInfo object.
        %>
        %> Depending on the input array's size and the target size, it will be cropped or zero-padded.
        %>
        %> @b Usage
        %>
        %> @code
        %> [updObj, updObjInfo, patchSubs] = hsiUtility.Resize(hsIm, labelInfo);
        %> @endcode
        %>
        %> @param obj [hsi] | An instance of the hsi class
        %> @param objInfo [hsiInfo] | An instance of the hsiInfo class
        %>
        %> @retval updObj [hsi] | An instance of the hsi class
        %> @retval updObjInfo [hsi] | An instance of the hsiInfo class
        %> @retval patchSubs [cell array] | The subscripts of each image patch
        %======================================================================
        function [updObj, updObjInfo, patchSubs] = Resize(obj, objInfo)
        %======================================================================
        %> @brief Resize resizes or splits in patches the values of an hsi object and the associated hsiInfo object.
        %>
        %> Depending on the input array's size and the target size, it will be cropped or zero-padded.
        %>
        %> @b Usage
        %>
        %> @code
        %> [updObj, updObjInfo, patchSubs] = hsiUtility.Resize(hsIm, labelInfo);
        %> @endcode
        %>
        %> @param obj [hsi] | An instance of the hsi class
        %> @param objInfo [hsiInfo] | An instance of the hsiInfo class
        %>
        %> @retval updObj [hsi] | An instance of the hsi class
        %> @retval updObjInfo [hsi] | An instance of the hsiInfo class
        %> @retval patchSubs [cell array] | The subscripts of each image patch
        %======================================================================

            updObj = obj;
            updObjInfo = objInfo;
            if config.GetSetting('HasResizeOptions')
                if ~config.GetSetting('SplitToPatches')
                    imgSize = config.GetSetting('ImageDimension');
                    updObj.Value = hsiUtility.ResizeArray(obj.Value, imgSize);
                    updObj.FgMask = hsiUtility.ResizeArray(obj.FgMask, imgSize);
                    updObjInfo.Labels = hsiUtility.ResizeArray(objInfo.Labels, imgSize);
                    updObjInfo.MultiClassLabels = hsiUtility.ResizeArray(objInfo.MultiClassLabels, imgSize);
                    patchSubs{1} = [1, 1];

                else
                    imgSize = config.GetSetting('PatchDimension');
                    [values, patchesIdx] = hsiUtility.SplitToPatches(obj.Value, imgSize);
                    [fgMasks, ~] = hsiUtility.SplitToPatches(obj.FgMask, imgSize);
                    [labels, ~] = hsiUtility.SplitToPatches(objInfo.Labels, imgSize);
                    [mclabels, ~] = hsiUtility.SplitToPatches(objInfo.MultiClassLabels, imgSize);

                    if numel(labels) > 0
                        updObj = cell(1, numel(values));
                        updObjInfo = cell(1, numel(values));
                        patchSubs = cell(1, numel(values));

                        for i = 1:numel(values)
                            obj.Value = values{i};
                            obj.FgMask = fgMasks{i};
                            objInfo.Labels = labels{i};
                            objInfo.MultiClassLabels = mclabels{i};

                            updObj{i} = obj;
                            updObjInfo{i} = objInfo;
                            patchSubs{i} = patchesIdx{i};
                        end
                    end
                end
            end
        end

        %======================================================================
        %> @brief PrepareReferenceLibrary reads and prepares a library of spectral references.
        %>
        %> It can be used for various comparisons, including Spectral Angle
        %> Mapper (SAM) calculation.
        %> The result is saved in config::[MatDir]\\[Database]\\[ReferenceLibraryName]\\[ReferenceLibraryName].mat.
        %> After creating it can be loaded with @c hsiUtility.GetReferenceLibrary.
        %>
        %> @b Usage
        %>
        %> @code
        %>     referenceIDs = {153, 166};
        %>     refLib = hsiUtility.PrepareReferenceLibrary(referenceIDs);
        %> @endcode
        %>
        %> @param refIDs [cell array] | A cell array of strings that
        %> includes all target reference IDs for samples to be included in the library.
        %>
        %> @retval refLib [struct] | A struct that contains the reference
        %> library. The struct has fields 'Data', 'Label' (Malignant (1) or
        %> Benign (0)) and 'Disease'.
        %>
        %======================================================================
        function [refLib] = PrepareReferenceLibrary(refIDs)
            refLib = PrepareReferenceLibraryInternal(refIDs);
        end

        %======================================================================
        %> @brief GetReferenceLibrary loads a library of spectral references.
        %>
        %> It loads a library created previously by @c function hsiUtility.PrepareReferenceLibrary .
        %> The result is loaded from config::[MatDir]\\[Database]\\[ReferenceLibraryName]\\[RreferenceLibraryName].mat.
        %> Plot with @c function plots.ReferenceLibrary .
        %>
        %> @b Usage
        %>
        %> @code
        %>     refLib = hsiUtility.GetReferenceLibrary();
        %>     plots.ReferenceLibrary(1, refLib);
        %> @endcode
        %>
        %> @retval refLib [struct] | A struct that contains the reference
        %> library. The struct has fields 'Data', 'Label' (Malignant (1) or
        %> Benign (0)) and 'Disease'.
        %>
        %======================================================================
        function [refLib] = GetReferenceLibrary()
        %======================================================================
        %> @brief GetReferenceLibrary loads a library of spectral references.
        %>
        %> It loads a library created previously by @c function hsiUtility.PrepareReferenceLibrary .
        %> The result is loaded from config::[MatDir]\\[Database]\\[ReferenceLibraryName]\\[RreferenceLibraryName].mat.
        %> Plot with @c function plots.ReferenceLibrary .
        %>
        %> @b Usage
        %>
        %> @code
        %>     refLib = hsiUtility.GetReferenceLibrary();
        %>     plots.ReferenceLibrary(1, refLib);
        %> @endcode
        %>
        %> @retval refLib [struct] | A struct that contains the reference
        %> library. The struct has fields 'Data', 'Label' (Malignant (1) or
        %> Benign (0)) and 'Disease'.
        %>
        %======================================================================
        
            saveName = commonUtility.GetFilename('ReferenceLib', config.GetSetting('ReferenceLibraryName'));
            if exist(saveName, 'file') == 2
                load(saveName, 'refLib');
                %fprintf('The reference library is loaded from %s.\n', saveName);

            else
                refLib = [];
                disp('The reference library is not created yet. Use hsiUtility.PrepareReferenceLibrary.');
            end
        end

        % ======================================================================
        %> @brief AdjustDimensions zero pads to adjust the length of the
        %> third dimension.
        %>
        %> @b Usage
        %>
        %> @code
        %> [scores] = hsiUtility.AdjustDimensions(scores, q);
        %> @endcode
        %>
        %> @param scores [numeric array] | The target array
        %> @param q [int] | The size of the third dimension
        %>
        %> @retval scores [numeric array] | The output array
        % ======================================================================
        function [scores] = AdjustDimensions(scores, q)
        % ======================================================================
        %> @brief AdjustDimensions zero pads to adjust the length of the
        %> third dimension.
        %>
        %> @b Usage
        %>
        %> @code
        %> [scores] = hsiUtility.AdjustDimensions(scores, q);
        %> @endcode
        %>
        %> @param scores [numeric array] | The target array
        %> @param q [int] | The size of the third dimension
        %>
        %> @retval scores [numeric array] | The output array
        % ======================================================================

            if iscell(scores)
                for i = 1:numel(scores)
                    scores{i} = hsiUtility.AdjustDimensions(scores{i}, q);
                end
            else

                % Adjust dimensions if it is smaller than expected
                if ndims(scores) == 3 && size(scores, 3) < q
                    [m, l, n] = size(scores);
                    newScores = zeros(m, l, q);
                    newScores(:, :, 1:n) = scores;
                    scores = newScores;
                end

                if ndims(scores) == 2 && size(scores, 2) < q
                    [m, n] = size(scores);
                    newScores = zeros(m, q);
                    newScores(:, 1:n) = scores;
                    scores = newScores;
                end
            end
        end

        % ======================================================================
        %> @brief CleanLabels returns superpixel labels that contain tissue pixels.
        %>
        %> Keep only pixels that belong to the tissue (Superpixel might assign
        %> background pixels also). The last label is background label.
        %>
        %> @b Usage
        %>
        %> @code
        %> [cleanLabels, validLabels] = hsiUtility.CleanLabels(labels, fgMask, pixelNum);
        %> @endcode
        %>
        %> @param labels [numeric array] | The labels of the superpixels
        %> @param fgMask [numeric array] | The foreground mask
        %> @param pixelNum [int] | The number of superpixels.
        %>
        %> @retval cleanLabels [numeric array] | The labels of the superpixels
        %> @retval validLabels [numeric array] | The superpixel labels that refer
        %> to tissue pixels
        % ======================================================================
        function [cleanLabels, validLabels] = CleanLabels(labels, fgMask, pixelNum)
        % ======================================================================
        %> @brief CleanLabels returns superpixel labels that contain tissue pixels.
        %>
        %> Keep only pixels that belong to the tissue (Superpixel might assign
        %> background pixels also). The last label is background label.
        %>
        %> @b Usage
        %>
        %> @code
        %> [cleanLabels, validLabels] = hsiUtility.CleanLabels(labels, fgMask, pixelNum);
        %> @endcode
        %>
        %> @param labels [numeric array] | The labels of the superpixels
        %> @param fgMask [numeric array] | The foreground mask
        %> @param pixelNum [int] | The number of superpixels.
        %>
        %> @retval cleanLabels [numeric array] | The labels of the superpixels
        %> @retval validLabels [numeric array] | The superpixel labels that refer
        %> to tissue pixels
        % ======================================================================
        
            labels(~fgMask) = pixelNum;

            pixelLim = 10;
            labelTags = unique(labels)';
            labelTags = labelTags(labelTags ~= pixelNum); % Remove last label (background pixels)
            validLabels = [];
            k = 0;

            for i = labelTags
                sumPixel = sum(labels == i, 'all');
                if sumPixel < pixelLim %Ignore superpixel labels with too few pixels
                    labels(labels == i) = pixelNum;
                else
                    k = k + 1;
                    validLabels(k) = i;
                end
            end

            cleanLabels = labels;
        end

    end
end
