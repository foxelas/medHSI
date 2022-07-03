% ======================================================================
%> @brief SegmentHypercubeToolboxAndShow applies Endmember-based segmentation to an hsi and plots image results.
%>
%> Pixels are clustered according to spectral similarity to reference endmembers.
%>
%> You can add a custom spectral similarity method at @c commonUtility.ProposedDistance
%>
%> Need to set config::[SaveFolder] for image output.
%>
%> @b Usage
%>
%> @code
%> segment.ApplyAndShow('HypercubeToolbox', 'pca', 'nfindr', 'sid');
%>
%> prediction = HypercubeToolboxAndShow(hsIm, labelInfo, 'pca', 'nfindr', 'sid');
%> @endcode
%>
%> @param hsIm [hsi] | An instance of the hsi class
%> @param labelInfo [hsiInfo] | An instance of the hsiInfo class
%> @param reductionMethod [char] | The reduction method. Options: ['PCA', 'MNF']. Default: 'library'.
%> @param referenceMethod [char] | The reference method for endmember calculation. Options: ['nfindr', 'ppi', 'fippi'].
%> @param similarityMethod [char] | The similarity method for clustering according to similarity to endmembers. Options: ['sid', 'jmsam', 'sid-sam', 'ns3', 'sam', 'custom'].
%>
%> @retval prediction [numeric array] | The predicted labels
% ======================================================================
function [prediction] = HypercubeToolboxAndShow(hsIm, labelInfo, reductionMethod, referenceMethod, similarityMethod)

hasLabels = ~isempty(labelInfo);

[prediction, endmembers, abundanceMap] = SegmentHypercubeToolbox(hsIm, reductionMethod, referenceMethod, similarityMethod);

w = hsiUtility.GetWavelengths(311);


if sum(endmembers(:)) == 0
    fprintf('All endmembers are zero curves for sample with id %s (%s).\n\n', hsIm.SampleID, labelInfo.Diagnosis);
else

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

    figure(2);
    montage(abundanceMap,'Size',[2 4],'BorderSize',[10 10]);
    colormap default
    title('Abundance Maps for Endmembers');
    plotPath = fullfile(savedir, strcat(saveName, '_abundance'));
    plots.SavePlot(2, plotPath);
    
    if hasLabels
        figure(3);
        savedir = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'), config.GetSetting('FileName')), '');
        srgb = hsIm.GetDisplayImage();
        img = {srgb, prediction};
        names = {labelInfo.Diagnosis, 'Clustering'};
        plotPath = fullfile(savedir, 'clustering');
        plots.MontageWithLabel(3, plotPath, img, names, labelInfo.Labels, hsIm.FgMask);       
    end
    
end

end