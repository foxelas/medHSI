# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""

import sys
import os

import tensorflow_datasets as tfds
import tensorflow as tf
print(tf.__version__)

import matplotlib.pyplot as plt
import numpy as np

import medHSIpy.tools.hsi_io as hio
# import hsi_decompositions as dc

read_manually = True
if read_manually:
    conf = hio.parse_config()
    fpath = os.path.join(conf['Directories']['outputDir'], conf['Folder Names']['datasets'], "hsi_normalized_full.h5")

    dataList, keyList = hio.load_dataset(fpath, 'image')

    sampleIds = [153, 172, 166, 169, 178, 184]
    print("Target Sample Images", sampleIds)

    keepInd = [keyList.index('sample' + str(id)) for id in sampleIds]
    print(keepInd)

    if not keepInd is None:
        dataList = [ dataList[i] for i in keepInd]

    # Prepare input data
    croppedData = hio.center_crop_list(dataList, 70, 70, True)

    # Prepare labels
    labelpath = os.path.join(conf['Directories']['outputDir'],  conf['Folder Names']['labelsManual'])
    labelRgb = hio.load_label_images(labelpath)

    for (x,y) in zip(dataList, labelRgb):
        if x.shape[0] != y.shape[0] or x.shape[1] != y.shape[1]:
            print('Error: images have different size!')
            print(x.shape)
            print(y.shape)
            hio.show_display_image(x)
            plt.imshow(y, cmap='gray')
            plt.show()

    labelImages = hio.get_labels_from_mask(labelRgb)
    croppedLabels = hio.center_crop_list(labelImages)

    # for (x,y) in zip(croppedData, croppedLabels):
    #     hio.show_display_image(x)
    #     print(np.max(y), np.min(y))
    #     plt.imshow(y, cmap='gray')
    #     plt.show()

    from sklearn.model_selection import train_test_split

    X_train, X_test, y_train, y_test = train_test_split(croppedData, croppedLabels, test_size=0.1, random_state=42)
    print('xtrain: ', len(X_train),', xtest: ', len(X_test))

    for (x,y) in zip(X_train, y_train):
        hio.show_display_image(x)
        hio.show_image(y)
        
else:
    dataset = tfds.load('pslnormalized')

    def load_image(datapoint):
        input_image = datapoint['hsi']
        input_mask = datapoint['tumor']
        v = tf.cast(input_mask, dtype=tf.int8)
        print(type(v))
        #plt.imshow(input_mask.numpy().astype("uint8"))
        print(tf.reduce_max(input_mask))
        print(tf.reduce_min(input_mask))
        return input_image, input_mask

    train_images = dataset['train'].map(load_image, num_parallel_calls=tf.data.AUTOTUNE)
    test_images = dataset['test'].map(load_image, num_parallel_calls=tf.data.AUTOTUNE)

#TRAIN_LENGTH = len(train_images) #info.splits['train'].num_examples
BATCH_SIZE = 64
BUFFER_SIZE = 1000
#STEPS_PER_EPOCH = TRAIN_LENGTH // BATCH_SIZE