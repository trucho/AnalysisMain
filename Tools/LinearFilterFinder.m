function LinearFilter=LinearFilterFinder(signal,response, samplerate, freqcutoff)

% this function will find the linear filter that changes row vector "signal" 
% into a set of "responses" in rows.  "samplerate" and "freqcuttoff" 
% (which should be the highest frequency in the signal) should be in HZ.

% The linear filter is a crosscorrelation normalized by the power spectrum of the signal
% JC 3/31/08 
% Modified Apr_2011 Juan (included scaling by 1/samplerate in every fft and 
% by samplerate for ifft)



FilterFft = mean((fft(response,[],2).*1/samplerate.*conj(fft(signal,[],2).*1/samplerate)),1)./...
    mean(fft(signal,[],2).*1/samplerate.*conj(fft(signal,[],2).*1/samplerate),1);
% FilterFft = (fft(response,[],2).*conj(fft(signal,[],2)))./(fft(signal,[],2).*conj(fft(signal,[],2)));

freqcutoff_adjusted = round(freqcutoff/(samplerate/length(signal))); % this adjusts the freq cutoff for the length

FilterFft(:,1+freqcutoff_adjusted:length(signal)-freqcutoff_adjusted) = 0 ; 

LinearFilter = real(ifft(FilterFft).*samplerate) ;

end