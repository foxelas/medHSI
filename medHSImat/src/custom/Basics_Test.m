
saveTarget = 'segmentation';
trainDataset = 'pslRaw';
targetDataset = 'split3';
config.SetSetting('Dataset', trainDataset);
[~, targetIDs] = commonUtility.DatasetInfo();

loadData = true;

if ~loadData
    trainN = 19;
    trainData = struct('Values', [], 'Labels', [], 'RGBs', [], 'Masks', [], 'ImageLabels', []);
    for i = 1:trainN
        [spectrumData, labelInfo] = hsiUtility.LoadHsiAndLabel(targetIDs{i});

        trainData(i).Values = spectrumData;
        trainData(i).Labels = labelInfo;
        trainData(i).RGBs = spectrumData.GetDisplayImage();
        trainData(i).Masks = spectrumData.FgMask;
        trainData(i).ImageLabels = logical(labelInfo.Labels);
        trainData(i).TargetName = targetIDs{i};
    end

    config.SetSetting('Dataset', targetDataset);
    fileName = commonUtility.GetFilename('output', fullfile(saveTarget, 'trainData'));
    save(fileName, 'trainData', '-v7.3');
else
    config.SetSetting('Dataset', targetDataset);
    fileName = commonUtility.GetFilename('output', fullfile(saveTarget, 'trainData'));
    load(fileName, 'trainData');
end

targetDataset = 'split3';
config.SetSetting('Dataset', targetDataset);
[~, targetIDs] = commonUtility.DatasetInfo();

if ~loadData
    testN = numel(targetIDs);
    testData = struct('Values', [], 'Labels', [], 'RGBs', [], 'Masks', [], 'ImageLabels', []);
    for i = 1:testN
        [spectrumData, labelInfo] = hsiUtility.LoadHsiAndLabel(targetIDs{i});
        testData(i).Values = spectrumData;
        testData(i).Labels = labelInfo;
        testData(i).RGBs = spectrumData.GetDisplayImage();
        testData(i).Masks = spectrumData.FgMask;
        testData(i).ImageLabels = logical(labelInfo.Labels);
        testData(i).TargetName = targetIDs{i};
    end

    config.SetSetting('Dataset', targetDataset);
    fileName = commonUtility.GetFilename('output', fullfile(saveTarget, 'testData'));
    save(fileName, 'testData', '-v7.3');
else
    config.SetSetting('Dataset', targetDataset);
    fileName = commonUtility.GetFilename('output', fullfile(saveTarget, 'testData'));
    load(fileName, 'testData');
end

rng default; % For reproducibility

methods = {'kmeans', 'abundance', 'signature'};

for k = 1:3
    method = methods{k};

    testDataSet = testData;
    trainDataSet = trainData; %struct('Values', [], 'Labels', [], 'RGBs', [], 'Masks', [], 'ImageLabels', []);

    switch method
        case 'abundance'
            name = 'Abundance-8';
            %observed
            boxConstraint = 44.184;
            kernelScale = 4.0136;
            %                 %estimated
            %                 boxConstraint = 38.64;
            %                 kernelScale = 4.1023;
            config.SetSetting('SaveFolder', fullfile(saveTarget, name));
            [testPerformance{k}, performanceRow(k, :)] = TrainClassifier(name, trainDataSet, testDataSet, 'abundance2', 8, [], [boxConstraint, kernelScale]);

        case 'signature'
            name = 'Signature';
            config.SetSetting('SaveFolder', fullfile(saveTarget, name));
            %observed
            boxConstraint = 44.184;
            kernelScale = 4.0136;
            %                 %estimated
            %                 boxConstraint = 38.64;
            %                 kernelScale = 4.1023;

            % %                 %observed
            % %                 boxConstraint = 11.767;
            % %                 kernelScale = 2.6353;
            % %                 %                %estimated
            % %                 %                boxConstraint = 9.862;
            % %                 %                kernelScale = 2.799;
            [testPerformance{k}, performanceRow(k, :)] = TrainClassifier(name, trainDataSet, testDataSet, 'none', 311, [], [boxConstraint, kernelScale]);

        case 'kmeans'
            name = 'KMeans+SAM';
            config.SetSetting('SaveFolder', fullfile(saveTarget, name));
            [testPerformance{k}, performanceRow(k, :)] = TrainSegmentation(name, testDataSet);
    end

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
performanceRow = [testPerformance.Accuracy * 100, ...
    testPerformance.Sensitivity * 100, ...
    testPerformance.Specificity * 100, ...
    testPerformance.JaccardCoeff * 100, ...
    testPerformance.AUC * 100];

fgMasks = {testData_.Masks};
sRGBs = {testData_.RGBs};

predlabels = cellfun(@(x) trainUtility.Predict(trainedModel, x, 'voting', true), testscores, 'un', 0);
origSizes = cellfun(@(x) size(x), fgMasks, 'un', 0);

for i = 1:numel(sRGBs)
    predImg = hsi.RecoverSpatialDimensions(predlabels{i}{1}, origSizes{i}, fgMasks{i});
    targetSample = testData_(i).TargetName;
    savePredPath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'), strcat('pred', targetSample)), 'mat');
    save(savePredPath, 'predImg');
end

saveResultPath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'), '0_performance'), 'mat');
save(saveResultPath, 'testPerformance', 'performanceRow', 'trainedModel', '-v7.3');
end

function [testPerformance, performanceRow] = TrainSegmentation(name_, testData_)


predMasks = cellfun(@(x) SegmentLeonInternal(x), {testData_.Values}, 'UniformOutput', false);
trueMasks = {testData_.ImageLabels};

predLabels = cell2mat(cellfun(@(x) x(:), predMasks, 'UniformOutput', false)');
gtLabels = cell2mat(cellfun(@(x) x(:), trueMasks, 'UniformOutput', false)');


[testPerformance] = trainUtility.Evaluation(name_, [], predLabels, gtLabels, predMasks, trueMasks, [], gtLabels, double(predLabels));

testPerformance.Name = name_;
fprintf('Test: %s - Jaccard: %.3f %%, AUC: %.3f, Accuracy: %.3f %%, Sensitivity: %.3f %%, Specificity: %.3f %%, \n\n', ...
    name_, testPerformance.JaccardCoeff*100, testPerformance.AUC, testPerformance.Accuracy*100, testPerformance.Sensitivity*100, ... .
    testPerformance.Specificity*100);

%     ytest = cellfun(@(x, y) GetMaskedPixelsInternal(x.Labels, y.FgMask), {testData_.Labels}, {testData_.Values}, 'un', 0);
%
performanceRow = [testPerformance.Accuracy * 100, ...
    testPerformance.Sensitivity * 100, ...
    testPerformance.Specificity * 100, ...
    testPerformance.JaccardCoeff * 100, ...
    testPerformance.AUC * 100];

sRGBs = {testData_.RGBs};

for i = 1:numel(sRGBs)
    predImg = predMasks{i};
    targetSample = testData_(i).TargetName;
    savePredPath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'), strcat('pred', targetSample)), 'mat');
    save(savePredPath, 'predImg');
end

saveResultPath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'), '0_performance'), 'mat');
save(saveResultPath, 'testPerformance', 'performanceRow', '-v7.3');
end