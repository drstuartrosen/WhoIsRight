function s=taper(wave, rise, fall, SampFreq)

% function s=taper(wave, rise, fall, SampFreq)

% null input wave leads to null output
% Put rises and falls onto a waveform 'wave'
% rise and fall times are specified independently in ms

% One-half cycle of a raised cosine is used.                                
% In this implementation, the start of the rise (e.g.          
% wave_start) is set to 0 (explicitly) while its end
% (e.g. wave_start[rise-1]) is left at its original amplitude.
% Intermediate values are scaled in accordance with the raised
% cosine. For rise times of 2 points or less, the original
% waveform is left unchanged.                                

% This routine is based on taper.c from aud_ml7

% calculate rise and fall times in numbers of samples

if (isempty(wave))
   s = [];
   return
end

rise = samplify(rise, SampFreq);
fall = samplify(fall, SampFreq);

s = wave;
% envelope = ones(1,length(wave));

if rise>2
    pi_over_rf = pi/(rise-1);
    for n=1:rise-2 	% needn't do n=0 because k=1 there
        k = 0.5 + 0.5 * cos(n * pi_over_rf);
        s(rise-n) = k * s(rise-n);
    end
    % ensure that wave goes to zero at beginning of rise
    s(1)=0;
end

if fall>2
    pi_over_rf = pi/(fall-1);
    finish = length(s);
    for n=1:fall-2 	% needn't do n=0 because k=1 there
        k = 0.5 + 0.5 * cos(n * pi_over_rf);
        s(finish+(n-(fall-1))) = k * s(finish+(n-(fall-1)));
     end
    % ensure that wave goes to zero at end of fall
    s(length(s))=0;
end

function samples = samplify(duration, SampFreq)
samples = floor(SampFreq*(duration/1000));
