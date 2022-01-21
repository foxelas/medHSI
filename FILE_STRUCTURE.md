medHSI/  
├── conf/  
│   ├── config.ini  
│   └── config.mat  
├── FILE_STRUCTURE.md  
├── LICENSE  
├── medHSImat/  
│   ├── setup/  
│   │   ├── demos/  
│   │   │   ├── config.ini  
│   │   │   ├── demo_init.m  
│   │   │   ├── input/  
│   │   │   │   └── demoDataInfoTable.xlsx  
│   │   │   ├── matfiles/  
│   │   │   └── output/  
│   │   ├── dependencies_matlab.md  
│   │   ├── README.md  
│   │   └── setup_matlab.m  
│   ├── src/  
│   │   ├── methods/  
│   │   │   └── CheckImportData.m  
│   │   └── scripts/  
│   │       ├── Beautify.m  
│   │       ├── GetAverageSpectraInROI.m  
│   │       ├── Main.m  
│   │       ├── T20210910_ReadHands.m  
│   │       ├── t20211104_ApplyScriptToEachImage.m  
│   │       ├── t20211207_PrepareLabels.m  
│   │       ├── t20211207_PrepareSummaryFigures.m  
│   │       ├── t20211208_TestSVM.m  
│   │       └── t20211230_PrintSampleHSI.m  
│   └── tools/  
│       ├── apply/  
│       │   ├── apply.m  
│       │   ├── ApplyOnQualityPixels.m  
│       │   ├── ApplyRowFunc.m  
│       │   ├── ApplyScriptToEachImage.m  
│       │   ├── KmeansInternal.m  
│       │   └── SuperpixelAnalysisInternal.m  
│       ├── config/  
│       │   ├── config.m  
│       │   └── SetOpt.m  
│       ├── databaseUtility/  
│       │   └── databaseUtility.m  
│       ├── dataUtility/  
│       │   └── dataUtility.m  
│       ├── hsi/  
│       │   ├── DimredInternal.m  
│       │   ├── GetDisplayImageInternal.m  
│       │   ├── GetFgMaskInternal.m  
│       │   ├── GetMaskFromFigureInternal.m  
│       │   ├── GetPixelsFromMaskInternal.m  
│       │   ├── GetQualityPixelsInternal.m  
│       │   ├── GetSpectraFromMaskInternal.m  
│       │   ├── hsi.m  
│       │   ├── NormalizeInternal.m  
│       │   └── RemoveBackgroundInternal.m  
│       ├── hsiUtility/  
│       │   ├── hsiUtility.m  
│       │   ├── LoadH5Data.m  
│       │   ├── NormalizeHSI.m  
│       │   ├── ReadHSIDataInternal.m  
│       │   ├── ReadStoredHSI.m  
│       │   ├── ReconstructDimred.m  
│       │   └── RecoverReducedHsi.m  
│       ├── methods/  
│       │   └── Dimred.m  
│       ├── metrics/  
│       │   └── metrics.m  
│       ├── plots/  
│       │   ├── PlotBandStatistics.m  
│       │   ├── PlotComponents.m  
│       │   ├── PlotDimred.m  
│       │   ├── PlotDualMontage.m  
│       │   ├── PlotEigenvectors.m  
│       │   ├── PlotGetLineColorMap.m  
│       │   ├── PlotMontageFolderContents.m  
│       │   ├── PlotNormalizationCheck.m  
│       │   ├── PlotOverlay.m  
│       │   ├── plots.m  
│       │   ├── PlotSpectra.m  
│       │   ├── PlotSpectraAverage.m  
│       │   ├── PlotSubimageMontage.m  
│       │   ├── PlotSuperpixels.m  
│       │   └── SavePlot.m  
│       └── utilities/  
│           ├── EndLogger.m  
│           ├── GetColorChartColors.m  
│           ├── GetColorchartValues.m  
│           ├── GetSolaxSpectra.m  
│           ├── PlotChromophoreAbsorptionSpectra.m  
│           ├── PlotColorMatchingFunctions.m  
│           ├── PlotSolaxIllumination.m  
│           └── StartLogger.m  
├── medHSIpy/  
│   ├── package/  
│   │   ├── LICENSE  
│   │   ├── README.md  
│   │   ├── requirements.txt  
│   │   ├── setup.cfg  
│   │   └── setup.py  
│   ├── segment_from_scratch.py  
│   ├── segment_from_sm.py  
│   ├── setup/  
│   │   └── datasets/  
│   │       ├── pslNormalized/  
│   │       │   ├── checksums.tsv  
│   │       │   ├── dummy_data/  
│   │       │   │   └── TODO-add_fake_data_in_this_directory.txt  
│   │       │   ├── pslNormalized.py  
│   │       │   └── pslNormalized_test.py  
│   │       └── README.md  
│   ├── src/  
│   │   └── main.py  
│   ├── tests/  
│   │   └── augment_segment.py  
│   └── tools/  
│       ├── create_file_structure.py  
│       ├── hsi_decompositions.py  
│       ├── hsi_io.py  
│       └── hsi_utils.py  
├── parameters/  
│   ├── displayParam.mat  
│   ├── displayParam_311.mat  
│   └── extinctionCoefficients.mat  
└── README.md  
