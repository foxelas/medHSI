classdef apply
    methods (Static)

        %% Contents
        %
        %   Static:
        %         [varargout] = ScriptToEachImage(functionName, condition, target, varargin)
        %         [result] = RowFunc(funcName, varargin)
        %         [varargout] = OnQualityPixels(func, varargin)
        %         [labels] = Kmeans(hsIm, targetName, clusterNum)
        %         [] = SuperpixelAnalysis(hsIm, targetName, isManual, pixelNum, pcNum)
        %         [varargout] = DisableFigures(functionName, varargin)
        %         [varargout] = DisableSaveFigures(functionName, varargin)

        function [varargout] = ScriptToEachImage(varargin)
            %%ApplyScriptToEachImage applies a script on each of the data samples who
            %%fullfill the condition
            %
            %   Usage:
            %   ApplyScriptToEachImage(@apply.Kmeans);
            %   ApplyScriptToEachImage(@apply.Kmeans, {'tissue', true}, []);

            [varargout{1:nargout}] = ApplyScriptToEachImage(varargin{:});
        end

        function [varargout] = DisableFigures(functionName, varargin)
            %%DisableFigures runs the function without showing any
            %%figures
            %
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