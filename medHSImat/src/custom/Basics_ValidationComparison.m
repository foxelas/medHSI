
showType = 'preprocessed'; %'denoised', 'preprocessed', 'merged'

config.SetSetting('Dataset', 'pslRaw');
[~, targetIDs] = commonUtility.DatasetInfo();

if strcmpi(showType, 'denoised')
    dirs = {'D:\elena\mspi\output\pslRaw-Denoisesmoothen\Framework-LOOCV\optimization-observed\KMeans+SAM\CV'; ...
        'D:\elena\mspi\output\pslRaw-Denoisesmoothen\Framework-LOOCV\optimization-observed\Abundance-8\CV'; ...
        'D:\elena\mspi\output\pslRaw-Denoisesmoothen\Framework-LOOCV\optimization-observed\Signature\CV'; ...
        'D:\elena\mspi\output\pslRaw-Denoisesmoothen32Augmented\python-test\validation\sm_resnet_pretrained_2022-06-09'; ...
        'D:\elena\mspi\output\pslRaw-Denoisesmoothen32Augmented\python-test\validation\sm_resnet_2022-06-09'; ...
        'D:\elena\mspi\output\pslRaw-Denoisesmoothen32Augmented\python-test\validation\cnn3d_2022-06-09'; ...
        'D:\elena\mspi\output\pslRaw-Denoisesmoothen32Augmented\python-test\validation\xception3d_max_2022-06-10'; ...
        };

elseif strcmpi(showType, 'preprocessed')
    %         'D:\elena\mspi\output\pslRaw-Denoisesmoothen32Augmented\python-test\validation\xception3d_max_2022-06-10'; ...
    dirs = {'D:\elena\mspi\output\pslRaw\Framework-LOOCV\KMeans+SAM\CV'; ...
        'D:\elena\mspi\output\pslRaw\Framework-LOOCV\Abundance-8\CV'; ...
        'D:\elena\mspi\output\pslRaw\Framework-LOOCV\Signature\CV'; ...
        'D:\elena\mspi\output\pslRaw32Augmented\python-test\validation\sm_resnet_pretrained_2022-06-11'; ...
        'D:\elena\mspi\output\pslRaw32Augmented\python-test\validation\sm_resnet_2022-06-11'; ...
        'D:\elena\mspi\output\pslRaw32Augmented\python-test\validation\cnn3d_2022-06-12'; ...
        };
elseif strcmpi(showType, 'merged')
    dirs = {'D:\elena\mspi\output\pslRaw\Framework-LOOCV\KMeans+SAM\CV'; ...
        'D:\elena\mspi\output\pslRaw\Framework-LOOCV\Abundance-8\CV'; ...
        'D:\elena\mspi\output\pslRaw\Framework-LOOCV\Signature\CV'; ...
        'D:\elena\mspi\output\pslRaw-Denoisesmoothen32Augmented\python-test\validation\sm_resnet_pretrained_2022-06-09'; ...
        'D:\elena\mspi\output\pslRaw-Denoisesmoothen32Augmented\python-test\validation\sm_resnet_2022-06-09'; ...
        'D:\elena\mspi\output\pslRaw-Denoisesmoothen32Augmented\python-test\validation\cnn3d_2022-06-12'; ...
        'D:\elena\mspi\output\pslRaw-Denoisesmoothen32Augmented\python-test\validation\xception3d_max_2022-06-10'; ...
        };
end
saveDir = strrep(commonUtility.GetFilename('output', strcat(showType, '\'), ''), 'pslRaw', 'Results');
folds = 19;


dirNumber = numel(dirs);
names = {'Kmeans+SAM', 'Abundance+SVM', 'Signature+SVM', 'Pretrained-Resnet', 'Custom-Resnet', '3D CNN', '3D Xception'};

saveNames = {'1', '2', '3', '4', '5', '6', '7'};
types = [true, true, true, false, false, false, false];
close all;

hasSens = true;
if hasSens
    fprintf('Accuracy & Sensitivity & Specificity & JC & AUC \n');
else
    fprintf('Accuracy & Precision & Recall & JC & AUC \n');
end

xVals1 = 1:folds;

hold on
for i = 1:dirNumber
    load(fullfile(dirs{i}, '0_performance.mat'))

    if types(i)

        for j = 1:folds
            load(fullfile(strrep(dirs{i}, '\CV', ''), num2str(j), strcat('pred', '150', '.mat')), 'predImg');
            filePath = config.DirMake(fullfile(saveDir, num2str(j), strcat(saveNames{i}, '.mat')));
            figure(2);
            imshow(predImg);
            save(filePath, 'predImg');
            plots.SavePlot(2, strrep(filePath, '.mat', '.png'));
        end

        v = cell2mat(testPerformance);
        fprintf('%s & %.2f (%.2f) & %.2f (%.2f) & %.2f (%.2f) & %.2f (%.2f) & %.3f\n', ...
            names{i}, mean([v.Accuracy]*100), std([v.Accuracy]*100), mean([v.Sensitivity]*100), std([v.Sensitivity]*100), ...
            mean([v.Specificity]*100), std([v.Specificity]*100), mean([v.JaccardCoeff]*100, 'omitnan'), std([v.JaccardCoeff]*100, 'omitnan'), mean([v.AUC]))
        iouVals1 = [v.JaccardCoeff] * 100;

        figure(1);
        plot(xVals1, iouVals1(1:folds), 'DisplayName', names{i}, 'LineWidth', 2);

    else
        parts = strsplit(dirs{i}, '\');
        folder = parts{end};
        folderparts = strsplit(folder, '_');

        for j = 1:folds
            folder2 = strjoin({folderparts{1:end-1}, num2str(j), folderparts{end}}, '_');
            loadPath = strjoin({parts{1:end}, folder2}, '\');
            load(fullfile(loadPath, strcat('pred', targetIDs{j}, '.mat')), 'predImg');
            filePath = config.DirMake(fullfile(saveDir, num2str(j), strcat(saveNames{i})));
            figure(2);
            imshow(predImg);
            save(filePath, 'predImg');
            plots.SavePlot(2, strrep(filePath, '.mat', '.png'));
        end

        v = cell2mat(testEval);

        iouVals1 = [v.val_iou_score] * 100;
        if length(iouVals1) >= folds
            figure(1);
            plot(xVals1, iouVals1(1:folds), 'DisplayName', names{i}, 'LineWidth', 2);

            auc = mean(auc_val_);

            sensitivities = [v.val_true_positives] ./ ([v.val_true_positives] + [v.val_false_negatives]);
            specificities = [v.val_true_negatives] ./ ([v.val_true_negatives] + [v.val_false_positives]);

            if ~hasSens
                fprintf('%s & %.2f (%.2f) & %.2f (%.2f) & %.2f (%.2f) & %.2f (%.2f) & %.3f\n', ...
                    names{i}, mean([v.val_accuracy])*100, std([v.val_accuracy])*100, mean(sensitivities)*100, std(sensitivities)*100, ...
                    mean(specificities)*100, std(specificities)*100, mean([v.val_iou_score])*100, std([v.val_iou_score])*100, auc);
            else
                fprintf('%s & %.2f (%.2f) & %.2f (%.2f) & %.2f (%.2f) & %.2f (%.2f) & %.3f\n', ...
                    names{i}, mean([v.val_accuracy])*100, std([v.val_accuracy])*100, mean([v.val_precision])*100, std([v.val_precision])*100, ...
                    mean([v.val_recall])*100, std([v.val_recall])*100, mean([v.val_iou_score])*100, std([v.val_iou_score])*100, auc);
            end
        end
    end

end
hold off

figure(1);
legend('FontSize', 15, 'Location', 'eastoutside');
xlabel('Patient Test Fold', 'FontSize', 15);
ylabel('Jaccard Coefficient', 'FontSize', 15);
xlim([1, folds]);
xticks(1:folds);
ylim([0, 100]);
yticks(0:10:100);
set(gcf, 'Position', get(0, 'Screensize'));
plots.SavePlot(1, fullfile(saveDir, 'fold-comparison.png'));


for j = 1:folds %numel(targetIDs)
    filePath = fullfile(saveDir, num2str(j), '0.mat');
    [hsIm, labelInfo] = hsiUtility.LoadHsiAndLabel(targetIDs{j});
    predImg = logical(labelInfo.Labels);
    rgbImg = hsIm.GetDisplayImage();
    save(filePath, 'predImg');
    figure(2);
    imshow(predImg);
    save(filePath, 'predImg', 'rgbImg');
    plots.SavePlot(2, strrep(filePath, '.mat', '.png'));
end

n = dirNumber + 1;
imgs = cell(folds*n);
c = 0;
for j = 1:folds
    for k = 0:(n - 1)
        filePath = fullfile(saveDir, num2str(j), strcat(num2str(k), '.mat'));
        if k == 0
            load(filePath, 'rgbImg');
            c = c + 1;
            imgs{c} = rgbImg;
        end

        load(filePath, 'predImg');
        c = c + 1;
        imgs{c} = predImg;
    end
end

nameTiles = {'RGB', 'Ground Truth', names{1:end}};

rowSplit = 5;
m = n + 1;
figure(3);
tiledlayout(rowSplit, m, 'TileSpacing', 'tight', 'Padding', 'tight');
for j = 1:rowSplit * m
    nexttile
    imshow(imgs{j});
    if j <= m
        title(nameTiles{j}, 'FontSize', 12);
    end
end
set(gcf, 'Position', get(0, 'Screensize'));
plots.SavePlot(3, fullfile(saveDir, 'seg-results1.png'));

figure(4);
tiledlayout(rowSplit, m, 'TileSpacing', 'tight', 'Padding', 'tight');
for j = 1:rowSplit * m
    nexttile
    imshow(imgs{j+rowSplit*m});
    if j <= m
        title(nameTiles{j}, 'FontSize', 12);
    end
end
set(gcf, 'Position', get(0, 'Screensize'));
plots.SavePlot(4, fullfile(saveDir, 'seg-results2.png'));

figure(5);
tiledlayout(rowSplit, m, 'TileSpacing', 'tight', 'Padding', 'tight');
for j = 1:rowSplit * m
    nexttile
    imshow(imgs{j+2*rowSplit*m});
    if j <= m
        title(nameTiles{j}, 'FontSize', 12);
    end
end
set(gcf, 'Position', get(0, 'Screensize'));
plots.SavePlot(5, fullfile(saveDir, 'seg-results3.png'));

figure(6);
tiledlayout(rowSplit, m, 'TileSpacing', 'tight', 'Padding', 'tight');
for j = 1:rowSplit * m
    nexttile
    if j + 3 * rowSplit * m > numel(imgs)
        break;
    end
    imshow(imgs{j+3*rowSplit*m});
    if j <= m
        title(nameTiles{j}, 'FontSize', 12);
    end
end
set(gcf, 'Position', get(0, 'Screensize'));
plots.SavePlot(6, fullfile(saveDir, 'seg-results4.png'));
