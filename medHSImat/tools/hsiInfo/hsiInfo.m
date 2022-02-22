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
        %> hsi class beforehand for the config::[database].
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
            % hsi class beforehand for the config::[database].
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
        %> The input data should be saved in folder with config::[labelDir]\\*.jpg.
        %> The data should be saved in folders according to tissue type, e.g.
        %> two folders with names 'Fixed', 'Unfixed' for two tissue conditions.
        %>
        %> Diagnostic data should be saved in config::[importDir]\\[database]+[diagnosisInfoTableName]
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
            % The input data should be saved in folder with config::[labelDir]\\*.jpg.
            % The data should be saved in folders according to tissue type, e.g.
            % two folders with names 'Fixed', 'Unfixed' for two tissue conditions.
            %
            % Diagnostic data should be saved in config::[importDir]\\[database]+[diseaseInfoTableName].
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
        %> The input data should be saved in folder with config::[labelDir]\\*.jpg.
        %> The data should be saved in folders according to tissue type, e.g.
        %> two folders with names 'Fixed', 'Unfixed' for two tissue conditions.
        %>
        %> Diagnostic data should be saved in config::[importDir]\\[database]+[diseaseInfoTableName].
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
            % The input data should be saved in folder with config::[labelDir]\\*.jpg.
            % The data should be saved in folders according to tissue type, e.g.
            % two folders with names 'Fixed', 'Unfixed' for two tissue conditions.
            %
            % Diagnostic data should be saved in config::[importDir]\\[database]+[diseaseInfoTableName].
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
        %> The input data should be saved in folder with config::[labelDir]\\*.jpg.
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
            % The input data should be saved in folder with config::[labelDir]\\*.jpg.
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
        %> The input data should be saved in folder with config::[labelDir]\\*.jpg.
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
            % The input data should be saved in folder with config::[labelDir]\\*.jpg.
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
            maskdir = fullfile(config.GetSetting('dataDir'), config.GetSetting('labelsFolderName'), hsIm.TissueType);
            dirList = dir(fullfile(maskdir, '*.jpg'));
            if ~isempty(dirList)
                labelFilenames = cellfun(@(x) strsplit(x, '_'), {dirList.name}', 'un', 0);
                labelFilenames = cellfun(@(x) x(1), labelFilenames, 'un', 0);
                labelFilenames = arrayfun(@(x) x{1}, labelFilenames);
                idx = find(contains(labelFilenames, hsIm.SampleID), 1);
            else
                idx = [];
            end

            if ~isempty(idx)
                imBase = hsIm.GetDisplayImage();
                imLab = imread(fullfile(maskdir, dirList(idx).name));

                fgMask = hsIm.FgMask;
                labelMask = im2gray(imLab) > 127;
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

                config.SetSetting('plotName', config.DirMake(config.GetSetting('outputDir'), config.GetSetting('labels'), strcat(targetID)));
                plots.SavePlot(2);

                config.SetSetting('plotName', config.DirMake(config.GetSetting('outputDir'), config.GetSetting('labelsApplied'), strcat(targetID)));
                plots.SavePlot(3);

                labelMask = uint8(labelMask);

            else
                fprintf('Missing label image for TargetID: %s and SampleID: %s. Assigning empty value. \n', targetID, hsIm.SampleID);
                labelMask = [];
            end

        end

        % ======================================================================
        %> @brief ReadDiagnosis reads diagnosis information from an excel file.
        %>
        %> Diagnostic data should be saved in config::[importDir]\\[database]+[diseaseInfoTableName].
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
            % Diagnostic data should be saved in config::[importDir]\\[database]+[diseaseInfoTableName].
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
