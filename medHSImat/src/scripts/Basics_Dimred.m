function [trainPerformance, testPerformance, methodName ] = Basics_Dimred()
% filePath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'),  'lastrun'), 'mat');
% load(filePath);
% filePath2 = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'),  'cvpInfo'), 'mat');
% load(filePath2);

experiment = strcat('Dimred', date(), '-rbf-100000-1to3');
Basics_Init(experiment);
config.SetSetting('Dataset', 'pslRaw');

diary log.txt

fprintf('Running for dataset %s\n', config.GetSetting('Dataset'));
dataset = config.GetSetting('Dataset');

%% Read h5 data
folds = 5;
testTargets = {'163', '251', '227'};
dataType = 'hsi';
qs = [5, 10, 20, 50, 100];
ks = 1:length(qs);
j = 0;

[trainData, testData, cvp] = trainUtility.SplitDataset(dataset, folds, testTargets, dataType);
filePath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'),  'lastrun'), 'mat');
save(filePath, '-v7.3');

%%%%%%%%%%%%%%%%%%%%%% Baseline %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('Baseline: %d \n\n', 311);
j = j + 1;
[trainPerformance{j}{1}, testPerformance{j}{1}] = trainUtility.ValidateTest2(trainData, testData, cvp, 'Baseline', 311);
PrepareGraphs_Dimred(trainPerformance, testPerformance);

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
    fprintf('ICA: %d \n\n', q);
    [trainPerformance{j}{k}, testPerformance{j}{k}] = trainUtility.ValidateTest2(trainData, testData, cvp, 'ICA', q);
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
%% Fails because of covarance 
% [valTrain(j, :), valTest(j, :)] = trainUtility.ValidateTest2(trainData, testData, cvp, 'qda', 1);
% save(filePath, 'trainPerformance', 'testPerformance');

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
pixelNumArray = [2, 5, 8, 10];

j = j + 1;
for k = ks
    q = qs(k);
    fprintf('MClusterPCA: %d \n\n', q);
    [trainPerformance{j}{k}, testPerformance{j}{k}] = trainUtility.ValidateTest2(trainData, testData, cvp, 'MClusterPCA', q, pixelNumArray);
end

%%%%%%%%%%%%%%%%%%%%% Autosave %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
save(filePath, 'trainPerformance', 'testPerformance');
PrepareGraphs_Dimred(trainPerformance, testPerformance);

%%%%%%%%%%%%%%%%%%%%% Autoencoder %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
j = j + 1;
for k = ks
    q = qs(k);
    fprintf('Autoencoder: %d \n\n', q);
    [trainPerformance{j}{k}, testPerformance{j}{k}] = trainUtility.ValidateTest2(trainData, testData, cvp, 'Autoencoder', q);
end
save(filePath, 'trainPerformance', 'testPerformance');
PrepareGraphs_Dimred(trainPerformance, testPerformance);

%%%%%%%%%%%%%%%%%%%%% Random Forest Importance %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('RFI: \n\n');

j = j + 1;
for k = ks
    q = qs(k);
    fprintf('RFI: %d \n\n', q);
    [trainPerformance{j}{k}, testPerformance{j}{k}] =trainUtility.ValidateTest2(trainData, testData, cvp, 'RFI', q);
end
save(filePath, 'trainPerformance', 'testPerformance');
PrepareGraphs_Dimred(trainPerformance, testPerformance);

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

diary off
end

%%%%%%%%%%%%%%%%%%%%% Assisting Functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [acc] = critfun(scores, labels)
SVMModel = fitcsvm(scores, labels, 'Standardize', true, 'KernelFunction', 'RBF', ...
    'KernelScale', 'auto');
predlabels = predict(SVMModel, scores);
[acc, ~, ~] = metrics.Evaluations(labels, predlabels);
end

function [] = PrepareGraphs_Dimred(trainPerformance, testPerformance)
    MakeFeatGraphs(trainPerformance, testPerformance);
    MakeBestGraphs(trainPerformance, testPerformance);
end

function [] = MakeFeatGraphs(trainPerformance, testPerformance)

targetMetrics = {'Sensitivity', 'JaccardCoeff'};
targets = {trainPerformance, testPerformance};
for ii = 1:length(targetMetrics)
    targetMetric = targetMetrics{ii};
    for i = 1:length(targets)
    target = targets{i};
        for j = 1:length(target)
            vals = target{j};
            xx = zeros(length(vals), 1);
            yy = zeros(length(vals), 1);
            for k = 1:length(vals)
                xx(k) = vals{k}.Features;
                yy(k) = vals{k}.(targetMetric);
            end
            xVals{j} = xx;
            yVals{j} = yy;
            dispName{j} = vals{1}.Name;
        end

        close all;
        fig = figure(1);
        hold on 
        for j = 1:length(target)
            xx = xVals{j};
            yy = yVals{j};
            h(j) = plot(xx, yy * 100, '-o', 'DisplayName', dispName{j}, ...
                'LineWidth',2, 'MarkerSize',10);
        end 
        hold off 
        xlabel('Number of Dimensions', 'FontSize', 15);
        xlab = strjoin({targetMetric, ' (%)'}, {' '});
        ylabel(xlab, 'FontSize', 15);
        if i == 1
            title('Train Performance', 'FontSize', 15);
            suffix = 'train';
        else
            title('Test Performance', 'FontSize', 15);
            suffix = 'test'; 
        end
        
        xticks([0:20:320]);
        yticks([0:20:100]);
        xlim([0, 315]);
        ylim([0, 100]);
        legend(h, 'Location', 'eastoutside', 'FontSize', 15);
        ax = gca;
        cutout(ax, 100, 300, 10);
        hold on;
        xline(105, '--');
        hold off;
        fig.WindowState = 'maximized';


        plotPath = commonUtility.GetFilename('output', ...
            fullfile(config.GetSetting('SaveFolder'),...
            strcat(targetMetric, '_', suffix) ), 'png');
        plots.SavePlot(fig, plotPath);
    end 
end
        
end 

function [] = MakeBestGraphs(trainPerformance, testPerformance)

targetMetrics = {'Sensitivity', 'JaccardCoeff'};
targets = {trainPerformance, testPerformance};
for ii = 1:length(targetMetrics)
    targetMetric = targetMetrics{ii};
    for i = 1:length(targets)
    target = targets{i};
    targetMetric
    i
        for j = 1:length(target)
            vals = target{j};
            yy = zeros(length(vals), 1);
            for k = 1:length(vals)
                yy(k) = vals{k}.(targetMetric);
            end
            [~, idx] = max(yy);
            
            xVals{j} = vals{idx}.AUCX;
            yVals{j} = vals{idx}.AUCY;
            dispName{j} = strjoin({vals{idx}.Name, ... %{strcat(vals{idx}.Name, '-', num2str(vals{idx}.Features)), ...
                strcat('(AUC:', fprintf('%.3f', vals{idx}.AUC) ,')')}, {' '});
            fprintf('%s\n', strcat(vals{idx}.Name, '-', num2str(vals{idx}.Features)));
        end

        close all;
        fig = figure(1);
        hold on 
        for j = 1:length(target)
            xx = xVals{j};
            yy = yVals{j};
            h(j) = plot(xx, yy, 'DisplayName', dispName{j}, ...
                'LineWidth',2);
        end 
        hold off 
        xlabel('False Positive Rate', 'FontSize', 15);
        ylabel('True Positive Rate', 'FontSize', 15);
        if i == 1
            title('Train Performance', 'FontSize', 15);
            suffix = 'train';
        else
            title('Test Performance', 'FontSize', 15);
            suffix = 'test'; 
        end
        
        xlim([0, 1]);
        ylim([0, 1]);
        legend(h, 'Location', 'eastoutside', 'FontSize', 15);
        fig.WindowState = 'maximized';


        plotPath = commonUtility.GetFilename('output', ...
            fullfile(config.GetSetting('SaveFolder'),...
            strcat('auc_', targetMetric, '_', suffix) ), 'png');
        plots.SavePlot(fig, plotPath);
    end 
end
        
end 
