% ======================================================================
%> @brief DimredAndTrainInternal trains and test an SVM classifier after dimension reduction.
%>
%> Observations are processed with the SVM as individual spectrums per pixel.
%> See @c dimredUtility for more information about additional arguments.
%>
%> How to change application scope of the dimension reduction method:
%> Join '-all' on 'method' string to train dimred on all data.
%> Otherwise, dimred is trained individually on each sample and according to the requirements of 'method'.
%>
%> @b Usage
%>
%> @code
%> boxConstraint = 2.1;
%> kernelScale = 4.3;
%> svmSettings = [boxConstraint, kernelScale];
%> [performanceStruct, trainedModel, Xvalid] = trainUtility.DimredAndTrain(trainData, testData, method, q, svmSettings);
%>
%> % Apply dimension reduction with additional settings.
%> superpixelNumber = 10;
%> [performanceStruct, trainedModel, Xvalid] = trainUtility.DimredAndTrain(trainData, testData, 'SuperPCA', q, svmSettings, superpixelNumber);
%> @endcode
%>
%> @param trainData [struct] | The train data
%> @param testData [struct] | The test data
%> @param method [char] | The dimension reduction method
%> @param q [int] | The reduced dimension
%> @param svmSettings [numeric array] | The settings for the SVM. It is an array of two values, 'BoxConstraint' and 'KernelScale'. If no setting is given, the model is optimized with 'KernelScale' = 'auto'.
%> @param varargin [cell array] | The arguments necessary for the dimension reduction method
%>
%> @retval performanceStruct [struct] | The model's performance
%> @retval trainedModel [model] | The trained SVM model
%> @retval Xvalid [numeric array] | The dimension-reduced test data
% ======================================================================
function [performanceStruct, trainedModel, XTest] = DimredAndTrainInternal(trainData, testData, method, q, svmSettings, varargin)

% scope of training

if strcmpi(method, 'lda')
    method = 'LDA-all'; %LDA is trained on all data

elseif strcmpi(method, 'pca-lda')
    method = 'PCA-LDA-all'; %PCA followed by LDA is trained on all data
end

updatedMethod = method;
if strcmpi(method, 'autoencoder') || strcmpi(method, 'rfi')
    updatedMethod = method; %'none'
    scope = 'all';

elseif strcmpi(method, 'lda')
    scope = 'all'; %LDA is trained on all data

elseif strcmpi(method, 'pca-lda')
    scope = 'all'; %PCA followed by LDA is trained on all data

elseif contains(lower(method), '-all')
    updatedMethod = strrep(method, '-all', '');
    scope = 'all';

else
    scope = 'perSample';
end

if strcmpi(method, 'MSuperPCA') || strcmpi(method, 'MClusterPCA')
    scope = 'stacked';
end

% Apply dimred depending on the scope
if strcmpi(scope, 'perSample')
    tic;
    transTrain = cellfun(@(x, y) x.Transform(true, updatedMethod, q, y, varargin{:}), {trainData.Values}, {trainData.ImageLabels}, 'un', 0);
    drTrainTime = toc;
    drTrainTime = drTrainTime / numel(transTrain);
    XTest = cellfun(@(x, y) x.Transform(true, updatedMethod, q, y, varargin{:}), {testData.Values}, {testData.ImageLabels}, 'un', 0);

    %Convert cell image data to concatenated array data
    XTrainScores = commonUtility.Cell2Mat(transTrain);
    XTestScores = commonUtility.Cell2Mat(XTest);

else %strcmpi(scope, 'all')
    tic;
    dataCell = cellfun(@(x) x.GetMaskedPixels(), {trainData.Values}, 'un', 0);
    dataArray = cell2mat(dataCell');
    dataCell = cellfun(@(x, y) GetMaskedPixelsInternal(y, x), {trainData.Masks}, {trainData.ImageLabels}, 'un', 0);
    dataLabels = cell2mat(dataCell');
    [coeff, XTrainScores, ~, ~, ~] = dimredUtility.Apply(dataArray, updatedMethod, q, [], dataLabels, varargin{:});
    drTrainTime = toc;
    drTrainTime = drTrainTime / numel(trainData);

    dataCell = cellfun(@(x) x.GetMaskedPixels(), {testData.Values}, 'un', 0);
    dataArray = cell2mat(dataCell');
    if ~isempty(coeff) && ~isobject(coeff)

        XTestScores = dataArray * coeff;
        XTest = cellfun(@(x) x.Transform(true, 'pretrained', q, [], coeff), {testData.Values}, 'un', 0);

    elseif isobject(coeff)
        dimredStruct = coeff;
        XTestScores = dimredUtility.Transform(dataArray, updatedMethod, q, dimredStruct);
        XTest = cellfun(@(x) x.Transform(true, updatedMethod, q, [], dimredStruct), {testData.Values}, 'un', 0);

    else
        error('Incomplete arguments. Dimension reduction failed.')
    end

end

% Use only foreground pixels for the analysis
transyTrain = cellfun(@(x, y) GetMaskedPixelsInternal(x, y), {trainData.ImageLabels}, {trainData.Masks}, 'un', 0);
yTrain = commonUtility.Cell2Mat(transyTrain);
transyValid = cellfun(@(x, y) GetMaskedPixelsInternal(x, y), {testData.ImageLabels}, {testData.Masks}, 'un', 0);
yTest = commonUtility.Cell2Mat(transyValid);

% Train SVM
switch lower(scope)
    case 'stacked'
        [yPredict, modelTrainTime, trainedModel, ~, ~] = trainUtility.StackMultiscale(@trainUtility.SVM, 'voting', XTrainScores, yTrain, XTestScores);

    otherwise
        [yPredict, modelTrainTime, trainedModel] = trainUtility.RunSVM(XTrainScores, yTrain, XTestScores, svmSettings);
end

% Evaluate Predictions
[performanceStruct, trainedModel] = trainUtility.ModelEvaluation(method, q, yPredict, yTest, yTrain, trainedModel, ...
    drTrainTime, modelTrainTime, testData, XTest);

end