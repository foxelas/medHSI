function [valTrain, valTest] = Basics_Dimred()
% filePath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'),  'lastrun'), 'mat');
% load(filePath);
% filePath2 = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'),  'cvpInfo'), 'mat');
% load(filePath2);
% filePath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'),  'lastrun-2'), 'mat');

experiment = strcat('Dimred', date(), '-rbf-100000');
Basics_Init(experiment);

config.SetSetting('Dataset', 'pslRaw');
fprintf('Running for dataset %s\n', config.GetSetting('Dataset'));
dataset = config.GetSetting('Dataset');

%% Read h5 data
folds = 5;
testTargets = {'163', '181', '227'};
dataType = 'hsi';
qs = [10, 50, 100];
j = 1;

[trainData, testData, cvp] = trainUtility.SplitDataset(dataset, folds, testTargets, dataType);

filePath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'),  'lastrun'), 'mat');
%%%%%%%%%%%%%%%%%%%%% Super PCA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for q = qs
    fprintf('SuperPCA: %d \n\n', q);
    j = j + 1;
    [valTrain(j, :), valTest(j, :)] = trainUtility.ValidateTest2(trainData, testData, cvp, 'SuperPCA', q);
end
save(filePath, 'valTrain', 'valTest');

%%%%%%%%%%%%%%%%%%%%%% Baseline %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('Baseline: %d \n\n', 311);
[valTrain(j, :), valTest(j, :)] = trainUtility.ValidateTest2(trainData, testData, cvp, 'none', 311);
save(filePath, 'valTrain', 'valTest');

%%%%%%%%%%%%%%%%%%%%%% PCA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for q = qs
    fprintf('PCA: %d \n\n', q);
    j = j + 1;
    [valTrain(j, :), valTest(j, :)] = trainUtility.ValidateTest2(trainData, testData, cvp, 'pca', q);
end
save(filePath, 'valTrain', 'valTest');

%%%%%%%%%%%%%%%%%%%%%% RICA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for q = qs
    fprintf('RICA: %d \n\n', q);
    j = j + 1;
    [valTrain(j, :), valTest(j, :)] = trainUtility.ValidateTest2(trainData, testData, cvp, 'rica', q);
end
save(filePath, 'valTrain', 'valTest');

%%%%%%%%%%%%%%%%%%%%%% Wavelength Selection %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('Wavelength Selection: \n\n');
j = j + 1;
[valTrain(j, :), valTest(j, :)] = trainUtility.ValidateTest2(trainData, testData, cvp, 'wavelength-selection', 2);
save(filePath, 'valTrain', 'valTest');

%%%%%%%%%%%%%%%%%%%%%% LDA/QDA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

j = j + 1;
fprintf('LDA: \n\n');
j = j + 1;
[valTrain(j, :), valTest(j, :)] = trainUtility.ValidateTest2(trainData, testData, cvp, 'lda', 1);

fprintf('QDA: \n\n');
j = j + 1;
%% Fails because of covarance 
% [valTrain(j, :), valTest(j, :)] = trainUtility.ValidateTest2(trainData, testData, cvp, 'qda', 1);
save(filePath, 'valTrain', 'valTest');


%%%%%%%%%%%%%%%%%%%%% Autoencoder %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for q = qs
    fprintf('AE: %d \n\n', q);
    j = j + 1;
    [valTrain(j, :), valTest(j, :)] = trainUtility.ValidateTest2(trainData, testData, cvp, 'autoencoder', q);
end
save(filePath, 'valTrain', 'valTest');

%%%%%%%%%%%%%%%%%%%%% Cluster PCA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for q = qs
    fprintf('ClusterPCA: %d \n\n', q);
    j = j + 1;
    [valTrain(j, :), valTest(j, :)] = trainUtility.ValidateTest2(trainData, testData, cvp, 'ClusterSuperPCA', q);
end
save(filePath, 'valTrain', 'valTest');

%%%%%%%%%%%%%%%%%%%%% Random Forest Importance %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('RFI: \n\n');

for q = qs
    fprintf('RFI: %d \n\n', q);
    j = j + 1;
    [valTrain(j, :), valTest(j, :)] = trainUtility.ValidateTest2(trainData, testData, cvp, 'rfi', q);
end
save(filePath, 'valTrain', 'valTest');

%%%%%%%%%%%%%%%%%%%%% Multiscale Super PCA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pixelNumArray = floor(20*sqrt(2).^[-2:2]);

for q = qs
    fprintf('MSuperPCA: %d \n\n', q);

    transformFun = @(x, i) IndexCell(x, i);
    numScales = numel(pixelNumArray);

    j = j + 1;
    [valTrain(j, :), valTest(j, :)] = trainUtility.ValidateTest2(trainData, testData, cvp, 'MSuperPCA', q, transformFun, numScales);
end
save(filePath, 'valTrain', 'valTest');

% %%%%%%%%%%%%%%%%%%%%% SFS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% fprintf('SFS: \n\n');
%
% for q = qs
%     fprintf('SFS: %d \n\n', q);
%
%     tic;
%     maxdev = chi2inv(.95, 1);
%     opt = statset('display', 'iter', ...
%         'TolFun', maxdev, ...
%         'TolTypeFun', 'abs');
%
%     inmodel = sequentialfs(@critfun, X, y, ...
%         'cv', 'none', ...
%         'nullmodel', true, ...
%         'options', opt, ...
%         'direction', 'forward', ...
%         'KeepIn', 1, ...
%         'NFeatures', q);
%     tt = toc;
%     fprintf('Runtime %.5f \n\n', tt);
%
%     imo = inmodel(1:q);
%     scoresrf = X(:, imo);
%     [accuracy, sensitivity, specificity] = RunKfoldValidation(scoresrf, y, cvp, 'rfi', q);
% end


end

%%%%%%%%%%%%%%%%%%%%% Assisting Functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [acc] = critfun(scores, labels)
SVMModel = fitcsvm(scores, labels, 'Standardize', true, 'KernelFunction', 'RBF', ...
    'KernelScale', 'auto');
predlabels = predict(SVMModel, scores);
[acc, ~, ~] = metrics.Evaluations(labels, predlabels);
end

function [scores] = transformSPCAFun(x)
scores = x.Transform(true, 'SuperPCA', 100);
end

function [scores] = IndexCell(x, i)
scores = x{i};
end