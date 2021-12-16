function [result] = ApplyRowFunc(funcName, varargin)
%APPLYROWFUNC applies a function on each row
%
%   Usage:
%   result = ApplyRowFunc(func, varargin) applies function func with
%   arguments varargin on each row of varargin
%

expectedArgs = nargin(funcName);
if expectedArgs < 0
    expectedArgs = numel(varargin);
end

rows = size(varargin{1}, 1);
result = cell(rows, 1);
newVarargin = cell(1, expectedArgs);
for i = 1:rows
    for j = 1:expectedArgs
        newVarargin{j} = varargin{j}(i, :);
    end
    result{i} = funcName(newVarargin{:});
end

if isnumeric(result{1})
    result = cell2mat(result);
end

end