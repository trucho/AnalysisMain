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
% Things missing:
    % Calculate adaptation taus (possiblity to do this across many many light levels?)
    % Gain vs Ib
    % Steady-state current vs Ib
    % +/- vs Ib
    % Steps and Sines

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

if false
    makeAxisStruct(hGUI.gObj.dfp,sprintf('df'),'EyeMovements/2019_Models/monoClark') 
    makeAxisStruct(hGUI.gObj.stpstim,sprintf('stj_stim'),'EyeMovements/2019_Models/monoClark')
    makeAxisStruct(hGUI.gObj.stp,sprintf('stj'),'EyeMovements/2019_Models/monoClark')
    makeAxisStruct(hGUI.gObj.gfs,sprintf('gF'),'EyeMovements/2019_Models/monoClark')
    makeAxisStruct(hGUI.gObj.gwf,sprintf('gW'),'EyeMovements/2019_Models/monoClark')
    makeAxisStruct(hGUI.gObj.ssi,sprintf('ssiS'),'EyeMovements/2019_Models/monoClark')
    makeAxisStruct(hGUI.gObj.ssiibs,sprintf('ssiH'),'EyeMovements/2019_Models/monoClark')
end


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
%% Fit to saccade trajectory stimulus with all free parameters
% This fitting has a lot of local minima
% hGUI = fit_monoClark(struct('ak_subflag',0,'ini',[28,0269,0119,20,0986,319,0116,0920]),10);
hGUI = fit_monoClark(struct('ak_subflag',0,'ini',[70,0351,0152,8,0958,0146,39,0295]),10);
%% Fit to Steps + Flashes (Adaptation Kinetics) using filters from fit to dim flash + saccade trajectory
% Fast version
hGUI = fit_monoClark_ak_KyClamped(struct('plotFlag',0,'ini',[783,810,485]),10); %best consistent fit has weird recovery kinetics with initial acceleration (but data too). It's also faster
% Slow version
% hGUI = fit_monoClark_ak_KyClamped(struct('plotFlag',0,'ini',[942,2190,0881]),10);
if false
    makeAxisStruct(hGUI.gObj.p_stim,sprintf('ak_stim'),'EyeMovements/2019_Models/monoClark') 
    makeAxisStruct(hGUI.gObj.p_resp,sprintf('ak_resp'),'EyeMovements/2019_Models/monoClark') 
    makeAxisStruct(hGUI.gObj.p_subf,sprintf('ak_subf'),'EyeMovements/2019_Models/monoClark') 
    makeAxisStruct(hGUI.gObj.p_on,sprintf('ak_on'),'EyeMovements/2019_Models/monoClark') 
    makeAxisStruct(hGUI.gObj.p_off,sprintf('ak_off'),'EyeMovements/2019_Models/monoClark')
end
%% Fit to Steps + Flashes (Adaptation Kinetics) with all free parameters
% but still starting parameters close to Ky_clamped
% Here it's hard to get pleasing fits to both step and flashes 
hGUI = fit_monoClark_ak(struct('plotFlag',0,'ini',[52,0364,0282,100,0963,293,500,2324]),10); 


%% biClark
%% biClark sequential fits
% Will use same "linear fit" as monoClark
% Fast version
hGUI = fit_monoClarkKy(struct('ak_subflag',1, 'ini',[44.8,0433,47.8,1800]),10);
% Slow version
% hGUI = fit_monoClarkKy(struct('ak_subflag',1, 'ini',[22,510,282,1515]),10); 
%% Fit to saccade trajectory stimulus using fast dim-flash response and reincluding feedbacks
% hGUI = fit_biClarkKyClamped(struct('ak_subflag',0,'ini',[0166,0100,0448,0194,0360,0287,10.7,0246]),10);
% hGUI = fit_biClarkKyClamped(struct('ak_subflag',0,'ini',[0312,70.7,0202,0206,0479,0578,86.5,0.026]),10); %from lsq. Need to play with nz2 and more fits
% hGUI = fit_biClarkKyClamped(struct('ak_subflag',0,'ini',[0140,0394,0310,0204,0475,0678,68.8,0127]),10); % somehow these 2 models are indistinguishable
hGUI = fit_biClarkKyClamped(struct('ak_subflag',0,'ini',[0171,0269,0415,0205,0372,0502,42.9,0227]),10); % somehow there 3 models are indistinguishable

if false
    makeAxisStruct(hGUI.gObj.dfp,sprintf('df'),'EyeMovements/2019_Models/biClark') 
    makeAxisStruct(hGUI.gObj.stpstim,sprintf('stj_stim'),'EyeMovements/2019_Models/biClark')
    makeAxisStruct(hGUI.gObj.stp,sprintf('stj'),'EyeMovements/2019_Models/biClark')
    makeAxisStruct(hGUI.gObj.gfs,sprintf('gF'),'EyeMovements/2019_Models/biClark')
    makeAxisStruct(hGUI.gObj.gwf,sprintf('gW'),'EyeMovements/2019_Models/biClark')
    makeAxisStruct(hGUI.gObj.ssi,sprintf('ssiS'),'EyeMovements/2019_Models/biClark')
    makeAxisStruct(hGUI.gObj.ssiibs,sprintf('ssiH'),'EyeMovements/2019_Models/biClark')
end
%% Fit to Steps + Flashes (Adaptation Kinetics) using filters from fit to dim flash + saccade trajectory
% Fast version
% hGUI = fit_biClark_ak_KyClamped(struct('plotFlag',0,'ini',[931,621,294,1e-14]),10); %best fit to flash #2 but has weird off kinetics
hGUI = fit_biClark_ak_KyClamped(struct('plotFlag',0,'ini',[0695,0749,0452,286]),10); %best fit to step alone and still has weird off kinetics (although less noticeable)

% Slow version
% hGUI = fit_monoClark_ak_KyClamped(struct('plotFlag',0,'ini',[942,2190,0881]),10);
if false
    makeAxisStruct(hGUI.gObj.p_stim,sprintf('ak_stim'),'EyeMovements/2019_Models/biClark') 
    makeAxisStruct(hGUI.gObj.p_resp,sprintf('ak_resp'),'EyeMovements/2019_Models/biClark') 
    makeAxisStruct(hGUI.gObj.p_subf,sprintf('ak_subf'),'EyeMovements/2019_Models/biClark') 
    makeAxisStruct(hGUI.gObj.p_on,sprintf('ak_on'),'EyeMovements/2019_Models/biClark') 
    makeAxisStruct(hGUI.gObj.p_off,sprintf('ak_off'),'EyeMovements/2019_Models/biClark') 
end

%% HERE%% HERE
%% HERE
%% HERE%% HERE
%% HERE
%% HERE%% HERE
%% HERE%% HERE
%{
Need to now fit ak with these models too
Final stj models need to be:
    - run for on/off asymmetries
    - half-desensitizing background for dim flash response
    - steady-state current vs. background

    - possibility of tracking changes in adapation kinetics for many light levels?
%}
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
hGUI = fit_biRieke(struct('ak_subflag',0,'ini',[0492,0228,8412,0192.5,0189,]),10); % this is with hillboost 1
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
