function sig = normaliseRMS(sig, out_rms)

% normalise a signal to a specified rms
%
%	sig - a waveform containing the signal or target
%   out_rms - rms output of final wave. Signal unchanged if rms=0
%		(Note! rms values are calculated Matlab style with waveform values assumed to 
%		be in the range +/- 1)
%
% Stuart Rosen stuart@phon.ucl.ac.uk
% August 2006

if out_rms>0
   % Calculate the rms level of the signal
   rms = norm(sig)/sqrt(length(sig));
   % Scale total to obtain desired rms
   sig = sig * out_rms/rms;
   % do something if clipping occurs
   [sig, correction] = no_clip(sig);
   if correction<-15 % allow a maximum of 15 dB attenuation 
      error('Output signal attenuated by too much.'); 
   end
end

