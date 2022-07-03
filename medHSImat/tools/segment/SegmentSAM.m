% ======================================================================
%> @brief SegmentSAM applies SAM-based segmentation to an hsi.
%>
%> @b Usage
%>
%> @code
%> [prediction, scoreImg, argminImg] = segment.Apply(hsIm, 'SAM', 'healthy', 13);
%>
%> [prediction, scoreImg, argminImg] = segmentSAM(hsIm, 'healthy', 13);
%> @endcode
%>
%> @param hsIm [hsi] | An instance of the hsi class
%> @param option [char] | Optional: The option for application. Options: ['library', 'healthy']. Default: 'library'.
%> @param threshold [double] | Optional: The threshold. Required when 'option' is 'healthy'. Default: 15.
%>
%> @retval prediction [numeric array] | The predicted labels
%> @retval scoreImg [numeric array] | The scores from SAM
%> @retval argminImg [numeric array] | The arguments of references with minimum SAM scores
% ======================================================================
function [prediction, scoreImg, argminImg] = SegmentSAM(hsIm, option, threshold)
if nargin < 2
    option = 'library';
end

if nargin < 3
    threshold = 15;
end

if strcmpi(option, 'library') % Comparison with a library of signatures
    [scoreImg, prediction, argminImg] = hsIm.ArgminSAM();
    argminImg = double(argminImg) ./ 4;

else % Comparison with a single healthy signature
    [scoreImg] = hsIm.SAMscore();
    prediction = uint8(scoreImg > threshold);
    argminImg = prediction;
end
end