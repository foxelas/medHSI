config.SetOpt();
config.SetSetting('isTest', false);
config.SetSetting('database', 'psl');

%% Read h5 data
[targetIDs, outRows] = databaseUtility.GetTargetIndexes({'tissue', true}, 'fix');

%%
dirpath = fullfile(config.GetSetting('outputDir'), config.GetSetting('labelsManual'));
dirList = dir(fullfile(dirpath, '*.jpg'));

close all;
maskdir = config.DirMake(config.GetSetting('outputDir'), config.GetSetting('labels'));
applieddir = config.DirMake(config.GetSetting('outputDir'), config.GetSetting('labelsApplied'));
basedir = config.DirMake(config.GetSetting('outputDir'), config.GetSetting('snapshots'), 'normalized');

for i = 1:numel(dirList)
    imBase = im2double(imread(fullfile(basedir, strrep(dirList(i).name, '_manual', ''))));
    imLab = imread(fullfile(dirList(i).folder, dirList(i).name));

    figure(1);
    imshow(imBase);
    figure(2);
    imshow(imLab);
    fgMask = GetFgMaskInternal(imBase);
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

    parts = strsplit(dirList(i).name, '_');
    sampleId = parts{1};
    id = targetIDs(strcmp([outRows.SampleID], sampleId));
    targetName = num2str(id); 
    savename = dataUtility.GetFilename('label', targetName);
    save(savename, 'labelMask');

    config.SetSetting('plotName', fullfile(maskdir, dirList(i).name));
    SavePlot(2);

    config.SetSetting('plotName', fullfile(applieddir, dirList(i).name));
    SavePlot(3);
end
