# -*- coding: utf-8 -*-
"""
Created on Tue Jun 15 20:02:11 2021

@author: foxel
"""

import matplotlib.pyplot as plt
import numpy as np
import math  
from hsi_io import makedir, flatten_hsi, flatten_hsis, get_savedir, simple_plot, show_image

def plot_eigenvectors(pcComp, xVals, pcNum, fpath, xlims = [380,780]):
    for i, eigenvector in zip(np.arange(pcNum), pcComp):
        if i < max(math.floor(pcNum/2), 5) :  
            plt.plot(xVals, eigenvector, label='eigv'+str(i+1))
        else:
            plt.plot(xVals, eigenvector, '--', label='eigv'+str(i+1))
            
    plt.legend(loc='upper right')
    plt.title('Eigenvectors')
    plt.xlabel('wavelength')
    plt.ylabel('coefficient')
    plt.xlim(xlims)
    #plt.ylim([-0.1, 0.1]) #
    plt.savefig(fpath + 'eigenvectors' + str(pcNum) +'.jpg')
    plt.show() 

def show_reduced_subimages(hsiList, decom, fpath='', numSub = 4):
    for i in range(len(hsiList)):
        img = decom.transform(flatten_hsi(hsiList[i]).transpose())
        img = img.reshape((hsiList[i].shape[0], hsiList[i].shape[1]))
        for j in range(numSub):               
            subImg = img[:,:,j]
            img =  (subImg - np.min(subImg)) / (np.max(subImg) - np.min(subImg))
            show_image(subImg, 'pc' + str(j) + '(Im' + str(i) +')', True, fpath)
                
from sklearn.decomposition import PCA
import os.path

def decompose(hsiList, method = 'pca', n_components=10):    
    if hsiList[0].ndim() == 3: 
        stacked = flatten_hsis(hsiList)
    else: 
        stacked = hsiList
    
    print('Total pixels for  fitting: ', stacked.shape[0], 'pixels')

    if method == 'pca': 
        decom = PCA(n_components=n_components)
        decom.fit(stacked)
    
    print('Finished dimension reduction.')
    return decom 

def prep_decomp_figures(decom, hsiList, method = 'pca', savefolder='', rangeLimits = [420, 730]):
    curSavedir = os.path.join(get_savedir(), 'pca', savefolder)
    makedir(curSavedir)
    
    if method == 'pca':
        explained_vals = decom.explained_variance_ratio_
        singular_vals = decom.singular_values_
        print('Explained variance:', explained_vals)
        print('Singular values:', singular_vals)
        
        plt.figure(0)
        simple_plot(explained_vals, 'Explained variance', 'pc number', 'explained percentage', curSavedir)
        plt.figure(1)
        simple_plot(singular_vals, 'Singular Values', 'pc number', 'value', curSavedir)
        
        w = np.arange(rangeLimits[0], rangeLimits[1]+1)
        plt.figure(2)
        plot_eigenvectors(decom.components_, w, 10, curSavedir)
        plt.figure(3)
        plot_eigenvectors(decom.components_, w, 3, curSavedir)
        
        plt.figure(4)
        show_reduced_subimages(hsiList, decom, curSavedir, numSub = 4)
