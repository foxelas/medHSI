% ======================================================================
%> @brief SegmentHypercubeToolbox applies Endmember-based segmentation to an hsi.
%>
%> Pixels are clustered according to spectral similarity to reference endmembers.
%>
%> You can add a custom spectral similarity method at @c commonUtility.ProposedDistance
%>
%> @b Usage
%>
%> @code
%> [prediction, endmembers, abundanceMap] = segment.Apply(hsIm, 'HypercubeToolbox', 'pca', 'nfindr', 'sid');
%>
%> [prediction, endmembers, abundanceMap] = SegmentHypercubeToolbox(hsIm, 'pca', 'nfindr', 'sid');
%> @endcode
%>
%> @param hsIm [hsi] | An instance of the hsi class
%> @param reductionMethod [char] | The reduction method. Options: ['PCA', 'MNF']. Default: 'library'.
%> @param referenceMethod [char] | The reference method for endmember calculation. Options: ['nfindr', 'ppi', 'fippi'].
%> @param similarityMethod [char] | The similarity method for clustering according to similarity to endmembers. Options: ['sid', 'jmsam', 'sid-sam', 'ns3', 'sam', 'custom'].
%>
%> @retval prediction [numeric array] | The predicted labels
%> @retval endmembers [numeric array] | The endmembers used for similarity clustering
%> @retval abundanceMap [numeric array] | The abundance map for each endmember
% ======================================================================
function [prediction, endmembers, abundanceMap] = SegmentHypercubeToolbox(hsIm, reductionMethod, referenceMethod, similarityMethod)

if strcmpi(reductionMethod, 'PCA') || strcmpi(reductionMethod, 'MNF')
    disp('Incorrect reduction method. Please select PCA or MNF.');
end

% numEndmembers = countEndmembersHFC(hsIm.Value,'PFA',10^-7);
endmembers = hsIm.FindPurePixels(numEndmembers, referenceMethod, reductionMethod);

switch similarityMethod
    case 'sid'

        %% Similarity using spectral information divergence (SID)
        % Chein-I Chang. “An Information-Theoretic Approach to Spectral Variability, Similarity, and Discrimination for Hyperspectral Image Analysis.” IEEE Transactions on Information Theory 46, no. 5 (August 2000): 1927–32. https://doi.org/10.1109/18.857802.
        funHandle = @sid;
    case 'jmsam'

        %% Similarity using Jeffries Matusita-Spectral Angle Mapper (JMSAM)
        % Padma, S., and S. Sanjeevi. “Jeffries Matusita Based Mixed-Measure for Improved Spectral Matching in Hyperspectral Image Analysis.” International Journal of Applied Earth Observation and Geoinformation 32 (October 2014): 138–51. https://doi.org/10.1016/j.jag.2014.04.001.
        funHandle = @jmsam;
    case 'sid-sam'

        %% Similarity using spectral information divergence-spectral angle mapper (SID-SAM) hybrid method
        %  Chang, Chein-I. “New Hyperspectral Discrimination Measure for Spectral Characterization.” Optical Engineering 43, no. 8 (August 1, 2004): 1777. https://doi.org/10.1117/1.1766301.
        funHandle = @sidsam;
    case 'ns3'

        %% Similarity using normalized spectral similarity score (NS3)
        % Nidamanuri, Rama Rao, and Bernd Zbell. “Normalized Spectral Similarity Score (NS3) as an Efficient Spectral Library Searching Method for Hyperspectral Image Classification.” IEEE Journal of Selected Topics in Applied Earth Observations and Remote Sensing 4, no. 1 (March 2011): 226–40. https://doi.org/10.1109/JSTARS.2010.2086435.
        funHandle = @ns3;
    case 'sam'

        %% Similarity using spectral angle mapper (SAM)
        % Kruse, F.A., A.B. Lefkoff, J.W. Boardman, K.B. Heidebrecht, A.T. Shapiro, P.J. Barloon, and A.F.H. Goetz. “The Spectral Image Processing System (SIPS)—Interactive Visualization and Analysis of Imaging Spectrometer Data.” Remote Sensing of Environment 44, no. 2–3 (May 1993): 145–63. https://doi.org/10.1016/0034-4257(93)90013-N.
        funHandle = @sam;
    case 'custom'

        %% Add a custom metric for spectral similarity
        funHandle = @(x, y) commonUtility.CalcDistance(x, y, @commonUtility.ProposedDistance);

    otherwise
        error('Unavailable similarity method.');
end

colSum = sum(endmembers, 1);
n = sum(colSum > 0);
score = zeros(size(hsIm.Value, 1), size(hsIm.Value, 2), n);
k = 0;
for i = 1:numEndmembers
    if colSum(i) > 0
        k = k + 1;
        score(:, :, k) = funHandle(hsIm.Value, endmembers(:, i));
    end
end

[~, prediction] = min(score, [], 3);
abundanceMap = estimateAbundanceLS(hsIm.Value, endmembers);
end