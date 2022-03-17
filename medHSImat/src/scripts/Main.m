%======================================================================
%> @mainpage Documentation guidelines
%>
%> @section intro Introduction
%>
%> The MedHSI package allows you to read and process Hyper-Spectral Images (HSI)
%> captured with a TopCon Spectroradiometer (.h5 files).
%>
%>The framework has been specifically developed for macropathology-related tasks.
%>
%>The methods are tested on hyper-spectral images (in the visible range) of Pigmented Skin Lesions.
%>
%> @section  Details
%> For details refer to https://foxelas.github.io/medHSI/.
%>
%> The structure is described in @ref descr. Also, check pages @b Classes and @b Files.
%>
%> If you find any mistakes or bugs, contact me by email at ealoupogianni[ at ]outlook.com.
%>
%> @section Installation
%> Check the @ref installation page.
%>
%> @section cite Cite
%> Cite as Aloupogianni, E. (2022) ``MedHSI package for Hyperspectral Medical Image Processing'' (Version 1.0) [https://github.com/foxelas/medHSI].
%>
%> @page installation Installation
%>
%> @section Description
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
%> Prepare relevant MATLAB dependencies
%> - Option 1: Manual installation
%>      - delimread [details](https://www.mathworks.com/matlabcentral/fileexchange/52423-delimread), [download](https://www.mathworks.com/matlabcentral/mlc-downloads/downloads/submissions/52423/versions/3/download/zip)
%>      - imoverlay [details](https://www.mathworks.com/matlabcentral/fileexchange/42904-imoverlay), [download](https://www.mathworks.com/matlabcentral/mlc-downloads/downloads/submissions/42904/versions/4/download/zip)
%>      - regionGrowing [details](https://www.mathworks.com/matlabcentral/fileexchange/32532-region-growing-2d-3d-grayscale), [download](https://www.mathworks.com/matlabcentral/mlc-downloads/downloads/submissions/32532/versions/6/download/zip)
%>      - regiongrowing [details](https://www.mathworks.com/matlabcentral/fileexchange/19084-region-growing), [download](https://www.mathworks.com/matlabcentral/mlc-downloads/downloads/submissions/19084/versions/1/download/zip)
%>      - spectralcolor [details](https://www.mathworks.com/matlabcentral/fileexchange/7021-spectral-and-xyz-color-functions), [download](https://www.mathworks.com/matlabcentral/mlc-downloads/downloads/submissions/7021/versions/2/download/zip)
%>      - SuperPCA [details](https://github.com/junjun-jiang/SuperPCA), [download](https://github.com/junjun-jiang/SuperPCA/archive/refs/heads/master.zip)
%>
%>
%> - Option 2: Bulk installation
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
%> @page descr Description
%>
%> @section Details
%>
%> The MedHSIMat folders contains subfolders for different uses.
%> - @b tools
%>   - Contains key classes for MedHSI processing.
%> - @b src
%>   - Contains user-defined scripts and functions for task customization.
%> - @b setup
%>   - Contains setup files and demo scripts
%======================================================================