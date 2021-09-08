function gfc = GoodnessOfFit(reconstructed, measured)
% GoodnessOfFit returns the Goodness Of Fit criterion
%
%   Usage:
%   gfc = GoodnessOfFit(reconstructed, measured)

if size(reconstructed) ~= size(measured)
    reconstructed = reconstructed';
end
gfc = abs(reconstructed*measured') / (sqrt(sum(reconstructed.^2)) * sqrt(sum(measured.^2)));
end