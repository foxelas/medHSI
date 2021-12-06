# -*- coding: utf-8 -*-
"""
Created on Tue Jun 15 18:00:32 2021

@author: foxel
"""

import matplotlib.pyplot as plt
import numpy as np
import os
import os.path
import sys


######################### Path #########################

def get_filenames(folder, target='.mat'):
    origListdir = os.listdir(folder)
    origListdir = [os.path.join(folder, x) for x in origListdir if target in x]
    return origListdir

def makedir(fpath):
    try:
        os.mkdir(fpath)
    except OSError as error:
        print('folder exists')
        
def get_savedir():
    return 'D:/elena/Google Drive/titech/research/experiments/output/hsi/python'

def get_tripletdir():
    return 'D:/elena/mspi/matfiles/hsi/calibTriplets'
    
######################### Messages #########################        
def not_implemented():
    print('Not yet implemented.')
    return

def not_supported(varname):
    print('Not supported [', varname, '].')
    return

######################### Config #########################
import configparser

def get_module_path():
    module_path = os.path.abspath(os.path.join('..'))
    if module_path not in sys.path:
        sys.path.append(module_path+"\\tools")
    #print('Module path: ', module_path)
    #sys.path
    return module_path

def get_config_path():
    module_path = get_module_path()
    settings_file = os.path.dirname(os.path.dirname(module_path)) + "\\conf" + "\\config.ini"
    return settings_file

def parse_config():
    settings_file = get_config_path()
    config = configparser.ConfigParser()
    config.read(settings_file, encoding = 'utf-8')
    print('Loading from settings .ini ', settings_file)
    config.sections()
    return config

conf = parse_config()

######################### Load #########################
    
from scipy.io import loadmat
import h5py
import mat73

###expected form of hsi data: Height x Width x Wavelengths

def load_from_h5(fname):
    val = h5py.File(fname, 'r')
    return val

def load_from_mat73(fname, varname=''):
    mat = mat73.loadmat(fname)
    val = mat[varname]
    return val

def load_from_mat(fname, varname=''):
    val = loadmat(fname)[varname]
    return val

def load_target_mat(fname, varname):
    hsi = load_from_mat73(fname + '_target.mat', varname) 
    return hsi

def load_white_mat(fname, varname):
    hsi = load_from_mat73(fname + '_white.mat', varname) 
    return hsi

def load_black_mat(fname, varname):
    hsi = load_from_mat73(fname + '_black.mat', varname) 
    return hsi

def load_dataset(fpath, sampleType='pixel', ash5=0):
    f = load_from_h5(fpath)
    hsiList = []
    
    for keyz in list(f.keys()):
        if ash5 == 1:
            val = f[keyz]
        else:
            val = f[keyz][:]
        if val.shape[2] != 311:
            val = np.transpose(val, [1, 2, 0])
        hsiList.append(val)
        
    dataList = []
    if sampleType == 'pixel':
        dataList = flatten_hsis(hsiList)
    elif sampleType == 'patch':
        not_implemented()
    elif sampleType == 'image':
        dataList = hsiList
    else:
        not_supported('SampleType')
    return dataList             

######################### Process #########################

def center_crop_hsi(hsi, targetHeight=None, targetWidth=None):        

    width = hsi.shape[1]
    height = hsi.shape[0]
    
    if targetWidth is None:
        targetWidth = min(width, height)

    if targetHeight is None:
        targetHeight = min(width, height)

    left = int(np.ceil((width - targetWidth) / 2))
    right = width - int(np.floor((width - targetWidth) / 2))

    top = int(np.ceil((height - targetHeight) / 2))
    bottom = height - int(np.floor((height - targetHeight) / 2))

    croppedImg = hsi[top:bottom, left:right,:]

    return croppedImg

def center_crop_list(dataList, targetHeight = 70, targetWidth = 70, showImage = False):
    croppedData = []
    for x in range(len(dataList)):
        val = center_crop_hsi(dataList[x], targetWidth, targetHeight)
        croppedData.append(val)
        
    if showImage:
        show_montage(croppedData)
            
    return croppedData
    
def normalize_hsi(hsi, white, black):
    normhsi = (hsi - black)  / (white - black + 0.0000001)
    return normhsi

def flatten_hsi(hsi):
    return np.reshape(hsi, (hsi.shape[0] * hsi.shape[1], hsi.shape[2])).transpose() 

def flatten_hsis(imgList):
    X = [flatten_hsi(x) for x in imgList]
    stacked = np.concatenate(X, axis=1).transpose()
    return stacked

def patch_split_hsi(hsi, patchDim=25):
    sb = np.array(hsi.shape)
    st = np.floor(sb[0:2] / patchDim)
    cropped = center_crop_hsi(hsi, st[0]*patchDim, st[1]*patchDim)
    patchIndex = np.meshgrid(np.arange(0,st[0], dtype=np.int32), np.arange(0,st[1], dtype=np.int32))
    patchList = np.empty((int(st[0]*st[1]), patchDim, patchDim, hsi.shape[2]))
    i = 0
    for x,y in zip(patchIndex[0].flatten(), patchIndex[1].flatten()): 
        #v = hsi[(0 + x*patchDim):(patchDim + x*patchDim), (0 + y*patchDim):(patchDim + y*patchDim),:]
        #print(np.max(v.flatten()))
        patchList[++i,:,:,:] = cropped[(0 + x*patchDim):(patchDim + x*patchDim), (0 + y*patchDim):(patchDim + y*patchDim),:]
        #print(np.max(patchList[i,:,:,:].flatten()))
    return patchList


######################### Reconstruct 3D #########################
import math

def xyz2rgb(imXYZ):
    d = imXYZ.shape
    r = math.prod(d[0:2])  
    w = d[-1]             
    XYZ = np.reshape(imXYZ, (r, w))
    
    M = [[3.2406, -1.5372, -0.4986],
        [-0.9689, 1.8758, 0.0414],
        [0.0557, -0.2040, 1.0570]]
    sRGB = np.transpose(np.dot(M, np.transpose(XYZ)))

    sRGB = np.reshape(sRGB, d)
    return sRGB

def get_display_image(hsi, imgType = 'srgb', channel = 150):
    recon = []
    if imgType == 'srgb':        
        [m,n,z] = hsi.shape
        
        filename = os.path.join(os.path.dirname(os.path.dirname(get_module_path())), conf['Directories']['paramDir'], 'displayParam_311.mat')
        xyz = load_from_mat(filename, 'xyz')
        illumination = load_from_mat(filename, 'illumination')
        
        colImage = np.reshape( hsi, (m*n, z) )  
        normConst = np.amax(colImage)
        colImage = colImage / float(normConst)
        colImage =  colImage * illumination
        colXYZ = np.dot(colImage, np.squeeze(xyz))
        
        imXYZ = np.reshape(colXYZ, (m, n, 3))
        imXYZ[imXYZ < 0] = 0
        imXYZ = imXYZ / np.amax(imXYZ)
        dispImage_ = xyz2rgb(imXYZ);
        dispImage_[dispImage_ < 0] = 0
        dispImage_[dispImage_ > 1] = 1
        dispImage_ = dispImage_**0.4;
        recon =  dispImage_

    elif imgType =='channel':
        recon = hsi[:,:, channel]
        
    else:
        not_supported(imgType)
    
    return recon

######################### Plotting #########################
import skimage.util

def simple_plot(y, figTitle, xLabel, yLabel, fpath):
    plt.plot(np.arange(len(y))+1, y)
    plt.title(figTitle)
    plt.xlabel(xLabel)
    plt.ylabel(yLabel)
    pltFname = fpath + figTitle.replace(' ', '_') + '.jpg'
    print('Save figure at: ', pltFname) 
    plt.savefig(pltFname)
    plt.show()

def show_image(x, figTitle = None, hasGreyScale = False, fpath = ""):
    if hasGreyScale:
        plt.imshow(x, cmap='gray')
    else:
        plt.imshow(x)
    if figTitle is not None:
        plt.title(figTitle)
        pltFname = os.path.join(fpath, figTitle.replace(' ', '_') + '.jpg')
        plt.savefig(pltFname)
        print('Save figure at:'+ pltFname)
    plt.show()

from PIL import Image

row_size = 4
margin = 3

def show_montage(hsiList, imgType = 'srgb', channel = 150):
    images = [get_display_image(x) for x in hsiList]

    width = max(image.shape[0] + margin for image in images)*row_size
    height = sum(image.shape[1] + margin for image in images)
    montage = Image.new(mode='RGBA', size=(width, height), color=(0,0,0,0))
    
    max_x = 0
    max_y = 0
    offset_x = 0
    offset_y = 0
    for i,image in enumerate(images):
        montage.paste(image, (max_x,max_y,offset_x, offset_y))
    
        max_x = max(max_x, offset_x + image.shape[0])
        max_y = max(max_y, offset_y + image.shape[1])
    
        if i % row_size == row_size-1:
            offset_y = max_y + margin
            offset_x = 0
        else:
            offset_x += margin + image.shape[0]
    
    montage = montage.crop((0, 0, max_x, max_y))
    #montage.save(output_fn)
    return 
    

fpath = 'D:\\elena\\mspi\\output\\000-Datasets\\hsi_normalized_full.h5'
dataList = load_dataset(fpath, 'image')

#hsi = dataList[0]
#dispImage_= get_display_image(hsi, 'srgb')
#show_image(dispImage_, None)
#show_montage(dataList)

hsiList = dataList
images = [get_display_image(x) for x in hsiList]

width = max(image.shape[0] + margin for image in images)*row_size
height = sum(image.shape[1] + margin for image in images)
montage = Image.new(mode='RGBA', size=(width, height), color=(0,0,0,0))

max_x = 0
max_y = 0
offset_x = 0
offset_y = 0
for i,image in enumerate(images):
    montage.paste(image, (max_x,max_y,offset_x, offset_y))

    max_x = max(max_x, offset_x + image.shape[0])
    max_y = max(max_y, offset_y + image.shape[1])

    if i % row_size == row_size-1:
        offset_y = max_y + margin
        offset_x = 0
    else:
        offset_x += margin + image.shape[0]

montage = montage.crop((0, 0, max_x, max_y))
