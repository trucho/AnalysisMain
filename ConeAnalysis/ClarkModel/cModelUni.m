function response = cModelUni(coeffs,time,stim,dt,varargin)

%  normal one
% tauy = coeffs(1);
% tauz = coeffs(2);
% ny = coeffs(3);
% nz = coeffs(4);
% gamma = coeffs(5);
% tauR = coeffs(6);
% alpha = coeffs(7);
% beta = coeffs(8);

% trying to bring coefficients to similar units (1-1000)
    tauy = coeffs(1) / 10000;
    tauz = coeffs(2) / 1000;
    ny = coeffs(3) / 100;
    nz = coeffs(4) / 100;
    gamma = coeffs(5) / 1000;
    tauR = coeffs(6) / 10000;
    alpha = coeffs(7) / 10;
    beta = coeffs(8) / 1000;

if size(time)~=size(stim)
    error('Time and stimulus have to be the same size');
end


    FiltY = (time/tauy).^ny .* exp(-time/tauy);
    FiltZ = gamma * FiltY + (1-gamma) * (time/tauz).^nz .* exp(-time/tauz);

    r = zeros(1, length(stim));
    y = real(ifft(fft(stim) .* fft(FiltY)))*dt;
    z = real(ifft(fft(stim) .* fft(FiltZ)))*dt;

    for t = 1:length(time)-1
        r(t+1) = r(t) + (dt / tauR)*(alpha*y(t) - (1 + beta*z(t))*r(t));
    end
    response = r;

% print model parameters to command
if nargin == 5
    verbose=varargin{1};
    if verbose
        fprintf('\n')
        fprintf ('coeffs =[...\n')
        fprintf('\t%02.3f ... \ttauy\n',coeffs(1))
        fprintf('\t%02.3f ... \ttauz\n',coeffs(2))
        fprintf('\t%02.3f ... \tny\n',coeffs(3))
        fprintf('\t%02.3f ... \tnz\n',coeffs(4))
        fprintf('\t%02.3f ... \tgamma\n',coeffs(5))
        fprintf('\t%02.3f ... \ttauR\n',coeffs(6))
        fprintf('\t%02.3f ... \talpha\n',coeffs(7))
        fprintf('\t%02.3f ... \tbeta\n',coeffs(8))
        fprintf('];\n')
        fprintf('\n')
    end
end
    
    
