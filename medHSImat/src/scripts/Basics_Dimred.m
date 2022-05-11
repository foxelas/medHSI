function [trainPerformance, testPerformance] = Basics_Dimred()

% filePath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'),  'lastrun'), 'mat');
% load(filePath);
% filePath2 = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'),  'cvpInfo'), 'mat');
% load(filePath2);

experiment = strcat('Dimred', date(), '-rbf-100000-outlier0,05');
Basics_Init(experiment);

dataset = config.GetSetting('Dataset');

%% Read h5 data
folds = 5;
testTargets = {'157', '251', '227'};
dataType = 'hsi';
qs = [5, 10, 20, 50, 100];
ks = 1:length(qs);
j = 0;

[trainData, testData, cvp] = trainUtility.SplitDataset(dataset, folds, testTargets, dataType);
filePath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'), 'lastrun'), 'mat');
save(filePath, '-v7.3');

%%%%%%%%%%%%%%%%%%%%%% Baseline %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('Baseline: %d \n\n', 311);
j = j + 1;
[trainPerformance{j}{1}, testPerformance{j}{1}] = trainUtility.ValidateTest2(trainData, testData, cvp, 'Baseline', 311);

%%%%%%%%%%%%%%%%%%%%%% PCA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

j = j + 1;
for k = ks
    q = qs(k);
    fprintf('PCA: %d \n\n', q);
    [trainPerformance{j}{k}, testPerformance{j}{k}] = trainUtility.ValidateTest2(trainData, testData, cvp, 'PCA', q);
end

%%%%%%%%%%%%%%%%%%%%%% ICA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

j = j + 1;
for k = ks
    q = qs(k);
    fprintf('FastICA: %d \n\n', q);
    [trainPerformance{j}{k}, testPerformance{j}{k}] = trainUtility.ValidateTest2(trainData, testData, cvp, 'FastICA', q);
end

%%%%%%%%%%%%%%%%%%%%%% RICA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

j = j + 1;
for k = ks
    q = qs(k);
    fprintf('RICA: %d \n\n', q);
    [trainPerformance{j}{k}, testPerformance{j}{k}] = trainUtility.ValidateTest2(trainData, testData, cvp, 'RICA', q);
end

%%%%%%%%%%%%%%%%%%%%%% Wavelength Selection %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('Wavelength Selection: \n\n');
j = j + 1;
[trainPerformance{j}{1}, testPerformance{j}{1}] = trainUtility.ValidateTest2(trainData, testData, cvp, 'MSelect', 2);

%%%%%%%%%%%%%%%%%%%%%% LDA/QDA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('LDA: \n\n');
j = j + 1;
[trainPerformance{j}{1}, testPerformance{j}{1}] = trainUtility.ValidateTest2(trainData, testData, cvp, 'LDA', 1);

% fprintf('QDA: \n\n');
% j = j + 1;
% %% Fails because of covariance
% [valTrain(j, :), valTest(j, :)] = trainUtility.ValidateTest2(trainData, testData, cvp, 'qda', 1);

%%%%%%%%%%%%%%%%%%%%% Cluster PCA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

j = j + 1;
for k = ks
    q = qs(k);
    fprintf('ClusterPCA: %d \n\n', q);
    [trainPerformance{j}{k}, testPerformance{j}{k}] = trainUtility.ValidateTest2(trainData, testData, cvp, 'ClusterPCA', q);
end

%%%%%%%%%%%%%%%%%%%%% Super PCA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

j = j + 1;
for k = ks
    q = qs(k);
    fprintf('SuperPCA: %d \n\n', q);
    [trainPerformance{j}{k}, testPerformance{j}{k}] = trainUtility.ValidateTest2(trainData, testData, cvp, 'SuperPCA', q);
end

%%%%%%%%%%%%%%%%%%%%% Multiscale Super PCA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pixelNumArray = floor(20*sqrt(2).^[-2:2]);

j = j + 1;
for k = ks
    q = qs(k);
    fprintf('MSuperPCA: %d \n\n', q);
    [trainPerformance{j}{k}, testPerformance{j}{k}] = trainUtility.ValidateTest2(trainData, testData, cvp, 'MSuperPCA', q, pixelNumArray);
end

%%%%%%%%%%%%%%%%%%%%% Multiscale Cluster PCA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pixelNumArray = [2, 5, 6, 8, 10];

j = j + 1;
for k = ks
    q = qs(k);
    fprintf('MClusterPCA: %d \n\n', q);
    [trainPerformance{j}{k}, testPerformance{j}{k}] = trainUtility.ValidateTest2(trainData, testData, cvp, 'MClusterPCA', q, pixelNumArray);
end

%%%%%%%%%%%%%%%%%%%%% Autoencoder %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
j = j + 1;
for k = ks
    q = qs(k);
    fprintf('Autoencoder: %d \n\n', q);
    [trainPerformance{j}{k}, testPerformance{j}{k}] = trainUtility.ValidateTest2(trainData, testData, cvp, 'Autoencoder', q);
end

%%%%%%%%%%%%%%%%%%%%% Random Forest Importance %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('RFI: \n\n');

j = j + 1;
for k = ks
    q = qs(k);
    fprintf('RFI: %d \n\n', q);
    [trainPerformance{j}{k}, testPerformance{j}{k}] = trainUtility.ValidateTest2(trainData, testData, cvp, 'RFI', q);
end

j = j + 1; 
fprintf('PCA-LDA: \n\n');
[trainPerformance{j}{1}, testPerformance{j}{1}] = trainUtility.ValidateTest2(trainData, testData, cvp, 'PCA-LDA', 20);

%%%%%%%%%%%%%%%%%%%%%%%% Results %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Save performance 
save(filePath, 'trainPerformance', 'testPerformance');
PrepareGraphs_Performance();

end

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


% %%%%%%%%%%%%%%%%%%%%% Assisting Functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [acc] = critfun(scores, labels)
% SVMModel = fitcsvm(scores, labels, 'Standardize', true, 'KernelFunction', 'RBF', ...
%     'KernelScale', 'auto');
% predlabels = predict(SVMModel, scores);
% [acc, ~, ~] = metrics.Evaluations(labels, predlabels);
% end
