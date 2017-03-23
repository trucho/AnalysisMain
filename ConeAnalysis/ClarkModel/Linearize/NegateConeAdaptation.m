%%
% NegateConeAdaptation.m
%
% This is code to play with stimulus manipulations to linearize cone
% responses by canceling effects of adaptation.

%% undo nonlinearities in cone model for step response

global StepStimulus
global CorrectedStepStimulus
global Prediction

%  set up parameters for stimulus
nSamples = 4080;       
TimeStep = 1e-3; % s
stimMean = 4000;

% init cone models
sensor = sensorCreate('human');
sensor = sensorSet(sensor, 'size', [1 1]);
sensor = sensorSet(sensor, 'time interval', TimeStep); 
sensor = sensorSet(sensor, 'conversion gain', 1);

%  create stimulus
clear stimulus;
tme = 1:nSamples;
tme = tme * TimeStep;
stimulus(1:nSamples) = stimMean;
stimulus(nSamples/4+1:3*nSamples/4) = stimMean*2;
stimulus(nSamples/6:nSamples/6+40) = stimMean + stimMean;
stimulus(5*nSamples/8:5*nSamples/8+40) = stimMean*2 + stimMean;
stimulus = reshape(stimulus, [1 1 nSamples]);
StepStimulus = stimulus;

% set photon rate in sensor and generate responses of linear and nonlinear
% cone models
sensor = sensorSet(sensor, 'photon rate', stimulus);
LinearModel = osCreate('linear');
LinearModel = osSet(LinearModel, 'noiseFlag', 0);
LinearModel = osCompute(LinearModel, sensor);
FullModel = osCreate('biophys');
FullModel = osCompute(FullModel, sensor);

LinearCurrent = squeeze(osGet(LinearModel, 'coneCurrentSignal'))*1.106;
FullCurrent = squeeze(osGet(FullModel, 'coneCurrentSignal'));
LinearCurrent = LinearCurrent; % - mean(LinearCurrent);
FullCurrent = FullCurrent; % - mean(FullCurrent);

% check error without correction
err = sum((LinearCurrent(nSamples/8:nSamples) - FullCurrent(nSamples/8:nSamples)).^2)

% starting parameters
coef = [0.51 5.6 1.31 0.097 0.67 0.185 0.125 1 66];

err = ConeStmWrapper(coef);

% plot
figure(2); clf;
plot(tme, FullCurrent, tme, LinearCurrent, tme, Prediction);
legend('full', 'linear');


%% optimize

options = optimset('MaxFunEvals', 500);
for iter = 1:2
    fitcoef = fminsearch(@ConeStmWrapper, coef, options)
    coef = fitcoef;
end

%%
% plot results

figure(2); clf;
subplot(2, 1, 1);
plot(tme, FullCurrent, tme, LinearCurrent, tme, Prediction, 'Linewidth', 2);
legend('full', 'linear', 'corrected');
axis tight
xlabel('sec');
ylabel('pA');
CurFigPanel = gca;
makeAxisStruct(CurFigPanel,'NegateAdaptResps','test')
subplot(2, 1, 2);
plot(tme, squeeze(StepStimulus), 'k', 'Linewidth', 2); 
plot(tme, squeeze(StepStimulus), tme, squeeze(CorrectedStepStimulus), 'Linewidth', 2); 
legend('original', 'corrected');
axis tight
xlabel('sec');
ylabel('R^*/sec');
ylim([0 2e4]);
CurFigPanel = gca;
makeAxisStruct(CurFigPanel,'NegateAdaptStm','test')

%% global optimization

prob = createOptimProblem('fminunc', 'objective', @ConeStmWrapper, 'x0', fitcoef);
gs = GlobalSearch('NumTrialPoints', 1000);
ms = MultiStart;
fitcoef = run(gs, prob, 10); 