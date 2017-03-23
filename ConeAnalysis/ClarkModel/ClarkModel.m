function params = ClarkModel(params)

    FiltY = (params.tme/params.tauy).^params.ny .*...
        exp(-params.tme/params.tauy);
    FiltZ = params.gamma *...
        FiltY + (1-params.gamma-params.gamma2) * (params.tme/params.tauz).^params.nz .* exp(-params.tme/params.tauz) +...
        params.gamma2 * (params.tme/params.tauzslow).^params.nzslow .* exp(-params.tme/params.tauzslow);
%    FiltZ = params.gamma * FiltY + (1-params.gamma) * (params.tme/params.tauz).^params.nz .* exp(-params.tme/params.tauz);
    
    r = zeros(1, length(params.stm));
    y = real(ifft(fft(params.stm) .* fft(FiltY)))*params.Dt;
    z = real(ifft(fft(params.stm) .* fft(FiltZ)))*params.Dt;

    for t = 1:length(params.tme)-1
        r(t+1) = r(t) + (params.Dt / params.tauR)*(params.alpha*y(t) - (1 + params.beta*z(t))*r(t));
    end
    params.response = r;
    


    
    
