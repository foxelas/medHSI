# -*- coding: utf-8 -*-
"""
Created on Tue Jun 15 18:00:32 2021

@author: foxel
"""

from cProfile import label
import matplotlib.pyplot as plt
import numpy as np
import os
import os.path
import cv2


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
    
######################### Messages #########################        
def not_implemented():
    print('Not yet implemented.')
    return

def not_supported(varname):
    print('Not supported [', varname, '].')
    return

######################### Config #########################
import configparser

dirSep = '\\'

def get_base_dir():
    cwd = os.getcwd()
    parts = cwd.split("\\")
    parts = parts[0: parts.index('medHSI')+1]
    parts.insert(1, os.sep)
    base_dir = os.path.join(*parts)
    return base_dir

def get_module_path():
    module_path = os.path.join(get_base_dir(), 'medHSIpy', 'src')
    return module_path

def get_config_path():
    settings_file = os.path.join(get_base_dir(), "conf", "config.ini")
    return settings_file

def parse_config():
    settings_file = get_config_path()
    config = configparser.ConfigParser()
    config.read(settings_file, encoding = 'utf-8')
    # print("Loading from settings conf/config.ini \n")
    # print("Sections")
    # print(config.sections())
    return config

conf = parse_config()

def get_savedir():
    dirName = os.path.join(conf['Directories']['outputDir'], conf['Folder Names']['pythonTest'])
    return dirName

def get_tripletdir():
    dirName = os.path.join(conf['Directories']['matDir'], conf['Folder Names']['triplets'] )
    return dirName

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
    keyList = list(f.keys())

    for keyz in keyList:
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
    return dataList, keyList          

def load_images(fpath):
    images = []
    for filename in os.listdir(fpath):
        img = cv2.imread(os.path.join(fpath,filename))
        if img is not None:
            images.append(img)
    return images

def load_label_images(fpath):
    imgList = load_images(fpath)
    rotImgList = [np.transpose(labelImg, [1, 0, 2]) for labelImg in imgList]
    return rotImgList


######################### Process #########################

def get_labels_from_mask(imgList):
    labels = []
    for img in imgList: 
        grayIm = cv2.convertScaleAbs(cv2.cvtColor(img, cv2.COLOR_BGR2GRAY))  
        #print("Min", np.min(np.min(grayIm)), "and Max ", np.max(np.max(grayIm)))     	
        (thresh, blackAndWhiteImage) = cv2.threshold(grayIm, 170, 255, cv2.THRESH_BINARY)  	
        labelImg = np.logical_not(blackAndWhiteImage)
        labelImg = labelImg.astype(np.int8)
        #plt.imshow(labelImg, cmap='gray')
        #plt.show()
        labels.append(labelImg)
    return labels
    
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

    if np.ndim(hsi) > 2:
        croppedImg = hsi[top:bottom, left:right,:]
    else:
        croppedImg = hsi[top:bottom, left:right]
        
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
        
        filename = os.path.join(get_base_dir(), conf['Directories']['paramDir'], 'displayParam_311.mat')

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
import skimage.io

def simple_plot(y, figTitle, xLabel, yLabel, fpath):
    plt.plot(np.arange(len(y))+1, y)
    plt.title(figTitle)
    plt.xlabel(xLabel)
    plt.ylabel(yLabel)
    pltFname = fpath + figTitle.replace(' ', '_') + '.jpg'
    print('Save figure at: ', pltFname) 
    plt.savefig(pltFname)
    plt.show()

def show_display_image(hsiIm, imgType = 'srgb', channel = 150): 
    show_image(get_display_image(hsiIm, imgType, channel))

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
    
def show_montage(dataList, imgType = 'srgb', channel = 150):
    #Needs to have same number of dimensions for each image, type float single
    hsiList = np.array([get_display_image(x, imgType, channel) for x in dataList], dtype="float64")
    m = skimage.util.montage(hsiList, channel_axis = 3)
    m = (m * 255).astype(np.uint8)
    filename = os.path.join(conf['Directories']['outputDir'], 'T20211207-python', 'normalized-montage.jpg')
    skimage.io.imsave(filename, m)



