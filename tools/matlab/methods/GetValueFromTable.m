function [value] = GetValueFromTable(tab, field, id)
%%GETVALUEFROMTABLE get a value from specific column in a table
%
%   Usage:
%   value = GetValueFromTable(tab, field, id)

column = tab.(field);
value = column{id};
end