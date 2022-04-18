# -*- coding: utf-8 -*
from contextlib import redirect_stdout
from keras import layers, backend
from keras.models import Model
import segmentation_models as sm

if __name__ == "__main__":
    import hsi_segment_from_sm
else:
    from . import hsi_segment_from_sm

N_SPACE = 3
N_SPECTRUM = 15
STRIDES_SPACE = 2 
STRIDES_SPECTRUM = 2

######### From scratch ###########

def get_xception3d_1(dropMiddle, height, width, numChannels, numClasses):
    channel_axis = -1
    depth = numChannels
    inputs = layers.Input((width, height, depth, 1), name='entry')

    ### [First half of the network: downsampling inputs] ###

    # Entry block
    x = layers.Conv3D(32, (N_SPACE, N_SPACE, N_SPECTRUM), strides=(STRIDES_SPACE, STRIDES_SPACE, STRIDES_SPECTRUM), use_bias=False, padding="same", name='block1_conv1')(inputs)
    x = layers.BatchNormalization(axis=channel_axis, name='block1_conv1_bn')(x)
    x = layers.Activation("relu", name='block1_conv1_act')(x)

    x = layers.Conv3D(64, (N_SPACE, N_SPACE, N_SPECTRUM), use_bias=False, name='block1_conv2')(x)
    x = layers.BatchNormalization(axis=channel_axis, name='block1_conv2_bn')(x)
    x = layers.Activation('relu', name='block1_conv2_act')(x)

    previous_block_activation = x  # Set aside residual

    # Blocks 1, 2, 3 are identical apart from the feature depth.
    k = 1
    for filters in  [128, 256, 728]:
        k += 1
        if k > 2:
            x = layers.Activation("relu", name='block'+str(k-1)+'_conv2_act')(x)
        x = layers.Conv3D(filters, (N_SPACE, N_SPACE, N_SPECTRUM), padding="same", groups=1, use_bias=False, name='block'+str(k)+'_DepthConv1_a')(x) #DepthwiseConv3D
        x = layers.Conv3D(filters, (1,1,1), padding="same", use_bias=False, name='block'+str(k)+'_DepthConv1_b')(x)
        x = layers.BatchNormalization(axis=channel_axis, name='block'+str(k)+'_DepthConv1_bn')(x)

        x = layers.Activation("relu")(x)
        x = layers.Conv3D(filters, (N_SPACE, N_SPACE, N_SPECTRUM), padding="same", groups=1, use_bias=False, name='block'+str(k)+'_DepthConv2_a')(x) #DepthwiseConv3D
        x = layers.Conv3D(filters, (1,1,1), padding="same", use_bias=False, name='block'+str(k)+'_DepthConv2_b')(x)
        x = layers.BatchNormalization(axis=channel_axis, name='block'+str(k)+'_DepthConv2_bn')(x)

        x = layers.MaxPooling3D((N_SPACE, N_SPACE, N_SPECTRUM), strides=(STRIDES_SPACE, STRIDES_SPACE, STRIDES_SPECTRUM), 
            padding="same", name='block'+str(k)+'_pool')(x)

        # Project residual
        residual = layers.Conv3D(filters, (1,1,1), strides=(STRIDES_SPACE, STRIDES_SPACE, STRIDES_SPECTRUM), padding="same", use_bias=False)(
            previous_block_activation
        )
        x = layers.add([x, residual])  # Add back residual
        previous_block_activation = x  # Set aside next residual


    if 'mean' in dropMiddle:
        x = layers.Lambda(lambda y: backend.mean(y, axis=3), 
            name='drop_spectral_dim')(x)
    elif 'max' in dropMiddle: 
        x = layers.Lambda(lambda y: backend.max(y, axis=3), 
            name='drop_spectral_dim')(x)

    # print("Drop dimm interior after")
    # print(x.shape.dims)

    ### [Second half of the network: upsampling inputs] ###

    for filters in [728, 256, 128, 64]:
        x = layers.Activation("relu")(x)
        x = layers.Conv2DTranspose(filters, 3, padding="same", use_bias=False)(x)
        x = layers.BatchNormalization()(x)

        x = layers.Activation("relu")(x)
        x = layers.Conv2DTranspose(filters, 3, padding="same", use_bias=False)(x)
        x = layers.BatchNormalization()(x)

        x = layers.UpSampling2D(2)(x)

        # Project residual
        if filters == 728:
            if 'mean' in dropMiddle:
                previous_block_activation = layers.Lambda(lambda y: backend.mean(y, axis=3), name='resid_drop_spectral_dim')(previous_block_activation)
            elif 'max' in dropMiddle:
                previous_block_activation = layers.Lambda(lambda y: backend.max(y, axis=3), name='resid_drop_spectral_dim')(previous_block_activation)

        residual = layers.UpSampling2D(2)(previous_block_activation)
        residual = layers.Conv2D(filters, 1, padding="same")(residual)

        x = layers.add([x, residual])  # Add back residual
        previous_block_activation = x  # Set aside next residual

        print("Second to last x")
        print(x.shape.dims)

    # Add a per-pixel classification layer
    outputs = layers.Conv2D(numClasses, 3, activation="sigmoid", padding="same")(x)

    # Define the model
    model = Model(inputs, outputs)
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

def get_xception3d_2(dropMiddle, height, width, numChannels, numClasses):
    
    depth = numChannels
    channel_axis = -1

    inputs = layers.Input((width, height, depth, 1), name='entry')

    ### [First half of the network: downsampling inputs] ###

    # Entry block
    x = layers.Conv3D(32, (N_SPACE, N_SPACE, N_SPECTRUM), strides=2, use_bias=False, padding="same", name='block1_conv1')(inputs)
    x = layers.BatchNormalization(axis=channel_axis, name='block1_conv1_bn')(x)
    x = layers.Activation("relu", name='block1_conv1_act')(x)

    x = layers.Conv3D(64, (N_SPACE, N_SPACE, N_SPECTRUM), use_bias=False, name='block1_conv2')(x)
    x = layers.BatchNormalization(axis=channel_axis, name='block1_conv2_bn')(x)
    x = layers.Activation('relu', name='block1_conv2_act')(x)

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

    x = layers.MaxPooling3D((N_SPACE, N_SPACE, N_SPECTRUM),
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
    x = separable_conv_layer(x, 256, (N_SPACE, N_SPACE, N_SPECTRUM), 3, 1)
    x = layers.BatchNormalization(axis=channel_axis, name='block3_sepconv1_bn')(x)
    x = layers.Activation('relu', name='block3_sepconv2_act')(x)
    x = separable_conv_layer(x, 256, (N_SPACE, N_SPACE, N_SPECTRUM), 3, 2)
    x = layers.BatchNormalization(axis=channel_axis, name='block3_sepconv2_bn')(x)

    x = layers.MaxPooling3D((N_SPACE, N_SPACE, N_SPECTRUM),
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
    x = separable_conv_layer(x, 728, (N_SPACE, N_SPACE, N_SPECTRUM), 4, 1)
    x = layers.BatchNormalization(axis=channel_axis, name='block4_sepconv1_bn')(x)
    x = layers.Activation('relu', name='block4_sepconv2_act')(x)
    x = separable_conv_layer(x, 728, (N_SPACE, N_SPACE, N_SPECTRUM), 4, 2)
    x = layers.BatchNormalization(axis=channel_axis, name='block4_sepconv2_bn')(x)

    x = layers.MaxPooling3D((N_SPACE, N_SPACE, N_SPECTRUM),
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
        x = separable_conv_layer(x, 728, (N_SPACE, N_SPACE, N_SPECTRUM), i+5, 1)
        x = layers.BatchNormalization(axis=channel_axis, name=prefix +'_sepconv1_bn')(x)
        x = layers.Activation('relu', name=prefix + '_sepconv2_act')(x)
        x = separable_conv_layer(x, 728, (N_SPACE, N_SPACE, N_SPECTRUM), i+5, 2)
        x = layers.BatchNormalization(axis=channel_axis, name=prefix +'_sepconv2_bn')(x)
        x = layers.Activation('relu', name=prefix + '_sepconv3_act')(x)
        x = separable_conv_layer(x, 728, (N_SPACE, N_SPACE, N_SPECTRUM), i+5, 3)
        x = layers.BatchNormalization(axis=channel_axis, name=prefix +'_sepconv3_bn')(x)

        x = layers.add([x, residual])

        previous_block_activation = x  # Set aside next residual

    residual = layers.Conv3D(1024, (1, 1, 1), strides=(2, 2, 2),
                             padding='same', use_bias=False)(x)
    residual = layers.BatchNormalization(axis=channel_axis)(residual)

    x = layers.Activation('relu', name='block13_sepconv1_act')(x)
    x = separable_conv_layer(x, 728, (N_SPACE, N_SPACE, N_SPECTRUM), 13, 1)
    x = layers.BatchNormalization(axis=channel_axis, name='block13_sepconv1_bn')(x)
    x = layers.Activation('relu', name='block13_sepconv2_act')(x)
    x = separable_conv_layer(x, 1024, (N_SPACE, N_SPACE, N_SPECTRUM), 13, 2)
    x = layers.BatchNormalization(axis=channel_axis, name='block13_sepconv2_bn')(x)

    x = layers.MaxPooling3D((N_SPACE, N_SPACE, N_SPECTRUM),
                            strides=(2, 2, 2),
                            padding='same',
                            name='block13_pool')(x)
    x = layers.add([x, residual])
    previous_block_activation = x  # Set aside next residual

    x = separable_conv_layer(x, 1536, (N_SPACE, N_SPACE, N_SPECTRUM), 14, 1)
    x = layers.BatchNormalization(axis=channel_axis, name='block14_sepconv1_bn')(x)
    x = layers.Activation('relu', name='block14_sepconv1_act')(x)
    x = separable_conv_layer(x, 2048, (N_SPACE, N_SPACE, N_SPECTRUM), 14, 2)
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
    model = Model(inputs, outputs, name='xception')
            
    return model

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

def preproc_data(x_train_raw, x_test_raw):
    x_train_preproc, x_test_preproc = hsi_segment_from_sm.get_sm_preproc_data(x_train_raw, x_test_raw, 'inceptionresnetv2')
    return x_train_preproc, x_test_preproc

def get_model(framework, x_train_raw, ytrain, x_test_raw, ytest, height, width, numChannels, numClasses, numEpochs=200, batchSize=12):
    backend.clear_session()
    x_train_preproc, x_test_preproc = preproc_data(x_train_raw, x_test_raw)
    if 'xception3d_max' in framework:
        model = get_xception3d_max(height, width, numChannels, numClasses)

    elif 'xception3d_mean' in framework: 
        model = get_xception3d_mean(height, width, numChannels, numClasses)

    elif 'xception3d2_max' in framework:
        model = get_xception3d2_max(height, width, numChannels, numClasses)

    elif 'xception3d2_mean' in framework:
        model = get_xception3d2_mean(height, width, numChannels, numClasses)

    #adam = Adam(lr=0.001, decay=1e-06)
    model.compile(
        'rmsprop', #'rmsprop', 'SGD', 'Adam',
        #loss='categorical_crossentropy'
        loss=sm.losses.bce_jaccard_loss,
        metrics=[sm.metrics.iou_score]
        )

    # fit model
    history = model.fit(
    x=x_train_preproc,
    y=ytrain,
    batch_size=batchSize,
    epochs=numEpochs,
    validation_data=(x_test_preproc, ytest),
    )

    return model, history

#backend.clear_session()



