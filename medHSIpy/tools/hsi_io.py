# -*- coding: utf-8 -*-
import os
import numpy as np

if __name__ == "__main__":
    import hsi_utils
else:
    from . import hsi_utils

# Image size should be multiple of 32
DEFAULT_HEIGHT = 32 #64

def load_data(name = None, fold = None):
    # name options: 'full', 'test', 'train'
    if name == None:
        name = 'full'

    conf = hsi_utils.parse_config()
    outputDir = "/home/nfs/ealoupogianni/mspi/output/"
    datasetName = conf['Data Settings']['Dataset']
    #datasetName = 'pslRaw-Denoisesmoothen32Augmented'
    fileName = 'hsi_'+ datasetName + '_' + name +'.h5'
    folderName = conf['Folder Names']['DatasetsFolderName']

    if fold is None:
        fpath = os.path.join(outputDir, datasetName, folderName, fileName)
    else: 
        fpath = os.path.join(outputDir, datasetName, folderName, str(fold),  fileName)

    print("Read from ", fpath)
    dataList, keyList, labelImages = hsi_utils.load_dataset(fpath, 'image')

    # Prepare input data
    croppedData = hsi_utils.center_crop_list(dataList, DEFAULT_HEIGHT, DEFAULT_HEIGHT, True)

    croppedLabels = hsi_utils.center_crop_list(labelImages, DEFAULT_HEIGHT, DEFAULT_HEIGHT)

    x_raw = np.array(croppedData, dtype=np.float32)
    y = np.array(croppedLabels, dtype=np.float32)

    return x_raw, y, keyList


def get_train_test(fold = None): 
    if fold is None:
        x_train_raw, y_train, names_train = load_data('train')
        x_test_raw, y_test, names_test = load_data('test')
    else:
        x_train_raw, y_train, names_train = load_data('train', fold)
        x_test_raw, y_test, names_test = load_data('test', fold)

    #from sklearn.model_selection import train_test_split
    #x_train_raw, x_test_raw, y_train, y_test = train_test_split(croppedData,  croppedLabels, test_size=0.1, random_state=42)
    #print('xtrain: ', len(x_train_raw),', xtest: ', len(x_test_raw))

    # for (x,y) in zip(x_train_raw, y_train_raw):
    #     hsi_utils.show_display_image(x)
    #     hsi_utils.show_image(y)

    return x_train_raw, x_test_raw, y_train, y_test, names_train, names_test 

def show_label_montage(name = None): 
    croppedData, croppedLabels, keyList = load_data(name)
    filename = os.path.join(hsi_utils.conf['Directories']['OutputDir'], hsi_utils.conf['Data Settings']['Dataset'], 
        hsi_utils.conf['Folder Names']['PythonTestFolderName'], name +'-normalized-montage.jpg')        
    hsi_utils.show_montage(croppedData, filename, 'srgb')
    filename =os.path.join(hsi_utils.conf['Directories']['OutputDir'], hsi_utils.conf['Data Settings']['Dataset'], 
        hsi_utils.conf['Folder Names']['PythonTestFolderName'], name +'-labels-montage.jpg')
    hsi_utils.show_montage(croppedLabels, filename, 'grey')

