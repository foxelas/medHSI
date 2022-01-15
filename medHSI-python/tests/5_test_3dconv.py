# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""

import sys
import os

import tensorflow_datasets as tfds 
import tensorflow as tf

module_path = os.path.abspath(os.path.join('..'))
if module_path not in sys.path:
    sys.path.append(os.path.join(module_path,"tools"))
import hsi_io as hio
# import hsi_decompositions as dc

read_manually = False
if read_manually:
    conf = hio.parse_config()
    fpath = os.path.join(conf['Directories']['outputDir'], "000-Datasets", "hsi_normalized_full.h5")  

    # f = io.load_from_h5(fpath)

    # sampleIds = [153, 172, 166, 169, 178 , 184]
    # print("Target Sample Images", sampleIds)

    # keepInd = []
    # for keyz, i in zip(list(f.keys()), range(len(list(f.keys())))):
    #     print(f[keyz].shape)
    #     if int(keyz.replace('sample', '')) in sampleIds:
    #         keepInd.append(i)
    #         print("For sample ", int(keyz.replace('sample', '')), " keeping index ", i)
     
    keepInd = [1, 5, 6, 7 ,9, 11]

    dataList = hio.load_dataset(fpath, 'image')

    if not keepInd is None: 
        dataList = [ dataList[i] for i in keepInd] 

    # Prepare input data 
    croppedData = hio.center_crop_list(dataList, 70, 70, True)

    # Prepare labels 
    labelpath = os.path.join(conf['Directories']['outputDir'],  conf['Folder Names']['labelsManual'])
    labelRgb = hio.load_images(labelpath)
    labelImages = hio.get_labels_from_mask(labelRgb)
    croppedLabels = hio.center_crop_list(labelImages)

    from sklearn.model_selection import train_test_split

    X_train, X_test, y_train, y_test = train_test_split(croppedData, croppedLabels, test_size=0.1, random_state=42)
    print("xtrain: ", len(X_train),", xtest: ", len(X_test))

else:
    dataset = tfds.load('pslnormalized')
    
    def load_image(datapoint):
        input_image = datapoint['hsi']
        input_mask = datapoint['tumor']
        
        return input_image, input_mask
  
    train_images = dataset['train'].map(load_image, num_parallel_calls=tf.data.AUTOTUNE)
    test_images = dataset['test'].map(load_image, num_parallel_calls=tf.data.AUTOTUNE)