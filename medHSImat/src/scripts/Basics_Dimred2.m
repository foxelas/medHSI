experiment = strcat('Dimred', '28-Apr-2022', '-rbf-100000-outlier0,05');
config.SetSetting('Dataset', 'pslRaw');

Basics_Init(experiment);
dataset = config.GetSetting('Dataset');

%% Read h5 data
folds = 5;
testTargets = {'157', '251', '227'};
dataType = 'hsi';

hasLoad = true;
% if hasLoad
%     foldDataFilePath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'),  'lastrun'), 'mat');
%     load(foldDataFilePath);
%     filePath2 = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'),  'cvpInfo'), 'mat');
%     load(filePath2);
% else
% 
%     [trainData, testData, cvp] = trainUtility.SplitDataset(dataset, folds, testTargets, dataType);
%     foldDataFilePath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'), 'lastrun'), 'mat');
%     save(foldDataFilePath, '-v7.3');
% end

%%%%% PCA-20
name = 'PCA-20';
[testPerformance{1}, performanceRow(1,:)] = TrainClassifier(name, trainData, testData, 'pca', 20); 

%%%% Abundance-8
name = 'Abundance-8';
[testPerformance{2}, performanceRow(2,:)] = TrainClassifier(name, trainData, testData, 'abundance', 8); 

%%%% ClusterPCA-100
name = 'ClusterPCA-100';
[testPerformance{3}, performanceRow(3,:)] = TrainClassifier(name, trainData, testData, 'clusterpca', 100); 

%%%%% RF-100
name = 'RFI-100';
q = 102;
filePath3 = strrep(foldDataFilePath, 'lastrun', 'rfi');
load(filePath3, 'impOOB');
method = 'pretrained';
featImp =impOOB';
[~, idx] = sort(featImp, 'descend');
dropIdx = idx(q+1:end);
dropIdx = [dropIdx; 311; 1];
featImp(dropIdx) = 0; 
coeff = diag(featImp);
coeff( :, ~any(coeff,1) ) = [];  %drop zero columns
[testPerformance{4}, performanceRow(4,:)] = TrainClassifier(name, trainData, testData, method, 100, coeff); 
testPerformance{4}.Name = 'RFI-100';

function [testPerformance, performanceRow] = TrainClassifier(name_, trainData_, testData_, method_, q_, coeff_) 
    config.SetSetting('SaveFolder', fullfile('FrameworkTesting', name_));
    
    if nargin < 6
        [testPerformance, trainedModel, testscores] = trainUtility.DimredAndTrain(trainData_, testData_, method_, q_); %, coeff);
    else
        [testPerformance, trainedModel, testscores] = trainUtility.DimredAndTrain(trainData_, testData_, method_, q_, coeff_);
    end 
    
    testPerformance.Name = name_;
    fprintf('Test: %s - Jaccard: %.3f %%, AUC: %.3f, Accuracy: %.3f %%, Sensitivity: %.3f %%, Specificity: %.3f %%, DR Train time: %.5f, SVM Train time: %.5f \n\n', ...
        name_, testPerformance.JaccardCoeff*100, testPerformance.AUC, testPerformance.Accuracy*100, testPerformance.Sensitivity*100, ... .
        testPerformance.Specificity*100, testPerformance.DRTrainTime, testPerformance.ModelTrainTime);
    
    ytest = cellfun(@(x, y) GetMaskedPixelsInternal(x.Labels, y.FgMask), {testData_.Labels}, {testData_.Values}, 'un', 0);
    
    performanceRow = [testPerformance.JaccardCoeff*100, ...
            testPerformance.JacDensity*100, ...
            testPerformance.Accuracy*100, ...
            testPerformance.Sensitivity*100 , ...
            testPerformance.Specificity*100, ...
            testPerformance.AUC*100];

    fgMasks = {testData_.Masks};
    sRGBs = {testData_.RGBs};
   
    predlabels = cellfun(@(x) trainUtility.Predict(trainedModel, x, 'voting', true), testscores, 'un', 0);
    origSizes = cellfun(@(x) size(x), fgMasks, 'un', 0);

    for i = 1:numel(sRGBs)

        %% without post-processing
        baseImg = sRGBs{i};
        predImg = hsi.RecoverSpatialDimensions(predlabels{i}{1}, origSizes{i}, fgMasks{i});
        postProbImg = hsi.RecoverSpatialDimensions(predlabels{i}{2}, origSizes{i}, fgMasks{i});
        labelImg = hsi.RecoverSpatialDimensions(ytest{i}, origSizes{i}, fgMasks{i});
        targetSample = testData_(i).Labels.ID;

        savePredPath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'),   strcat('pred', targetSample)), 'mat');
        save(savePredPath, 'predImg');
        
        plotPath1 = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'),  targetSample), 'png');
        plots.GroundTruthComparison(1, plotPath1, baseImg, labelImg, predImg);

        borderImg = zeros(size(predImg));
        plotPath2 = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'),  strcat('check_', targetSample)), 'png');
        plots.PredictionValues(2, plotPath2, rescale(postProbImg(:,:,2)), borderImg);
        

        %% with post processing
        seClose = strel('disk', 3);
        closeMask = imclose(predImg, seClose);
        seErode = strel('disk', 3);
        postPredMask = imerode(closeMask, seErode);
        
        plotPath1 = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'), 'post-process', targetSample), 'png');
        plots.PostProcessingComparison(3, plotPath1, labelImg, predImg, postPredMask);
        
        savePredPath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'), 'post-process', strcat('pred', targetSample)), 'mat');
        predImg = postPredMask;
        save(savePredPath, 'predImg');
    end

    saveResultPath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'),'result'), 'mat');
    save(saveResultPath, 'testPerformance', 'performanceRow');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% baseDir = 'D:\elena\mspi\output\pslRaw32Augmented\python-test\';
% folderName = '2022-05-11_sm_resnet_pretrained';
% %folderName = '2022-05-11_sm_resnet';    
% %folderName = '2022-05-17_xception3d3_max_dropout_first-last';
% %folderName = '2022-05-13_cnn3d';
% 
% fgMasks = {testData.Masks};
% sRGBs = {testData.RGBs};
% 
% jacsim = 0;
% jacDensity = 0;
% mahalDist = 0;
% accuracy = 0;
% sensitivity = 0;
% specificity = 0;
% 
% for i = 1:numel(sRGBs)
% 
%     %% without post-processing
%     matPath = fullfile(baseDir, folderName, strcat( 'pred', strrep(testTargets{i}, 'sample', '') ,'.mat'));
%     load(matPath, 'predImg');
%     
%     predMask =  predImg > 0.5;  %logical(hsi.RecoverSpatialDimensions(predLabelsCell{i}, origSizes{i}, fgMasks{i}));
%     trueMask = testData(i).ImageLabels;
%     
%     jacsim = jacsim + commonUtility.Jaccard(predMask, trueMask);
%     jacDensity = jacDensity + MeasureDensity(predMask, trueMask);
%     [accuracy1, sensitivity1, specificity1] = commonUtility.Evaluations(trueMask(:), predMask(:));
%     accuracy = accuracy + accuracy1;
%     sensitivity = sensitivity + sensitivity1;
%     specificity = specificity + specificity1;
%     [h, w] = size(trueMask);
%     mahalDist = mahalDist + mahal([1]', reshape(predMask, [h * w, 1]));
% end
% 
% testPerformance.JaccardCoeff = jacsim / numel(sRGBs);
% testPerformance.JacDensity = jacDensity / numel(sRGBs);
% testPerformance.Mahalanobis = mahalDist / numel(sRGBs);
% testPerformance.Accuracy = accuracy / numel(sRGBs);
% testPerformance.Sensitivity = sensitivity / numel(sRGBs);
% testPerformance.Specificity = specificity / numel(sRGBs);
% 
% 
% b = [testPerformance.JaccardCoeff*100, ...
% testPerformance.JacDensity*100, ...
% testPerformance.Accuracy*100, ...
% testPerformance.Sensitivity*100 , ...
% testPerformance.Specificity*100]