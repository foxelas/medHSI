%% PENDING FIX 
dirpath = fullfile(config.GetSetting('outputDir'), 'labels-manual');
dirList = dir(fullfile(dirpath, '*.jpg'));

close all;
maskdir = config.DirMake(config.GetSetting('outputDir'), config.GetSetting('labelsFolderName'));
applieddir = config.DirMake(config.GetSetting('outputDir'), config.GetSetting('labelsAppliedFolderName'));

[~, targetIDs] = commonUtility.DatasetInfo();

for i = 1:numel(dirList)

	%% PENDING FIX 
    parts = strsplit(dirList(i).name, '_');
    sampleId = parts{1};
    id = targetIDs(strcmp([outRows.SampleID], sampleId));
	
    targetName = num2str(id);

    hsIm = hsiUtility.LoadHSI(targetName, 'dataset');

    imBase = hsIm.GetDisplayImage();
    imLab = imread(fullfile(dirList(i).folder, dirList(i).name));

    figure(1);
    imshow(imBase);
    figure(2);
    imshow(imLab);
    fgMask = hsIm.FgMask;
    labelMask = rgb2gray(imLab) <= 127;
    labelMask = imfill(labelMask, 'holes');
    %     se = strel('disk',3);
    %     labelMask = imclose(labelMask, se);

    figure(1);
    imshow(fgMask);
    figure(2);
    imshow(labelMask);

    labelMask = labelMask & fgMask;
    c = imoverlay(imBase, labelMask, 'c');
    figure(3);
    imshow(c);

    savename = dataUtility.GetFilename('label', targetName);
    save(savename, 'labelMask');

    config.SetSetting('plotName', fullfile(maskdir, dirList(i).name));
    SavePlot(2);

    config.SetSetting('plotName', fullfile(applieddir, dirList(i).name));
    SavePlot(3);
end
