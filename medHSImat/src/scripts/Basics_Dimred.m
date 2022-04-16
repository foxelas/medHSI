function [trainPerformance, testPerformance, methodName ] = Basics_Dimred()
filePath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'),  'lastrun'), 'mat');
load(filePath);
filePath2 = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'),  'cvpInfo'), 'mat');
load(filePath2);

% experiment = strcat('Dimred', date(), '-linear-100000-removeduplicates');
% Basics_Init(experiment);
% config.SetSetting('Dataset', 'pslRaw');

diary log.txt

fprintf('Running for dataset %s\n', config.GetSetting('Dataset'));
dataset = config.GetSetting('Dataset');

%% Read h5 data
folds = 5;
testTargets = {'163', '181', '227'};
dataType = 'hsi';
qs = [10, 50, 100];
j = 0;

% [trainData, testData, cvp] = trainUtility.SplitDataset(dataset, folds, testTargets, dataType);
% filePath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'),  'lastrun'), 'mat');
% save(filePath, '-v7.3');

%%%%%%%%%%%%%%%%%%%%%% Baseline %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('Baseline: %d \n\n', 311);
j = j + 1;
methodName{j} = 'baseline';
% [trainPerformance(j), testPerformance(j)] = trainUtility.ValidateTest2(trainData, testData, cvp, 'none', 311);
save(filePath, 'trainPerformance', 'testPerformance');

%%%%%%%%%%%%%%%%%%%%%% PCA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for q = qs
    fprintf('PCA: %d \n\n', q);
    j = j + 1;
    methodName{j} = strcat('pca-', num2str(q));
%     [trainPerformance(j), testPerformance(j)] = trainUtility.ValidateTest2(trainData, testData, cvp, 'pca', q);
end
save(filePath, 'trainPerformance', 'testPerformance');

%%%%%%%%%%%%%%%%%%%%%% RICA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for q = qs
    fprintf('RICA: %d \n\n', q);
    j = j + 1;
    methodName{j} = strcat('rica-', num2str(q));
%     [trainPerformance(j), testPerformance(j)] = trainUtility.ValidateTest2(trainData, testData, cvp, 'rica', q);
end
save(filePath, 'trainPerformance', 'testPerformance');

%%%%%%%%%%%%%%%%%%%%%% Wavelength Selection %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('Wavelength Selection: \n\n');
j = j + 1;
methodName{j} = strcat('manual-', '2');
% [trainPerformance(j), testPerformance(j)] = trainUtility.ValidateTest2(trainData, testData, cvp, 'wavelength-selection', 2);
save(filePath, 'trainPerformance', 'testPerformance');

%%%%%%%%%%%%%%%%%%%%%% LDA/QDA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

j = j + 1;
fprintf('LDA: \n\n');
j = j + 1;
methodName{j} = strcat('lda-', '1');
% [trainPerformance(j), testPerformance(j)] = trainUtility.ValidateTest2(trainData, testData, cvp, 'lda', 1);
save(filePath, 'trainPerformance', 'testPerformance');

% fprintf('QDA: \n\n');
% j = j + 1;
%% Fails because of covarance 
% [valTrain(j, :), valTest(j, :)] = trainUtility.ValidateTest2(trainData, testData, cvp, 'qda', 1);
% save(filePath, 'trainPerformance', 'testPerformance');

%%%%%%%%%%%%%%%%%%%%% Cluster PCA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for q = qs
    fprintf('ClusterPCA: %d \n\n', q);
    j = j + 1;
    methodName{j} = strcat('clusterPCA-', num2str(q));
%     [trainPerformance(j), testPerformance(j)] = trainUtility.ValidateTest2(trainData, testData, cvp, 'ClusterPCA', q);
end
save(filePath, 'trainPerformance', 'testPerformance');

%%%%%%%%%%%%%%%%%%%%% Super PCA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for q = qs
    fprintf('SuperPCA: %d \n\n', q);
    j = j + 1;
    methodName{j} = strcat('superPCA-', num2str(q));
%     [trainPerformance(j), testPerformance(j)] = trainUtility.ValidateTest2(trainData, testData, cvp, 'SuperPCA', q);
end
save(filePath, 'trainPerformance', 'testPerformance');


%%%%%%%%%%%%%%%%%%%%% Multiscale Super PCA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pixelNumArray = floor(20*sqrt(2).^[-2:2]);

for q = qs
    fprintf('MSuperPCA: %d \n\n', q);
    j = j + 1;
    methodName{j} = strcat('MSuperPCA-', num2str(q));
%     [trainPerformance(j), testPerformance(j)] = trainUtility.ValidateTest2(trainData, testData, cvp, 'MSuperPCA', q, pixelNumArray);
end
save(filePath, 'trainPerformance', 'testPerformance');


%%%%%%%%%%%%%%%%%%%%% Multiscale Cluster PCA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pixelNumArray = [2, 5, 8, 10];

for q = qs
    fprintf('MClusterPCA: %d \n\n', q);
    j = j + 1;
    methodName{j} = strcat('MClusterPCA-', num2str(q));
    [trainPerformance(j), testPerformance(j)] = trainUtility.ValidateTest2(trainData, testData, cvp, 'MClusterPCA', q, pixelNumArray);
end
save(filePath, 'trainPerformance', 'testPerformance');

%%%%%%%%%%%%%%%%%%%%% Autoencoder %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for q = qs
    fprintf('AE: %d \n\n', q);
    j = j + 1;
    methodName{j} = strcat('autoencoder-', num2str(q));
    [trainPerformance(j), testPerformance(j)] = trainUtility.ValidateTest2(trainData, testData, cvp, 'autoencoder', q);
end
save(filePath, 'trainPerformance', 'testPerformance');

%%%%%%%%%%%%%%%%%%%%% Random Forest Importance %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('RFI: \n\n');

for q = qs
    fprintf('RFI: %d \n\n', q);
    j = j + 1;
    methodName{j} = strcat('rfi-', num2str(q));
    [trainPerformance(j), testPerformance(j)] = trainUtility.ValidateTest2(trainData, testData, cvp, 'rfi', q);
end
save(filePath, 'trainPerformance', 'testPerformance');

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

filePath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'),  'results'), 'txt');
load(filePath, 'trainPerformance', 'testPerformance', 'methodName');

diary off


close all; 
plotPath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'),  'trainPerformance'), 'png');
figure(1);
hold on
for i =1:numel(trainPerformance)
    plot(trainPerformance(i).AUCX, trainPerformance(i).AUCY, 'DisplayName', methodName{i});
end
hold off
legend();
xlabel('False positive rate');
ylabel('True positive rate');
ylim([0,1]);
title('Train Performance');
plots.SavePlot(1, plotPath);

plotPath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'),  'testPerformance'), 'png');
figure(2);
hold on
for i =1:numel(trainPerformance)
    plot(testPerformance(i).AUCX, testPerformance(i).AUCY, 'DisplayName', methodName{i});
end
hold off 
legend();
xlabel('False positive rate');
ylabel('True positive rate');
ylim([0,1]);
title('Test Performance');
plots.SavePlot(2, plotPath);
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
