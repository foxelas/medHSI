% ======================================================================
%> @brief DistanceScoresInternal returns similarity clustering labels for a target hsi based on a references set of spectral curves.
%>
%> You can set the spectral distance metric with funcHandle.
%> Common spectral ditance metrics are @@sam, sid, @jmsam, @ns3, @sidsam.
%>
%> @b Usage
%>
%> @code
%> clusterLabels = DistanceScoresInternal(target, endmembers, @sam);
%>
%> clusterLabels = hsIm.DistanceScores(target, endmembers, @sam);
%> @endcode
%>
%> @param target [numeric array] | An 3D hsi value
%> @param references [numeric array] | An array of spectral references
%> @param funcHandle [function handle] | Optional: The spectral distance measure. Default: SAM.
%>
%> @retval clusterLabels [numeric array] | The labels based on minimum distance.
% ======================================================================
function [clusterLabels] = DistanceScoresInternal(target, references, funcHandle)
% DistanceScoresInternal returns similarity clustering labels for a target hsi based on a references set of spectral curves.
%
% You can set the spectral distance metric with funcHandle.
% Common spectral ditance metrics are @@sam, sid, @jmsam, @ns3, @sidsam.
%
% @b Usage
%
% @code
% clusterLabels = DistanceScoresInternal(target, endmembers, @sam);
%
% clusterLabels = hsIm.DistanceScores(target, endmembers, @sam);
% @endcode
%
% @param target [numeric array] | An 3D hsi value
% @param references [numeric array] | An array of spectral references
% @param funcHandle [function handle] | Optional: The spectral distance measure. Default: SAM.
%
% @retval clusterLabels [numeric array] | The labels based on minimum distance.

if nargin < 3
    funcHandle = @sam;
end

numEndmembers = size(references, 2);
%%Find discrepancy metrics
[h, w, z] = size(target);
isNonZeroEndmember = any(references, 1);
distanceScores = zeros(h, w, sum(isNonZeroEndmember));
k = 0;
for i = 1:numEndmembers
    if isNonZeroEndmember(i)
        k = k + 1;
        distanceScores(:, :, k) = funcHandle(target, references(:, i));
    end
end
k = sum(isNonZeroEndmember);
[~, clusterLabels] = min(distanceScores, [], 3);

for i = k:-1:2
    %%If cluster pixels are less than feature dimension, then merge it
    %%with the previous cluster
    if sum(clusterLabels == i, 'all') <= z
        clusterLabels(clusterLabels == i) = i - 1;
    end
end

end