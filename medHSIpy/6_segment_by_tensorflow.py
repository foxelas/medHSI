# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""

import sys
import os

import tensorflow_datasets as tfds
import tensorflow as tf
print(tf.__version__)

import matplotlib.pyplot as plt
import numpy as np

import tools.hsi_io as hio
# import medHSIpy.tools.hsi_decompositions as dc


dataset = tfds.load('pslnormalized')

def load_image(datapoint):
    input_image = datapoint['hsi']
    input_mask = datapoint['tumor']
    tf.print(input_mask)

    
    print(tf.reduce_max(input_mask))
    print(tf.reduce_min(input_mask))
    return input_image, input_mask

train_images = dataset['train'].map(load_image, num_parallel_calls=tf.data.AUTOTUNE)
test_images = dataset['test'].map(load_image, num_parallel_calls=tf.data.AUTOTUNE)

TRAIN_LENGTH = len(train_images) #info.splits['train'].num_examples
BATCH_SIZE = 1 # 64
BUFFER_SIZE = 2 # 1000
STEPS_PER_EPOCH = TRAIN_LENGTH #TRAIN_LENGTH // BATCH_SIZE

class Augment(tf.keras.layers.Layer):
  def __init__(self, seed=42):
    super().__init__()
    # both use the same seed, so they'll make the same random changes.
    self.augment_inputs = tf.keras.layers.RandomFlip(mode="horizontal", seed=seed)
    self.augment_labels = tf.keras.layers.RandomFlip(mode="horizontal", seed=seed)

  def call(self, inputs, labels):
    inputs = self.augment_inputs(inputs)
    labels = self.augment_labels(labels)
    return inputs, labels

train_batches = (
    train_images
    .cache()
    .shuffle(BUFFER_SIZE)
    .batch(BATCH_SIZE)
    .repeat()
    .map(Augment())
    .prefetch(buffer_size=tf.data.AUTOTUNE))

test_batches = test_images.batch(BATCH_SIZE)

def display(display_list):
  plt.figure(figsize=(15, 15))

  title = ['Input Image', 'True Mask', 'Predicted Mask']

  for i in range(len(display_list)):
    plt.subplot(1, len(display_list), i+1)
    plt.title(title[i])
    plt.imshow(tf.keras.utils.array_to_img(display_list[i]))
    plt.axis('off')
  plt.show()

  for images, masks in train_batches.take(2):
    sample_image, sample_mask = images[0], masks[0]
    display([sample_image, sample_mask])