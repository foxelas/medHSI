database = 'pslRaw-Denoisesmoothen32Augmented'; %'pslRaw32Augmented';
fullDatabase = 'pslRaw';
isAugmented = contains(lower(database), 'augmented');

config.SetSetting('Dataset', database);
dirName = fullfile('python-test', 'validation', 'xception3d_max_2022-06-10\');
baseDir = commonUtility.GetFilename('output', dirName, '');
folderList = dir(baseDir);
folderNames = {folderList([folderList.isdir]).name};
folderNames = folderNames(3:end);
n = 32;

for i = 1:numel(folderNames)
    curDir = fullfile(baseDir, folderNames{i}, 'p_*.mat');
    resultImages = dir(curDir);
    names = {resultImages.name};
    samplesSplits = cellfun(@(x) strsplit(x, {'_'}), names, 'un', 0);
    samples = cellfun(@(x) x{2}, samplesSplits, 'un', 0);
    samples = unique(samples);


    for j = 1:numel(samples)

        config.SetSetting('Dataset', fullDatabase);
        [hsIm, labelInfo] = hsiUtility.LoadHsiAndLabel(strrep(samples{j}, 'sample', ''));
        baseImg = hsIm.GetDisplayImage();
        labelImg = rescale(labelInfo.Labels);

        [d1, d2] = size(labelImg);

        config.SetSetting('Dataset', database);

        img = zeros(d1, d2, 311);
        predImg = zeros(d1, d2);
        borderImg = zeros(d1, d2);

        if isAugmented
            targetSamples = names(contains(names, samples{j}) & contains(names, '_0.'));
        else
            targetSamples = names(contains(names, samples{j}));
        end

        for k = 1:numel(targetSamples)
            id = strrep(targetSamples{k}, 'sample', '');
            id = strrep(id, '.mat', '');
            id = strrep(id, 'p_', '');

            [hsIm, labelInfo] = hsiUtility.LoadHsiAndLabel(id);
            pos = labelInfo.Comment;
            ii = pos(1);
            jj = pos(2);
            a1 = (ii - 1) * n + 1;
            a2 = ii * n;
            b1 = (jj - 1) * n + 1;
            b2 = jj * n;
            img(a1:a2, b1:b2, :) = hsIm.Value;
            load(fullfile(baseDir, folderNames{i}, targetSamples{k}), 'prediction');
            predImg(a1:a2, b1:b2) = imrotate(flip(prediction, 1), -90); %flip(imrotate(prediction, 90), 1);
            borderImg(a1:a1+1, b1:b2) = 1;
            borderImg(a1:a2, b2-1:b2) = 1;
            borderImg(a2-1:a2, b1:b2) = 1;
            borderImg(a1:a2, b1:b1+1) = 1;
        end


        %          rgbImg = zeros(d1, d2, 311);
        %          rgbImg(1:size(pred,1), 1:size(pred,2), :) = img;
        %          rgbImg = GetDisplayImageInternal(rgbImg);

        plotPath1 = fullfile(baseDir, folderNames{i}, strcat(samples{j}, '.png'));
        plots.GroundTruthComparison(1, plotPath1, baseImg, labelImg, predImg);

        plotPath2 = fullfile(baseDir, folderNames{i}, strcat('check_', samples{j}, '.png'));
        plots.PredictionValues(2, plotPath2, predImg, borderImg);

        matPath = fullfile(baseDir, folderNames{i}, strcat('pred', strrep(samples{j}, 'sample', ''), '.mat'));
        save(matPath, 'predImg');
    end
end