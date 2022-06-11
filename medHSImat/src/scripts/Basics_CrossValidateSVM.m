folds = 13;

config.SetSetting('Dataset', 'pslRaw32AugmentedPatientValidation\');
loadData = true;

if ~loadData
    trainData = cell(folds, 1);
    for i = 1:folds
        config.SetSetting('Dataset', strcat('pslRaw32AugmentedPatientValidation\', num2str(i)));
        [~, targetIDs] = commonUtility.DatasetInfo();

        trainDataFold = struct('Values', [], 'Labels', [], 'RGBs', [], 'Masks', [], 'ImageLabels', []);

        for j = 1:numel(targetIDs)
            [spectrumData, labelInfo] = hsiUtility.LoadHsiAndLabel(targetIDs{j});
            trainDataFold(j).Values = spectrumData;
            trainDataFold(j).Labels = labelInfo;
            trainDataFold(j).RGBs = spectrumData.GetDisplayImage();
            trainDataFold(j).Masks = spectrumData.FgMask;
            trainDataFold(j).ImageLabels = logical(labelInfo.Labels);
        end

        trainData{i} = trainDataFold;
    end

    config.SetSetting('Dataset', 'pslRaw');
    config.SetSetting('SaveFolder', 'pslRaw');
    fileName = commonUtility.GetFilename('output', fullfile('Framework-CrossValidation', 'foldData'));
    save(fileName, 'trainData', '-v7.3');
else
    config.SetSetting('Dataset', 'pslRaw');
    config.SetSetting('SaveFolder', 'pslRaw');
    fileName = commonUtility.GetFilename('output', fullfile('Framework-CrossValidation', 'foldData'));
    load(fileName, 'trainData');
end

foldInds = 1:folds;
methods = {'abundance', 'signature'};

for k = 1:2
    method = methods{k};
    for i = 1:folds
        testDataSet = trainData{foldInds == i};
        trainDataSet = []; %struct('Values', [], 'Labels', [], 'RGBs', [], 'Masks', [], 'ImageLabels', []);
        for kk = 1:folds
            if kk ~= i
                trainDataSet = [trainDataSet, trainData{foldInds == kk}];
            end
        end

        fprintf('Fold %d\n', i);

        switch method
            case 'abundance'
                name = 'Abundance-8';
                [testPerformance{i}, performanceRow(i, :)] = TrainClassifier(name, trainDataSet, testDataSet, 'abundance2', 8, [], []);

            case 'signature'
                name = 'Signature';
                boxConstraint = 11.767;
                kernelScale = 2.6353;
                % boxConstraint = 9.862;
                % kernelScale = 2.799;
                [testPerformance{i}, performanceRow(i, :)] = TrainClassifier(name, trainDataSet, testDataSet, 'none', 311, [], [boxConstraint, kernelScale]);
        end
    end

    v = cell2mat(testPerformance);
    fprintf('%s & %.2f (%.2f) & %.2f (%.2f) & %.2f (%.2f) & %.2f (%.2f) & %.3f\n', ...
        method, mean([v.Accuracy]*100), std([v.Accuracy]*100), mean([v.Sensitivity]*100), std([v.Sensitivity]*100), mean([v.Specificity]*100), std([v.Specificity]*100), mean([v.JaccardCoeff]*100, 'omitnan'), std([v.JaccardCoeff]*100, 'omitnan'), mean([v.AUC]))

    if strcmpi(method, 'abundance')
        resultAbundance = testPerformance;
        resultRowAbundance = performanceRow;

    elseif strcmpi(method, 'signature')
        resultSignature = testPerformance;
        resultRowSignature = performanceRow;
    end

end

function [testPerformance, performanceRow] = TrainClassifier(name_, trainData_, testData_, method_, q_, coeff_, svmSettings)
config.SetSetting('SaveFolder', fullfile('FrameworkTesting', name_));

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
performanceRow = [testPerformance.Accuracy * 100, ...
    testPerformance.Sensitivity * 100, ...
    testPerformance.Specificity * 100, ...
    testPerformance.JaccardCoeff * 100, ...
    testPerformance.AUC * 100];
%
%     fgMasks = {testData_.Masks};
%     sRGBs = {testData_.RGBs};
%
%     predlabels = cellfun(@(x) trainUtility.Predict(trainedModel, x, 'voting', true), testscores, 'un', 0);
%     origSizes = cellfun(@(x) size(x), fgMasks, 'un', 0);
%
%     for i = 1:numel(sRGBs)
%
%         %% without post-processing
%         baseImg = sRGBs{i};
%         predImg = hsi.RecoverSpatialDimensions(predlabels{i}{1}, origSizes{i}, fgMasks{i});
%         postProbImg = hsi.RecoverSpatialDimensions(predlabels{i}{2}, origSizes{i}, fgMasks{i});
%         labelImg = hsi.RecoverSpatialDimensions(ytest{i}, origSizes{i}, fgMasks{i});
%         targetSample = testData_(i).Labels.ID;
%
%         savePredPath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'),   strcat('pred', targetSample)), 'mat');
%         save(savePredPath, 'predImg');
%
%         plotPath1 = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'),  targetSample), 'png');
%         plots.GroundTruthComparison(1, plotPath1, baseImg, labelImg, predImg);
%
%         borderImg = zeros(size(predImg));
%         plotPath2 = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'),  strcat('check_', targetSample)), 'png');
%         plots.PredictionValues(2, plotPath2, rescale(postProbImg(:,:,2)), borderImg);
%
%
%         %% with post processing
%         seClose = strel('disk', 3);
%         closeMask = imclose(predImg, seClose);
%         seErode = strel('disk', 3);
%         postPredMask = imerode(closeMask, seErode);
%
%         plotPath1 = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'), 'post-process', targetSample), 'png');
%         plots.PostProcessingComparison(3, plotPath1, labelImg, predImg, postPredMask);
%
%         savePredPath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'), 'post-process', strcat('pred', targetSample)), 'mat');
%         predImg = postPredMask;
%         save(savePredPath, 'predImg');
%     end
%
%     saveResultPath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'),'result'), 'mat');
%     save(saveResultPath, 'testPerformance', 'performanceRow');
end