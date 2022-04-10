# -*- coding: utf-8 -*

######### From Segment Models #########
import segmentation_models as sm
from keras.layers import Input, Conv2D
from keras.models import Model
from keras import layers, backend


NUMBER_OF_CLASSES = 1
NUMBER_OF_CHANNELS = 311

sm.set_framework('tf.keras')
sm.framework()

def get_sm_preproc_data(x_train_raw, x_test_raw, backbone):
    preprocess_input = sm.get_preprocessing(backbone)

    # preprocess input
    xtrain = preprocess_input(x_train_raw)
    xtest = preprocess_input(x_test_raw)
    return xtrain, xtest

def get_sm_model(backbone):
    # define model
    if backbone == 'resnet34':
        model = sm.Unet(backbone, input_shape=(None, None, NUMBER_OF_CHANNELS), encoder_weights=None, classes=NUMBER_OF_CLASSES)
    
    elif backbone == 'resnet34_pretrained':
        backbone = 'resnet34'
        base_model = sm.Unet(backbone_name=backbone, encoder_weights='imagenet')

        input = Input(shape=(None, None, NUMBER_OF_CHANNELS))
        l1 = Conv2D(3, (1, 1))(input) # map N channels data to 3 channels
        output = base_model(l1)

        model = Model(inputs=input, outputs=output, name=base_model.name)

    elif backbone == 'inceptionresnetv2':
        model = sm.Unet(backbone, input_shape=(None, None, NUMBER_OF_CHANNELS), encoder_weights=None, classes=NUMBER_OF_CLASSES)

    elif backbone == 'vgg19':
        base_model = sm.Unet(backbone_name=backbone, encoder_weights='imagenet')

        input = Input(shape=(None, None, NUMBER_OF_CHANNELS))
        l1 = Conv2D(3, (1, 1))(input) # map N channels data to 3 channels
        output = base_model(l1)

        model = Model(inputs=input, outputs=output, name=base_model.name)

    elif backbone == 'efficientnetb7':
        model = sm.Unet(backbone, input_shape=(None, None, NUMBER_OF_CHANNELS), encoder_weights=None, classes=NUMBER_OF_CLASSES)

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

def get_vgg(x_train_raw, x_test_raw):
    backbone = 'vgg19'
    model, x_train_preproc, x_test_preproc = build_sm_model(backbone, x_train_raw, x_test_raw)
    return model, x_train_preproc, x_test_preproc 

def get_resnet(x_train_raw, x_test_raw):
    backbone = 'resnet34'
    model, x_train_preproc, x_test_preproc = build_sm_model(backbone, x_train_raw, x_test_raw)
    return model, x_train_preproc, x_test_preproc 

def get_inception(x_train_raw, x_test_raw):
    backbone = 'inceptionresnetv2'
    model, x_train_preproc, x_test_preproc = build_sm_model(backbone, x_train_raw, x_test_raw)
    return model, x_train_preproc, x_test_preproc 

def get_resnet_pretrained(x_train_raw, x_test_raw):
    backbone = 'resnet34_pretrained'
    model, x_train_preproc, x_test_preproc = build_sm_model(backbone, x_train_raw, x_test_raw)
    return model, x_train_preproc, x_test_preproc 

def get_efficientnet_pretrained(x_train_raw, x_test_raw):
    backbone = 'efficientnetb7'
    model, x_train_preproc, x_test_preproc = build_sm_model(backbone, x_train_raw, x_test_raw)
    return model, x_train_preproc, x_test_preproc 

###########################################
# creating the Conv-Batch Norm block

def conv_bn(x, filters, kernel_size, strides=1):
    
    x = layers.Conv2D(filters=filters, 
               kernel_size = kernel_size, 
               strides=strides, 
               padding = 'same', 
               use_bias = False)(x)
    x = layers.BatchNormalization()(x)

    return x 

# creating separableConv-Batch Norm block

def sep_bn(x, filters, kernel_size, strides=1):
    
    x = layers.SeparableConv2D(filters=filters, 
                        kernel_size = kernel_size, 
                        strides=strides, 
                        padding = 'same', 
                        use_bias = False)(x)
    x = layers.BatchNormalization()(x)
    return x

# entry flow

def entry_flow(x):
    
    x = conv_bn(x, filters =32, kernel_size =3, strides=2)
    x = layers.ReLU()(x)
    x = conv_bn(x, filters =64, kernel_size =3, strides=1)
    tensor = layers.ReLU()(x)
    
    x = sep_bn(tensor, filters = 128, kernel_size =3)
    x = layers.ReLU()(x)
    x = sep_bn(x, filters = 128, kernel_size =3)
    x = layers.MaxPool2D(pool_size=3, strides=2, padding = 'same')(x)
    
    tensor = conv_bn(tensor, filters=128, kernel_size = 1,strides=2)
    x = layers.Add()([tensor,x])
    
    x = layers.ReLU()(x)
    x = sep_bn(x, filters =256, kernel_size=3)
    x = layers.ReLU()(x)
    x = sep_bn(x, filters =256, kernel_size=3)
    x = layers.MaxPool2D(pool_size=3, strides=2, padding = 'same')(x)
    
    tensor = conv_bn(tensor, filters=256, kernel_size = 1,strides=2)
    x = layers.Add()([tensor,x])
    
    x = layers.ReLU()(x)
    x = sep_bn(x, filters =728, kernel_size=3)
    x = layers.ReLU()(x)
    x = sep_bn(x, filters =728, kernel_size=3)
    x = layers.MaxPool2D(pool_size=3, strides=2, padding = 'same')(x)
    
    tensor = conv_bn(tensor, filters=728, kernel_size = 1,strides=2)
    x = layers.Add()([tensor,x])
    return x

# middle flow

def middle_flow(tensor):
    
    for _ in range(8):
        x = layers.ReLU()(tensor)
        x = sep_bn(x, filters = 728, kernel_size = 3)
        x = layers.ReLU()(x)
        x = sep_bn(x, filters = 728, kernel_size = 3)
        x = layers.ReLU()(x)
        x = sep_bn(x, filters = 728, kernel_size = 3)
        x = layers.ReLU()(x)
        tensor = layers.Add()([tensor,x])
        
    return tensor

# exit flow
def exit_flow(tensor):
    
    x = layers.ReLU()(tensor)
    x = sep_bn(x, filters = 728,  kernel_size=3)
    x = layers.ReLU()(x)
    x = sep_bn(x, filters = 1024,  kernel_size=3)
    x = layers.MaxPool2D(pool_size = 3, strides = 2, padding ='same')(x)
    
    tensor = conv_bn(tensor, filters =1024, kernel_size=1, strides =2)
    x = layers.Add()([tensor,x])
    
    x = sep_bn(x, filters = 1536,  kernel_size=3)
    x = layers.ReLU()(x)
    x = sep_bn(x, filters = 2048,  kernel_size=3)
    x = layers.GlobalAvgPool2D()(x)
    
    x = layers.Dense(units = 1000, activation = 'softmax')(x)
    
    return x

# model code
def build_xception_classification_model(width=64, height=64, depth=3):
    input = layers.Input(shape = (width,height,3))
    x = entry_flow(input)
    x = middle_flow(x)
    output = exit_flow(x)

    model = Model (inputs=input, outputs=output)
    return model

def build_xception_segmentation_model(width=64, height=64, depth=3):
    inputs = layers.Input(shape = (width,height,3), name='input')

    channel_axis = 1 if backend.image_data_format() == 'channels_first' else -1
    x = layers.Conv2D(32, (3, 3),
                    strides=(2, 2),
                    use_bias=False,
                    name='block1_conv1')(input)
    x = layers.BatchNormalization(axis=channel_axis, name='block1_conv1_bn')(x)
    x = layers.Activation('relu', name='block1_conv1_act')(x)
    x = layers.Conv2D(64, (3, 3), use_bias=False, name='block1_conv2')(x)
    x = layers.BatchNormalization(axis=channel_axis, name='block1_conv2_bn')(x)
    x = layers.Activation('relu', name='block1_conv2_act')(x)

    residual = layers.Conv2D(128, (1, 1),
                             strides=(2, 2),
                             padding='same',
                             use_bias=False)(x)
    residual = layers.BatchNormalization(axis=channel_axis)(residual)

    x = layers.SeparableConv2D(128, (3, 3),
                               padding='same',
                               use_bias=False,
                               name='block2_sepconv1')(x)
    x = layers.BatchNormalization(axis=channel_axis, name='block2_sepconv1_bn')(x)
    x = layers.Activation('relu', name='block2_sepconv2_act')(x)
    x = layers.SeparableConv2D(128, (3, 3),
                               padding='same',
                               use_bias=False,
                               name='block2_sepconv2')(x)
    x = layers.BatchNormalization(axis=channel_axis, name='block2_sepconv2_bn')(x)

    x = layers.MaxPooling2D((3, 3),
                            strides=(2, 2),
                            padding='same',
                            name='block2_pool')(x)
    x = layers.add([x, residual])

    residual = layers.Conv2D(256, (1, 1), strides=(2, 2),
                             padding='same', use_bias=False)(x)
    residual = layers.BatchNormalization(axis=channel_axis)(residual)

    x = layers.Activation('relu', name='block3_sepconv1_act')(x)
    x = layers.SeparableConv2D(256, (3, 3),
                               padding='same',
                               use_bias=False,
                               name='block3_sepconv1')(x)
    x = layers.BatchNormalization(axis=channel_axis, name='block3_sepconv1_bn')(x)
    x = layers.Activation('relu', name='block3_sepconv2_act')(x)
    x = layers.SeparableConv2D(256, (3, 3),
                               padding='same',
                               use_bias=False,
                               name='block3_sepconv2')(x)
    x = layers.BatchNormalization(axis=channel_axis, name='block3_sepconv2_bn')(x)

    x = layers.MaxPooling2D((3, 3), strides=(2, 2),
                            padding='same',
                            name='block3_pool')(x)
    x = layers.add([x, residual])

    residual = layers.Conv2D(728, (1, 1),
                             strides=(2, 2),
                             padding='same',
                             use_bias=False)(x)
    residual = layers.BatchNormalization(axis=channel_axis)(residual)

    x = layers.Activation('relu', name='block4_sepconv1_act')(x)
    x = layers.SeparableConv2D(728, (3, 3),
                               padding='same',
                               use_bias=False,
                               name='block4_sepconv1')(x)
    x = layers.BatchNormalization(axis=channel_axis, name='block4_sepconv1_bn')(x)
    x = layers.Activation('relu', name='block4_sepconv2_act')(x)
    x = layers.SeparableConv2D(728, (3, 3),
                               padding='same',
                               use_bias=False,
                               name='block4_sepconv2')(x)
    x = layers.BatchNormalization(axis=channel_axis, name='block4_sepconv2_bn')(x)

    x = layers.MaxPooling2D((3, 3), strides=(2, 2),
                            padding='same',
                            name='block4_pool')(x)
    x = layers.add([x, residual])

    for i in range(8):
        residual = x
        prefix = 'block' + str(i + 5)

        x = layers.Activation('relu', name=prefix + '_sepconv1_act')(x)
        x = layers.SeparableConv2D(728, (3, 3),
                                   padding='same',
                                   use_bias=False,
                                   name=prefix + '_sepconv1')(x)
        x = layers.BatchNormalization(axis=channel_axis,
                                      name=prefix + '_sepconv1_bn')(x)
        x = layers.Activation('relu', name=prefix + '_sepconv2_act')(x)
        x = layers.SeparableConv2D(728, (3, 3),
                                   padding='same',
                                   use_bias=False,
                                   name=prefix + '_sepconv2')(x)
        x = layers.BatchNormalization(axis=channel_axis,
                                      name=prefix + '_sepconv2_bn')(x)
        x = layers.Activation('relu', name=prefix + '_sepconv3_act')(x)
        x = layers.SeparableConv2D(728, (3, 3),
                                   padding='same',
                                   use_bias=False,
                                   name=prefix + '_sepconv3')(x)
        x = layers.BatchNormalization(axis=channel_axis,
                                      name=prefix + '_sepconv3_bn')(x)

        x = layers.add([x, residual])

    residual = layers.Conv2D(1024, (1, 1), strides=(2, 2),
                            padding='same', use_bias=False)(x)
    residual = layers.BatchNormalization(axis=channel_axis)(residual)

    x = layers.Activation('relu', name='block13_sepconv1_act')(x)
    x = layers.SeparableConv2D(728, (3, 3),
                            padding='same',
                            use_bias=False,
                            name='block13_sepconv1')(x)
    x = layers.BatchNormalization(axis=channel_axis, name='block13_sepconv1_bn')(x)
    x = layers.Activation('relu', name='block13_sepconv2_act')(x)
    x = layers.SeparableConv2D(1024, (3, 3),
                            padding='same',
                            use_bias=False,
                            name='block13_sepconv2')(x)
    x = layers.BatchNormalization(axis=channel_axis, name='block13_sepconv2_bn')(x)

    x = layers.MaxPooling2D((3, 3),
                            strides=(2, 2),
                            padding='same',
                            name='block13_pool')(x)
    x = layers.add([x, residual])

    x = layers.SeparableConv2D(1536, (3, 3),
                            padding='same',
                            use_bias=False,
                            name='block14_sepconv1')(x)
    x = layers.BatchNormalization(axis=channel_axis, name='block14_sepconv1_bn')(x)
    x = layers.Activation('relu', name='block14_sepconv1_act')(x)

    x = layers.SeparableConv2D(2048, (3, 3),
                            padding='same',
                            use_bias=False,
                            name='block14_sepconv2')(x)
    x = layers.BatchNormalization(axis=channel_axis, name='block14_sepconv2_bn')(x)
    x = layers.Activation('relu', name='block14_sepconv2_act')(x)

    #if pooling == 'avg':
       # x = layers.GlobalAveragePooling2D()(x)
    #elif pooling == 'max':
    outputs = layers.GlobalMaxPooling2D()(x)

    # Define the model
    model = Model(inputs, outputs)
    return model



def get_xception_model(x_train_raw, x_test_raw, width=64, height=64, depth=3):
    backbone = 'inceptionresnetv2'
    x_train_preproc, x_test_preproc = get_sm_preproc_data(x_train_raw, x_test_raw, backbone)
    model = build_xception_segmentation_model(width, height)

    model.compile(
    'Adam',
    loss=sm.losses.bce_jaccard_loss,
    metrics=[sm.metrics.iou_score],
    )

    return model, x_train_preproc, x_test_preproc

