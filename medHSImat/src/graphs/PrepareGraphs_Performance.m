function [] = PrepareGraphs_Performance()
    filePath = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'),  'lastrun'), 'mat');
    load(filePath);
    
    MakeTable(trainPerformance, filePath);
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
        color = hsv(length(target)+1);
        fig = figure(1);
        hold on 
        for j = 1:length(target)
            xx = xVals{j};
            yy = yVals{j};
            h(j) = plot(xx, yy * 100, '-o', 'DisplayName', dispName{j}, ...
                'LineWidth',2, 'MarkerSize',10, 'Color', color(j+1,:));
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
                strcat('(AUC:', sprintf('%.3f', vals{idx}.AUC) ,')')}, {' '});
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
        legend(h, 'Location', 'southeast', 'FontSize', 15);
%         fig.WindowState = 'maximized';

        plotPath = commonUtility.GetFilename('output', ...
            fullfile(config.GetSetting('SaveFolder'),...
            strcat('auc_', targetMetric, '_', suffix) ), 'png');
        plots.SavePlot(fig, plotPath);
    end 
end
        
end 

function [] = MakeTable(trainPerformance, filePath)

targetMetrics = {'Sensitivity', 'JaccardCoeff'};
% logVal = [];
targets = {trainPerformance};
for ii = 1:length(targetMetrics)
    targetMetric = targetMetrics{ii};
    sprintf('Target Metric: %s\n', targetMetric);
    
    resultStruct = struct('Method', [], 'N', [], 'JacCoef', [], 'Accuracy', [],  ...
        'Sensitivity', [], 'Specificity', [], 'DR', [], 'SVM', []);
    c = 0; 
    for i = 1:length(targets)
    target = targets{i};
        for j = 1:length(target)
            vals = target{j};
            yy = zeros(length(vals), 1);
            for k = 1:length(vals)
                yy(k) = vals{k}.(targetMetric);
            end
            [~, idx] = max(yy);
            selRow = vals{idx};
            c = c + 1;
            resultStruct(c) = struct('Method', selRow.Name, 'N', selRow.Features, ...
                'JacCoef',  sprintf('%.3f (%.2f)', selRow.JaccardCoeff *100, selRow.JaccardCoeffSD*100), ...
                'Accuracy', sprintf('%.3f (%.2f)', selRow.Accuracy *100, selRow.AccuracySD*100),  ...
                'Sensitivity', sprintf('%.3f (%.2f)', selRow.Sensitivity *100, selRow.SensitivitySD*100), ...
                'Specificity', sprintf('%.3f (%.2f)', selRow.Specificity *100, selRow.SpecificitySD*100), ...
                'DR', sprintf('%.3f', selRow.DRTrainTime), 'SVM', sprintf('%.3f', selRow.ModelTrainTime));
   
%             rowText = sprintf('%s & %d & %.3f (%.2f) & %.3f (%.2f) & %.3f (%.2f) & %.3f (%.2f) & %.3f & %.3f\n', selRow.Name, selRow.Features, ...
%             selRow.JaccardCoeff *100, selRow.JaccardCoeffSD*100, selRow.Accuracy*100, selRow.AccuracySD*100, ...
%             selRow.Sensitivity *100, selRow.SensitivitySD*100, selRow.Specificity*100, selRow.SpecificitySD*100, ...
%             selRow.DRTrainTime,selRow.ModelTrainTime);
%             logVal = [logVal, rowText ];
        end
    end
    T = struct2table(resultStruct);
   
    T = renamevars(T, [T.Properties.VariableNames], ...
                 ["Method", "N", "JacCoef* (%%)", "Accuracy* (%%)",  ...
                    "Sensitivity* (%%)", "Specificity* (%%)", "DR $t_{train}$", "SVM $t_{train}$"]);
             
    label = 'tab:validation-results';
    caption = 'Classification Performance after 5-fold Validation';
    notes = {'* Values are reported as MEAN(SD).', 'N denotes the retained number of features. $t_{train}$ denotes the training time.'};
    Ttex = table2latex(T, [], label, caption, [], false, notes, false);
    
    filePath2 = strrep(filePath, 'lastrun.mat', strcat('optimal_', targetMetric, '.txt'));
    writeToFile(filePath2, Ttex);

end

end