% ======================================================================
%> @brief PreprocessInternal transforms the dataset into images or pixels as preparation for training.
%>
%> For data type 'image', the function rearranges pixels as a pixel (observation) by feature 2D array.
%> For more details check @c function PreprocessInternal .
%> This function can also handle multiscale transformations.
%>
%> @b Usage
%>
%> @code
%>   [X, y, sRGBs, fgMasks, labelImgs] = trainUtility.Preprocess(hsiList, labelInfos, dataType);
%>
%>   transformFun = @Dimred;
%>   [X, y, sRGBs, fgMasks, labelImgs] = PreprocessInternal(hsiList, labelInfos, dataType, transformFun);
%> @endcode
%>
%> @param hsiList [cell array] | The list of hsi objects
%> @param labelInfos [cell array] | The list of hsiInfo objects
%> @param dataType [char] | The target data type, either 'hsi', 'image' or 'pixel'
%> @param transformFun [function handle] | Optional: The function handle for the function to be applied. Default: None.
%>
%> @retval X [numeric array or cell array] | The processed data
%> @retval y [numeric array or cell array] | The processed values
%> @retval sRGBs [cell array] | The array of sRGBs for the data
%> @retval fgMasks [cell array] | The foreground masks of sRGBs for the data
%> @retval labelImgs [cell array] | The label masks for the data
%>
% ======================================================================
function [X, y, sRGBs, fgMasks, labelImgs] = PreprocessInternal(hsiList, labelInfos, dataType, transformFun)
% PreprocessInternal transforms the dataset into images or pixels as preparation for training.
%
% For data type 'image', the function rearranges pixels as a pixel (observation) by feature 2D array.
% For more details check @c function PreprocessInternal .
% This function can also handle multiscale transformations.
%
% @b Usage
%
% @code
%   [X, y, sRGBs, fgMasks, labelImgs] = trainUtility.Preprocess(hsiList, labelInfos, dataType);
%
%   transformFun = @Dimred;
%   [X, y, sRGBs, fgMasks, labelImgs] = PreprocessInternal(hsiList, labelInfos, dataType, transformFun);
% @endcode
%
% @param hsiList [cell array] | The list of hsi objects
% @param labelInfos [cell array] | The list of hsiInfo objects
% @param dataType [char] | The target data type, either 'hsi', 'image' or 'pixel'
% @param transformFun [function handle] | Optional: The function handle for the function to be applied. Default: None.
%
% @retval X [numeric array or cell array] | The processed data
% @retval y [numeric array or cell array] | The processed values
% @retval sRGBs [cell array] | The array of sRGBs for the data
% @retval fgMasks [cell array] | The foreground masks of sRGBs for the data
% @retval labelImgs [cell array] | The label masks for the data
%

useTransform = (nargin >= 4);

n = numel(hsiList);
X = cell(n, 1);
y = cell(n, 1);
sRGBs = cell(n, 1);
fgMasks = cell(n, 1);
labelImgs = cell(n, 1);

for i = 1:n
    hsIm = hsiList{i};
    labelInfo = labelInfos{i};
    fgMask = hsIm.FgMask;
    ydata = [];
    if strcmp(dataType, 'image')
        xdata = hsIm.Value;
        if hasLabels
            ydata = double(labelInfo.Labels);
        end

    elseif strcmp(dataType, 'hsi')
        xdata = hsIm;
        ydata = labelInfo;

    elseif strcmp(dataType, 'pixel')
        if useTransform
            scores = transformFun(hsIm);
            xdata = GetMaskedPixelsInternal(scores, fgMask);
        else
            xdata = hsIm.GetMaskedPixels(fgMask);
        end
        if ~isempty(labelInfo.Labels)
            ydata = double(GetMaskedPixelsInternal(labelInfo.Labels, fgMask));
        end

    else
        error('Incorrect data type');
    end       
    
    X{i} = xdata;
    y{i} = ydata;   
    sRGBs{i} = hsIm.GetDisplayRescaledImage();
    fgMasks{i} = fgMask;
    labelImgs{i} = logical(labelInfo.Labels);
                
end 

end 

