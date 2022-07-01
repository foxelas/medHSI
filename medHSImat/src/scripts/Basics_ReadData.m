[flag, fileS] = CheckImportData();
hsiUtility.PrepareDataset('pslRaw', {'tissue', true}, true, {'raw', false});

%% split image creation and label creation in two 
%% labelme in Anaconda 
% activate labelme
% cd Desktop\
% Labelme.exe
% labelme_json_to_dataset 263.json -o 263 

hsiUtility.PrepareDataset('pslRaw', {'tissue', true}, true, {'raw', false});


%export 
config.SetSetting('Dataset', 'split3');
hsiUtility.ExportH5Dataset();

%denoise 
Basics_Denoise()

%make 32 patch 
targetDataset = '32';
baseDataset = 'split3-Denoisesmoothen';
Basics_MakeDataset(targetDataset, baseDataset);