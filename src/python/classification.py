# -*- coding: utf-8 -*-
"""
Created on Sun Sep  5 14:21:54 2021

@author: foxel
"""

import hsi_io as hio
import matplotlib.pyplot as plt

#Read hsi images from .mat files 
indexes = [67, 94]
fpath = hio.get_tripletdir() #'D:\elena\mspi\matfiles\hsi\calibTriplets'
hsiList = hio.load_hsi(fpath, indexes, 0, 'spectralData')

#Pixel samples


#Patch samples  

