from hsi_decompositions import decompose, prep_decomp_figures
from hsi_io import load_hsi
import matplotlib.pyplot as plt

indexes = [67, 94]
fpath = 'D:\elena\mspi\matfiles\hsi\calibTriplets'
hsiList = load_hsi(fpath, indexes, 0, 'spectralData')

## Train pca with only these two images
plt.close('all')
decom = decompose(hsiList, 'pca', 10)
prep_decomp_figures(decom, hsiList, 'pca', 'exp1_raw_full', [380, 780])

## Pca including hands and after discarding top and bottom of spectrum 
plt.close('all')
decom = decompose(hsiList, 'pca', 10)
prep_decomp_figures(decom, hsiList, 'pca', 'exp2_raw_cropped')

## Pca including hands and after discarding top and bottom of spectrum , after normalization
plt.close('all')
normList = load_hsi(fpath, indexes, 1, 'spectralData')
decompose(normList, 'pca', 10)
decom = prep_decomp_figures(decom, normList, 'pca', 'exp3_norm_cropped')
