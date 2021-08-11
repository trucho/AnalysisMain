%% Code to compare fits and adaptations across stimuli and models

%% Starting with semi-manual extraction of adaptation parameters and amplitude of single-photon response
% target values:
% spra = 0.069 pA
% WeberIo = 
% HillIo = 
% Hilln = 
% Idark = 

% fitPredictions
% isetbioParams, stjParams, akParams, bnParams, sineParams
biRieke.gamma = [1000,238.32,789,200,1500];
biRieke.ih = [80,136,290,162,115];
biRieke.spra = [0.164107, 0.0665566, 0.469504, 0.0665365, 0.353614 ];
biRieke.WeberIo = [3287.31, 14049.1, 4188.71, 16727.5, 2172.52];
biRieke.HillIo = [35921.4, 151365, 45314.8, 45054.5, 23496.2 ];
biRieke.Hilln = [0.9974, 1.02332, 1.00816, 0.798574, 1.03326 ];
biRieke.Idark = [79.40, 134.952, 287.781, 156.163, 113.988 ];

% stjParams, akParams, bnParams, sineParams
vanHat.gamma = [1000,300,892,140,1800];
vanHat.ih = [80,136,290,105,115]; 
vanHat.spra = [0.142576, 0.0727741, 0.46108, 0.026225, 0.368569,];
vanHat.WeberIo = [4198.46, 14018.2, 4705.67, 30075.7, 2332.23,];
vanHat.HillIo = [38785.5, 131995, 43639.1, 268491, 21455.2,];
vanHat.Hilln = [1.07113, 1.06571, 1.07181, 1.13338, 1.1347,];
vanHat.Idark = [79.2874, 134.867, 287.407, 104.068, 113.636,];


% stjParams, akParams, bnParams, sineParams
monoClark.spra = [0.00652336, 0.443069, 0.0235316, 0.117601,];
monoClark.WeberIo = [1111794, 33237, 221590, 70593,];
monoClark.HillIo = [1613987, 4499969, 685419, 127582,]; % this automatic Hill fit is no good for most cells. Needs revisit
monoClark.Hilln = [1.00, 0.226, 1.00, 1.00,];

% stjParams, akParams, bnParams, sineParams
biClark.spra = [0.00689326, 0.418948, 0.0295812, 0.20148,];
biClark.WeberIo = [1052585, 35090, 161046, 37782,];
biClark.HillIo = [1428235, NaN, 297835, NaN,]; % this automatic Hill fit is no good for most cells. Needs revisit
biClark.Hilln = [1.00, 1.00, 1.00, NaN,];



mSize = 10;

f1 = getfigH(1);
xlim([0,0.5]);
ylim([1000,2e6]);
f1.YScale='log';
lH = lineH(biRieke.spra,biRieke.WeberIo,f1);
lH.markers;lH.color([198 026 000]./255); lH.setName('biRieke');
lH.h.MarkerSize=mSize;

lH = lineH(vanHat.spra,vanHat.WeberIo,f1);
lH.markers;lH.color([000 075 245]./255); lH.setName('vanHat');
lH.h.MarkerSize=mSize;


lH = lineH(monoClark.spra,monoClark.WeberIo,f1);
lH.markers;lH.color([077 221 169]./255); lH.setName('monoClark');
lH.h.MarkerSize=mSize;


lH = lineH(biClark.spra,biClark.WeberIo,f1);
lH.markers;lH.color([255 127 000]./255); lH.setName('biClark');
lH.h.MarkerSize=mSize;


lH = lineH([0.069 0.069],[1e3 2e6],f1);
lH.linek; lH.setName('stjSPRA');

lH = lineH([0 0.5],[2250 2250],f1);
lH.linek; lH.setName('Io_AR2013');

lH = lineH([0 0.5],[3330 3330],f1);
lH.linek; lH.setName('Io_Cao2014');

lH.setXLabel('single-photon response amplitude (pA)')
lH.setYLabel('half-desensitizing background (R*/s)')


% 
% biRiekeMap.gamma = [100,150,200,250,300,350,400,450,500,550,600,650,700,750,800,850,900,950,1000];
% biRiekeMap.spra = [0.0279327,0.0418962,0.0558578,0.0698174,0.0837752,0.097731,0.111685,0.125637,0.139587,0.153535,0.167481,0.181426,0.195368,0.209309,0.223247,0.237184,0.251119,0.265052,0.278983]; %idark = 136pA
% biRiekeMap.WeberIo = [33268.5,22256.3,16727.5,13394.5,11162.6,9562.06,8357.68,7418.66,6666.56,6051.12,5538.4,5104.72,4733.15,4411.3,4129.87,3881.74,3661.38,3464.41,3287.31];

load('/Users/angueyraaristjm/matlab/AnalysisMain/ConeAnalysis/ClarkModel/biRiekeMap.mat')
lH = lineH(biRiekeMap.spra,biRiekeMap.WeberIo,f1);
% lH.linemarkers();
lH.color([198 026 000]./255); lH.setName('biRiekeMap');
lH.h.LineWidth=2;

load('/Users/angueyraaristjm/matlab/AnalysisMain/ConeAnalysis/ClarkModel/vanHatMap.mat')
lH = lineH(vanHatMap.spra,vanHatMap.WeberIo,f1);
% lH.linemarkers();
lH.color([000 075 245]./255); lH.setName('vanHatMap');
lH.h.LineWidth=2;

lH = lineH(monoClarkMap_alpha.spra,monoClarkMap_alpha.WeberIo,f1);
% lH.linemarkers();
lH.color([077 221 169]./255); lH.setName('monoClarkMap_alpha');
lH.h.LineWidth=2;
% 
% lH = lineH(monoClarkMap_beta.spra,monoClarkMap_beta.WeberIo,f1);
% % lH.linemarkers();
% lH.color([077 221 169]./255); lH.setName('monoClarkMap_beta');
% lH.h.LineWidth=2;
% 
% lH = lineH(monoClarkMap_alphabeta.spra,monoClarkMap_alphabeta.WeberIo,f1);
% % lH.linemarkers();
% lH.color([077 221 169]./255); lH.setName('monoClarkMap_alphabeta');
% lH.h.LineWidth=2;
% 
% lH = lineH(monoClarkMap_gamma.spra,monoClarkMap_gamma.WeberIo,f1);
% % lH.linemarkers();
% lH.color([077 221 169]./255); lH.setName('monoClarkMap_gamma');
% lH.h.LineWidth=2;
% 
% lH = lineH(monoClarkMap_1alpha2beta.spra,monoClarkMap_1alpha2beta.WeberIo,f1);
% % lH.linemarkers();
% lH.color([077 221 169]./255); lH.setName('monoClarkMap_1alpha2beta');
% lH.h.LineWidth=2;
% 
% lH = lineH(monoClarkMap_1alpha10beta.spra,monoClarkMap_1alpha10beta.WeberIo,f1);
% % lH.linemarkers();
% lH.color([077 221 169]./255); lH.setName('monoClarkMap_1alpha10beta');
% lH.h.LineWidth=2;
% 
% lH = lineH(monoClarkMap_1alpha20beta.spra,monoClarkMap_1alpha20beta.WeberIo,f1);
% % lH.linemarkers();
% lH.color([077 221 169]./255); lH.setName('monoClarkMap_1alpha20beta');
lH.h.LineWidth=2;


%%



%% %% biRieke Map as gamma changes (saved; no need to re-run) % Aug 2021
% % isetbio params
% gammaRange = [1000:50:1000];
% gammaRange = logspace(1,4);
% WeberIo = NaN(size(gammaRange));
% spra = NaN(size(gammaRange));
% for i = 1:length(gammaRange)
%     fprintf('\n\ngamma = %g\n',gammaRange(i))
%     hGUI = fit_biRieke_justIo(struct('ak_subflag',0,'ini',[0500,220,2000,136,0400,gammaRange(i)]),10); % this is from isetbio params (modified to rModel6) but still a discrepancy on holding current of 56 pA that could be artificially corrected. 
%     spra(i) = max(hGUI.df_ifit - mean(hGUI.df_ifit(1:100)));
%     WeberIo(i) = hGUI.gain_iIo;
%     fprintf('spra = %g pA\n',spra(i))
% end
% 
% biRiekeMap.gamma = gammaRange;
% biRiekeMap.spra = spra;
% biRiekeMap.WeberIo = WeberIo;

%% %% vanHat Map as gamma changes (saved; no need to re-run) % Aug 2021
% % isetbio params
% gammaRange = logspace(1,4);
% WeberIo = NaN(size(gammaRange));
% spra = NaN(size(gammaRange));
% for i = 1:length(gammaRange)
%     fprintf('\n\ngamma = %g\n',gammaRange(i))
%     hGUI = fit_vanHat_justIo(struct('ak_subflag',0,'ini',[526,235,2395,136,gammaRange(i)]));
%     spra(i) = max(hGUI.df_ifit - mean(hGUI.df_ifit(1:100)));
%     WeberIo(i) = hGUI.gain_iIo;
%     fprintf('spra = %g pA\n',spra(i))
% end
% 
% vanHatMap.gamma = gammaRange;
% vanHatMap.spra = spra;
% vanHatMap.WeberIo = WeberIo;

%% %% monoClark Map as alpha changes
% % alphaRange = [10:10:100];
% alphaRange = logspace(1,4);
% WeberIo = NaN(size(alphaRange));
% spra = NaN(size(alphaRange));
% for i = 1:length(alphaRange)
%     fprintf('\n\ngamma = %g\n',alphaRange(i))
%     hGUI = fit_monoClarkKyClamped_justIo(struct('ak_subflag',0,'ini',[0166,0100,0448,alphaRange(i),036.0]),10); % this is from isetbio params (modified to rModel6) but still a discrepancy on holding current of 56 pA that could be artificially corrected. 
%     spra(i) = max(hGUI.df_ifit - mean(hGUI.df_ifit(1:100)));
%     WeberIo(i) = hGUI.gain_iIo;
%     fprintf('spra = %g pA\n',spra(i))
% end
% % 
% monoClarkMap_alpha.alpha = alphaRange;
% monoClarkMap_alpha.spra = spra;
% monoClarkMap_alpha.WeberIo = WeberIo;


%% %% monoClark Map as beta changes
% % betaRange =  [10:10:100];
% betaRange = logspace(1,4);
% WeberIo = NaN(size(betaRange));
% spra = NaN(size(betaRange));
% for i = 1:length(betaRange)
%     fprintf('\n\ngamma = %g\n',betaRange(i))
%     hGUI = fit_monoClarkKyClamped_justIo(struct('ak_subflag',0,'ini',[0166,0100,0448,019.4,betaRange(i)]),10); % this is from isetbio params (modified to rModel6) but still a discrepancy on holding current of 56 pA that could be artificially corrected. 
%     spra(i) = max(hGUI.df_ifit - mean(hGUI.df_ifit(1:100)));
%     WeberIo(i) = hGUI.gain_iIo;
%     fprintf('spra = %g pA\n',spra(i))
% end
% % 
% monoClarkMap_beta.beta = betaRange;
% monoClarkMap_beta.spra = spra;
% monoClarkMap_beta.WeberIo = WeberIo;

%% %% monoClark Map as alpha and beta change with the same value
% % alphabetaRange =  [10:10:100];
% alphabetaRange = logspace(1,4);
% WeberIo = NaN(size(alphabetaRange));
% spra = NaN(size(alphabetaRange));
% for i = 1:length(alphabetaRange)
%     fprintf('\n\ngamma = %g\n',alphabetaRange(i))
%     hGUI = fit_monoClarkKyClamped_justIo(struct('ak_subflag',0,'ini',[0166,0100,0448,alphabetaRange(i),alphabetaRange(i)]),10); % this is from isetbio params (modified to rModel6) but still a discrepancy on holding current of 56 pA that could be artificially corrected. 
%     spra(i) = max(hGUI.df_ifit - mean(hGUI.df_ifit(1:100)));
%     WeberIo(i) = hGUI.gain_iIo;
%     fprintf('spra = %g pA\n',spra(i))
% end
% % 
% monoClarkMap_alphabeta.alpha = alphabetaRange;
% monoClarkMap_alphabeta.beta = alphabetaRange;
% monoClarkMap_alphabeta.spra = spra;
% monoClarkMap_alphabeta.WeberIo = WeberIo;

%% %% monoClark Map as alpha and beta change with the beta=10*alpha
% alphabetaRange =  [10:10:100];
alphaRange = logspace(1,4,10);
betaRange = alphaRange * 10;
WeberIo = NaN(size(betaRange));
spra = NaN(size(betaRange));
for i = 1:length(betaRange)
    fprintf('\n\ngamma = %g\n',betaRange(i))
    hGUI = fit_monoClarkKyClamped_justIo(struct('ak_subflag',0,'ini',[0166,0100,0448,alphaRange(i),betaRange(i)]),10); % this is from isetbio params (modified to rModel6) but still a discrepancy on holding current of 56 pA that could be artificially corrected. 
    spra(i) = max(hGUI.df_ifit - mean(hGUI.df_ifit(1:100)));
    WeberIo(i) = hGUI.gain_iIo;
    fprintf('spra = %g pA\n',spra(i))
end
% 
monoClarkMap_1alpha10beta.alpha = alphaRange;
monoClarkMap_1alpha10beta.beta = betaRange;
monoClarkMap_1alpha10beta.spra = spra;
monoClarkMap_1alpha10beta.WeberIo = WeberIo;


%% %% monoClark Map as alpha and beta change with the beta=20*alpha
% alphabetaRange =  [10:10:100];
alphaRange = logspace(1,4,10);
betaRange = alphaRange * 20;
WeberIo = NaN(size(betaRange));
spra = NaN(size(betaRange));
for i = 1:length(betaRange)
    fprintf('\n\ngamma = %g\n',betaRange(i))
    hGUI = fit_monoClarkKyClamped_justIo(struct('ak_subflag',0,'ini',[0166,0100,0448,alphaRange(i),betaRange(i)]),10); % this is from isetbio params (modified to rModel6) but still a discrepancy on holding current of 56 pA that could be artificially corrected. 
    spra(i) = max(hGUI.df_ifit - mean(hGUI.df_ifit(1:100)));
    WeberIo(i) = hGUI.gain_iIo;
    fprintf('spra = %g pA\n',spra(i))
end
% 
monoClarkMap_1alpha20beta.alpha = alphaRange;
monoClarkMap_1alpha20beta.beta = betaRange;
monoClarkMap_1alpha20beta.spra = spra;
monoClarkMap_1alpha20beta.WeberIo = WeberIo;


%% %% monoClark Map as gamma changes
% % gammaRange = [100:200:1000];
% gammaRange = logspace(1,4);
% WeberIo = NaN(size(gammaRange));
% spra = NaN(size(gammaRange));
% for i = 1:length(gammaRange)
%     fprintf('\n\ngamma = %g\n',gammaRange(i))
%     hGUI = fit_monoClarkKyClamped_justIo(struct('ak_subflag',0,'ini',[0166,0100,gammaRange(i),019.4,036.0]),10); % this is from isetbio params (modified to rModel6) but still a discrepancy on holding current of 56 pA that could be artificially corrected. 
%     spra(i) = max(hGUI.df_ifit - mean(hGUI.df_ifit(1:100)));
%     WeberIo(i) = hGUI.gain_iIo;
%     fprintf('spra = %g pA\n',spra(i))
% end
% % 
% monoClarkMap_gamma.gamma = gammaRange;
% monoClarkMap_gamma.spra = spra;
% monoClarkMap_gamma.WeberIo = WeberIo;

% Fit to saccade trajectory stimulus using fast dim-flash response and reincluding feedback
% hGUI = fit_monoClarkKyClamped(struct('ak_subflag',0,'ini',[0166,0100,0448,019.4,036.0]),10); 

%%
%%
%%


%% vanHat
% Fit to adaptation
% hGUI = fit_vanHat(struct('ak_subflag',0,'ini',[526,235,2395,80,1000]),10);
% spra = 0.142576 pA
% WeberIo = 4198.46
% HillIo = 38785.5
% Hilln =1.07113
% Idark = 79.2874

%  Fit to saccade trajectory
% hGUI = fit_vanHat(struct('ak_subflag',0,'ini',[526,235,2395,136,0300]),10);
% spra = 0.0727741 pA
% WeberIo = 14018.2
% HillIo = 131995
% Hilln = 1.06571
% Idark = 134.867

% kGc,sigma,eta,idark,gamma
% 526,235,2395,136,0300
% idark,eta,gamma
% 290,2395,892
% Fit to steps and flashes
% hGUI = fit_vanHat(struct('ak_subflag',0,'ini',[526,235,2395,290,892]),10);
% spra = 0.46108 pA
% WeberIo = 4705.67
% HillIo = 43639.1
% Hilln = 1.07181
% Idark = 287.407


% Fit to binary noise (mid epochs)
% hGUI = fit_vanHat(struct('ak_subflag',0,'ini',[526,235,2395,105,0140]),10);
% spra = 0.026225 pA
% WeberIo = 30075.7
% HillIo = 268491
% Hilln = 1.13338
% Idark = 156.163

% Fit to sines 
hGUI = fit_vanHat(struct('ak_subflag',0,'ini',[526,235,2395,115,1800]),10);
% spra = 0.368569 pA
% WeberIo = 2172.52
% HillIo = 23496.2
% Hilln = 1.03326
% Idark = 113.988


spra = max(hGUI.df_ifit - mean(hGUI.df_ifit(1:100)));
fprintf('spra = %g pA\n',spra)

%% biRieke

% isetbio params
% hGUI = fit_biRieke(struct('ak_subflag',0,'ini',[0500,220,2000,80,0400,01000]),10); % this is from isetbio params (modified to rModel6) but still a discrepancy on holding current of 56 pA that could be artificially corrected. 
% spra = 0.164107 pA
% WeberIo = 3287.31
% HillIo = 35921.4
% Hilln = 0.9974
% Idark = 79.40

%  Fit to saccade trajectory
% hGUI = fit_biRieke(struct('ak_subflag',0,'ini',[0500,220,2000,136,0400,238.32]),10); % isetBio, Fred's Aug 2020 fit
% spra = 0.0665566 pA
% WeberIo = 14049.1
% HillIo = 151365
% Hilln = 1.02332
% Idark = 134.952

% Fit to steps and flashes
% hGUI = fit_biRieke(struct('ak_subflag',0,'ini',[0500,220,2000,290,0400,789]),10);
% spra = 0.469504 pA
% WeberIo = 4188.71
% HillIo = 45314.8
% Hilln = 1.00816
% Idark = 287.781

% Fit to binary noise (first epochs)
% hGUI = fit_biRieke(struct('ak_subflag',0,'ini',[0500,220,2000,162,0400,200]),10);
% spra = 0.0665365 pA
% WeberIo = 16727.5
% HillIo = 45054.5
% Hilln = 0.798574
% Idark = 156.163

% Fit to sines 
% hGUI = fit_biRieke(struct('ak_subflag',0,'ini',[0500,220,2000,115,0400,1500]),10);
% spra = 0.353614 pA
% WeberIo = 2172.52
% HillIo = 23496.2
% Hilln = 1.03326
% Idark = 113.988


spra = max(hGUI.df_ifit - mean(hGUI.df_ifit(1:100)));
fprintf('spra = %g pA\n',spra)
%% monoClark
% Fit to saccade trajectory stimulus using fast dim-flash response and reincluding feedback
% hGUI = fit_monoClarkKyClamped(struct('ak_subflag',0,'ini',[0166,0100,0448,019.4,036.0]),10); 
% spra = 0.00652336 pA
% WeberIo = 1111794
% HillIo = 1613987
% Hilln = 1.00

% Fit to saccade trajectory stimulus using fast dim-flash response and reincluding feedback
hGUI = fit_monoClarkKyClamped(struct('ak_subflag',0,'ini',[0166,0100,0448,0100,100*20]),10); 
% spra = 0.00652336 pA
% WeberIo = 1111794
% HillIo = 1613987
% Hilln = 1.00

% Fit to steps and flashes for 111412Fc02 (latest)
% hGUI = fit_monoClarkKyClamped(struct('ak_subflag',0,'ini',[166,100,745,1320,829]),10); %
% spra = 0.00652336 pA
% WeberIo = 1111794
% HillIo = 1613987
% Hilln = 1.00

q
% Fit to binary noise (mid epochs)
% hGUI = fit_monoClarkKyClamped(struct('ak_subflag',0,'ini',[0166,0100,1370,70,79]),10); 
% spra = 0.0235316 pA
% WeberIo = 221590
% HillIo = 685419
% Hilln = 1.00

% Fit to sines
% hGUI = fit_monoClarkKyClamped(struct('ak_subflag',0,'ini',[0166,0100,600,350,450]),10); 
% spra = 0.00652336 pA
% WeberIo = 70593
% HillIo = 127582
% Hilln = 1.00


spra = max(hGUI.df_ifit - mean(hGUI.df_ifit(1:100)));
fprintf('spra = %g pA\n',spra)
%% biClark
% Fit to saccade trajectory stimulus using fast dim-flash response and reincluding feedback
% hGUI = fit_biClarkKyClamped(struct('ak_subflag',0,'ini',[35,0284,0500,0205,0312,146,184,0232]),10);
% spra = 0.00689326 pA
% WeberIo = 1052585
% HillIo = 1428235
% Hilln = 1.00

% Fit to steps and flashes for 111412Fc02 (latest)
% hGUI = fit_biClarkKyClamped(struct('ak_subflag',0,'ini',[35,0284,896,12480,6510,114,184,0232]),10);
% spra = 0.418948 pA
% WeberIo = 35090
% HillIo = 0000000
% Hilln = 1.00


% Fit to binary noise (mid epochs)
% hGUI = fit_biClarkKyClamped(struct('ak_subflag',0,'ini',[35,0284,721,880,1700,60,184,0232]),10);
% spra = 0.0295812 pA
% WeberIo = 161046
% HillIo = 297835
% Hilln = 1.00

% Fit to sines
hGUI = fit_biClarkKyClamped(struct('ak_subflag',0,'ini',[35,0284,591,6000,8000,100,184,0232]),10);
% spra = 0.20148 pA
% WeberIo = 37782
% HillIo = 000000
% Hilln = 1.00


spra = max(hGUI.df_ifit - mean(hGUI.df_ifit(1:100)));
fprintf('spra = %g pA\n',spra)
