# -*- coding: utf-8 -*-
import os
import pathlib
import matplotlib.pyplot as plt
import numpy as np
import pickle

if __name__ == "__main__":
    import hsi_utils
else:
    from . import hsi_utils

# Image size should be multiple of 32
DEFAULT_HEIGHT = 32 #64

def load_data():
    conf = hsi_utils.parse_config()
    outputDir = conf['Directories']['OutputDir']
    datasetName = conf['Data Settings']['Dataset']
    fileName = 'hsi_'+ datasetName + '_full' +'.h5'
    folderName = conf['Folder Names']['DatasetsFolderName']
    fpath = os.path.join(outputDir, datasetName, folderName, fileName)
    print("Read from ", fpath)
    dataList, keyList, labelImages = hsi_utils.load_dataset(fpath, 'image')

    # Prepare input data
    croppedData = hsi_utils.center_crop_list(dataList, DEFAULT_HEIGHT, DEFAULT_HEIGHT, True)

    croppedLabels = hsi_utils.center_crop_list(labelImages, DEFAULT_HEIGHT, DEFAULT_HEIGHT)

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

def get_model_filename(suffix='', extension='txt', folder = None):
    model_name = ''

    if folder is None:
        today = date.today()
        model_name = str(today) + '_'
    
    savedir = os.path.join(hsi_utils.conf['Directories']['OutputDir'],
        hsi_utils.conf['Data Settings']['Dataset'], hsi_utils.conf['Folder Names']['PythonTestFolderName'])
    if folder is not None:
        savedir = os.path.join(savedir, folder)

    try: 
        os.mkdir(savedir) 
    except OSError as error: 
        pass

    filename = os.path.join(savedir, model_name + suffix + '.' + extension)
    return filename

def save_model_summary(model, folder = None):
    filename = get_model_filename('modelsummary', 'txt', folder)
    if __name__ != "__main__":
        print("Saved at: ", filename)
    with open(filename, 'w', encoding='utf-8') as f:
        with redirect_stdout(f):
            model.summary()

from keras.utils.vis_utils import plot_model

def save_model_graph(model, folder = None):
    filename = get_model_filename('modelgraph', 'png', folder)
    if __name__ != "__main__":
        print("Saved at: ", filename)
    plot_model(model, to_file=filename, show_shapes=True, show_layer_names=True)

def save_model_info(model, folder = None, optSettings = None):
    save_model_summary(model, folder)
    save_model_graph(model, folder)
    if (optSettings != None): 
        filename = get_model_filename('optimizationSettings', 'txt', folder)
        with open(filename, 'w', encoding='utf-8') as f:
            with redirect_stdout(f):
                print(optSettings)

    filename = get_model_filename('model', 'pkl', folder)
    abspath = pathlib.Path(filename).absolute()
    with open(str(abspath), 'wb') as f:
        pickle.dump(abspath, f)
        
def show_label_montage(): 
    croppedData, croppedLabels = load_data()
    filename = os.path.join(hsi_utils.conf['Directories']['OutputDir'], hsi_utils.conf['Data Settings']['Dataset'], 
        hsi_utils.conf['Folder Names']['PythonTestFolderName'], 'normalized-montage.jpg')        
    hsi_utils.show_montage(croppedData, filename, 'srgb')
    filename =os.path.join(hsi_utils.conf['Directories']['OutputDir'], hsi_utils.conf['Data Settings']['Dataset'], 
        hsi_utils.conf['Folder Names']['PythonTestFolderName'], 'labels-montage.jpg')
    hsi_utils.show_montage(croppedLabels, filename, 'grey')


def plot_history(history, folder = None):
    plt.plot(history.history['loss'])
    plt.plot(history.history['val_loss'])
    plt.title('model loss')
    plt.ylabel('loss')
    plt.xlabel('epoch')
    plt.legend(['train', 'test'], loc='upper left')

    filename = get_model_filename('loss', 'png', folder)
    plt.savefig(filename)

    plt.show()


    plt.plot(history.history['iou_score'])
    plt.plot(history.history['val_iou_score'])
    plt.title('IOU scores')
    plt.ylabel('iou score')
    plt.xlabel('epoch')
    plt.legend(['train', 'test'], loc='upper left')

    filename = get_model_filename('iou_score', 'png', folder)
    plt.savefig(filename)

    plt.show()


def visualize(hsi, gt, pred, folder = None, iou = None, suffix = None):
    plt.subplot(1,3,1)
    plt.title("Original")
    plt.imshow(hsi_utils.get_display_image(hsi))

    plt.subplot(1,3,2)
    plt.title("Ground Truth")
    plt.imshow(gt)

    plt.subplot(1,3,3)
    figTitle = ["Prediction" if iou == None else "Prediction (" + str(iou) + "%)"]
    plt.title(figTitle)
    plt.imshow(pred)

    filename = get_model_filename('visualization'+suffix, 'png', folder)
    plt.savefig(filename)

    #plt.show()

def plot_roc(fpr, tpr, auc_val, model_name, folder):

    fig = plt.figure(2)
    
    plt.clf()
    plt.plot([0, 1], [0, 1], 'k--')
    for (fpr_, tpr_, auc_val_, model_name_) in zip(fpr, tpr, auc_val, model_name):
        plt.plot(fpr_, tpr_, label=model_name_ +' (area = {:.3f})'.format(auc_val_))
    plt.xlabel('False positive rate')
    plt.ylabel('True positive rate')
    plt.title('ROC curve')

    # legend
    plt.legend(bbox_to_anchor=(1.02, 1), loc='upper left')


    filename = get_model_filename('auc', 'png', folder)
    plt.savefig(filename)
    plt.show()

    # Zoom in view of the upper left corner.
    fig = plt.figure(3)

    plt.clf()
    plt.xlim(0, 0.2)
    plt.ylim(0.8, 1)
    plt.plot([0, 1], [0, 1], 'k--')
    for (fpr_, tpr_, auc_val_, model_name_) in zip(fpr, tpr, auc_val, model_name):
         plt.plot(fpr_, tpr_, label=model_name_ +' (area = {:.3f})'.format(auc_val_))
    # plt.plot(fpr_rf, tpr_rf, label='RF (area = {:.3f})'.format(auc_rf))
    plt.xlabel('False positive rate')
    plt.ylabel('True positive rate')
    plt.title('ROC curve (zoomed in at top left)')
    plt.legend(bbox_to_anchor=(1.02, 1), loc='upper left')

    filename = get_model_filename('auc-zoom', 'png', folder)
    plt.savefig(filename)
    plt.show()


#### Init 
show_label_montage()
