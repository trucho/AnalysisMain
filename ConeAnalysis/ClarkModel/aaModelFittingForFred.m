%% Fitting cone models log (Jun 2017 - Aug 2019, Juan Angueyra)
% trying to rationalize and document model fitting procedures and avoid going in loops
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
% a lot of decimal values (probably rounding errors?). For this reason I have recaled parameters in the model functions themselves.

% For saccade trajectory GUIs: 'lsq' tries to fit saccade trajectory data while 'fmc' tries to fit dim-flash response
% For adaptation kinetics GUIs: 'lsq' tries to fit step + flashes with 40 ms delay while 'fmc' tries to fit step only (no flashes)
%% Aug_2019
% NOTE: Seems like some of the problems of the Clark model could be solved by giving the model some intrinsic activity. This would add extra parameter but would
% give ability to undershoot when coming back to darkness and would make the response to flashes have a little tail.
%% monoClark sequential fits
% Trying to find better params for Clark Model, so that between cells maybe only alpha, beta, gamma vary but filters have the same shape
% Also trying to get best fit with sequential fitting vs. best fit with all parameters free

%% Fit to dim-flash response using a linear Clark model (no feedback)
% (ignore other panels as they are not relevant to this fit)
% Fast version
% hGUI = fit_monoClarkKy(struct('ak_subflag',1, 'ini',[44.8,0433,47.8,1800]),10);
% Slow version
hGUI = fit_monoClarkKy(struct('ak_subflag',1, 'ini',[22,510,282,1515]),10); 
%% Fit to saccade trajectory stimulus using fast dim-flash response and reincluding feedback
hGUI = fit_monoClarkKyClamped(struct('ak_subflag',0,'ini',[0166,0100,0448,0194,0360]),10);
%% Fit to saccade trajectory stimulus with all free parameters
% This fitting has a lot of local minima
% hGUI = fit_monoClark(struct('ak_subflag',0,'ini',[28,0269,0119,20,0986,319,0116,0920]),10);
hGUI = fit_monoClark(struct('ak_subflag',0,'ini',[70,0351,0152,8,0958,0146,39,0295]),10);
%% Fit to Steps + Flashes (Adaptation Kinetics) using filters from fit to dim flash + saccade trajectory
hGUI = fit_monoClark_ak_KyClamped(struct('plotFlag',0,'ini',[783,810,485]),10);
%% Fit to Steps + Flashes (Adaptation Kinetics) with all free parameters
% but still starting parameters close to Ky_clamped
% Here it's hard to get pleasing fits to both step and flashes 
hGUI = fit_monoClark_ak(struct('plotFlag',0,'ini',[52,0364,0282,100,0963,293,500,2324]),10); 



