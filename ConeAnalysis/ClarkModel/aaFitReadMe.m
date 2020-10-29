%% Fitting cone models log (Jun 2017, Juan Angueyra)
% trying to rationalize and document model fitting procedures and avoid going in loops

%% BIG PROBLEM: clark models scale with skippts!
%% Relevant files
%#ok<*UNRCH>
% Cone models
edit cModel_Ky.m    % Clark model (linear filter only / no feedback)
edit cModelUni.m    % Clark model
edit cModelBi.m     % Clark model (2 feedbacks)
edit vhModel5.m     % van Hateren's model
edit rModel5.m      % Rieke model (2 feedbacks)
% Fitting GUIs
edit fit_monoClark.m    % fit Clark model to saccade trajectory
edit fit_biClark.m      % fit biClark model to saccade trajectory
edit fit_vanHat.m       % fit Biophysical model to saccade trajectory
edit fit_biRieke.m      % fit Biophysical model with 2 feedbacks to saccade trajectory

% READ ME: 
% fitting GUIs are initialized with what I think are the best fitted parameters, which I found using a combination of manual and automatic fitting.
% 'Revert to ini' flips parameters back to these initial values
% All parameters can be set using sliders or table ('curr' column)
% Once parameters have been set, fit will be recalculated after pressing 'accept fit'
% Automatic searches for best fits can be done using 'lsq' or 'fmc'
% Both of these functions seem to be more reliable when all model parameters are in similar ranges; especially there are problems when values are small or have
% a lot of decimal values (probably rounding errors?). For this reason I have rescaled parameters in the model functions themselves.

% For saccade trajectory GUIs: 'lsq' tries to fit saccade trajectory data while 'fmc' tries to fit dim-flash response
% For adaptation kinetics GUIs: 'lsq' tries to fit step + flashes with 40 ms delay while 'fmc' tries to fit step only (no flashes)
%%
% Aug 11 2020:
    % will stick to isetbio parameters for manuscript and provide some options based on Fred's multiple cell fitting
    % main task right now is to update all figures + text.
    % Fred divides all stimuli by 5, because of supposed miscalibration.
    % from Fred's isetbio fits:
%         obj.model.sigma = 22;  % rhodopsin activity decay rate (1/sec) - default 22
%         obj.model.phi = 22;     % phosphodiesterase activity decay rate (1/sec) - default 22
%         obj.model.eta = 2000;  % phosphodiesterase activation rate constant (1/sec) - default 2000
%         obj.model.gdark = 20.5; % concentration of cGMP in darkness - default 20.5
%         obj.model.k = 0.02;     % constant relating cGMP to current - default 0.02
%         obj.model.h = 3;       % cooperativity for cGMP->current - default 3
%         obj.model.cdark = 1;  % dark calcium concentration - default 1
%         obj.model.beta = 9;  % rate constant for calcium removal in 1/sec - default 9
%         obj.model.betaSlow = 0.4; % rate constant for slow calcium modulation of channels - default 0.4
%         obj.model.n = 4;    % cooperativity for cyclase, hill coef - default 4
%         obj.model.kGc = 0.5;   % hill affinity for cyclase - default 0.5
%         obj.model.OpsinGain = 10; % so stimulus can be in R*/sec (this is rate of increase in opsin activity per R*/sec) - default 10

    % coef = [2.3832  136.1001    6.1649   75.5345    6.7369  283.6476    1.3161  107.1802];
    
    % redoing sineStim.mat for sine responses to have dt = 1e-4 rather than 1e-3, like in real data

% Jan 21 2020:
    % Seems like we went full circle in biRieke fits and just stuck with params from thesis (2014 / isetbio / linearization)
    % Now need to reassess vanHat
    % Also need to reassess clark models and explore how to get better adaptation parameters
% Things missing:
    % Calculate adaptation taus (possiblity to do this across many many light levels?)
    % Steps and Sines
  
%% biRieke
%% Fit to saccade trajectory
% Jan 2020: after discussions with Fred, using best fit for saccade trajectory, best fit for adaptation kinetics, then isetbio params for adaptation 
% Jan 2020: in my model k = 0.01 but in isetbio k = 0.02. Modified this and it seems this factor is just cancelling out in current calculations and can be set
% to anything.

% Save Adaptation stuff from this model
% Still the same as of Aug 2020
hGUI = fit_biRieke(struct('ak_subflag',0,'ini',[0500,220,2000,80,0400,01000]),10); % this is from isetbio params (modified to rModel6) but still a discrepancy on holding current of 56 pA that could be artificially corrected. 
if false
    makeAxisStruct(hGUI.gObj.gfs_stim,sprintf('gStim'),'EyeMovements/2019_Models/biRieke')
    makeAxisStruct(hGUI.gObj.gfs,sprintf('gF'),'EyeMovements/2019_Models/biRieke')
    makeAxisStruct(hGUI.gObj.gwf,sprintf('gW'),'EyeMovements/2019_Models/biRieke')
    makeAxisStruct(hGUI.gObj.ssi_stim,sprintf('ssiStim'),'EyeMovements/2019_Models/biRieke')
    makeAxisStruct(hGUI.gObj.ssi,sprintf('ssiS'),'EyeMovements/2019_Models/biRieke')
    makeAxisStruct(hGUI.gObj.ssiibs,sprintf('ssiH'),'EyeMovements/2019_Models/biRieke')
end
%%
% Save as good fit to saccade trajectory data
hGUI = fit_biRieke(struct('ak_subflag',0,'ini',[0500,220,2000,136,0400,238.32]),10); % isetBio, Fred's Aug 2020 fit
% hGUI = fit_biRieke(struct('ak_subflag',0,'ini',[0500,220,2000,136,0400,050]),10); % this is from isetbio params (modified to rModel6) but still a discrepancy on holding current of 56 pA.


if false
    makeAxisStruct(hGUI.gObj.dfp,sprintf('df'),'EyeMovements/2019_Models/biRieke') 
    makeAxisStruct(hGUI.gObj.stpstim,sprintf('stj_stim'),'EyeMovements/2019_Models/biRieke')
    makeAxisStruct(hGUI.gObj.stp,sprintf('stj'),'EyeMovements/2019_Models/biRieke')
end


% hGUI = fit_biRieke(struct('ak_subflag',0,'ini',[0300,220,2000,136,0400,0300]),10); % this is from AdaptationModel/clark.m (modified to rModel6); this was old fit. Still good after 6 years
% hGUI = fit_biRieke(struct('ak_subflag',0,'ini',[0300,220,2000,80,0400,0300]),10); % And this increases opsinGain to 10 but it does not get adaptation stuff. So hillAffinity should be 0.5

% hGUI = fit_biRieke(struct('ak_subflag',0,'ini',[0500,220,2000,136,0400,0250]),10); % this is keeping hillAffinity at 0.5;
% hGUI = fit_biRieke(struct('ak_subflag',0,'ini',[0530,0235,2.48e+03,0135,1.69e+03,0291]),10); % 

%% Fit to adaptation kinetics only 2 parameters
% Aug 2020: changed example cell from 111412Fc01 to 111412Fc02 (back calculations suggest that led setting in notes is not correct; will probably exclude this cell)
hGUI = fit_biRieke_ak_Clamped(struct('plotFlag',0,'ini',[290,789]),10); % this one is for 111412Fc02

% hGUI = fit_biRieke_ak_Clamped(struct('plotFlag',0,'ini',[350,285]),10); % this one is ok for hillAffinity = 0.5; qualitatively similar
% hGUI = fit_biRieke_ak_Clamped(struct('plotFlag',0,'ini',[350,340]),10); % this one is ok for hillAffinity = 0.3

if false
    makeAxisStruct(hGUI.gObj.p_stimS,sprintf('ak_stimS'),'EyeMovements/2019_Models/biRieke') 
    makeAxisStruct(hGUI.gObj.p_stimF,sprintf('ak_stimF'),'EyeMovements/2019_Models/biRieke') 
    makeAxisStruct(hGUI.gObj.p_resp,sprintf('ak_resp'),'EyeMovements/2019_Models/biRieke') 
    makeAxisStruct(hGUI.gObj.p_subf,sprintf('ak_subf'),'EyeMovements/2019_Models/biRieke') 
    makeAxisStruct(hGUI.gObj.p_on,sprintf('ak_on'),'EyeMovements/2019_Models/biRieke') 
    makeAxisStruct(hGUI.gObj.p_off,sprintf('ak_off'),'EyeMovements/2019_Models/biRieke') 
end

%% Fit to adaptation kinetics all parameters
% Nothing look great here 
%  hGUI = fit_biRieke_ak(struct('plotFlag',0,'ini',[0527,0186,10480,350,0400,500]),10);
 hGUI = fit_biRieke_ak(struct('plotFlag',0,'ini',[0200,0186,1500,350,0400,200]),10);
%  hGUI = fit_biRieke_ak(struct('plotFlag',0,'ini',[500,0220,2000,350,0400,285]),10);

%% Replicate responses to binary noise
hGUI = fit_biRieke_bn(10);BIPBIP();

% % saving to struct to make summary plot for all models
bn = struct();
bn.biRieke = hGUI.modelRatio';
bn.biRiekeIbs = hGUI.ib';

if false
    makeAxisStruct(hGUI.gObj.p_ex50kStim,sprintf('rm_exStim'),'EyeMovements/2019_Models/BinaryNoise') 
    makeAxisStruct(hGUI.gObj.p_ex50k,sprintf('rm_exFit'),'EyeMovements/2019_Models/BinaryNoise')
end

%% Replicate responses to sine stimulation
figure(1);clf;
hGUI = fit_biRieke_sine(1);

% % saving to struct to make summary plot for all models
sine = struct();
sine.biRieke = hGUI.modelRatio';
sine.biRiekeIbs = hGUI.ib';

if false
    makeAxisStruct(hGUI.gObj.p_exStim,sprintf('rm_exStim'),'EyeMovements/2019_Models/Sine') 
    makeAxisStruct(hGUI.gObj.p_exResp01,sprintf('rm_exResp01'),'EyeMovements/2019_Models/Sine')
    makeAxisStruct(hGUI.gObj.p_exResp02,sprintf('rm_exResp02'),'EyeMovements/2019_Models/Sine')
    makeAxisStruct(hGUI.gObj.p_exResp03,sprintf('rm_exResp03'),'EyeMovements/2019_Models/Sine')
    makeAxisStruct(hGUI.gObj.p_exResp04,sprintf('rm_exResp04'),'EyeMovements/2019_Models/Sine')
    makeAxisStruct(hGUI.gObj.p_ratio,sprintf('sineRatio'),'EyeMovements/2019_Models/Sine')
end




% lH = lineH(sold.i,sold.ai,hGUI.gObj.p_ratio); lH.liner();
% lH = lineH(meanIntensity*1e4, asyIndex,hGUI.gObj.p_ratio);

% THIS IS JUST THE MODEL TO MAKE MOCK FIGURE
if false
    hGUI.ib_example = 10000;
    hGUI.createExampleObjects();
%     makeAxisStruct(hGUI.gObj.p_stim,sprintf('sine_stm'),'EyeMovements/Asymmetry') 
%     makeAxisStruct(hGUI.gObj.p_resp,sprintf('sine_resp'),'EyeMovements/Asymmetry') 
%     makeAxisStruct(hGUI.gObj.p_ratio,sprintf('sine_ratio'),'EyeMovements/Asymmetry')
%     makeAxisStruct(hGUI.gObj.p_exStim,sprintf('sine_coneStim'),'EyeMovements/Asymmetry')
%     makeAxisStruct(hGUI.gObj.p_exResp01,sprintf('sine_coneResp_1200'),'EyeMovements/Asymmetry')
%     makeAxisStruct(hGUI.gObj.p_exResp02,sprintf('sine_coneResp_4000'),'EyeMovements/Asymmetry')
%     makeAxisStruct(hGUI.gObj.p_exResp03,sprintf('sine_coneResp_12000'),'EyeMovements/Asymmetry')
%     makeAxisStruct(hGUI.gObj.p_exResp04,sprintf('sine_coneResp_40000'),'EyeMovements/Asymmetry')
end
%% Map adaptation kinetic taus for model
% hGUI = fit_biRieke_aktaus(1); % This can take a long time
if false
    makeAxisStruct(hGUI.gObj.p_onTau,sprintf('model_onTau'),'AdaptationKinetics') 
    makeAxisStruct(hGUI.gObj.p_offTau,sprintf('model_offTau'),'AdaptationKinetics') 
end

%% Apr_2020 redoing vanHat again (Can this really be the last time please!!!!!?!!!?!?!?!?!?)
%% Fit to saccade trajectory
% good fit for adaptation
% hGUI = fit_vanHat(struct('ak_subflag',0,'ini',[526,235,2395,136,1000]),10); % this is from isetbio params (modified to rModel6) but still a discrepancy on holding current of 56 pA that could be artificially corrected. 

if false
    makeAxisStruct(hGUI.gObj.gfs_stim,sprintf('gStim'),'EyeMovements/2019_Models/vanHat')
    makeAxisStruct(hGUI.gObj.gfs,sprintf('gF'),'EyeMovements/2019_Models/vanHat')
    makeAxisStruct(hGUI.gObj.gwf,sprintf('gW'),'EyeMovements/2019_Models/vanHat')
    makeAxisStruct(hGUI.gObj.ssi_stim,sprintf('ssiStim'),'EyeMovements/2019_Models/vanHat')
    makeAxisStruct(hGUI.gObj.ssi,sprintf('ssiS'),'EyeMovements/2019_Models/vanHat')
    makeAxisStruct(hGUI.gObj.ssiibs,sprintf('ssiH'),'EyeMovements/2019_Models/vanHat')
end

% hGUI = fit_vanHat(struct('ak_subflag',0,'ini',[526,235,2395,136,0277]),10); % this is from isetbio params (modified to rModel6) but still a discrepancy on holding current of 56 pA that could be artificially corrected. 
% Save as good fit to saccade trajectory data
if false
    makeAxisStruct(hGUI.gObj.dfp,sprintf('df'),'EyeMovements/2019_Models/vanHat') 
    makeAxisStruct(hGUI.gObj.stpstim,sprintf('stj_stim'),'EyeMovements/2019_Models/vanHat')
    makeAxisStruct(hGUI.gObj.stp,sprintf('stj'),'EyeMovements/2019_Models/vanHat')
end

%% Fit to adaptation kinetics
% hGUI = fit_vanHat_ak_Clamped(struct('plotFlag',0),10);
% hGUI = fit_vanHat_ak_Clamped(struct('plotFlag',0,'ini',[327,1965,2.7]),10); %free eta and free opsin gain
% hGUI = fit_vanHat_ak_Clamped(struct('plotFlag',0,'ini',[350,8585,1300]),10); %free eta and free opsin gain
hGUI = fit_vanHat_ak_Clamped(struct('plotFlag',0,'ini',[350,2395,346]),10); %free eta and free opsin gain
% hGUI = fit_vanHat_ak_Clamped(struct('plotFlag',0,'ini',[350,2000,285]),10); %free eta and free opsin gain
if false
    makeAxisStruct(hGUI.gObj.p_stimS,sprintf('ak_stimS'),'EyeMovements/2019_Models/vanHat') 
    makeAxisStruct(hGUI.gObj.p_stimF,sprintf('ak_stimF'),'EyeMovements/2019_Models/vanHat') 
    makeAxisStruct(hGUI.gObj.p_resp,sprintf('ak_resp'),'EyeMovements/2019_Models/vanHat') 
    makeAxisStruct(hGUI.gObj.p_subf,sprintf('ak_subf'),'EyeMovements/2019_Models/vanHat') 
    makeAxisStruct(hGUI.gObj.p_on,sprintf('ak_on'),'EyeMovements/2019_Models/vanHat') 
    makeAxisStruct(hGUI.gObj.p_off,sprintf('ak_off'),'EyeMovements/2019_Models/vanHat') 
end

%% Binary noise for vanHat model
hGUI = fit_vanHat_bn(10);BIPBIP();

% % saving to struct to make summary plot for all models
bn.vanHat = hGUI.modelRatio';
bn.vanHatIbs = hGUI.ib';

if false
    makeAxisStruct(hGUI.gObj.p_ex50kStim,sprintf('vh_exStim'),'EyeMovements/2019_Models/BinaryNoise') 
    makeAxisStruct(hGUI.gObj.p_ex50k,sprintf('vh_exFit'),'EyeMovements/2019_Models/BinaryNoise')
end

%% Replicate responses to sine stimulation
figure(1);clf;
hGUI = fit_vanHatRieke_sine(1);

% % saving to struct to make summary plot for all models
sine.vanHat= hGUI.modelRatio';
sine.vanHatIbs = hGUI.ib';

if false
    makeAxisStruct(hGUI.gObj.p_exStim,sprintf('vh_exStim'),'EyeMovements/2019_Models/Sine') 
    makeAxisStruct(hGUI.gObj.p_exResp01,sprintf('vh_exResp01'),'EyeMovements/2019_Models/Sine')
    makeAxisStruct(hGUI.gObj.p_exResp02,sprintf('vh_exResp02'),'EyeMovements/2019_Models/Sine')
    makeAxisStruct(hGUI.gObj.p_exResp03,sprintf('vh_exResp03'),'EyeMovements/2019_Models/Sine')
    makeAxisStruct(hGUI.gObj.p_exResp04,sprintf('vh_exResp04'),'EyeMovements/2019_Models/Sine')
end


%% Aug_2019
% NOTE: Seems like some of the problems of the Clark model could be solved by giving the model some intrinsic activity. This would add extra parameter but would
% give ability to undershoot when coming back to darkness and would make the response to flashes have a little tail.

% Replicate Fig.5 for all models
% Requires:
% (1) df + df_fit + df_norm
% (2) stj + stj_fit
% (3) ak_step + ak_step_flashes + fits + flashes + fits + isolated_flashes + taus [in theory, this could be just mapped out instead of fitting with single exponenetial]
% (4) prediction of steady-state current vs. Ib
% (5) prediction of gain vs Ib

%% monoClark
%% monoClark sequential fits
% Trying to find better params for Clark Model, so that between cells maybe only alpha, beta, gamma vary but filters have the same shape
% Also trying to get best fit with sequential fitting vs. best fit with all parameters free
%% Fit to dim-flash response using a linear Clark model (no feedback)
% (ignore other panels as they are not relevant to this fit)
% Fast version
hGUI = fit_monoClarkKy(struct('ak_subflag',1, 'ini',[44.8,0433,47.8,180]),10);
% Slow version
% hGUI = fit_monoClarkKy(struct('ak_subflag',1, 'ini',[22,510,282,1515]),10); 
%% Fit to saccade trajectory stimulus using fast dim-flash response and reincluding feedback
hGUI = fit_monoClarkKyClamped(struct('ak_subflag',0,'ini',[0166,0100,0448,019.4,036.0]),10); % 
% hGUI = fit_monoClarkKyClamped(struct('ak_subflag',0,'ini',[360,010,518,20,26.0]),10); % 

if false
    makeAxisStruct(hGUI.gObj.dfp,sprintf('df'),'EyeMovements/2019_Models/monoClark') 
%     makeAxisStruct(hGUI.gObj.stpstim,sprintf('stj_stim'),'EyeMovements/2019_Models/monoClark')
    makeAxisStruct(hGUI.gObj.stp,sprintf('stj'),'EyeMovements/2019_Models/monoClark')
    makeAxisStruct(hGUI.gObj.gfs_stim,sprintf('gStim'),'EyeMovements/2019_Models/monoClark')
    makeAxisStruct(hGUI.gObj.gfs,sprintf('gF'),'EyeMovements/2019_Models/monoClark')
    makeAxisStruct(hGUI.gObj.gwf,sprintf('gW'),'EyeMovements/2019_Models/monoClark')
    makeAxisStruct(hGUI.gObj.ssi_stim,sprintf('ssiStim'),'EyeMovements/2019_Models/monoClark')
    makeAxisStruct(hGUI.gObj.ssi,sprintf('ssiS'),'EyeMovements/2019_Models/monoClark')
    makeAxisStruct(hGUI.gObj.ssiibs,sprintf('ssiH'),'EyeMovements/2019_Models/monoClark')
end

%% Trying to replicate fit to Baylor data in 2013 Clark paper but just realized that this is entirely for turtle cones which have a ttp of ~ 100 ms instead of 34 ms
hGUI = fit_monoClark(struct('ak_subflag',0,'ini',[38,200,150,700,930,39,.11,4.4]),10);
%% Trying to get filters for model diagram
%made testClark.m, copied cModelUni_Ky_clamped into it and replaced title by 
% function [response,FiltY,FiltZ] = testmonoClark(coeffs,time,stim,dt,varargin)
% [r,FY,FZ]=testmonoClark(hGUI.curr,hGUI.df_tme,hGUI.df_stm,hGUI.dt);
% [r,Ky,Kz]=testmonoClark([0166,0100,0448,019.4,036.0],hGUI.df_tme,hGUI.df_stm,hGUI.dt);
[r,Ky,Kz]=testmonoClark([40,0200,0448,019.4,036.0],hGUI.df_tme,hGUI.df_stm,hGUI.dt);

% % % % [r,Ky,Kz]=testmonoClark_Clark([20,700,930,.11,4.4],hGUI.df_tme,hGUI.df_stm,hGUI.dt);

f1 = getfigH(1);
xlim([0 .25])
lH=lineH(hGUI.df_tme,normalize(hGUI.df_ifit),f1);
lH.linek;lH.setName('df');lH.h.LineWidth=2;

lH=lineH(hGUI.df_tme,normalize(Ky),f1);
lH.lineb;lH.setName('Ky');lH.h.LineWidth=2;
%faking this one
lH=lineH(hGUI.df_tme,normalize(Kz),f1);
lH.lineg;lH.setName('Kz');lH.h.LineWidth=2;

if false
    makeAxisStruct(f1,sprintf('DiagramCurves'),'EyeMovements/2019_Models/monoClark') 
end



%%

% % % % obtained from full model fit to stj, which looks like fast dim-flash response without weird hump
% % %     tauy = 45 / 10000;
% % %     ny = 433 / 100;
% % %     tauR = 48 / 10000;
% % %     
% % %     
% % %     tauz = coeffs(1) / 1000;
% % %     nz = coeffs(2) / 100;
% % %     gamma = coeffs(3) / 1000;
% % %     alpha = coeffs(4) / 1; %following new rescaling from monoClark on Aug 2019
% % %     beta = coeffs(5) / 100;
% % %     
% % % 
% % % % obtained from full model fit to stj, which looks like fast dim-flash response without weird hump
% % %     tauy = 45 / 10000;
% % %     ny = 433 / 100;
% % %     tauR = 48 / 10000;
% % %     tauz = 166 / 1000;
% % %     nz = 100 / 100;
% % %     
% % %     gamma = coeffs(1) / 1000;
% % %     alpha = coeffs(2) / 1; %10;
% % %     beta = coeffs(3) / 100; %1000;
%% Exploring manually how to get better adaptation
% fit to stj: Io = 1 111 790 R/s; I1/2 = 1 570 000 R*/s n = 1
% hGUI = fit_monoClarkKyClamped(struct('ak_subflag',0,'ini',[0166,0100,0448,019.4,036.0]),10);
% without touching Z
    % increasing gamma decreases I0: I0(gamma=1000) = 689 793 but it also squares off the responses
%         hGUI = fit_monoClarkKyClamped(struct('ak_subflag',0,'ini',[0166,0100,1000,019.4,036.0]),10); 
    % if gamma is too high, sharp decreases in luminance create a huge response
%         hGUI = fit_monoClarkKyClamped(struct('ak_subflag',0,'ini',[0166,0100,3000,019.4,036.0]),10); 
    % increasing alpha increases responses but does not alter adaptation properties
%         hGUI = fit_monoClarkKyClamped(struct('ak_subflag',0,'ini',[0166,0100,0448,200,036.0]),10);
    % increasing beta greatly reduces I0: I0(gamma=200) = 190 701 but makes responses really small
%         hGUI = fit_monoClarkKyClamped(struct('ak_subflag',0,'ini',[0166,0100,0448,19.4,200]),10);
    % increasing beta greatly reduces I0: I0(gamma=500) = 75 687
%         hGUI = fit_monoClarkKyClamped(struct('ak_subflag',0,'ini',[0166,0100,0448,19.4,500]),10);
    % increasing beta greatly reduces I0: I0(gamma=500) = 75 687 and counteracting size by increasing alpha really distorts responses
%         hGUI = fit_monoClarkKyClamped(struct('ak_subflag',0,'ini',[0166,0100,0448,200,500]),10);
%         hGUI = fit_monoClarkKyClamped(struct('ak_subflag',0,'ini',[300,100,0448,200,500]),10);
    % increasing beta greatly reduces I0: I0(gamma=500) = 75 687 and counteracting size by increasing alpha really distorts responses
%         hGUI = fit_monoClarkKyClamped(struct('ak_subflag',0,'ini',[0166,0100,800,200,500]),10);
%     hGUI = fit_monoClarkKyClamped(struct('ak_subflag',0,'ini',[0166,0100,500,200,500]),10);
    
%     hGUI = fit_monoClarkKyClamped(struct('ak_subflag',0,'ini',[0357,100,600,320,200]),10);
%     hGUI = fit_monoClarkKyClamped(struct('ak_subflag',0,'ini',[300,200,600,600,340]),10);

    %lsq keeps finding this fit as good:
%     hGUI = fit_monoClarkKyClamped(struct('ak_subflag',0,'ini',[0357,2.51e-14,0518,20.3,26.1,]),10);
    %from there:
%     hGUI = fit_monoClarkKyClamped(struct('ak_subflag',0,'ini',[200,100,1000,200,400,]),10);
 
%% Fit to saccade trajectory stimulus with all free parameters
% This fitting has a lot of local minima
% hGUI = fit_monoClark(struct('ak_subflag',0,'ini',[28,0269,0119,20,0986,319,0116,0920]),10);
hGUI = fit_monoClark(struct('ak_subflag',0,'ini',[70,0351,0152,8,0958,0146,39,0295]),10);

%% Fit to Steps + Flashes (Adaptation Kinetics) using filters from fit to dim flash + saccade trajectory
% Fast version
% hGUI = fit_monoClark_ak_KyClamped(struct('plotFlag',0,'ini',[745,1320,829]),10); %best consistent fit has weird recovery kinetics with initial acceleration (but data too). It's also faster
% Slow version
% hGUI = fit_monoClark_ak_KyClamped(struct('plotFlag',0,'ini',[942,2190,0881]),10);
if false
    makeAxisStruct(hGUI.gObj.p_stimS,sprintf('ak_stimS'),'EyeMovements/2019_Models/monoClark') 
    makeAxisStruct(hGUI.gObj.p_stimF,sprintf('ak_stimF'),'EyeMovements/2019_Models/monoClark')
    makeAxisStruct(hGUI.gObj.p_resp,sprintf('ak_resp'),'EyeMovements/2019_Models/monoClark') 
    makeAxisStruct(hGUI.gObj.p_subf,sprintf('ak_subf'),'EyeMovements/2019_Models/monoClark') 
    makeAxisStruct(hGUI.gObj.p_on,sprintf('ak_on'),'EyeMovements/2019_Models/monoClark') 
    makeAxisStruct(hGUI.gObj.p_off,sprintf('ak_off'),'EyeMovements/2019_Models/monoClark')
end
%% Fit to Steps + Flashes (Adaptation Kinetics) with all free parameters
% but still starting parameters close to Ky_clamped
% Here it's hard to get pleasing fits to both step and flashes 
% hGUI = fit_monoClark_ak(struct('plotFlag',0,'ini',[52,0364,0282,100,0963,293,500,2324]),10); %this was example cell#1
% this works pretty well, but dimflash response ttp is long
hGUI = fit_monoClark_ak(struct('plotFlag',0,'ini',[80.5,0189,0213,0.801,0915,0336,2140,9700]),10); %this is example cell#2



%% Binary noise for monoClark model
hGUI = fit_monoClark_bn(10);BIPBIP();

% % saving to struct to make summary plot for all models
bn.monoClark = hGUI.modelRatio';
bn.monoClarkIbs = hGUI.ib';

if false
    makeAxisStruct(hGUI.gObj.p_ex50kStim,sprintf('mc_exStim'),'EyeMovements/2019_Models/BinaryNoise') 
    makeAxisStruct(hGUI.gObj.p_ex50k,sprintf('mc_exFit'),'EyeMovements/2019_Models/BinaryNoise')
end

%% Replicate responses to sine stimulation
% Difficult to fit low background data but very good for high background.
figure(1);clf;
hGUI = fit_monoClark_sine(1);



% % saving to struct to make summary plot for all models
sine.monoClark= hGUI.modelRatio';
sine.monoClarkIbs = hGUI.ib';

if false
    makeAxisStruct(hGUI.gObj.p_exStim,sprintf('mc_exStim'),'EyeMovements/2019_Models/Sine') 
    makeAxisStruct(hGUI.gObj.p_exResp01,sprintf('mc_exResp01'),'EyeMovements/2019_Models/Sine')
    makeAxisStruct(hGUI.gObj.p_exResp02,sprintf('mc_exResp02'),'EyeMovements/2019_Models/Sine')
    makeAxisStruct(hGUI.gObj.p_exResp03,sprintf('mc_exResp03'),'EyeMovements/2019_Models/Sine')
    makeAxisStruct(hGUI.gObj.p_exResp04,sprintf('mc_exResp04'),'EyeMovements/2019_Models/Sine')
end


%% biClark
%% biClark sequential fits
% Will use same "linear fit" as monoClark
% Fast version
hGUI = fit_monoClarkKy(struct('ak_subflag',1, 'ini',[44.8,0433,47.8,180]),10);
% Slow version
% hGUI = fit_monoClarkKy(struct('ak_subflag',1, 'ini',[22,510,282,1515]),10); 
%% Fit to saccade trajectory stimulus using fast dim-flash response and reincluding feedbacks
% % % hGUI = fit_biClarkKyClamped(struct('ak_subflag',0,'ini',[0166,0100,0448,0194,0360,0287,10.7,0246]),10); % this one is not great. Why is it here?
% hGUI = fit_biClarkKyClamped(struct('ak_subflag',0,'ini',[0312,70.7,0202,0206,0479,0578,86.5,0.026]),10); %from lsq. Need to play with nz2 and more fits
% hGUI = fit_biClarkKyClamped(struct('ak_subflag',0,'ini',[0140,0394,0310,0204,0475,0678,68.8,0127]),10); % somehow these 2 models are indistinguishable
% hGUI = fit_biClarkKyClamped(struct('ak_subflag',0,'ini',[0171,0269,0415,0205,0372,0502,42.9,0227]),10); % somehow there 3 models are indistinguishable

% Apr_2020: Just realized in all these fits tauz_slow is faster that tauz. Trying to get new fit
hGUI = fit_biClarkKyClamped(struct('ak_subflag',0,'ini',[35,0284,0500,0205,0312,146,184,0232]),10); 

if false
    makeAxisStruct(hGUI.gObj.dfp,sprintf('df'),'EyeMovements/2019_Models/biClark') 
%     makeAxisStruct(hGUI.gObj.stpstim,sprintf('stj_stim'),'EyeMovements/2019_Models/biClark')
    makeAxisStruct(hGUI.gObj.stp,sprintf('stj'),'EyeMovements/2019_Models/biClark')
    makeAxisStruct(hGUI.gObj.gfs_stim,sprintf('gStim'),'EyeMovements/2019_Models/biClark')
    makeAxisStruct(hGUI.gObj.gfs,sprintf('gF'),'EyeMovements/2019_Models/biClark')
    makeAxisStruct(hGUI.gObj.gwf,sprintf('gW'),'EyeMovements/2019_Models/biClark')
    makeAxisStruct(hGUI.gObj.ssi_stim,sprintf('ssiStim'),'EyeMovements/2019_Models/biClark')
    makeAxisStruct(hGUI.gObj.ssi,sprintf('ssiS'),'EyeMovements/2019_Models/biClark')
    makeAxisStruct(hGUI.gObj.ssiibs,sprintf('ssiH'),'EyeMovements/2019_Models/biClark')
end
%% Fit to Steps + Flashes (Adaptation Kinetics) using filters from fit to dim flash + saccade trajectory
% Fast version

% this is old example cell
% hGUI = fit_biClark_ak_KyClamped(struct('plotFlag',0,'ini',[931,621,294,1e-14]),10); %best fit to flash #2 but has weird off kinetics
% hGUI = fit_biClark_ak_KyClamped(struct('plotFlag',0,'ini',[772,0749,0407,34]),10); %best fit to step alone and still has weird off kinetics (although less noticeable)

hGUI = fit_biClark_ak_KyClamped(struct('plotFlag',0,'ini',[896,1248,651,114]),10); %best fit to step alone and still has weird off kinetics (although less noticeable)

% Slow version
% hGUI = fit_monoClark_ak_KyClamped(struct('plotFlag',0,'ini',[942,2190,0881]),10);
if false
    makeAxisStruct(hGUI.gObj.p_stimS,sprintf('ak_stimS'),'EyeMovements/2019_Models/biClark') 
    makeAxisStruct(hGUI.gObj.p_stimF,sprintf('ak_stimF'),'EyeMovements/2019_Models/biClark')
    makeAxisStruct(hGUI.gObj.p_resp,sprintf('ak_resp'),'EyeMovements/2019_Models/biClark') 
    makeAxisStruct(hGUI.gObj.p_subf,sprintf('ak_subf'),'EyeMovements/2019_Models/biClark') 
    makeAxisStruct(hGUI.gObj.p_on,sprintf('ak_on'),'EyeMovements/2019_Models/biClark') 
    makeAxisStruct(hGUI.gObj.p_off,sprintf('ak_off'),'EyeMovements/2019_Models/biClark')
end


%% Binary noise for biClark model
hGUI = fit_biClark_bn(10);BIPBIP();

% % saving to struct to make summary plot for all models
bn.biClark = hGUI.modelRatio';
bn.biClarkIbs = hGUI.ib';

if false
    makeAxisStruct(hGUI.gObj.p_ex50kStim,sprintf('bc_exStim'),'EyeMovements/2019_Models/BinaryNoise') 
    makeAxisStruct(hGUI.gObj.p_ex50k,sprintf('bc_exFit'),'EyeMovements/2019_Models/BinaryNoise')
   
%     save('/Users/angueyraaristjm/matlab/AnalysisMain/ConeAnalysis/ClarkModel/bnRatiosAllModels.mat',bn);
    f1 = getfigH(1);
    f1.XScale='log';
    lH = lineH(bn.biRiekeIbs,bn.biRieke,f1);
    lH.color([198 026 000]./255); lH.setName('biRieke');lH.linewidth_up;
    lH = lineH(bn.vanHatIbs,bn.vanHat,f1);
    lH.color([000 075 245]./255); lH.setName('vanHat');lH.linewidth_up;
    lH = lineH(bn.monoClarkIbs,bn.monoClark,f1);
    lH.color([077 221 169]./255); lH.setName('monoClark');lH.linewidth_up;
    lH = lineH(bn.biClarkIbs,bn.biClark,f1);
    lH.color([255 127 000]./255); lH.setName('biClark');lH.linewidth_up;
    
    makeAxisStruct(f1,sprintf('bnRatios'),'EyeMovements/2019_Models/BinaryNoise') 
end



%% Replicate responses to sine stimulation
% Difficult to fit low background data but very good for high background.
figure(1);clf;
hGUI = fit_biClark_sine(1);

% % saving to struct to make summary plot for all models
sine.biClark= hGUI.modelRatio';
sine.biClarkIbs = hGUI.ib';

if false
    makeAxisStruct(hGUI.gObj.p_exStim,sprintf('bc_exStim'),'EyeMovements/2019_Models/Sine') 
    makeAxisStruct(hGUI.gObj.p_exResp01,sprintf('bc_exResp01'),'EyeMovements/2019_Models/Sine')
    makeAxisStruct(hGUI.gObj.p_exResp02,sprintf('bc_exResp02'),'EyeMovements/2019_Models/Sine')
    makeAxisStruct(hGUI.gObj.p_exResp03,sprintf('bc_exResp03'),'EyeMovements/2019_Models/Sine')
    makeAxisStruct(hGUI.gObj.p_exResp04,sprintf('bc_exResp04'),'EyeMovements/2019_Models/Sine')
    
    %     save('/Users/angueyraaristjm/matlab/AnalysisMain/ConeAnalysis/ClarkModel/sineRatiosAllModels.mat',sine);
    f1 = getfigH(9);
    f1.XScale='log';
    lH = lineH(sine.biRiekeIbs,sine.biRieke,f1);
    lH.color([198 026 000]./255); lH.setName('biRieke');lH.linewidth_up;
    lH = lineH(sine.vanHatIbs,sine.vanHat,f1);
    lH.color([000 075 245]./255); lH.setName('vanHat');lH.linewidth_up;
    lH = lineH(sine.monoClarkIbs,sine.monoClark,f1);
    lH.color([077 221 169]./255); lH.setName('monoClark');lH.linewidth_up;
    lH = lineH(sine.biClarkIbs,sine.biClark,f1);
    lH.color([255 127 000]./255); lH.setName('biClark');lH.linewidth_up;
    
    makeAxisStruct(f1,sprintf('bnRatios'),'EyeMovements/2019_Models/BinaryNoise')
end

%% Trying to get filters for model diagram
%made testClark.m, copied cModelUni_Ky_clamped into it and replaced title by 
% function [response,FiltY,FiltZ] = testClark(coeffs,time,stim,dt,varargin)
% [r,FY,FZ]=testClark(hGUI.curr,hGUI.df_tme,hGUI.df_stm,hGUI.dt);
% [r,Ky,Kz]=testClark([0166,0100,0448,019.4,036.0],hGUI.df_tme,hGUI.df_stm,hGUI.dt);
% [r,Ky,Kz,Kzs]=testClark([0171,0269,0415,0205,0372,0502,42.9,0227],hGUI.df_tme,hGUI.df_stm,hGUI.dt,1);
% [r,Ky,Kz,Kzs]=testClark([35,0284,0500,0205,0312,146,184,0232],hGUI.df_tme,hGUI.df_stm,hGUI.dt,0);

df_tme = 0:hGUI.dt:2;
df_stm = (df_tme*0);
df_stm(1:length(hGUI.df_stm)) = hGUI.df_stm; 
% [r,Ky,Kz,Kzs]=testClark([35,0284,0500,0205,0312,146,184,0232],df_tme,df_stm,hGUI.dt,0); % hard for diagram
[r,Ky,Kz,Kzs]=testClark([35,0284,0500,0205,0312,146,80,0232],df_tme,df_stm,hGUI.dt,0);

f1 = getfigH(1);
% xlim([0 .5])
lH=lineH(hGUI.df_tme,normalize(hGUI.df_ifit),f1);
lH.linedash;lH.setName('df');lH.h.LineWidth=2;

lH=lineH(df_tme,normalize(Ky),f1);
lH.lineb;lH.setName('Ky');lH.h.LineWidth=2;
%faking this one
lH=lineH(df_tme,normalize(Kz),f1);
lH.lineg;lH.setName('Kz');lH.h.LineWidth=2;


%faking this one
lH=lineH(df_tme,normalize(Kzs),f1);
lH.liner;lH.setName('Kzs');lH.h.LineWidth=2;

if false
    makeAxisStruct(f1,sprintf('DiagramCurves'),'EyeMovements/2019_Models/biClark') 
end




%%
f1 = getfigH(1);
% xlim([0 .5])

lH=lineH([0 df_tme],[0 exp(-df_tme/.30)],f1);
lH.linek;lH.setName('e0');lH.h.LineWidth=2;

lH=lineH([df_tme],[exp(-df_tme/.10)],f1);
lH.liner;lH.setName('e1');lH.h.LineWidth=2;

lH=lineH([df_tme],[exp(-df_tme/.20)],f1);
lH.liner;lH.setName('e2');lH.h.LineWidth=2;

lH=lineH([df_tme],[exp(-df_tme/.30)],f1);
lH.liner;lH.setName('e3');lH.h.LineWidth=2;

lH=lineH([df_tme],[exp(-df_tme/.10)],f1);
lH.liner;lH.setName('e4');lH.h.LineWidth=2;

lH=lineH([df_tme],[exp(-df_tme/.30)],f1);
lH.liner;lH.setName('e5');lH.h.LineWidth=2;

lH=lineH([df_tme],[exp(-df_tme/.03)],f1);
lH.liner;lH.setName('e6');lH.h.LineWidth=2;



if false
    makeAxisStruct(f1,sprintf('ExpCurve'),'EyeMovements/2019_Models/biClark') 
end



%% 2019 code before trying to match isetbio params again.
% To get back to this would need to use rModel5 in all fitting instead of rModel6
%% vanHat
%% Fit to saccade trajectory
hGUI = fit_vanHat(struct('ak_subflag',0),10);
if false
    makeAxisStruct(hGUI.gObj.dfp,sprintf('df'),'EyeMovements/2019_Models/vanHat') 
    makeAxisStruct(hGUI.gObj.stpstim,sprintf('stj_stim'),'EyeMovements/2019_Models/vanHat')
    makeAxisStruct(hGUI.gObj.stp,sprintf('stj'),'EyeMovements/2019_Models/vanHat')
    makeAxisStruct(hGUI.gObj.gfs,sprintf('gF'),'EyeMovements/2019_Models/vanHat')
    makeAxisStruct(hGUI.gObj.gwf,sprintf('gW'),'EyeMovements/2019_Models/vanHat')
    makeAxisStruct(hGUI.gObj.ssi,sprintf('ssiS'),'EyeMovements/2019_Models/vanHat')
    makeAxisStruct(hGUI.gObj.ssiibs,sprintf('ssiH'),'EyeMovements/2019_Models/vanHat')
end
%% Fit to adaptation kinetics
% hGUI = fit_vanHat_ak_Clamped(struct('plotFlag',0),10);
% hGUI = fit_vanHat_ak_Clamped(struct('plotFlag',0,'ini',[327,1965,2.7]),10); %free eta and free opsin gain
hGUI = fit_vanHat_ak_Clamped(struct('plotFlag',0,'ini',[327,8585,13]),10); %free eta and free opsin gain
if false
    makeAxisStruct(hGUI.gObj.p_stim,sprintf('ak_stim'),'EyeMovements/2019_Models/vanHat') 
    makeAxisStruct(hGUI.gObj.p_resp,sprintf('ak_resp'),'EyeMovements/2019_Models/vanHat') 
    makeAxisStruct(hGUI.gObj.p_subf,sprintf('ak_subf'),'EyeMovements/2019_Models/vanHat') 
    makeAxisStruct(hGUI.gObj.p_on,sprintf('ak_on'),'EyeMovements/2019_Models/vanHat') 
    makeAxisStruct(hGUI.gObj.p_off,sprintf('ak_off'),'EyeMovements/2019_Models/vanHat') 
end
%% biRieke
%% Fit to saccade trajectory
% hGUI = fit_biRieke(struct('ak_subflag',0,'ini',[474,220,8538,125,280]),10); % this was with hillboost 3, but I think Fred never used this, so turned back to 1
% hGUI = fit_biRieke(struct('ak_subflag',0,'ini',[0492,0228,8412,0192.5,0189,]),10); % this is with hillboost 1
hGUI = fit_biRieke(struct('ak_subflag',0,'ini',[0504,0232,8000,0193,400,]),10); % this is from isetbio params (modified to rModel6)
% hGUI = fit_biRieke(struct('ak_subflag',0,'ini',[0492,0228,8412,264.5,0189,]),10); % this is almost fit to ak, but need to modify opsing gain from 10 to 13
if false
    makeAxisStruct(hGUI.gObj.dfp,sprintf('df'),'EyeMovements/2019_Models/biRieke') 
    makeAxisStruct(hGUI.gObj.stpstim,sprintf('stj_stim'),'EyeMovements/2019_Models/biRieke')
    makeAxisStruct(hGUI.gObj.stp,sprintf('stj'),'EyeMovements/2019_Models/biRieke')
    makeAxisStruct(hGUI.gObj.gfs,sprintf('gF'),'EyeMovements/2019_Models/biRieke')
    makeAxisStruct(hGUI.gObj.gwf,sprintf('gW'),'EyeMovements/2019_Models/biRieke')
    makeAxisStruct(hGUI.gObj.ssi,sprintf('ssiS'),'EyeMovements/2019_Models/biRieke')
    makeAxisStruct(hGUI.gObj.ssiibs,sprintf('ssiH'),'EyeMovements/2019_Models/biRieke')
end


%% Fit to adaptation kinetics only 2 parameters
hGUI = fit_biRieke_ak_Clamped(struct('plotFlag',0,'ini',[264,13]),10);

if false
    makeAxisStruct(hGUI.gObj.p_stim,sprintf('ak_stim'),'EyeMovements/2019_Models/biRieke') 
    makeAxisStruct(hGUI.gObj.p_resp,sprintf('ak_resp'),'EyeMovements/2019_Models/biRieke') 
    makeAxisStruct(hGUI.gObj.p_subf,sprintf('ak_subf'),'EyeMovements/2019_Models/biRieke') 
    makeAxisStruct(hGUI.gObj.p_on,sprintf('ak_on'),'EyeMovements/2019_Models/biRieke') 
    makeAxisStruct(hGUI.gObj.p_off,sprintf('ak_off'),'EyeMovements/2019_Models/biRieke') 
end

%% Fit to adaptation kinetics all parameters
hGUI = fit_biRieke_ak(struct('plotFlag',0,'ini',[0527,0186,10480,0174,220]),10);

%% 2017 code
%% 2017 code
%% 2017 code
%% 2017 code
%% 2017 code
%% 2017 code
%% Show me the fit!
% fitting stj
% hGUI = fit_monoClark(struct('ak_subflag',0),10);
% hGUI = fit_biClark(struct('ak_subflag',0),10);
% hGUI = fit_vanHat(struct('ak_subflag',0),10);
% hGUI = fit_biRieke(struct('ak_subflag',0),10);

% fitting hyst
% hGUI = fit_monoClark_hyst(struct('plotFlag',0,'normFlag',0,'phaseFlag',5),10);
% hGUI = fit_biClark_hyst(struct('plotFlag',0,'normFlag',0,'phaseFlag',1),10);
% hGUI = fit_vanHat_hyst(struct('plotFlag',0,'normFlag',0,'phaseFlag',1),10);
% hGUI = fit_biRieke_hyst(struct('plotFlag',0,'normFlag',0,'phaseFlag',1),10);

% fitting adaptation kinetics
% hGUI = fit_biClark_ak(struct('plotFlag',0),10);
hGUI = fit_monoClark_ak(struct('plotFlag',0),10);
%% Export fits to Igor (February 2017)
%% Saccade trajectory
%% monoClark
hGUI = fit_monoClark(struct('ak_subflag',0),10);
% makeAxisStruct(hGUI.gObj.stpstim,sprintf('%s_%s_stim','monoClark','stj'),'EyeMovements/2017_06_modelFits/stj')
% makeAxisStruct(hGUI.gObj.stp,sprintf('%s_%s','monoClark','stj'),'EyeMovements/2017_06_modelFits/stj')
% makeAxisStruct(hGUI.gObj.dfp,sprintf('%s_%s_df','monoClark','stj'),'EyeMovements/2017_06_modelFits/stj')
hGUI.gObj.dfnormButton.Value=1; hGUI.dfNorm();
% makeAxisStruct(hGUI.gObj.dfp,sprintf('%s_%s_dfnorm','monoClark','stj'),'EyeMovements/2017_06_modelFits/stj')
%% biClark
hGUI = fit_biClark(struct('ak_subflag',0),10);
% makeAxisStruct(hGUI.gObj.stpstim,sprintf('%s_%s_stim','biClark','stj'),'EyeMovements/2017_06_modelFits/stj')
% makeAxisStruct(hGUI.gObj.stp,sprintf('%s_%s','biClark','stj'),'EyeMovements/2017_06_modelFits/stj')
% makeAxisStruct(hGUI.gObj.dfp,sprintf('%s_%s_df','biClark','stj'),'EyeMovements/2017_06_modelFits/stj')
hGUI.gObj.dfnormButton.Value=1; hGUI.dfNorm();
% makeAxisStruct(hGUI.gObj.dfp,sprintf('%s_%s_dfnorm','biClark','stj'),'EyeMovements/2017_06_modelFits/stj')
%% vanHat
hGUI = fit_vanHat(struct('ak_subflag',0),10);
% makeAxisStruct(hGUI.gObj.stpstim,sprintf('%s_%s_stim','vanHat','stj'),'EyeMovements/2017_06_modelFits/stj')
% makeAxisStruct(hGUI.gObj.stp,sprintf('%s_%s','vanHat','stj'),'EyeMovements/2017_06_modelFits/stj')
% makeAxisStruct(hGUI.gObj.dfp,sprintf('%s_%s_df','vanHat','stj'),'EyeMovements/2017_06_modelFits/stj')
hGUI.gObj.dfnormButton.Value=0; hGUI.dfNorm();
% makeAxisStruct(hGUI.gObj.dfp,sprintf('%s_%s_dfnorm','vanHat','stj'),'EyeMovements/2017_06_modelFits/stj')
%% biRieke
hGUI = fit_biRieke(struct('ak_subflag',0),10);
% makeAxisStruct(hGUI.gObj.stpstim,sprintf('%s_%s_stim','biRieke','stj'),'EyeMovements/2017_06_modelFits/stj')
% makeAxisStruct(hGUI.gObj.stp,sprintf('%s_%s','biRieke','stj'),'EyeMovements/2017_06_modelFits/stj')
% makeAxisStruct(hGUI.gObj.dfp,sprintf('%s_%s_df','biRieke','stj'),'EyeMovements/2017_06_modelFits/stj')
hGUI.gObj.dfnormButton.Value=0; hGUI.dfNorm();
% makeAxisStruct(hGUI.gObj.dfp,sprintf('%s_%s_dfnorm','biRieke','stj'),'EyeMovements/2017_06_modelFits/stj')

%%
%%
%% Steps and Sines (or hysteresis)
%% monoClark
hGUI = fit_monoClark_hyst(struct('plotFlag',1,'normFlag',0),10);
% makeAxisStruct(hGUI.gObj.full_stim,sprintf('%s_%s_stim','monoClark','hyst'),'EyeMovements/2017_06_modelFits/hyst')
% makeAxisStruct(hGUI.gObj.full_ss,sprintf('%s_%s','monoClark','hyst'),'EyeMovements/2017_06_modelFits/hyst')
% makeAxisStruct(hGUI.gObj.dfp,sprintf('%s_%s_df','monoClark','hyst'),'EyeMovements/2017_06_modelFits/hyst')
hGUI.gObj.dfnormButton.Value=1; hGUI.dfNorm();
% makeAxisStruct(hGUI.gObj.dfp,sprintf('%s_%s_dfnorm','monoClark','hyst'),'EyeMovements/2017_06_modelFits/hyst')
hGUI = fit_monoClark_hyst(struct('plotFlag',1,'normFlag',0,'phaseFlag',5),10);
% makeAxisStruct(hGUI.gObj.full_stim,sprintf('%s_%s2_stim','monoClark','hyst'),'EyeMovements/2017_06_modelFits/hyst')
% makeAxisStruct(hGUI.gObj.full_ss,sprintf('%s_%s2','monoClark','hyst'),'EyeMovements/2017_06_modelFits/hyst')
%% biClark
hGUI = fit_biClark_hyst(struct('plotFlag',1,'normFlag',0),10);
% makeAxisStruct(hGUI.gObj.full_stim,sprintf('%s_%s_stim','biClark','hyst'),'EyeMovements/2017_06_modelFits/hyst')
% makeAxisStruct(hGUI.gObj.full_ss,sprintf('%s_%s','biClark','hyst'),'EyeMovements/2017_06_modelFits/hyst')
% makeAxisStruct(hGUI.gObj.dfp,sprintf('%s_%s_df','biClark','hyst'),'EyeMovements/2017_06_modelFits/hyst')
hGUI.gObj.dfnormButton.Value=1; hGUI.dfNorm();
% makeAxisStruct(hGUI.gObj.dfp,sprintf('%s_%s_dfnorm','biClark','hyst'),'EyeMovements/2017_06_modelFits/hyst')
hGUI = fit_biClark_hyst(struct('plotFlag',1,'normFlag',0,'phaseFlag',5),10);
% makeAxisStruct(hGUI.gObj.full_stim,sprintf('%s_%s2_stim','biClark','hyst'),'EyeMovements/2017_06_modelFits/hyst')
% makeAxisStruct(hGUI.gObj.full_ss,sprintf('%s_%s2','biClark','hyst'),'EyeMovements/2017_06_modelFits/hyst')
%% vanHat
hGUI = fit_vanHat_hyst(struct('plotFlag',1,'normFlag',0),10);
dfh=findobj('tag','df_cfit'); dfh.YData=dfh.YData-2+.12;
dfh=findobj('tag','df_ffit'); dfh.YData=dfh.YData-2+.12;
dfh=findobj('tag','df_ifit'); dfh.YData=dfh.YData-2+.12;
%%
% makeAxisStruct(hGUI.gObj.full_stim,sprintf('%s_%s_stim','vanHat','hyst'),'EyeMovements/2017_06_modelFits/hyst')
% makeAxisStruct(hGUI.gObj.full_ss,sprintf('%s_%s','vanHat','hyst'),'EyeMovements/2017_06_modelFits/hyst')
% makeAxisStruct(hGUI.gObj.dfp,sprintf('%s_%s_df','vanHat','hyst'),'EyeMovements/2017_06_modelFits/hyst')
hGUI.gObj.dfnormButton.Value=1; hGUI.dfNorm();
% makeAxisStruct(hGUI.gObj.dfp,sprintf('%s_%s_dfnorm','vanHat','hyst'),'EyeMovements/2017_06_modelFits/hyst')
hGUI = fit_vanHat_hyst(struct('plotFlag',1,'normFlag',0,'phaseFlag',5),10);
% makeAxisStruct(hGUI.gObj.full_stim,sprintf('%s_%s2_stim','vanHat','hyst'),'EyeMovements/2017_06_modelFits/hyst')
% makeAxisStruct(hGUI.gObj.full_ss,sprintf('%s_%s2','vanHat','hyst'),'EyeMovements/2017_06_modelFits/hyst')
%% biRieke
hGUI = fit_biRieke_hyst(struct('plotFlag',1,'normFlag',0),10);
dfh=findobj('tag','df_cfit'); dfh.YData=dfh.YData-1.5+.015;
dfh=findobj('tag','df_ffit'); dfh.YData=dfh.YData-1.5+.015;
dfh=findobj('tag','df_ifit'); dfh.YData=dfh.YData-1.5+.015;
%%
% makeAxisStruct(hGUI.gObj.full_stim,sprintf('%s_%s_stim','biRieke','hyst'),'EyeMovements/2017_06_modelFits/hyst')
% makeAxisStruct(hGUI.gObj.full_ss,sprintf('%s_%s','biRieke','hyst'),'EyeMovements/2017_06_modelFits/hyst')
% makeAxisStruct(hGUI.gObj.dfp,sprintf('%s_%s_df','biRieke','hyst'),'EyeMovements/2017_06_modelFits/hyst')
hGUI.gObj.dfnormButton.Value=1; hGUI.dfNorm();
% makeAxisStruct(hGUI.gObj.dfp,sprintf('%s_%s_dfnorm','biRieke','hyst'),'EyeMovements/2017_06_modelFits/hyst')

hGUI = fit_biRieke_hyst(struct('plotFlag',1,'normFlag',0,'phaseFlag',5),10);
% makeAxisStruct(hGUI.gObj.full_stim,sprintf('%s_%s2_stim','biRieke','hyst'),'EyeMovements/2017_06_modelFits/hyst')
% makeAxisStruct(hGUI.gObj.full_ss,sprintf('%s_%s2','biRieke','hyst'),'EyeMovements/2017_06_modelFits/hyst')
