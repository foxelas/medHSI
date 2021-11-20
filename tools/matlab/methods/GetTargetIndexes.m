function [targetIDs, outRows] = GetTargetIndexes(content, target)
%GetTargetIndexes returns target indexes and relevant rows from the DB in
%order to access specific categories of *tissue* samples.
%
%   Usage:
%   [targetIDs, outRows] = GetTargetIndexes(); %all
%   [targetIDs, outRows] = GetTargetIndexes([], 'fix'); %fix
%   [targetIDs, outRows] = GetTargetIndexes({'tissue', true}, 'raw'); %raw

if nargin < 1 || isempty(content) 
	content = {'tissue', true};
end

if nargin < 2 || isempty(target) || strcmp(target, 'all')
    target = [];
else
    target = {target, false};
end
[~, targetIDs, outRows] = Query(content, [], [], [], [], target, []);    
    
end 