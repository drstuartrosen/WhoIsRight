function sig = AddNoise(sig, nz, rms_sig, Fs, snr, duration, fixed, in_rms, out_rms, warning_noise_duration, RiseFall)

%   modified from add_noise(SignalWav, NoiseWav, snr, duration, out_rms) as
%   used by Jude Barwell in her 4th year project. Changed in many ways.
%
% 	Combine a noise and signal waveform at an arbitrary signal-to-noise ratio
%   Return the wave
%	The level of the signal or noise can be fixed, and the output level can be normalised
%	Randomize the starting point of the noise
%
%	sig - a waveform containing the signal or target
%	nz - a waveform containing the noise (must be longer in duration than signal)
%   rms_sig - specified as the SignalWav may contain silences
%   Fs - sampling frequency
%	snr - signal-to-noise ratio at which to combine the waveforms
%	duration - (ms) of final waveform. If 0, the signal duration is used
%   fixed - 'noise' or 'signal' to be fixed in level at level specified by in_rms
%   in_rms - if 0, level of signal or noise left unchanged
%   out_rms - rms output of final combined wave. Signal unchanged if rms=0
%		(Note! rms values are calculated Matlab style with waveform values assumed to 
%		be in the range +/- 1)
%   warning_noise_duration - extra section of noise to serve as precursor to
%       stimulus word (ms)
%
% Stuart Rosen stuart@phon.ucl.ac.uk
% July 2006

RISE_FALL = 50;    % taper the noise on and off, and add this duration to start and finish of signal (was 200)
                   % This is in addition to the warning_noise_duration
                   
                
if nargin < 11
    RiseFall = RISE_FALL;
end

nz_samples=length(nz);
n_samples=length(sig);
n_original_sig=length(sig);

n_augmented = 0;
if (duration>0) % make output waveform this duration
   duration = Fs * duration/1000; % number of sample points in total
   % ensure signal is not longer than this already
   if n_samples>duration 
      error('The signal waveform is too long for given duration.'); 
   end
   % augment signal with zeros
   n_augmented = round((duration-n_samples)/2);
   sig = [zeros(1,n_augmented) sig' zeros(1,round(n_augmented))]';
   n_samples=length(sig);
end

rise_fall = floor(Fs * RiseFall/1000); % number of sample points for rise and fall
if RiseFall>0 | warning_noise_duration>0
   warning_noise_duration = floor(Fs * warning_noise_duration/1000); % number of sample points for extra noise
   % augment signal with zeros at start and finish
   sig = [zeros(1,rise_fall) zeros(1,warning_noise_duration) sig zeros(1,rise_fall)]';
   n_samples=length(sig);
end

if nz_samples<n_samples 
   error('The noise waveform is not long enough.'); 
end

% select a random portion of the noise file, of the appropriate length
start = floor((nz_samples-n_samples)*rand);
noise = nz(start:start+n_samples-1);

% Calculate the rms levels of the noise
rms_noise = norm(noise)/sqrt(length(noise));

% put on rises and falls
% Done after calculation of noise rms
noise=taper(noise, RiseFall, RiseFall, Fs);

% calculate the multiplicative factor for the signal-to-noise ratio
snr = 10^(snr/20);
   
if strcmp(fixed, 'signal') % fix the signal level and scale the noise
   error('Fixed signal not yet fully implemented!!');
   if in_rms>0 % scale the signal to the desired level, then scale the level of the noise and add it in to the signal
      
   else % leave the signal as is, then scale the level of the noise and add it in to the signal
      sig = sig + noise * (rms_sig/(snr * rms_noise));
   end   
elseif strcmp(fixed, 'noise') % fix the noise level and scale the signal
   if in_rms>0 % scale the noise to the desired level, then scale the level of the signal and add it to the noise
      sig = (noise * in_rms/rms_noise) + sig * (snr*in_rms)/rms_sig;
   else % leave the noise as is, then scale the level of the signal and add it to the noise
      sig = noise + sig * (snr*rms_noise)/rms_sig;
   end  
else
   error('Fixed wave must be signal or noise.');
end
   
% Test option
% sig = noise * (rms_sig/(snr * rms_noise));

% See if entire output waveform should be scaled to a particular rms
if (out_rms>0) 
   % Calculate rms level of combined signal+noise
   rms_total = norm(sig)/sqrt(length(sig));
   % Scale total to obtain desired rms
   sig = sig * out_rms/rms_total;
end

% do something if clipping occurs
[sig, correction] = no_clip(sig);
if correction<-15 % allow a maximum of 15 dB attenuation 
   error('Output signal attenuated by too much.'); 
end

