function [] = CustomDistancesSegmentation(hsIm, labelInfo, reductionMethod, referenceMethod)

% numEndmembers = countEndmembersHFC(hsIm.Value,'PFA',10^-7);
if strcmpi(referenceMethod,  'nfindr')
    numEndmembers = 8;
    endmembers = nfindr(hsIm.Value,numEndmembers, 'ReductionMethod', reductionMethod);
elseif strcmpi(referenceMethod,  'ppi')
    numEndmembers = 5;
    endmembers = ppi(hsIm.Value,numEndmembers, 'ReductionMethod', reductionMethod);
elseif strcmpi(referenceMethod,  'fippi')
    numEndmembers = 5;
    endmembers = fippi(hsIm.Value,numEndmembers, 'ReductionMethod', reductionMethod);
end

w = hsiUtility.GetWavelengths(311);

figure(1);
plot(w, endmembers);   
xlabel('Band Number')
ylabel('Data Value')
legend('Location','Bestoutside');
title(sprintf('Endmembers (Num:%d)', numEndmembers));
xlim([420, 730]);
savedir = commonUtility.GetFilename('output', fullfile(config.GetSetting('SaveFolder'), config.GetSetting('FileName')), '');
plotPath = fullfile(savedir, 'endmembers');
plots.SavePlot(1, plotPath);

if sum(endmembers(:)) == 0 
    fprintf('All endmembers are zero curves for sample with id %s (%s).\n\n', hsIm.SampleID, labelInfo.Diagnosis);
else
%     %% Similarity using Frechet Distance 
%     segment.Apply(2, hsIm, endmembers, @(x,y) commonUtility.CalcDistance(x, y, @commonUtility.Frechet), labelInfo, 'endmember_frechet');
%     
%     %% Similarity using proposed 1 
%     segment.Apply(3, hsIm, endmembers, @(x,y)  commonUtility.CalcDistance(x, y, @commonUtility.ProposedDistance1), labelInfo, 'endmember_proposed1');
%     
%     %% Similarity using proposed 2 
%     segment.Apply(4, hsIm, endmembers, @(x,y)  commonUtility.CalcDistance(x, y, @commonUtility.ProposedDistance2), labelInfo, 'endmember_proposed2');
%     
    %% Similarity using proposed 3
    segment.Apply(3, hsIm, endmembers, @(x,y)  commonUtility.CalcDistance(x, y, @commonUtility.ProposedDistance3), labelInfo, 'endmember_proposed3');
    

end
end
