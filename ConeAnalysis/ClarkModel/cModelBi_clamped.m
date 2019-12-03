function response = cModelBi_clamped(coeffs,time,stim,dt,varargin)

% % normal one
% tauy = coeffs(1);
% tauz = coeffs(2);
% ny = coeffs(3);
% nz = coeffs(4);
% gamma = coeffs(5);
% tauR = coeffs(6);
% alpha = coeffs(7);
% beta = coeffs(8);
% gamma2 = coeffs(9);
% tauzslow = coeffs(10);
% nzslow = coeffs(11);


    
    
    
% obtained from no-feedback model fit to dim flash, which looks like fast dim-flash response without weird hump
    tauy = 45 / 10000;
    ny = 433 / 100;
    tauR = 48 / 10000;
% obtained from constrained model fit to stj, which has many good fits that are very similar in spite of different parameters
    tauz = 171 / 1000;
    nz = 269 / 100;

    tauzslow = 42.9 / 1000;
    nzslow = 227 / 100;
    
    
    gamma = coeffs(1) / 1000;
    alpha = coeffs(2) / 1; %10;
    beta = coeffs(3) / 100; %1000;
    gamma2 = coeffs(4) / 1000; 
    
if size(time)~=size(stim)
    error('Time and stimulus have to be the same size');
end

    FiltY = (time/tauy).^ny .*...
        exp(-time/tauy);
    FiltZ = gamma * FiltY +...
        (1-gamma-gamma2) * (time/tauz).^nz .* exp(-time/tauz) +...
        gamma2 * (time/tauzslow).^nzslow .* exp(-time/tauzslow);
%    FiltZ = gamma * FiltY + (1-gamma) * (time/tauz).^nz .* exp(-time/tauz);
    
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
        fprintf ('ccoeffs =[...\n')
        fprintf('\t%02.3f ... \ttauy\n',tauy)
        fprintf('\t%02.3f ... \ttauz\n',tauz)
        fprintf('\t%02.3f ... \tny\n',ny)
        fprintf('\t%02.3f ... \tnz\n',nz)
        fprintf('\t%02.3f ... \tgamma\n',gamma)
        fprintf('\t%02.3f ... \ttauR\n',tauR)
        fprintf('\t%02.3f ... \talpha\n',alpha)
        fprintf('\t%02.3f ... \tbeta\n',beta)
        fprintf('\t%02.3f ... \tgamma2\n',gamma2)
        fprintf('\t%02.3f ... \ttauz_slow\n',tauzslow)
        fprintf('\t%02.3f ... \tnz_slow\n',nzslow)
        fprintf('];\n')
        fprintf('\n')
    end
end
    
    
