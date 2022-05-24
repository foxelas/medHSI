% filePath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'),  'lastrun'), 'mat');
% load(filePath);
% filePath2 = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'),  'cvpInfo'), 'mat');
% load(filePath2);

% experiment = strcat('Dimred', date(), '-rbf-100000-outlier0,05');
% config.SetSetting('Dataset', 'pslRaw-Denoisesmoothen');
% 
% Basics_Init(experiment);
% 
% dataset = config.GetSetting('Dataset');
% 
% %% Read h5 data
% folds = 5;
% testTargets = {'157', '251', '227'};
% dataType = 'hsi';
% qs = [5, 10, 20, 50, 100];
% ks = 1:length(qs);
% j = 0;
% 
% [trainData, testData, cvp] = trainUtility.SplitDataset(dataset, folds, testTargets, dataType);
% filePath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'), 'lastrun'), 'mat');
% save(filePath, '-v7.3');



q = 100;
method = 'clusterPCA';
% method = 'pretrained';
% featImp =impOOB';
% [~, idx] = sort(featImp, 'descend');
% dropIdx = idx(q+1:end);
% dropIdx = [dropIdx; 311; 1];
% featImp(dropIdx) = 0; 
% coeff = diag(featImp);
% coeff( :, ~any(coeff,1) ) = [];  %drop zero columns

[testPerformance, trainedModel, testscores] = trainUtility.DimredAndTrain(trainData, testData, method, q); %, coeff);
fprintf('Test - Jaccard: %.3f %%, AUC: %.3f, Accuracy: %.3f %%, Sensitivity: %.3f %%, Specificity: %.3f %%, DR Train time: %.5f, SVM Train time: %.5f \n\n', ...
    testPerformance.JaccardCoeff*100, testPerformance.AUC, testPerformance.Accuracy*100, testPerformance.Sensitivity*100, ... .
    testPerformance.Specificity*100, testPerformance.DRTrainTime, testPerformance.ModelTrainTime);
ytest = cellfun(@(x, y) GetMaskedPixelsInternal(x.Labels, y.FgMask), {testData.Labels}, {testData.Values}, 'un', 0);
b = [testPerformance.JaccardCoeff*100, ...
testPerformance.JacDensity*100, ...
testPerformance.Accuracy*100, ...
testPerformance.Sensitivity*100 , ...
testPerformance.Specificity*100]

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

    figure(5);  imshow(predMask);
    imgFilePath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'), num2str(i), ...
        strcat('mask_pred_', method, '_', num2str(q))), 'png');
    plots.SavePlot(5, imgFilePath); 
    
    
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
    
    
    figure(6);  imshow(postPredMask);
    imgFilePath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'), strcat(num2str(i), '_post'), ...
        strcat('mask_pred_', method, '_', num2str(q))), 'png');
    plots.SavePlot(6, imgFilePath); 

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