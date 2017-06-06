%% Fitting cone models log (Jun 2017, Juan Angueyra)
% trying to put some sense into it and avoid going in loops

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
p = struct;
p.ak_subflag = 1;
% hGUI = fit_biClark(p,10);
% hGUI = fit_vanHat(p,10);
% hGUI = fit_biRieke(p,10);
hGUI = fit_biRieke_hyst(p,10);
