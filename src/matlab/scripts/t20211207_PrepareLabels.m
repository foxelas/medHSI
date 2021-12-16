Config.SetOpt();
Config.SetSetting('isTest', false);
Config.SetSetting('database', 'psl');
%% Read h5 data
[targetIDs, outRows] = DB.GetTargetIndexes({'tissue', true},  'fix');

%%
dirpath = fullfile(Config.GetSetting('outputDir'),Config.GetSetting('labelsManual'));
dirList = dir(fullfile(dirpath, '*.jpg'));

close all;
savedir = Config.DirMake(Config.GetSetting('matDir'), strcat(Config.GetSetting('database'), 'Labels\'));
maskdir = Config.DirMake(Config.GetSetting('outputDir'), Config.GetSetting('labels'), '\');
applieddir = Config.DirMake(Config.GetSetting('outputDir'), Config.GetSetting('labelsApplied'), '\');
basedir = Config.DirMake(Config.GetSetting('outputDir'), Config.GetSetting('snapshots'),  'normalized\');

for i=1:numel(dirList)
    imBase = im2double(imread(fullfile(basedir, strrep(dirList(i).name, '_manual', ''))));
    imLab = imread(fullfile(dirList(i).folder, dirList(i).name));

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
    
    Config.SetSetting('plotName', fullfile(maskdir, dirList(i).name));
    SavePlot(2);

    Config.SetSetting('plotName', fullfile(applieddir, dirList(i).name));
    SavePlot(3);
end
