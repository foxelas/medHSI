import setuptools

with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

setuptools.setup(
    name="medhsi",
    version="1.0.0",
    author="foxelas",
    author_email="foxelas@outlook.com",
    description="Tools for Macropathology Hyper-Spectral Image Processing",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/foxelas/medHSI",
    packages=setuptools.find_packages(),
    classifiers=[
        "Programming Language :: Python :: 3",
		"License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
    ],
    python_requires='>=3.6',
    install_requires=['numpy',
                      'scikit-learn',
                      'matplotlib',
                      'h5py',
                      'scipy',
                      'scikit-image',
                      'mat73',
                      'configparser',
                      'keras',
                      'tensorflow',
                      'segmentation_models',
                      'opencv-python',
                      ]
)