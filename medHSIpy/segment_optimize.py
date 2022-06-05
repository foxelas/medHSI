from random import seed
from datetime import date
from keras import backend


from tools import hio, train_utils, cmdl, xmdl, segsm
import segmentation_models as sm

WIDTH = 32 #64
HEIGHT = 32 # 64
NUMBER_OF_CLASSES = 1
NUMBER_OF_CHANNELS = 311
NUMBER_OF_EPOCHS = 100 # 200
VALIDATION_FOLDS = 5
BATCH_SIZE = 4 #8


# #### Init 
# hio.show_label_montage('train')
# hio.show_label_montage('test')
# hio.show_label_montage('full')


def get_framework(framework, xtrain, xtest, ytrain, ytest, optimizerName, learning_rate, decay, lossFunction):
    if 'sm' in framework:
        model, history = segsm.fit_sm_model(framework, xtrain, ytrain, xtest, ytest, 
            HEIGHT, WIDTH, NUMBER_OF_CHANNELS, NUMBER_OF_CLASSES, NUMBER_OF_EPOCHS, 
            optimizerName, learning_rate, decay, lossFunction)
            
    elif 'cnn3d' in framework:
        model, history = cmdl.get_cnn_model(framework, xtrain, ytrain, xtest, ytest, 
            HEIGHT, WIDTH, NUMBER_OF_CHANNELS, NUMBER_OF_CLASSES, NUMBER_OF_EPOCHS, 
            64, optimizerName, learning_rate, decay, lossFunction)

    else:
        model, history = xmdl.get_xception_model(framework, xtrain, ytrain, xtest, ytest, 
            HEIGHT, WIDTH, NUMBER_OF_CHANNELS, NUMBER_OF_CLASSES, NUMBER_OF_EPOCHS, 
            optimizerName, learning_rate, decay, lossFunction)

    return model, history

flist = [
    #successful 
    #'sm_resnet',  
    #'sm_resnet_pretrained',
    'cnn3d'
 ]


for framework in flist: 
    testEval = []
    print("Running for framework:" + framework)

    learningRates = [0.001, 0.0001, 0.00001, 0.000001]
    exponentialDecay = [0, 1e-5, 1e-6] 
    optimizers = ["RMSProp"] #"Adam"
    lossFunctions = ["BCE", "BCE+JC"]

    X_train, X_test, y_train, y_test, names_train, names_test = hio.get_train_test()

    folder = framework 
    counter = 0 
    for lr in learningRates:
        for ed in exponentialDecay:
            for optz in optimizers:
                for lossFun in lossFunctions:
                    backend.clear_session()
                    counter = counter + 1    

                    model, history_ = get_framework(framework, X_train, X_test, y_train, y_test, optz, lr, ed, lossFun)
                    testEval_ = train_utils.get_eval_metrics_and_settings(history_, True, optz, lr, ed, lossFun)

                    testEval.append(testEval_)

                    train_utils.save_performance(folder, testEval)

print("Finished.")
