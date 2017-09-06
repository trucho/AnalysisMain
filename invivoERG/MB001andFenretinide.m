%% MB-001 Aug_2017
% Iseries only
% Analysis instructions:
    % 0) Give csv extension to ERG files (using bash):
    %       "for d in *; do for i in $d/*; do mv "$i" "$i.csv"; done; done
    % 1) Open jupyter notebook and map csv files to hdf5 in whole folder
    % 2) Identify relevant directory and files
    % 3) Individually screen intensity series data and get averages
    % (erg_screentrials)
    % 4) OPTIONAL: look at a- or b-wave vs. I (cd/m^2)
    % (erg_iseries)
    % 5) Summary plots



%% MB-001 Low Dose (8 mg/kg)
close all; clear; clear classes; clc

% Day 1 (baseline)
% dirData = '20170829/20170829_Sq1006_MB001High';
% dirFile = '01_IseriesPre';
% dirFile = '02_IseriesPre';
% dirFile = '11_IseriesPost10min';

% Day 3
dirData = '20170831/20170831_Sq1006_MB001High';
% dirFile = '01_IseriesPre';
dirFile = '13_IseriesPost10min';
% dirFile = '14_IseriesPost10min_repeat';




erg=ERGobj(dirData,dirFile);

%% first screen trials
hGUI=erg_screentrials(erg,[],10);
set(hGUI.figH,'Position',[-1760 -43 1572 989])
% set(hGUI.figH,'Position',[0 100 900 989])

%% then save a and b wave amplitudes
hGUI=erg_iseries(erg,[],10);
set(hGUI.figH,'Position',[-1760 -43 1572 989])
%%

%% Gather saved data to plot
close all; clear; clear classes; clc
Is=struct;

% % Vehicle
% Sq='Sq1000';
% Sq='Sq992';

% % MB-001 Low (8 mg/kg)
% Sq='Sq993';
% Sq='Sq998';

% % MB-001 High (80 mg/kg)
Sq='Sq1006';
% Sq='Sq928'; % dead during day3



switch Sq
    case 'Sq1006'
        dirData='20170829/20170829_Sq1006_MB001High';
        Is.d1pre=ERGobj(dirData,'dirFile');
        Is.d1post=ERGobj(dirData,'dirFile');
        dirData='20170831/20170831_Sq1006_MB001High';
        Is.d3pre=ERGobj(dirData,'dirFile');
        Is.d3post=ERGobj(dirData,'dirFile');
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

colors=pmkmp(size(fields(Is),1),'CubicL');
colors=pmkmp(size(fields(Is),1),'LinLhot');


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

lH=lineH(results.d1pre.iF,(results.d1pre.Lb_peak),f3);
lH.color(colors(1,:));
set(lH.h,'DisplayName','L_d1pre')
lH=lineH(results.d1post.iF,(results.d1post.Lb_peak),f3);
lH.color(colors(2,:));
set(lH.h,'DisplayName','L_d1post')
lH=lineH(results.d3pre.iF,(results.d3pre.Lb_peak),f3);
lH.color(colors(3,:));
set(lH.h,'DisplayName','L_d3pre')
lH=lineH(results.d3post.iF,(results.d3post.Lb_peak),f3);
lH.color(colors(4,:));
set(lH.h,'DisplayName','L_d3post')

f4=getfigH(4);
set(f4,'XScale','log')
setLabels(f4,'I_{Flash} (cd/m^2)','Right b_{peak} (\muV)')

lH=lineH(results.d1pre.iF,(results.d1pre.Rb_peak),f4);
lH.color(colors(1,:));
set(lH.h,'DisplayName','R_d1pre')
lH=lineH(results.d1post.iF,(results.d1post.Rb_peak),f4);
lH.color(colors(2,:));
set(lH.h,'DisplayName','R_d1post')
lH=lineH(results.d3pre.iF,(results.d3pre.Rb_peak),f4);
lH.color(colors(3,:));
set(lH.h,'DisplayName','R_d3pre')
lH=lineH(results.d3post.iF,(results.d3post.Rb_peak),f4);
lH.color(colors(4,:));
set(lH.h,'DisplayName','R_d3post')
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

