# -*- coding: utf-8 -*
from keras import layers, backend
from keras.models import Model

if __name__ == "__main__":
    import train_utils
else:
    from . import train_utils

N_SPACE = 3
STRIDES_SPACE = 2 
STRIDES_SPECTRUM = 2
DROPOUT_RATE = 0.4

## With filters 128, 256, 728  and spectral_step =15
def get_xception3d_1(dropMiddle, width, height, numChannels, numClasses):
    channel_axis = -1
    depth = numChannels
    spectral_step = 15

    inputs = layers.Input((width, height, depth, 1), name='entry')

    ### [First half of the network: downsampling inputs] ###

    # Entry block
    x = layers.Conv3D(32, (N_SPACE, N_SPACE, spectral_step), strides=(STRIDES_SPACE, STRIDES_SPACE, STRIDES_SPECTRUM), use_bias=False, padding="same", name='block1_conv1')(inputs)
    x = layers.BatchNormalization(axis=channel_axis, name='block1_conv1_bn')(x)
    x = layers.Activation("relu", name='block1_conv1_act')(x)
    x = layers.Dropout(DROPOUT_RATE)(x)

    x = layers.Conv3D(64, (N_SPACE, N_SPACE, spectral_step), use_bias=False, name='block1_conv2')(x)
    x = layers.BatchNormalization(axis=channel_axis, name='block1_conv2_bn')(x)
    x = layers.Activation('relu', name='block1_conv2_act')(x)
    x = layers.Dropout(DROPOUT_RATE)(x)

    previous_block_activation = x  # Set aside residual

    # Blocks 1, 2, 3 are identical apart from the feature depth.
    k = 1
    for filters in  [128, 256, 728]:
        k += 1
        if k > 2:
            x = layers.Activation("relu", name='block'+str(k-1)+'_conv2_act')(x)
        x = layers.Conv3D(filters, (N_SPACE, N_SPACE, spectral_step), padding="same", groups=1, use_bias=False, name='block'+str(k)+'_DepthConv1_a')(x) #DepthwiseConv3D
        x = layers.Conv3D(filters, (1,1,1), padding="same", use_bias=False, name='block'+str(k)+'_DepthConv1_b')(x)
        x = layers.BatchNormalization(axis=channel_axis, name='block'+str(k)+'_DepthConv1_bn')(x)

        x = layers.Activation("relu", name='block'+str(k)+'_conv2_act_mid')(x)
        x = layers.Conv3D(filters, (N_SPACE, N_SPACE, spectral_step), padding="same", groups=1, use_bias=False, name='block'+str(k)+'_DepthConv2_a')(x) #DepthwiseConv3D
        x = layers.Conv3D(filters, (1,1,1), padding="same", use_bias=False, name='block'+str(k)+'_DepthConv2_b')(x)
        x = layers.BatchNormalization(axis=channel_axis, name='block'+str(k)+'_DepthConv2_bn')(x)

        x = layers.MaxPooling3D((N_SPACE, N_SPACE, spectral_step), strides=(STRIDES_SPACE, STRIDES_SPACE, STRIDES_SPECTRUM), 
            padding="same", name='block'+str(k)+'_pool')(x)
        x = layers.Dropout(DROPOUT_RATE*0.6)(x)

        # Project residual
        residual = layers.Conv3D(filters, (1,1,1), strides=(STRIDES_SPACE, STRIDES_SPACE, STRIDES_SPECTRUM), padding="same", use_bias=False, name = 'resid' + str(k) + '_conv3d')(
            previous_block_activation
        )
        x = layers.add([x, residual])  # Add back residual
        previous_block_activation = x  # Set aside next residual

    x = layers.Activation('relu', name='drop_act')(x)

    if 'mean' in dropMiddle:
        x = layers.Lambda(lambda y: backend.mean(y, axis=3), 
            name='drop_spectral_dim')(x)
    elif 'max' in dropMiddle: 
        x = layers.Lambda(lambda y: backend.max(y, axis=3), 
            name='drop_spectral_dim')(x)

    x = layers.BatchNormalization(axis=channel_axis, name='drop_bn')(x)

    # print("Drop dimm interior after")
    # print(x.shape.dims)

    ### [Second half of the network: upsampling inputs] ###

    for filters in [728, 256, 128, 64]:
        k += 1
        x = layers.Activation("relu", name='decoder_block' + str(k)+'_act1')(x)
        x = layers.Conv2DTranspose(filters, 3, padding="same", use_bias=False, name='decoder_block' + str(k)+'_convtrans1')(x)
        x = layers.BatchNormalization(name='decoder_block' + str(k)+'_bn1')(x)

        x = layers.Activation("relu", name='decoder_block' + str(k)+'_act2')(x)
        x = layers.Conv2DTranspose(filters, 3, padding="same", use_bias=False, name='decoder_block' + str(k)+'_convtrans2')(x)
        x = layers.BatchNormalization(name='decoder_block' + str(k)+'_bn2')(x)
        #if filters != 64:
            #x = layers.Dropout(DROPOUT_RATE*0.3)(x)

        x = layers.UpSampling2D(2, name='decoder_block' + str(k)+'_upsampling')(x)

        # Project residual
        if filters == 728:
            if 'mean' in dropMiddle:
                previous_block_activation = layers.Lambda(lambda y: backend.mean(y, axis=3), name='resid_drop_spectral_dim')(previous_block_activation)
            elif 'max' in dropMiddle:
                previous_block_activation = layers.Lambda(lambda y: backend.max(y, axis=3), name='resid_drop_spectral_dim')(previous_block_activation)

        residual = layers.UpSampling2D(2, name='decoder_residual' + str(k)+'_upsampling')(previous_block_activation)
        residual = layers.Conv2D(filters, 1, padding="same",  name='decoder_residual' + str(k)+'_conv')(residual)

        x = layers.add([x, residual], name='decoder_block' + str(k)+'add')  # Add back residual
        previous_block_activation = x  # Set aside next residual

        print("Second to last x")
        print(x.shape.dims)

    # Add a per-pixel classification layer
    outputs = layers.Conv2D(numClasses, 3, activation="sigmoid", padding="same", name ='exit_conv')(x)

    # Define the model
    model = Model(inputs, outputs, name = "xception3D_1")
    return model

## With filters 128, 256  and spectral_step = 15
def get_xception3d_3(dropMiddle, width, height, numChannels, numClasses):
    channel_axis = -1
    depth = numChannels
    spectral_step = 15
    inputs = layers.Input((width, height, depth, 1), name='entry')

    ### [First half of the network: downsampling inputs] ###

    # Entry block
    x = layers.Conv3D(32, (N_SPACE, N_SPACE, spectral_step), strides=(STRIDES_SPACE, STRIDES_SPACE, STRIDES_SPECTRUM), use_bias=False, padding="same", name='block1_conv1')(inputs)
    x = layers.BatchNormalization(axis=channel_axis, name='block1_conv1_bn')(x)
    x = layers.Activation("relu", name='block1_conv1_act')(x)
    x = layers.Dropout(DROPOUT_RATE)(x)

    x = layers.Conv3D(64, (N_SPACE, N_SPACE, spectral_step), use_bias=False, name='block1_conv2')(x)
    x = layers.BatchNormalization(axis=channel_axis, name='block1_conv2_bn')(x)
    x = layers.Activation('relu', name='block1_conv2_act')(x)
    x = layers.Dropout(DROPOUT_RATE)(x)

    previous_block_activation = x  # Set aside residual

    # Blocks 1, 2, 3 are identical apart from the feature depth.
    k = 1
    for filters in  [128, 256]:
        k += 1
        if k > 2:
            x = layers.Activation("relu", name='block'+str(k-1)+'_conv2_act')(x)
        x = layers.Conv3D(filters, (N_SPACE, N_SPACE, spectral_step), padding="same", groups=1, use_bias=False, name='block'+str(k)+'_DepthConv1_a')(x) #DepthwiseConv3D
        x = layers.Conv3D(filters, (1,1,1), padding="same", use_bias=False, name='block'+str(k)+'_DepthConv1_b')(x)
        x = layers.BatchNormalization(axis=channel_axis, name='block'+str(k)+'_DepthConv1_bn')(x)

        x = layers.Activation("relu", name='block'+str(k)+'_conv2_act_mid')(x)
        x = layers.Conv3D(filters, (N_SPACE, N_SPACE, spectral_step), padding="same", groups=1, use_bias=False, name='block'+str(k)+'_DepthConv2_a')(x) #DepthwiseConv3D
        x = layers.Conv3D(filters, (1,1,1), padding="same", use_bias=False, name='block'+str(k)+'_DepthConv2_b')(x)
        x = layers.BatchNormalization(axis=channel_axis, name='block'+str(k)+'_DepthConv2_bn')(x)

        x = layers.MaxPooling3D((N_SPACE, N_SPACE, spectral_step), strides=(STRIDES_SPACE, STRIDES_SPACE, STRIDES_SPECTRUM), 
            padding="same", name='block'+str(k)+'_pool')(x)
        x = layers.Dropout(DROPOUT_RATE)(x)

        # Project residual
        residual = layers.Conv3D(filters, (1,1,1), strides=(STRIDES_SPACE, STRIDES_SPACE, STRIDES_SPECTRUM), padding="same", use_bias=False)(
            previous_block_activation
        )
        x = layers.add([x, residual])  # Add back residual
        previous_block_activation = x  # Set aside next residual

    x = layers.Activation('relu', name='drop_act')(x)

    if 'mean' in dropMiddle:
        x = layers.Lambda(lambda y: backend.mean(y, axis=3), 
            name='drop_spectral_dim')(x)
    elif 'max' in dropMiddle: 
        x = layers.Lambda(lambda y: backend.max(y, axis=3), 
            name='drop_spectral_dim')(x)

    x = layers.BatchNormalization(axis=channel_axis, name='drop_bn')(x)

    # print("Drop dimm interior after")
    # print(x.shape.dims)

    ### [Second half of the network: upsampling inputs] ###

    for filters in [256, 128, 64]:
        k += 1
        x = layers.Activation("relu", name='decoder_block' + str(k)+'_act1')(x)
        x = layers.Conv2DTranspose(filters, 3, padding="same", use_bias=False, name='decoder_block' + str(k)+'_convtrans1')(x)
        x = layers.BatchNormalization(name='decoder_block' + str(k)+'_bn1')(x)

        x = layers.Activation("relu", name='decoder_block' + str(k)+'_act2')(x)
        x = layers.Conv2DTranspose(filters, 3, padding="same", use_bias=False, name='decoder_block' + str(k)+'_convtrans2')(x)
        x = layers.BatchNormalization(name='decoder_block' + str(k)+'_bn2')(x)

        x = layers.UpSampling2D(2, name='decoder_block' + str(k)+'_upsampling')(x)

        # Project residuals
        if filters == 256:
            if 'mean' in dropMiddle:
                previous_block_activation = layers.Lambda(lambda y: backend.mean(y, axis=3), name='resid_drop_spectral_dim')(previous_block_activation)
            elif 'max' in dropMiddle:
                previous_block_activation = layers.Lambda(lambda y: backend.max(y, axis=3), name='resid_drop_spectral_dim')(previous_block_activation)

        residual = layers.UpSampling2D(2, name='decoder_residual' + str(k)+'_upsampling')(previous_block_activation)
        residual = layers.Conv2D(filters, 1, padding="same",  name='decoder_residual' + str(k)+'_conv')(residual)

        x = layers.add([x, residual], name='decoder_block' + str(k)+'add')  # Add back residual
        previous_block_activation = x  # Set aside next residual

        print("Second to last x")
        print(x.shape.dims)

    # Add a per-pixel classification layer
    outputs = layers.Conv2D(numClasses, 3, activation="sigmoid", padding="same", name ='exit_conv')(x)

    # Define the model
    model = Model(inputs, outputs, name = "xception3D_3")
    return model

## With filters 128, 256  and spectral_step = 10,20
def get_xception3d_4(dropMiddle, width, height, numChannels, numClasses):
    channel_axis = -1
    depth = numChannels
    inputs = layers.Input((width, height, depth, 1), name='entry')
    spectral_step1 = 10
    spectral_step2 = 20

    ### [First half of the network: downsampling inputs] ###

    # Entry block
    x = layers.Conv3D(32, (N_SPACE, N_SPACE, spectral_step1), strides=(STRIDES_SPACE, STRIDES_SPACE, STRIDES_SPECTRUM), use_bias=False, padding="same", name='block1_conv1')(inputs)
    x = layers.BatchNormalization(axis=channel_axis, name='block1_conv1_bn')(x)
    x = layers.Activation("relu", name='block1_conv1_act')(x)
    x = layers.Dropout(DROPOUT_RATE)(x)

    x = layers.Conv3D(64, (N_SPACE, N_SPACE, spectral_step1), use_bias=False, name='block1_conv2')(x)
    x = layers.BatchNormalization(axis=channel_axis, name='block1_conv2_bn')(x)
    x = layers.Activation('relu', name='block1_conv2_act')(x)
    x = layers.Dropout(DROPOUT_RATE)(x)

    previous_block_activation = x  # Set aside residual

    # Blocks 1, 2, 3 are identical apart from the feature depth.
    k = 1
    for filters in  [128, 256]:
        k += 1
        if k > 2:
            x = layers.Activation("relu", name='block'+str(k-1)+'_conv2_act')(x)

        x = layers.Conv3D(filters, (N_SPACE, N_SPACE, spectral_step2), padding="same", groups=1, use_bias=False, name='block'+str(k)+'_DepthConv1_a')(x) #DepthwiseConv3D
        x = layers.Conv3D(filters, (1,1,1), padding="same", use_bias=False, name='block'+str(k)+'_DepthConv1_b')(x)
        x = layers.BatchNormalization(axis=channel_axis, name='block'+str(k)+'_DepthConv1_bn')(x)

        x = layers.Activation("relu", name='block'+str(k)+'_conv2_act_mid')(x)
        x = layers.Conv3D(filters, (N_SPACE, N_SPACE, spectral_step2), padding="same", groups=1, use_bias=False, name='block'+str(k)+'_DepthConv2_a')(x) #DepthwiseConv3D
        x = layers.Conv3D(filters, (1,1,1), padding="same", use_bias=False, name='block'+str(k)+'_DepthConv2_b')(x)
        x = layers.BatchNormalization(axis=channel_axis, name='block'+str(k)+'_DepthConv2_bn')(x)

        x = layers.MaxPooling3D((N_SPACE, N_SPACE, spectral_step2), strides=(STRIDES_SPACE, STRIDES_SPACE, STRIDES_SPECTRUM), 
            padding="same", name='block'+str(k)+'_pool')(x)
        x = layers.Dropout(DROPOUT_RATE)(x)

        # Project residual
        residual = layers.Conv3D(filters, (1,1,1), strides=(STRIDES_SPACE, STRIDES_SPACE, STRIDES_SPECTRUM), padding="same", use_bias=False)(
            previous_block_activation
        )
        x = layers.add([x, residual])  # Add back residual
        previous_block_activation = x  # Set aside next residual

    x = layers.Activation('relu', name='drop_act')(x)

    if 'mean' in dropMiddle:
        x = layers.Lambda(lambda y: backend.mean(y, axis=3), 
            name='drop_spectral_dim')(x)
    elif 'max' in dropMiddle: 
        x = layers.Lambda(lambda y: backend.max(y, axis=3), 
            name='drop_spectral_dim')(x)

    x = layers.BatchNormalization(axis=channel_axis, name='drop_bn')(x)

    # print("Drop dimm interior after")
    # print(x.shape.dims)

    ### [Second half of the network: upsampling inputs] ###

    for filters in [256, 128, 64]:
        k += 1
        x = layers.Activation("relu", name='decoder_block' + str(k)+'_act1')(x)
        x = layers.Conv2DTranspose(filters, 3, padding="same", use_bias=False, name='decoder_block' + str(k)+'_convtrans1')(x)
        x = layers.BatchNormalization(name='decoder_block' + str(k)+'_bn1')(x)

        x = layers.Activation("relu", name='decoder_block' + str(k)+'_act2')(x)
        x = layers.Conv2DTranspose(filters, 3, padding="same", use_bias=False, name='decoder_block' + str(k)+'_convtrans2')(x)
        x = layers.BatchNormalization(name='decoder_block' + str(k)+'_bn2')(x)

        x = layers.UpSampling2D(2, name='decoder_block' + str(k)+'_upsampling')(x)

        # Project residuals
        if filters == 256:
            if 'mean' in dropMiddle:
                previous_block_activation = layers.Lambda(lambda y: backend.mean(y, axis=3), name='resid_drop_spectral_dim')(previous_block_activation)
            elif 'max' in dropMiddle:
                previous_block_activation = layers.Lambda(lambda y: backend.max(y, axis=3), name='resid_drop_spectral_dim')(previous_block_activation)

        residual = layers.UpSampling2D(2, name='decoder_residual' + str(k)+'_upsampling')(previous_block_activation)
        residual = layers.Conv2D(filters, 1, padding="same",  name='decoder_residual' + str(k)+'_conv')(residual)

        x = layers.add([x, residual], name='decoder_block' + str(k)+'add')  # Add back residual
        previous_block_activation = x  # Set aside next residual

        print("Second to last x")
        print(x.shape.dims)

    # Add a per-pixel classification layer
    outputs = layers.Conv2D(numClasses, 3, activation="sigmoid", padding="same", name ='exit_conv')(x)

    # Define the model
    model = Model(inputs, outputs, name = "xception3D_4")
    return model

## With filters 128, 256  and spectral_step = 10,20 and 3D dropout
def get_xception3d_5(dropMiddle, width, height, numChannels, numClasses):
    channel_axis = -1
    depth = numChannels
    inputs = layers.Input((width, height, depth, 1), name='entry')
    spectral_step1 = 10
    spectral_step2 = 20

    ### [First half of the network: downsampling inputs] ###

    # Entry block
    x = layers.Conv3D(32, (N_SPACE, N_SPACE, spectral_step1), strides=(STRIDES_SPACE, STRIDES_SPACE, STRIDES_SPECTRUM), use_bias=False, padding="same", name='block1_conv1')(inputs)
    x = layers.BatchNormalization(axis=channel_axis, name='block1_conv1_bn')(x)
    x = layers.Activation("relu", name='block1_conv1_act')(x)
    x = layers.SpatialDropout3D(DROPOUT_RATE)(x)

    x = layers.Conv3D(64, (N_SPACE, N_SPACE, spectral_step1), use_bias=False, name='block1_conv2')(x)
    x = layers.BatchNormalization(axis=channel_axis, name='block1_conv2_bn')(x)
    x = layers.Activation('relu', name='block1_conv2_act')(x)
    x = layers.SpatialDropout3D(DROPOUT_RATE)(x)

    previous_block_activation = x  # Set aside residual

    # Blocks 1, 2, 3 are identical apart from the feature depth.
    k = 1
    for filters in  [128, 256]:
        k += 1
        if k > 2:
            x = layers.Activation("relu", name='block'+str(k-1)+'_conv2_act')(x)
            
        x = layers.Conv3D(filters, (N_SPACE, N_SPACE, spectral_step2), padding="same", groups=1, use_bias=False, name='block'+str(k)+'_DepthConv1_a')(x) #DepthwiseConv3D
        x = layers.Conv3D(filters, (1,1,1), padding="same", use_bias=False, name='block'+str(k)+'_DepthConv1_b')(x)
        x = layers.BatchNormalization(axis=channel_axis, name='block'+str(k)+'_DepthConv1_bn')(x)

        x = layers.Activation("relu", name='block'+str(k)+'_conv2_act_mid')(x)
        x = layers.Conv3D(filters, (N_SPACE, N_SPACE, spectral_step2), padding="same", groups=1, use_bias=False, name='block'+str(k)+'_DepthConv2_a')(x) #DepthwiseConv3D
        x = layers.Conv3D(filters, (1,1,1), padding="same", use_bias=False, name='block'+str(k)+'_DepthConv2_b')(x)
        x = layers.BatchNormalization(axis=channel_axis, name='block'+str(k)+'_DepthConv2_bn')(x)

        x = layers.MaxPooling3D((N_SPACE, N_SPACE, spectral_step2), strides=(STRIDES_SPACE, STRIDES_SPACE, STRIDES_SPECTRUM), 
            padding="same", name='block'+str(k)+'_pool')(x)
        x = layers.SpatialDropout3D(DROPOUT_RATE)(x)

        # Project residual
        residual = layers.Conv3D(filters, (1,1,1), strides=(STRIDES_SPACE, STRIDES_SPACE, STRIDES_SPECTRUM), padding="same", use_bias=False)(
            previous_block_activation
        )
        x = layers.add([x, residual])  # Add back residual
        previous_block_activation = x  # Set aside next residual

    x = layers.Activation('relu', name='drop_act')(x)

    if 'mean' in dropMiddle:
        x = layers.Lambda(lambda y: backend.mean(y, axis=3), 
            name='drop_spectral_dim')(x)
    elif 'max' in dropMiddle: 
        x = layers.Lambda(lambda y: backend.max(y, axis=3), 
            name='drop_spectral_dim')(x)

    x = layers.BatchNormalization(axis=channel_axis, name='drop_bn')(x)

    # print("Drop dimm interior after")
    # print(x.shape.dims)

    ### [Second half of the network: upsampling inputs] ###

    for filters in [256, 128, 64]:
        k += 1
        x = layers.Activation("relu", name='decoder_block' + str(k)+'_act1')(x)
        x = layers.Conv2DTranspose(filters, 3, padding="same", use_bias=False, name='decoder_block' + str(k)+'_convtrans1')(x)
        x = layers.BatchNormalization(name='decoder_block' + str(k)+'_bn1')(x)

        x = layers.Activation("relu", name='decoder_block' + str(k)+'_act2')(x)
        x = layers.Conv2DTranspose(filters, 3, padding="same", use_bias=False, name='decoder_block' + str(k)+'_convtrans2')(x)
        x = layers.BatchNormalization(name='decoder_block' + str(k)+'_bn2')(x)

        x = layers.UpSampling2D(2, name='decoder_block' + str(k)+'_upsampling')(x)
        x = layers.Dropout(DROPOUT_RATE)(x)

        # Project residuals
        if filters == 256:
            if 'mean' in dropMiddle:
                previous_block_activation = layers.Lambda(lambda y: backend.mean(y, axis=3), name='resid_drop_spectral_dim')(previous_block_activation)
            elif 'max' in dropMiddle:
                previous_block_activation = layers.Lambda(lambda y: backend.max(y, axis=3), name='resid_drop_spectral_dim')(previous_block_activation)

        residual = layers.UpSampling2D(2, name='decoder_residual' + str(k)+'_upsampling')(previous_block_activation)
        residual = layers.Conv2D(filters, 1, padding="same",  name='decoder_residual' + str(k)+'_conv')(residual)

        x = layers.add([x, residual], name='decoder_block' + str(k)+'add')  # Add back residual
        previous_block_activation = x  # Set aside next residual

        print("Second to last x")
        print(x.shape.dims)

    # Add a per-pixel classification layer
    outputs = layers.Conv2D(numClasses, 3, activation="sigmoid", padding="same", name ='exit_conv')(x)

    # Define the model
    model = Model(inputs, outputs, name = "xception3D_5")
    return model



def separable_conv_layer(input, fiters, kernel, blockNum, sepConvNum):
    prefix = 'block' + str(blockNum) + '_sepconv' + str(sepConvNum) 
    x = layers.SeparableConv2D(fiters, kernel,
                               padding='same',
                               use_bias=False,
                               name=prefix)(input)
    # x = layers.Conv3D(fiters, kernel, 
    #                     padding="same", 
    #                     #groups=input//2, 
    #                     use_bias = False,  
    #                     name = prefix + '_a')(input) #DepthwiseConv3D
    #x = layers.Conv3D(fiters, (1,1,1), padding="same", use_bias = False, name = prefix + '_b')(x)

    return x 

def get_xception3d_2(dropMiddle, width, height, numChannels, numClasses):
    
    depth = numChannels
    channel_axis = -1
    spectral_step = 15
    inputs = layers.Input((width, height, depth, 1), name='entry')

    ### [First half of the network: downsampling inputs] ###

    # Entry block
    x = layers.Conv3D(32, (N_SPACE, N_SPACE, spectral_step), strides=2, use_bias=False, padding="same", name='block1_conv1')(inputs)
    x = layers.BatchNormalization(axis=channel_axis, name='block1_conv1_bn')(x)
    x = layers.Activation("relu", name='block1_conv1_act')(x)
    x = layers.Dropout(DROPOUT_RATE)(x)

    x = layers.Conv3D(64, (N_SPACE, N_SPACE, spectral_step), use_bias=False, name='block1_conv2')(x)
    x = layers.BatchNormalization(axis=channel_axis, name='block1_conv2_bn')(x)
    x = layers.Activation('relu', name='block1_conv2_act')(x)
    x = layers.Dropout(DROPOUT_RATE)(x)

    previous_block_activation = x  # Set aside residual

    residual = layers.Conv3D(128, (1, 1, 1),
                             strides=(2, 2, 2),
                             padding='same',
                             use_bias=False)(x)
    residual = layers.BatchNormalization(axis=channel_axis)(residual)

    # block 2
    x = separable_conv_layer(x, 128, (N_SPACE, N_SPACE), 2, 1)
    x = layers.BatchNormalization(axis=channel_axis, name='block2_sepconv1_bn')(x)
    x = separable_conv_layer(x, 128, (N_SPACE, N_SPACE), 2, 2)
    x = layers.BatchNormalization(axis=channel_axis, name='block2_sepconv2_bn')(x)

    x = layers.MaxPooling3D((N_SPACE, N_SPACE, spectral_step),
                            strides=(2, 2, 2),
                            padding='same',
                            name='block2_pool')(x)
    x = layers.add([x, residual])

    previous_block_activation = x  # Set aside next residual
    residual = layers.Conv3D(256, (1, 1, 1), strides=(2, 2, 2),
                             padding='same', use_bias=False)(x)
    residual = layers.BatchNormalization(axis=channel_axis)(residual)

    #block 3
    x = layers.Activation('relu', name='block3_sepconv1_act')(x)
    x = separable_conv_layer(x, 256, (N_SPACE, N_SPACE, spectral_step), 3, 1)
    x = layers.BatchNormalization(axis=channel_axis, name='block3_sepconv1_bn')(x)
    x = layers.Activation('relu', name='block3_sepconv2_act')(x)
    x = separable_conv_layer(x, 256, (N_SPACE, N_SPACE, spectral_step), 3, 2)
    x = layers.BatchNormalization(axis=channel_axis, name='block3_sepconv2_bn')(x)

    x = layers.MaxPooling3D((N_SPACE, N_SPACE, spectral_step),
                            strides=(2, 2, 2),
                            padding='same',
                            name='block3_pool')(x)
    x = layers.add([x, residual])
    previous_block_activation = x  # Set aside next residual

    residual = layers.Conv3D(728, (1, 1, 1), strides=(2, 2, 2),
                             padding='same', use_bias=False)(x)
    residual = layers.BatchNormalization(axis=channel_axis)(residual)

    #block 4
    x = layers.Activation('relu', name='block4_sepconv1_act')(x)
    x = separable_conv_layer(x, 728, (N_SPACE, N_SPACE, spectral_step), 4, 1)
    x = layers.BatchNormalization(axis=channel_axis, name='block4_sepconv1_bn')(x)
    x = layers.Activation('relu', name='block4_sepconv2_act')(x)
    x = separable_conv_layer(x, 728, (N_SPACE, N_SPACE, spectral_step), 4, 2)
    x = layers.BatchNormalization(axis=channel_axis, name='block4_sepconv2_bn')(x)

    x = layers.MaxPooling3D((N_SPACE, N_SPACE, spectral_step),
                            strides=(2, 2, 2),
                            padding='same',
                            name='block4_pool')(x)
    x = layers.add([x, residual])
    previous_block_activation = x  # Set aside next residual

    # adding residuals
    for i in range(8):
        residual = x
        prefix = 'block' + str(i + 5)

        x = layers.Activation('relu', name=prefix + '_sepconv1_act')(x)
        x = separable_conv_layer(x, 728, (N_SPACE, N_SPACE, spectral_step), i+5, 1)
        x = layers.BatchNormalization(axis=channel_axis, name=prefix +'_sepconv1_bn')(x)
        x = layers.Activation('relu', name=prefix + '_sepconv2_act')(x)
        x = separable_conv_layer(x, 728, (N_SPACE, N_SPACE, spectral_step), i+5, 2)
        x = layers.BatchNormalization(axis=channel_axis, name=prefix +'_sepconv2_bn')(x)
        x = layers.Activation('relu', name=prefix + '_sepconv3_act')(x)
        x = separable_conv_layer(x, 728, (N_SPACE, N_SPACE, spectral_step), i+5, 3)
        x = layers.BatchNormalization(axis=channel_axis, name=prefix +'_sepconv3_bn')(x)

        x = layers.add([x, residual])

        previous_block_activation = x  # Set aside next residual

    residual = layers.Conv3D(1024, (1, 1, 1), strides=(2, 2, 2),
                             padding='same', use_bias=False)(x)
    residual = layers.BatchNormalization(axis=channel_axis)(residual)

    x = layers.Activation('relu', name='block13_sepconv1_act')(x)
    x = separable_conv_layer(x, 728, (N_SPACE, N_SPACE, spectral_step), 13, 1)
    x = layers.BatchNormalization(axis=channel_axis, name='block13_sepconv1_bn')(x)
    x = layers.Activation('relu', name='block13_sepconv2_act')(x)
    x = separable_conv_layer(x, 1024, (N_SPACE, N_SPACE, spectral_step), 13, 2)
    x = layers.BatchNormalization(axis=channel_axis, name='block13_sepconv2_bn')(x)

    x = layers.MaxPooling3D((N_SPACE, N_SPACE, spectral_step),
                            strides=(2, 2, 2),
                            padding='same',
                            name='block13_pool')(x)
    x = layers.add([x, residual])
    previous_block_activation = x  # Set aside next residual

    x = separable_conv_layer(x, 1536, (N_SPACE, N_SPACE, spectral_step), 14, 1)
    x = layers.BatchNormalization(axis=channel_axis, name='block14_sepconv1_bn')(x)
    x = layers.Activation('relu', name='block14_sepconv1_act')(x)
    x = separable_conv_layer(x, 2048, (N_SPACE, N_SPACE, spectral_step), 14, 2)
    x = layers.BatchNormalization(axis=channel_axis, name='block14_sepconv2_bn')(x)
    x = layers.Activation('relu', name='block14_sepconv2_act')(x)
    previous_block_activation = x  # Set aside next residual

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
            if 'mean' in dropMiddle:
                previous_block_activation = layers.Lambda(lambda y: backend.mean(y, axis=3), name='resid_drop_thrid_dim')(previous_block_activation)
            elif 'max' in dropMiddle: 
                previous_block_activation = layers.Lambda(lambda y: backend.max(y, axis=3), name='resid_drop_thrid_dim')(previous_block_activation)
       
        #print(x)
        #print(previous_block_activation)

        residual = layers.UpSampling2D(2)(previous_block_activation)
        residual = layers.Conv2D(filters, 1, padding="same")(residual)

        x = layers.add([x, residual])  # Add back residual
        previous_block_activation = x  # Set aside next residual

    # Add a per-pixel classification layer
    outputs = layers.Conv2D(numClasses, 3, activation="sigmoid", padding="same")(x)

    # Define the model
    model = Model(inputs, outputs, name='xception3D_2')
            
    return model

###################################### TRAINING #######################################
def get_xception3d_mean(height, width, numChannels, numClasses):
    model = get_xception3d_1('mean', height, width, numChannels, numClasses)
    return model 

def get_xception3d_max(height, width, numChannels, numClasses):
    model = get_xception3d_1('max', height, width, numChannels, numClasses)
    return model 

def get_xception3d2_mean(height, width, numChannels, numClasses):
    model = get_xception3d_2('mean', height, width, numChannels, numClasses)
    return model 

def get_xception3d2_max(height, width, numChannels, numClasses):
    model = get_xception3d_2('max', height, width, numChannels, numClasses)
    return model 

def get_xception3d3_mean(height, width, numChannels, numClasses):
    model = get_xception3d_3('mean', height, width, numChannels, numClasses)
    return model 

def get_xception3d3_max(height, width, numChannels, numClasses):
    model = get_xception3d_3('max', height, width, numChannels, numClasses)
    return model 

def get_xception3d4_mean(height, width, numChannels, numClasses):
    model = get_xception3d_4('mean', height, width, numChannels, numClasses)
    return model 

def get_xception3d4_max(height, width, numChannels, numClasses):
    model = get_xception3d_4('max', height, width, numChannels, numClasses)
    return model 

def get_xception3d5_mean(height, width, numChannels, numClasses):
    model = get_xception3d_5('mean', height, width, numChannels, numClasses)
    return model 

def get_xception3d5_max(height, width, numChannels, numClasses):
    model = get_xception3d_5('max', height, width, numChannels, numClasses)
    return model 


# def preproc_data(x_train_raw, x_test_raw):
#     x_train_preproc, x_test_preproc = hsi_segment_from_sm.get_sm_preproc_data(x_train_raw, x_test_raw, 'inceptionresnetv2')
#     return x_train_preproc, x_test_preproc

def get_xception_model(framework, x_train_raw, ytrain, x_test_raw, ytest, height, width, numChannels, numClasses, numEpochs=200, batchSize=8, 
    optimizerName = "RMSProp", learning_rate = 0.00001, decay = 0, lossFunction = "BCE+JC"):

    backend.clear_session()
    
    ## already preprocessed from 0 to 1
    # x_train_preproc, x_test_preproc = preproc_data(x_train_raw, x_test_raw)

    x_train_preproc = x_train_raw
    x_test_preproc = x_test_raw

    if 'xception3d_max' in framework:
        model = get_xception3d_max(height, width, numChannels, numClasses)
        batchSize = 4
        # learning_rate = 0.00001

    elif 'xception3d_mean' in framework: 
        model = get_xception3d_mean(height, width, numChannels, numClasses)
        batchSize = 4
        # learning_rate = 0.00001

    elif 'xception3d2_max' in framework:
        model = get_xception3d2_max(height, width, numChannels, numClasses)
        batchSize = 32

    elif 'xception3d2_mean' in framework:
        model = get_xception3d2_mean(height, width, numChannels, numClasses)
        batchSize = 32
    
    elif 'xception3d3_max' in framework:
        model = get_xception3d3_max(height, width, numChannels, numClasses)

    elif 'xception3d3_mean' in framework:
        model = get_xception3d3_mean(height, width, numChannels, numClasses)

    elif 'xception3d4_max' in framework:
        model = get_xception3d4_max(height, width, numChannels, numClasses)
        batchSize = 16
        # learning_rate = 0.00001

    elif 'xception3d4_mean' in framework:
        model = get_xception3d4_mean(height, width, numChannels, numClasses)
        batchSize = 16
        # learning_rate = 0.00001

    elif 'xception3d5_max' in framework:
        model = get_xception3d5_max(height, width, numChannels, numClasses)
        batchSize = 16
        # learning_rate = 0.0000005 #0.0000001

    elif 'xception3d5_mean' in framework:
        model = get_xception3d5_mean(height, width, numChannels, numClasses)
        batchSize = 16
        # learning_rate = 0.0000005 #0.0000001

    else: 
        print("Model:" + framework + " is not supported")

    model = train_utils.ompile_custom(framework, model, optimizerName, learning_rate, decay, lossFunction)
    model, history = train_utils.fit_model(framework, model, x_train_preproc, ytrain, x_test_preproc, ytest, numEpochs, batchSize)

    return model, history

