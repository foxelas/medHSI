SetOpt();
SetSetting('isTest', false);
SetSetting('database', 'psl');
%% Read h5 data
[targetIDs, outRows] = GetTargetIndexes({'tissue', true},  'fix');

%%
dirpath = fullfile(GetSetting('outputDir'),GetSetting('labelsManual'));
dirList = dir(fullfile(dirpath, '*.jpg'));

close all;
savedir = DirMake(GetSetting('matDir'), strcat(GetSetting('database'), 'Labels\'));
maskdir = DirMake(GetSetting('outputDir'), GetSetting('labels'), '\');
applieddir = DirMake(GetSetting('outputDir'), GetSetting('labelsApplied'), '\');

for i=1:2:numel(dirList)
    imBase = im2double(imread(fullfile(dirList(i).folder, dirList(i).name)));
    imLab = imread(fullfile(dirList(i+1).folder, dirList(i+1).name));

    figure(1);imshow(imBase);
    figure(2);imshow(imLab);
    fgMask = GetFgMask(imBase);
    labelMask =  rgb2gray(imLab) <= 127;
    labelMask = imfill(labelMask, 'holes');
%     se = strel('disk',3);
%     labelMask = imclose(labelMask, se);

    figure(1); imshow(fgMask);
    figure(2); imshow(labelMask); 
    
    labelMask = labelMask & fgMask;
    c = imoverlay(imBase, labelMask, 'c');
    figure(3);imshow(c);
    
    parts = strsplit(dirList(i).name, '_');
    sampleId = parts{1};
    id = targetIDs(strcmp([outRows.SampleID], sampleId));
    savename = fullfile(savedir, strcat(num2str(id), '_label.mat'));
    save(savename, 'labelMask');
    
    SetSetting('plotName', fullfile(maskdir, dirList(i).name));
    SavePlot(2);

    SetSetting('plotName', fullfile(applieddir, dirList(i).name));
    SavePlot(3);
end
