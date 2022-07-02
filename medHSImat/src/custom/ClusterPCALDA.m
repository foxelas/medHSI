% filePath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'),  'lastrun'), 'mat');
% load(filePath);
% filePath2 = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'),  'cvpInfo'), 'mat');
% load(filePath2);

q = 10;
denoiseMethod = 'PCA'; %'ClusterPCA';
pixelNumArray = [2, 5, 6];

%varargin = {pixelNumArray};
varargin = {};

XTrain = cellfun(@(x, y) x.Transform(true, denoiseMethod, q, y, varargin{:}), {trainData.Values}, {trainData.ImageLabels}, 'un', 0);
XValid = cellfun(@(x, y) x.Transform(true, denoiseMethod, q, y, varargin{:}), {testData.Values}, {testData.ImageLabels}, 'un', 0);

%Convert cell image data to concatenated array data
XTrainscores = commonUtility.Cell2Mat(XTrain);
XValidscores = commonUtility.Cell2Mat(XValid);

XTrainscores2 = XTrainscores;
XValidscores2 = XValidscores;
XValid2 = XValid;

% dataCell  = cellfun(@(x) x.GetMaskedPixels(), {trainData.Values}, 'un', 0);
% dataArray = cell2mat(dataCell');
% dataCell  = cellfun(@(x, y) GetMaskedPixelsInternal(y, x), {trainData.Masks}, {trainData.ImageLabels}, 'un', 0);
% dataLabels = cell2mat(dataCell');
% [coeffFirst, XTrainscores, ~, ~, ~] = dimredUtility.Apply(dataArray, denoiseMethod, q, [], []);
%
% dataCell  = cellfun(@(x) x.GetMaskedPixels(), {testData.Values}, 'un', 0);
% dataArray = cell2mat(dataCell');
% XValidscores = dataArray * coeffFirst;
% XValid = cellfun(@(x) x.Transform(true, 'pretrained', q, [], coeffFirst), {testData.Values}, 'un', 0);
%

dataCell = cellfun(@(x, y) GetMaskedPixelsInternal(y, x), {trainData.Masks}, {trainData.ImageLabels}, 'un', 0);
yTrain = cell2mat(dataCell');
dataCell = cellfun(@(x, y) GetMaskedPixelsInternal(y, x), {testData.Masks}, {testData.ImageLabels}, 'un', 0);
yTest = cell2mat(dataCell');

% classMethod = 'LDA';
%
%
% [coeffSecond, XTrainscores2, ~, ~, ~, Mdl] = dimredUtility.Apply(XTrainscores, classMethod, 1, [], yTrain);
%
% XValid2 = cellfun(@(x) dimredUtility.Transform(x , 'pretrained', 1, coeffSecond), XValid, 'un', 0);
%
%
% XValidscores2 = XValidscores * coeffSecond;
%
% XTrainscores2 = double(Mdl.predict(XTrainscores));
% XValidscores2 = double(Mdl.predict(XValidscores));


[predLabels, modelTrainTime, trainedModel] = trainUtility.RunSVM(XTrainscores2, yTrain, XValidscores2);

mergedMethod = strcat(denoiseMethod, classMethod);
[performanceStruct, trainedModel] = trainUtility.ModelEvaluation(mergedMethod, q, yTest, predLabels, yTrain, trainedModel, ...
    1, 1, testData, XValid2);