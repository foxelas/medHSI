%======================================================================
%> @brief FoldIndexes returns the sample ids for different folds. 
%>
%> @b Usage
%>
%> @code
%> foldSampleIds = trainUtility.FoldIndexes(foldType);
%>
%> foldSampleIds = GetFolds(foldType);
%> @endcode
%>
%> @param foldType [char] | Optional: The type for selecting sample ids for folds. Options: ['byPatient', 'bySample']. Default: 'bySample'. 
%======================================================================
function [foldSampleIds] = GetFolds(foldType)

    if nargin < 1 
        foldType = 'bySample';
    end
        
    [~, targetIDs] = commonUtility.DatasetInfo();
    
    splits = cellfun(@(x) (strsplit(x, '_')), targetIDs, 'UniformOutput', false);
    sampleIds = unique( cellfun(@(x) char(x{1}), splits, 'UniformOutput', false));
    
    if strcmpi(foldType, 'bySample')
        foldSampleIds = sampleIds;
        
    elseif strcmpi(foldType, 'byPatient')
        [~, targetIDsAll, outRows] = databaseUtility.Query();
        targetIDsAll = arrayfun(@(x) num2str(x), targetIDsAll, 'UniformOutput', false);
        [~, ~, ids] = intersect(sampleIds, targetIDsAll);
        patientNumbers = table2array(outRows(ids, 'Patient'));
        sampleIds = table2array(outRows(ids, 'SampleID')); 
        unPatientNumbers = unique(patientNumbers);
        
        foldSampleIds = cell(numel(unPatientNumbers), 1); 
        for i = 1:numel(unPatientNumbers)
           k = unPatientNumbers(i);
           foldSampleIds{i} = sampleIds(patientNumbers == k);
        end
    end
   
 end