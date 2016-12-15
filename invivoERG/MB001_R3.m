%% MB-001 Aug_2016
% Iseries only
% Analysis instructions:
    % 1) Open jupyter notebook and map csv files to hdf5 in whole folder
    % 2) Identify relevant directory and files
    % 3) Individually screen intensity series data and get averages
    % (erg_screentrials)
    % 4) OPTIONAL: look at a- or b-wave vs. I (cd/m^2)
    % (erg_iseries)
    % 5) Summary plots



%% Round 1
close all; clear; clear classes; clc
% Sq852 MB-001 day3
%%% Screened:
% dirData='20160818/20160818_Sq852/';
% dirFile='20160818_Sq852_01_IsXeMax';
% dirFile='20160818_Sq852_08_IsXeMax_posti';
% dirFile='20160818_Sq852_14_IsXeMax_postii';

% Sq922 MB-001 day 3
%%% Screened:
% dirData='20160818/20160818_Sq922/';
% dirFile='20160818_Sq922_01_iSXeMax';
% dirFile='20160818_Sq922_08_IsXeMax7minpost';
% dirFile='20160818_Sq922_11_IsXeMax6postii';
% dirFile='20160818_Sq922_17_IsXeMaxpostiii';

%% Round 2
close all; clear; clear classes; clc
% I was more consistent this time with bleaching and protocols recorded
% Still working on how best to display these data

% Sq_813 (MB-001)
    % Day 1 (Baseline)
% dirData='20160926/20160926_Sq813/';
% dirFile='20160926_Sq813_01_ISeriesXeMax';
% dirFile='20160926_Sq813_07_ISeriesXeMax_post';
    % Day 3
% dirData='20160929/20160929_Sq813/';
% dirFile='20160929_Sq813_01_Iseries';
% dirFile='20160929_Sq813_08_Iseries_post10min';

% Sq_821 (MB-001)
    % Day 1 (Baseline)
% dirData='20160926/20160926_Sq821/';
% dirFile='20160926_Sq821_01_ISeriesXeMax';
% dirFile='20160926_Sq821_08_ISeriesXeMax_post10min';
    % Day 3
% dirData='20160929/20160929_Sq821/';
% dirFile='20160929_Sq821_01_Iseries_pre';
% dirFile='20160929_Sq821_09_Iseries_post10min';

% Sq_852 (DMSO)
    % Day 1 (Baseline)
% dirData='20160926/20160926_Sq852/';
% dirFile='20160926_Sq852_01_ISeriesXeMax';
% dirFile='20160926_Sq852_08_ISeriesXeMax_post';
    % Day 3
% dirData='20160929/20160929_Sq852/';
% dirFile='20160929_Sq852_01_Iseries';
% dirFile='20160929_Sq852_08_Iseries_post10min';


% Sq_922 (DMSO)
    % Day 1 (Baseline)
% dirData='20160926/20160926_Sq922/';
% dirFile='20160926_Sq922_01_ISeriesXeMax';
% dirFile='20160926_Sq922_07_ISeriesXeMax_post';
    % Day 3
% dirData='20160929/20160929_Sq922/';
% dirFile='20160929_Sq922_01_Iseries_pre';
% dirFile='20160929_Sq922_09_Iseries_post10min';





erg=ERGobj(dirData,dirFile);
hGUI=erg_screentrials(erg,[],10);
set(hGUI.figH,'Position',[-1760 -243 1572 989])

%% then save a and b wave amplitudes
hGUI=erg_iseries(erg,[],10);
%%

%% Gather saved data to plot
close all; clear; clear classes; clc

Sq813=struct;
Sq821=struct;
Sq852=struct;
Sq922=struct;

% Sq_813 (DMSO)
dirData='20160819/20160819_Sq813/';
Sq813.vpre=ERGobj(dirData,'20160819_Sq813_01_IsXeMax');
Sq813.vpost=ERGobj(dirData,'20160819_Sq813_14_IsXeMax_postii_8min');
% Sq_813 (MB-001)
dirData='20160929/20160929_Sq813/';
Sq813.dpre=ERGobj(dirData,'20160929_Sq813_01_Iseries');
Sq813.dpost=ERGobj(dirData,'20160929_Sq813_08_Iseries_post10min');

% Sq_821 (DMSO)
dirData='20160819/20160819_Sq821/';
Sq821.vpre=ERGobj(dirData,'20160819_Sq821_01_IsXeMax');
Sq821.vpost=ERGobj(dirData,'20160819_Sq821_13_IsXeMax_postii_16min');
% Sq_821 (MB-001)
dirData='20160929/20160929_Sq821/';
Sq821.dpre=ERGobj(dirData,'20160929_Sq821_01_Iseries_pre');
Sq821.dpost=ERGobj(dirData,'20160929_Sq821_09_Iseries_post10min');

% Sq_852 (MB-001)
dirData='20160818/20160818_Sq852/';
Sq852.dpre=ERGobj(dirData,'20160818_Sq852_01_IsXeMax');
Sq852.dpost=ERGobj(dirData,'20160818_Sq852_14_IsXeMax_postii');
% Sq_852 (DMSO)
dirData='20160929/20160929_Sq852/';
Sq852.vpre=ERGobj(dirData,'20160929_Sq852_01_Iseries');
Sq852.vpost=ERGobj(dirData,'20160929_Sq852_08_Iseries_post10min');

% Sq_922 (MB-001)
dirData='20160818/20160818_Sq922/';
Sq922.dpre=ERGobj(dirData,'20160818_Sq922_01_iSXeMax');
Sq922.dpost=ERGobj(dirData,'20160818_Sq922_17_IsXeMaxpostiii');
% Sq_922 (DMSO)
dirData='20160929/20160929_Sq922/';
Sq922.vpre=ERGobj(dirData,'20160929_Sq922_01_Iseries_pre');
Sq922.vpost=ERGobj(dirData,'20160929_Sq922_09_Iseries_post10min');
%%
% erg_screentrials(Sq813.vpre,[],10)
% erg_screentrials(Is.vpost,[],10)
% erg_screentrials(Sq922.dpre,[],10)
% erg_screentrials(Sq922.dpost,[],10)
%%
% %% recheck if needed
% hGUI1=erg_iseries(Is.vpre,[],10);
% hGUI2=erg_iseries(Is.vpost,[],10);
% hGUI3=erg_iseries(Is.dpre,[],10);
% hGUI4=erg_iseries(Is.dpost,[],10);
%%
% Bleached eyes:
    %813/822: 
        %vehicle:L
        %drug:R
    %852/922: 
        %vehicle:R
        %drug:L
temp=Sq813.vpre.Iseries_abpeaks();
Sq813.results.vpre.iF=temp.iF;
Sq813.results.vpre.a_peak=temp.La_peak;
Sq813.results.vpre.a_t=temp.La_t;
Sq813.results.vpre.b_peak=temp.Lb_peak;
Sq813.results.vpre.b_t=temp.Lb_t;

temp=Sq813.vpost.Iseries_abpeaks();
Sq813.results.vpost.iF=temp.iF;
Sq813.results.vpost.a_peak=temp.La_peak;
Sq813.results.vpost.a_t=temp.La_t;
Sq813.results.vpost.b_peak=temp.Lb_peak;
Sq813.results.vpost.b_t=temp.Lb_t;

temp=Sq813.dpre.Iseries_abpeaks();
Sq813.results.dpre.iF=temp.iF;
Sq813.results.dpre.a_peak=temp.Ra_peak;
Sq813.results.dpre.a_t=temp.Ra_t;
Sq813.results.dpre.b_peak=temp.Rb_peak;
Sq813.results.dpre.b_t=temp.Rb_t;

temp=Sq813.dpost.Iseries_abpeaks();
Sq813.results.dpost.iF=temp.iF;
Sq813.results.dpost.a_peak=temp.Ra_peak;
Sq813.results.dpost.a_t=temp.Ra_t;
Sq813.results.dpost.b_peak=temp.Rb_peak;
Sq813.results.dpost.b_t=temp.Rb_t;

%Sq 821
temp=Sq821.vpre.Iseries_abpeaks();
Sq821.results.vpre.iF=temp.iF;
Sq821.results.vpre.a_peak=temp.La_peak;
Sq821.results.vpre.a_t=temp.La_t;
Sq821.results.vpre.b_peak=temp.Lb_peak;
Sq821.results.vpre.b_t=temp.Lb_t;

temp=Sq821.vpost.Iseries_abpeaks();
Sq821.results.vpost.iF=temp.iF;
Sq821.results.vpost.a_peak=temp.La_peak;
Sq821.results.vpost.a_t=temp.La_t;
Sq821.results.vpost.b_peak=temp.Lb_peak;
Sq821.results.vpost.b_t=temp.Lb_t;

temp=Sq821.dpre.Iseries_abpeaks();
Sq821.results.dpre.iF=temp.iF;
Sq821.results.dpre.a_peak=temp.Ra_peak;
Sq821.results.dpre.a_t=temp.Ra_t;
Sq821.results.dpre.b_peak=temp.Rb_peak;
Sq821.results.dpre.b_t=temp.Rb_t;

temp=Sq821.dpost.Iseries_abpeaks();
Sq821.results.dpost.iF=temp.iF;
Sq821.results.dpost.a_peak=temp.Ra_peak;
Sq821.results.dpost.a_t=temp.Ra_t;
Sq821.results.dpost.b_peak=temp.Rb_peak;
Sq821.results.dpost.b_t=temp.Rb_t;


% Sq852
temp=Sq852.vpre.Iseries_abpeaks();
Sq852.results.vpre.iF=temp.iF;
Sq852.results.vpre.a_peak=temp.Ra_peak;
Sq852.results.vpre.a_t=temp.Ra_t;
Sq852.results.vpre.b_peak=temp.Rb_peak;
Sq852.results.vpre.b_t=temp.Rb_t;

temp=Sq852.vpost.Iseries_abpeaks();
Sq852.results.vpost.iF=temp.iF;
Sq852.results.vpost.a_peak=temp.Ra_peak;
Sq852.results.vpost.a_t=temp.Ra_t;
Sq852.results.vpost.b_peak=temp.Rb_peak;
Sq852.results.vpost.b_t=temp.Rb_t;

temp=Sq852.dpre.Iseries_abpeaks();
Sq852.results.dpre.iF=temp.iF;
Sq852.results.dpre.a_peak=temp.La_peak;
Sq852.results.dpre.a_t=temp.La_t;
Sq852.results.dpre.b_peak=temp.Lb_peak;
Sq852.results.dpre.b_t=temp.Lb_t;

temp=Sq852.dpost.Iseries_abpeaks();
Sq852.results.dpost.iF=temp.iF;
Sq852.results.dpost.a_peak=temp.La_peak;
Sq852.results.dpost.a_t=temp.La_t;
Sq852.results.dpost.b_peak=temp.Lb_peak;
Sq852.results.dpost.b_t=temp.Lb_t;

%Sq 922
temp=Sq922.vpre.Iseries_abpeaks();
Sq922.results.vpre.iF=temp.iF;
Sq922.results.vpre.a_peak=temp.Ra_peak;
Sq922.results.vpre.a_t=temp.Ra_t;
Sq922.results.vpre.b_peak=temp.Rb_peak;
Sq922.results.vpre.b_t=temp.Rb_t;

temp=Sq922.vpost.Iseries_abpeaks();
Sq922.results.vpost.iF=temp.iF;
Sq922.results.vpost.a_peak=temp.Ra_peak;
Sq922.results.vpost.a_t=temp.Ra_t;
Sq922.results.vpost.b_peak=temp.Rb_peak;
Sq922.results.vpost.b_t=temp.Rb_t;

temp=Sq922.dpre.Iseries_abpeaks();
Sq922.results.dpre.iF=temp.iF;
Sq922.results.dpre.a_peak=temp.La_peak;
Sq922.results.dpre.a_t=temp.La_t;
Sq922.results.dpre.b_peak=temp.Lb_peak;
Sq922.results.dpre.b_t=temp.Lb_t;

temp=Sq922.dpost.Iseries_abpeaks();
Sq922.results.dpost.iF=temp.iF;
Sq922.results.dpost.a_peak=temp.La_peak;
Sq922.results.dpost.a_t=temp.La_t;
Sq922.results.dpost.b_peak=temp.Lb_peak;
Sq922.results.dpost.b_t=temp.Lb_t;


%%
% colors=pmkmp(size(fields(Is),1),'CubicL');
% colors=pmkmp(size(fields(Is),1),'LinLhot');
colors = [[.5 .5 .5];[0 0 0];[1 .5 .5];[1 0 0];];

results = Sq852.results;

f1=getfigH(1);
set(f1,'XScale','log')
setLabels(f1,'I_{Flash} (cd/m^2)','Left a_{peak} (\muV)')

lH=lineH(results.vpre.iF,(-results.vpre.a_peak),f1);
lH.color(colors(1,:));
set(lH.h,'DisplayName','vpre')
lH=lineH(results.vpost.iF,(-results.vpost.a_peak),f1);
lH.color(colors(2,:));
set(lH.h,'DisplayName','vpost')
lH=lineH(results.dpre.iF,(-results.dpre.a_peak),f1);
lH.color(colors(3,:));
set(lH.h,'DisplayName','dpre')
lH=lineH(results.dpost.iF,(-results.dpost.a_peak),f1);
lH.color(colors(4,:));
set(lH.h,'DisplayName','dpost')

%
f2=getfigH(2);
set(f2,'XScale','log')
setLabels(f2,'I_{Flash} (cd/m^2)','Left b_{peak} (\muV)')

lH=lineH(results.vpre.iF,(results.vpre.b_peak),f2);
lH.color(colors(1,:));
set(lH.h,'DisplayName','vpre')
lH=lineH(results.vpost.iF,(results.vpost.b_peak),f2);
lH.color(colors(2,:));
set(lH.h,'DisplayName','vpost')
lH=lineH(results.dpre.iF,(results.dpre.b_peak),f2);
lH.color(colors(3,:));
set(lH.h,'DisplayName','dpre')
lH=lineH(results.dpost.iF,(results.dpost.b_peak),f2);
lH.color(colors(4,:));
set(lH.h,'DisplayName','dpost')

%% Exploring ratios pre/post
ratios=struct;

f5=getfigH(5);
set(f5,'XScale','log')
setLabels(f5,'I_{Flash} (cd/m^2)','Ratio pre/post a_{peak} (\muV)')
lH = lineH(Sq821.results.vpre.iF,ones(size(Sq821.results.vpre.iF)),f5);
lH.linedash;


lH=lineH(Sq813.results.vpost.iF,(Sq813.results.vpre.Rb_peak([1:8,10:13])./Sq813.results.vpost.Rb_peak),f5);
lH.color(colors(2,:));
set(lH.h,'DisplayName','R_veh')
lH=lineH(Sq813.results.dpre.iF,(Sq813.results.dpre.Rb_peak./Sq813.results.dpost.Rb_peak),f5);
lH.color(colors(4,:));
set(lH.h,'DisplayName','R_drug')

lH=lineH(Sq821.results.vpre.iF,(Sq821.results.vpre.Rb_peak./Sq821.results.vpost.Rb_peak),f5);
lH.color(colors(2,:));
set(lH.h,'DisplayName','R_veh')
lH=lineH(Sq821.results.vpre.iF,(Sq821.results.dpre.Rb_peak./Sq821.results.dpost.Rb_peak),f5);
lH.color(colors(4,:));
set(lH.h,'DisplayName','R_drug')

lH=lineH(Sq852.results.vpre.iF,(Sq852.results.vpre.Rb_peak./Sq852.results.vpost.Rb_peak),f5);
lH.color(colors(2,:));
set(lH.h,'DisplayName','R_veh')
lH=lineH(Sq852.results.dpost.iF,(Sq852.results.dpre.Rb_peak([2:9,12:13])./Sq852.results.dpost.Rb_peak),f5);
lH.color(colors(4,:));
set(lH.h,'DisplayName','R_drug')

lH=lineH(Sq922.results.vpre.iF,(Sq922.results.vpre.Rb_peak./Sq922.results.vpost.Rb_peak),f5);
lH.color(colors(2,:));
set(lH.h,'DisplayName','R_veh')
lH=lineH(Sq922.results.dpost.iF,(Sq922.results.dpre.Rb_peak(2:13)./Sq922.results.dpost.Rb_peak),f5);
lH.color(colors(4,:));
set(lH.h,'DisplayName','R_drug')


%% Export to Igor for collaboration
% Panel plans: 
% IS averages pre and post just bleached eye 
% iF vs a- and b-waves L and R
% ratios?
makeAxisStruct(f1,'aMB001_L',sprintf('erg/squirrel/invivo/Sq922'));
makeAxisStruct(f2,'aMB001_R',sprintf('erg/squirrel/invivo/Sq922'));
makeAxisStruct(f2,'bMB001_L',sprintf('erg/squirrel/invivo/Sq922'));
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

