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


def get_framework(framework, xtrain, xtest, ytrain, ytest):
    if 'sm' in framework:
        model, history = segsm.fit_sm_model(framework, xtrain, ytrain, xtest, ytest, 
            height=HEIGHT, width=WIDTH, numChannels=NUMBER_OF_CHANNELS, 
            numClasses=NUMBER_OF_CLASSES, numEpochs=NUMBER_OF_EPOCHS)
            
    elif 'cnn3d' in framework:
        model, history = cmdl.get_cnn_model(framework, xtrain, ytrain, xtest, ytest, 
            height=HEIGHT, width=WIDTH,  numChannels=NUMBER_OF_CHANNELS, 
            numClasses=NUMBER_OF_CLASSES, numEpochs=NUMBER_OF_EPOCHS)

    else:
        model, history = xmdl.get_xception_model(framework, xtrain, ytrain, xtest, ytest, 
            height=HEIGHT, width=WIDTH,  numChannels=NUMBER_OF_CHANNELS, 
            numClasses=NUMBER_OF_CLASSES, numEpochs=NUMBER_OF_EPOCHS)

    return model, history

flist = [
    #successful 
    'sm_resnet',  
    #'sm_resnet_pretrained',
 ]


for framework in flist: 

    fpr = [] 
    tpr = [] 
    auc_val = [] 
    trainEval = [] 
    testEval = []
    history = []
    foldNames = [] 

    print("Running for framework:" + framework)

    folds = 13

    for fold in range(1, folds+1):
        backend.clear_session()
        
        X_train, X_test, y_train, y_test, names_train, names_test = hio.get_train_test(fold)

        dictVal = "Fold" + str(fold)

        foldNames.append(dictVal) 

        model, history_ = get_framework(framework, X_train, X_test, y_train, y_test)

        folder = str(date.today()) + '_' + framework + '_' + str(fold)

        #prepare again in order to avoid pre-processing errors 
        X_train, X_test, y_train, y_test, names_train, names_test = hio.get_train_test(fold)

        [fpr_, tpr_, auc_val_, trainEval_, testEval_]  = train_utils.evaluate_model(model, history_, framework, folder, X_test, y_test)
        fpr.append(fpr_)
        tpr.append(tpr_)
        auc_val.append(auc_val_)
        trainEval.append(trainEval_)
        testEval.append(testEval_)
        history.append(history_.history)

        preds = model.predict(X_test)
        k = 0
        for (hsi, gt, id, pred) in zip(X_test, y_test, names_test, preds):
            iou = sm.metrics.iou_score(gt, pred)
            k += 1 
            train_utils.visualize(hsi, gt, pred, folder, round(iou.numpy() * 100,2), id)
    
    folder = str(date.today()) + '_' + framework 
    train_utils.save_evaluate_model_folds(folder, fpr, tpr, auc_val, trainEval, testEval, history)


    # ROC AUC comparison 
    train_utils.plot_roc(fpr, tpr, auc_val, foldNames, None)
