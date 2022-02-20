% ======================================================================
%> @brief GetQualityPixelsInternal returns the values and indexes for good quality pixels only.
%>
%> Quality is determined according to spectral brightness.
%>
%> @b Usage
%>
%> @code
%> [newI, idxs] = GetQualityPixelsInternal(spectralData, meanLimit, maxLimit);
%> @endcode
%>
%> @param obj [hsi] | An instance of the hsi class
%> @b Optional varargin
%> @param meanLimit [double] | The mean brightness limit. Default
%> is 0.2.
%> @param maxLimit [double] | The max brightness limit. Default is
%> 0.99.
%>
%> @retval newI [numeric array] | The stacked spectra of good
%> quality pixels
%> @retval newI [numeric array] | The indexes of good quality
%> pixels
% ======================================================================
function [newI, idxs] = GetQualityPixelsInternal(I, meanLimit, maxLimit)
% GetQualityPixelsInternal returns the values and indexes for good quality pixels only.
%
% Quality is determined according to spectral brightness.
%
% @b Usage
%
% @code
% [newI, idxs] = GetQualityPixelsInternal(spectralData, meanLimit, maxLimit);
% @endcode
%
% @param obj [hsi] | An instance of the hsi class
% @b Optional varargin
% @param meanLimit [double] | The mean brightness limit. Default
% is 0.2.
% @param maxLimit [double] | The max brightness limit. Default is
% 0.99.
%
% @retval newI [numeric array] | The stacked spectra of good
% quality pixels
% @retval newI [numeric array] | The indexes of good quality
% pixels

if nargin < 2
    meanLimit = 0.2;
end
if nargin < 3
    maxLimit = 0.99;
end

if ndims(I) == 2
    spectralMean = mean(I, 2);
    spectralMax = max(I, [], 2);
    idxs = spectralMean > meanLimit & spectralMax < maxLimit & spectralMean > 0;
    newI = I(idxs, :);
else
    [m, n, w] = size(I);
    I2d = reshape(I, [m * n, w]);
    [newI, idxs] = GetQualityPixelsinternal(I2d, meanLimit, maxLimit);
end
end