function [] = HypercubeToolboxAnalysis(hsIm, labelInfo, reductionMethod, referenceMethod)

colHsIm = hsIm.GetMaskedPixels();
n = size(colHsIm, 1);
F = factor(n);
if F(1) > 0 && F(1) ~= n
    rscolHsIm = reshape(colHsIm, [n / F(1), F(1), size(colHsIm, 2)]);
else
    colHsIm = colHsIm(1:(n - 1), :);
    n = n - 1;
    F = factor(n);
    rscolHsIm = reshape(colHsIm, [n / F(1), F(1), size(colHsIm, 2)]);
end

% numEndmembers = countEndmembersHFC(hsIm.Value,'PFA',10^-7);
if strcmpi(referenceMethod, 'nfindr')
    numEndmembers = 8;
    endmembers = nfindr(rscolHsIm, numEndmembers, 'ReductionMethod', reductionMethod);
elseif strcmpi(referenceMethod, 'ppi')
    numEndmembers = 5;
    endmembers = ppi(rscolHsIm, numEndmembers, 'ReductionMethod', reductionMethod);
elseif strcmpi(referenceMethod, 'fippi')
    numEndmembers = 5;
    endmembers = fippi(rscolHsIm, numEndmembers, 'ReductionMethod', reductionMethod);
end

w = hsiUtility.GetWavelengths(311);

figure(1);
plot(w, endmembers);
xlabel('Band Number')
ylabel('Data Value')
legend('Location', 'Bestoutside');
title(sprintf('Endmembers (Num:%d)', numEndmembers));
xlim([420, 730]);
savedir = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'), config.GetSetting('FileName')), '');
plotPath = fullfile(savedir, 'endmembers');
plots.SavePlot(1, plotPath);

if sum(endmembers(:)) == 0
    fprintf('All endmembers are zero curves for sample with id %s (%s).\n\n', hsIm.SampleID, labelInfo.Diagnosis);
else

    %% Similarity using spectral information divergence (SID)
    % Chein-I Chang. “An Information-Theoretic Approach to Spectral Variability, Similarity, and Discrimination for Hyperspectral Image Analysis.” IEEE Transactions on Information Theory 46, no. 5 (August 2000): 1927–32. https://doi.org/10.1109/18.857802.
    segment.Apply(2, hsIm, endmembers, @sid, labelInfo, 'endmember_sid');

    %% Similarity using Jeffries Matusita-Spectral Angle Mapper (JMSAM)
    % Padma, S., and S. Sanjeevi. “Jeffries Matusita Based Mixed-Measure for Improved Spectral Matching in Hyperspectral Image Analysis.” International Journal of Applied Earth Observation and Geoinformation 32 (October 2014): 138–51. https://doi.org/10.1016/j.jag.2014.04.001.
    segment.Apply(3, hsIm, endmembers, @jmsam, labelInfo, 'endmember_jmsam');

    %% Similarity using spectral information divergence-spectral angle mapper (SID-SAM) hybrid method
    %  Chang, Chein-I. “New Hyperspectral Discrimination Measure for Spectral Characterization.” Optical Engineering 43, no. 8 (August 1, 2004): 1777. https://doi.org/10.1117/1.1766301.
    segment.Apply(4, hsIm, endmembers, @sidsam, labelInfo, 'endmember_sidsam');

    %% Similarity using normalized spectral similarity score (NS3)
    % Nidamanuri, Rama Rao, and Bernd Zbell. “Normalized Spectral Similarity Score (NS3) as an Efficient Spectral Library Searching Method for Hyperspectral Image Classification.” IEEE Journal of Selected Topics in Applied Earth Observations and Remote Sensing 4, no. 1 (March 2011): 226–40. https://doi.org/10.1109/JSTARS.2010.2086435.
    segment.Apply(5, hsIm, endmembers, @ns3, labelInfo, 'endmember_ns3');

    %% Similarity using spectral angle mapper (SAM)
    % Kruse, F.A., A.B. Lefkoff, J.W. Boardman, K.B. Heidebrecht, A.T. Shapiro, P.J. Barloon, and A.F.H. Goetz. “The Spectral Image Processing System (SIPS)—Interactive Visualization and Analysis of Imaging Spectrometer Data.” Remote Sensing of Environment 44, no. 2–3 (May 1993): 145–63. https://doi.org/10.1016/0034-4257(93)90013-N.
    segment.Apply(6, hsIm, endmembers, @sam, labelInfo, 'endmember_sam');
end
end
