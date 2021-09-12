function [pHsi] = Preprocessing(hsi)
% Preprocessing prepares normalized data according to our specifications
%
%   Usage:
%   pHsi = Preprocessing(hsi);
%
%   YOU CAN CHANGE THIS FUNCTION ACCORDING TO YOUR SPECIFICATIONS

hsi = hsi(:, :, [420:730]-380);
[updI, ~] = RemoveBackground(hsi);
pHsi = updI;

end