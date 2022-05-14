from random import seed
from datetime import date
from matplotlib.pyplot import title


from tools import hio
import segmentation_models as sm
import tools.hsi_segment_from_sm as segsm
import tools.hsi_segment_from_scratch as segscratch
import tools.from_the_internet as fi


from sklearn.metrics import roc_curve, auc
import numpy as np

WIDTH = 32 #64
HEIGHT = 32 # 64
NUMBER_OF_CLASSES = 1
NUMBER_OF_CHANNELS = 311
NUMBER_OF_EPOCHS = 400 # 200
VALIDATION_FOLDS = 5
BATCH_SIZE = 8


# #### Init 
# hio.show_label_montage('train')
# hio.show_label_montage('test')
# hio.show_label_montage('full')

X_train, X_test, y_train, y_test, names_train, names_test = hio.get_train_test()

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


# model = fi.build_xception_segmentation_model(32, 32, 3)
# folder = str(date.today()) + '_' + 'xception_base' 
# hio.save_model_info(model, folder)

flist = [
    # # failing 
    # 'sm_vgg', 'sm_vgg_pretrained', 
    # 'sm_inception', 'sm_inception_pretrained', 
    # 'sm_efficientnet', 'sm_efficientnet_pretrained', 
    # 'sm_inceptionresnet' , 'sm_inceptionresnet_pretrained'

    # #successful 
    # 'sm_resnet', 'sm_resnet_pretrained',

    # 'cnn3d', 
    'xception3d_max', 'xception3d_mean', 'xception3d2_max', 'xception3d2_mean'
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
    X_train, X_test, y_train, y_test, names_train, names_test = hio.get_train_test()

    [fpr_, tpr_, auc_val_] = calc_plot_roc(model, X_test, y_test, framework, folder)
    fpr.append(fpr_)
    tpr.append(tpr_)
    auc_val.append(auc_val_)

    preds = model.predict(X_test)
    k = 0
    for (hsi, gt, id, pred) in zip(X_test, y_test, names_test, preds):
        iou = sm.metrics.iou_score(gt, pred)
        k += 1 
        hio.visualize(hsi, gt, pred, folder, round(iou.numpy() * 100,2), id)

# ROC AUC comparison 
hio.plot_roc(fpr, tpr, auc_val, flist, None)

