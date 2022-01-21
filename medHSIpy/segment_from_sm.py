# -*- coding: utf-8 -*
from random import seed
from tools import hio

######### From Segment Models #########
import segmentation_models as sm
from keras.layers import Input, Conv2D
from keras.models import Model

NUMBER_OF_CLASSES = 1
NUMBER_OF_CHANNELS = 311

sm.set_framework('tf.keras')
sm.framework()

def get_sm_preproc_data(x_train_raw, x_test_raw, backbone):
    preprocess_input = sm.get_preprocessing(backbone)

    # preprocess input
    x_train = preprocess_input(x_train_raw)
    x_test = preprocess_input(x_test_raw)
    return x_train, x_test

def get_sm_model(backbone):
    # define model
    if backbone == 'resnet34':
        model = sm.Unet(backbone, input_shape=(None, None, NUMBER_OF_CHANNELS), encoder_weights=None, classes=NUMBER_OF_CLASSES)

    elif backbone == 'inceptionresnetv2':
        model = sm.Unet(backbone, input_shape=(None, None, NUMBER_OF_CHANNELS), encoder_weights=None, classes=NUMBER_OF_CLASSES)

    elif backbone == 'vgg19':
        base_model = sm.Unet(backbone_name=backbone, encoder_weights='imagenet')

        input = Input(shape=(None, None, NUMBER_OF_CHANNELS))
        l1 = Conv2D(3, (1, 1))(input) # map N channels data to 3 channels
        output = base_model(l1)

        model = Model(inputs=input, outputs=output, name=base_model.name)

    return model

def build_sm_model(backbone, x_train_raw, x_test_raw):
    x_train_preproc, x_test_preproc = get_sm_preproc_data(x_train_raw, x_test_raw, backbone)
    model = get_sm_model(backbone)

    model.compile(
    'Adam',
    loss=sm.losses.bce_jaccard_loss,
    metrics=[sm.metrics.iou_score],
    )

    return model, x_train_preproc, x_test_preproc

def get_vgg(x_train_raw, y_test_raw):
    backbone = 'vgg19'
    model, x_train_preproc, x_test_preproc = build_sm_model(backbone, x_train_raw, y_test_raw)
    return model, x_train_preproc, x_test_preproc 

def get_resnet(x_train_raw, y_test_raw):
    backbone = 'resnet34'
    model, x_train_preproc, x_test_preproc = build_sm_model(backbone, x_train_raw, y_test_raw)
    return model, x_train_preproc, x_test_preproc 

def get_inception(x_train_raw, y_test_raw):
    backbone = 'inceptionresnetv2'
    model, x_train_preproc, x_test_preproc = build_sm_model(backbone, x_train_raw, y_test_raw)
    return model, x_train_preproc, x_test_preproc 

x_train, x_test, y_train, y_test = hio.get_train_test()
model, x_train_preproc, x_test_preproc = get_vgg()
# model, x_train_preproc, x_test_preproc = get_inception()
# model, x_train_preproc, x_test_preproc = get_resnet()

# x_train_raw, x_test_raw, y_train, y_test = hio.get_train_test()

hio.save_model_info(model)

# fit model
history = model.fit(
   x=x_train_preproc,
   y=y_train,
   batch_size=64,
   epochs=200,
   validation_data=(x_test_preproc, y_test),
)

hio.plot_history(history)

preds = model.predict(x_test)
for (hsi, gt, pred) in zip(x_test, y_test, preds):
   hio.visualize(hsi, gt, pred)