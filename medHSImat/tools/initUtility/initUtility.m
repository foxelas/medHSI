% ======================================================================
%> @brief A utility class for initialization purposes.
%
%> Functions are applied on the currently selected dataset,
%> unless mentioned otherwise. The dataset name is recovered as
%>
%> @code
%> config.GetSetting('Dataset')
%> @endcode
%>
% ======================================================================
classdef initUtility
    methods (Static)
        %======================================================================
        %> @brief InitExperiment prepares the initialization settings for
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
        %======================================================================
        %> @brief InitExperiment prepares the initialization settings for
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
        %> @brief CheckImportData checks the structure of filenames and file information to be read.
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
        %======================================================================
        %> @brief CheckImportData checks the structure of filenames and file information to be read.
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
        
            [flag, fileS] = CheckImportDataInternal();
        end
        
        %======================================================================
        %> @brief PrepareLabels prepares labels in the DataDir after the labelme labels have been created.
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
        %======================================================================
        %> @brief PrepareLabels prepares labels in the DataDir after the labelme labels have been created.
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
        
            PrepareLabelsFromLabelMe(inputFolder, dataset, contentConditions, targetConditions);
        end
        
        %======================================================================
        %> @brief UpdateLabels updates labelsInfo files after the labels have been created.
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
        %======================================================================
        %> @brief UpdateLabels updates labelsInfo files after the labels have been created.
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
        %> @brief MakeDataset prepares the target dataset.
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
        %======================================================================
        %> @brief MakeDataset prepares the target dataset.
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
        
            MakeDatasetInternal(varargin{:});
        end
        
        %======================================================================
        %> @brief GetDiscardedPatches returns the names of patches that should be discarded from the analyis.
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
        %======================================================================
        %> @brief GetDiscardedPatches returns the names of patches that should be discarded from the analyis.
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
            discardedPatches = GetDiscardedPatches(); 
        end
        
        %======================================================================
        %> @brief FunctionsWithoutSVMOptimization sets the names of functions, for which no SVM optimization will be used in their children functions.
        %> 
        %> You can add function names according to your prefrences. 
        %>
        %> @b Usage
        %>
        %> @code
        %> functionNames = FunctionsWithoutSVMOptimization();
        %> @endcode
        %>
        %> @retval functionNames [cell array] | The cell array of the parent functions.
        %======================================================================
        function [functionNames] = FunctionsWithoutSVMOptimization()
        %======================================================================
        %> @brief FunctionsWithoutSVMOptimization sets the names of functions, for which no SVM optimization will be used in their children functions.
        %> 
        %> You can add function names according to your prefrences. 
        %>
        %> @b Usage
        %>
        %> @code
        %> functionNames = FunctionsWithoutSVMOptimization();
        %> @endcode
        %>
        %> @retval functionNames [cell array] | The cell array of the parent functions.
        %======================================================================
        
            functionNames = {'Validation', 'ValidateTest2', 'Basics_LOOCV', 'Basics_Test'};
        end
    end
end