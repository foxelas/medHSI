# -*- coding: utf-8 -*-
import asynchat
import os

import matplotlib.pyplot as plt
import numpy as np
import tools.hsi_io as hio
# import medHSIpy.tools.hsi_decompositions as dc

conf = hio.parse_config()
fpath = os.path.join(conf['Directories']['outputDir'], conf['Folder Names']['datasets'], "hsi_normalized_full.h5")

dataList, keyList = hio.load_dataset(fpath, 'image')

sampleIds = [153, 172, 166, 169, 178, 184]
print("Target Sample Images", sampleIds)

keepInd = [keyList.index('sample' + str(id)) for id in sampleIds]
print(keepInd)

if not keepInd is None:
    dataList = [ dataList[i] for i in keepInd]

# Image size should be multiple of 32
imgSize = 64

# Prepare input data
croppedData = hio.center_crop_list(dataList, imgSize, imgSize, True)

# Prepare labels
labelpath = os.path.join(conf['Directories']['outputDir'],  conf['Folder Names']['labelsManual'])
labelRgb = hio.load_label_images(labelpath)

# for (x,y) in zip(dataList, labelRgb):
#     if x.shape[0] != y.shape[0] or x.shape[1] != y.shape[1]:
#         print('Error: images have different size!')
#         print(x.shape)
#         print(y.shape)
#         hio.show_display_image(x)
#         plt.imshow(y, cmap='gray')
#         plt.show()

labelImages = hio.get_labels_from_mask(labelRgb)
croppedLabels = hio.center_crop_list(labelImages)

# for (x,y) in zip(croppedData, croppedLabels):
#     hio.show_display_image(x)
#     print(np.max(y), np.min(y))
#     plt.imshow(y, cmap='gray')
#     plt.show()

from sklearn.model_selection import train_test_split

croppedData = np.array(croppedData, dtype=np.float32)
croppedLabels = np.array(croppedLabels, dtype=np.float32)
x_train_raw, x_test_raw, y_train, y_test = train_test_split(croppedData,  croppedLabels, test_size=0.1, random_state=42)
print('xtrain: ', len(x_train_raw),', xtest: ', len(x_test_raw))

# for (x,y) in zip(x_train_raw, y_train_raw):
#     hio.show_display_image(x)
#     hio.show_image(y)
        
import segmentation_models as sm

sm.set_framework('tf.keras')
sm.framework()

NUMBER_OF_CLASSES = 1
BACKBONE = 'resnet34'
preprocess_input = sm.get_preprocessing(BACKBONE)

# preprocess input
x_train = preprocess_input(x_train_raw)
x_test = preprocess_input(x_test_raw)

# define model
model = sm.Unet(BACKBONE, input_shape=(None, None, 311), encoder_weights=None, classes=NUMBER_OF_CLASSES)
model.compile(
    'Adam',
    loss=sm.losses.bce_jaccard_loss,
    metrics=[sm.metrics.iou_score],
)

# fit model
# if you use data generator use model.fit_generator(...) instead of model.fit(...)
# more about `fit_generator` here: https://keras.io/models/sequential/#fit_generator
history = model.fit(
   x=x_train,
   y=y_train,
   batch_size=64,
   epochs=200,
   validation_data=(x_test, y_test),
)

plt.plot(history.history['loss'])
plt.plot(history.history['val_loss'])
plt.title('model loss')
plt.ylabel('loss')
plt.xlabel('epoch')
plt.legend(['train', 'test'], loc='upper left')
plt.show()

def visualize(hsi, gt, pred):

    plt.subplot(1,3,1)
    plt.title("Original")
    plt.imshow(hio.get_display_image(hsi))

    plt.subplot(1,3,2)
    plt.title("Ground Truth")
    plt.imshow(gt)

    plt.subplot(1,3,3)
    plt.title("Prediction")
    plt.imshow(pred)
    plt.show()

preds = model.predict(x_test)
for (hsi, gt, pred) in zip(x_test, y_test, preds):
    visualize(hsi, gt, pred)

from contextlib import redirect_stdout
from datetime import date

today = date.today()
with open(str(today) + '_modelsummary.txt', 'w', encoding='utf-8') as f:
    with redirect_stdout(f):
        model.summary()
