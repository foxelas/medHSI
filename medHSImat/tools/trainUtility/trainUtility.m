% ======================================================================
%> @brief trainUtility is a class that handles training of hyperspectral data.
%>
% ======================================================================
classdef trainUtility
    methods (Static)

        function [] = ExportTrainTest(baseDataset, testIds)
            
            if nargin < 1 
                baseDataset = config.GetSetting('Dataset');
            end
            
            if nargin < 2
                testIds = {'157', '251', '227'};
            end

            config.SetSetting('Dataset', baseDataset);
            [~, targetIDs] = commonUtility.DatasetInfo();

            fileName = commonUtility.GetFilename('output', ...
                fullfile(config.GetSetting('DatasetsFolderName'), strcat('hsi_', config.GetSetting('Dataset'), '_train')), 'h5');
            trainTargetIDs = targetIDs(~contains(targetIDs, testIds));
            hsiUtility.SaveToH5(trainTargetIDs, fileName);

            fileName = commonUtility.GetFilename('output', ...
                fullfile(config.GetSetting('DatasetsFolderName'), strcat('hsi_', config.GetSetting('Dataset'), '_test')), 'h5');
            testTargetIDs = targetIDs(contains(targetIDs, testIds));
            hsiUtility.SaveToH5(testTargetIDs, fileName);
        end
        
        function [] = ExportPatientFolds(baseDataset)
            targetDataset =  strcat(baseDataset, 'PatientValidation');

            foldSampleIds = {{'001'}; {'002', '003', '004'}; {'005'}; {'006'}; {'007'}; {'008', '009'}; {'010'}; {'011'}; {'012'}; {'013'}; {'014'}; {'015', '016', '017', '018'}; {'019'}};
            
            discardedPatches = {'187_patch32', '187_patch33',  '199_patch24', '199_patch29', '199_patch30', '199_patch31', '199_patch32', '205_patch16', '205_patch22', ...
                '205_patch23', '205_patch24', '205_patch29', '205_patch30', '205_patch31', '205_patch32', '205_patch33', '205_patch34', '205_patch35', '205_patch37', ...
                '205_patch38', '205_patch39', '205_patch40', '205_patch41', '205_patch42', '205_patch43', '205_patch44', '205_patch47', '205_patch48', '205_patch49', ...
                '205_patch51', '205_patch52', '205_patch53', '205_patch54', '205_patch57', '205_patch58', '205_patch61', '205_patch62', '205_patch63', '205_patch66', ...
                '205_patch67', '205_patch71', '205_patch72', '205_patch73', '205_patch74', '205_patch75', '205_patch76', '205_patch77', '205_patch78', '205_patch81', ...
                '205_patch82', '205_patch83', '205_patch84', '205_patch85', '205_patch86', '205_patch87', '205_patch88', '205_patch91', '205_patch92', '205_patch93', ...
                '205_patch94', '205_patch95', '205_patch96', '205_patch97', '205_patch98', '205_patch99', '205_patch100', '205_patch101', '205_patch102', '205_patch103', ...
                '205_patch104', '205_patch105', '205_patch106', '205_patch107', '205_patch108', '205_patch109', '205_patch110', '205_patch111', '205_patch112', ...
                '205_patch113', '205_patch114', '205_patch117', '205_patch118', '205_patch119', '212_patch7', '251_patch41', '230_patch27', '227_patch1',...
                '193_patch8', '181_patch64', '187_patch1', '160_patch8', '157_patch3', '150_patch4'};
            
            config.SetSetting('Dataset', targetDataset);
            baseDir = commonUtility.GetFilename('dataset', '', '');

            config.SetSetting('Dataset', baseDataset);
            [~, targetIDs] = commonUtility.DatasetInfo();
            
            targetIDs = targetIDs(~contains(targetIDs, discardedPatches));
            
            folds = numel(foldSampleIds); 
            foldTargets = cell(folds, 1);

            for k = 1:folds                
                targetSampleIds = foldSampleIds{k};
                foldDir = config.DirMake(baseDir, num2str(k), '\');
                testIds = {};
                
                c = 0; 
                for i = 1:length(targetIDs)
                    
                    targetName = num2str(targetIDs{i});
                    [spectralData, labelInfo] = hsiUtility.LoadHsiAndLabel(targetName);

                    if any(contains(targetSampleIds, labelInfo.SampleID))
                        saveDir = fullfile(foldDir, strcat(targetName, '.mat'));
                        save(saveDir, 'spectralData', 'labelInfo');
                        c = c+1; 
                        testIds{c} = targetName;
                    end
                end
                
                foldTargets{k} = testIds; 
                
                fileName = commonUtility.GetFilename('output', ...
                    fullfile(config.GetSetting('DatasetsFolderName'), num2str(k), strcat('hsi_', config.GetSetting('Dataset'), '_train')), 'h5');
                trainTargetIDs = targetIDs(~contains(targetIDs, testIds));
                hsiUtility.SaveToH5(trainTargetIDs, fileName);

                fileName = commonUtility.GetFilename('output', ...
                    fullfile(config.GetSetting('DatasetsFolderName'), num2str(k),strcat('hsi_', config.GetSetting('Dataset'), '_test')), 'h5');
                testTargetIDs = targetIDs(contains(targetIDs, testIds));
                hsiUtility.SaveToH5(testTargetIDs, fileName);
            end  

        end
        
        % ======================================================================
        %> @brief Augment applies augmentation on the dataset
        %>
        %> The base dataset should be already saved before running augmentation.
        %> For details check @c AugmentInternal .
        %>
        %> 'set1': applies vertical and horizontal flipping.
        %> 'set2': applies random rotation.
        %>
        %> @b Usage
        %>
        %> @code
        %> baseDataset = 'pslData';
        %> hsiUtility.PrepareDataset(baseDataset, {'tissue', true});
        %>
        %> augType = 'set1';
        %> augmentedDataset = 'pslDataAug';
        %> trainUtility.Augment(baseDataset, augmentedDataset, augType);
        %> @endcode
        %>
        %> @param baseDataset [char] | The base dataset
        %> @param targetDataset [char] | The target dataset
        %> @param augType [char] | Optional: The augmentation type ('set1' or 'set2'). Default: 'set1'
        %>
        % ======================================================================
        function [] = Augment(varargin)
            % Augment applies augmentation on the dataset
            %
            % The base dataset should be already saved before running augmentation.
            % For details check @c AugmentInternal .
            %
            % 'set1': applies vertical and horizontal flipping.
            % 'set2': applies random rotation.
            %
            % @b Usage
            %
            % @code
            % baseDataset = 'pslData';
            % hsiUtility.PrepareDataset(baseDataset, {'tissue', true});
            %
            % augType = 'set1';
            % augmentedDataset = 'pslDataAug';
            % trainUtility.Augment(baseDataset, augmentedDataset, augType);
            % @endcode
            %
            % @param baseDataset [char] | The base dataset
            % @param targetDataset [char] | The target dataset
            % @param augType [char] | Optional: The augmentation type ('set1' or 'set2'). Default: 'set1'
            %
            AugmentInternal(varargin{:});
        end

        % ======================================================================
        %> @brief ResizeInternal applies resizing on the dataset.
        %>
        %> The base dataset should be already saved with @c hsiUtility.PrepareDataset before running ResizeInternal.
        %>
        %> If all arguments are not provided, they are fetched from the config file.
        %> Target settings are: config::[HasResizeOptions], config::[ImageDimension] and config::[SplitToPatches].
        %>
        %> For details check @c ResizeInternal .
        %>
        %> @b Usage
        %>
        %> @code
        %> baseDataset = 'pslData';
        %> hsiUtility.PrepareDataset(baseDataset, {'tissue', true});
        %> config.SetSetting('HasResizeOptions', true);
        %> config.SetSetting('ImageDimension', 512);
        %> config.SetSetting('SplitToPatches', false);
        %> resizedDataset = 'psl512';
        %> trainUtility.Resize(baseDataset, resizedDataset);
        %>
        %> resizedDataset = 'psl-patches';
        %> trainUtility.Resize(baseDataset, resizedDataset, true, 32, true);
        %> @endcode
        %>
        %> @param baseDataset [char] | The base dataset
        %> @param targetDataset [char] | The target dataset
        %> @param hasResizeOptions [logical] | Optional: Flag to enable resizing. Default: config:[HasResizeOptions].
        %> @param imageDimension [int] | Optional: The target image size. Default: config:[ImageDimension].
        %> @param splitToPatches [logical] | Optional: Flag to enable split to patches. Default: config:[SplitToPatches].
        % ======================================================================
        function [] = Resize(varargin)
            % ResizeInternal applies resizing on the dataset.
            %
            % The base dataset should be already saved with @c hsiUtility.PrepareDataset before running ResizeInternal.
            %
            % If all arguments are not provided, they are fetched from the config file.
            % Target settings are: config::[HasResizeOptions], config::[ImageDimension] and config::[SplitToPatches].
            %
            % For details check @c ResizeInternal .
            %
            % @b Usage
            %
            % @code
            % baseDataset = 'pslData';
            % hsiUtility.PrepareDataset(baseDataset, {'tissue', true});
            % config.SetSetting('HasResizeOptions', true);
            % config.SetSetting('ImageDimension', 512);
            % config.SetSetting('SplitToPatches', false);
            % resizedDataset = 'psl512';
            % trainUtility.Resize(baseDataset, resizedDataset);
            %
            % resizedDataset = 'psl-patches';
            % trainUtility.Resize(baseDataset, resizedDataset, true, 32, true);
            % @endcode
            %
            % @param baseDataset [char] | The base dataset
            % @param targetDataset [char] | The target dataset
            % @param hasResizeOptions [logical] | Optional: Flag to enable resizing. Default: config:[HasResizeOptions].
            % @param imageDimension [int] | Optional: The target image size. Default: config:[ImageDimension].
            % @param splitToPatches [logical] | Optional: Flag to enable split to patches. Default: config:[SplitToPatches].
            ResizeInternal(varargin{:});
        end

        % ======================================================================
        %> @brief PreprocessInternal transforms the dataset into images or pixels as preparation for training.
        %>
        %> For data type 'image', the function rearranges pixels as a pixel (observation) by feature 2D array.
        %> For more details check @c function PreprocessInternal .
        %> This function can also handle multiscale transformations.
        %>
        %> @b Usage
        %>
        %> @code
        %>   [X, y, sRGBs, fgMasks, labelImgs] = trainUtility.Preprocess(hsiList, labelInfos, dataType);
        %>
        %>   transformFun = @Dimred;
        %>   [X, y, sRGBs, fgMasks, labelImgs] = PreprocessInternal(hsiList, labelInfos, dataType, transformFun);
        %> @endcode
        %>
        %> @param hsiList [cell array] | The list of hsi objects
        %> @param labelInfos [cell array] | The list of hsiInfo objects
        %> @param dataType [char] | The target data type, either 'hsi', 'image' or 'pixel'
        %> @param transformFun [function handle] | Optional: The function handle for the function to be applied. Default: None.
        %>
        %> @retval X [numeric array or cell array] | The processed data
        %> @retval y [numeric array or cell array] | The processed values
        %> @retval sRGBs [cell array] | The array of sRGBs for the data
        %> @retval fgMasks [cell array] | The foreground masks of sRGBs for the data
        %> @retval labelImgs [cell array] | The label masks for the data
        %>
        % ======================================================================
        function [X, y, sRGBs, fgMasks, labelImgs] = Preprocess(hsiList, labelInfos, varargin)
            % PreprocessInternal transforms the dataset into images or pixels as preparation for training.
            %
            % For data type 'image', the function rearranges pixels as a pixel (observation) by feature 2D array.
            % For more details check @c function PreprocessInternal .
            % This function can also handle multiscale transformations.
            %
            % @b Usage
            %
            % @code
            %   [X, y, sRGBs, fgMasks, labelImgs] = trainUtility.Preprocess(hsiList, labelInfos, dataType);
            %
            %   transformFun = @Dimred;
            %   [X, y, sRGBs, fgMasks, labelImgs] = PreprocessInternal(hsiList, labelInfos, dataType, transformFun);
            % @endcode
            %
            % @param hsiList [cell array] | The list of hsi objects
            % @param labelInfos [cell array] | The list of hsiInfo objects
            % @param dataType [char] | The target data type, either 'hsi', 'image' or 'pixel'
            % @param transformFun [function handle] | Optional: The function handle for the function to be applied. Default: None.
            %
            % @retval X [numeric array or cell array] | The processed data
            % @retval y [numeric array or cell array] | The processed values
            % @retval sRGBs [cell array] | The array of sRGBs for the data
            % @retval fgMasks [cell array] | The foreground masks of sRGBs for the data
            % @retval labelImgs [cell array] | The label masks for the data
            %
            [X, y, sRGBs, fgMasks, labelImgs] = PreprocessInternal(hsiList, labelInfos, varargin{:});
        end

        % ======================================================================
        %> @brief SplitDatasetInternalsplits the dataset to train, test and prepares a cross validation setting.
        %>
        %> For more details check @c function SplitDatasetInternal .
        %>
        %> @b Usage
        %>
        %> @code
        %>   [trainData, testData, cvp] = trainUtility.SplitDataset(dataset, folds, testTargets, dataType);
        %>
        %>   transformFun = @Dimred;
        %>   [trainData, testData, cvp] = SplitDatasetInternal(dataset, folds, testTargets, dataType, transformFun);
        %> @endcode
        %>
        %> @param dataset [char] | The target dataset
        %> @param folds [numeric] | The number of folds
        %> @param testTargets [cell array] | The IDs of the test targets
        %> @param dataType [char] | The target data type, either 'hsi', 'image' or 'pixel'
        %> @param transformFun [function handle] | Optional: The function handle for the function to be applied. Default: None.
        %>
        %> @retval trainData [struct] | The train data
        %> @retval testData [struct] | The test data
        %> @retval cvp [struct] | The cross validation settings
        %>
        % ======================================================================
        function [trainData, testData, cvp] = SplitDataset(dataset, folds, testTargets, dataType, varargin)
            % SplitDatasetInternalsplits the dataset to train, test and prepares a cross validation setting.
            %
            % For more details check @c function SplitDatasetInternal .
            %
            % @b Usage
            %
            % @code
            %   [trainData, testData, cvp] = trainUtility.SplitDataset(dataset, folds, testTargets, dataType);
            %
            %   transformFun = @Dimred;
            %   [trainData, testData, cvp] = SplitDatasetInternal(dataset, folds, testTargets, dataType, transformFun);
            % @endcode
            %
            % @param dataset [char] | The target dataset
            % @param folds [numeric] | The number of folds
            % @param testTargets [cell array] | The IDs of the test targets
            % @param dataType [char] | The target data type, either 'hsi', 'image' or 'pixel'
            % @param transformFun [function handle] | Optional: The function handle for the function to be applied. Default: None.
            %
            % @retval trainData [struct] | The train data
            % @retval testData [struct] | The test data
            % @retval cvp [struct] | The cross validation settings
            %
            [trainData, testData, cvp] = SplitDatasetInternal(dataset, folds, testTargets, dataType, varargin{:});
        end

        % ======================================================================
        %> @brief KfoldPartitions splits cross validation partitions.
        %>
        %> @b Usage
        %>
        %> @code
        %> folds = 5;
        %> [cvp] = trainUtility.KfoldPartitions(numData, folds);
        %> @endcode
        %>
        %> @param numData [int] | The number of data
        %> @param folds [int] | The number of folds
        %>
        %> @retval cvp [cell array] | The cross validation index splits
        % ======================================================================
        function [cvp] = KfoldPartitions(numData, folds)
            % KfoldPartitions splits cross validation partitions.
            %
            % @b Usage
            %
            % @code
            % folds = 5;
            % [cvp] = trainUtility.KfoldPartitions(numData, folds);
            % @endcode
            %
            % @param numData [int] | The number of data
            % @param folds [int] | The number of folds
            %
            % @retval cvp [cell array] | The cross validation index splits

            if nargin < 2
                folds = 10;
            end
            cvp = cvpartition(numData, 'kfold', folds);
        end

        % ======================================================================
        %> @brief SVM trains an RBF SVM classifier.
        %>
        %> You can alter the settings of the SVM classifier according to your specifications.
        %>
        %> @b Usage
        %>
        %> @code
        %> SVMModel = SVM(Xtrain, ytrain);
        %> @endcode
        %>
        %> @param Xtrain [numeric array] | The train data
        %> @param ytrain [numeric array] | The train labels
        %>
        %> @retval SVMModel [model] | The trained SVM model
        % ======================================================================
        function [SVMModel] = SVM(Xtrain, ytrain, svmSettings)
            % SVM trains an RBF SVM classifier.
            %
            % You can alter the settings of the SVM classifier according to your specifications.
            %
            % @b Usage
            %
            % @code
            % SVMModel = SVM(Xtrain, ytrain);
            % @endcode
            %
            % @param Xtrain [numeric array] | The train data
            % @param ytrain [numeric array] | The train labels
            %
            % @retval SVMModel [model] | The trained SVM model

            iterLim = 10000;
            % TO REMOVE
            factors = 10;
            kk = ceil(decimate(1:size(Xtrain, 1), factors));
            Xtrain = Xtrain(kk, :);
            ytrain = ytrain(kk, :);
            % TO REMOVE
        
%             hasOptimization = ~commonUtility.IsChild({'RunKfoldValidation', 'ValidateTest2'});
            hasOptimization = ~commonUtility.IsChild({'RunKfoldValidation', 'ValidateTest2', 'Basics_Dimred2', 'Basics_CrossValidateSVM'});
            filePath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'), 'SVMModel'), 'mat');
            
            if hasOptimization
                optim = 'Bayesian'; %'Grid' 
                textPath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'), 'optimizationStruct'), 'txt');
                diary(textPath);
                close all;

                if strcmpi(optim, 'Bayesian') %Use Bayesian optimization
    
    %                 optimParams = {'BoxConstraint', 'KernelScale', 'Standardize', 'KernelFunction'};
                    optimParams = 'auto';
                    optimOptions =  struct('AcquisitionFunctionName', 'expected-improvement-plus', 'MaxObjectiveEvaluations', 200);
                    
                    SVMModel = fitcsvm(Xtrain, ytrain, 'IterationLimit', iterLim, ...
                         'Standardize', true, 'KernelFunction', 'rbf', ...
                         'OptimizeHyperparameters', optimParams, 'HyperparameterOptimizationOptions',optimOptions); 
                    
    
                    imgPath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'), 'optimizationObjective'), 'png');
                    plots.SavePlot(1, imgPath);
                    imgPath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'), 'optimizationParams'), 'png');
                    plots.SavePlot(2, imgPath);     
                end

                if strcmpi(optim, 'Grid')

                    boxConstraints =linspace(1, 1000, 10);
                    kernelScales = linspace(1, 50, 10);
                    
                    SVMModel = fitcsvm(Xtrain, ytrain, 'IterationLimit', iterLim, ...
                               'Standardize', true, 'KernelFunction', 'rbf', 'KernelScale', 'auto');

                    bestModel = SVMModel; 
                    bestPerf = bestModel.ConvergenceInfo.Objective;
                    fprintf('First: BoxC %.5f, KernelScale %.5f\n', bestModel.BoxConstraints(1), bestModel.KernelParameters.Scale);

                    for boxVal = boxConstraints
                        for kernelVal = kernelScales
                            SVMModel = fitcsvm(Xtrain, ytrain, 'IterationLimit', iterLim, ...
                               'Standardize', true, 'KernelFunction', 'rbf', 'BoxConstraint', boxVal, 'KernelScale', kernelVal);
                            perf = SVMModel.ConvergenceInfo.Objective;
                            if (perf < bestPerf)
                                bestModel = SVMModel;
                                bestPerf = bestModel.ConvergenceInfo.Objective;
                                fprintf('Best: BoxC %.5f, KernelScale %.5f\n', bestModel.BoxConstraints(1), bestModel.KernelParameters.Scale);
                            end
                        end
                    end
                    fprintf('\nFinal: BoxC %.5f, KernelScale %.5f\n', bestModel.BoxConstraints(1), bestModel.KernelParameters.Scale);
                    SVMModel = bestModel;
                end
                diary off 

            else
                if ~isempty(svmSettings)
                    SVMModel = fitcsvm(Xtrain, ytrain, 'Standardize', true, 'KernelFunction', 'rbf', ... %'RBF', 'linear', 'polynomial' |   'OutlierFraction', 0.1, | 'PolynomialOrder', 5
                        'BoxConstraint', svmSettings(1), 'KernelScale', svmSettings(2));
                else
                    SVMModel = fitcsvm(Xtrain, ytrain, 'Standardize', true, 'KernelFunction', 'rbf', ... %'RBF', 'linear', 'polynomial' |   'OutlierFraction', 0.1, | 'PolynomialOrder', 5
                        'KernelScale', 'auto');
                end
                
                %, 'OutlierFraction', 0.05);
                %'Cost', [0, 1; 3, 0], 'IterationLimit', 10000 | 'OutlierFraction', 0.05
                %'Standardize', true | 'BoxConstraint', 2, 'IterationLimit', iterLim,
            end
            
            save(filePath, 'SVMModel');
        end

        % ======================================================================
        %> @brief RunSVM trains and test an SVM classifier.
        %>
        %> @b Usage
        %>
        %> @code
        %> [accuracy, sensitivity, specificity, st, SVMModel] = trainUtility.RunSVM(Xtrain, ytrain, Xvalid, yvalid);
        %> @endcode
        %>
        %> @param Xtrain [numeric array] | The train data
        %> @param ytrain [numeric array] | The train labels
        %> @param Xvalid [numeric array] | The test data
        %>
        %> @retval accuracy [numeric] | The model accuracy
        %> @retval sensitivity [numeric] | The model sensitivity
        %> @retval specificity [numeric] | The model specificity
        %> @retval st [double] | The train run time
        %> @retval SVMModel [model] | The trained SVM model
        % ======================================================================
        function [predlabels, st, SVMModel] = RunSVM(Xtrain, ytrain, Xvalid, svmSettings)
            % RunSVM trains and test an SVM classifier.
            %
            % @b Usage
            %
            % @code
            % [accuracy, sensitivity, specificity, st, SVMModel] = trainUtility.RunSVM(Xtrain, ytrain, Xvalid, yvalid);
            % @endcode
            %
            % @param Xtrain [numeric array] | The train data
            % @param ytrain [numeric array] | The train labels
            % @param Xvalid [numeric array] | The test data
            %
            % @retval accuracy [numeric] | The model accuracy
            % @retval sensitivity [numeric] | The model sensitivity
            % @retval specificity [numeric] | The model specificity
            % @retval st [double] | The train run time
            % @retval SVMModel [model] | The trained SVM model

            tic;
            SVMModel = trainUtility.SVM(Xtrain, ytrain,svmSettings);
            st = toc;
            predlabels = predict(SVMModel, Xvalid);
        end

        % ======================================================================
        %> @brief StackMultiscale trains a collection of stacked classifiers.
        %>
        %> @b Usage
        %>
        %> @code
        %> [predLabels, st, SVMModels, XtrainTrans, XvalidTrans] = trainUtility.StackMultiscale(@trainUtility.SVM, 'voting', Xtrain, ytrain, Xvalid);
        %> @endcode
        %>
        %> @param classifierFun [function handle] | The classifier function
        %> @param fusionMethod [char] | The fusion method
        %> @param Xtrain [cell array] | The train data
        %> @param ytrain [numeric array] | The train labels
        %> @param Xvalid [cell array] | The test data
        %>
        %> @retval predLabels [numeric array] | The predicted labels
        %> @retval st [double] | The train run time
        %> @retval models [model] | The trained stacked models
        %> @retval XtrainTrans [numeric array] | The transformed train data
        %> @retval XvalidTrans [numeric array] | The transformed test data
        % ======================================================================
        function [predLabels, st, models, XtrainTrans, XvalidTrans] = StackMultiscale(classifierFun, fusionMethod, Xtrain, ytrain, Xvalid)
            % StackMultiscale trains a collection of stacked classifiers.
            %
            % @b Usage
            %
            % @code
            % [predLabels, st, SVMModels, XtrainTrans, XvalidTrans] = trainUtility.StackMultiscale(@trainUtility.SVM, 'voting', Xtrain, ytrain, Xvalid);
            % @endcode
            %
            % @param classifierFun [function handle] | The classifier function
            % @param fusionMethod [char] | The fusion method
            % @param Xtrain [cell array] | The train data
            % @param ytrain [numeric array] | The train labels
            % @param Xvalid [cell array] | The test data
            % @param yvalid [numeric array] | The test labels
            %
            % @retval predLabels [numeric array] | The predicted labels
            % @retval st [double] | The train run time
            % @retval models [model] | The trained stacked models
            % @retval XtrainTrans [numeric array] | The transformed train data
            % @retval XvalidTrans [numeric array] | The transformed test data

            st = 0;
            if ~iscell(Xtrain)
                error('Data should be in a cell format');
            end

            numScales = numel(Xtrain);

            models = cell(numScales, 1);
            XtrainTrans = cell(numScales, 1);
            XvalidTrans = cell(numScales, 1);
            for scale = 1:numScales
                XtrainScale = Xtrain{scale};
                XvalidScale = Xvalid{scale};

                tic;
                trainedModel = classifierFun(XtrainScale, ytrain);
                tclassifiertemp = toc;
                st = st + tclassifiertemp;

                models{scale} = trainedModel;
                XtrainTrans{scale} = XtrainScale;
                XvalidTrans{scale} = XvalidScale;
            end

            predLabels = trainUtility.Predict(models, XvalidTrans, fusionMethod);
        end

        % ======================================================================
        %> @brief Predict returns the predicted labels from the model.
        %>
        %> @b Usage
        %>
        %> @code
        %> predLabels = trainUtility.Predict(trainedModel, Xtest);
        %>
        %> predLabels = trainUtility.Predict(trainedModel, Xtest, 'voting');
        %> @endcode
        %>
        %> @retval trainedModel [model] | The trained model
        %> @param Xtest [numeric array] | The test data
        %> @param fusionMethod [char] | Optional: The fusion method. Default: 'voting'.
        %>
        %> @retval predLabels [numeric array] | The predicted labels
        % ======================================================================
        function predLabels = Predict(trainedModel, Xtest, fusionMethod, hasPosterior)
            % Predict returns the predicted labels from the model.
            %
            % @b Usage
            %
            % @code
            % predLabels = trainUtility.Predict(trainedModel, Xtest);
            %
            % predLabels = trainUtility.Predict(trainedModel, Xtest, 'voting');
            % @endcode
            %
            % @retval trainedModel [model] | The trained model
            % @param Xtest [numeric array] | The test data
            % @param fusionMethod [char] | Optional: The fusion method. Default: 'voting'.
            %
            % @retval predLabels [numeric array] | The predicted labels

            if nargin < 3
                fusionMethod = 'voting';
            end

            if nargin < 4 
                hasPosterior = false; 
            end 
            
            if iscell(trainedModel) && numel(trainedModel) == 1
                trainedModel = trainedModel{1};
            end

            if iscell(trainedModel)
                models = trainedModel;
                numModels = numel(models);
                preds = zeros(size(Xtest{1}, 1), numModels);
                postProbs = zeros(size(Xtest{1}, 1), numModels);

                for i = 1:numModels
                    trainedModel = models{i};
                    scores = Xtest{i};
                    [preds(:, i), postProbs(:,i)] = predict(trainedModel, scores);
                end

                if strcmpi(fusionMethod, 'voting')
                    predLabels = round(sum(preds./size(preds, 2), 2));
                    postProbs = mean(postProbs, 2);

                else
                    error('Not supported fusion method.')
                end

            else
                [predLabels, postProbs] = predict(trainedModel, Xtest);
            end
            
            if hasPosterior 
                predLabels = {predLabels, postProbs};
            end
        end

        % ======================================================================
        %> @brief Cell2Mat concatenates the contents of a cell array of values to a matrix.
        %>
        %> @b Usage
        %>
        %> @code
        %> [matArr] = trainUtility.Cell2Mat(cellArr);
        %> @endcode
        %>
        %> @param cellArr [cell array] | The cell array
        %>
        %> @retval arr [numeric array] | The array
        % ======================================================================
        function [arr] = Cell2Mat(cellArr)
            % Cell2Mat concatenates the contents of a cell array of values to a matrix.
            %
            % @b Usage
            %
            % @code
            % [matArr] = trainUtility.Cell2Mat(cellArr);
            % @endcode
            %
            % @param cellArr [cell array] | The cell array
            %
            % @retval arr [numeric array] | The array

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
        %> @brief DimredAndTrain trains and test an SVM classifier after dimension reduction.
        %>
        %> @b Usage
        %>
        %> @code
        %> [performanceStruct, trainedModel, Xvalid] = trainUtility.DimredAndTrain(trainData, testData, method, q);
        %> @endcode
        %>
        %> @param trainData [struct] | The train data
        %> @param testData [struct] | The test data
        %> @param method [char] | The dimension reduction method
        %> @param q [int] | The reduced dimension
        %> @param varargin | Additional optional arguments
        %>
        %> @retval performanceStruct [struct] | The model's performance
        %> @retval trainedModel [model] | The trained SVM model
        %> @retval Xvalid [numeric array] | The dimension-reduced test data
        % ======================================================================
        function [performanceStruct, trainedModel, XValid] = DimredAndTrain(trainData, testData, method, q, svmSettings, varargin)
            % DimredAndTrain trains and test an SVM classifier after dimension reduction.
            %
            % @b Usage
            %
            % @code
            % [performanceStruct, trainedModel, Xvalid] = trainUtility.DimredAndTrain(trainData, testData, method, q);
            % @endcode
            %
            % @param trainData [struct] | The train data
            % @param testData [struct] | The test data
            % @param method [char] | The dimension reduction method
            % @param q [int] | The reduced dimension
            % @param varargin | Additional optional arguments
            %
            % @retval performanceStruct [struct] | The model's performance
            % @retval trainedModel [model] | The trained SVM model
            % @retval Xvalid [numeric array] | The dimension-reduced test data

            if strcmpi(method, 'lda')
                method = 'LDA-all';
            end
            
            if strcmpi(method, 'pca-lda')
                method = 'PCA-LDA-all';
            end
            
            preTransMethod = method;
            if strcmpi(method, 'autoencoder') || strcmpi(method, 'rfi')  
                preTransMethod = method; %'none'
                scope = 'all';
            elseif contains(lower(method), '-all')
                preTransMethod = strrep(method, '-all', '');
                scope = 'all';
            else
                scope = 'perSample';
            end
                 
            if strcmpi(method, 'msuperpca') || strcmpi(method, 'mclusterpca')
                scope = 'stacked';
            end

            if strcmpi(scope, 'perSample')
                tic;
                transTrain = cellfun(@(x, y) x.Transform(true, preTransMethod, q, y, varargin{:}), {trainData.Values}, {trainData.ImageLabels}, 'un', 0);
                drTrainTime = toc;
                drTrainTime = drTrainTime / numel(transTrain);
                XValid = cellfun(@(x, y) x.Transform(true, preTransMethod, q, y, varargin{:}), {testData.Values}, {testData.ImageLabels}, 'un', 0);
                
                %Convert cell image data to concatenated array data
                XTrainscores = trainUtility.Cell2Mat(transTrain);
                XValidscores = trainUtility.Cell2Mat(XValid);
            end
            
            if strcmpi(scope, 'all')
                tic; 
                dataCell  = cellfun(@(x) x.GetMaskedPixels(), {trainData.Values}, 'un', 0);
                dataArray = cell2mat(dataCell');
                dataCell  = cellfun(@(x, y) GetMaskedPixelsInternal(y, x), {trainData.Masks}, {trainData.ImageLabels}, 'un', 0);
                dataLabels = cell2mat(dataCell');
                [coeff, XTrainscores, ~, ~, ~] = dimredUtility.Apply(dataArray, preTransMethod, q, [], dataLabels, varargin{:});
                drTrainTime = toc;
                drTrainTime = drTrainTime / numel(trainData);
            
                dataCell  = cellfun(@(x) x.GetMaskedPixels(), {testData.Values}, 'un', 0);
                dataArray = cell2mat(dataCell');
                if ~isempty(coeff) && ~isobject(coeff) 

                    XValidscores = dataArray * coeff;
                    XValid = cellfun(@(x) x.Transform(true, 'pretrained', q, [], coeff), {testData.Values}, 'un', 0);
                    
                elseif isobject(coeff)
                    dimredStruct = coeff;
                    XValidscores = dimredUtility.Transform(dataArray, preTransMethod, q, dimredStruct);
                    XValid = cellfun(@(x) x.Transform(true, preTransMethod, q, [], dimredStruct), {testData.Values}, 'un', 0);

                else 
                    error('Incomplete arguments. Dimension reduction failed.')
                end

            end 
            
            transyTrain = cellfun(@(x, y) GetMaskedPixelsInternal(x, y), {trainData.ImageLabels}, {trainData.Masks}, 'un', 0);
            yTrain = trainUtility.Cell2Mat(transyTrain);
            transyValid = cellfun(@(x, y) GetMaskedPixelsInternal(x, y), {testData.ImageLabels}, {testData.Masks}, 'un', 0);
            yValid = trainUtility.Cell2Mat(transyValid);
            
            switch lower(scope)
                case 'stacked'
                    [predLabels, modelTrainTime, trainedModel, ~, ~] = trainUtility.StackMultiscale(@trainUtility.SVM, 'voting', XTrainscores, yTrain, XValidscores);

                otherwise
                    [predLabels, modelTrainTime, trainedModel] = trainUtility.RunSVM(XTrainscores, yTrain, XValidscores, svmSettings);
            end

            [performanceStruct, trainedModel] = trainUtility.ModelEvaluation(method, q, yValid, predLabels, yTrain, trainedModel, ...
                drTrainTime, modelTrainTime, testData, XValid);
        end

        % ======================================================================
        %> @brief GetMeanAUC returns average AUC values.
        %>
        %> @b Usage
        %>
        %> @code
        %> [meanAucX, meanAucY] = trainUtility.GetMeanAUC(aucX, aucY);
        %> @endcode
        %>
        %> @param inScores [numeric array] | The target array
        %> @param method [char] | The dimension reduction method
        %> @param q [int] | The reduced dimension
        %> @param trainedObj [numeric array] | The trained dimension reduction object
        %>
        %> @retval transScores [numeric array] | The transformed scores
        % ======================================================================
        function [meanAucX, meanAucY] = GetMeanAUC(aucX, aucY)
            % GetMeanAUC returns average AUC values.
            %
            % @b Usage
            %
            % @code
            % [meanAucX, meanAucY] = trainUtility.GetMeanAUC(aucX, aucY);
            % @endcode
            %
            % @param inScores [numeric array] | The target array
            % @param method [char] | The dimension reduction method
            % @param q [int] | The reduced dimension
            % @param trainedObj [numeric array] | The trained dimension reduction object
            %
            % @retval transScores [numeric array] | The transformed scores
            n = numel(aucX);
            meanAucX = linspace(0, 1, 100);
            for i = 1:n
                aucXVals = aucX{i};
                aucYVals = aucY{i};
                [aucXVals, idxs, ~] = unique(aucXVals);
                if i == 1
                    meanAucY = (interp1(aucXVals, aucYVals(idxs), meanAucX)) / n;
                else
                    meanAucY = meanAucY + (interp1(aucXVals, aucYVals(idxs), meanAucX)) / n;
                end
            end
        end

        % ======================================================================
        %> @brief ModelEvaluation returns the model evaluation results.
        %>
        %> @b Usage
        %>
        %> @code
        %> [perfStr, trainedModel] = trainUtility.ModelEvaluation(modelName, featNum, gtLabels, predLabels, trainLabels, trainedModel, stackedModels, drTrainTime, modelTrainTime);
        %> @endcode
        %>
        %> @param modelName [char] | The model name
        %> @param featNum [int] | The number of features
        %> @param gtLabels [numeric array] | The ground truth labels
        %> @param predLabels [numeric array] | The predicted labels
        %> @param trainLabels [numeric array] | The training set labels
        %> @param stackedModels [model or cell array] | The models
        %> @param drTrainTime [double] | The training time for dimension reduction
        %> @param modelTrainTime [double] | The time for model training
        %>
        %> @retval perfStr [struct] | The performance structure
        %> @retval trainedModel [model] | The trained model
        % ======================================================================
        function [perfStr, stackedModels] = ModelEvaluation(modelName, featNum, gtLabels, predLabels, trainLabels, ...
                stackedModels, drTrainTime, modelTrainTime, testData, testScores)
            % ModelEvaluation returns the model evaluation results.
            %
            % @b Usage
            %
            % @code
            % [perfStr, trainedModel] = trainUtility.ModelEvaluation(modelName, featNum, gtLabels, predLabels, trainLabels, trainedModel, stackedModels, drTrainTime, modelTrainTime);
            % @endcode
            %
            % @param modelName [char] | The model name
            % @param featNum [int] | The number of features
            % @param gtLabels [numeric array] | The ground truth labels
            % @param predLabels [numeric array] | The predicted labels
            % @param trainLabels [numeric array] | The training set labels
            % @param stackedModels [model or cell array] | The models
            % @param drTrainTime [double] | The training time for dimension reduction
            % @param modelTrainTime [double] | The time for model training
            %
            % @retval perfStr [struct] | The performance structure
            % @retval trainedModel [model] | The trained model

            perfStr = struct('Name', [], 'Features', [], 'Accuracy', [], 'Sensitivity', [], 'Specificity', [], 'JaccardCoeff', [], 'AUC', [], ...
                'AUCX', [], 'AUCY', [], 'DRTrainTime', [], 'ModelTrainTime', [], 'Mahalanobis', [], 'JacDensity', []);

            if ~iscell(stackedModels)
                firstModel = stackedModels;
                clear stackedModels
                stackedModels{1} = firstModel;
            end

            %% Results evaluation
            [perfStr.Accuracy, perfStr.Sensitivity, perfStr.Specificity] = commonUtility.Evaluations(gtLabels, predLabels);

            fgMasks = {testData.Masks};
            sRGBs = {testData.RGBs};
            predLabelsCell = cellfun(@(x) trainUtility.Predict(stackedModels, x, 'voting'), testScores, 'un', 0);
            origSizes = cellfun(@(x) size(x), fgMasks, 'un', 0);

            jacsim = 0;
            jacDensity = 0;
            mahalDist = 0;
            for i = 1:numel(sRGBs)

                %% without post-processing
                predMask = logical(hsi.RecoverSpatialDimensions(predLabelsCell{i}, origSizes{i}, fgMasks{i}));
                trueMask = testData(i).ImageLabels;
                
                jacsim = jacsim + commonUtility.Jaccard(predMask, trueMask);
                jacDensity = jacDensity + 0; % MeasureDensity(predMask, trueMask);
                [h, w] = size(trueMask);
                mahalDist = mahalDist + mahal([1]', reshape(predMask, [h * w, 1]));
            end

            perfStr.JaccardCoeff = jacsim / numel(sRGBs);
            perfStr.JacDensity = jacDensity / numel(sRGBs);
            perfStr.Mahalanobis = mahalDist / numel(sRGBs);
            perfStr.DRTrainTime = drTrainTime;
            perfStr.ModelTrainTime = modelTrainTime;
            perfStr.Name = modelName;
            perfStr.Features = featNum;

            % TO REMOVE
            factors = 10;
            kk = ceil(decimate(1:size(trainLabels, 1), factors));
            ytrainDecim = trainLabels(kk, :);
            % TO REMOVE

            isTesting = true; % ~commonUtility.IsChild({'RunKfoldValidation'});
            if ~isTesting
                modN = numel(stackedModels);
                aucX = cell(modN,1);
                aucY = cell(modN,1);
                aucVal = zeros(modN,1);
                for i = 1:modN
                    singleModel = fitPosterior(stackedModels{i});
                    [~,score_svm] = resubPredict(singleModel);
                    [aucX{i}, aucY{i}, ~, aucVal(i)] = perfcurve(ytrainDecim, score_svm(:, stackedModels{i}.ClassNames), 1);
                end
                [meanAucX, meanAucY] = trainUtility.GetMeanAUC(aucX, aucY);
                perfStr.AUCX = meanAucX;
                perfStr.AUCY = meanAucY;
                perfStr.AUC = mean(aucVal);
            else
                perfStr.AUCX = [];
                perfStr.AUCY = [];
                perfStr.AUC = 0;
            end
            
        end
        % ======================================================================
        %> @brief RunKfoldValidation trains and tests an classifier with cross validation.
        %>
        %> @b Usage
        %>
        %> @code
        %> [peformanceStruct] = trainUtility.RunKfoldValidation(X, y, cvp, method, q);
        %> @endcode
        %>
        %> @param trainData [struct] | The train data
        %> @param cvp [cell array] | The cross validation index splits
        %> @param method [char] | The dimension reduction method
        %> @param q [int] | The reduced dimension
        %> @param varargin | Additional optional arguments
        %>
        %> @retval peformanceStruct [struct] | The model's performance
        % ======================================================================
        function [peformanceStruct] = RunKfoldValidation(trainData, cvp, method, q, varargin)
            % RunKfoldValidation trains and tests an classifier with cross validation.
            %
            % @b Usage
            %
            % @code
            % [peformanceStruct] = trainUtility.RunKfoldValidation(X, y, cvp, method, q);
            % @endcode
            %
            % @param trainData [struct] | The train data
            % @param cvp [cell array] | The cross validation index splits
            % @param method [char] | The dimension reduction method
            % @param q [int] | The reduced dimension
            % @param varargin | Additional optional arguments
            %
            % @retval peformanceStruct [struct] | The model's performance

            numValidSets = cvp.NumTestSets;
            perfStr = cell(numValidSets,1);
            for k = 1:numValidSets
                trainDataFold = trainData(cvp.training(k));
                testDataFold = trainData(cvp.test(k));

                [perfStr(k), ~, ~] = trainUtility.DimredAndTrain(trainDataFold, testDataFold, method, q, varargin{:});
            end

            peformanceStruct = struct('Name', perfStr(1).Name, 'Features', perfStr(1).Features, ...
                'Accuracy', mean([perfStr.Accuracy]), 'Sensitivity', mean([perfStr.Sensitivity]), 'Specificity', mean([perfStr.Specificity]), ...
                'JaccardCoeff', mean([perfStr.JaccardCoeff]), 'AUC', 0, 'AUCX', [], 'AUCY', [], ...
                'DRTrainTime', mean([perfStr.DRTrainTime]), 'ModelTrainTime', mean([perfStr.ModelTrainTime]), ...
                'AccuracySD', std([perfStr.Accuracy]), 'SensitivitySD', std([perfStr.Sensitivity]), 'SpecificitySD', std([perfStr.Specificity]), ...
                'JaccardCoeffSD', std([perfStr.JaccardCoeff]), 'AUCSD', 0, ...
                'Mahalanobis', mean([perfStr.Mahalanobis]), 'MahalanobisSD', std([perfStr.Mahalanobis]), ...
                'JacDensity', mean([perfStr.JacDensity]), 'JacDensitySD', std([perfStr.JacDensity]));
            
            fprintf('%d-fold validated - Jaccard: %.3f %%, Accuracy: %.3f %%, Sensitivity: %.3f %%, Specificity: %.3f %%, DR Train time: %.5f, SVM Train time: %.5f \n\n', ...
                numValidSets, peformanceStruct.JaccardCoeff*100, peformanceStruct.Accuracy*100, peformanceStruct.Sensitivity*100, ... .
                peformanceStruct.Specificity*100, peformanceStruct.DRTrainTime, peformanceStruct.ModelTrainTime);
        end

        % ======================================================================
        %> @brief ValidateTest returns the results after cross validation of a classifier.
        %>
        %> @b Usage
        %>
        %> @code
        %> [valTrain, valTest] = trainUtility.ValidateTest(Xtrain, ytrain, Xtest, ytest, cvp, method, q);
        %> @endcode
        %>
        %> @param Xtrain [numeric array] | The train data
        %> @param ytrain [numeric array] | The train labels
        %> @param Xvalid [numeric array] | The test data
        %> @param yvalid [numeric array] | The test labels
        %> @param cvp [cell array] | The cross validation index splits
        %> @param method [char] | The dimension reduction method
        %> @param q [int] | The reduced dimension
        %>
        %> @retval valTrain [numeric array] | The train performance results
        %> @retval valTest [numeric array] | The validation performance results
        % ======================================================================
        function [valTrain, valTest] = ValidateTest(Xtrain, ytrain, Xvalid, yvalid, cvp, method, q)
            % ValidateTest returns the results after cross validation of a classifier.
            %
            % @b Usage
            %
            % @code
            % [valTrain, valTest] = trainUtility.ValidateTest(Xtrain, ytrain, Xtest, ytest, cvp, method, q);
            % @endcode
            %
            % @param Xtrain [numeric array] | The train data
            % @param ytrain [numeric array] | The train labels
            % @param Xvalid [numeric array] | The test data
            % @param yvalid [numeric array] | The test labels
            % @param cvp [cell array] | The cross validation index splits
            % @param method [char] | The dimension reduction method
            % @param q [int] | The reduced dimension
            %
            %> @retval valTrain [numeric array] | The train performance results
            %> @retval valTest [numeric array] | The validation performance results

            [accuracy, sensitivity, specificity, tdimred, tclassifier] = trainUtility.RunKfoldValidation(Xtrain, ytrain, cvp, method, q);
            valTrain = [accuracy, sensitivity, specificity, tdimred, tclassifier];
            fprintf('Train - Accuracy: %.5f, Sensitivity: %.5f, Specificity: %.5f, DR Train time: %.5f, SVM Train time: %.5f \n\n', ...
                accuracy, sensitivity, specificity, tdimred, tclassifier);
            [accuracy, sensitivity, specificity, tdimred, tclassifier, ~, ~, ~] = trainUtility.DimredAndTrain(Xtrain, ytrain, Xvalid, yvalid, method, q);
            fprintf('Test - Accuracy: %.5f, Sensitivity: %.5f, Specificity: %.5f, DR Train time: %.5f, SVM Train time: %.5f \n\n', ...
                accuracy, sensitivity, specificity, tdimred, tclassifier);
            valTest = [accuracy, sensitivity, specificity, tdimred, tclassifier];
        end

        % ======================================================================
        %> @brief ValidateTest2 returns the results after cross validation of a classifier.
        %>
        %> Need to set config::[SaveFolder] for image output.
        %>
        %> @b Usage
        %>
        %> @code
        %> [trainPerformance, testPerformance] = trainUtility.ValidateTest2(trainData, testData, cvp, method, q);
        %>
        %> numScales = numel(pixelNumArray);
        %> [trainPerformance, testPerformance] = trainUtility.ValidateTest2(trainData, testData, cvp, method, q, numScales);
        %> @endcode
        %>
        %> @param trainData [struct] | The train data
        %> @param testData [struct] | The test data
        %> @param cvp [cell array] | The cross validation index splits
        %> @param method [char] | The dimension reduction method
        %> @param q [int] | The reduced dimension
        %> @param varargin | Additional optional arguments
        %>
        %> @retval trainPerformance [numeric array] | The train performance results
        %> @retval testPerformance [numeric array] | The test performance results
        % ======================================================================
        function [trainPerformance, testPerformance] = ValidateTest2(trainData, testData, cvp, method, q, varargin)
            % ValidateTest2 returns the results after cross validation of a classifier.
            %
            % Need to set config::[SaveFolder] for image output.
            %
            % @b Usage
            %
            % @code
            % [trainPerformance, testPerformance] = trainUtility.ValidateTest2(trainData, testData, cvp, method, q);
            %
            % numScales = numel(pixelNumArray);
            % [trainPerformance, testPerformance] = trainUtility.ValidateTest2(trainData, testData, cvp, method, q, numScales);
            % @endcode
            %
            % @param trainData [struct] | The train data
            % @param testData [struct] | The test data
            % @param cvp [cell array] | The cross validation index splits
            % @param method [char] | The dimension reduction method
            % @param q [int] | The reduced dimension
            % @param varargin | Additional optional arguments
            %
            % @retval trainPerformance [numeric array] | The train performance results
            % @retval testPerformance [numeric array] | The test performance results

            [trainPerformance] = trainUtility.RunKfoldValidation(trainData, cvp, method, q, varargin{:});

            [testPerformance, trainedModel, testscores] = trainUtility.DimredAndTrain(trainData, testData, method, q, varargin{:});
            fprintf('Test - Jaccard: %.3f %%, AUC: %.3f, Accuracy: %.3f %%, Sensitivity: %.3f %%, Specificity: %.3f %%, DR Train time: %.5f, SVM Train time: %.5f \n\n', ...
                testPerformance.JaccardCoeff*100, testPerformance.AUC, testPerformance.Accuracy*100, testPerformance.Sensitivity*100, ... .
                testPerformance.Specificity*100, testPerformance.DRTrainTime, testPerformance.ModelTrainTime);
            ytest = cellfun(@(x, y) GetMaskedPixelsInternal(x.Labels, y.FgMask), {testData.Labels}, {testData.Values}, 'un', 0);

            fgMasks = {testData.Masks};
            sRGBs = {testData.RGBs};
            predlabels = cellfun(@(x) trainUtility.Predict(trainedModel, x, 'voting'), testscores, 'un', 0);
            origSizes = cellfun(@(x) size(x), fgMasks, 'un', 0);

            for i = 1:numel(sRGBs)

                %% without post-processing
                predMask = hsi.RecoverSpatialDimensions(predlabels{i}, origSizes{i}, fgMasks{i});
                trueMask = hsi.RecoverSpatialDimensions(ytest{i}, origSizes{i}, fgMasks{i});
                jacsim = commonUtility.Jaccard(predMask, trueMask);

                imgFilePath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'), num2str(i), ...
                    strcat('pred_', method, '_', num2str(q))), 'png');
                figTitle = sprintf('%s', strcat(method, '-', num2str(q), ' (', sprintf('%.2f', jacsim*100), '%)'));
                plots.Overlay(4, imgFilePath, sRGBs{i}, predMask, figTitle);

                %% with post processing
                seClose = strel('disk', 3);
                closeMask = imclose(predMask, seClose);
                seErode = strel('disk', 3);
                postPredMask = imerode(closeMask, seErode);
                jacsim = commonUtility.Jaccard(postPredMask, trueMask);

                imgFilePath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'), strcat(num2str(i), '_post'), ...
                    strcat('pred_', method, '_', num2str(q))), 'png');
                figTitle = sprintf('%s', strcat(method, '-', num2str(q), ' (', sprintf('%.2f', jacsim*100), '%)'));
                plots.Overlay(4, imgFilePath, sRGBs{i}, postPredMask, figTitle);
            end

        end
        
    end
end