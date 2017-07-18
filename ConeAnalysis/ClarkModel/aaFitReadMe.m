%% Fitting cone models log (Jun 2017, Juan Angueyra)
% trying to put some sense into it and avoid going in loops


%% BIG PROBLEM: clark models scale with skippts!
%% Open relevant files
%% Fitting GUIs
edit fit_monoClark.m
edit fit_biClark.m
edit fit_vanHat.m
edit fit_biRieke.m
% Things missing:
    % Calculate adaptation taus (possiblity to do this across many many light levels?)
    % Gain vs Ib
    % Steady-state current vs Ib
    % +/- vs Ib
    % Steps and Sines
%% Cone models
edit cModelUni.m    % Clark model
edit cModelBi.m     % Clark model (2 feedbacks)
edit vhModel5.m     % van Hateren's model
edit rModel5.m      % Rieke model (2 feedbacks)
%%
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
hGUI = fit_biClark_ak(struct('plotFlag',0),10);
%% Export fits to Igor
%% Saccade trajectory
%% monoClark
hGUI = fit_monoClark(struct('ak_subflag',0),10);
makeAxisStruct(hGUI.gObj.stpstim,sprintf('%s_%s_stim','monoClark','stj'),'EyeMovements/2017_06_modelFits/stj')
makeAxisStruct(hGUI.gObj.stp,sprintf('%s_%s','monoClark','stj'),'EyeMovements/2017_06_modelFits/stj')
makeAxisStruct(hGUI.gObj.dfp,sprintf('%s_%s_df','monoClark','stj'),'EyeMovements/2017_06_modelFits/stj')
hGUI.gObj.dfnormButton.Value=1; hGUI.dfNorm();
makeAxisStruct(hGUI.gObj.dfp,sprintf('%s_%s_dfnorm','monoClark','stj'),'EyeMovements/2017_06_modelFits/stj')
%% biClark
hGUI = fit_biClark(struct('ak_subflag',0),10);
makeAxisStruct(hGUI.gObj.stpstim,sprintf('%s_%s_stim','biClark','stj'),'EyeMovements/2017_06_modelFits/stj')
makeAxisStruct(hGUI.gObj.stp,sprintf('%s_%s','biClark','stj'),'EyeMovements/2017_06_modelFits/stj')
makeAxisStruct(hGUI.gObj.dfp,sprintf('%s_%s_df','biClark','stj'),'EyeMovements/2017_06_modelFits/stj')
hGUI.gObj.dfnormButton.Value=1; hGUI.dfNorm();
makeAxisStruct(hGUI.gObj.dfp,sprintf('%s_%s_dfnorm','biClark','stj'),'EyeMovements/2017_06_modelFits/stj')
%% vanHat
hGUI = fit_vanHat(struct('ak_subflag',0),10);
makeAxisStruct(hGUI.gObj.stpstim,sprintf('%s_%s_stim','vanHat','stj'),'EyeMovements/2017_06_modelFits/stj')
makeAxisStruct(hGUI.gObj.stp,sprintf('%s_%s','vanHat','stj'),'EyeMovements/2017_06_modelFits/stj')
makeAxisStruct(hGUI.gObj.dfp,sprintf('%s_%s_df','vanHat','stj'),'EyeMovements/2017_06_modelFits/stj')
hGUI.gObj.dfnormButton.Value=1; hGUI.dfNorm();
makeAxisStruct(hGUI.gObj.dfp,sprintf('%s_%s_dfnorm','vanHat','stj'),'EyeMovements/2017_06_modelFits/stj')
%% biRieke
hGUI = fit_biRieke(struct('ak_subflag',0),10);
makeAxisStruct(hGUI.gObj.stpstim,sprintf('%s_%s_stim','biRieke','stj'),'EyeMovements/2017_06_modelFits/stj')
makeAxisStruct(hGUI.gObj.stp,sprintf('%s_%s','biRieke','stj'),'EyeMovements/2017_06_modelFits/stj')
makeAxisStruct(hGUI.gObj.dfp,sprintf('%s_%s_df','biRieke','stj'),'EyeMovements/2017_06_modelFits/stj')
hGUI.gObj.dfnormButton.Value=1; hGUI.dfNorm();
makeAxisStruct(hGUI.gObj.dfp,sprintf('%s_%s_dfnorm','biRieke','stj'),'EyeMovements/2017_06_modelFits/stj')

%%
%%
%% Steps and Sines (or hysteresis)
%% monoClark
hGUI = fit_monoClark_hyst(struct('plotFlag',1,'normFlag',0),10);
makeAxisStruct(hGUI.gObj.full_stim,sprintf('%s_%s_stim','monoClark','hyst'),'EyeMovements/2017_06_modelFits/hyst')
makeAxisStruct(hGUI.gObj.full_ss,sprintf('%s_%s','monoClark','hyst'),'EyeMovements/2017_06_modelFits/hyst')
makeAxisStruct(hGUI.gObj.dfp,sprintf('%s_%s_df','monoClark','hyst'),'EyeMovements/2017_06_modelFits/hyst')
hGUI.gObj.dfnormButton.Value=1; hGUI.dfNorm();
makeAxisStruct(hGUI.gObj.dfp,sprintf('%s_%s_dfnorm','monoClark','hyst'),'EyeMovements/2017_06_modelFits/hyst')
hGUI = fit_monoClark_hyst(struct('plotFlag',1,'normFlag',0,'phaseFlag',5),10);
makeAxisStruct(hGUI.gObj.full_stim,sprintf('%s_%s2_stim','monoClark','hyst'),'EyeMovements/2017_06_modelFits/hyst')
makeAxisStruct(hGUI.gObj.full_ss,sprintf('%s_%s2','monoClark','hyst'),'EyeMovements/2017_06_modelFits/hyst')
%% biClark
hGUI = fit_biClark_hyst(struct('plotFlag',1,'normFlag',0),10);
makeAxisStruct(hGUI.gObj.full_stim,sprintf('%s_%s_stim','biClark','hyst'),'EyeMovements/2017_06_modelFits/hyst')
makeAxisStruct(hGUI.gObj.full_ss,sprintf('%s_%s','biClark','hyst'),'EyeMovements/2017_06_modelFits/hyst')
makeAxisStruct(hGUI.gObj.dfp,sprintf('%s_%s_df','biClark','hyst'),'EyeMovements/2017_06_modelFits/hyst')
hGUI.gObj.dfnormButton.Value=1; hGUI.dfNorm();
makeAxisStruct(hGUI.gObj.dfp,sprintf('%s_%s_dfnorm','biClark','hyst'),'EyeMovements/2017_06_modelFits/hyst')
hGUI = fit_biClark_hyst(struct('plotFlag',1,'normFlag',0,'phaseFlag',5),10);
makeAxisStruct(hGUI.gObj.full_stim,sprintf('%s_%s2_stim','biClark','hyst'),'EyeMovements/2017_06_modelFits/hyst')
makeAxisStruct(hGUI.gObj.full_ss,sprintf('%s_%s2','biClark','hyst'),'EyeMovements/2017_06_modelFits/hyst')
%% vanHat
hGUI = fit_vanHat_hyst(struct('plotFlag',1,'normFlag',0),10);
dfh=findobj('tag','df_cfit'); dfh.YData=dfh.YData-2+.12;
dfh=findobj('tag','df_ffit'); dfh.YData=dfh.YData-2+.12;
dfh=findobj('tag','df_ifit'); dfh.YData=dfh.YData-2+.12;
%%
makeAxisStruct(hGUI.gObj.full_stim,sprintf('%s_%s_stim','vanHat','hyst'),'EyeMovements/2017_06_modelFits/hyst')
makeAxisStruct(hGUI.gObj.full_ss,sprintf('%s_%s','vanHat','hyst'),'EyeMovements/2017_06_modelFits/hyst')
makeAxisStruct(hGUI.gObj.dfp,sprintf('%s_%s_df','vanHat','hyst'),'EyeMovements/2017_06_modelFits/hyst')
hGUI.gObj.dfnormButton.Value=1; hGUI.dfNorm();
makeAxisStruct(hGUI.gObj.dfp,sprintf('%s_%s_dfnorm','vanHat','hyst'),'EyeMovements/2017_06_modelFits/hyst')
hGUI = fit_vanHat_hyst(struct('plotFlag',1,'normFlag',0,'phaseFlag',5),10);
makeAxisStruct(hGUI.gObj.full_stim,sprintf('%s_%s2_stim','vanHat','hyst'),'EyeMovements/2017_06_modelFits/hyst')
makeAxisStruct(hGUI.gObj.full_ss,sprintf('%s_%s2','vanHat','hyst'),'EyeMovements/2017_06_modelFits/hyst')
%% biRieke
hGUI = fit_biRieke_hyst(struct('plotFlag',1,'normFlag',0),10);
dfh=findobj('tag','df_cfit'); dfh.YData=dfh.YData-1.5+.015;
dfh=findobj('tag','df_ffit'); dfh.YData=dfh.YData-1.5+.015;
dfh=findobj('tag','df_ifit'); dfh.YData=dfh.YData-1.5+.015;
%%
makeAxisStruct(hGUI.gObj.full_stim,sprintf('%s_%s_stim','biRieke','hyst'),'EyeMovements/2017_06_modelFits/hyst')
makeAxisStruct(hGUI.gObj.full_ss,sprintf('%s_%s','biRieke','hyst'),'EyeMovements/2017_06_modelFits/hyst')
makeAxisStruct(hGUI.gObj.dfp,sprintf('%s_%s_df','biRieke','hyst'),'EyeMovements/2017_06_modelFits/hyst')
hGUI.gObj.dfnormButton.Value=1; hGUI.dfNorm();
makeAxisStruct(hGUI.gObj.dfp,sprintf('%s_%s_dfnorm','biRieke','hyst'),'EyeMovements/2017_06_modelFits/hyst')

hGUI = fit_biRieke_hyst(struct('plotFlag',1,'normFlag',0,'phaseFlag',5),10);
makeAxisStruct(hGUI.gObj.full_stim,sprintf('%s_%s2_stim','biRieke','hyst'),'EyeMovements/2017_06_modelFits/hyst')
makeAxisStruct(hGUI.gObj.full_ss,sprintf('%s_%s2','biRieke','hyst'),'EyeMovements/2017_06_modelFits/hyst')
