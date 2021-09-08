function nmse = Nmse(reconstructed, measured)
% Nmse returns the Normalized Mean Square Error
%
%   Usage:
%   nmse = Nmse(reconstructed, measured)

nmse = (measured - reconstructed) * (measured - reconstructed)' / (measured * reconstructed');
end