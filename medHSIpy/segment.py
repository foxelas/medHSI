from random import seed
from datetime import date

from tools import hio
import tools.hsi_segment_from_sm as segsm
import tools.hsi_segment_from_scratch as segscratch
from keras import backend

WIDTH = 64
HEIGHT = 64
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
            model = segscratch.get_cnn3d_unbalanced_model()

        elif 'cnn3d_balanced' in framework:
            model = segscratch.get_cnn3d_balanced_model()

        elif 'cnn2d' in framework:
            model = segscratch.get_cnn2d_model()


        model.compile(
            'Adam',
            loss='categorical_crossentropy')

        # fit model
        history = model.fit(
        x=xtrain,
        y=ytrain,
        batch_size=64,
        epochs=200,
        validation_data=(xtest, ytest),
        )

    return model, history

# Current frameworks:
# From segmentation_models: 'sm_vgg', 'sm_inception', 'sm_resnet'
# From scratch: 'cnn3d_unbalanced', 'cnn3d_balanced', 'cnn2d'

framework = 'cnn3d_unbalanced'
model, history = get_framework(framework, x_train, x_test, y_train, y_test)

folder = str(date.today()) + '_' + framework 
hio.save_model_info(model, folder)

hio.plot_history(history, folder)

#prepare again in order to avoid pre-processing errors 
x_train, x_test, y_train, y_test = hio.get_train_test()

preds = model.predict(x_test)
for (hsi, gt, pred) in zip(x_test, y_test, preds):
   hio.visualize(hsi, gt, pred, folder)