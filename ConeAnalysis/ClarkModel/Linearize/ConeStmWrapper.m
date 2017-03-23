function err = ConeStmWrapper(coef)
    
    global StepStimulus
    global CorrectedStepStimulus
    global Prediction
    
    TimeStep = 1e-3;
    stimMean = 4000;
    nSamples = length(StepStimulus);
    
    err = 0;

    sensor = sensorCreate('human');
    sensor = sensorSet(sensor, 'size', [1 1]);
    sensor = sensorSet(sensor, 'time interval', TimeStep); 
    sensor = sensorSet(sensor, 'conversion gain', 1);

    %  create stimulus
    tme = 1:nSamples;
    tme = tme * TimeStep;
    stimulus(1:nSamples) = stimMean;
    stimulus(nSamples/4+1:3*nSamples/4) = stimMean*2*coef(3);
    filt = exp(-tme/abs(coef(4)));
    filt = filt / sum(filt);
    filteredStimulus1 = real(ifft(fft(stimulus) .* fft(filt)));    
    filt = exp(-tme/abs(coef(6)));
    filt = filt / sum(filt);
    filteredStimulus2 = real(ifft(fft(stimulus) .* fft(filt)));    
    stimulus(nSamples/4+1:3*nSamples/4) = (1-coef(5))*stimulus(nSamples/4+1:3*nSamples/4) + coef(5)*filteredStimulus1(nSamples/4+1:3*nSamples/4);
    stimulus(3*nSamples/4+1:nSamples) = (1-coef(7))*stimulus(3*nSamples/4+1:nSamples) + coef(7)*filteredStimulus2(3*nSamples/4+1:nSamples);
    stimulus(3*nSamples/4-round(coef(8)):3*nSamples/4+round(coef(9))) = 0;
    stimulus(nSamples/6:nSamples/6+40) = stimMean + stimMean * coef(1);
    stimulus(5*nSamples/8:5*nSamples/8+40) = stimMean*2 + stimMean * coef(2);
    stimulus = reshape(stimulus, [1 1 nSamples]);
    
    % set photon rate in sensor
    sensor = sensorSet(sensor, 'photon rate', StepStimulus);
    LinearModel = osCreate('linear');
    LinearModel = osSet(LinearModel, 'noiseFlag', 0);
    LinearModel = osCompute(LinearModel, sensor);
    sensor = sensorSet(sensor, 'photon rate', stimulus);
    CorrectedModel = osCreate('biophys');
    CorrectedModel = osCompute(CorrectedModel, sensor);

    LinearCurrent = squeeze(osGet(LinearModel, 'coneCurrentSignal'))*1.106;
    CorrectedCurrent = squeeze(osGet(CorrectedModel, 'coneCurrentSignal'));
    
    err = sum((LinearCurrent(nSamples/8:nSamples) - CorrectedCurrent(nSamples/8:nSamples)).^2);
    fprintf(1, '%d\n', err);
    Prediction = CorrectedCurrent;
    CorrectedStepStimulus = stimulus;
    
end
        
