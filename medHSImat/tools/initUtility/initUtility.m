% ======================================================================
%> @brief initUtility is a utility class for initialization purposes.
%
%> Functions are applied on the currently selected dataset,
%> unless mentioned otherwise. The dataset name is recovered as
%>
%> @code
%> config.GetSetting('Dataset')
%> @endcode
%>
%
% For details check https://foxelas.github.io/medHSIdocs/classinit_utility.html
% ======================================================================
classdef initUtility
    methods (Static)
        %======================================================================
        %> @brief initUtility.InitExperiment prepares the initialization settings for
        %> according to the experiment and the selected dataset.
        %>
        %>
        %> If dataset is not provided, config::[Dataset] is used.
        %> It sets config::[Experiment], config::[SaveFolder], config:::[ShowFigures].
        %
        %> @b Usage
        %>
        %> @code
        %> initUtility.InitExperiment('Test-Clustering', 'pslRaw');
        %> @endcode
        %>
        %> @param experiment [char] | The name of the experiment
        %> @param dataset [char] | Optional: The name of the dataset.Default: config::[Dataset].
        %======================================================================
        function [] = InitExperiment(experiment, dataset)

            close all;
            clc;

            if nargin > 1
                config.SetSetting('Dataset', dataset);
            end

            rng(1); % For reproducibility

            config.SetSetting('Experiment', experiment);
            config.SetSetting('SaveFolder', experiment);
            config.SetSetting('ShowFigures', true);

            fprintf('Running for dataset %s\n', config.GetSetting('Dataset'));
        end


        %======================================================================
        %> @brief initUtility.CheckImportData checks the structure of filenames and file information to be read.
        %>
        %> Reads .h5 files from the directory in config::[DataDir].
        %>
        %> @b Usage
        %> @code
        %>	[flag, fileS] = CheckImportData();
        %> @endcode
        %>
        %> @retval flag [boolean] | A flag that indicates whether the check passes
        %> @retval fileS [struct] | A structure that contains information about files to be read
        %======================================================================
        function [flag, fileS] = CheckImportData()

            [flag, fileS] = CheckImportDataInternal();
        end

        %======================================================================
        %> @brief initUtility.PrepareLabels prepares labels in the DataDir after the labelme labels have been created.
        %>
        %> You can modify this function, according to your data structure.
        %>
        %> Reads img.png files created by Labelme and prepares black and white label masks.
        %>
        %> @b Usage
        %> @code
        %> initUtility.PrepareLabels('02-Labelme', 'pslRaw', {'tissue', true}, {'raw', false});
        %> @endcode
        %>
        %> @param inputFolder [string] | The input folder where the labelme output is located. It should exist under config::[Dataset]/dataset/.
        %> @param dataset [string] | The name of target dataset
        %> @param  contentConditions [cell array] | The content conditions for reading files
        %> @param targetConditions [cell array] | Optional: The target conditions for reading files. Default: none.
        %======================================================================
        function [] = PrepareLabels(inputFolder, dataset, contentConditions, targetConditions)

            PrepareLabelsFromLabelMe(inputFolder, dataset, contentConditions, targetConditions);
        end

        %======================================================================
        %> @brief initUtility.UpdateLabels updates labelsInfo files after the labels have been created.
        %> Labels should be saved in %config::[DataDir]/'02-Labels'/
        %>
        %> Reads img.png files created by Labelme and prepares black and white label masks.
        %>
        %> @b Usage
        %> @code
        %> initUtility.UpdateLabelInfos('pslRaw');
        %> @endcode
        %>
        %> @param dataset [string] | Optional: The name of target dataset. Default: config::[Dataset].
        %======================================================================
        function [] = UpdateLabelInfos(dataset)

            if nargin > 1
                config.SetSetting('Dataset', dataset);
            end

            [~, targetIDs] = commonUtility.DatasetInfo();
            for i = 1:length(targetIDs)
                targetID = targetIDs{i};
                spectralData = hsiUtility.LoadHsiAndLabel(targetID);
                labelInfo = hsiInfo.ReadHsiInfoFromHsi(spectralData);

                %% Save data info in a file
                filename = commonUtility.GetFilename('dataset', targetID);
                save(filename, 'spectralData', 'labelInfo', '-v7.3');
            end
        end

        %======================================================================
        %> @brief initUtility.MakeDataset prepares the target dataset.
        %>
        %> You can choose among:
        %> -All: the entire dataset (reads from scratch)
        %> -Raw: the raw dataset (reads from scratch)
        %> -Fix: the fix dataset (reads from scratch)
        %> -Augmented: the augmented dataset (based on base dataset)
        %> -512: the resized 512x512 dataset (based on base dataset)
        %> -32: the 32x32 patch dataset (based on base dataset)
        %> -pca: the pca dataset (based on base dataset)
        %>
        %> @b Usage
        %>
        %> @code
        %> config.SetSetting('Dataset', 'pslRaw');
        %> initUtility.MakeDataset('Augmented');
        %> %Returns dataset 'pslRawAugmented'
        %>
        %> initUtility.MakeDataset('Augmented', 'pslRaw');
        %>
        %> @endcode
        %>
        %> @param targetDataset [char] | Optional: The target dataset. Default: 'All'.
        %> @param targetDataset [char] | Optional: The base dataset. Default: 'psl'.
        %======================================================================
        function [] = MakeDataset(varargin)

            MakeDatasetInternal(varargin{:});
        end

        %======================================================================
        %> @brief initUtility.GetDiscardedPatches returns the names of patches that should be discarded from the analyis.
        %>
        %> You can add values according to your protocol.
        %>
        %> @b Usage
        %>
        %> @code
        %> [discardedPatches] =  GetDiscardedPatches();
        %>
        %> [discardedPatches] =  initUtility.DiscardedPatches();
        %> @endcode
        %>
        %> @retval discardedPatches [cell array] | The ids of the discarded patches.
        %======================================================================
        function [discardedPatches] = DiscardedPatches()
            discardedPatches = GetDiscardedPatches();
        end

        %======================================================================
        %> @brief initUtility.FunctionsWithoutSVMOptimization sets the names of functions, for which no SVM optimization will be used in their children functions.
        %>
        %> You can add function names according to your prefrences.
        %>
        %> @b Usage
        %>
        %> @code
        %> disabledParentFuns = FunctionsWithoutSVMOptimization();
        %> @endcode
        %>
        %> @retval disabledParentFuns [cell array] | The cell array of the parent functions.
        %======================================================================
        function [disabledParentFuns] = FunctionsWithoutSVMOptimization()

            disabledParentFuns = {'Validation', 'ValidateTest2', 'Basics_LOOCV', 'Basics_Test'};
        end
    end
end