function [setId] = SelectDatabaseSamples(dataTable, setId)
%SelectDatabaseSamples from DataInfo table in order to ignore incorrect
%samples inside Query.m
%
%   Usage:
%   [setId] = SelectDatabaseSamples(dataTable, setId)

setId = setId & ~contains(lower(dataTable.SampleID), 'b');
end