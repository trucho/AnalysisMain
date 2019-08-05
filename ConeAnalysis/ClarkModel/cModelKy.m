function response = cModelKy(coeffs,time,stim,dt,varargin)

%  normal one
% tauy = coeffs(1);
% ny = coeffs(2);
% tauR = coeffs(3);
% alpha = coeffs(4);



% trying to bring coefficients to similar units (1-1000)
    tauy = coeffs(1) / 10000;
    ny = coeffs(2) / 100;
    tauR = coeffs(3) / 10000;
    alpha = coeffs(4) / 10;

if size(time)~=size(stim)
    error('Time and stimulus have to be the same size');
end


    FiltY = (time/tauy).^ny .* exp(-time/tauy);

    r = zeros(1, length(stim));
    y = real(ifft(fft(stim) .* fft(FiltY)))*dt;

    for t = 1:length(time)-1
        r(t+1) = r(t) + (dt / tauR)*(alpha*y(t) - r(t));
    end
    response = r;

% print model parameters to command
if nargin == 5
    verbose=varargin{1};
    if verbose
        fprintf('\n')
        fprintf ('coeffs =[...\n')
        fprintf('\t%02.3f ... \ttauy\n',coeffs(1))
        fprintf('\t%02.3f ... \tny\n',coeffs(2))
        fprintf('\t%02.3f ... \ttauR\n',coeffs(3))
        fprintf('\t%02.3f ... \talpha\n',coeffs(4))
        fprintf('];\n')
        fprintf('\n')
    end
end
    
    
