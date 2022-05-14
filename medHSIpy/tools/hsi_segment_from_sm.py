# -*- coding: utf-8 -*

######### From Segment Models #########
import segmentation_models as sm
from keras.layers import Input, Conv2D
from tensorflow.keras.optimizers import Adam, RMSprop
from keras.models import Model

RESNET_BACKBONE = 'resnet34'
INCEPTION_BACKBONE = 'inceptionv3'
INCEPTION_RESNET_BACKBONE = 'inceptionresnetv2'
VGG_BACKBONE = 'vgg19'
EFFICIENTNET_BACKBONE = 'efficientnetb7'

sm.set_framework('tf.keras')
sm.framework()

###################################################################################
def get_sm_preproc_data(x_train_raw, x_test_raw, backbone):
    preprocess_input = sm.get_preprocessing(backbone)

    # preprocess input
    xtrain = preprocess_input(x_train_raw)
    xtest = preprocess_input(x_test_raw)
    return xtrain, xtest

def add_input_layer(backbone, numChannels): 
    base_model = sm.Unet(backbone_name=backbone, encoder_weights='imagenet')

    input = Input(shape=(None, None, numChannels))
    l1 = Conv2D(3, (1, 1))(input) # map N channels data to 3 channels
    output = base_model(l1)

    model = Model(inputs=input, outputs=output, name=base_model.name)
    return model 

def get_target_backbone(backbone):
    if 'inceptionresnet' in backbone:
        target_backbone = INCEPTION_RESNET_BACKBONE
    elif 'resnet' in backbone: 
        target_backbone = RESNET_BACKBONE
    elif 'inception' in backbone:
        target_backbone = INCEPTION_BACKBONE
    elif 'efficientnet' in backbone:
        target_backbone = EFFICIENTNET_BACKBONE
    elif 'vgg' in backbone:
        target_backbone = VGG_BACKBONE
    return target_backbone

def get_sm_model(backbone, height, width, numChannels, numClasses):
    target_backbone = get_target_backbone(backbone)
    if 'pretrained' in backbone: 
        model = add_input_layer(target_backbone, numChannels) 
    else: 
        model = sm.Unet(target_backbone, input_shape=(None, None, numChannels), encoder_weights=None, classes=numClasses)
    return model

def build_sm_model(backbone, x_train_raw, x_test_raw, height, width, numChannels, numClasses):
    target_backbone = get_target_backbone(backbone)
    x_train_preproc, x_test_preproc = get_sm_preproc_data(x_train_raw, x_test_raw, target_backbone)
    model = get_sm_model(backbone, height, width, numChannels, numClasses)

    learing_rate = 0.0001
    # optimizer = Adam() 
    optimizer = RMSprop(learning_rate=learing_rate) # decay=1e-06
    targetLoss = sm.losses.bce_jaccard_loss #categorical_crossentropy'
    metrics = [sm.metrics.iou_score, 'accuracy']
    lossFunName = targetLoss if str(targetLoss) == targetLoss else str(targetLoss._name)
    optSettings = "Compiled with" + "\n" + "Optimizer" + str(optimizer._name) + "\n" + "Learning Rate" + str(learing_rate) + "\n" +  "Loss Function" + lossFunName

    model.compile(
        optimizer = optimizer,  #'rmsprop', 'SGD', 'Adam',
        loss=targetLoss,
        metrics=metrics
        )

    return model, x_train_preproc, x_test_preproc, optSettings

def fit_sm_model(backbone, x_train_raw, ytrain, x_test_raw, ytest, height, width, numChannels, numClasses, numEpochs):

    model, x_train_prep, x_test_prep, optSettings = build_sm_model(backbone, x_train_raw, x_test_raw, height, width, numChannels, numClasses)

    # fit model
    history = model.fit(
    x=x_train_prep,
    y=ytrain,
    batch_size=64,
    epochs=numEpochs,
    validation_data=(x_test_prep, ytest),
    )

    return model, history, optSettings
