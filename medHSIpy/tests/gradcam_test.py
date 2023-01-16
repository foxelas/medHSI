from random import seed
from datetime import date
from matplotlib.pyplot import title


from tools import hio
import segmentation_models as sm
import tools.hsi_segment_from_sm as segsm
import tools.hsi_segment_from_scratch as segscratch
import tools.from_the_internet as fi


from sklearn.metrics import roc_curve, auc
import numpy as np

WIDTH = 32 #64
HEIGHT = 32 # 64
NUMBER_OF_CLASSES = 1
NUMBER_OF_CHANNELS = 311
NUMBER_OF_EPOCHS = 5 # 200
VALIDATION_FOLDS = 5
BATCH_SIZE = 8


# #### Init 
# hio.show_label_montage('train')
# hio.show_label_montage('test')
# hio.show_label_montage('full')

X_train, X_test, y_train, y_test, names_train, names_test = hio.get_train_test()

def get_framework(framework, xtrain, xtest, ytrain, ytest):
    if 'sm' in framework:
        model, history, optSettings = segsm.fit_sm_model(framework, xtrain, ytrain, xtest, ytest, 
            height=HEIGHT, width=WIDTH, numChannels=NUMBER_OF_CHANNELS, 
            numClasses=NUMBER_OF_CLASSES, numEpochs=NUMBER_OF_EPOCHS)
            
    elif 'cnn3d' == framework:
        model, history, optSettings = segscratch.get_cnn_model(framework, xtrain, ytrain, xtest, ytest, 
            height=HEIGHT, width=WIDTH,  numChannels=NUMBER_OF_CHANNELS, 
            numClasses=NUMBER_OF_CLASSES, numEpochs=NUMBER_OF_EPOCHS, batchSize=64)

    else:
        model, history, optSettings = segscratch.get_xception_model(framework, xtrain, ytrain, xtest, ytest, 
            height=HEIGHT, width=WIDTH,  numChannels=NUMBER_OF_CHANNELS, 
            numClasses=NUMBER_OF_CLASSES, numEpochs=NUMBER_OF_EPOCHS, batchSize=BATCH_SIZE)

    return model, history, optSettings

############################################


import tensorflow as tf
from tensorflow import keras

# Display
from IPython.display import Image, display
import matplotlib.pyplot as plt
import matplotlib.cm as cm


def get_img_array(img_path, size):
    # `img` is a PIL image of size 299x299
    img = keras.preprocessing.image.load_img(img_path, target_size=size)
    # `array` is a float32 Numpy array of shape (299, 299, 3)
    array = keras.preprocessing.image.img_to_array(img)
    # We add a dimension to transform our array into a "batch"
    # of size (1, 299, 299, 3)
    array = np.expand_dims(array, axis=0)
    return array


def make_gradcam_heatmap(img_array, model, last_conv_layer_name, pred_index=None):
    # First, we create a model that maps the input image to the activations
    # of the last conv layer as well as the output predictions
    grad_model = tf.keras.models.Model(
        [model.inputs], [model.get_layer(last_conv_layer_name).output, model.output]
    )

    # Then, we compute the gradient of the top predicted class for our input image
    # with respect to the activations of the last conv layer
    with tf.GradientTape() as tape:
        last_conv_layer_output, preds = grad_model(img_array)
        if pred_index is None:
            pred_index = tf.argmax(preds[0])
        class_channel = preds[:, pred_index]

    # This is the gradient of the output neuron (top predicted or chosen)
    # with regard to the output feature map of the last conv layer
    grads = tape.gradient(class_channel, last_conv_layer_output)

    # This is a vector where each entry is the mean intensity of the gradient
    # over a specific feature map channel
    pooled_grads = tf.reduce_mean(grads, axis=(0, 1, 2))

    # We multiply each channel in the feature map array
    # by "how important this channel is" with regard to the top predicted class
    # then sum all the channels to obtain the heatmap class activation
    last_conv_layer_output = last_conv_layer_output[0]
    heatmap = last_conv_layer_output @ pooled_grads[..., tf.newaxis]
    heatmap = tf.squeeze(heatmap)

    # For visualization purpose, we will also normalize the heatmap between 0 & 1
    heatmap = tf.maximum(heatmap, 0) / tf.math.reduce_max(heatmap)
    return heatmap.numpy()


last_conv_layer_name = "stage4_unit2_conv2"

# import pickle
# filename = 'cd.pkl'
# with open(filename, 'rb') as f:
#     classification_dict = pickle.load(f)

import tools.hsi_utils as hsi_utils
from tools.grad_cam import GradCAM
import cv2

framework = 'sm_resnet'

model, history, optSettings = get_framework(framework, X_train, X_test, y_train, y_test)

folder = str(date.today()) + '_' + framework 
hio.save_model_info(model, folder, optSettings)

hio.plot_history(history, folder)

#prepare again in order to avoid pre-processing errors 
X_train, X_test, y_train, y_test, names_train, names_test = hio.get_train_test()

preds = model.predict(X_test)

from seggradcam.seggradcam import SegGradCAM, SuperRoI, ClassRoI, PixelRoI, BiasRoI
from seggradcam.visualize_sgc import SegGradCAMplot

model2 = model 
for (hsi, gt, id, pred) in zip(X_test, y_test, names_test, preds):

    fig = plt.figure(1)
    plt.clf()
    plt.subplot(1,3,1)
    plt.title("Original")
    plt.imshow(hsi_utils.get_display_image(hsi))

    # Remove last layer's softmax
    model2.layers[-1].activation = None

    # Print what the top predicted class is
    v = hsi.reshape(1, 32, 32, 311)
    preds2 = model2.predict(v)


    plt.subplot(1,3,3)
    plt.imshow(preds2[0,:,:,0])

    # # initialize our gradient class activation map and build the heatmap
    # cam = GradCAM(model, 1)
    # heatmap = cam.compute_heatmap(v)
    # # resize the resulting heatmap to the original input image dimensions
    # # and then overlay heatmap on top of the image
    # heatmap = cv2.resize(heatmap, (32, 32))
    # (heatmap, output) = cam.overlay_heatmap(heatmap, hsi[:,:,200], alpha=0.5)


    # # Generate class activation heatmap
    # heatmap = make_gradcam_heatmap(v, model2, last_conv_layer_name)

    # # Display heatmap
    # plt.matshow(heatmap)
    # plt.show()
    # create a SegGradCAM object


    # cls = 1
    # prop_from_layer = model.layers[-1].name
    # prop_to_layer = 'stage4_unit2_conv2'

    # roi=PixelRoI(15,15,v)
    # pixsgc = SegGradCAM(model, v, cls,  prop_to_layer,prop_from_layer, roi=roi,
    #                 normalize=True, abs_w=False, posit_w=False)
    # # compute SegGradCAM
    # pixsgc.SGC()
    # # create an object with plotting functionality
    # plotter = SegGradCAMplot(pixsgc,model=model,n_classes=2,outfolder="test", gt = gt)
    # # plot explanations on 1 picture
    # plotter.explainPixel()

    import lime 
    from lime import lime_image
    explainer = lime_image.LimeImageExplainer()
    
    rgbImg = hsi_utils.get_display_image(hsi)
    hsiTupple = [hsi, rgbImg.astype('double')]
    explanation = explainer.explain_instance(hsiTupple, model.predict, top_labels=1, hide_color=0, num_samples=30)
