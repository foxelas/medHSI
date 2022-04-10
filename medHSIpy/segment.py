from random import seed
from datetime import date
from matplotlib.pyplot import title


from tools import hio
import segmentation_models as sm
import tools.hsi_segment_from_sm as segsm
import tools.hsi_segment_from_scratch as segscratch
from keras import backend 

WIDTH = 32 #64
HEIGHT = 32 # 64
NUMBER_OF_CLASSES = 1
NUMBER_OF_CHANNELS = 311

x_train, x_test, y_train, y_test = hio.get_train_test()

def get_framework(framework, xtrain, xtest, ytrain, ytest):
    if 'sm' in framework:
        if 'vgg' in framework:
            model, x_train_preproc, x_test_preproc = segsm.get_vgg(xtrain, xtest)
        elif 'inception' in framework:
            model, x_train_preproc, x_test_preproc = segsm.get_inception(xtrain, xtest)
        elif 'resnet' in framework:
            model, x_train_preproc, x_test_preproc = segsm.get_resnet(xtrain, xtest)
        elif 'resnet-pretrained' in framework:
            model, x_train_preproc, x_test_preproc = segsm.get_resnet_pretrained(xtrain, xtest)
        elif 'efficientnet' in framework:
            model, x_train_preproc, x_test_preproc = segsm.get_efficientnet_pretrained(xtrain, xtest)
        elif 'xception' in framework: 
            model, x_train_preproc, x_test_preproc = segsm.get_xception_model(xtrain, xtest,height=HEIGHT, width=WIDTH)

        # fit model
        history = model.fit(
        x=x_train_preproc,
        y=ytrain,
        batch_size=64,
        epochs=200,
        validation_data=(x_test_preproc, ytest),
        )

    else:
        backend.clear_session()
        if 'cnn3d_unbalanced' in framework:
            model = segscratch.get_cnn3d_unbalanced_model(height=HEIGHT, width=WIDTH)

        elif 'cnn3d_unbalanced_2' in framework: 
            model = segscratch.get_cnn3d_unbalanced_model_2(height=HEIGHT, width=WIDTH)

        elif 'cnn3d_balanced' in framework:
            model = segscratch.get_cnn3d_balanced_model(height=HEIGHT, width=WIDTH)

        elif 'cnn2d' in framework:
            model = segscratch.get_cnn2d_model(height=HEIGHT, width=WIDTH)

        elif 'simple' in framework: 
            model =  segscratch.get_simple_model(height=HEIGHT, width=WIDTH)

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
        epochs=20,
        validation_data=(xtest, ytest),
        )

    return model, history

# Current frameworks:
# From segmentation_models: 'sm_vgg', 'sm_inception', 'sm_resnet'
# From scratch: 'cnn3d_unbalanced', 'cnn3d_balanced', 'cnn2d'

#flist = [ 'sm_vgg', 'sm_resnet', 'sm_resnet_pretrained', 
# 'sm_inception','cnn3d_balanced', 'cnn3d_unbalanced_2',
#'cnn3d_unbalanced', 'sm_efficientnetb7', 'sm_xception']
backend.clear_session()
flist = ['cnn3d_unbalanced']
for framework in flist: 
    model, history = get_framework(framework, x_train, x_test, y_train, y_test)

    folder = str(date.today()) + '_' + framework 
    hio.save_model_info(model, folder)

    hio.plot_history(history, folder)

    #prepare again in order to avoid pre-processing errors 
    x_train, x_test, y_train, y_test = hio.get_train_test()

    preds = model.predict(x_test)
    for (hsi, gt, pred) in zip(x_test, y_test, preds):
        iou = sm.metrics.iou_score(gt, pred)
        # m = metrics.MeanIoU(num_classes=NUMBER_OF_CLASSES)
        # m.update_state(pred, gt)
        # iou2 = m.result().numpy()
        # print("By sm ", str(iou), " and by keras ", str(iou2))
        hio.visualize(hsi, gt, pred, folder, round(iou.numpy() * 100,2))
        