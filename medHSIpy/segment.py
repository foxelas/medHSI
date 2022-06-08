from random import seed
from datetime import date
from keras import backend


from tools import hio, train_utils, cmdl, xmdl, segsm
import segmentation_models as sm

WIDTH = 32 #64
HEIGHT = 32 # 64
NUMBER_OF_CLASSES = 1
NUMBER_OF_CHANNELS = 311
NUMBER_OF_EPOCHS = 200 # 200
VALIDATION_FOLDS = 5
BATCH_SIZE = 4 #8


# #### Init 
# hio.show_label_montage('train')
# hio.show_label_montage('test')
# hio.show_label_montage('full')

X_train, X_test, y_train, y_test, names_train, names_test = hio.get_train_test()

def get_framework(framework, xtrain, xtest, ytrain, ytest):
    if 'sm' in framework:
        model, history = segsm.fit_sm_model(framework, xtrain, ytrain, xtest, ytest, 
            height=HEIGHT, width=WIDTH, numChannels=NUMBER_OF_CHANNELS, 
            numClasses=NUMBER_OF_CLASSES, numEpochs=NUMBER_OF_EPOCHS)
            
    elif 'cnn3d' in framework:
        model, history = cmdl.get_cnn_model(framework, xtrain, ytrain, xtest, ytest, 
            HEIGHT, WIDTH, NUMBER_OF_CHANNELS, NUMBER_OF_CLASSES, NUMBER_OF_EPOCHS, 
            64, "RMSProp", 0.0001, 0, "BCE+JC")

    else:
        model, history = xmdl.get_xception_model(framework, xtrain, ytrain, xtest, ytest, 
            height=HEIGHT, width=WIDTH,  numChannels=NUMBER_OF_CHANNELS, 
            numClasses=NUMBER_OF_CLASSES, numEpochs=NUMBER_OF_EPOCHS)

    return model, history

flist = [
    # # failing 
    # 'sm_vgg', 'sm_vgg_pretrained', 
    # 'sm_inception', 'sm_inception_pretrained', 
    # 'sm_efficientnet', 'sm_efficientnet_pretrained', 
    # 'sm_inceptionresnet' , 'sm_inceptionresnet_pretrained'

    # #successful 
    #'sm_resnet', 
    
    #'sm_resnet_pretrained',

    'cnn3d', 
    #'cnn3d2'
    #'xception3d5_max', 'xception3d5_mean',
    #'xception3d4_max', 'xception3d4_mean',
    #'xception3d3_max', 'xception3d3_mean',
    #'xception3d_max',  'xception3d_mean', 
    # 'xception3d2_max', 'xception3d2_mean'
 ]

fpr = [] 
tpr = [] 
auc_val = [] 

baseDate = str(date.today())
for framework in flist: 
    backend.clear_session()

    framework = framework + '_' + baseDate 

    print("Running for framework:" + framework)
    model, history = get_framework(framework, X_train, X_test, y_train, y_test)

    folder = framework

    #prepare again in order to avoid pre-processing errors 
    X_train, X_test, y_train, y_test, names_train, names_test = hio.get_train_test()
    [fpr_, tpr_, auc_val_]  = train_utils.save_evaluate_model(model, history.history, framework, folder, X_test, y_test)
    fpr.append(fpr_)
    tpr.append(tpr_)
    auc_val.append(auc_val_)

    preds = model.predict(X_test)
    k = 0
    for (hsi, gt, id, pred) in zip(X_test, y_test, names_test, preds):
        iou = sm.metrics.iou_score(gt, pred)
        k += 1 
        train_utils.visualize(hsi, gt, pred, folder, round(iou.numpy() * 100,2), id)

# ROC AUC comparison 
train_utils.plot_roc(fpr, tpr, auc_val, flist, None)

