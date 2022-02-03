classdef trainUtility
    %     [valTrain, valTest] = RunKfoldValidation(X, y, cvp, method, q)   
    %     [valTrain, valTest] = ValidateTest2(X, y, Xtest, ytest, srgb, fgMask, cvp, method, q)
    %     [accuracy, sensitivity, specificity, st] = RunSVM(scores, labels, testscores, testlabels)
    %     [acc, sens, spec, tdimred, st, model] = DimredAndTrain(Xtrain, ytrain, Xvalid, yvalid, method, q)
    %     [cvp] = KfoldPartitions(labels, folds)
    
    methods (Static)
         
        function [valTrain, valTest] = ValidateTest(X, y, Xtest, ytest, cvp, method, q)   
            [accuracy, sensitivity, specificity, tdimred, tclassifier] = trainUtility.RunKfoldValidation(X, y, cvp, method, q);
            valTrain = [accuracy, sensitivity, specificity, tdimred, tclassifier];
            [accuracy, sensitivity, specificity, tdimred, tclassifier, ~, ~, ~] = trainUtility.DimredAndTrain(X, y, Xtest, ytest, method, q);
            fprintf('Test - Accuracy: %.5f, Sensitivity: %.5f, Specificity: %.5f, DR Train time: %.5f, SVM Train time: %.5f \n\n', ...
                accuracy, sensitivity, specificity, tdimred, tclassifier);
            valTest = [accuracy, sensitivity, specificity, tdimred, tclassifier];            
        end
        
        function [valTrain, valTest] = ValidateTest2(X, y, Xtest, ytest, srgb, fgMask, cvp, method, q)   
            [accuracy, sensitivity, specificity, tdimred, tclassifier] = trainUtility.RunKfoldValidation(X, y, cvp, method, q);
            valTrain = [accuracy, sensitivity, specificity, tdimred, tclassifier];
            [accuracy, sensitivity, specificity, tdimred, tclassifier, Mdl, ~, testscores] = trainUtility.DimredAndTrain(X, y, Xtest, ytest, method, q);
            fprintf('Test - Accuracy: %.5f, Sensitivity: %.5f, Specificity: %.5f, DR Train time: %.5f, SVM Train time: %.5f \n\n', ...
                accuracy, sensitivity, specificity, tdimred, tclassifier);
            valTest = [accuracy, sensitivity, specificity, tdimred, tclassifier];
            
            predlabels = predict(Mdl, testscores);
            predLabel = RecoverReducedHsiInternal(predlabels, size(fgMask), fgMask);
            imgFilename = fullfile(config.GetSetting('outputDir'), config.GetSetting('experiment'), strcat('pred_', method,'_', num2str(q), '.png'));
            config.SetSetting('plotName', imgFilename);
            plots.Overlay(4, srgb, predLabel, strcat(method, '-', num2str(q)));            
        end
        
        
        function [accuracy, sensitivity, specificity, tdimred, tclassifier] = RunKfoldValidation(X, y, cvp, method, q)   
            numvalidsets = cvp.NumTestSets;
            acc = zeros(1, numvalidsets);
            sens = zeros(1, numvalidsets);
            spec = zeros(1, numvalidsets);
            st = zeros(1, numvalidsets);

            for k = 1:numvalidsets
                Xtrain = X(cvp.training(k),:);
                ytrain = y(cvp.training(k),:);
                Xvalid = X(cvp.test(k),:);
                yvalid = y(cvp.test(k),:);

                [acc(k), sens(k), spec(k), tdimred, st(k), ~, ~, ~] = trainUtility.DimredAndTrain(Xtrain, ytrain, Xvalid, yvalid, method, q);         
            end

            accuracy = mean(acc);
            sensitivity = mean(sens);
            specificity = mean(spec);
            tclassifier = mean(st);
            fprintf('%d-fold validated - Accuracy: %.5f, Sensitivity: %.5f, Specificity: %.5f, DR Train time: %.5f, SVM Train time: %.5f \n\n', ...
                numvalidsets, accuracy, sensitivity, specificity, tdimred, tclassifier);
        end
        
        function [acc, sens, spec, tdimred, st, Mdl, scores, testscores] = DimredAndTrain(Xtrain, ytrain, Xvalid, yvalid, method, q)
            switch method
                case 'pca'
                    tic;
                    [coeff, scores, latent, explained, objective] = Dimred(Xtrain, 'pca', q);
                    tdimred = toc;
                    testscores = Xvalid *coeff;
                    [acc, sens, spec, st, Mdl] = trainUtility.RunSVM(scores, ytrain, testscores, yvalid);

                case 'rica'
                    tic;
                    warning('off', 'all');
                    [coeff, scores, ~, ~, ~] = Dimred(Xtrain, 'rica', q);
                    warning('on', 'all');
                    tdimred = toc;
                    testscores = Xvalid *coeff;
                    [acc, sens, spec, st, Mdl] = trainUtility.RunSVM(scores, ytrain, testscores, yvalid); 

                case 'simple'
                    wavelengths = hsiUtility.GetWavelengths(311);
                    tic;
                    id1 = find(wavelengths == 540);
                    id2 = find(wavelengths == 650);
                    scores = Xtrain(:, [id1, id2]);
                    tdimred = toc;
                    testscores = Xvalid(:, [id1, id2]);
                    [acc, sens, spec, st, Mdl] =  trainUtility.RunSVM(scores, ytrain, testscores, yvalid);

                case 'lda'
                    tic;
                    [~, scores, ~, ~, ~, LMdl] = Dimred(Xtrain, 'lda', q, ytrain);
                    tdimred = toc;
                    st = tdimred;
                    ypred1 = predict(LMdl, Xvalid);
                    scores = Xtrain;
                    testscores = Xvalid;
                    [acc, sens, spec] = metrics.Evaluations(yvalid,ypred1);
                    Mdl = LMdl;

                case 'qda'
                    [~, scores, ~, ~, ~, LMdl] = Dimred(Xtrain, 'qda', q, ytrain);
                    tdimred = toc;
                    st = tdimred;
                    ypred1 = predict(LMdl, Xvalid);
                    scores = Xtrain;
                    testscores = Xvalid;
                    [acc, sens, spec] = metrics.Evaluations(yvalid,ypred1);
                    Mdl = LMdl;

                case 'rfi'
                    tdimred = 0;
                    scores = Xtrain;
                    testscores = Xvalid;
                    [acc, sens, spec, st, Mdl] =  trainUtility.RunSVM(Xtrain, ytrain, Xvalid, yvalid);

                case 'autoencoder'
                    tic;
                    autoenc = trainAutoencoder(Xtrain',q,'MaxEpochs',400,...
                        'UseGPU', true);
                    tdimred = toc;
                    scores = encode(autoenc,Xtrain')';
                    testscores = encode(autoenc, Xvalid')';
                    [acc, sens, spec, st, Mdl] = trainUtility.RunSVM(scores, ytrain, testscores, yvalid);

                otherwise
                   tdimred = 0;
                   scores = Xtrain;
                   testscores = Xvalid;
                   [acc, sens, spec, st, Mdl] =  trainUtility.RunSVM(Xtrain, ytrain, Xvalid, yvalid);
            end
        end
        
        function [accuracy, sensitivity, specificity, st, SVMModel] = RunSVM(scores, labels, testscores, testlabels)
            % SVMModel = fitcsvm(X,Y,'Standardize',true,'KernelFunction','RBF',...
            %     'KernelScale','auto');

            %     SVMModel = fitcsvm(scores,labels);
            tic;
            SVMModel =  fitcsvm(scores,labels, 'Standardize',true,'KernelFunction','RBF',...
                'KernelScale','auto', 'Cost',[0,1;3,0]);
            st = toc;
            predlabels = predict(SVMModel,testscores);

           [accuracy, sensitivity, specificity] = metrics.Evaluations(testlabels,predlabels);

        end 
        
        function [cvp] = KfoldPartitions(labels, folds)
            if nargin < 2
                folds = 10;
            end
            cvp = cvpartition(length(labels),'kfold',folds);
        end
    end
end