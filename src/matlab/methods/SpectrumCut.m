function [newSpectrum, newX] = SpectrumCut(oldSpectrum, x)
%SPECTRUMCUT removes noisy bands from the spectrum
%
%   Usage:
%   [newSpectrum, newX] = SpectrumCut(oldSpectrum, 380:780)

ids = x >= 420 & x <= 730;
newX = x(ids);
newSpectrum = oldSpectrum(ids);
end