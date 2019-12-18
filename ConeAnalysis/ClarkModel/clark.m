
%%
% saccades
clear stm tme
global EyeMovementsExample
global BinaryEx
global StepExample

% load DataForModelFitting

Dt = 5e-4;
stm = EyeMovementsExample.Stim*Dt/1e7;
tme = EyeMovementsExample.TimeAxis;

%StepExample = AK_example;
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

%%
%**************************************************************************
% biophysical model
%**************************************************************************

    params.beta = coef(1); 
    params.hillcoef = coef(2);			% effective Ca2+ cooperativity to GC (2-4)
    params.sigma = coef(3);			% rhodopsin activity decay rate constant (1/sec) (~100/sec)
    params.phi = coef(3);			% rhodopsin activity decay rate constant (1/sec) (~100/sec)
    params.gamma = coef(4);
    params.eta = coef(5);				% phosphodiesterase activation rate constant (1/sec) (>100/sec)
    params.betaSlow=coef(6);

    
    

%% isetbio

params.beta = 9;
params.hillaffinity = 0.3;
params.sigma = 22;
params.phi = 22;
params.eta = 2000;
params.betaSlow = 0.4;


% obj.model.sigma = 22;  % rhodopsin activity decay rate (1/sec) - default 22
% obj.model.phi = 22;     % phosphodiesterase activity decay rate (1/sec) - default 22
% obj.model.eta = 2000;	  % phosphodiesterase activation rate constant (1/sec) - default 2000
% obj.model.gdark = 20.5; % concentration of cGMP in darkness - default 20.5
% obj.model.k = 0.02;     % constant relating cGMP to current - default 0.02
% obj.model.h = 3;       % cooperativity for cGMP->current - default 3
% obj.model.cdark = 1;  % dark calcium concentration - default 1
% obj.model.beta = 9;	  % rate constant for calcium removal in 1/sec - default 9
% obj.model.betaSlow = 0.4; % rate constant for slow calcium modulation of channels - default 0.4
% obj.model.n = 4;  	  % cooperativity for cyclase, hill coef - default 4
% obj.model.kGc = 0.5;   % hill affinity for cyclase - default 0.5
% obj.model.OpsinGain = 10; % so stimulus can be in R*/sec (this is rate of increase in opsin activity per R*/sec) - default 10
    
coef = [params.beta params.hillaffinity params.sigma 0.19  3.9    1.2 params.eta params.betaSlow]
err = BiophysModelWrapper(coef);

%%    
coef = [9.1971    0.2916   21.1499    0.2248    4.0813    1.3703 2341 1];
err = BiophysModelWrapper(coef);

%%
options = optimset('MaxFunEvals', 100);
for iter = 1:5
    fitcoef = fminsearch(@BiophysModelWrapper, coef, options)
    coef = fitcoef;
end

%%
%**************************************************************************
% fits to time course of gain and current changes
%**************************************************************************

%% fit step response with single or double exponential

PrePts = 10000;
StmPts = 20000;
[MaxVal, MaxLoc] = max(AK_example.Step);

Resp = AK_example.Step(MaxLoc:PrePts+StmPts) - mean(AK_example.Step(PrePts+StmPts-500:PrePts+StmPts));
tme = [1:length(Resp)] * 0.1;

coef = [0 10 100];
fixed = [true false false];
fitcoef = nlinfitsome(fixed, tme, Resp, @exponential, coef);
fit = exponential(fitcoef, tme);

coef = [0 10 100 10 1000];
fixed = [true false false false false];
fitcoef = nlinfitsome(fixed, tme, Resp, @double_exponential, coef);
fit2 = double_exponential(fitcoef, tme);

figure(2);
plot(tme, Resp, tme, fit, tme, fit2);

err = 1 - mean((Resp - fit).^2) / mean((Resp-mean(Resp)).^2);
err2 = 1 - mean((Resp - fit2).^2) / mean((Resp-mean(Resp)).^2);

fprintf(1, '%d %d\n', err, err2);


%% compare gain and current changes

clear IsolatedFlash FlashIndices RespGain;

IntPts = 1000;

FixedFlashIndices = find(diff(AK_example.FlashLockedStim) > 0);
figure(2); clf; hold on
for resp = 1:size(AK_example.Flash, 1)
    IsolatedFlash(resp, :) = AK_example.Flash(resp, :) - AK_example.Step;
    FlashIndices(resp, :) = [FixedFlashIndices find(diff(AK_example.FlashStim(resp, :)) > 0)];
    for flash = 1:length(FlashIndices(resp, :))
        RespGain(resp, flash) = mean(IsolatedFlash(resp, FlashIndices(resp, flash):FlashIndices(resp, flash) + IntPts));
    end
    plot(FlashIndices(resp, :), RespGain(resp, :), 'o');
    if (resp == 1)
        CombinedRespGain = RespGain(resp, [2 4]);
        CombinedFlashIndices = FlashIndices(resp, [2 4]);
    else
        CombinedRespGain = [CombinedRespGain RespGain(resp, [2 4])];
        CombinedFlashIndices = [CombinedFlashIndices FlashIndices(resp, [2 4])];
    end
end

CombinedFlashIndices = CombinedFlashIndices - min(CombinedFlashIndices);
coef = [18 20 100 -10 1000];
fitcoef = nlinfit(CombinedFlashIndices, CombinedRespGain, @double_exponential, coef);
fit = double_exponential(fitcoef, CombinedFlashIndices);
figure(3);
plot(CombinedFlashIndices, CombinedRespGain, 'o', CombinedFlashIndices, fit, 'or');


