%% model parameters

params.beta = 9;
params.hillaffinity = 0.5;
params.sigma = 22;
params.phi = 22;
params.eta = 2000;
params.betaSlow = 0.4;
params.biophysFlag = 1;
params.darkCurrent = 200;
params.hillcoef = 4;
params.gamma = 10;

%% sinusoids

clear asyIndex stm

meanIntensity = [1000 2000 4000 8000 12000 16000 20000 30000 40000] * 1e-4;
params.tme = [1:200000] * 1e-4;
freq = 2.5;
figure(2); clf

for cond = 1:length(meanIntensity)
    stm = meanIntensity(cond) * (1+sin(2*pi*params.tme*freq));
    stm(1:length(params.tme)/2) = meanIntensity(cond);
    params.stm = stm;
    params = RiekeModel_FredAug2020(params);
    params.response = params.response - params.response(length(params.tme)/2);
    plot(params.response);
    pause(1);
    
    asyIndex(cond) = -min(params.response(length(params.tme)*3/4:length(params.tme))) / max(params.response(length(params.tme)*3/4:length(params.tme)));
end

figure(3);
plot(log10(meanIntensity*1e4), asyIndex);
xlim([2 5]);
ylim([0 3.5]);
xlabel('log(R^*/s)');
ylabel('asymmetry index');

%% Steps and flashes

clear meanIntens flashRespGain stepRespGain stm
stm(1:40000) = 0;
params.tme = [1:length(stm)] * 1e-4;
figure(2); clf;
for step = 1:12
    stm(10000:20000) = 100 * 2^step*1e-4;
    stm(5000) = 10;
    stm(15000) = 10;
    params.stm = stm;
    params = RiekeModel_FredAug2020(params);
    subplot(1, 2, 1);
    plot(params.response);
    flashRespGain(step) = (mean(params.response(15000:16000)) - params.response(15000)) / (mean(params.response(5000:6000)) - params.response(5000));
    stepRespGain(step) = params.response(20000) - params.response(9000);
    meanIntens(step) = 100*2^step;
    pause(1);
end
flashRespGain = flashRespGain / flashRespGain(1);
stepRespGain = stepRespGain / params.darkCurrent;
%%
coef = 1e3;
fitcoef = nlinfit(meanIntens, log10(flashRespGain), 'WeberFechner', coef);

coef = [1e3 1];
hillcoef = nlinfit(meanIntens, stepRespGain, 'HillEq', coef);

fprintf(1, 'half desensitizing background = %d\nhalf max step = %d\n', fitcoef, hillcoef(1));

clf;
subplot(1, 2, 1);
loglog(meanIntens, flashRespGain, 'o'); hold on
xlabel('log(R^*/s)');
ylabel('log(S/S_D)');
subplot(1, 2, 2);
semilogx(meanIntens, stepRespGain, 'o');
xlabel('log(R^*/s)');
ylabel('norm resp');
