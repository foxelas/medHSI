% ======================================================================
%> @brief A class that holds tumor labels and diagnosis information.
%
%> It is used to contain the information about the labeled dataset.
%> It works in tandem with the @b hsi class.
%>
% ======================================================================
classdef hsiInfo
    properties
        %> A string that shows the target ID
        ID = ''
        %> A string that shows the sampleID
        SampleID = ''
        %> A numeric 2D array that contains the labels of a sample
        Labels = []
        %> A string that shows the 
        Diagnosis = ''
    end

    methods 
    % ======================================================================
    %> @brief hsiInfo prepares an instance of class hsiInfo.
    %> 
    %> If the values are missing, an empty instance is returned. 
    %> In order to work properly, the HSI images should be read with the
    %> hsi class beforehand for the config::[database].
    %> 
    %> @b Usage
    %> @code
    %> labelInfo = hsiInfo('158', '001', labels, 'Carcinoma');
    %> @endcode
    %>
    %> @param targetId [char] | The unique ID of the target sample
    %> @param sampleID [char] | The sampleID of the target sample
    %> @param labels [numeric array] | The labels of the target sample
    %> @param diagnosis [char] | The diagnosis (disease name) of the target
    %> sample
    %
    %> @retval obj [hsiInfo] | The initialized hsiInfo object
    % ======================================================================
        function [obj] = hsiInfo(targetId, sampleID, labels, diagnosis)
                %> @brief hsiInfo prepares an instance of class hsiInfo.
    %> 
    %> If the values are missing, an empty instance is returned. 
    %> In order to work properly, the HSI images should be read with the
    %> hsi class beforehand for the config::[database].
    %> 
    %> @b Usage
    %> @code
    %> labelInfo = hsiInfo('158', '001', labels, 'Carcinoma');
    %> @endcode
    %>
    %> @param targetId [char] | The unique ID of the target sample
    %> @param sampleID [char] | The sampleID of the target sample
    %> @param labels [numeric array] | The labels of the target sample
    %> @param diagnosis [char] | The diagnosis (disease name) of the target
    %> sample
    %
    %> @retval obj [hsiInfo] | The initialized hsiInfo object
            if nargin < 1
                obj = hsiInfo.Empty();
            else
                obj.ID = targetId;
                obj.SampleID = sampleID;
                obj.Labels = labels;
                obj.Diagnosis = diagnosis;
            end
        end      
    end 
    
    methods (Static)
    % ======================================================================
    %> @brief Empty returns an empty instance of class hsiInfo.
    %> 
    %> @b Usage
    %> @code
    %> labelInfo = hsiInfo.Empty();
    %> @endcode
    %>
    %> @retval obj [hsiInfo] | The initialized hsiInfo object
    % ======================================================================
        function [obj] = Empty()
    %> @brief Empty returns an empty instance of class hsiInfo.
    %> 
    %> @b Usage
    %> @code
    %> labelInfo = hsiInfo.Empty();
    %> @endcode
    %>
    %> @retval obj [hsiInfo] | The initialized hsiInfo object
            obj.ID = '';
            obj.SampleID = '';
            obj.Labels = [];
            obj.Diagnosis = '';
        end
        
    % ======================================================================
    %> @brief ReadHsiInfo reads label information and prepares an instance of class hsiInfo.
    %> 
    %> The input data should be saved in folder with config::[outputDir]\[labelDir]\.
    %> The data should be saved in folders according to tissue type, e.g.
    %> two folders with names 'Fixed', 'Unfixed' for two tissue conditions.
    %> 
    %> Diagnostic data should be saved in config::[importDir]\[database]\[diseaseInfoTableName]
    %> 
    %> @b Usage
    %> @code
    %> labelInfo = hsiInfo.ReadHsiInfo('158', '001', labels, 'Carcinoma');
    %> @endcode
    %>
    %> @param targetId [char] | The unique ID of the target sample
    %> @param sampleID [char] | The sampleID of the target sample
    %
    %> @retval obj [hsiInfo] | The initialized hsiInfo object
    % ======================================================================
    function [obj] = ReadHsiInfo(targetId, sampleId)
    %> @brief ReadHsiInfo reads label information and prepares an instance of class hsiInfo.
    %> 
    %> The input data should be saved in folder with config::[outputDir]\[labelDir]\.
    %> The data should be saved in folders according to tissue type, e.g.
    %> two folders with names 'Fixed', 'Unfixed' for two tissue conditions.
    %> 
    %> Diagnostic data should be saved in config::[importDir]\[database]\[diseaseInfoTableName]
    %> 
    %> @b Usage
    %> @code
    %> labelInfo = hsiInfo.ReadHsiInfo('158', '001', labels, 'Carcinoma');
    %> @endcode
    %>
    %> @param targetId [char] | The unique ID of the target sample
    %> @param sampleID [char] | The sampleID of the target sample
    %
    %> @retval obj [hsiInfo] | The initialized hsiInfo objects
            labels = hsiInfo.ReadLabel(targetId);
            diagnosis = hsiInfo.ReadDiagnosis(sampleId);
            obj = hsiInfo(targetId, sampleId, labels, diagnosis);
    end
       
    % ======================================================================
    %> @brief ReadLabel reads label information from a label image.
    %> 
    %> The input data should be saved in folder with config::[outputDir]\[labelDir]\.
    %> The data should be saved in folders according to tissue type, e.g.
    %> two folders with names 'Fixed', 'Unfixed' for two tissue conditions.
    %> 
    %> @b Usage
    %> @code
    %> labelInfo = hsiInfo.ReadLabel('158');
    %> @endcode
    %>
    %> @param targetId [char] | The unique ID of the target sample
    %
    %> @retval labelMask [numeric array] | The label mask
    % ======================================================================  
        function [labelMask] = ReadLabel(targetID)
    %> @brief ReadLabel reads label information from a label image.
    %> 
    %> The input data should be saved in folder with config::[outputDir]\[labelDir]\.
    %> The data should be saved in folders according to tissue type, e.g.
    %> two folders with names 'Fixed', 'Unfixed' for two tissue conditions.
    %> 
    %> @b Usage
    %> @code
    %> labelInfo = hsiInfo.ReadLabel('158');
    %> @endcode
    %>
    %> @param targetId [char] | The unique ID of the target sample
    %
    %> @retval labelMask [numeric array] | The label mask

            if isnumeric(targetID)
                targetID = num2str(targetID);
            end
            close all; 
            
            hsIm = hsiUtility.LoadHSI(targetID, 'dataset');           
            maskdir = fullfile(config.GetSetting('labelDir'), hsIm.TissueType);
            dirList = dir(fullfile(maskdir, '*.jpg'));
            labelFilenames = cellfun(@(x) strsplit(x, '_'), dirList.name, 'un', 0);
            idx = find(contains(labelFilenames{:,1}, hsIm.SampleID), 1);
            
            if ~isempty(idx)
                imBase = hsIm.GetDisplayImage();
                imLab = imread(fullfile(maskdir, labelFilenames{idx}));
                
                fgMask = hsIm.FgMask;
                labelMask = rgb2gray(imLab) <= 127;
                labelMask = imfill(labelMask, 'holes');
                %     se = strel('disk',3);
                %     labelMask = imclose(labelMask, se);

                figure(1);
                imshow(fgMask);
                
                figure(2);
                imshow(labelMask);

                labelMask = labelMask & fgMask;
                c = imoverlay(imBase, labelMask, 'c');
                
                figure(3);
                imshow(c);

                config.SetSetting('plotName', config.DirMake(config.GetSetting('output'), config.GetSettin('labels'), strcat(targetID)));
                plots.SavePlot(2);

                config.SetSetting('plotName', config.DirMake(config.GetSetting('output'), config.GetSettin('labelsApplied'), strcat(targetID)));
                plots.SavePlot(3);
            
            else
                fprintf('Missing label image for TargetID: %s and SampleID: %s. Assigning empty value. \n', targetID, hsIm.SampleID);
                labelMask = [];
            end
            
            labelMask = uint(labelMask);
        end
        
     % ======================================================================
    %> @brief ReadDiagnosis reads diagnosis information from an excel file.
    %> 
    %> Diagnostic data should be saved in config::[importDir]\[database]\[diseaseInfoTableName]
    %> 
    %> @b Usage
    %> @code
    %> labelInfo = hsiInfo.ReadDiagnosis('001');
    %> @endcode
    %>
    %> @param sampleID [char] | The sampleID of the target sample
    %
    %> @retval diagnosis [char] | The diagnosis string
    % ======================================================================  
        function [diagnosis] = ReadDiagnosis(sampleId)
                %> @brief ReadDiagnosis reads diagnosis information from an excel file.
    %> 
    %> Diagnostic data should be saved in config::[importDir]\[database]\[diseaseInfoTableName]
    %> 
    %> @b Usage
    %> @code
    %> labelInfo = hsiInfo.ReadDiagnosis('001');
    %> @endcode
    %>
    %> @param sampleID [char] | The sampleID of the target sample
    %
    %> @retval diagnosis [char] | The diagnosis string
    
            dataTable = databaseUtility.GetDiseaseTable();
            id = find(strcmp(dataTable.SampleID, sampleId), 1);
            if ~isempty(id)
                diagnosis = dataTable{id, 'Diagnosis'}{1,1};
            else
                diagnosis = '';
            end
        end
    end
end
    