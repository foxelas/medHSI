[flag, fileS] = CheckImportData();
hsiUtility.PrepareDataset('pslRaw', {'tissue', true}, true, {'raw', false});

%% split image creation and label creation in two 
%% labelme in Anaconda 
% activate labelme
% cd Desktop\
% Labelme.exe
% labelme_json_to_dataset 263.json -o 263 

hsiUtility.PrepareDataset('pslRaw', {'tissue', true}, true, {'raw', false});
