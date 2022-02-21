% ======================================================================
%> @brief GetDisplayImageInternal returns an RGB image from the hyperspectral data.
%>
%> @b Usage
%>
%> @code
%> dispImage =  GetDisplayImageInternal(hsIm, superixelNumber);
%>
%> dispImage =  GetDisplayImageInternal(hsIm, 'rgb');
%>
%> dispImage =  GetDisplayImageInternal(hsIm, 'channel', 200);
%> @endcode
%>
%> @param obj [hsi] | An instance of the hsi class
%> @param method [string] | The method for display image creation
%> ('rgb' or 'channel')
%> @param channelNumber [int] | The target channel number
%>
%> @retval dispImage [numeric array] | The display image
% ======================================================================
function dispImage = GetDisplayImageInternal(hsIm, method, channel)
% GetDisplayImageInternal returns an RGB image from the hyperspectral data.
%
% @b Usage
%
% @code
% dispImage =  GetDisplayImageInternal(hsIm, superixelNumber);
%
% dispImage =  GetDisplayImageInternal(hsIm, 'rgb');
%
% dispImage =  GetDisplayImageInternal(hsIm, 'channel', 200);
% @endcode
%
% @param obj [hsi] | An instance of the hsi class
% @param method [string] | The method for display image creation
% ('rgb' or 'channel')
% @param channelNumber [int] | The target channel number
%
% @retval dispImage [numeric array] | The display image

if nargin < 2
    method = 'rgb';
end

if nargin < 3
    channel = 100;
end

[m, n, z] = size(hsIm);
if (z < 401)
    v = hsiUtility.GetWavelengths(z, 'index');
    spectralImage2 = zeros(m, n, 401);
    spectralImage2(:, :, v) = hsIm;
    hsIm = spectralImage2;
    z = 401;
    clear 'spectralImage2';
end
if config.HasGPU()
    spectralImage_ = gpuArray(hsIm);
else
    spectralImage_ = hsIm;
end
clear 'spectralImage';

switch method
    case 'rgb'
        %[lambda, xFcn, yFcn, zFcn] = colorMatchFcn('CIE_1964');
        colImage = double(reshape(spectralImage_, [m * n, z]));

        [xyz, illumination] = PrepareParams(z);
        normConst = double(max(max(colImage)));
        colImage = colImage ./ normConst;
        colImage = bsxfun(@times, colImage, illumination);
        colXYZ = colImage * squeeze(xyz);
        clear 'colImage';

        imXYZ = reshape(colXYZ, [m, n, 3]);
        imXYZ = max(imXYZ, 0);
        imXYZ = imXYZ / max(imXYZ(:));
        dispImage_ = XYZ2sRGB_exgamma(imXYZ);
        dispImage_ = max(dispImage_, 0);
        dispImage_ = min(dispImage_, 1);
        dispImage_ = dispImage_.^0.4;

    case 'channel'
        dispImage_ = rescale(spectralImage_(:, :, channel));
    otherwise
        error('Unsupported method for display image reconstruction');
end

if config.HasGPU()
    dispImage = gather(dispImage_);
else
    dispImage = dispImage_;
end

end

function [xyz, illumination] = PrepareParams(z)
filename = commonUtility.GetFilename('param', 'displayParam');
if ~exist(filename, 'file')
    lambdaIn = hsiUtility.GetWavelengths(z, 'raw');
    [lambdaMatch, xFcn, yFcn, zFcn] = colorMatchFcn('1964_FULL');
    xyz = interp1(lambdaMatch', [xFcn; yFcn; zFcn]', lambdaIn, 'pchip', 0);
    [solaxSpec, lambdaMatch] = GetSolaxSpectra();
    illumination = interp1(lambdaMatch, solaxSpec', lambdaIn, 'pchip', 0);
    save(filename, 'xyz', 'illumination');
else
    load(filename, 'xyz', 'illumination');
end
end