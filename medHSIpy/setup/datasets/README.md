# Instructions for Python

## To prepare the dataset

1. (Optional) install tensorflow-datasets

pip install tensorflow-datasets
tfds --version

2. Build dataset

cd C:\<user location>\medHSI\medHSI-python\setup\datasets\pslNormalized
tfds build --register_checksums

3. Results are saved in C:\Users\<user name>\tensorflow_datasets\pslnormalized\1.0.0

4. Load as

import tensorflow_datasets as tfds
df = tfds.load('pslnormalized')
