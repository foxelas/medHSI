# -*- coding: utf-8 -*
from keras import layers, backend
from keras.models import Model

if __name__ == "__main__":
    import train_utils
else:
    from . import train_utils

############################ BLOCKS ###################################
def double_conv_block(x, n_filters, kernel_size):
   # Conv2D then ReLU activation
   x = layers.Conv3D(filters=n_filters, kernel_size=kernel_size, padding = "same", activation = "relu", kernel_initializer = "he_normal")(x)
   # Conv2D then ReLU activation
   x = layers.Conv3D(filters=n_filters, kernel_size=kernel_size, padding = "same", activation = "relu", kernel_initializer = "he_normal")(x)
   return x

def downsample_block(x, n_filters, kernel_size):
   f = double_conv_block(x, n_filters, kernel_size)
   f = layers.Dropout(0.4)(f)
   p = layers.MaxPool3D(2)(f)
   return f, p

def double_conv_block_2D(x, n_filters):
   # Conv2D then ReLU activation
   x = layers.Conv2D(filters=n_filters, kernel_size=3, padding = "same", activation = "relu", kernel_initializer = "he_normal")(x)
   # Conv2D then ReLU activation
   x = layers.Conv2D(filters=n_filters, kernel_size=3, padding = "same", activation = "relu", kernel_initializer = "he_normal")(x)
   return x

def upsample_block(x, conv_features, n_filters):
   # upsample
   x = layers.Conv2DTranspose(n_filters, 3, 2, padding="same")(x)
   conv_features = layers.Lambda(lambda y: backend.mean(y, axis=3))(conv_features)
   
   # concatenate
   x = layers.concatenate([x, conv_features])
   # dropout
   x = layers.Dropout(0.4)(x)
   # Conv2D twice with ReLU activation
   x = double_conv_block_2D(x, n_filters)
   return x

############################ CNN ###################################

def cnn3d( width, height, numChannels, numClasses): 

    depth = numChannels
    channel_axis = -1

    ## Model Structure 
    ## Input layer
    input_layer = layers.Input((width, height, depth, 1), name='entry')
    # encoder: contracting path - downsample
    # 1 - downsample
    f1, p1 = downsample_block(input_layer, 4, (3, 3, 50))
    # 2 - downsample
    f2, p2 = downsample_block(p1, 8, (3, 3, 50))
    # 3 - downsample
    f3, p3 = downsample_block(p2, 8, (3, 3, 30))
    # 4 - downsample
    f4, p4 = downsample_block(p3, 16, (3, 3, 20))
    # 5 - downsample
    f5, p5 = downsample_block(p4, 16, (3, 3, 20))

    # 6 - bottleneck
    bottleneck = double_conv_block(p5, 32, (1, 1, 19))
    bottleneck = layers.Lambda(lambda y: backend.mean(y, axis=3), name='drop_thrid_dim')(bottleneck)
    
    # decoder: expanding path - upsample
    # 6 - upsample
    u6 = upsample_block(bottleneck, f5, 16)
    # 7 - upsample
    u7 = upsample_block(u6, f4, 16)
    # 8 - upsample
    u8 = upsample_block(u7, f3, 8)
    # 9 - upsample
    u9 = upsample_block(u8, f2, 8)
    # 9 - upsample
    u10 = upsample_block(u9, f1, 4)
    output_layer = layers.Conv2D(numClasses, 3, padding="same", activation = "sigmoid")(u10)
    #numClasses, 3, activation="sigmoid", padding="same"
    model = Model(inputs=input_layer, outputs=output_layer, name = "cnn3d")

    return model 

def cnn3d2( width, height, numChannels, numClasses): 

    depth = numChannels
    channel_axis = -1

    ## Model Structure 
    ## Input layer
    input_layer = layers.Input((width, height, depth, 1), name='entry')
    # encoder: contracting path - downsample
    # 1 - downsample
    f1, p1 = downsample_block(input_layer, 4, (3, 3, 20))
    # 2 - downsample
    f2, p2 = downsample_block(p1, 8, (3, 3, 20))
    # 3 - downsample
    f3, p3 = downsample_block(p2, 8, (3, 3, 20))
    # 4 - downsample
    f4, p4 = downsample_block(p3, 16, (3, 3, 20))
    # 5 - downsample
    f5, p5 = downsample_block(p4, 16, (1, 1, 5))
    # 6 - downsample
    f6, p6 = downsample_block(p5, 16, (1, 1, 5))
    # 7 - downsample
    f7, p7 = downsample_block(p6, 16, (1, 1, 5))

    # 6 - bottleneck
    bottleneck = double_conv_block(p7, 32, (1, 1, 5))
    bottleneck = layers.Lambda(lambda y: backend.mean(y, axis=3), name='drop_thrid_dim')(bottleneck)
    
    # decoder: expanding path - upsample
    u7b = upsample_block(bottleneck, f7, 16)
    u7c = upsample_block(u7b, f6, 16)
    u7d = upsample_block(u7c, f5, 16)

    # 7 - upsample
    u7 = upsample_block(u7d, f4, 16)
    # 8 - upsample
    u8 = upsample_block(u7, f3, 8)
    # 9 - upsample
    u9 = upsample_block(u8, f2, 8)
    # 9 - upsample
    u10 = upsample_block(u9, f1, 4)
    output_layer = layers.Conv2D(numClasses, 3, padding="same", activation = "sigmoid")(u10)
    #numClasses, 3, activation="sigmoid", padding="same"
    model = Model(inputs=input_layer, outputs=output_layer, name = "cnn3d_2d")

    return model 

############################ TRAIN ###################################

def get_cnn_model(framework, x_train_raw, ytrain, x_test_raw, ytest, height, width, numChannels, numClasses, numEpochs=200, batchSize=64,
   optimizerName = "RMSProp", learning_rate = 0.0001, decay = 0, lossFunction = "BCE+JC"):

   backend.clear_session()

   # x_train_preproc, x_test_preproc = preproc_data(x_train_raw, x_test_raw)
   x_train_preproc = x_train_raw
   x_test_preproc = x_test_raw
   
   if 'cnn3d2' in framework:
      model = cnn3d2(height, width, numChannels, numClasses)

   elif 'cnn3d' in framework:
      model = cnn3d(height, width, numChannels, numClasses)

   model = train_utils.compile_custom(framework, model, optimizerName, learning_rate, decay, lossFunction)

   model, history = train_utils.fit_model(framework, model, x_train_preproc, ytrain, x_test_preproc, ytest, numEpochs, batchSize)

   return model, history