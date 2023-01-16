showType = 'merged'; %'denoised', 'preprocessed', 'merged'

config.SetSetting('Dataset', 'split3');
[~, targetIDs] = commonUtility.DatasetInfo();

if strcmpi(showType, 'merged')
    dirs = {'D:\elena\mspi\output\split3\segmentation\KMeans+SAM', ...
        'D:\elena\mspi\output\split3\segmentation\Abundance-8', ...
        'D:\elena\mspi\output\split3\segmentation\Signature', ...
        'D:\elena\mspi\output\split3-test\python-test\sm_resnet_2022-06-17', ...
        'D:\elena\mspi\output\split3-test\python-test\sm_resnet_pretrained_2022-06-17', ...
        'D:\elena\mspi\output\split3-test\python-test\xception3d5_max_2022-06-17', ...
        };
end
saveDir = commonUtility.GetFilename('output', strcat(showType, '\'), '');
folds = 13;


dirNumber = numel(dirs);
names = {'Kmeans+SAM', 'Abundance+SVM', 'Signature+SVM', 'Pretrained-Resnet', 'Custom-Resnet', '3D Xception'};

saveNames = {'1', '2', '3', '4', '5', '6', '7'};
types = [true, true, true, false, false, false, false];
close all;

hasSens = true;
if hasSens
    fprintf('Accuracy & Sensitivity & Specificity & JC & AUC \n');
else
    fprintf('Accuracy & Precision & Recall & JC & AUC \n');
end

for i = 6:dirNumber
    load(fullfile(dirs{i}, '0_performance.mat'))

    if types(i)

        for j = 1:folds
            load(fullfile(dirs{i}, strcat('pred', targetIDs{j}, '.mat')), 'predImg');
            filePath = config.DirMake(fullfile(saveDir, num2str(j), strcat(saveNames{i}, '.mat')));
            figure(2);
            imshow(predImg);
            save(filePath, 'predImg');
            plots.SavePlot(2, strrep(filePath, '.mat', '.png'));
        end

        v = testPerformance;
        fprintf('%s & %.2f & %.2f  & %.2f & %.2f  & %.3f\n', ...
            names{i}, v.Accuracy*100, v.Sensitivity*100, ...
            v.Specificity, v.JaccardCoeff*100, v.AUC);

    else
        for j = 1:folds
            load(fullfile(dirs{i}, strcat('pred', targetIDs{j}, '.mat')), 'predImg');
            filePath = config.DirMake(fullfile(saveDir, num2str(j), strcat(saveNames{i})));
            figure(2);
            imshow(predImg);
            save(filePath, 'predImg');
            plots.SavePlot(2, strrep(filePath, '.mat', '.png'));
        end

        v = testEval;

        sensitivities = v.val_true_positives ./ (v.val_true_positives + v.val_false_negatives);
        specificities = v.val_true_negatives ./ (v.val_true_negatives + v.val_false_positives);

        fprintf('%s & %.2f & %.2f  & %.2f & %.2f  & %.3f\n', ...
            names{i}, v.val_accuracy*100, sensitivities*100, ...
            specificities, v.val_iou_score*100, auc_val_);
    end

end

% for j = 1:folds %numel(targetIDs)
%     filePath = fullfile(saveDir, num2str(j), '0.mat');
%     [hsIm, labelInfo] = hsiUtility.LoadHsiAndLabel(targetIDs{j});
%     predImg = logical(labelInfo.Labels);
%     rgbImg = hsIm.GetDisplayImage();
%     save(filePath, 'predImg');
%     figure(2);
%     imshow(predImg);
%     save(filePath, 'predImg', 'rgbImg');
%     plots.SavePlot(2, strrep(filePath, '.mat', '.png'));
% end

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
