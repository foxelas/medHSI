# -*- coding: utf-8 -*
from random import seed
from tools import hio, util
import matplotlib.pyplot as plt

from keras import layers, backend
from keras.models import Model

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
        x = layers.BatchNormalization()(x)

        x = layers.Activation("relu")(x)
        x = layers.Conv3D(filters, 3, padding="same", groups=filters//2)(x) #DepthwiseConv3D
        x = layers.Conv3D(filters, (1,1,1), padding="same")(x)
        x = layers.BatchNormalization()(x)

        x = layers.MaxPooling3D(3, strides=2, padding="same")(x)

        # Project residual
        residual = layers.Conv3D(filters, 1, strides=2, padding="same")(
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
        x = layers.Conv2DTranspose(filters, 3, padding="same")(x)
        x = layers.BatchNormalization()(x)

        x = layers.Activation("relu")(x)
        x = layers.Conv2DTranspose(filters, 3, padding="same")(x)
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
    outputs = layers.Conv2D(num_classes, 3, activation="softmax", padding="same")(x)

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

backend.clear_session()

x_train, x_test, y_train, y_test = hio.get_train_test()

model = get_cnn3d_unbalanced_model()
hio.save_model_info(model)

model.compile(
    'Adam',
    loss='categorical_crossentropy')

# fit model
history = model.fit(
   x=x_train,
   y=y_train,
   batch_size=64,
   epochs=200,
   validation_data=(x_test, y_test),
)

hio.plot_history(history)

preds = model.predict(x_test)
for (hsi, gt, pred) in zip(x_test, y_test, preds):
   hio.visualize(hsi, gt, pred)


