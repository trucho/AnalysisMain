function response = cModelUni_allclamped(coeffs,time,stim,dt,varargin)

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
%     tauz = 178 / 1000;
%     nz = 100 / 100;

% obtained from full model fit to stj, which looks like fast dim-flash response without weird hump
    tauy = 45 / 10000;
    ny = 433 / 100;
    tauR = 48 / 10000;
    tauz = 166 / 1000;
    nz = 100 / 100;
    
    gamma = 448 / 1000;
    alpha = 19.4 / 1; %10;
    beta = 36 / 100; %1000;
    
    scalefactor = coeffs(1);

if size(time)~=size(stim)
    error('Time and stimulus have to be the same size');
end

    stim = stim .* scalefactor;
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
        fprintf('\t%02.3f ... \ttauy\n',tauy)
        fprintf('\t%02.3f ... \ttauz\n',tauz)
        fprintf('\t%02.3f ... \tny\n',ny)
        fprintf('\t%02.3f ... \tnz\n',nz)
        fprintf('\t%02.3f ... \tgamma\n',coeffs(1))
        fprintf('\t%02.3f ... \ttauR\n',tauR)
        fprintf('\t%02.3f ... \talpha\n',coeffs(2))
        fprintf('\t%02.3f ... \tbeta\n',coeffs(3))
        fprintf('];\n')
        fprintf('\n')
    end
end
    
    
