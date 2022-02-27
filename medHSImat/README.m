%======================================================================
%> @mainpage Documentation guidelines
%>
%> @section intro Introduction
%>
%> The MedHSI package allows you to read and process Hyper-Spectral Images (HSI)
%> captured with a TopCon Spectroradiometer (.h5 files).
%>
%> The framework has been specifically developed for macropathology-related tasks. The methods are tested on hyper-spectral images (in the visible range) of Pigmented Skin Lesions.
%>
%> @section details Details 
%> Refer to https://foxelas.github.io/medHSI/.
%>
%> @section Installation 
%> Check the @ref installation page. 
%>
%> @section structure Structure
%> Check pages @b Classes and @b Files.
%>
%> @section contact Contact 
%> If you find any mistakes or bugs, contact me by email at ealoupogianni[ at ]outlook.com.
%>
%> @section cite Cite 
%> Cite as Aloupogianni, E. (2022) ``MedHSI package for Hyperspectral Medical Image Processing'' (Version 1.0) [https://github.com/foxelas/medHSI].
%>
%> @page installation Installation
%>
%> @section descr Description 
%> 
%> The MedHSI package allows you to read and process Hyper-Spectral Images (HSI)
%> captured with a TopCon Spectroradiometer (.h5 files).
%>
%> This package contains two branches :
%> - medHSIMat branch for MATLAB 2020
%>   - Used for data import, preprocessing, normalization, dimension reduction and graphics production
%> - medHSIpy branch for python 3.8
%>   - Used classification and segmentation tasks 
%> 
%> @section before Before installation
%> - Download relevant MATLAB dependencies 
%>    - Check dependencies at https://foxelas.github.io/medHSI/dependencies/
%>    1. Open MATLAB and navigate to folder ..//medHSI//medHSImat//setup
%>    2. Install necessary dependencies by runnning
%> @code
%> script 'setup_matlab.m'
%> @endcode 
%>
%> @section Installation 
%> - Download the package from GitHub
%>		- You can clone or download a @b .zip file at https://github.com/foxelas/medHSI
%> - (Optional) Run demo
%>    - Move demo folder outside medHSI folder
%>    - Add demo folder to matlab path
%>    - Replace conf/config.ini with setup/demos/config.ini
%>    - Run 
%> @code 
%> script 'demo_init.m'
%> @endcode
%> 
%>
%======================================================================

