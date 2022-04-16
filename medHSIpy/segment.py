from random import seed
from datetime import date
from matplotlib.pyplot import title


from tools import hio
import segmentation_models as sm
import tools.hsi_segment_from_sm as segsm
import tools.hsi_segment_from_scratch as segscratch
from keras import backend 

from sklearn.metrics import roc_curve, auc
import matplotlib.pyplot as plt
import numpy as np

WIDTH = 32 #64
HEIGHT = 32 # 64
NUMBER_OF_CLASSES = 1
NUMBER_OF_CHANNELS = 311
NUMBER_OF_EPOCHS = 200 # 200

X_train, X_test, y_train, y_test = hio.get_train_test()

def get_framework(framework, xtrain, xtest, ytrain, ytest):
    if 'sm' in framework:
        model, history = segsm.fit_sm_model(framework, xtrain, ytrain, xtest, ytest, 
            height=HEIGHT, width=WIDTH, numChannels=NUMBER_OF_CHANNELS, 
            numClasses=NUMBER_OF_CLASSES, numEpochs=NUMBER_OF_EPOCHS)

    else:
        backend.clear_session()
        if 'xception3d_max' in framework:
            model = segscratch.get_xception3d_max(height=HEIGHT, width=WIDTH)

        elif 'xception3d_mean' in framework: 
            model = segscratch.get_xception3d_mean(height=HEIGHT, width=WIDTH)

        elif 'xception3d2_max' in framework:
            model = segscratch.get_xception3d2_max(height=HEIGHT, width=WIDTH)

        elif 'xception3d2_mean' in framework:
            model = segscratch.get_xception3d2_mean(height=HEIGHT, width=WIDTH)

        #adam = Adam(lr=0.001, decay=1e-06)
        model.compile(
            'rmsprop', #'rmsprop', 'SGD', 'Adam',
            #loss='categorical_crossentropy'
            loss=sm.losses.bce_jaccard_loss,
            metrics=[sm.metrics.iou_score]
            )

        # fit model
        history = model.fit(
        x=xtrain,
        y=ytrain,
        batch_size=12,
        epochs=NUMBER_OF_EPOCHS,
        validation_data=(xtest, ytest),
        )

    return model, history

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

backend.clear_session()
flist = ['sm_vgg', 'sm_vgg_pretrained', 
    'sm_resnet', 'sm_resnet_pretrained',
    'sm_inception', 'sm_inception_pretrained', 
    'sm_efficientnet', 'sm_efficientnet_pretrained', 
    'sm_inceptionresnet' , 'sm_inceptionresnet_pretrained', 
    # 'xception3d_max', 'xception3d_mean', 
    # 'xception3d2_max', 'xception3d2_mean'
 ]

fpr = [] 
tpr = [] 
auc_val = [] 

for framework in flist: 
    model, history = get_framework(framework, X_train, X_test, y_train, y_test)

    folder = str(date.today()) + '_' + framework 
    hio.save_model_info(model, folder)

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
