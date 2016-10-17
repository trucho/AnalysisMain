%% EML +/- and -/- ERGs 
% Sep_2016: EML+/- has no b-wave!
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

% wl05-2 (EML1+/-)
dirData='20160928/20160928_wl05_2_eml1het/';
dirFile='20160928_wl05_2_01_iSscotdark';

% % wl05-3 (WT)
% dirData='20160928/20160928_wl05_3_wt/';
% dirFile='20160928_wl05_3_01_iSscotdark';     




erg=ERGobj(dirData,dirFile);
hGUI=erg_screentrials(erg,[],10);
set(hGUI.figH,'Position',[-1760 -243 1572 989])

%% then save a and b wave amplitudes
hGUI=erg_iseries(erg,[],10);

%%
makeAxisStruct(hGUI.figData.plotL2,'IsMB001pre_L',sprintf('erg/squirrel/invivo/Sq922'));
makeAxisStruct(hGUI.figData.plotR2,'IsMB001pre_R',sprintf('erg/squirrel/invivo/Sq922'));
