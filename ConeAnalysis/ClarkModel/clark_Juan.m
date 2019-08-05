%%
clear, startup
global EyeMovementsExample
global BinaryEx
load('/Users/angueyraaristjm/matlab/AnalysisMain/ConeAnalysis/ClarkModel/EyeMovementsExample_092413Fc12vClamp.mat')
load('/Users/angueyraaristjm/matlab/AnalysisMain/ConeAnalysis/ClarkModel/BinaryEx.mat')
%%
% saccades

Dt = 5e-4;
% stm = EyeMovementsExample.Stim*Dt/1e7; %where does this scaling come from?
stm = EyeMovementsExample.Stim*Dt/5; %this one is because of Juan's miscalibration
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
expfit = ConeEmpiricalDimFlash(expcoef, tme');

stm = zeros(1,nSamples);
%stm = stm * 0.013;
stm(1) = 1;
tme = 1:length(stm);
tme = tme * Dt;

ImpulseResponse.expfit = expfit' / max(expfit);
ImpulseResponse.tme = tme;
ImpulseResponse.stm = stm;

%%
params=struct();
params.stm = stm;
params.tme = tme;
params.Dt = Dt;

% original numbers from Fred
% params.tauy = 0.001;
% params.tauz = 0.01;
% params.ny = 3;
% params.nz = 3;
% params.gamma = 0.3;
% params.tauR = 0.0002;
% params.alpha = -1;
% params.beta = -0.000001;
% params.gamma2 = 0.2;
% params.tauzslow = 0.18;
% params.nzslow = 1.61;
% params = ClarkModel(params);

% playing with this
params.tauy = 0.0071;
params.tauz = 0.0145;
params.ny = 2.828;
params.nz = 1.4745;
params.gamma = 0.055;
params.tauR = 0.001;
params.alpha = 12.95;
params.beta = 0.248;
params.gamma2 = 0.0751;
params.tauzslow = 0.243;
params.nzslow = 0.83;
params = ClarkModel(params);

% coef = [0.0071 0.0145 2.828 1.4745 0.055 0.001 12.95 0.248 0.0751 0.243 0.83];

% params.tauy = coef(1);
% params.tauz = coef(2);
% params.ny = coef(3);
% params.nz = coef(4);
% params.gamma = coef(5);
% params.tauR = coef(6);
% params.alpha = coef(7);
% params.beta = coef(8);
% params.gamma2 = coef(9);
% params.tauzslow = coef(10);
% params.nzslow = coef(11);

% params.gamma2 = 0;
% params.tauzslow = 0;
% params.nzslow = 0;

params = ClarkModel(params);
%
f1=getfigH(1);
lH=line(EyeMovementsExample.TimeAxis, EyeMovementsExample.Mean, 'Parent',f1);
lH=line(params.tme, params.response-params.response(2000), 'Parent',f1);
set(lH,'linewidth',2,'Color',[1 0 0]);

lH=line(EyeMovementsExample.TimeAxis(2000), params.response(2000), 'Parent',f1);
set(lH,'Marker','o','MarkerSize',10,'Color','k')

% plot(params.tme, -expfit, 'k');



%%

coef = [0.0071 0.0145 2.828 1.4745 0.055 0.001 12.95 0.248 0.0751 0.243 0.83];
err = ClarkModelWrapper(coef)

%%
fitcoef = fminsearch(@ClarkModelWrapper, coef)


%%
params.response
