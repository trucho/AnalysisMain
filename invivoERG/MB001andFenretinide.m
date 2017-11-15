%% MB-001 Aug_2017
% Iseries only
% Analysis instructions:
    % 0) Give csv extension to ERG files (using bash):
    %       "for d in *; do for i in $d/*; do mv "$i" "$i.csv"; done; done
    % 1) Open jupyter notebook and map csv files to hdf5 in whole folder
    % 2) Identify relevant directory and files
    % 2.5) OPTIONAL: create h5 files by merging data from two h5 files from same protocol
    % (ERGmerge('test',{'01_IseriesPre';'02_IseriesPre'});
    % 3) Individually screen intensity series data and get averages
    % (erg_screentrials)
    % 4) OPTIONAL: look at a- or b-wave vs. I (cd/m^2)
    % (erg_iseries)
    % 5) Summary plots

%% File merging for Iseries that was run more that once
mergeDir = '20170829/20170829_Sq993_MB001Low';
mergeFiles = {'11_IseriesPost10min_CrashedAfter10steps';'12_IseriesPost10min_Repeat9to13'};
ERGmerge(mergeDir,mergeFiles);

%% MB-001 Low Dose (8 mg/kg)
% Sq 993
% % Day 1 (baseline)
% dirData = '20170829/20170829_Sq993_MB001Low';
% dirFile = '01_IseriesPre';
% dirFile = '11_IseriesPost10min_merged';
% 
% % Day 3
% dirData = '20170831/20170831_Sq993_MB001Low';
% dirFile = '01_IseriesPre';
% dirFile = '14_IseriesPost10min';

% Sq 998
% % Day 1 (baseline)
% dirData = '20170830/20170830_Sq998_MB001Low';
% dirFile = '01_IseriesPre';
% dirFile = '12_IseriesPost';

% Day 3
% dirData = '20170901/20170901_Squirrel998_MB001Low';
% dirFile = '01_IseriesPre';
% dirFile = '10_IseriesPost10min';

erg=ERGobj(dirData,dirFile);

%% MB-001 High Dose (80 mg/kg)
close all; clear; clear classes; clc

% Sq 1006
% Day 1 (baseline)
% dirData = '20170829/20170829_Sq1006_MB001High';
% dirFile = '01_IseriesPre_merged';
% dirFile = '11_IseriesPost10min';

% Day 3
% dirData = '20170831/20170831_Sq1006_MB001High';
% dirFile = '01_IseriesPre';
% dirFile = '13_IseriesPost10min_merged';


% Sq 928 (died during ERG day 3)
% Day 1 (baseline)
% dirData = '20170830/20170830_Sq928_MB001High';
% dirFile = '01_IseriesPre';
% dirFile = '12_IseriesPost10min';
% 
% % Day 3
% dirData = '20170901/20170901_Squirrel928_MB001High';
% dirFile = '01_IseriesPre';
% dirFile = '';


% Sq 1057 (died before ERG day 3)
% Day 1 (baseline)
% dirData = '20171023/20171023_Sq1057_MB001High';
% dirFile = '01_IseriesPre';
% dirFile = '10_IseriesPost10min';
% 
% % Day 3
% dirData = '';
% dirFile = '';
% dirFile = '';

% Sq 1040 (died after day 4)
% Day 1 (baseline)
% dirData = '20171023/20171023_Sq1040_MB001High';
% dirFile = '01_IseriesPre';
% dirFile = '10_IseriesPost10min';
% 
% % Day 3
% dirData = '20171025/20171025_Sq1040_MB001High';
% dirFile = '01_IseriesPre';
% dirFile = '10_IseriesPost10min';

erg=ERGobj(dirData,dirFile);

%% Vehicle
% Sq 1000
% Day 1 (baseline)
% dirData = '20170829/20170829_Sq1000_Veh';
% dirFile = '01_IseriesPre';
% dirFile = '10_IseriesPost10min';

% Day 3
% dirData = '20170831/20170831_Sq1000_Vehicle';
% dirFile = '01_IseriesPre';
% dirFile = '13_IseriesPost10min';

% Sq 992
% Day 1 (baseline)
% dirData = '20170830/20170830_Sq992_Veh';
% dirFile = '01_IseriesPre';
% dirFile = '12_IseriesPost10min';
% 
% % Day 3
% dirData = '20170901/20170901_Squirrel992_Vehicle';
% dirFile = '01_IseriesPre';
% dirFile = '10_IseriesPost10min';

% Sq 999
% Day 1 (baseline)
% dirData = '20170905/20170905_Sq999_Vehicle';
% dirFile = '01_IseriesPre';
% dirFile = '10_IseriesPost10min20s';
% 
% % Day 3
dirData = '20170907/20170907_Sq999_Vehicle';
dirFile = '01_IseriesPre';
dirFile = '10_IseriesPost10min';

erg=ERGobj(dirData,dirFile);

%% Fenretinide

% Sq 990
% Day 1 (baseline)
% dirData = '20170905/20170905_Sq990_Fenretinide';
% dirFile = '01_IseriesPre';
% dirFile = '10_IseriesPost10min';
% 
% % Day 3
% dirData = '20170907/20170907_Sq990_Fenretinide';
% dirFile = '01_IseriesPre';
% dirFile = '10_IseriesPost10min';

% Sq 995
% Day 1 (baseline)
% dirData = '20170905/20170905_Sq995_Fenretinide';
% dirFile = '01_IseriesPre';
% dirFile = '10_IseriesPost10min';
% 
% % Day 3
% dirData = '20170907/20170907_Sq995_Fenretinide';
% dirFile = '01_IseriesPre';
% dirFile = '10_IseriesPost10min';

% Sq 1090
% Day 1 (baseline)
% dirData = '20171023/20171023_Sq1090_Fenretinide';
% dirFile = '01_IseriesPre';
% dirFile = '10_IseriesPost10min';
% 
% % Day 3
dirData = '20171025/20171025_Sq1090_Fenretinide';
% dirFile = '01_IseriesPre';
dirFile = '10_IseriesPost10min';
erg=ERGobj(dirData,dirFile);

%% first screen trials
hGUI=erg_screentrials(erg,[],10);
% set(hGUI.figH,'Position',[-1760 -43 1572 989])
% set(hGUI.figH,'Position',[0 100 900 989])
set(hGUI.figH,'Position',[200 5 1169 800]) %1 screen

%% then save a and b wave amplitudes
hGUI=erg_iseries(erg,[],10);
% set(hGUI.figH,'Position',[-1760 -43 1572 989])
set(hGUI.figH,'Position',[200 5 1169 800]) %1 screen
%%

%% Gather saved data to plot
close all; clear; clear classes; clc
Is=struct;

% % Vehicle
% Sq='Sq1000';
% Sq='Sq992';
% Sq='Sq999';

% % MB-001 Low (8 mg/kg)
% Sq='Sq993';
Sq='Sq998';

% % MB-001 High (80 mg/kg)
Sq='Sq1006'; % euthanized for RPE collection
% Sq='Sq928'; % dead during day 3
% Sq='Sq1057'; % dead before day 3
Sq='Sq1040'; % dead during day 4

%Fenretinide
% Sq='Sq990';
% Sq='Sq995';
% Sq='Sq1090';

colors=pmkmp(size(fields(Is),1),'CubicL');
colors=pmkmp(size(fields(Is),1),'LinLhot');
colors = [.5 .5 .5; 0 0 0; 1 0.5 0.5; 1 0 0];

switch Sq
    % Vehicle
    case 'Sq1000'
        dirData = '20170829/20170829_Sq1000_Veh';
        Is.d1pre=ERGobj(dirData,'01_IseriesPre');
        Is.d1post=ERGobj(dirData,'10_IseriesPost10min');
        dirData='20170831/20170831_Sq1000_Vehicle';
        Is.d3pre=ERGobj(dirData,'01_IseriesPre');
        Is.d3post=ERGobj(dirData,'13_IseriesPost10min');
    case 'Sq992'
        dirData = '20170830/20170830_Sq992_Veh';
        Is.d1pre=ERGobj(dirData,'01_IseriesPre');
        Is.d1post=ERGobj(dirData,'12_IseriesPost10min');
        dirData='20170901/20170901_Squirrel992_Vehicle';
        Is.d3pre=ERGobj(dirData,'01_IseriesPre');
        Is.d3post=ERGobj(dirData,'10_IseriesPost10min');
    case 'Sq999'
        dirData = '20170905/20170905_Sq999_Vehicle';
        Is.d1pre=ERGobj(dirData,'01_IseriesPre');
        Is.d1post=ERGobj(dirData,'10_IseriesPost10min20s');
        dirData='20170907/20170907_Sq999_Vehicle';
        Is.d3pre=ERGobj(dirData,'01_IseriesPre');
        Is.d3post=ERGobj(dirData,'10_IseriesPost10min');
    % MB-001 Low
    case 'Sq993'
        dirData='20170829/20170829_Sq993_MB001Low';
        Is.d1pre=ERGobj(dirData,'01_IseriesPre');
        Is.d1post=ERGobj(dirData,'11_IseriesPost10min_merged');
        dirData='20170831/20170831_Sq993_MB001Low';
        Is.d3pre=ERGobj(dirData,'01_IseriesPre');
        Is.d3post=ERGobj(dirData,'14_IseriesPost10min');
    case 'Sq998'
        dirData='20170830/20170830_Sq998_MB001Low';
        Is.d1pre=ERGobj(dirData,'01_IseriesPre');
        Is.d1post=ERGobj(dirData,'12_IseriesPost');
        dirData='20170901/20170901_Squirrel998_MB001Low';
        Is.d3pre=ERGobj(dirData,'01_IseriesPre');
        Is.d3post=ERGobj(dirData,'10_IseriesPost10min');
    %MB-001 High
    case 'Sq1006'
        dirData='20170829/20170829_Sq1006_MB001High';
        Is.d1pre=ERGobj(dirData,'01_IseriesPre_merged');
        Is.d1post=ERGobj(dirData,'11_IseriesPost10min');
        dirData='20170831/20170831_Sq1006_MB001High';
        Is.d3pre=ERGobj(dirData,'01_IseriesPre');
        Is.d3post=ERGobj(dirData,'13_IseriesPost10min_merged');
    case 'Sq928'
        dirData='20170830/20170830_Sq928_MB001High';
        Is.d1pre=ERGobj(dirData,'01_IseriesPre');
        Is.d1post=ERGobj(dirData,'12_IseriesPost10min');
        dirData='20170901/20170901_Squirrel928_MB001High';
        Is.d3pre=ERGobj(dirData,'01_IseriesPre');
        Is.d3post=ERGobj(dirData,'01_IseriesPre');
    case 'Sq1057'
        dirData='20171023/20171023_Sq1057_MB001High';
        Is.d1pre=ERGobj(dirData,'01_IseriesPre');
        Is.d1post=ERGobj(dirData,'10_IseriesPost10min');
        dirData='';
        Is.d3pre=ERGobj(dirData,'');
        Is.d3post=ERGobj(dirData,'');
    case 'Sq1040'
        dirData='20171023/20171023_Sq1040_MB001High';
        Is.d1pre=ERGobj(dirData,'01_IseriesPre');
        Is.d1post=ERGobj(dirData,'10_IseriesPost10min');
        dirData='20171025/20171025_Sq1040_MB001High';
        Is.d3pre=ERGobj(dirData,'01_IseriesPre');
        Is.d3post=ERGobj(dirData,'10_IseriesPost10min');
    % Fenretinide
    case 'Sq990'
        dirData = '20170905/20170905_Sq990_Fenretinide';
        Is.d1pre=ERGobj(dirData,'01_IseriesPre');
        Is.d1post=ERGobj(dirData,'10_IseriesPost10min');
        dirData='20170907/20170907_Sq990_Fenretinide';
        Is.d3pre=ERGobj(dirData,'01_IseriesPre');
        Is.d3post=ERGobj(dirData,'10_IseriesPost10min');
    case 'Sq995'
        dirData = '20170905/20170905_Sq995_Fenretinide';
        Is.d1pre=ERGobj(dirData,'01_IseriesPre');
        Is.d1post=ERGobj(dirData,'10_IseriesPost10min');
        dirData='20170907/20170907_Sq995_Fenretinide';
        Is.d3pre=ERGobj(dirData,'01_IseriesPre');
        Is.d3post=ERGobj(dirData,'10_IseriesPost10min');
    case 'Sq1090'
        dirData = '20171023/20171023_Sq1090_Fenretinide';
        Is.d1pre=ERGobj(dirData,'01_IseriesPre');
        Is.d1post=ERGobj(dirData,'10_IseriesPost10min');
        dirData='20171025/20171025_Sq1090_Fenretinide';
        Is.d3pre=ERGobj(dirData,'01_IseriesPre');
        Is.d3post=ERGobj(dirData,'10_IseriesPost10min');
end


% %%
% % %% recheck if needed
% % % hGUI1=erg_iseries(Is.d1pre,[],10);
% % % hGUI2=erg_iseries(Is.d1post,[],10);
% % % hGUI3=erg_iseries(Is.d3pre,[],10);
% % % hGUI4=erg_iseries(Is.d3post,[],10);
% %%
results.d1pre=Is.d1pre.Iseries_abpeaks();
results.d1post=Is.d1post.Iseries_abpeaks();
results.d3pre=Is.d3pre.Iseries_abpeaks();
results.d3post=Is.d3post.Iseries_abpeaks();

f1=getfigH(1);
set(f1,'XScale','log')
setLabels(f1,'I_{Flash} (cd/m^2)','Left a_{peak} (\muV)')

lH=lineH(results.d1pre.iF,(-results.d1pre.La_peak),f1);
lH.color(colors(1,:));
set(lH.h,'DisplayName','L_d1pre')
lH=lineH(results.d1post.iF,(-results.d1post.La_peak),f1);
lH.color(colors(2,:));
set(lH.h,'DisplayName','L_d1post')
lH=lineH(results.d3pre.iF,(-results.d3pre.La_peak),f1);
lH.color(colors(3,:));
set(lH.h,'DisplayName','L_d3pre')
lH=lineH(results.d3post.iF,(-results.d3post.La_peak),f1);
lH.color(colors(4,:));
set(lH.h,'DisplayName','L_d3post')

f2=getfigH(2);
set(f2,'XScale','log')
setLabels(f2,'I_{Flash} (cd/m^2)','Right a_{peak} (\muV)')

lH=lineH(results.d1pre.iF,(-results.d1pre.Ra_peak),f2);
lH.color(colors(1,:));
set(lH.h,'DisplayName','R_d1pre')
lH=lineH(results.d1post.iF,(-results.d1post.Ra_peak),f2);
lH.color(colors(2,:));
set(lH.h,'DisplayName','R_d1post')
lH=lineH(results.d3pre.iF,(-results.d3pre.Ra_peak),f2);
lH.color(colors(3,:));
set(lH.h,'DisplayName','R_d3pre')
lH=lineH(results.d3post.iF,(-results.d3post.Ra_peak),f2);
lH.color(colors(4,:));
set(lH.h,'DisplayName','R_d3post')
%
f3=getfigH(3);
set(f3,'XScale','log')
setLabels(f3,'I_{Flash} (cd/m^2)','Left b_{peak} (\muV)')

lH=lineH(results.d1pre.iF,(results.d1pre.Lab_peak),f3);
lH.color(colors(1,:));
set(lH.h,'DisplayName','L_d1pre')
lH=lineH(results.d1post.iF,(results.d1post.Lab_peak),f3);
lH.color(colors(2,:));
set(lH.h,'DisplayName','L_d1post')
lH=lineH(results.d3pre.iF,(results.d3pre.Lab_peak),f3);
lH.color(colors(3,:));
set(lH.h,'DisplayName','L_d3pre')
lH=lineH(results.d3post.iF,(results.d3post.Lab_peak),f3);
lH.color(colors(4,:));
set(lH.h,'DisplayName','L_d3post')

f4=getfigH(4);
set(f4,'XScale','log')
setLabels(f4,'I_{Flash} (cd/m^2)','Right b_{peak} (\muV)')

lH=lineH(results.d1pre.iF,(results.d1pre.Rab_peak),f4);
lH.color(colors(1,:));
set(lH.h,'DisplayName','R_d1pre')
lH=lineH(results.d1post.iF,(results.d1post.Rab_peak),f4);
lH.color(colors(2,:));
set(lH.h,'DisplayName','R_d1post')
lH=lineH(results.d3pre.iF,(results.d3pre.Rab_peak),f4);
lH.color(colors(3,:));
set(lH.h,'DisplayName','R_d3pre')
lH=lineH(results.d3post.iF,(results.d3post.Rab_peak),f4);
lH.color(colors(4,:));
set(lH.h,'DisplayName','R_d3post')

%% Export to Igor for collaboration
% Panel plans: 
% IS averages pre and post L and R 
% iF vs a- and b-waves L and R
saveFolder = sprintf('erg/squirrel/invivo/%s',Sq);
makeAxisStruct(f1,'aMB001_L',saveFolder);
makeAxisStruct(f2,'aMB001_R',saveFolder);
makeAxisStruct(f3,'bMB001_L',saveFolder);
makeAxisStruct(f4,'bMB001_R',saveFolder);

%%
hGUI=erg_iseries(Is.pre,[],10);
drawnow
makeAxisStruct(hGUI.figData.plotL2,'IsMB001pre_L',saveFolder);
makeAxisStruct(hGUI.figData.plotR2,'IsMB001pre_R',saveFolder);
%%
hGUI=erg_iseries(Is.postiii,[],10);
drawnow
makeAxisStruct(hGUI.figData.plotL2,'IsMB001postiii_L',saveFolder);
makeAxisStruct(hGUI.figData.plotR2,'IsMB001postiii_R',saveFolder);

