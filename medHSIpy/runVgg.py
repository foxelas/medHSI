# -*- coding: utf-8 -*
from random import seed
from tools import hio, util
import segmentation_models as sm
import matplotlib.pyplot as plt

from keras.layers import Input, Conv2D
from keras.models import Model

x_train_raw, x_test_raw, y_train, y_test = hio.get_train_test()

sm.set_framework('tf.keras')
sm.framework()

NUMBER_OF_CLASSES = 1
NUMBER_OF_CHANNELS = 311
BACKBONE = 'vgg19'
preprocess_input = sm.get_preprocessing(BACKBONE)

# preprocess input
x_train = preprocess_input(x_train_raw)
x_test = preprocess_input(x_test_raw)

x_train_raw, x_test_raw, y_train, y_test = hio.get_train_test()


# define model
base_model = sm.Unet(backbone_name=BACKBONE, encoder_weights='imagenet')

input = Input(shape=(None, None, NUMBER_OF_CHANNELS))
l1 = Conv2D(3, (1, 1))(input) # map N channels data to 3 channels
output = base_model(l1)

model = Model(inputs=input, outputs=output, name=base_model.name)

model.compile(
    'Adam',
    loss=sm.losses.bce_jaccard_loss,
    metrics=[sm.metrics.iou_score],
)

hio.save_model_summary(model)

# fit model
history = model.fit(
   x=x_train,
   y=y_train,
   batch_size=64,
   epochs=200,
   validation_data=(x_test, y_test),
)

plt.plot(history.history['loss'])
plt.plot(history.history['val_loss'])
plt.title('model loss')
plt.ylabel('loss')
plt.xlabel('epoch')
plt.legend(['train', 'test'], loc='upper left')
plt.show()

def visualize(hsi, gt, pred):

    plt.subplot(1,3,1)
    plt.title("Original")
    plt.imshow(util.get_display_image(hsi))

    plt.subplot(1,3,2)
    plt.title("Ground Truth")
    plt.imshow(gt)

    plt.subplot(1,3,3)
    plt.title("Prediction")
    plt.imshow(pred)
    plt.show()

preds = model.predict(x_test)
for (hsi, gt, pred) in zip(x_test_raw, y_test, preds):
    visualize(hsi, gt, pred)

