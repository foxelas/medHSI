# -*- coding: utf-8 -*-
import os
import matplotlib.pyplot as plt
import numpy as np

if __name__ == "__main__":
    import hsi_utils
else:
    from . import hsi_utils

# Image size should be multiple of 32
DEFAULT_HEIGHT = 64

def load_data():
    conf = hsi_utils.parse_config()
    fpath = os.path.join(conf['Directories']['outputDir'], conf['Folder Names']['datasets'], "hsi_normalized_full.h5")

    dataList, keyList = hsi_utils.load_dataset(fpath, 'image')

    sampleIds = [153, 172, 166, 169, 178, 184]
    print("Target Sample Images", sampleIds)

    keepInd = [keyList.index('sample' + str(id)) for id in sampleIds]
    print(keepInd)

    if not keepInd is None:
        dataList = [ dataList[i] for i in keepInd]

    # Prepare input data
    croppedData = hsi_utils.center_crop_list(dataList, DEFAULT_HEIGHT, DEFAULT_HEIGHT, True)

    # Prepare labels
    labelpath = os.path.join(conf['Directories']['outputDir'],  conf['Folder Names']['labelsManual'])
    labelRgb = hsi_utils.load_label_images(labelpath)

    # for (x,y) in zip(dataList, labelRgb):
    #     if x.shape[0] != y.shape[0] or x.shape[1] != y.shape[1]:
    #         print('Error: images have different size!')
    #         print(x.shape)
    #         print(y.shape)
    #         hsi_utils.show_display_image(x)
    #         plt.imshow(y, cmap='gray')
    #         plt.show()

    labelImages = hsi_utils.get_labels_from_mask(labelRgb)
    croppedLabels = hsi_utils.center_crop_list(labelImages)

    # for (x,y) in zip(croppedData, croppedLabels):
    #     hsi_utils.show_display_image(x)
    #     print(np.max(y), np.min(y))
    #     plt.imshow(y, cmap='gray')
    #     plt.show()

    return croppedData, croppedLabels

def get_train_test(): 
    from sklearn.model_selection import train_test_split

    croppedData, croppedLabels = load_data()

    croppedData = np.array(croppedData, dtype=np.float32)
    croppedLabels = np.array(croppedLabels, dtype=np.float32)
    x_train_raw, x_test_raw, y_train, y_test = train_test_split(croppedData,  croppedLabels, test_size=0.1, random_state=42)
    print('xtrain: ', len(x_train_raw),', xtest: ', len(x_test_raw))

    # for (x,y) in zip(x_train_raw, y_train_raw):
    #     hsi_utils.show_display_image(x)
    #     hsi_utils.show_image(y)

    return x_train_raw, x_test_raw, y_train, y_test


from contextlib import redirect_stdout
from datetime import date

def get_model_filename(model, suffix='', extension='txt'):
    today = date.today()
    model_name = str(today)
    savedir = os.path.join(hsi_utils.conf['Directories']['outputDir'],
        hsi_utils.conf['Folder Names']['pythonTest'])
    filename = os.path.join(savedir, model_name + suffix + '.' + extension)
    return filename

def save_model_summary(model):
    filename = get_model_filename(model, '_modelsummary', 'txt')
    if __name__ != "__main__":
        print("Saved at: ", filename)
    with open(filename, 'w', encoding='utf-8') as f:
        with redirect_stdout(f):
            model.summary()

from keras.utils.vis_utils import plot_model

def save_model_graph(model):
    filename = get_model_filename(model, '_modelgraph', 'png')
    if __name__ != "__main__":
        print("Saved at: ", filename)
    plot_model(model, to_file=filename, show_shapes=True, show_layer_names=True)

def save_model_info(model):
    save_model_summary(model)
    save_model_graph(model)

def show_label_montage(): 
    croppedData, croppedLabels = load_data()
    filename = os.path.join(hsi_utils.conf['Directories']['outputDir'], 'T20211207-python', 'normalized-montage.jpg')
    hsi_utils.show_montage(croppedData, filename, 'srgb')
    filename = os.path.join(hsi_utils.conf['Directories']['outputDir'], 'T20211207-python', 'labels-montage.jpg')
    hsi_utils.show_montage(croppedLabels, filename, 'grey')


def plot_history(history):
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
    plt.imshow(hsi_utils.get_display_image(hsi))

    plt.subplot(1,3,2)
    plt.title("Ground Truth")
    plt.imshow(gt)

    plt.subplot(1,3,3)
    plt.title("Prediction")
    plt.imshow(pred)
    plt.show()