function [] = Plots(fig, funcName, varargin)
%PLOTS wraps plotting functions
%
%   Usage:
%   Plots(fig, funcName, varargin) plots function with funcName and
%   arguments varargin in figure fig
%   Plots(1, @PlotSpectra, spectra)

if isnumeric(fig) && ~isempty(fig)
    %disp('Check if no overlaps appear and correct fig is saved.')
    figure(fig);
    clf(fig);
else
    fig = gcf;
end

newVarargin = varargin;
expectedArgs = nargin(funcName);
for i = (length(newVarargin) + 1):(expectedArgs - 1)
    newVarargin{i} = [];
end
newVarargin{length(newVarargin)+1} = fig;

funcName(newVarargin{:});
end