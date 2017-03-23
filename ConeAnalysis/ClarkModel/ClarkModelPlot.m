function err = ClarkModelWrapper(coef)
    global EyeMovementsExample
    global ImpulseResponse
    global BinaryEx
    
    Dt = 5e-4;
    stm = EyeMovementsExample.Stim/1e7;
    tme = EyeMovementsExample.TimeAxis;
  
  
    params.stm = stm;
    params.tme = tme;

    params.Dt = Dt;

    params.tauy = coef(1);
    params.tauz = coef(2);
    params.ny = coef(3);
    params.nz = coef(4);
    params.gamma = coef(5);
    params.tauR = coef(6);
    params.alpha = coef(7);
    params.beta = coef(8);
    
    params = ClarkModel(params);
    figure(1); clf; subplot(1, 3, 1)
    plot(params.response); hold on;
    plot(EyeMovementsExample.Mean);
    
    err1 = mean((params.response - EyeMovementsExample.Mean).^2);
    err1 = err1 / length(params.response);
    
    params.stm = ImpulseResponse.stm;
    params.tme = ImpulseResponse.tme;
    params = ClarkModel(params);

    err2 = mean((params.response - ImpulseResponse.expfit).^2);
    err2 = err2 / length(params.response);

    subplot(1, 3, 2);
    plot(params.response); hold on;
    plot(ImpulseResponse.expfit);

    params.stm = BinaryEx.Stim50k(1, :);
    params.stm = params.stm * 5e4 / mean(params.stm) / 1e7;
    params.tme = BinaryEx.TimeAxis;
    params = ClarkModel(params);
    params.response = -params.response;
    expResponse = BinaryEx.Data50k(1, :);
    expResponse = expResponse - mean(expResponse(1:1000));
    expResponse = expResponse - min(expResponse);
    expResponse = expResponse / 10;
    
    err3 = mean((params.response - expResponse).^2);
    err3 = err3 / length(params.response);
    subplot(1, 3, 3);
    plot(params.response); hold on;
    plot(expResponse);

    err = err1 + err2 + err3;
    pause(1);
