from random import seed
from datetime import date
from matplotlib.pyplot import title


from tools import hio
import segmentation_models as sm
import tools.hsi_segment_from_sm as segsm
import tools.hsi_segment_from_scratch as segscratch
import tools.from_the_internet as fi
from keras import backend 

from sklearn.metrics import roc_curve, auc
import numpy as np

WIDTH = 32 #64
HEIGHT = 32 # 64
NUMBER_OF_CLASSES = 1
NUMBER_OF_CHANNELS = 311
NUMBER_OF_EPOCHS = 200
BATCH_SIZE = 8

X_train, X_test, y_train, y_test = hio.get_train_test()

def get_framework(framework, xtrain, xtest, ytrain, ytest):
    if 'sm' in framework:
        model, history, optSettings = segsm.fit_sm_model(framework, xtrain, ytrain, xtest, ytest, 
            height=HEIGHT, width=WIDTH, numChannels=NUMBER_OF_CHANNELS, 
            numClasses=NUMBER_OF_CLASSES, numEpochs=NUMBER_OF_EPOCHS)
            
    elif 'cnn3d' == framework:
        model, history, optSettings = segscratch.get_cnn_model(framework, xtrain, ytrain, xtest, ytest, 
            height=HEIGHT, width=WIDTH,  numChannels=NUMBER_OF_CHANNELS, 
            numClasses=NUMBER_OF_CLASSES, numEpochs=NUMBER_OF_EPOCHS, batchSize=64)

    else:
        model, history, optSettings = segscratch.get_xception_model(framework, xtrain, ytrain, xtest, ytest, 
            height=HEIGHT, width=WIDTH,  numChannels=NUMBER_OF_CHANNELS, 
            numClasses=NUMBER_OF_CLASSES, numEpochs=NUMBER_OF_EPOCHS, batchSize=BATCH_SIZE)

    return model, history, optSettings

def calc_plot_roc(model, X_test, y_test, model_name, folder):
    y_scores = model.predict(X_test).ravel()
    y_test = np.reshape(y_test.astype(int), (y_scores.shape[0],  1))

    fpr, tpr, thresholds_keras = roc_curve(y_test, y_scores)
    auc_val = auc(fpr, tpr)

    hio.plot_roc([fpr], [tpr], [auc_val], [model_name], folder)

    return fpr, tpr, auc_val

# Current frameworks:
# From segmentation_models: 'sm_vgg', 'sm_inception', 'sm_resnet', 'sm_efficientnet', 'sm_inceptionresnet'
# From scratch: 'cnn3d_unbalanced', 'cnn3d_balanced', 'cnn2d'

# model = fi.get_cnn2d_model(128, 128, 3)
# folder = str(date.today()) + '_' + 'cnn2d_seg_base' 
# hio.save_model_info(model, folder)

# model = fi.build_xception_classification_model(128, 128, 3)
# folder = str(date.today()) + '_' + 'xception_class_base' 
# hio.save_model_info(model, folder)



# model = fi.build_xception_segmentation_model(32, 32, 3)
# folder = str(date.today()) + '_' + 'xception_base' 
# hio.save_model_info(model, folder)

flist = [
    #'sm_vgg', 'sm_vgg_pretrained', 
    # 'sm_resnet', 'sm_resnet_pretrained',
    # 'sm_inception', 'sm_inception_pretrained', 
    # 'sm_efficientnet', 'sm_efficientnet_pretrained', 
    # 'sm_inceptionresnet' , 'sm_inceptionresnet_pretrained', 
    
    'xception3d_max', 'cnn3d', 'xception3d_mean', 
    #'xception3d2_max', 'xception3d2_mean'
 ]

fpr = [] 
tpr = [] 
auc_val = [] 

for framework in flist: 
    model, history, optSettings = get_framework(framework, X_train, X_test, y_train, y_test)

    folder = str(date.today()) + '_' + framework 
    hio.save_model_info(model, folder, optSettings)

    hio.plot_history(history, folder)

    #prepare again in order to avoid pre-processing errors 
    X_train, X_test, y_train, y_test = hio.get_train_test()

    [fpr_, tpr_, auc_val_] = calc_plot_roc(model, X_test, y_test, framework, folder)
    fpr.append(fpr_)
    tpr.append(tpr_)
    auc_val.append(auc_val_)

    preds = model.predict(X_test)
    k = 0
    for (hsi, gt, pred) in zip(X_test, y_test, preds):
        iou = sm.metrics.iou_score(gt, pred)
        k += 1 
        hio.visualize(hsi, gt, pred, folder, round(iou.numpy() * 100,2), str(k))

# ROC AUC comparison 
hio.plot_roc(fpr, tpr, auc_val, flist, None)

