import segmentation_models as sm
from keras.models import Model
from keras import layers, backend

if __name__ == "__main__":
    import hsi_segment_from_sm
else:
    from . import hsi_segment_from_sm

NUMBER_OF_CLASSES = 1
NUMBER_OF_CHANNELS = 311

#########################################EXCEPTION SEGMENTATION  ################################
def get_cnn2d_model(width=64, height=64, depth=NUMBER_OF_CHANNELS):
    num_classes = NUMBER_OF_CLASSES
    inputs = layers.Input((width, height, depth, 1), name='cnn2d')

    ### [First half of the network: downsampling inputs] ###

    # Entry block
    x = layers.Conv2D(32, 3, strides=2, padding="same")(inputs)
    x = layers.BatchNormalization()(x)
    x = layers.Activation("relu")(x)

    previous_block_activation = x  # Set aside residual

    # Blocks 1, 2, 3 are identical apart from the feature depth.
    for filters in [64, 128, 256]:
        x = layers.Activation("relu")(x)
        x = layers.SeparableConv2D(filters, 3, padding="same")(x) #DepthwiseConv3D
        x = layers.BatchNormalization()(x)

        x = layers.Activation("relu")(x)
        x = layers.SeparableConv2D(filters, 3, padding="same")(x)
        x = layers.BatchNormalization()(x)

        x = layers.MaxPooling2D(3, strides=2, padding="same")(x)

        # Project residual
        residual = layers.Conv2D(filters, 1, strides=2, padding="same")(
            previous_block_activation
        )
        x = layers.add([x, residual])  # Add back residual
        previous_block_activation = x  # Set aside next residual

    ### [Second half of the network: upsampling inputs] ###

    for filters in [256, 128, 64, 32]:
        x = layers.Activation("relu")(x)
        x = layers.Conv2DTranspose(filters, 3, padding="same")(x)
        x = layers.BatchNormalization()(x)

        x = layers.Activation("relu")(x)
        x = layers.Conv2DTranspose(filters, 3, padding="same")(x)
        x = layers.BatchNormalization()(x)

        x = layers.UpSampling2D(2)(x)

        # Project residual
        residual = layers.UpSampling2D(2)(previous_block_activation)
        residual = layers.Conv2D(filters, 1, padding="same")(residual)
        x = layers.add([x, residual])  # Add back residual
        previous_block_activation = x  # Set aside next residual

    # Add a per-pixel classification layer
    outputs = layers.Conv2D(num_classes, 3, activation="softmax", padding="same")(x)

    # Define the model
    model = Model(inputs, outputs)
    return model

######################################### CNN3d Classification  ################################

def get_cnn3d_class_model(width=64, height=64, depth=NUMBER_OF_CHANNELS):
    """Build a 3D convolutional neural network model."""

    inputs = layers.Input((width, height, depth, 1))

    x = layers.Conv3D(filters=64, kernel_size=3, activation="relu")(inputs)
    x = layers.MaxPool3D(pool_size=2)(x)
    x = layers.BatchNormalization()(x)

    x = layers.Conv3D(filters=64, kernel_size=3, activation="relu")(x)
    x = layers.MaxPool3D(pool_size=2)(x)
    x = layers.BatchNormalization()(x)

    x = layers.Conv3D(filters=128, kernel_size=3, activation="relu")(x)
    x = layers.MaxPool3D(pool_size=2)(x)
    x = layers.BatchNormalization()(x)

    x = layers.Conv3D(filters=256, kernel_size=3, activation="relu")(x)
    x = layers.MaxPool3D(pool_size=2)(x)
    x = layers.BatchNormalization()(x)

    x = layers.GlobalAveragePooling3D()(x)
    x = layers.Dense(units=512, activation="relu")(x)
    x = layers.Dropout(0.3)(x)

    outputs = layers.Dense(units=1, activation="sigmoid")(x)

    # Define the model.
    model = Model(inputs, outputs, name="3dcnn")
    return model

#########################################EXCEPTION 2D CLASSIFICATION ################################

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
    x_train_preproc, x_test_preproc = hsi_segment_from_sm.get_sm_preproc_data(x_train_raw, x_test_raw, backbone)
    model = build_xception_segmentation_model(width, height)

    model.compile(
    'Adam',
    loss=sm.losses.bce_jaccard_loss,
    metrics=[sm.metrics.iou_score],
    )

    return model, x_train_preproc, x_test_preproc