classdef trainUtility
    %   Static:
    %       %% Core
    %       Augment(dataset, augType)
    %       [X, y, Xtest, ytest, cvp, sRGBs, fgMasks] = trainUtility.SplitTrainTest(dataset, testTargets, dataType, hasLabels, folds, transformFun);
    %       [cvp, X, y, Xtest, ytest, sRGBs, fgMasks] = PrepareSpectralDataset(folds, testingSamples, numSamples, content, target, useCustomMask, transformFun)
    %       [cvp] = KfoldPartitions(labels, folds)
    %
    %       %% Train
    %       [acc, sens, spec, tdimred, st, model] = DimredAndTrain(Xtrain, ytrain, Xvalid, yvalid, method, q)
    %       [accuracy, sensitivity, specificity, st] = RunSVM(scores, labels, testscores, testlabels)
    %
    %       %% Validation
    %       [valTrain, valTest] = RunKfoldValidation(X, y, cvp, method, q)
    %       [valTrain, valTest] = ValidateTest(X, y, Xtest, ytest, cvp, method, q)
    %       [valTrain, valTest] = ValidateTest2(X, y, Xtest, ytest, srgb, fgMask, cvp, method, q)

    methods (Static)

        %% Core  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [] = Augment(varargin)
            % Augment reads a group of hsi data, prepares .mat files,
            % prepared normalized files and returns montage previews of contents
            % Each sample contained in the original dataset is assumed unique
            %
            %   Usage:
            %   Augment(dataset)
            %   Augment(dataset, 'set2');
            AugmentInternal(varargin{:});
        end

        function [X, y, Xtest, ytest, cvp, sRGBs, fgMasks] = SplitTrainTest(varargin)

            %% SplitTrainTest rearranges pixels as a pixel (observation) by feature 2D array
            % One pixel is one data sample
            %
            %   Arguments
            %   dataset: string, the folder name of dataset (must be in
            %   matfiles\hsi\)
            %   testTargets: array of str targetNames
            %   dataType: 'image' or 'pixel'
            %   hasLabels: bool
            %   folds: numeric
            %   transformFun: function handle
            %
            %   Usage:
            %   dataset = 'pslBase';
            %   testTargets = {'153'};
            %   dataType = 'pixel';
            %   [X, y, Xtest, ytest, cvp, sRGBs, fgMasks] = trainUtility.SplitTrainTest(dataset, testTargets, dataType);
            %
            %   hasLabels = true;
            %   transformFun = @Dimred;
            %   folds = 5;
            %   [X, y, Xtest, ytest, cvp, sRGBs, fgMasks] = trainUtility.SplitTrainTest(dataset, testTargets, dataType, hasLabels, folds, transformFun);

            [X, y, Xtest, ytest, cvp, sRGBs, fgMasks] = SplitTrainTestInternal(varargin{:});
        end

        function [cvp, X, y, Xtest, ytest, sRGBs, fgMasks] = PrepareSpectralDataset(folds, testingSamples, numSamples, content, target, useCustomMask, transformFun)

            %% PrepareSpectralDataset rearranges pixels as a pixel (observation) by feature 2D array
            % One pixel is one data sample
            %
            %   Usage:
            %   folds = 5;
            %   testingSamples = [5];
            %   numSamples = 6;
            %   content = {'tissue', true};
            %   target = 'fix';
            %   useCustomMask = true;
            %   [cvp, X, y, Xtest, ytest, sRGBs, fgMasks] = trainUtility.PrepareSpectralDataset(folds, testingSamples, numSamples, content, target, useCustomMask);
            %
            %   transformFun = @Dimred;
            %   [cvp, X, y, Xtest, ytest, sRGBs, fgMasks] = trainUtility.PrepareSpectralDataset(folds, testingSamples, numSamples, content, target, useCustomMask,transformFun);

            useTransform = ~(nargin < 7);

            %% Read h5 data
            [targetIDs, ~] = databaseUtility.GetTargetIndexes(content, target);

            X = [];
            y = [];
            Xtest = [];
            ytest = [];
            sRGBs = cell(length(testingSamples), 1);
            fgMasks = cell(length(testingSamples), 1);

            k = 0;
            for i = 1:numSamples %only 6 available labels else length(targetIDs)

                id = targetIDs(i);

                %% load HSI from .mat file
                targetName = num2str(id);
                I = hsiUtility.LoadHSI(targetName, 'dataset');

                imgFilename = fullfile(config.GetSetting('outputDir'), config.GetSetting('experiment'), strcat(targetName, '.png'));
                if useCustomMask
                    fgMask = I.GetCustomMask();
                    config.SetSetting('plotName', imgFilename);
                    plots.Overlay(3, I.GetDisplayRescaledImage(), fgMask);
                    save(strrep(imgFilename, '.png', '.mat'), 'fgMask');
                else
                    load(strrep(imgFilename, '.png', '.mat'), 'fgMask');
                    %fgMask = I.FgMask;
                end

                [m, n, ~] = I.Size();

                if useTransform
                    scores = transformFun(I);
                    Xcol = GetMaskedPixelsInternal(scores, fgMask);
                else
                    Xcol = I.GetMaskedPixels(fgMask);
                end

                labelfile = dataUtility.GetFilename('label', targetName);
                if exist(labelfile, 'file')
                    load(labelfile, 'labelMask');
                    ycol = GetMaskedPixelsInternal(labelMask(1:m, 1:n), fgMask);

                    if isempty(find(testingSamples == i, 1))
                        X = [X; Xcol];
                        y = [y; ycol];

                    else

                        %% Prepare Test Set
                        Xtest = [Xtest; Xcol];
                        ytest = [ytest; ycol];

                        %% Recover Test Image
                        k = k + 1;
                        sRGBs{k} = I.GetDisplayRescaledImage();
                        fgMasks{k} = fgMask;
                    end
                else
                    if isempty(find(testingSamples == i, 1))
                        X = [X; Xcol];
                    else

                        %% Prepare Test Set
                        Xtest = [Xtest; Xcol];

                        %% Recover Test Image
                        k = k + 1;
                        sRGBs{k} = I.GetDisplayRescaledImage();
                        fgMasks{k} = fgMask;
                    end
                end
            end

            if ~isempty(y)
                cvp = trainUtility.KfoldPartitions(y, folds);
            else
                cvp = [];
            end
        end

        function [cvp] = KfoldPartitions(labels, folds)
            if nargin < 2
                folds = 10;
            end
            cvp = cvpartition(length(labels), 'kfold', folds);
        end

        %% Train  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [accuracy, sensitivity, specificity, st, SVMModel] = RunSVM(scores, labels, testscores, testlabels)
            % SVMModel = fitcsvm(X,Y,'Standardize',true,'KernelFunction','RBF',...
            %     'KernelScale','auto');

            %     SVMModel = fitcsvm(scores,labels);
            tic;
            SVMModel = fitcsvm(scores, labels, 'Standardize', true, 'KernelFunction', 'RBF', ...
                'KernelScale', 'auto', 'Cost', [0, 1; 3, 0]);
            st = toc;
            predlabels = predict(SVMModel, testscores);

            [accuracy, sensitivity, specificity] = metrics.Evaluations(testlabels, predlabels);
        end

        function [acc, sens, spec, tdimred, st, Mdl, scores, testscores] = DimredAndTrain(Xtrain, ytrain, Xvalid, yvalid, method, q)
            switch method
                case 'pca'
                    tic;
                    [coeff, scores, latent, explained, objective] = Dimred(Xtrain, 'pca', q);
                    tdimred = toc;
                    testscores = Xvalid * coeff;
                    [acc, sens, spec, st, Mdl] = trainUtility.RunSVM(scores, ytrain, testscores, yvalid);

                case 'rica'
                    tic;
                    warning('off', 'all');
                    [coeff, scores, ~, ~, ~] = Dimred(Xtrain, 'rica', q);
                    warning('on', 'all');
                    tdimred = toc;
                    testscores = Xvalid * coeff;
                    [acc, sens, spec, st, Mdl] = trainUtility.RunSVM(scores, ytrain, testscores, yvalid);

                case 'simple'
                    wavelengths = hsiUtility.GetWavelengths(311);
                    tic;
                    id1 = find(wavelengths == 540);
                    id2 = find(wavelengths == 650);
                    scores = Xtrain(:, [id1, id2]);
                    tdimred = toc;
                    testscores = Xvalid(:, [id1, id2]);
                    [acc, sens, spec, st, Mdl] = trainUtility.RunSVM(scores, ytrain, testscores, yvalid);

                case 'lda'
                    tic;
                    [~, scores, ~, ~, ~, LMdl] = Dimred(Xtrain, 'lda', q, ytrain);
                    tdimred = toc;
                    st = tdimred;
                    ypred1 = predict(LMdl, Xvalid);
                    scores = Xtrain;
                    testscores = Xvalid;
                    [acc, sens, spec] = metrics.Evaluations(yvalid, ypred1);
                    Mdl = LMdl;

                case 'qda'
                    [~, scores, ~, ~, ~, LMdl] = Dimred(Xtrain, 'qda', q, ytrain);
                    tdimred = toc;
                    st = tdimred;
                    ypred1 = predict(LMdl, Xvalid);
                    scores = Xtrain;
                    testscores = Xvalid;
                    [acc, sens, spec] = metrics.Evaluations(yvalid, ypred1);
                    Mdl = LMdl;

                case 'rfi'
                    tdimred = 0;
                    scores = Xtrain;
                    testscores = Xvalid;
                    [acc, sens, spec, st, Mdl] = trainUtility.RunSVM(Xtrain, ytrain, Xvalid, yvalid);

                case 'autoencoder'
                    tic;
                    autoenc = trainAutoencoder(Xtrain', q, 'MaxEpochs', 400, ...
                        'UseGPU', true);
                    tdimred = toc;
                    scores = encode(autoenc, Xtrain')';
                    testscores = encode(autoenc, Xvalid')';
                    [acc, sens, spec, st, Mdl] = trainUtility.RunSVM(scores, ytrain, testscores, yvalid);

                otherwise
                    tdimred = 0;
                    scores = Xtrain;
                    testscores = Xvalid;
                    [acc, sens, spec, st, Mdl] = trainUtility.RunSVM(Xtrain, ytrain, Xvalid, yvalid);
            end
        end

        %% Validation  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function [accuracy, sensitivity, specificity, tdimred, tclassifier] = RunKfoldValidation(X, y, cvp, method, q)
            numvalidsets = cvp.NumTestSets;
            acc = zeros(1, numvalidsets);
            sens = zeros(1, numvalidsets);
            spec = zeros(1, numvalidsets);
            st = zeros(1, numvalidsets);

            for k = 1:numvalidsets
                Xtrain = X(cvp.training(k), :);
                ytrain = y(cvp.training(k), :);
                Xvalid = X(cvp.test(k), :);
                yvalid = y(cvp.test(k), :);

                [acc(k), sens(k), spec(k), tdimred, st(k), ~, ~, ~] = trainUtility.DimredAndTrain(Xtrain, ytrain, Xvalid, yvalid, method, q);
            end

            accuracy = mean(acc);
            sensitivity = mean(sens);
            specificity = mean(spec);
            tclassifier = mean(st);
            fprintf('%d-fold validated - Accuracy: %.5f, Sensitivity: %.5f, Specificity: %.5f, DR Train time: %.5f, SVM Train time: %.5f \n\n', ...
                numvalidsets, accuracy, sensitivity, specificity, tdimred, tclassifier);
        end

        function [valTrain, valTest] = ValidateTest(X, y, Xtest, ytest, cvp, method, q)
            [accuracy, sensitivity, specificity, tdimred, tclassifier] = trainUtility.RunKfoldValidation(X, y, cvp, method, q);
            valTrain = [accuracy, sensitivity, specificity, tdimred, tclassifier];
            [accuracy, sensitivity, specificity, tdimred, tclassifier, ~, ~, ~] = trainUtility.DimredAndTrain(X, y, Xtest, ytest, method, q);
            fprintf('Test - Accuracy: %.5f, Sensitivity: %.5f, Specificity: %.5f, DR Train time: %.5f, SVM Train time: %.5f \n\n', ...
                accuracy, sensitivity, specificity, tdimred, tclassifier);
            valTest = [accuracy, sensitivity, specificity, tdimred, tclassifier];
        end

        function [valTrain, valTest] = ValidateTest2(X, y, Xtest, ytest, sRGBs, fgMasks, cvp, method, q)
            [accuracy, sensitivity, specificity, tdimred, tclassifier] = trainUtility.RunKfoldValidation(X, y, cvp, method, q);
            valTrain = [accuracy, sensitivity, specificity, tdimred, tclassifier];
            [accuracy, sensitivity, specificity, tdimred, tclassifier, Mdl, ~, testscores] = trainUtility.DimredAndTrain(X, y, Xtest, ytest, method, q);
            fprintf('Test - Accuracy: %.5f, Sensitivity: %.5f, Specificity: %.5f, DR Train time: %.5f, SVM Train time: %.5f \n\n', ...
                accuracy, sensitivity, specificity, tdimred, tclassifier);
            valTest = [accuracy, sensitivity, specificity, tdimred, tclassifier];

            predlabels = predict(Mdl, testscores);
            origSizes = cellfun(@(x) size(x), fgMasks, 'un', 0);
            predLabels = hsi.RecoverSpatialDimensions(predlabels, origSizes, fgMasks);
            for i = 1:numel(sRGBs)
                imgFilename = fullfile(config.GetSetting('outputDir'), config.GetSetting('experiment'), ...
                    strcat('pred_', num2str(i), '_', method, '_', num2str(q), '.png'));
                config.SetSetting('plotName', imgFilename);
                plots.Overlay(4, sRGBs{i}, predLabels{i}, strcat(method, '-', num2str(q)));
            end
        end

    end
end