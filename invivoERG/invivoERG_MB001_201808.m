%% MB-001 Aug_2016
% screen trials for all data first
close all; clear; clear classes; clc

% Sq852 MB-001 day3
% dirData='20160818/20160818_Sq852/';
% dirFile='20160818_Sq852_01_IsXeMax';
% dirFile='20160818_Sq852_02_Steps2sG';
% dirFile='20160818_Sq852_03_sine';
% dirFile='20160818_Sq852_04_Flashes_pre';
% dirFile='20160818_Sq852_05_Flashes_posti_0min';
% dirFile='20160818_Sq852_06_Flashes_posti_3o6min';
% dirFile='20160818_Sq852_07_Flashes_posti_7min';
% dirFile='20160818_Sq852_08_IsXeMax_posti';
% dirFile='20160818_Sq852_09_Steps2sG_posti';
% dirFile='20160818_Sq852_10_Flashes_preii';
% dirFile='20160818_Sq852_11_Flashes_postii_0min';
% dirFile='20160818_Sq852_12_Flashes_postii_3min';
% dirFile='20160818_Sq852_13_Flashes_postii_6min';
% dirFile='20160818_Sq852_14_IsXeMax_postii';
% dirFile='20160818_Sq852_15_Flashes_postii_15min';
% dirFile='20160818_Sq852_16_Steps2sG_postii';

% Sq922 MB-001 day 3
dirData='20160818/20160818_Sq922/';
% dirFile='20160818_Sq922_01_iSXeMax';
% dirFile='20160818_Sq922_02_Steps2sG';
% dirFile='20160818_Sq922_03_sine';
% dirFile='20160818_Sq922_04_FlashesPre';
% dirFile='20160818_Sq922_05_FlashesPosti_0min';
% dirFile='20160818_Sq922_06_FlashesPosti_3min';
% dirFile='20160818_Sq922_07_FlashesPosti_6min';
% dirFile='20160818_Sq922_08_IsXeMax7minpost';
% dirFile='20160818_Sq922_09_FlashesPostii_0min';
% dirFile='20160818_Sq922_10_FlashesPostii_4min';
% dirFile='20160818_Sq922_11_IsXeMax6postii';
% dirFile='20160818_Sq922_12_FlashesPostiii_0min';
% dirFile='20160818_Sq922_13_FlashesPostiii_2o5min';
% dirFile='20160818_Sq922_14_FlashesPostiii_5min';
% dirFile='20160818_Sq922_15_FlashesPostiii_8min';
% dirFile='20160818_Sq922_16_Steps2sGpostiii';
% dirFile='20160818_Sq922_17_IsXeMaxpostiii';


erg=ERGobj(dirData,dirFile);
erg_screentrials(erg,[],10)
%% Sq852 MB-001 day3: Intensity series
close all; clear; clear classes; clc
dirData='20160818/20160818_Sq852/';
Is=struct;
Is.pre=ERGobj(dirData,'20160818_Sq852_01_IsXeMax');
Is.posti=ERGobj(dirData,'20160818_Sq852_08_IsXeMax_posti');
Is.postii=ERGobj(dirData,'20160818_Sq852_14_IsXeMax_postii');
% %%
% hGUI1=erg_iseries(Is.pre,[],10);
% hGUI2=erg_iseries(Is.posti,[],11);
% hGUI3=erg_iseries(Is.postii,[],12);
% %%
results.pre=Is.pre.Iseries_abpeaks();
results.posti=Is.posti.Iseries_abpeaks();
results.postii=Is.postii.Iseries_abpeaks();
colors=pmkmp(3,'CubicL');

f1=getfigH(1);
set(f1,'XScale','log')

setLabels(f1,'I_{Flash} (cd/m^2)','TRP (\muV)')
lH=lineH(results.pre.iF,(-results.pre.La_peak),f1);
lH.color(colors(1,:));
set(lH.h,'DisplayName','L_pre')
lH=lineH(results.posti.iF,(-results.posti.La_peak),f1);
lH.color(colors(2,:));
set(lH.h,'DisplayName','L_posti')
lH=lineH(results.postii.iF,(-results.postii.La_peak),f1);
lH.color(colors(3,:));
set(lH.h,'DisplayName','L_postii')

lH=lineH(results.pre.iF,(-results.pre.Ra_peak),f1);
lH.color(colors(1,:)); lH.marker('^');
set(lH.h,'DisplayName','R_pre')
lH=lineH(results.posti.iF,(-results.posti.Ra_peak),f1);
lH.color(colors(2,:)); lH.marker('^');
set(lH.h,'DisplayName','R_posti')
lH=lineH(results.postii.iF,(-results.postii.Ra_peak),f1);
lH.color(colors(3,:)); lH.marker('^');
set(lH.h,'DisplayName','R_postii')

%
f2=getfigH(2);
set(f2,'XScale','log')
setLabels(f2,'I_{Flash} (cd/m^2)','TRP (\muV)')

lH=lineH(results.pre.iF,(results.pre.Lb_peak),f2);
lH.color(colors(1,:));
set(lH.h,'DisplayName','Is_pre')
lH=lineH(results.posti.iF,(results.posti.Lb_peak),f2);
lH.color(colors(2,:));
set(lH.h,'DisplayName','Is_posti')
lH=lineH(results.postii.iF,(results.postii.Lb_peak),f2);
lH.color(colors(3,:));
set(lH.h,'DisplayName','Is_postii')

lH=lineH(results.pre.iF,(results.pre.Rb_peak),f2);
lH.color(colors(1,:)); lH.marker('^');
set(lH.h,'DisplayName','R_pre')
lH=lineH(results.posti.iF,(results.posti.Rb_peak),f2);
lH.color(colors(2,:)); lH.marker('^');
set(lH.h,'DisplayName','R_posti')
lH=lineH(results.postii.iF,(results.postii.Rb_peak),f2);
lH.color(colors(3,:)); lH.marker('^');
set(lH.h,'DisplayName','R_postii')
%% Sq922 MB-001 day3: Intensity series
close all; clear; clear classes; clc
dirData='20160818/20160818_Sq922/';
Is=struct;
Is.pre=ERGobj(dirData,'20160818_Sq922_01_iSXeMax');
Is.posti=ERGobj(dirData,'20160818_Sq922_08_IsXeMax7minpost');
Is.postii=ERGobj(dirData,'20160818_Sq922_11_IsXeMax6postii');
Is.postiii=ERGobj(dirData,'20160818_Sq922_17_IsXeMaxpostiii');
% %%
% hGUI1=erg_iseries(Is.pre,[],10);
% hGUI2=erg_iseries(Is.posti,[],10);
% hGUI3=erg_iseries(Is.postii,[],10);
% hGUI4=erg_iseries(Is.postii,[],10);
%%
results.pre=Is.pre.Iseries_abpeaks();
results.posti=Is.posti.Iseries_abpeaks();
results.postii=Is.postii.Iseries_abpeaks();
results.postiii=Is.postiii.Iseries_abpeaks();
colors=pmkmp(4,'CubicL');
colors=pmkmp(4,'LinLhot');


f1=getfigH(1);
set(f1,'XScale','log')
setLabels(f1,'I_{Flash} (cd/m^2)','Left a_{peak} (\muV)')

lH=lineH(results.pre.iF,(-results.pre.La_peak),f1);
lH.color(colors(1,:));
set(lH.h,'DisplayName','L_pre')
lH=lineH(results.posti.iF,(-results.posti.La_peak),f1);
lH.color(colors(2,:));
set(lH.h,'DisplayName','L_posti')
lH=lineH(results.postii.iF,(-results.postii.La_peak),f1);
lH.color(colors(3,:));
set(lH.h,'DisplayName','L_postii')
lH=lineH(results.postiii.iF,(-results.postiii.La_peak),f1);
lH.color(colors(4,:));
set(lH.h,'DisplayName','L_postiii')

f2=getfigH(2);
set(f2,'XScale','log')
setLabels(f2,'I_{Flash} (cd/m^2)','Right a_{peak} (\muV)')

lH=lineH(results.pre.iF,(-results.pre.Ra_peak),f2);
lH.color(colors(1,:));
set(lH.h,'DisplayName','R_pre')
lH=lineH(results.posti.iF,(-results.posti.Ra_peak),f2);
lH.color(colors(2,:));
set(lH.h,'DisplayName','R_posti')
lH=lineH(results.postii.iF,(-results.postii.Ra_peak),f2);
lH.color(colors(3,:));
set(lH.h,'DisplayName','R_postii')
lH=lineH(results.postiii.iF,(-results.postiii.Ra_peak),f2);
lH.color(colors(4,:));
set(lH.h,'DisplayName','R_postiii')
%
f3=getfigH(3);
set(f3,'XScale','log')
setLabels(f3,'I_{Flash} (cd/m^2)','Left b_{peak} (\muV)')

lH=lineH(results.pre.iF,(results.pre.Lb_peak),f3);
lH.color(colors(1,:));
set(lH.h,'DisplayName','L_pre')
lH=lineH(results.posti.iF,(results.posti.Lb_peak),f3);
lH.color(colors(2,:));
set(lH.h,'DisplayName','L_posti')
lH=lineH(results.postii.iF,(results.postii.Lb_peak),f3);
lH.color(colors(3,:));
set(lH.h,'DisplayName','L_postii')
lH=lineH(results.postiii.iF,(results.postiii.Lb_peak),f3);
lH.color(colors(4,:));
set(lH.h,'DisplayName','L_postiii')

f4=getfigH(4);
set(f4,'XScale','log')
setLabels(f4,'I_{Flash} (cd/m^2)','Right b_{peak} (\muV)')

lH=lineH(results.pre.iF,(results.pre.Rb_peak),f4);
lH.color(colors(1,:));
set(lH.h,'DisplayName','R_pre')
lH=lineH(results.posti.iF,(results.posti.Rb_peak),f4);
lH.color(colors(2,:));
set(lH.h,'DisplayName','R_posti')
lH=lineH(results.postii.iF,(results.postii.Rb_peak),f4);
lH.color(colors(3,:));
set(lH.h,'DisplayName','R_postii')
lH=lineH(results.postiii.iF,(results.postiii.Rb_peak),f4);
lH.color(colors(4,:));
set(lH.h,'DisplayName','R_postiii')
%% Export to Igor for collaboration
% Panel plans: 
% IS averages pre and post L and R 
% iF vs a- and b-waves L and R
makeAxisStruct(f1,'aMB001_L',sprintf('erg/squirrel/invivo/Sq922'));
makeAxisStruct(f2,'aMB001_R',sprintf('erg/squirrel/invivo/Sq922'));
makeAxisStruct(f3,'bMB001_L',sprintf('erg/squirrel/invivo/Sq922'));
makeAxisStruct(f4,'bMB001_R',sprintf('erg/squirrel/invivo/Sq922'));

%%
hGUI=erg_iseries(Is.pre,[],10);
drawnow
makeAxisStruct(hGUI.figData.plotL2,'IsMB001pre_L',sprintf('erg/squirrel/invivo/Sq922'));
makeAxisStruct(hGUI.figData.plotR2,'IsMB001pre_R',sprintf('erg/squirrel/invivo/Sq922'));
%%
hGUI=erg_iseries(Is.postiii,[],10);
drawnow
makeAxisStruct(hGUI.figData.plotL2,'IsMB001postiii_L',sprintf('erg/squirrel/invivo/Sq922'));
makeAxisStruct(hGUI.figData.plotR2,'IsMB001postiii_R',sprintf('erg/squirrel/invivo/Sq922'));

