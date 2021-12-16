classdef Apply
    methods(Static)
%% Contents 
%
%   Static:
%         [varargout] = ScriptToEachImage(functionName, condition, target, varargin)
%         [result] = RowFunc(funcName, varargin)
%         [varargout] = OnQualityPixels(func, varargin)

        function [varargout] = ScriptToEachImage(varargin)
            [varargout] = ApplyScriptToEachImage(varargin{:});
        end
        
        function [result] = RowFunc(varargin)
            [result] = ApplyRowFunc(varargin{:});
        end
        
        function [varargout] = OnQualityPixels(varargin)
            [varargout] = ApplyOnQualityPixels(varargin{:});
        end
    end
end