% ======================================================================
%> @brief hsiInfo is a class that holds tumor labels and diagnosis information.
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
        %> hsi class beforehand for the config::[Database].
        %>
        %> @b Usage
        %>
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
        %> @return instance of the hsiInfo class
        % ======================================================================
        function [obj] = hsiInfo(targetId, sampleID, labels, diagnosis)
            % hsiInfo prepares an instance of class hsiInfo.
            %
            % If the values are missing, an empty instance is returned.
            % In order to work properly, the HSI images should be read with the
            % hsi class beforehand for the config::[Database].
            %
            % @b Usage
            % @code
            %
            % labelInfo = hsiInfo('158', '001', labels, 'Carcinoma');
            % @endcode
            %
            % @param targetId [char] | The unique ID of the target sample
            % @param sampleID [char] | The sampleID of the target sample
            % @param labels [numeric array] | The labels of the target sample
            % @param diagnosis [char] | The diagnosis (disease name) of the target
            % sample
            %
            % @return instance of the hsiInfo class

            if nargin < 1
                obj = hsiInfo('', '', [], '');
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
        %> @brief ReadHsiInfo reads label information and prepares an instance of class hsiInfo.
        %>
        %> The input data should be saved in folder with config::[LabelDir]\\*.jpg.
        %> The data should be saved in folders according to tissue type, e.g.
        %> two folders with names 'Fixed', 'Unfixed' for two tissue conditions.
        %>
        %> Diagnostic data should be saved in config::[ImportDir]\\[Database]+[DiagnosisInfoTableName]
        %>
        %> @b Usage
        %>
        %> @code
        %> labelInfo = hsiInfo.ReadHsiInfo('158', '001', labels, 'Carcinoma');
        %> @endcode
        %>
        %> @param targetId [char] | The unique ID of the target sample
        %> @param sampleID [char] | The sampleID of the target sample
        %
        %> @return instance of the hsiInfo class
        % ======================================================================
        function [obj] = ReadHsiInfo(targetId, sampleId)
            % ReadHsiInfo reads label information and prepares an instance of class hsiInfo.
            %
            % The input data should be saved in folder with config::[LabelDir]\\*.jpg.
            % The data should be saved in folders according to tissue type, e.g.
            % two folders with names 'Fixed', 'Unfixed' for two tissue conditions.
            %
            % Diagnostic data should be saved in config::[ImportDir]\\[Database]+[DiagnosisInfoTableName]
            %
            % @b Usage
            %
            % @code
            % labelInfo = hsiInfo.ReadHsiInfo('158', '001', labels, 'Carcinoma');
            % @endcode
            %
            % @param targetId [char] | The unique ID of the target sample
            % @param sampleID [char] | The sampleID of the target sample
            %
            % @return instance of the hsiInfo class

            labels = hsiInfo.ReadLabel(targetId);
            diagnosis = hsiInfo.ReadDiagnosis(sampleId);
            obj = hsiInfo(targetId, sampleId, labels, diagnosis);
        end

        % ======================================================================
        %> @brief ReadHsiInfo reads label information and prepares an instance of class hsiInfo.
        %>
        %> The input data should be saved in folder with config::[LabelDir]\\*.jpg.
        %> The data should be saved in folders according to tissue type, e.g.
        %> two folders with names 'Fixed', 'Unfixed' for two tissue conditions.
        %>
        %> Diagnostic data should be saved in config::[ImportDir]\\[Database]+[DiseaseInfoTableName].
        %>
        %> @b Usage
        %>
        %> @code
        %> labelInfo = hsiInfo.ReadHsiInfoFromHsi(hsIm);
        %> @endcode
        %>
        %> @param hsIm [hsi] | An object of hsi class
        %
        %> @return instance of the hsiInfo class
        % ======================================================================
        function [obj] = ReadHsiInfoFromHsi(hsIm)
            % ReadHsiInfo reads label information and prepares an instance of class hsiInfo.
            %
            % The input data should be saved in folder with config::[LabelDir]\\*.jpg.
            % The data should be saved in folders according to tissue type, e.g.
            % two folders with names 'Fixed', 'Unfixed' for two tissue conditions.
            %
            % Diagnostic data should be saved in config::[ImportDir]\\[Database]+[DiseaseInfoTableName].
            %
            % @b Usage
            %
            % @code
            % labelInfo = hsiInfo.ReadHsiInfoFromHsi(hsIm);
            % @endcode
            %
            % @param hsIm [hsi] | An object of hsi class
            %
            % @return instance of the hsiInfo class
            targetId = hsIm.ID;
            sampleId = hsIm.SampleID;
            labels = hsiInfo.ReadLabelFromHsi(hsIm);
            diagnosis = hsiInfo.ReadDiagnosis(sampleId);
            obj = hsiInfo(targetId, sampleId, labels, diagnosis);
        end

        % ======================================================================
        %> @brief ReadLabel reads label information from a label image.
        %>
        %> The input data should be saved in folder with config::[LabelDir]\\*.jpg.
        %> The data should be saved in folders according to tissue type, e.g.
        %> two folders with names 'Fixed', 'Unfixed' for two tissue conditions.
        %>
        %> @b Usage
        %>
        %> @code
        %> labelInfo = hsiInfo.ReadLabel('158');
        %> @endcode
        %>
        %> @param targetId [char] | The unique ID of the target sample
        %
        %> @retval labelMask [numeric array] | The label mask
        % ======================================================================
        function [labelMask] = ReadLabel(targetID)
            % ReadLabel reads label information from a label image.
            %
            % The input data should be saved in folder with config::[LabelDir]\\*.jpg.
            % The data should be saved in folders according to tissue type, e.g.
            % two folders with names 'Fixed', 'Unfixed' for two tissue conditions.
            %
            % @b Usage
            %
            % @code
            % labelInfo = hsiInfo.ReadLabel('158');
            % @endcode
            %
            % @param targetId [char] | The unique ID of the target sample
            %
            % @retval labelMask [numeric array] | The label mask
            if isnumeric(targetID)
                targetID = num2str(targetID);
            end
            close all;

            hsIm = hsi.Load(targetID, 'dataset');
            [labelMask] = hsiInfo.ReadLabelFromHsi(hsIm);

        end

        % ======================================================================
        %> @brief ReadLabelFromHsi reads label information from a label image.
        %>
        %> The input data should be saved in folder with config::[LabelDir]\\*.jpg.
        %> The data should be saved in folders according to tissue type, e.g.
        %> two folders with names 'Fixed', 'Unfixed' for two tissue conditions.
        %>
        %> @b Usage
        %>
        %> @code
        %> labelInfo = hsiInfo.ReadLabelFromHsi(hsIm);
        %> @endcode
        %>
        %> @param hsIm [hsi] | An object of hsi class
        %
        %> @retval labelMask [numeric array] | The label mask
        % ======================================================================
        function [labelMask] = ReadLabelFromHsi(hsIm)
            % ReadLabelFromHsi reads label information from a label image.
            %
            % The input data should be saved in folder with config::[LabelDir]\\*.jpg.
            % The data should be saved in folders according to tissue type, e.g.
            % two folders with names 'Fixed', 'Unfixed' for two tissue conditions.
            %
            % @b Usage
            %
            % @code
            % labelInfo = hsiInfo.ReadLabelFromHsi(hsIm);
            % @endcode
            %
            % @param hsIm [hsi] | An object of hsi class
            %
            % @retval labelMask [numeric array] | The label mask

            close all;

            targetID = hsIm.ID;
            filename = fullfile(config.GetSetting('DataDir'), config.GetSetting('LabelsFolderName'), hsIm.TissueType, strcat(targetID, '.png'));
            if exist(filename, 'file') == 2
                imBase = hsIm.GetDisplayImage();
                imLab = double(imread(filename));

                fgMask = hsIm.FgMask;
                labelMask = logical(imfill(imLab, 'holes'));
                %     se = strel('disk',3);
                %     labelMask = imclose(labelMask, se);

                labelsFolder = commonUtility.GetFilename('Output', fullfile(config.GetSetting('LabelsFolderName'), strcat(targetID)), '');
                plots.Show(1, labelsFolder, labelMask);

                if size(labelMask) ~= size(fgMask)
                    labelMaskOld = labelMask;
                    labelMask = zeros(size(fgMask));
                    if abs(size(labelMaskOld, 1)-size(labelMask, 1)) > 2 || abs(size(labelMaskOld, 2)-size(labelMask, 2)) > 2
                        fprintf('The image and label matrixes differ too much in size. Please check ID: % and sample %s.\n', hsIm.ID, hsIm.SampleID);
                    end

                    if (size(labelMaskOld, 1) > size(labelMask, 1)) || (size(labelMaskOld, 2) > size(labelMask, 2))
                        labelMask = labelMaskOld(1:size(labelMask, 1), 1:size(labelMask, 2));
                    else
                        labelMask(1:size(labelMaskOld, 1), 1:size(labelMaskOld, 2)) = labelMaskOld;
                    end
                end
                labelMask = labelMask & fgMask;
                labelsAppliedFolder = commonUtility.GetFilename('Output', fullfile(config.GetSetting('LabelsAppliedFolderName'), strcat(targetID)), '');
                plots.Overlay(2, labelsAppliedFolder, imBase, labelMask);

                labelMask = uint8(labelMask);

            else
                fprintf('Missing label image for TargetID: %s and SampleID: %s. Assigning empty value. \n', targetID, hsIm.SampleID);
                labelMask = [];
            end

        end

        % ======================================================================
        %> @brief ReadDiagnosis reads diagnosis information from an excel file.
        %>
        %> Diagnostic data should be saved in config::[ImportDir]\\[Database]+[DiseaseInfoTableName].
        %>
        %> @b Usage
        %>
        %> @code
        %> labelInfo = hsiInfo.ReadDiagnosis('001');
        %> @endcode
        %>
        %> @param sampleID [char] | The sampleID of the target sample
        %
        %> @retval diagnosis [char] | The diagnosis string
        % ======================================================================
        function [diagnosis] = ReadDiagnosis(sampleId)
            % ReadDiagnosis reads diagnosis information from an excel file.
            %
            % Diagnostic data should be saved in config::[ImportDir]\\[Database]+[DiseaseInfoTableName].
            %
            % @b Usage
            %
            % @code
            % labelInfo = hsiInfo.ReadDiagnosis('001');
            % @endcode
            %
            % @param sampleID [char] | The sampleID of the target sample
            %
            % @retval diagnosis [char] | The diagnosis string

            diagnosis = '';
            dataTable = databaseUtility.GetDiagnosisTable();
            if ~isempty(dataTable)
                id = find(strcmp(dataTable.SampleID, sampleId), 1);
                if ~isempty(id)
                    diagnosis = dataTable{id, 'Diagnosis'}{1, 1};
                end
            end
        end
    end
end
