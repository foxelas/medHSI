function Ttex = Table2latex(T, selectedCols, label, caption)
%     Table2latex converts a table to the tabular form for use in LaTeX.
%
%     Input args
%     T: a table of elements
%     selectedCols: index vector of table columns that need to be printed
%
%     Output args
%     Ttex: the formatted text for the table
%
%     Dependencies
%     None
%
%     Usage
%     Ttex = Table2latex(T);
%     Ttex = Table2latex(T, [1:5]);
%     The function prints the formatted table, which then
%     can be copied and pasted to LaTeX as is.
%     Created by https://github.com/foxelas/ (2020)

hasHeader = istable(T);
if hasHeader
    v = table2cell(T);
elseif iscell(T)
    v = T;
else
    error('Unsupported file format.');
end

rows = size(v, 1);

if nargin < 2
    columns = size(v, 2);
    selectedCols = 1:columns;
else
    columns = numel(selectedCols);
end

if nargin < 3
    label = '';
end

if nargin < 4
    caption = '';
end

symb = ' & ';
slant = '\\';
textRows = cell(2+rows+1, 1);
textRows{1} = strcat(slant, 'begin{table}[htb]\n', slant, 'caption{', caption, '}\n', slant, 'begin{center}\n', slant, 'label{tab:', label, '}\n{', slant, 'tt');
textRows{2} = strcat(slant, 'begin{tabular}{|');
for ii = 1:columns
    textRows{2} = strcat(textRows{2}, 'c|');
end
textRows{2} = strcat(textRows{2}, '}', slant, 'hline');

if hasHeader
    textRows{3} = strcat(strjoin(cellfun(@(x) convertCell(x), T.Properties.VariableNames(selectedCols), 'UniformOutput', false), symb), slant, slant, slant, 'hline');
    curRows = 3;
else
    curRows = 2;
end

for ii = 1:rows
    curRows = curRows + 1;
    textRows{curRows} = strcat(strjoin(cellfun(@(x) convertCell(x), v(ii, selectedCols), 'UniformOutput', false), symb), slant, slant, slant, 'hline');
end

curRows = curRows + 1;
textRows{curRows} = strcat(slant, 'end{tabular}\n}\n', slant, 'end{center}\n', slant, 'end{table}', '\n\n');

Ttex = strjoin(textRows, '\n');
fprintf(Ttex);

end

function xnew = convertCell(x)
if ischar(x)
    xnew = x;
elseif isnumeric(x)
    xnew = num2str(x, '%.3f');
elseif islogical(x)
    logVals = {'F', 'T'};
    xnew = logVals{x+1};
end
end