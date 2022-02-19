% ======================================================================
%> @brief A utility class for applying functions to different data samples
%
%> Functions using apply are applied on the currently selected dataset, 
%> unless mentioned otherwise. The dataset name is recovered from
%> config.GetSetting('dataset').
%>
% ======================================================================
classdef apply
    methods (Static)
    % ======================================================================
    %> @brief ScriptToEachImage applies a script on each of the data samples who fullfill the condition
    %>
    %> @param functionName [Function Handle] | Handle of the target function to be applied. 
    %> @param vargin [Cell array] | The arguments necessary for the target function. 
    %
    %> @retval varargout [Cell array] | The arguments returned from the target function.
    % ======================================================================
        function [varargout] = ScriptToEachImage(functionName, varargin)
    %> @brief ScriptToEachImage applies a script on each of the data samples who fullfill the condition
    %>
    %> @param functionName [Function Handle] | Handle of the target function to be applied. 
    %> @param vargin [Cell array] | The arguments necessary for the target function. 
    %
    %> @retval varargout [Cell array] | The arguments returned from the target function. 
            if nargin < 2
                varargin = {};
            end
            
            [~, targetIDs] = dataUtility.DatasetInfo();
            
            for i = 1:length(targetIDs)
                %% load HSI from .mat file
                targetName = targetIDs{i};
                hsIm = hsiUtility.LoadHSI(targetName, 'dataset');

                %% Change to Relevant Script
                if nargout(functionName) > 0
                    varargout{:} = functionName(hsIm, targetName, varargin{:});
                else
                    functionName(hsIm, targetName, varargin{:});
                    varargout{:} = {};
                end
            end
        end
        
        function [varargout] = DisableFigures(functionName, varargin)
            %%DisableFigures runs the function without showing any
            %%figures
            %   lallalslsla 
            %   Usage:
            %   DisableFigures(@apply.Kmeans);
            warning('off', 'all');
            showFigures = config.GetSetting('showFigures');
            saveImages = config.GetSetting('saveImages');

            config.SetSetting('showFigures', false);
            config.SetSetting('saveImages', false);
            warning('on', 'all');

            if nargout(functionName) > 0
                [varargout{1:nargout}] = functionName(varargin{:});
            else
                functionName(varargin{:});
                varargout{:} = {};
            end

            warning('off', 'all');
            config.SetSetting('saveImages', saveImages);
            config.SetSetting('showFigures', showFigures);
            warning('on', 'all');
        end

        function [varargout] = DisableSaveFigures(functionName, varargin)
            %%DisableSaveFigures runs the function without saving any
            %%figures
            %
            %   Usage:
            %   DisableSaveFigures(@apply.Kmeans);
            warning('off', 'all');
            saveImages = config.GetSetting('saveImages');
            config.SetSetting('saveImages', false);
            warning('on', 'all');
            if nargout(functionName) > 0
                [varargout{1:nargout}] = functionName(varargin{:});
            else
                functionName(varargin{:});
                varargout{:} = {};
            end

            warning('off', 'all');
            config.SetSetting('saveImages', saveImages);
            warning('on', 'all');
        end

        function [result] = RowFunc(varargin)
            %APPLYROWFUNC applies a function on each row
            %
            %   Usage:
            %   result = ApplyRowFunc(func, varargin) applies function func with
            %   arguments varargin on each row of varargin
            %
            [result] = ApplyRowFunc(varargin{:});
        end

        function [varargout] = OnQualityPixels(varargin)
            % APPLYONQUALITYPIXELS apply a function on only goog quality functions.
            %
            %   Usage:
            %   [coeff] = ApplyOnQualityPixels(@doPixelPCA, colMsi);
            %   applies function 'doPixelPCA' on good quality pixels of array colMsi
            [varargout{1:nargout}] = ApplyOnQualityPixels(varargin{:});
        end

        function [labels] = Kmeans(hsIm, targetName, clusterNum)
            %%Kmeans performs Kmeans clustering on the HSI
            %
            %   Usage:
            %   labels = apply.Kmeans(hsi, '158', 5);
            [labels] = KmeansInternal(hsIm, targetName, clusterNum);
        end

        function [] = SuperpixelAnalysis(varargin)
            %%SuperpixelAnalysis applies SuperPCA on an image
            %
            %   Usage:
            %   apply.SuperpixelAnalysis(hsi, targetName);
            SuperpixelAnalysisInternal(varargin{:});
        end
    end
end