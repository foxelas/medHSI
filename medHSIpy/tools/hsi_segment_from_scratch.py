# -*- coding: utf-8 -*
from contextlib import redirect_stdout
from keras import layers, backend
from keras.models import Model
from datetime import date


if __name__ == "__main__":
    import hsi_io
else:
    from . import hsi_io


#from tools import dc3d

NUMBER_OF_CLASSES = 1
NUMBER_OF_CHANNELS = 311

######### From scratch ###########
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

def get_cnn3d_unbalanced_model(width=64, height=64, depth=NUMBER_OF_CHANNELS):
    num_classes = NUMBER_OF_CLASSES
    inputs = layers.Input((width, height, depth, 1), name='entry')

    ### [First half of the network: downsampling inputs] ###

    # Entry block
    x = layers.Conv3D(32, (3, 3, 5), strides=2, use_bias=False, padding="same", name='block1_conv1')(inputs)
    x = layers.BatchNormalization()(x)
    x = layers.Activation("relu")(x)

    previous_block_activation = x  # Set aside residual

    # Blocks 1, 2, 3 are identical apart from the feature depth.
    for filters in [64, 128, 256]:
        x = layers.Activation("relu")(x)
        x = layers.Conv3D(filters,  (3, 3, 5), padding="same", groups=filters//2, use_bias=False)(x) #DepthwiseConv3D
        x = layers.Conv3D(filters, (1,1,1), padding="same", use_bias=False)(x)
        x = layers.BatchNormalization()(x)

        x = layers.Activation("relu")(x)
        x = layers.Conv3D(filters,  (3, 3, 5), padding="same", groups=filters//2, use_bias=False)(x) #DepthwiseConv3D
        x = layers.Conv3D(filters, (1,1,1), padding="same", use_bias=False)(x)
        x = layers.BatchNormalization()(x)

        x = layers.MaxPooling3D(3, strides=2, padding="same")(x)

        # Project residual
        residual = layers.Conv3D(filters, (1,1,1), strides=2, padding="same", use_bias=False)(
            previous_block_activation
        )
        x = layers.add([x, residual])  # Add back residual
        previous_block_activation = x  # Set aside next residual

    x = layers.Lambda(lambda y: backend.mean(y, axis=3), 
        #output_shape=(None, 4,4,256),
        name='drop_thrid_dim')(x)

    ### [Second half of the network: upsampling inputs] ###

    for filters in [256, 128, 64, 32]:
        x = layers.Activation("relu")(x)
        x = layers.Conv2DTranspose(filters, 3, padding="same", use_bias=False)(x)
        x = layers.BatchNormalization()(x)

        x = layers.Activation("relu")(x)
        x = layers.Conv2DTranspose(filters, 3, padding="same", use_bias=False)(x)
        x = layers.BatchNormalization()(x)

        x = layers.UpSampling2D(2)(x)

        # Project residual
        if filters == 256:
            previous_block_activation = layers.Lambda(lambda y: backend.mean(y, axis=3), name='resid_drop_thrid_dim')(previous_block_activation)
        #print(x)
        #print(previous_block_activation)

        residual = layers.UpSampling2D(2)(previous_block_activation)
        residual = layers.Conv2D(filters, 1, padding="same")(residual)

        x = layers.add([x, residual])  # Add back residual
        previous_block_activation = x  # Set aside next residual

    # Add a per-pixel classification layer
    outputs = layers.Conv2D(num_classes, 3, activation="sigmoid", padding="same")(x)

    # Define the model
    model = Model(inputs, outputs)
    return model

def get_cnn3d_balanced_model(width=64, height=64, depth=NUMBER_OF_CHANNELS):
    num_classes = NUMBER_OF_CLASSES
    inputs = layers.Input((width, height, depth, 1), name='cnn2d')

    ### [First half of the network: downsampling inputs] ###

    # Entry block
    x = layers.Conv3D(32, 3, strides=2, padding="same")(inputs)
    x = layers.BatchNormalization()(x)
    x = layers.Activation("relu")(x)

    previous_block_activation = x  # Set aside residual

    # Blocks 1, 2, 3 are identical apart from the feature depth.
    for filters in [64, 128, 256]:
        x = layers.Activation("relu")(x)
        x = layers.Conv3D(filters, 3, padding="same", groups=filters//2)(x) #DepthwiseConv3D
        x = layers.Conv3D(filters, (1,1,1), padding="same")(x)
        #x = dc3d.DepthwiseConv3D(3, 2)(x)
        x = layers.BatchNormalization()(x)

        x = layers.Activation("relu")(x)
        x = layers.Conv3D(filters, 3, padding="same", groups=filters//2)(x) #DepthwiseConv3D
        x = layers.Conv3D(filters, (1,1,1), padding="same")(x)
        #x = dc3d.DepthwiseConv3D(3, 2)(x)
        x = layers.BatchNormalization()(x)

        x = layers.MaxPooling3D(3, strides=2, padding="same")(x)

        # Project residual
        residual = layers.Conv3D(filters, 1, strides=2, padding="same")(
            previous_block_activation
        )
        x = layers.add([x, residual])  # Add back residual
        previous_block_activation = x  # Set aside next residual

    ### [Second half of the network: upsampling inputs] ###

    for filters in [256, 128, 64, 32]:
        x = layers.Activation("relu")(x)
        x = layers.Conv3DTranspose(filters, 3, padding="same")(x)
        x = layers.BatchNormalization()(x)

        x = layers.Activation("relu")(x)
        x = layers.Conv3DTranspose(filters, 3, padding="same")(x)
        x = layers.BatchNormalization()(x)

        x = layers.UpSampling3D(2)(x)

        # Project residual
        residual = layers.UpSampling3D(2)(previous_block_activation)
        residual = layers.Conv3D(filters, 1, padding="same")(residual)

        x = layers.add([x, residual])  # Add back residual
        previous_block_activation = x  # Set aside next residual

    # drop spectral dimension layer 
    x = layers.Lambda(lambda y: backend.mean(y, axis=3), 
        name='drop_thrid_dim')(x)

    # Add a per-pixel classification layer
    outputs = layers.Conv2D(num_classes, 3, activation="softmax", padding="same")(x)


    # Define the model
    model = Model(inputs, outputs)
    return model

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

def separable_conv_layer(input, fiters, kernel, blockNum, sepConvNum):
    # x = layers.SeparableConv2D(128, (3, 3),
    #                            padding='same',
    #                            use_bias=False,
    #                            name='block2_sepconv1')
    prefix = 'block' + str(blockNum) + '_sepconv' + str(sepConvNum) 
    x = layers.Conv3D(fiters, kernel, 
                        padding="same", 
                        #groups=input//2, 
                        use_bias = False,  
                        name = prefix + '_a')(input) #DepthwiseConv3D
    #x = layers.Conv3D(fiters, (1,1,1), padding="same", use_bias = False, name = prefix + '_b')(x)

    return x 

def get_cnn3d_unbalanced_model_2(width=64, height=64, depth=NUMBER_OF_CHANNELS):
    num_classes = NUMBER_OF_CLASSES
    channel_axis = -1

    nspace = 3 
    nspect = 5 
    inputs = layers.Input((width, height, depth, 1), name='entry')

    ### [First half of the network: downsampling inputs] ###

    # Entry block
    x = layers.Conv3D(32, (nspace, nspace, nspect), strides=2, use_bias=False, padding="same", name='block1_conv1')(inputs)
    x = layers.BatchNormalization(axis=channel_axis, name='block1_conv1_bn')(x)
    x = layers.Activation("relu", name='block1_conv1_act')(x)

    x = layers.Conv3D(64, (nspace, nspace, nspect), use_bias=False, name='block1_conv2')(x)
    x = layers.BatchNormalization(axis=channel_axis, name='block1_conv2_bn')(x)
    x = layers.Activation('relu', name='block1_conv2_act')(x)


    residual = layers.Conv3D(128, (1, 1, 1),
                             strides=(2, 2),
                             padding='same',
                             use_bias=False)(x)
    residual = layers.BatchNormalization(axis=channel_axis)(residual)
    # block 2
    x = separable_conv_layer(x, 128, (nspace, nspace, nspect), 2, 1)
    x = layers.BatchNormalization(axis=channel_axis, name='block2_sepconv1_bn')(x)
    x = separable_conv_layer(x, 128, (nspace, nspace, nspect), 2, 2)
    x = layers.BatchNormalization(axis=channel_axis, name='block2_sepconv2_bn')(x)

    x = layers.MaxPooling3D((nspace, nspace, nspect),
                            strides=(2, 2, 2),
                            padding='same',
                            name='block2_pool')(x)
    x = layers.add([x, residual])


    residual = layers.Conv3D(256, (1, 1, 1), strides=(2, 2, 2),
                             padding='same', use_bias=False)(x)
    residual = layers.BatchNormalization(axis=channel_axis)(residual)

    #block 3
    x = layers.Activation('relu', name='block3_sepconv1_act')(x)
    x = separable_conv_layer(x, 256, (nspace, nspace, nspect), 3, 1)
    x = layers.BatchNormalization(axis=channel_axis, name='block3_sepconv1_bn')(x)
    x = layers.Activation('relu', name='block3_sepconv2_act')(x)
    x = separable_conv_layer(x, 256, (nspace, nspace, nspect), 3, 2)
    x = layers.BatchNormalization(axis=channel_axis, name='block3_sepconv2_bn')(x)

    x = layers.MaxPooling3D((nspace, nspace, nspect),
                            strides=(2, 2, 2),
                            padding='same',
                            name='block3_pool')(x)
    x = layers.add([x, residual])

    residual = layers.Conv3D(728, (1, 1, 1), strides=(2, 2, 2),
                             padding='same', use_bias=False)(x)
    residual = layers.BatchNormalization(axis=channel_axis)(residual)

    #block 4
    x = layers.Activation('relu', name='block4_sepconv1_act')(x)
    x = separable_conv_layer(x, 728, (nspace, nspace, nspect), 4, 1)
    x = layers.BatchNormalization(axis=channel_axis, name='block4_sepconv1_bn')(x)
    x = layers.Activation('relu', name='block4_sepconv2_act')(x)
    x = separable_conv_layer(x, 728, (nspace, nspace, nspect), 4, 2)
    x = layers.BatchNormalization(axis=channel_axis, name='block4_sepconv2_bn')(x)

    x = layers.MaxPooling3D((nspace, nspace, nspect),
                            strides=(2, 2, 2),
                            padding='same',
                            name='block4_pool')(x)
    x = layers.add([x, residual])

    # adding residuals
    for i in range(8):
        residual = x
        prefix = 'block' + str(i + 5)

        x = layers.Activation('relu', name=prefix + '_sepconv1_act')(x)
        x = separable_conv_layer(x, 728, (nspace, nspace, nspect), i+5, 1)
        x = layers.BatchNormalization(axis=channel_axis, name=prefix +'_sepconv1_bn')(x)
        x = layers.Activation('relu', name=prefix + '_sepconv2_act')(x)
        x = separable_conv_layer(x, 728, (nspace, nspace, nspect), i+5, 2)
        x = layers.BatchNormalization(axis=channel_axis, name=prefix +'_sepconv2_bn')(x)
        x = layers.Activation('relu', name=prefix + '_sepconv3_act')(x)
        x = separable_conv_layer(x, 728, (nspace, nspace, nspect), i+5, 3)
        x = layers.BatchNormalization(axis=channel_axis, name=prefix +'_sepconv3_bn')(x)

        x = layers.add([x, residual])

    residual = layers.Conv3D(1024, (1, 1, 1), strides=(2, 2, 2),
                             padding='same', use_bias=False)(x)
    residual = layers.BatchNormalization(axis=channel_axis)(residual)

    x = layers.Activation('relu', name='block13_sepconv1_act')(x)
    x = separable_conv_layer(x, 728, (nspace, nspace, nspect), 13, 1)
    x = layers.BatchNormalization(axis=channel_axis, name='block13_sepconv1_bn')(x)
    x = layers.Activation('relu', name='block13_sepconv2_act')(x)
    x = separable_conv_layer(x, 1024, (nspace, nspace, nspect), 13, 2)
    x = layers.BatchNormalization(axis=channel_axis, name='block13_sepconv2_bn')(x)

    x = layers.MaxPooling3D((nspace, nspace, nspect),
                            strides=(2, 2, 2),
                            padding='same',
                            name='block13_pool')(x)
    x = layers.add([x, residual])

    x = separable_conv_layer(x, 1536, (nspace, nspace, nspect), 14, 1)
    x = layers.BatchNormalization(axis=channel_axis, name='block14_sepconv1_bn')(x)
    x = layers.Activation('relu', name='block14_sepconv1_act')(x)
    x = separable_conv_layer(x, 2048, (nspace, nspace, nspect), 14, 2)
    x = layers.BatchNormalization(axis=channel_axis, name='block14_sepconv2_bn')(x)
    x = layers.Activation('relu', name='block14_sepconv2_act')(x)

    # Define the model
    model = Model(inputs, x, name='xception')
            
    return model


#backend.clear_session()



