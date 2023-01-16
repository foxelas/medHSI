% ======================================================================
%> @brief EvaluateTestInternal prepares figures of the predicted segments during testing.
%>
%> @b Usage
%>
%> @code
%> EvaluateTestInternal(trainedModel, testData, XTestScores, yTest);
%>
%> trainUtility.EvaluateTestInternal(trainedModel, testData, XTestScores, yTest);
%> @endcode
%>
%> @param trainedModel [cell array] | The stacked models. If only one model is used, then it has length 1.
%> @param testData [cell array] | The test data.
%> @param XTestScores [numeric array] | The train feature vectors.
%> @param yTest [numeric array] | The ground truth labels.
% ======================================================================
function [] = EvaluateTestInternal(trainedModel, testData, XTestScores, yTest)

fgMasks = {testData.Masks};
sRGBs = {testData.RGBs};
yPredict = cellfun(@(x) trainUtility.Predict(trainedModel, x, 'voting'), XTestScores, 'un', 0);
origSizes = cellfun(@(x) size(x), fgMasks, 'un', 0);

for i = 1:numel(sRGBs)

    %% without post-processing
    maskPredict = hsi.RecoverSpatialDimensions(yPredict{i}, origSizes{i}, fgMasks{i});
    maskTest = hsi.RecoverSpatialDimensions(yTest{i}, origSizes{i}, fgMasks{i});
    jacsim = commonUtility.Jaccard(maskPredict, maskTest);

    imgFilePath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'), num2str(i), ...
        strcat('pred_', method, '_', num2str(q))), 'png');

    figTitle = sprintf('%s', strcat(method, '-', num2str(q), ' (', sprintf('%.2f', jacsim*100), '%)'));
    plots.Overlay(1, imgFilePath, sRGBs{i}, maskPredict, figTitle);

    %% with post processing
    seClose = strel('disk', 3);
    closeMask = imclose(maskPredict, seClose);
    seErode = strel('disk', 3);
    postMaskPredict = imerode(closeMask, seErode);
    jacsim = commonUtility.Jaccard(postMaskPredict, maskTest);

    imgFilePath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'), strcat(num2str(i), '_post'), ...
        strcat('pred_', method, '_', num2str(q))), 'png');
    figTitle = sprintf('%s', strcat(method, '-', num2str(q), ' (', sprintf('%.2f', jacsim*100), '%)'));
    plots.Overlay(1, imgFilePath, sRGBs{i}, postMaskPredict, figTitle);
end

end