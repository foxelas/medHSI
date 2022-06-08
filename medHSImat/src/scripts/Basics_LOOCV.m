% folds = 19;
% 
% saveTarget = 'Framework-LOOCV';
% 
% targetDataset = strcat('pslRaw-Denoisesmoothen32', 'LOOCValidation');
% config.SetSetting('Dataset', targetDataset);
% loadData = true;
% 
% if ~loadData
%     trainData = cell(folds, 1);
%     for i = 1:folds
%       config.SetSetting('Dataset', fullfile(targetDataset, num2str(i)));
%       [~, targetIDs] = commonUtility.DatasetInfo();
% 
%        trainDataFold = struct('Values', [], 'Labels', [], 'RGBs', [], 'Masks', [], 'ImageLabels', []);
% 
%       for j = 1:numel(targetIDs)
%          [spectrumData, labelInfo] = hsiUtility.LoadHsiAndLabel(targetIDs{j});
%          trainDataFold(j).Values = spectrumData;
%          trainDataFold(j).Labels = labelInfo;
%          trainDataFold(j).RGBs = spectrumData.GetDisplayImage();
%          trainDataFold(j).Masks = spectrumData.FgMask;
%          trainDataFold(j).ImageLabels = logical(labelInfo.Labels);
%          trainDataFold(j).TargetName = targetIDs{j};
%       end
% 
%       trainData{i} = trainDataFold;
%     end
% 
%     config.SetSetting('Dataset', targetDataset);
%     fileName = commonUtility.GetFilename('output', fullfile(saveTarget,'foldData'));
%     save(fileName, 'trainData', '-v7.3');
% else
%     config.SetSetting('Dataset', targetDataset);
%     fileName = commonUtility.GetFilename('output', fullfile(saveTarget,'foldData'));
%     load(fileName, 'trainData');
% end
rng default; % For reproducibility

foldInds = 1:folds;
methods = {'kmeans', 'abundance', 'signature'};

for k = 1:3
    method = methods{k}; 
    for i = 1:folds
       testDataSet = trainData{foldInds == i};
       trainDataSet =  []; %struct('Values', [], 'Labels', [], 'RGBs', [], 'Masks', [], 'ImageLabels', []);
       for kk = 1:folds
           if kk ~= i 
                trainDataSet = [trainDataSet, trainData{foldInds == kk} ];
           end
       end
       

       fprintf('Fold %d\n', i);
       
       switch method
           case 'abundance'
                name = 'Abundance-8';
                %observed 
                boxConstraint = 44.184;
                kernelScale = 4.0136;
%                 %estimated 
%                 boxConstraint = 38.64;
%                 kernelScale = 4.1023;
                       
                config.SetSetting('SaveFolder', fullfile(saveTarget, name, num2str(i)));
                [testPerformance{i}, performanceRow(i,:)] = TrainClassifier(name, trainDataSet, testDataSet, 'abundance2', 8, [], [boxConstraint, kernelScale]); 

           case 'signature'
               name = 'Signature';
               config.SetSetting('SaveFolder', fullfile(saveTarget, name, num2str(i)));
               boxConstraint = 11.767;
               kernelScale = 2.6353; 
               % boxConstraint = 9.862;
               % kernelScale = 2.799; 
                [testPerformance{i}, performanceRow(i,:)] = TrainClassifier(name, trainDataSet, testDataSet, 'none', 311, [], [boxConstraint, kernelScale]);
           case 'kmeans'
               name = 'KMeans+SAM';
               config.SetSetting('SaveFolder', fullfile(saveTarget, name, num2str(i)));
               [testPerformance{i}, performanceRow(i,:)] = TrainSegmentation(name, testDataSet);
       end
    end
    
    v = cell2mat(testPerformance);
    fprintf('%s & %.2f (%.2f) & %.2f (%.2f) & %.2f (%.2f) & %.2f (%.2f) & %.3f\n', ...
        method, mean([v.Accuracy] *100), std([v.Accuracy] * 100), mean([v.Sensitivity] *100), std([v.Sensitivity] *100),mean([v.Specificity] *100), std([v.Specificity] *100),mean([v.JaccardCoeff] *100, 'omitnan'), std([v.JaccardCoeff] *100, 'omitnan'),mean([v.AUC]))

    config.SetSetting('SaveFolder', fullfile(saveTarget, name, 'CV'));
    saveResultPath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'),'0_performance'), 'mat');
    save(saveResultPath, 'performanceRow', 'testPerformance');

end 

function [testPerformance, performanceRow] = TrainClassifier(name_, trainData_, testData_, method_, q_, coeff_, svmSettings) 
    
    if nargin < 6 
        coeff_ = [];
    end
    
    if nargin < 7
        svmSettings = [];
    end
    
    if isempty(coeff_)
        [testPerformance, trainedModel, testscores] = trainUtility.DimredAndTrain(trainData_, testData_, method_, q_, svmSettings); %, coeff);
    else
        [testPerformance, trainedModel, testscores] = trainUtility.DimredAndTrain(trainData_, testData_, method_, q_, svmSettings, coeff_);
    end 
    
    testPerformance.Name = name_;
    fprintf('Test: %s - Jaccard: %.3f %%, AUC: %.3f, Accuracy: %.3f %%, Sensitivity: %.3f %%, Specificity: %.3f %%, DR Train time: %.5f, SVM Train time: %.5f \n\n', ...
        name_, testPerformance.JaccardCoeff*100, testPerformance.AUC, testPerformance.Accuracy*100, testPerformance.Sensitivity*100, ... .
        testPerformance.Specificity*100, testPerformance.DRTrainTime, testPerformance.ModelTrainTime);
    
%     ytest = cellfun(@(x, y) GetMaskedPixelsInternal(x.Labels, y.FgMask), {testData_.Labels}, {testData_.Values}, 'un', 0);
%     
    performanceRow = [testPerformance.Accuracy*100, ...
            testPerformance.Sensitivity*100 , ...
            testPerformance.Specificity*100, ...
            testPerformance.JaccardCoeff*100, ...
            testPerformance.AUC*100];

    fgMasks = {testData_.Masks};
    sRGBs = {testData_.RGBs};
   
    predlabels = cellfun(@(x) trainUtility.Predict(trainedModel, x, 'voting', true), testscores, 'un', 0);
    origSizes = cellfun(@(x) size(x), fgMasks, 'un', 0);

    for i = 1:numel(sRGBs)
        prediction = hsi.RecoverSpatialDimensions(predlabels{i}{1}, origSizes{i}, fgMasks{i});
        targetSample = testData_(i).TargetName;
        savePredPath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'),   strcat('p_sample', targetSample)), 'mat');
        save(savePredPath, 'prediction');
    end

    saveResultPath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'),'0_performance'), 'mat');
    save(saveResultPath, 'testPerformance', 'performanceRow', 'trainedModel', '-v7.3');
end

function [testPerformance, performanceRow] = TrainSegmentation(name_, testData_) 
    

    predMasks = cellfun(@(x) SegmentLeonInternal(x), {testData_.Values}, 'UniformOutput', false);
    trueMasks = {testData_.ImageLabels};

    predLabels = cell2mat(cellfun(@(x) x(:), predMasks,'UniformOutput', false)');
    gtLabels =cell2mat(cellfun(@(x) x(:), trueMasks,'UniformOutput', false)');


    [testPerformance] = trainUtility.Evaluation(name_, [], predLabels, gtLabels, predMasks, trueMasks, [], gtLabels, double(predLabels));

    testPerformance.Name = name_;
    fprintf('Test: %s - Jaccard: %.3f %%, AUC: %.3f, Accuracy: %.3f %%, Sensitivity: %.3f %%, Specificity: %.3f %%, \n\n', ...
        name_, testPerformance.JaccardCoeff*100, testPerformance.AUC, testPerformance.Accuracy*100, testPerformance.Sensitivity*100, ... .
        testPerformance.Specificity*100);
    
%     ytest = cellfun(@(x, y) GetMaskedPixelsInternal(x.Labels, y.FgMask), {testData_.Labels}, {testData_.Values}, 'un', 0);
%     
    performanceRow = [testPerformance.Accuracy*100, ...
            testPerformance.Sensitivity*100 , ...
            testPerformance.Specificity*100, ...
            testPerformance.JaccardCoeff*100, ...
            testPerformance.AUC*100];

    sRGBs = {testData_.RGBs};

    for i = 1:numel(sRGBs)
        prediction = predMasks{i};
        targetSample = testData_(i).TargetName;
        savePredPath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'),   strcat('p_sample', targetSample)), 'mat');
        save(savePredPath, 'prediction');
    end

    saveResultPath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'),'0_performance'), 'mat');
    save(saveResultPath, 'testPerformance', 'performanceRow', '-v7.3');
end