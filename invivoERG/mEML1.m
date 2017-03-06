%% EML +/- and -/- ERGs 
% Sep_2016: EML+/- has no b-wave, but was not replicated since
% Iseries
% Analysis instructions:
    % 1) Open jupyter notebook and map csv files to hdf5 in whole folder
    % 2) Identify relevant directory and files
    % 3) Individually screen intensity series data and get averages
    % (erg_screentrials)
    % 4) OPTIONAL: look at a- or b-wave vs. I (cd/m^2)
    % (erg_iseries)
    % 5) Summary plots

%% 
close all; clear; clear classes; clc

% % wl05-2 (EML1+/-)
% dirData='20160928/20160928_wl05_2_eml1het/';
% dirFile='20160928_wl05_2_01_iSscotdark';

% wl05-3 (WT)
% dirData='20160928/20160928_wl05_3_wt/';
% dirFile='20160928_wl05_3_01_iSscotdark';

% % wl06-10 (???)
% dirData='20161007/20161007_wl06_10/';
% dirFile='01_iSeries';


% % wl06-13 (???)
% dirData='20161007/20161007_wl06_13/';
% dirFile='01_iSeriesCyExt';


% % wl05-37 (EML1+/-)
% dirData='20161021/20161021_wl05_37_eml1het/';
% dirFile='01_iSeries';

% % wl05-36 (WT)
% dirData='20161021/20161021_wl05_36_wt/';
% dirFile='01_iSeries';

% % wl05-42 (EML1+/-)
% dirData='20161118/20161128_wl05_42_eml1het/';
% dirFile='01_iSeriesScotopic';
% dirFile='02_iSeriesPhotopic';

% % wl05-40 (WT)
% dirData='20161118/20161128_wl05_40_wt/';
% dirFile='01_iSeriesScotopic';
% dirFile='02_iSeriesPhotopic';

% % wl05-100 (EML1-/-)
dirData='20170301/20170301_wl05_100_eml1ko/';
dirFile='01_iSeriesScotopic';
dirFile='02_iSeriesPhotopic';

% % wl05-103 (EML1+/-)
dirData='20170301/20170301_wl05_103_eml1het/';
% dirFile='01_iSeriesScotopic';
dirFile='02_iSeriesPhotopic';

% % wl05-106 (WT)
dirData='20170301/20170301_wl05_106_wt/';
% dirFile='01_iSeriesScotopic';
% % % % % dirFile='02_iSeriesPhotopic'; % mouse woke up

erg=ERGobj(dirData,dirFile);

%%

hGUI=erg_screentrials(erg,[],10);
set(hGUI.figH,'Position',[-1712 1 1483 1007])

%% then save a and b wave amplitudes
hGUI=erg_iseries(erg,[],10);
%% compare littermates
dirData='20170301/20170301_wl05_100_eml1ko/';
dirFile='01_iSeriesScotopic';
dirFile='02_iSeriesPhotopic';
erg1=ERGobj(dirData,dirFile);
hGUI1=erg_iseries(erg1,[],10);


%%
dirData='20170301/20170301_wl05_103_eml1het/';
dirFile='01_iSeriesScotopic';
dirFile='02_iSeriesPhotopic';
erg2=ERGobj(dirData,dirFile);
hGUI2=erg_iseries(erg2,[],11);

%%
dirData='20170301/20170301_wl05_106_wt/';
dirFile='01_iSeriesScotopic';

erg3=ERGobj(dirData,dirFile);
hGUI3=erg_iseries(erg3,[],12);

%%
% % % % makeAxisStruct(hGUI.figData.plotL2,'IsMB001pre_L',sprintf('erg/squirrel/invivo/Sq922'));
% % % % makeAxisStruct(hGUI.figData.plotR2,'IsMB001pre_R',sprintf('erg/squirrel/invivo/Sq922'));
