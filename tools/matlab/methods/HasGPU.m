function [hasGpu] = HasGPU()
%HASGPU informs whether there is gpu available
%
%   Usage:
%   hasGpu = HasGPU()

v = dbstack;
if numel(v) > 1
    parentName = v(2).name;
else
    parentName = 'none';
end
isFirst = contains(parentName, 'initialization');
if isFirst
    %pcName = char(java.net.InetAddress.getLocalHost.getHostName);
    %if stcmp(pcName, 'GPU-PC2') == 0
    if length(ver('parallel')) == 1
        SetSetting('pcHasGPU', true);
    end
end
hasGpu = GetSetting('pcHasGPU');
end