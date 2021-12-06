# -*- coding: utf-8 -*-
"""
Created on Tue Jun 15 18:00:32 2021

@author: foxel
"""

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


######################### Load #########################

def load_images(folder, target='.jpg'):
    images = []
    origListdir = get_filenames(folder, target)
    for filename in origListdir: 
        img = cv2.imread(filename)
        img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        #plt.imshow(img)
        img = img.astype('float32') / 255.0
        if img is not None:
            images.append(img)
    #images = images[1:]
    return images

def load_crop(folder, x = 50, y = 50, w = 800, h = 800):
    fullImg = load_images(folder)
    cropImg = []
    for img in fullImg:
        cropped = img[y:y+h, x:x+w]
        #plt.imshow(cropped)
        cropImg.append(cropped)
    return cropImg
    
import scipy.io
import h5py
import mat73

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

def load_hsi_old(folder, indexes=None, hasNorm=0, varname='hsi'):
    hsis = []
    if indexes is None:
        origListdir = get_filenames(folder, '.mat')
        for filename in origListdir:
            hsi = load_from_mat73(filename, 'img')
            hsis.append(hsi)
    else:
        for i in range(len(indexes)):
            basefname = os.path.join(folder, str(indexes[i]))
            hsi = load_target_mat(basefname, varname)
            if hasNorm == 1: 
                white = load_white_mat(basefname, varname)
                black = load_black_mat(basefname, varname)
                normhsi = normalize_hsi(hsi, white, black)
                hsis.append(normhsi)
            else:
                hsis.append(hsi)
    return hsis

def load_dataset(fpath, sampleType='pixel', ash5=0):
    f = load_from_h5(fpath)
    hsiList = []
    for keyz in list(f.keys()):
        if ash5 == 1:
            val = f[keyz]
        else:
            val = f[keyz][:]
        hsiList.append(val)
    dataList = []
    if sampleType == 'pixel':
        dataList = flatten_hsis(hsiList)
    elif sampleType == 'patch':
        dataList = patch_split_hsis(hsiList) 
    elif sampleType == 'image':
        dataList = hsiList
    else:
        not_supported('SampleType')
    return dataList      

def import_dataset_old(folder, hasNorm=0, sampleType='pixel'):
    varname = 'spectralData'
    hsiList = load_hsi(folder, None, hasNorm, varname)
    dataList = []
    if sampleType == 'pixel':
        dataList = flatten_hsis(hsiList)
    elif sampleType == 'patch':
        dataList = patch_split_hsis(hsiList) 
    else:
        not_supported('SampleType')
    return dataList        

######################### Process #########################

def crop_image_middle(img, st):
    sb = np.array(img.shape[0:2])
    if np.ndim(st) == 0:
        st =  np.array([st, st])
    mid = np.floor(st/2)
    rem = np.ceil(st/2 - mid)
    fn1 = [int(x) for x in sb/2-mid - rem]
    fn2 = [int(x) for x in sb/2+mid]
    imCrop = img[fn1[0]:fn2[0],fn1[1]:fn2[1],:]
    return imCrop
    
def normalize_hsi(hsi, white, black):
    normhsi = (hsi - black)  / (white - black + 0.0000001)
    return normhsi

def crop_range(hsi, rangeLimits=[420, 730]):
    w = np.arange(rangeLimits[0], rangeLimits[1]+1)
    if rangeLimits is not [380, 780]:
        hsi = hsi[:,:,w - rangeLimits[0]]
    return hsi

def crop_ranges(imgList, rangeLimits = [420, 730]):
    return [crop_range(x, rangeLimits) for x in imgList]

def flatten_hsi(hsi):
    return np.reshape(hsi, (hsi.shape[0] * hsi.shape[1], hsi.shape[2])).transpose() 

def flatten_hsis(imgList):
    X = [flatten_hsi(x) for x in imgList]
    stacked = np.concatenate(X, axis=1).transpose()
    return stacked

def patch_split_hsi(hsi, patchDim=25):
    sb = np.array(hsi.shape)
    st = np.floor(sb[0:2] / patchDim)
    cropped = crop_image_middle(hsi, st*patchDim)
    patchIndex = np.meshgrid(np.arange(0,st[0], dtype=np.int32), np.arange(0,st[1], dtype=np.int32))
    patchList = np.empty((int(st[0]*st[1]), patchDim, patchDim, hsi.shape[2]))
    i = 0
    for x,y in zip(patchIndex[0].flatten(), patchIndex[1].flatten()): 
        #v = hsi[(0 + x*patchDim):(patchDim + x*patchDim), (0 + y*patchDim):(patchDim + y*patchDim),:]
        #print(np.max(v.flatten()))
        patchList[++i,:,:,:] = cropped[(0 + x*patchDim):(patchDim + x*patchDim), (0 + y*patchDim):(patchDim + y*patchDim),:]
        #print(np.max(patchList[i,:,:,:].flatten()))
    return patchList

def patch_split_hsis(imgList):
    #split 
    #save as subimages 
    #re-read subimages         
    not_implemented()
    return imgList

######################### Plotting #########################
       
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
    