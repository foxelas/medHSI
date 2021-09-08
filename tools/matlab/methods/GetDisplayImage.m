function dispImage = GetDisplayImage(spectralImage, method, channel)
%GetDisplayImage returns the display image from an HSI image
%
%   Usage:
%   dispImage = GetDisplayImage(spectralImage, 'rgb')
%   dispImage = GetDisplayImage(spectralImage, 'channel', 200)

if nargin < 2
    method = 'rgb';
end

if nargin < 3
    channel = 100;
end

[m, n, z] = size(spectralImage);
if (z < 401)
    v = GetWavelengths(z, 'index');
    spectralImage2 = zeros(m, n, 401);
    spectralImage2(:, :, v) = spectralImage;
    spectralImage = spectralImage2;
    clear 'spectralImage2';
end
if HasGPU()
    spectralImage_ = gpuArray(spectralImage);
else
    spectralImage_ = spectralImage;
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

if HasGPU()
    dispImage = gather(dispImage_);
else
    dispImage = dispImage_;
end

end

function [xyz, illumination] = PrepareParams(z)
filename = 'parameters/getDisplayHSIparams.mat';
if ~exist(filename, 'file')
    lambdaIn = GetWavelengths(z, 'raw');
    [lambdaMatch, xFcn, yFcn, zFcn] = colorMatchFcn('1964_FULL');
    xyz = interp1(lambdaMatch', [xFcn; yFcn; zFcn]', lambdaIn, 'pchip', 0);
    [solaxSpec, lambdaMatch] = GetSolaxSpectra();
    illumination = interp1(lambdaMatch, solaxSpec', lambdaIn, 'pchip', 0);
    save('parameters/getDisplayHSIparams.mat', 'xyz', 'illumination');
else
    load('parameters/getDisplayHSIparams.mat', 'xyz', 'illumination');
end
end