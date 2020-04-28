function [response,Ky,Kz] = testmonoClark(coeffs,time,stim,dt,varargin)

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
% best fit to dim-flash response without feedback
%     tauy = 29 / 10000;
%     ny = 367 / 100;
%     tauR = 275 / 10000;
% obtained from full model fit to stj, which looks like fast dim-flash response without weird hump
    tauy = 38 / 10000;
    ny = 150 / 100;
    tauR = 39 / 10000;
    
    
    tauz = coeffs(1) / 1000;
    nz = coeffs(2) / 100;
    gamma = coeffs(3) / 1000;
    alpha = coeffs(4) / 1; %following new rescaling from monoClark on Aug 2019
    beta = coeffs(5) / 100;

if size(time)~=size(stim)
    error('Time and stimulus have to be the same size');
end


    FiltY = (time/tauy).^ny .* exp(-time/tauy);
    Ky = FiltY;
    FiltZ = gamma * FiltY + (1-gamma) * (time/tauz).^nz .* exp(-time/tauz);
    Kz = (time/tauz).^nz .* exp(-time/tauz);
%     Kz = FiltZ;
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
        fprintf('\t%02.3f ... \ttauy\n',tauy)
        fprintf('\t%02.3f ... \ttauz\n',coeffs(1))
        fprintf('\t%02.3f ... \tny\n',ny)
        fprintf('\t%02.3f ... \tnz\n',coeffs(2))
        fprintf('\t%02.3f ... \tgamma\n',coeffs(3))
        fprintf('\t%02.3f ... \ttauR\n',tauR)
        fprintf('\t%02.3f ... \talpha\n',coeffs(4))
        fprintf('\t%02.3f ... \tbeta\n',coeffs(5))
        fprintf('];\n')
        fprintf('\n')
    end
end