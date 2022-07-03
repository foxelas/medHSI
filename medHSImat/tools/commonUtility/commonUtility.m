% ======================================================================
%> @brief commonUtility is a class that handles common utilities.
%>
% ======================================================================
classdef commonUtility
    methods (Static)
        % ======================================================================
        %> @brief commonUtility.GetBoundingBoxMask returns the mask corner indexes for a bounding box.
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
            % ======================================================================
            %> @brief commonUtility.GetBoundingBoxMask returns the mask corner indexes for a bounding box.
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
            bbox = [corners(1), corners(3), corners(2) - corners(1) + 1, corners(4) - corners(3) + 1];
        end

        % ======================================================================
        %> @brief commonUtility.GetFilename returns the the directories for saved data.
        %>
        %> For filename choose between: 'preprocessed', 'dataset', 'target', 'white', 'black', 'raw', 'model', 'param', 'referenceLib', 'output' or 'h5'
        %>
        %> @b Usage
        %>
        %> @code
        %> filename = num2str(id);
        %> fullPath = commonUtility.GetFilename('label', filename);
        %>
        %> dirOnly = commonUtility.GetFilename('dataset', 'none', '');
        %> @endcode
        %>
        %> @param directoryType [string] | The type of the directory to be recovered
        %> @param filename [string] | Optional: The name of the file. Default: ''
        %> @param extension [string] | Optional: The file extension. Default: 'mat'
        %>
        %> @retval fullPath [string] | The full path to the target file
        % ======================================================================
        function [fullPath] = GetFilename(directoryType, filename, extension)
            % ======================================================================
            %> @brief commonUtility.GetFilename returns the the directories for saved data.
            %>
            %> For filename choose between: 'preprocessed', 'dataset', 'target', 'white', 'black', 'raw', 'model', 'param', 'referenceLib', 'output' or 'h5'
            %>
            %> @b Usage
            %>
            %> @code
            %> filename = num2str(id);
            %> fullPath = commonUtility.GetFilename('label', filename);
            %>
            %> dirOnly = commonUtility.GetFilename('dataset', 'none', '');
            %> @endcode
            %>
            %> @param directoryType [string] | The type of the directory to be recovered
            %> @param filename [string] | Optional: The name of the file. Default: ''
            %> @param extension [string] | Optional: The file extension. Default: 'mat'
            %>
            %> @retval fullPath [string] | The full path to the target file
            % ======================================================================

            if nargin < 2
                filename = '';
            end

            if nargin < 3
                extension = 'mat';
            end

            switch lower(directoryType)
                case 'preprocessed'
                    if strcmpi(config.GetSetting('Normalization'), 'raw')
                        fullPath = commonUtility.GetFilename('target', filename);
                    else
                        baseDir = config.DirMake(config.GetSetting('MatDir'), ...
                            strcat(config.GetSetting('Database'), config.GetSetting('NormalizedFolderName')), filename);
                        fullPath = strcat(baseDir, '_', config.GetSetting('Normalization'));
                    end

                case 'dataset'
                    fullPath = config.DirMake(config.GetSetting('MatDir'), ...
                        strcat(config.GetSetting('Dataset')), filename);

                case 'target'
                    baseDir = fullfile(config.GetSetting('MatDir'), ...
                        strcat(config.GetSetting('Database'), config.GetSetting('TripletsFolderName')), filename);
                    fullPath = strcat(baseDir, '_target');

                case 'raw'
                    fullPath = commonUtility.GetFilename('target', filename);

                case 'white'
                    baseDir = fullfile(config.GetSetting('MatDir'), ...
                        strcat(config.GetSetting('Database'), config.GetSetting('TripletsFolderName')), filename);
                    fullPath = strcat(baseDir, '_white');

                case 'black'
                    baseDir = fullfile(config.GetSetting('MatDir'), ...
                        strcat(config.GetSetting('Database'), config.GetSetting('TripletsFolderName')), filename);
                    fullPath = strcat(baseDir, '_black');

                case 'model'
                    fullPath = config.DirMake(config.GetSetting('OutputDir'), ...
                        config.GetSetting('Experiment'), filename);

                case 'param'
                    fullPath = fullfile(config.GetSetting('ParamDir'), filename);

                case 'referencelib'
                    fullPath = config.DirMake(config.GetSetting('MatDir'), ...
                        fullfile(config.GetSetting('Dataset'), config.GetSetting('ReferenceLibraryName')), ...
                        filename);

                case 'h5'
                    fullPath = config.DirMake(config.GetSetting('MatDir'), ...
                        config.GetSetting('Database'), filename);

                case 'output'
                    fullPath = config.DirMake(config.DirMake(config.GetSetting('OutputDir'), ...
                        config.GetSetting('Dataset'), filename));

                otherwise
                    error('Unsupported dataType.');
            end

            [dirpath, target, ext] = fileparts(fullPath);
            if strcmp(target, 'none')
                fullPath = strrep(fullfile(dirpath, '.'), '.', '');
            elseif isempty(extension)
                fullPath = fullfile(dirpath, target);
            elseif isempty(ext)
                fullPath = strcat(fullPath, '.', extension);
            elseif ~strcmp(strrep(ext, '.', ''), extension)
                fullPath = strrep(fullPath, ext, strcat('.', extension));
            end
        end

        % ======================================================================
        %> @brief commonUtility.DatasetInfo returns datanames and targetIDs in the current dataset.
        %>
        %> The dataset is fetched from the directory according config::[Dataset].
        %>
        %> @b Usage
        %>
        %> @code
        %> [datanames, targetIDs] = commonUtility.DatasetInfo();
        %> @endcode
        %>
        %> @param bySample [boolean] | Optional: Flag about whether only unique sample ids should be recovered. Default: true.
        %>
        %> @retval datanames [string] | The datanames of saved files
        %> @retval targetIDs [string] | The targetIDs of saved files
        % ======================================================================
        function [datanames, targetIDs] = DatasetInfo(bySample)
            % ======================================================================
            %> @brief commonUtility.DatasetInfo returns datanames and targetIDs in the current dataset.
            %>
            %> The dataset is fetched from the directory according config::[Dataset].
            %>
            %> @b Usage
            %>
            %> @code
            %> [datanames, targetIDs] = commonUtility.DatasetInfo();
            %> @endcode
            %>
            %> @param bySample [boolean] | Optional: Flag about whether only unique sample ids should be recovered. Default: true.
            %>
            %> @retval datanames [string] | The datanames of saved files
            %> @retval targetIDs [string] | The targetIDs of saved files
            % ======================================================================
            if nargin < 1
                bySample = false;
            end

            fdir = dir(strrep(commonUtility.GetFilename('dataset'), '.mat', '\*.mat'));
            if numel(fdir) < 1
                warning('You should first read the dataset. Use hsiUtility.ReadDataset().');

            else
                datanames = {fdir.name};
                if bySample
                    unNames = cellfun(@(x) strsplit(x, {'_', '.'}), datanames', 'un', 0);
                    unNames = cellfun(@(x) x{1}, unNames, 'un', 0);
                    targetIDs = unique(unNames);
                else
                    unNames = cellfun(@(x) strsplit(x, {'.'}), datanames', 'un', 0);
                    unNames = cellfun(@(x) x{1}, unNames, 'un', 0);
                    targetIDs = unique(unNames);
                end
            end
        end

        % ======================================================================
        %> @brief commonUtility.GoodnessOfFit returns coodness of fit coefficient
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
            % ======================================================================
            %> @brief commonUtility.GoodnessOfFit returns coodness of fit coefficient
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

            if size(reconstructed) ~= size(measured)
                reconstructed = reconstructed';
            end
            gfc = abs(reconstructed*measured') / (sqrt(sum(reconstructed.^2)) * sqrt(sum(measured.^2)));
        end

        % ======================================================================
        %> @brief commonUtility.Nmse returns the Normalized Mean Square Error
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
            % ======================================================================
            %> @brief commonUtility.Nmse returns the Normalized Mean Square Error
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

            errVal = (measured - reconstructed) * (measured - reconstructed)' / (measured * reconstructed');
        end

        % ======================================================================
        %> @brief commonUtility.Rmse returns the Root Mean Square Error
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
            % ======================================================================
            %> @brief commonUtility.Rmse returns the Root Mean Square Error
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

            N = size(measured, 2);
            errVal = sqrt(((measured - reconstructed) * (measured - reconstructed)')/N);
        end

        % ======================================================================
        %> @brief commonUtility.Jaccard returns the Jaccard Coefficient.
        %>
        %> Compares the error between two masks. The higher the value, the
        %> more similar the masks.
        %>
        %> @b Usage
        %>
        %> @code
        %> jac = commonUtility.Jaccard(prediction, groundTruth);
        %> @endcode
        %>
        %> @param prediction [numeric array] | The predicted mask
        %> @param groundTruth [numeric array] | The ground truth mask
        %>
        %> @retval jacVal [numeric] | The jaccard coefficient value
        % ======================================================================
        function jacVal = Jaccard(prediction, groundTruth)
            % ======================================================================
            %> @brief commonUtility.Jaccard returns the Jaccard Coefficient.
            %>
            %> Compares the error between two masks. The higher the value, the
            %> more similar the masks.
            %>
            %> @b Usage
            %>
            %> @code
            %> jac = commonUtility.Jaccard(prediction, groundTruth);
            %> @endcode
            %>
            %> @param prediction [numeric array] | The predicted mask
            %> @param groundTruth [numeric array] | The ground truth mask
            %>
            %> @retval jacVal [numeric] | The jaccard coefficient value
            % ======================================================================

            if ismatrix(prediction) || ismatrix(groundTruth)
                prediction = prediction(:);
                groundTruth = groundTruth(:);
            end

            prediction = logical(prediction);
            groundTruth = logical(groundTruth);

            if (sum(prediction, "all") == 0 && sum(groundTruth, "all") == 0)
                jacVal = 1;
            else
                jacVal = jaccard(prediction, groundTruth);
            end

            if isnan(jacVal)
                jacVal = 1;
            end

            if isempty(jacVal) %% both predicted and real are zeros
                jacVal = 1;
            end
        end

        % ======================================================================
        %> @brief commonUtility.Evaluations returns performance metrics for classification tasks
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
            % ======================================================================
            %> @brief commonUtility.Evaluations returns performance metrics for classification tasks
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
            if ~isnumeric(actual) && isnumeric(predicted)
                actual = double(actual);
            end
            cmat = confusionmat(actual, predicted);
            accuracy = (cmat(1, 1) + cmat(2, 2)) / length(actual);
            sensitivity = cmat(2, 2) / (cmat(2, 1) + cmat(2, 2));
            specificity = cmat(1, 1) / (cmat(1, 1) + cmat(1, 2));
        end

        % ======================================================================
        %> @brief commonUtility.Cell2Mat concatenates the contents of a cell array of values to a matrix.
        %>
        %> @b Usage
        %>
        %> @code
        %> [matArr] = commonUtility.Cell2Mat(cellArr);
        %> @endcode
        %>
        %> @param cellArr [cell array] | The cell array
        %>
        %> @retval arr [numeric array] | The array
        % ======================================================================
        function [arr] = Cell2Mat(cellArr)
            % ======================================================================
            %> @brief commonUtility.Cell2Mat concatenates the contents of a cell array of values to a matrix.
            %>
            %> @b Usage
            %>
            %> @code
            %> [matArr] = commonUtility.Cell2Mat(cellArr);
            %> @endcode
            %>
            %> @param cellArr [cell array] | The cell array
            %>
            %> @retval arr [numeric array] | The array
            % ======================================================================

            isStack = iscell(cellArr{1});
            if isStack
                numStack = numel(cellArr{1});
                arr = cell(numStack, 1);
                for i = 1:numStack
                    cellStack = cellfun(@(x) x{i}', cellArr, 'un', 0);
                    stackArr = [cellStack{:}];
                    arr{i} = stackArr';
                end
            else
                cellArr = cellfun(@(x) x', cellArr, 'un', 0);
                arr = [cellArr{:}];
                arr = arr';
            end
        end

        % ======================================================================
        %> @brief commonUtility.CalcDistance calculates a distance between a target hsi cube and a reference according to a target function.
        %>
        %> @b Usage
        %>
        %> @code
        %> [dist] = commonUtility.CalcDistance(target, reference, funHandle);
        %> @endcode
        %>
        %> @param target [numeric array] | The hsi cube
        %> @param reference [vector] | The reference curve
        %> @param funHandle [function handle] | The function handle for the function to be applied.
        %>
        %> @retval dist [double] | The distance
        % ======================================================================
        function [dist] = CalcDistance(target, reference, funHandle)
            % ======================================================================
            %> @brief commonUtility.CalcDistance calculates a distance between a target hsi cube and a reference according to a target function.
            %>
            %> @b Usage
            %>
            %> @code
            %> [dist] = commonUtility.CalcDistance(target, reference, funHandle);
            %> @endcode
            %>
            %> @param target [numeric array] | The hsi cube
            %> @param reference [vector] | The reference curve
            %> @param funHandle [function handle] | The function handle for the function to be applied.
            %>
            %> @retval dist [double] | The distance
            % ======================================================================
            vals = reshape(target, [size(target, 1) * size(target, 2), size(target, 3)]);
            dists = arrayfun(@(rowidxs) funHandle(vals(rowidxs, :)', reference), (1:size(vals, 1)).');
            dist = reshape(dists, [size(target, 1), size(target, 2)]);
        end

        % ======================================================================
        %> @brief commonUtility.Frechet calculates the Frechet distance between a target and a reference.
        %>
        %> @b Usage
        %>
        %> @code
        %> [dist] = commonUtility.Frechet(target, reference);
        %> @endcode
        %>
        %> @param target [vector] | The target curve
        %> @param reference [vector] | The reference curve
        %>
        %> @retval dist [double] | The distance
        % ======================================================================
        function dist = Frechet(target, reference)
            % ======================================================================
            %> @brief commonUtility.Frechet calculates the Frechet distance between a target and a reference.
            %>
            %> @b Usage
            %>
            %> @code
            %> [dist] = commonUtility.Frechet(target, reference);
            %> @endcode
            %>
            %> @param target [vector] | The target curve
            %> @param reference [vector] | The reference curve
            %>
            %> @retval dist [double] | The distance
            % ======================================================================
            [dist, ~] = DiscreteFrechetDist(target, reference);
        end

        % ======================================================================
        %> @brief commonUtility.Frechet calculates the Proposed distance between a target and a reference.
        %>
        %> @b Usage
        %>
        %> @code
        %> [dist] = commonUtility.ProposedDistance(target, reference);
        %> @endcode
        %>
        %> @param target [vector] | The target curve
        %> @param reference [vector] | The reference curve
        %>
        %> @retval dist [double] | The distance
        % ======================================================================
        function dist = ProposedDistance(target, reference)
            % ======================================================================
            %> @brief commonUtility.Frechet calculates the Proposed distance between a target and a reference.
            %>
            %> @b Usage
            %>
            %> @code
            %> [dist] = commonUtility.ProposedDistance(target, reference);
            %> @endcode
            %>
            %> @param target [vector] | The target curve
            %> @param reference [vector] | The reference curve
            %>
            %> @retval dist [double] | The distance
            % ======================================================================
            dist = ((sum((target).^2) / (sum((reference).^2))));
        end

        % ======================================================================
        %> @brief commonUtility.IsChild checks if a function is child to a set of target parents.
        %>
        %> @b Usage
        %>
        %> @code
        %> [dist] = commonUtility.IsChild(targetParents);
        %> @endcode
        %>
        %> @param targetParents [cell array] | The target parents
        %>
        %> @retval isChild [bool] | The flag that shows if it is child
        % ======================================================================
        function isChild = IsChild(targetParents)
            % ======================================================================
            %> @brief commonUtility.IsChild checks if a function is child to a set of target parents.
            %>
            %> @b Usage
            %>
            %> @code
            %> [dist] = commonUtility.IsChild(targetParents);
            %> @endcode
            %>
            %> @param targetParents [cell array] | The target parents
            %>
            %> @retval isChild [bool] | The flag that shows if it is child
            % ======================================================================
            stack = dbstack();
            isChild = false;
            for k = 1:numel(stack)
                for i = 1:numel(targetParents)
                    if contains(stack(k).name, targetParents{i})
                        isChild = true;
                    end
                end
            end
        end
    end
end