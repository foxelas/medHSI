classdef dataUtility
    methods (Static)

        %% Contents
        %
        %   Static:
        %         [outname] = StrrepAll(inname, isLegacy)
        %         [value] = GetValueFromTable(tab, field, id)
        %         [bbox] = GetBoundingBoxMask(corners)
        %         [newSpectrum, newX] = SpectrumCut(oldSpectrum, x)
        %         [outSpectrum] = SpectrumPad(inSpectrum, options)
        %         [reorderedSpectra, labels] = ReorderSpectra(target, chartColorOrder, spectraColorOrder, wavelengths, spectralWavelengths)
        %         [filename] = GetFilename(dataType, targetName);
        %         [datanames, targetIDs] = DatasetInfo()

        function [outname] = StrrepAll(inname, isLegacy)
            %     StrrepAll fomats an inname to outname
            %
            %     Usage:
            %     [outname] = StrrepAll(inname)

            if nargin < 2
                isLegacy = false;
            end

            [~, outname] = fileparts(inname);

            str = '_';
            if isLegacy
                str = ' ';
            end

            outname = strrep(outname, '\', str);
            outname = strrep(outname, '_', str);
            outname = strrep(outname, ' ', str);

            outname = strrep(outname, '.csv', '');
            outname = strrep(outname, '.mat', '');

        end

        function [value] = GetValueFromTable(tab, field, id)
            %%GETVALUEFROMTABLE get a value from specific column in a table
            %
            %   Usage:
            %   value = GetValueFromTable(tab, field, id)

            column = tab.(field);
            value = column{id};
        end

        function [bbox] = GetBoundingBoxMask(corners)
            %     GETBOUNDINGBOX returns the settings for a bounding box from the mask indexes
            %
            %     Usage:
            %     bbox = GetBoundingBoxMask(corners)
            %
            %     Example
            %     corners = [316, 382, 242, 295];
            %     bbox = GetBoundingBoxMask(corners);
            %     returns bboxHb = [316 242 382-316 295-242];

            bbox = [corners(1), corners(3), corners(2) - corners(1) + 1, corners(4) - corners(3) + 1];

        end

        function [newSpectrum, newX] = SpectrumCut(oldSpectrum, x)
            %SPECTRUMCUT removes noisy bands from the spectrum
            %
            %   Usage:
            %   [newSpectrum, newX] = SpectrumCut(oldSpectrum, 380:780)

            ids = x >= 420 & x <= 730;
            newX = x(ids);
            newSpectrum = oldSpectrum(ids);
        end

        function [outSpectrum] = SpectrumPad(inSpectrum, options)
            %SPECTRUMPAD adds or removes padding to spectrum array
            %
            %   Usage:
            %   [outSpectrum] = SpectrumPad(inSpectrum) adds padding to inSpectrum
            %   [outSpectrum] = SpectrumPad(inSpectrum, 'add') adds padding to inSpectrum
            %   [outSpectrum] = SpectrumPad(inSpectrum, 'del') removes padding from inSpectrum

            if nargin < 2
                options = 'add';
            end

            m = length(inSpectrum);

            switch options
                case 'add'
                    x = hsiUtility.GetWavelengths(m, 'index');
                    if m > 100
                        outSpectrum = zeros(401, 1);
                    else
                        outSpectrum = zeros(36, 1);
                    end
                    outSpectrum(x) = inSpectrum;

                case 'del'
                    isPadded = true;
                    if m == 36
                        cutoff = 15;
                    elseif m == 401
                        cutoff = 150;
                    else
                        isPadded = false;
                    end

                    if isPadded && isempty(nonzeros(inSpectrum(1:cutoff)))
                        idStart = find(inSpectrum, 1);
                        outSpectrum = inSpectrum(idStart:end);

                    elseif isPadded && isempty(nonzeros(inSpectrum((end -cutoff):end)))
                        idEnd = find(inSpectrum, 1, 'last');
                        outSpectrum = inSpectrum(1:idEnd);

                    else
                        outSpectrum = inSpectrum;
                    end

                otherwise
                    error('Unsupported options');
            end
        end

        function [reorderedSpectra, labels] = ReorderSpectra(target, chartColorOrder, spectraColorOrder, wavelengths, spectralWavelengths)
            %REORDERSPECTRA match chartColorOrder according to spectralColorOrder
            % i.e. match babel order to colorchart order
            %
            %   Usage:
            %    [reorderedSpectra, labels] = ReorderSpectra(target, chartColorOrder,
            %       spectraColorOrder, wavelengths, spectralWavelengths)

            if size(target, 2) ~= 401 && size(target, 2) == 161
                wavelengths = [380:540]';
            elseif size(target, 2) ~= 401 && size(target, 2) ~= 161
                wavelengths = [541:780]';
            end

            [~, idx] = ismember(spectraColorOrder, chartColorOrder);
            idx = nonzeros(idx);
            [~, idx2] = ismember(spectralWavelengths', wavelengths);

            idx2 = nonzeros(idx2);

            targetDecim = target(:, idx2);
            reorderedSpectra = targetDecim(idx, :);

            labels = spectraColorOrder;
        end

        function [targetFilename] = GetFilename(dataType, targetName, extension)
            %GetFilename returns the directories for saved data
            %
            %   Inputs
            %   dataType: choose between 'preprocessed', 'target', 'white',
            %   'black', 'dataset', 'raw', 'label', 'param',
            %   'referenceLib', 'augmentation', 'h5' or 'model'
            %   targetName: the name of the target
            %
            %   Usage:
            %   targetName = num2str(id);
            %   labelfile = dataUtility.GetFilename('label', targetName);

            if nargin < 2
                targetName = '';
            end

            if nargin < 3
                extension = 'mat';
            end

            switch dataType
                case 'preprocessed'
                    if strcmpi(config.GetSetting('normalization'), 'raw')
                        targetFilename = dataUtility.GetFilename('target', targetName);
                    else
                        baseDir = config.DirMake(config.GetSetting('matDir'), ...
                            strcat(config.GetSetting('database'), config.GetSetting('normalizedName')), targetName);
                        targetFilename = strcat(baseDir, '_', config.GetSetting('normalization'));
                    end

                case 'dataset'
                    targetFilename = config.DirMake(config.GetSetting('matDir'), ...
                        strcat(config.GetSetting('dataset')), targetName);

                case 'target'
                    baseDir = fullfile(config.GetSetting('matDir'), ...
                        strcat(config.GetSetting('database'), config.GetSetting('tripletsName')), targetName);
                    targetFilename = strcat(baseDir, '_target');

                case 'raw'
                    targetFilename = dataUtility.GetFilename('target', targetName);

                case 'white'
                    baseDir = fullfile(config.GetSetting('matDir'), ...
                        strcat(config.GetSetting('database'), config.GetSetting('tripletsName')), targetName);
                    targetFilename = strcat(baseDir, '_white');

                case 'black'
                    baseDir = fullfile(config.GetSetting('matDir'), ...
                        strcat(config.GetSetting('database'), config.GetSetting('tripletsName')), targetName);
                    targetFilename = strcat(baseDir, '_black');

                case 'model'
                    targetFilename = config.DirMake(config.GetSetting('outputDir'), ...
                        config.GetSetting('experiment'), targetName);

                case 'param'
                    targetFilename = fullfile(config.GetRunBaseDir(), ...
                        config.GetSetting('paramDir'), targetName);

                case 'referenceLib'
                    targetFilename = config.DirMake(config.GetSetting('matDir'), ...
                        strcat(config.GetSetting('database'), config.GetSetting('referenceLibraryName')), ...
                        targetName);

                case 'augmentation'
                    targetFilename = config.DirMake(config.GetSetting('matDir'), ...
                        config.GetSetting('augmentation'), targetName);

                case 'h5'
                    targetFilename = config.DirMake(config.GetSetting('matDir'), ...
                        config.GetSetting('database'), targetName);

                otherwise
                    error('Unsupported dataType.');
            end

            [~, ~, ext] = fileparts(targetFilename);
            if isempty(ext)
                targetFilename = strcat(targetFilename, '.', extension);
            elseif ~strcmp(strrep(ext, '.', ''), extension)
                targetFilename = strrep(targetFilename, ext, strcat('.', extension));
            end
        end

        function [datanames, targetIDs] = DatasetInfo()
            fdir = dir(strrep(dataUtility.GetFilename('dataset'), '.mat', '\*.mat'));
            if numel(fdir) < 1
                error('You should first read the dataset. Use hsiUtility.ReadDataset().');

            else
                datanames = {fdir.name};
                unNames = cellfun(@(x) strsplit(x, {'_', '.'}), datanames', 'un', 0);
                unNames = cellfun(@(x) x{1}, unNames, 'un', 0);
                targetIDs = unique(unNames);
            end
        end
    end
end