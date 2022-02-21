% ======================================================================
%> @brief commonUtility is a class that handles common utilities.
%>
% ======================================================================
classdef commonUtility
    methods (Static)
        % ======================================================================
        %> @brief GetBoundingBoxMask returns the mask corner indexes for a bounding box.
        %>
        %> @b Usage
        %>
        %> @code
        %> bbox = commonUtility.GetBoundingBoxMask(corners);
        %>
        %> corners = [316, 382, 242, 295];
        %> bbox = commonUtility.GetBoundingBoxMask(corners);
        %> @endcode
        %>
        % ======================================================================
        function [bbox] = GetBoundingBoxMask(corners)
            % GetBoundingBoxMask returns the mask corner indexes for a bounding box.
            %
            % @b Usage
            %
            % @code
            % bbox = commonUtility.GetBoundingBoxMask(corners);
            %
            % corners = [316, 382, 242, 295];
            % bbox = commonUtility.GetBoundingBoxMask(corners);
            % @endcode
            %
            bbox = [corners(1), corners(3), corners(2) - corners(1) + 1, corners(4) - corners(3) + 1];
        end

        % ======================================================================
        %> @brief GetFilename returns the the directories for saved data.
        %>
        %> For filename choose between: 'preprocessed', 'dataset', 'target', 'white', 'black', 'raw', 'model', 'param', 'referenceLib', 'augmentation' or 'h5'
        %>
        %> @b Usage
        %>
        %> @code
        %> filename = num2str(id);
        %> fullPath = commonUtility.GetFilename('label', filename);
        %> @endcode
        %>
        %> @param directoryType [string] | The type of the directory to be recovered
        %> @b Optional
        %> @param filename [string] | The name of the file. Default: ''.
        %> @param extension [string] | The file extension. Default: '.mat'.
        %>
        %> @retval fullPath [string] | The full path to the target file
        % ======================================================================
        function [fullPath] = GetFilename(directoryType, filename, extension)
            % GetFilename returns the the directories for saved data.
            %
            % For filename choose between: 'preprocessed', 'dataset', 'target', 'white', 'black', 'raw', 'model', 'param', 'referenceLib', 'augmentation' or 'h5'
            %
            % @b Usage
            %
            % @code
            % filename = num2str(id);
            % fullPath = commonUtility.GetFilename('label', filename);
            % @endcode
            %
            % @param directoryType [string] | The type of the directory to be recovered
            % @b Optional
            % @param filename [string] | The name of the file. Default: ''.
            % @param extension [string] | The file extension. Default: '.mat'.
            %
            % @retval fullPath [string] | The full path to the target file
            if nargin < 2
                filename = '';
            end

            if nargin < 3
                extension = 'mat';
            end

            switch directoryType
                case 'preprocessed'
                    if strcmpi(config.GetSetting('normalization'), 'raw')
                        fullPath = commonUtility.GetFilename('target', filename);
                    else
                        baseDir = config.DirMake(config.GetSetting('matDir'), ...
                            strcat(config.GetSetting('database'), config.GetSetting('normalizedName')), filename);
                        fullPath = strcat(baseDir, '_', config.GetSetting('normalization'));
                    end

                case 'dataset'
                    fullPath = config.DirMake(config.GetSetting('matDir'), ...
                        strcat(config.GetSetting('dataset')), filename);

                case 'target'
                    baseDir = fullfile(config.GetSetting('matDir'), ...
                        strcat(config.GetSetting('database'), config.GetSetting('tripletsName')), filename);
                    fullPath = strcat(baseDir, '_target');

                case 'raw'
                    fullPath = commonUtility.GetFilename('target', filename);

                case 'white'
                    baseDir = fullfile(config.GetSetting('matDir'), ...
                        strcat(config.GetSetting('database'), config.GetSetting('tripletsName')), filename);
                    fullPath = strcat(baseDir, '_white');

                case 'black'
                    baseDir = fullfile(config.GetSetting('matDir'), ...
                        strcat(config.GetSetting('database'), config.GetSetting('tripletsName')), filename);
                    fullPath = strcat(baseDir, '_black');

                case 'model'
                    fullPath = config.DirMake(config.GetSetting('outputDir'), ...
                        config.GetSetting('experiment'), filename);

                case 'param'
                    fullPath = fullfile(config.GetRunBaseDir(), ...
                        config.GetSetting('paramDir'), filename);

                case 'referenceLib'
                    fullPath = config.DirMake(config.GetSetting('matDir'), ...
                        strcat(config.GetSetting('database'), config.GetSetting('referenceLibraryName')), ...
                        filename);

                case 'augmentation'
                    fullPath = config.DirMake(config.GetSetting('matDir'), ...
                        config.GetSetting('augmentation'), filename);

                case 'h5'
                    fullPath = config.DirMake(config.GetSetting('matDir'), ...
                        config.GetSetting('database'), filename);

                otherwise
                    error('Unsupported dataType.');
            end

            [~, ~, ext] = fileparts(fullPath);
            if isempty(ext)
                fullPath = strcat(fullPath, '.', extension);
            elseif ~strcmp(strrep(ext, '.', ''), extension)
                fullPath = strrep(fullPath, ext, strcat('.', extension));
            end
        end

        % ======================================================================
        %> @brief DatasetInfo returns datanames and targetIDs in the current dataset.
        %>
        %> The dataset is fetched from the directory according config::['dataset'].
        %>
        %> @b Usage
        %>
        %> @code
        %> [datanames, targetIDs] = commonUtility.DatasetInfo();
        %> @endcode
        %>
        %> @retval datanames [string] | The datanames of saved files
        %> @retval targetIDs [string] | The targetIDs of saved files
        % ======================================================================
        function [datanames, targetIDs] = DatasetInfo()
            % DatasetInfo returns datanames and targetIDs in the current dataset.
            %
            % The dataset is fetched from the directory according config::['dataset'].
            %
            % @b Usage
            %
            % @code
            % [datanames, targetIDs] = commonUtility.DatasetInfo();
            % @endcode
            %
            % @retval datanames [string] | The datanames of saved files
            % @retval targetIDs [string] | The targetIDs of saved files

            fdir = dir(strrep(commonUtility.GetFilename('dataset'), '.mat', '\*.mat'));
            if numel(fdir) < 1
                error('You should first read the dataset. Use hsiUtility.ReadDataset().');

            else
                datanames = {fdir.name};
                unNames = cellfun(@(x) strsplit(x, {'_', '.'}), datanames', 'un', 0);
                unNames = cellfun(@(x) x{1}, unNames, 'un', 0);
                targetIDs = unique(unNames);
            end
        end

        % ======================================================================
        %> @brief GoodnessOfFit returns coodness of fit coefficient
        %>
        %> Compares the similarity of two curves. The higher the value, the
        %> more similar the curves. Values above 0.99 are considered good for
        %> reconstruction.
        %>
        %> @b Usage
        %>
        %> @code
        %> gfc = commonUtility.GoodnessOfFit(reconstructed, measured);
        %> @endcode
        %>
        %> @param reconstructed [vector] | The vector of the reconstructed curve
        %> @param measured [vector] | The vector of the measured curve
        %>
        %> @retval coefficient [numeric] | The coefficient value
        % ======================================================================
        function gfc = GoodnessOfFit(reconstructed, measured)
            % GoodnessOfFit returns coodness of fit coefficient
            %
            % Compares the similarity of two curves. The higher the value, the
            % more similar the curves. Values above 0.99 are considered good for
            % reconstruction.
            %
            % @b Usage
            %
            % @code
            % gfc = commonUtility.GoodnessOfFit(reconstructed, measured);
            % @endcode
            %
            % @param reconstructed [vector] | The vector of the reconstructed curve
            % @pararm measured [vector] | The vector of the measured curve
            %
            % @retval coefficient [numeric] | The coefficient value
            if size(reconstructed) ~= size(measured)
                reconstructed = reconstructed';
            end
            gfc = abs(reconstructed*measured') / (sqrt(sum(reconstructed.^2)) * sqrt(sum(measured.^2)));
        end

        % ======================================================================
        %> @brief Nmse returns the Normalized Mean Square Error
        %>
        %> Compares the error between two curves. The smaller the value, the
        %> more similar the curves.
        %>
        %> @b Usage
        %>
        %> @code
        %> errVal = commonUtility.Nmse(reconstructed, measured);
        %> @endcode
        %>
        %> @param reconstructed [vector] | The vector of the reconstructed curve
        %> @param measured [vector] | The vector of the measured curve
        %>
        %> @retval errVal [numeric] | The coefficient value
        % ======================================================================
        function errVal = Nmse(reconstructed, measured)
            % Nmse returns the Normalized Mean Square Error
            %
            % Compares the error between two curves. The smaller the value, the
            % more similar the curves.
            %
            % @b Usage
            %
            % @code
            % errVal = commonUtility.Nmse(reconstructed, measured);
            % @endcode
            %
            % @param reconstructed [vector] | The vector of the reconstructed curve
            % @param measured [vector] | The vector of the measured curve
            %
            % @retval errVal [numeric] | The coefficient value
            errVal = (measured - reconstructed) * (measured - reconstructed)' / (measured * reconstructed');
        end
        % ======================================================================
        %> @brief Rmse returns the Root Mean Square Error
        %>
        %> Compares the error between two curves. The smaller the value, the
        %> more similar the curves.
        %>
        %> @b Usage
        %>
        %> @code
        %> errVal = commonUtility.Rmse(reconstructed, measured);
        %> @endcode
        %>
        %> @param reconstructed [vector] | The vector of the reconstructed curve
        %> @param measured [vector] | The vector of the measured curve
        %>
        %> @retval errVal [numeric] | The coefficient value
        % ======================================================================
        function errVal = Rmse(reconstructed, measured)
            % Rmse returns the Root Mean Square Error
            %
            % Compares the error between two curves. The smaller the value, the
            % more similar the curves.
            %
            % @b Usage
            %
            % @code
            % errVal = commonUtility.Rmse(reconstructed, measured);
            % @endcode
            %
            % @param reconstructed [vector] | The vector of the reconstructed curve
            % @param measured [vector] | The vector of the measured curve
            %
            % @retval errVal [numeric] | The coefficient value
            N = size(measured, 2);
            errVal = sqrt(((measured - reconstructed) * (measured - reconstructed)')/N);
        end

        % ======================================================================
        %> @brief Evaluations returns performance metrics for classification tasks
        %>
        %> Returns accuracy, sensitivity and specificity metrics.
        %>
        %> @b Usage
        %>
        %> @code
        %> [accuracy, sensitivity, specificity] = commonUtility.Evaluations(actual, predicted);
        %> @endcode
        %>
        %> @param actual [vector] | The actual values
        %> @param predicted [vector] | The predicted values
        %>
        %> @retval accuracy [numeric] | The model accuracy
        %> @retval sensitivity [numeric] | The model sensitivity
        %> @retval specificity [numeric] | The model specificity
        % ======================================================================
        function [accuracy, sensitivity, specificity] = Evaluations(actual, predicted)
            % Evaluations returns performance metrics for classification tasks
            %
            % Returns accuracy, sensitivity and specificity metrics.
            %
            % @b Usage
            %
            % @code
            % [accuracy, sensitivity, specificity] = commonUtility.Evaluations(actual, predicted);
            % @endcode
            %
            % @param actual [vector] | The actual values
            % @param predicted [vector] | The predicted values
            %
            % @retval accuracy [numeric] | The model accuracy
            % @retval sensitivity [numeric] | The model sensitivity
            % @retval specificity [numeric] | The model specificity
            if ~isnumeric(actual) && isnumeric(predicted)
                actual = double(actual);
            end
            cmat = confusionmat(actual, predicted);
            accuracy = (cmat(1, 1) + cmat(2, 2)) / length(actual);
            sensitivity = cmat(2, 2) / (cmat(2, 1) + cmat(2, 2));
            specificity = cmat(1, 1) / (cmat(1, 1) + cmat(1, 2));
        end
    end
end