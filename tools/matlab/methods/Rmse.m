function rmse = Rmse(reconstructed, measured)
% RMSE returns the Root Mean Square Error
%
%   Usage:
%   rmse = Rmse(reconstructed, measured)

N = size(measured, 2);
rmse = sqrt(((measured - reconstructed) * (measured - reconstructed)')/N);
end