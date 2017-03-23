
%%
% saccades
clear stm tme
global EyeMovementsExample
global BinaryEx

Dt = 5e-4;
stm = EyeMovementsExample.Stim*Dt/1e7;
tme = EyeMovementsExample.TimeAxis;

%%
% impulse response

global ImpulseResponse;

clear stm tme;
Dt = 5e-4;
nSamples = 1000;

% compute fit to measured response (Angueyra and Rieke, 2013)
expcoef = [5 0.02 0.03 0.53 34];            % fit to measured response
tme = (1:nSamples)*Dt;
expfit = coneEmpiricalDimFlash(expcoef, tme');

stm = zeros(1,nSamples);
%stm = stm * 0.013;
stm(1) = 1;
tme = 1:length(stm);
tme = tme * Dt;

ImpulseResponse.expfit = expfit' / max(expfit);
ImpulseResponse.tme = tme;
ImpulseResponse.stm = stm;

%%

params.stm = stm;
params.tme = tme;
params.Dt = Dt;

params.tauy = 0.001;
params.tauz = 0.01;
params.ny = 3;
params.nz = 3;
params.gamma = 0.3;
params.tauR = 0.0002;
params.alpha = -1;
params.beta = -0.000001;
params.gamma2 = 0.2;
params.tauzslow = 0.18;
params.nzslow = 1.61;
params = ClarkModel(params);

%%
figure(1);clf
plot(params.tme, params.response); hold on
%plot(params.tme, -expfit, 'k');

plot(EyeMovementsExample.TimeAxis, EyeMovementsExample.Mean, 'k');


%%

coef = [0.0071 0.0145 2.828 1.4745 0.055 0.001 12.95 0.248 0.0751 0.243 0.83];
err = ClarkModelWrapper(coef)

%%
fitcoef = fminsearch(@ClarkModelWrapper, coef)



