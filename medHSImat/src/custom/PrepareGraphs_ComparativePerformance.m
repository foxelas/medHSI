
baseDir = commonUtility.GetFilename('output', 'python-test', '');


n = numel(testPerformance);
target = cell(n, 1);
targetAUC = cell(n, 1);
targetNames = cell(n, 1);

for i = 1:n
    target{i}(1, :) = testPerformance{i}.AUCX;
    target{i}(2, :) = testPerformance{i}.AUCY;
    targetAUC{i} = testPerformance{i}.AUC;
    targetNames{i} = testPerformance{i}.Name;
end

s = numel(target);
baseDir = commonUtility.GetFilename('output', 'python-test', '');
folderList = dir(baseDir);
folderNames = {folderList([folderList.isdir]).name};
folderNames = folderNames(3:end);

for i = 1:numel(folderNames)
    curDir = fullfile(baseDir, folderNames{i}, 'auc.mat');
    if exist(curDir, 'file')
        load(curDir);

        target{s+i}(1, :) = fpr_;
        target{s+i}(2, :) = tpr_;
        targetAUC{s+i} = auc_val_;
        parts = strsplit(folderNames{i}, {'_'});
        targetNames{s+i} = parts{2};
    end

end

Comparative_AUC(target, targetAUC, targetNames);

function Comparative_AUC(target, targetAUC, targetNames)

close all;
fig = figure(1);
c = 0;
h = zeros(length(target), 1);
hold on
for j = 1:length(target)
    if ~isempty(target{j})
        xx = target{j}(1, :);
        yy = target{j}(2, :);
        c = c + 1;
        dispName = strjoin({targetNames{j}, ... %{strcat(vals{idx}.Name, '-', num2str(vals{idx}.Features)), ...
            strcat('(AUC:', sprintf('%.3f', targetAUC{j}), ')')}, {' '});

        h(c) = plot(xx, yy, 'DisplayName', dispName, ...
            'LineWidth', 2);
    end
end
hold off
xlabel('False Positive Rate', 'FontSize', 15);
ylabel('True Positive Rate', 'FontSize', 15);
title('Test Performance', 'FontSize', 15);

xlim([0, 1]);
ylim([0, 1]);
legend(h, 'Location', 'southeast', 'FontSize', 15);
%         fig.WindowState = 'maximized';

plotPath = commonUtility.GetFilename('output', 'comprative_auc', 'png');
plots.SavePlot(fig, plotPath);


end