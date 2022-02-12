function [mask] = GetCustomMaskInternal(I)
%GetCustomMask returns a manually drawn polygon mask 
%
%   Usage:
%   [fgMask] = GetCustomMask(I);

    [~, ~, w] = size(I);
    
    %% Draw polygon mask
    if w > 3
        Irgb = GetDisplayImageInternal(I);
    else
        Irgb = I;
    end

    mask = roipoly(Irgb);
    title('Draw polygon')
 
end