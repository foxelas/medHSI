classdef apply
    methods
%% Contents 
%
%   Static:
%         [varargout] = ScriptToEachImage(functionName, condition, target, varargin)
%         [result] = RowFunc(funcName, varargin)
%         [varargout] = OnQualityPixels(func, varargin)

        function [varargout] = ScriptToEachImage(functionName, condition, target, varargin)
            [varargout] = ApplyScriptToEachImage(functionName, condition, target, varargin);
        end
        
        function [result] = RowFunc(funcName, varargin)
            [result] = ApplyRowFunc(funcName, varargin);
        end
        
        function [varargout] = OnQualityPixels(func, varargin)
            [varargout] = ApplyOnQualityPixels(func, varargin);
        end
    end
end