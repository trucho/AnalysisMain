% Script for figure1 of The Senses: Subcortical color vision pathways (2020)
% Created by Juan Angueyra (March 9th, 2020) angueyra@nih.gov

cd ('/Users/angueyraaristjm/matlab/matlab-analysis/trunk/users/juan/AnalysisTools/Calibration');

%%
%%%%%%%%% %%%%%%% %%%%%%% 
wl = [325:725];
L = GeneratePhotoreceptorSpectrum('LCone',wl);
M = GeneratePhotoreceptorSpectrum('MCone',wl);
S = GeneratePhotoreceptorSpectrum('SCone',wl);

midM = [find(M>0.5,1,'first') find(M>0.5,1,'last')];
wl_midM = wl(midM);

thirdM = find(M>1/3,1,'first');
wl_thirdM = wl(thirdM);

topM = find(M == max(M));
wl_topM = wl(topM);

wl_isoML = 549;
M_isoML = M(wl==wl_isoML);
L_isoML = L(wl==wl_isoML);


wl_metaML = [500 630];
M_metaML = [M(wl==wl_metaML(1)) M(wl==wl_metaML(2))];
L_metaML = [L(wl==wl_metaML(1)) L(wl==wl_metaML(2))];

colors.r = [204,44,42]./255;
colors.g = [4, 205, 34]./255;
colors.b = [70, 105, 242]./255;
colors.k = [0,0,0]./255;

%%%%%%% %%%%%%% %%%%%%% %%%%%%% %%%%%%% 
%%%%%%% Spectral sensitivity plots %%%%%%% 
%%%%%%% %%%%%%% %%%%%%% %%%%%%% %%%%%%% 

% Univariance M: intensity
fig1=getfigH(1);
setLabels(fig1,'Wavelength (nm)','Sensitivity');
lH=lineH(wl,M,fig1);
lH.line;lH.color(colors.g);lH.setName('M');lH.h.LineWidth=6;

lH=lineH([wl_topM wl_topM],[0 M(topM)],fig1);
lH.line;lH.color(colors.k);lH.setName('topM');lH.h.LineWidth=4;

lH=lineH([wl_thirdM wl_thirdM],[0 M(thirdM)],fig1);
lH.line;lH.color(colors.k);lH.setName('thirdM1');lH.h.LineWidth=4;
% 
% lH=lineH([wl_thirdM wl_thirdM],[M(thirdM) 2*M(thirdM)],fig1);
% lH.linemarkers;lH.color(colors.k);lH.setName('thirdM1');lH.h.LineWidth=2;
% 
% lH=lineH([wl_thirdM wl_thirdM],[2*M(thirdM) 3*M(thirdM)],fig1);
% lH.line;lH.color(colors.k);lH.setName('thirdM1');lH.h.LineWidth=2;



% Univariance M: wavelength
fig2=getfigH(2);
setLabels(fig2,'Wavelength (nm)','Sensitivity');
lH=lineH(wl,M,fig2);
lH.line;lH.color(colors.g);lH.setName('M');lH.h.LineWidth=6;

lH=lineH([wl_midM(1) wl_midM(1)],[0 M(midM(1))],fig2);
lH.line;lH.color(colors.k);lH.setName('midMlo');lH.h.LineWidth=4;

lH=lineH([wl_midM(2) wl_midM(2)],[0 M(midM(2))],fig2);
lH.line;lH.color(colors.k);lH.setName('midMhi');lH.h.LineWidth=4;

% Univariance disambiguation:
fig3=getfigH(3);
setLabels(fig3,'Wavelength (nm)','Sensitivity');
lH=lineH(wl,L,fig3);
lH.line;lH.color(colors.r);lH.setName('L');lH.h.LineWidth=6;

lH=lineH([wl_midM(1) wl_midM(1)],[0 L(midM(1))],fig3);
lH.line;lH.color(colors.k);lH.setName('midMlo');lH.h.LineWidth=4;

lH=lineH([wl_midM(2) wl_midM(2)],[0 L(midM(2))],fig3);
lH.line;lH.color(colors.k);lH.setName('midMhi');lH.h.LineWidth=4;

% Metamer for M L
fig4=getfigH(4);
setLabels(fig4,'Wavelength (nm)','Sensitivity');
lH=lineH(wl,L,fig4);
lH.line;lH.color(colors.r);lH.setName('L');lH.h.LineWidth=6;
lH=lineH(wl,M,fig4);
lH.line;lH.color(colors.g);lH.setName('M');lH.h.LineWidth=6;
lH=lineH(wl,S,fig4);
lH.line;lH.color(colors.b);lH.setName('S');lH.h.LineWidth=1;

% lH=lineH([wl_isoML wl_isoML]-1,[0 M_isoML],fig4);
lH=lineH([wl_isoML wl_isoML]-1,[0 sum(M_metaML)/M_isoML],fig4);
lH.line;lH.color(colors.k);lH.setName('M_isoML');lH.h.LineWidth=4;

lH=lineH([wl_metaML(1) wl_metaML(1)],[0 M_metaML(1)],fig4);
lH.line;lH.color(colors.g);lH.setName('M_meta1');lH.h.LineWidth=4;
lH=lineH([wl_metaML(2) wl_metaML(2)],[0 M_metaML(2)],fig4);
lH.line;lH.color(colors.g);lH.setName('M_meta2');lH.h.LineWidth=4;

lH=lineH([wl_metaML(1) wl_metaML(1)],[0 L_metaML(1)],fig4);
lH.line;lH.color(colors.r);lH.setName('L_meta1');lH.h.LineWidth=4;
lH=lineH([wl_metaML(2) wl_metaML(2)],[0 L_metaML(2)],fig4);
lH.line;lH.color(colors.r);lH.setName('L_meta2');lH.h.LineWidth=4;

%% 
%%%%%%% %%%%%%% %%%%%%% %%%%%%% %%%%%%% 
%%%%%%% Simulated responses plots %%%%%%% 
%%%%%%% %%%%%%% %%%%%%% %%%%%%% %%%%%%% 

M_flashes = [max(M) M(midM) sum(M_metaML) sum(M_metaML)].*5000;
L_flashes = [max(L) L(midM) sum(L_metaML) sum(L_metaML)].*5000;

flashI = 5000;

% Univariance M: intensity
tAx = 0:1:1600;

s_topM = zeros(size(tAx));
s_topM(200:210) = flashI;

s_thirdM = zeros(size(tAx));
s_thirdM(700:710) = flashI;
s_thirdM(1200:1210) = flashI*3;

fig5=getfigH(5);
setLabels(fig5,'','');
lH=lineH(tAx,s_topM+max(s_thirdM)+1000,fig5);
lH.line;lH.color(colors.k);lH.setName('s_topM');lH.h.LineWidth=4;
lH=lineH(tAx,s_thirdM,fig5);
lH.line;lH.color(colors.k);lH.setName('s_thirdM');lH.h.LineWidth=4;


r_uniM = DoTheConeVolution(s_topM+s_thirdM./3,tAx/1000);

fig9=getfigH(9);
setLabels(fig9,'time (s)','');
lH=lineH(tAx/1000,r_uniM,fig9);
lH.line;lH.color(colors.g);lH.setName('r_uniM');lH.h.LineWidth=4;

%
% Univariance M: wavelength

s_halfM1 = zeros(size(tAx));
s_halfM1(300:310) = flashI;

s_halfM2 = zeros(size(tAx));
s_halfM2(1000:1010) = flashI;

fig6=getfigH(6);
setLabels(fig6,'','');
lH=lineH(tAx,s_halfM1+flashI+1000,fig6);
lH.line;lH.color(colors.k);lH.setName('s_halfM1');lH.h.LineWidth=4;
lH=lineH(tAx,s_halfM2,fig6);
lH.line;lH.color(colors.k);lH.setName('s_halfM2');lH.h.LineWidth=4;


r_MhalfM = DoTheConeVolution(s_halfM1./2+s_halfM2./2,tAx/1000);

fig10=getfigH(10);
setLabels(fig10,'time (s)','');
lH=lineH(tAx/1000,r_MhalfM,fig10);
lH.line;lH.color(colors.g);lH.setName('r_MhalfM');lH.h.LineWidth=4;

%
% Univariance disambiguation:

fig7=getfigH(7);
setLabels(fig7,'','');
lH=lineH(tAx,s_halfM1+flashI+1000,fig7);
lH.line;lH.color(colors.k);lH.setName('s_halfM1');lH.h.LineWidth=4;
lH=lineH(tAx,s_halfM2,fig7);
lH.line;lH.color(colors.k);lH.setName('s_halfM2');lH.h.LineWidth=4;



r_LhalfM = DoTheConeVolution(s_halfM1./L(midM(2))+s_halfM2./L(midM(1)),tAx/1000);

fig11=getfigH(11);
setLabels(fig11,'time (s)','');
lH=lineH(tAx/1000,r_LhalfM,fig11);
lH.line;lH.color(colors.r);lH.setName('r_LhalfM');lH.h.LineWidth=4;

% Metamer for M L

s_metaM1 = zeros(size(tAx));
s_metaM1(1000:1010) = sum(M_metaML)/M_isoML*flashI;

s_metaM2 = zeros(size(tAx));
s_metaM2(300:310) = flashI;


s_metaM3 = zeros(size(tAx));
s_metaM3(300:310) = flashI;


fig8=getfigH(8);
setLabels(fig8,'','');
lH=lineH(tAx,s_metaM1+max(s_metaM1)+1000,fig8);
lH.line;lH.color(colors.k);lH.setName('s_metaM1');lH.h.LineWidth=4;
lH=lineH(tAx,s_metaM2,fig8);
lH.line;lH.color(colors.k);lH.setName('s_metaM2');lH.h.LineWidth=4;
lH=lineH(tAx,s_metaM3-max(s_metaM1)-1000,fig8);
lH.line;lH.color(colors.k);lH.setName('s_metaM3');lH.h.LineWidth=4;


r_metaML = DoTheConeVolution(s_metaM2 + circshift(s_metaM2,700),tAx/1000);

fig12=getfigH(12);
setLabels(fig12,'time (s)','');
lH=lineH(tAx/1000,r_metaML,fig12);
lH.line;lH.color(colors.g);lH.setName('r_Mmeta');lH.h.LineWidth=4;

fig13=getfigH(13);
setLabels(fig13,'time (s)','');
lH=lineH(tAx/1000,r_metaML,fig13);
lH.line;lH.color(colors.r);lH.setName('r_LMeta');lH.h.LineWidth=4;



%%

makeAxisStruct(fig1,'MUni1','LiLab/TheSenses2020')
makeAxisStruct(fig2,'MUni2','LiLab/TheSenses2020')
makeAxisStruct(fig3,'MUni3','LiLab/TheSenses2020')
makeAxisStruct(fig4,'Metamer','LiLab/TheSenses2020')
makeAxisStruct(fig5,'MUni1_stim','LiLab/TheSenses2020')
makeAxisStruct(fig6,'MUni2_stim','LiLab/TheSenses2020')
makeAxisStruct(fig7,'MUni3_stim','LiLab/TheSenses2020')
makeAxisStruct(fig8,'Metamer_stim','LiLab/TheSenses2020')
makeAxisStruct(fig9,'MUni1_r','LiLab/TheSenses2020')
makeAxisStruct(fig10,'MUni2_r','LiLab/TheSenses2020')
makeAxisStruct(fig11,'MUni3_r','LiLab/TheSenses2020')
makeAxisStruct(fig12,'Metamer_rM','LiLab/TheSenses2020')
makeAxisStruct(fig13,'Metamer_rL','LiLab/TheSenses2020')


%%




%%


lH=lineH(wl_isoML,M_isoML,fig1);
lH.markers;lH.color(colors.b);lH.setName('M_isoML');lH.h.MarkerSize=10;
lH=lineH(wl_isoML,L_isoML,fig1);
lH.markers;lH.color(colors.b);lH.setName('L_isoML');lH.h.MarkerSize=10;

lH=lineH(wl_metaML,M_metaML,fig1);
lH.markers;lH.color(colors.b);lH.setName('M_metaML');lH.h.MarkerSize=10;
lH=lineH(wl_metaML,L_metaML,fig1);
lH.markers;lH.color(colors.b);lH.setName('L_metaML');lH.h.MarkerSize=10;

%%




%%
fig1=getfigH(1);
setLabels(fig1,'Wavelength (nm)','Sensitivity');

lH=lineH(wl,M./L,fig1);
lH.line;lH.color(colors.r);lH.setName('L');lH.h.LineWidth=4;

%     'r' : '#747474',
%     'u' : '#B540B7',
%     's' : '#4669F2',
%     'm' : '#04CD22',
%     'l' : '#CC2C2A',
% %     'plt' : '',