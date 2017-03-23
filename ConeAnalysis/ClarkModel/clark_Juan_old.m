
%%
% saccades
clear stm tme
global EyeMovementsExample
global BinaryEx

Dt = 5e-4;
stm = EyeMovementsExample.Stim/1e7;
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

ImpulseResponse.expfit = -expfit';
ImpulseResponse.tme = tme;
ImpulseResponse.stm = stm;

%%

params.stm = stm;
params.tme = tme;
params.Dt = Dt;

params.tauy = 0.0087;
params.tauz = 0.0152;
params.ny = 2.86;
params.nz = 3.63;
params.gamma = 0.15;
params.tauR = 0.0009;
params.alpha = -0.834;
params.beta = 0.0245;
params.gamma2 = 0.2;
params.tauzslow = 0.18;
params.nzslow = 1.61;
params = ClarkModel(params);

figure(1);clf
plot(params.tme, params.response); hold on
%plot(params.tme, -expfit, 'k');

plot(EyeMovementsExample.TimeAxis, EyeMovementsExample.Mean, 'k');


%%

coef = [0.0087 0.0152 2.86 3.63 0.15 0.0009 -0.834 0.0245 0.2 0.18 1.61];
err = ClarkModelWrapper(coef)

%%
fitcoef = fminsearch(@ClarkModelWrapper, coef)



