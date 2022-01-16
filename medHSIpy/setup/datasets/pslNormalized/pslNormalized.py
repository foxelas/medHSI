"""pslNormalized dataset."""

from pyrsistent import v
import tensorflow as tf
import tensorflow_datasets as tfds

import os 
def get_tools_dir():
    cwd = os.getcwd()
    parts = cwd.split("\\")
    parts = parts[0: parts.index('medHSIpy')+1]
    parts.insert(1, os.sep)
    base_dir = os.path.join(*parts)
    tools_dir = os.path.join(base_dir, 'tools')
    return tools_dir

import sys
sys.path.append(get_tools_dir())
import hsi_io

_DESCRIPTION = """
pslNormalized is a labeled dataset that contains hyper-spectral images of pigmented skin lesions, 
captured during gross-pathology and before formalin fixing. 
"""

# TODO(pslNormalized): BibTeX citation
_CITATION =  """
Hyper-spectral Images of ex-vivo gross pigmented skin lesions,
foxelas, 2021
"""


class Pslnormalized(tfds.core.GeneratorBasedBuilder):
  """DatasetBuilder for pslNormalized dataset."""

  VERSION = tfds.core.Version('1.0.0')
  # pytype: disable=wrong-keyword-args
  BUILDER_CONFIGS = [
      # `name` (and optionally `description`) are required for each config
      #MyDatasetConfig(name='small', description='Small ...', img_size=(8, 8)),
      #MyDatasetConfig(name='big', description='Big ...', img_size=(32, 32)),
      ]
  # pytype: enable=wrong-keyword-args
  RELEASE_NOTES = {
      '1.0.0': 'Initial release.',
  }

  def _info(self) -> tfds.core.DatasetInfo:
    """Returns the dataset metadata."""
    # Specifies the tfds.core.DatasetInfo object
    return tfds.core.DatasetInfo(
        builder=self,
        description=_DESCRIPTION,
        features=tfds.features.FeaturesDict({
            # These are the features of your dataset like images, labels ...
            'id': tfds.features.Text(),
            'hsi': tfds.features.Tensor(shape=(70, 70, 311), dtype=tf.float64),
            'tumor': tfds.features.Tensor(shape=(70, 70), dtype=tf.int8),
        }),
        # If there's a common (input, target) tuple from the
        # features, specify them here. They'll be used if
        # `as_supervised=True` in `builder.as_dataset`.
        supervised_keys=('hsi', 'tumor'),  # Set to `None` to disable
        #homepage='https://dataset-homepage/',
        citation=_CITATION,
        disable_shuffling=True,
    )

  def _split_generators(self, dl_manager: tfds.download.DownloadManager):
    """Returns SplitGenerators."""
    # TODO(pslNormalized): Downloads the data and defines the splits
    # path = dl_manager.download_and_extract('https://todo-data-url')
    
    # # data_path is a pathlib-like `Path('<manual_dir>/data.zip')`
    # archive_path = dl_manager.manual_dir / 'data.zip'
    # # Extract the manually downloaded `data.zip`
    # extracted_path = dl_manager.extract(archive_path)

    # Returns the Dict[split names, Iterator[Key, Example]]

    path = "empty\\path"
    
    return {
        'train': self._generate_examples(0, 4),
        'test': self._generate_examples(5, 5)
    }

  def _generate_examples(self, startIdx, endIdx):
    """Yields examples."""
    # Yields (key, example) tuples from the dataset
    #    


    conf = hsi_io.conf
    fpath = os.path.join(conf['Directories']['outputDir'], conf['Folder Names']['datasets'], 'hsi_normalized_full.h5')
        
    dataList, keyList = hsi_io.load_dataset(fpath, 'image')

    ### Temporary
    sampleIds = [153, 172, 166, 169, 178, 184]
    keepInd = [1, 7, 5, 6, 9, 11]
    if not keepInd is None: 
        dataList = [ dataList[i] for i in keepInd] 

    # Prepare input data 
    croppedData = hsi_io.center_crop_list(dataList, 70, 70, True)

    # Prepare labels 
    labelpath = os.path.join(conf['Directories']['outputDir'], conf['Folder Names']['labelsManual'])
    labelRgb = hsi_io.load_label_images(labelpath)
    labelImages = hsi_io.get_labels_from_mask(labelRgb)
    croppedLabels = hsi_io.center_crop_list(labelImages)
    
    for (hsIm, labelIm, i) in zip(croppedData, croppedLabels, range(len(croppedData))):
        if i >= startIdx and i <= endIdx:
            yield sampleIds[i], {
                'id': "sample" + str(sampleIds[i]),
                'hsi': hsIm,
                'tumor': labelIm,
            }
