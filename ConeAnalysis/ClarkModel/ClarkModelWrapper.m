function err = ClarkModelWrapper(coef)
    global EyeMovementsExample
    global ImpulseResponse
    global BinaryEx
    
    params.Fourier = 1;
    params.tauy = coef(1);
    params.tauz = coef(2);
    params.ny = coef(3);
    params.nz = coef(4);
    params.gamma = coef(5);
    params.tauR = coef(6);
    params.alpha = coef(7);
    params.beta = coef(8);
    params.gamma2 = coef(9);
    params.tauzslow = coef(10);
    params.nzslow = coef(11);
    
    
    Dt = 5e-4;
    stm = EyeMovementsExample.Stim*Dt/5;
    tme = EyeMovementsExample.TimeAxis;
  
    params.stm = stm;
    params.tme = tme;

    params.Dt = Dt;

    params = ClarkModel(params);
    params.response = params.response - params.response(2000);
    figure(1); clf; subplot(1, 3, 1)
    plot(params.response); hold on
    plot(EyeMovementsExample.Mean);
    
    err1 = mean((params.response - EyeMovementsExample.Mean).^2);
    err1 = err1 / length(params.response);
    
    params.stm = ImpulseResponse.stm*1000;
    params.tme = ImpulseResponse.tme;
    params = ClarkModel(params);
    params.response = params.response - min(params.response);
    params.response = params.response / max(params.response);
    
    err2 = mean((params.response - ImpulseResponse.expfit).^2);
    err2 = err2 / length(params.response);

    figure(1);
    subplot(1, 3, 2);
    plot(params.response); hold on;
    plot(ImpulseResponse.expfit);

    params.stm = BinaryEx.Stim50k(1, :);
    params.stm = params.stm * 1e4 * params.Dt / mean(params.stm);
    params.tme = BinaryEx.TimeAxis;
    params = ClarkModel(params);
    params.response = params.response - min(params.response);
    expResponse = BinaryEx.Data50k(1, :);
    expResponse = expResponse - mean(expResponse(1:1000));
    expResponse = expResponse - min(expResponse);
%    expResponse = expResponse / 10;
    
    err3 = mean((params.response - expResponse).^2);
    err3 = err3 / length(params.response);
    figure(1);
    subplot(1, 3, 3);
    plot(params.response); hold on;
    plot(expResponse);

    err = err1 + err2 + err3;
    err = err1 + err2;
    pause(1);
