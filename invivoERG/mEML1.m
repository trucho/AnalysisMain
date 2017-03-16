%% EML +/- and -/- ERGs 
% Sep_2016: EML+/- has no b-wave, but was not replicated since
% Iseries
% Analysis instructions:
    % 1) Open jupyter notebook and map csv files to hdf5 in whole folder
    % 2) Identify relevant directory and files
    % 3) Individually screen intensity series data and get averages
    % (erg_screentrials)
    % 4) OPTIONAL: look at a- or b-wave vs. I (cd/m^2)
    % (erg_iseries) (Lock&Save to store in results)
    % 5) Summary plots: erg_issummary

%% 
close all; clear; clear classes; clc

% % wl05-2 (EML1+/-)
% dirData='20160928/20160928_wl05_2_eml1het/';
% dirFile='20160928_wl05_2_01_iSscotdark';

% wl05-3 (WT)
% dirData='20160928/20160928_wl05_3_wt/';
% dirFile='20160928_wl05_3_01_iSscotdark';


% wl06-10 (eml1weird???) % 3-bands in genotyping
% dirData='20161007/20161007_wl06_10/';
% dirFile='01_iSeries';

% wl06-13 (eml1weird???) % 3-bands in genotyping
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
% dirData='20170301/20170301_wl05_100_eml1ko/';
% dirFile='01_iSeriesScotopic';
% dirFile='02_iSeriesPhotopic';

% % wl05-103 (EML1+/-)
% dirData='20170301/20170301_wl05_103_eml1het/';
% dirFile='01_iSeriesScotopic';
% dirFile='02_iSeriesPhotopic';

% % wl05-106 (WT)
% dirData='20170301/20170301_wl05_106_wt/';
% dirFile='01_iSeriesScotopic';
% % % % % dirFile='02_iSeriesPhotopic'; % mouse woke up

% % wl05-102 (EML1-/-)
dirData='20170309/20170309_wl05_102_eml1ko/';
dirFile='01_iSeriesScotopicXe';
dirFile='02_iSeriesPhotopic';

% % wl05-107 (WT)
dirData='20170309/20170309_wl05_107_wt/';
dirFile='01_iSeriesScotopicStitch'; %Steps 1- 13 = CyanLED; 13-16 = Xenon lamp


% % wl05-109 (EML1+/-)
dirData='20170309/20170309_wl05_109_eml1het/';
dirFile='01_iSeriesScotopicXe';
% dirFile='02_iSeriesPhotopic';

erg=ERGobj(dirData,dirFile);

%%
hGUI=erg_screentrials(erg,[],10);
% set(hGUI.figH,'Position',[-1712 1 1483 1007])
%% then save a and b wave amplitudes
hGUI=erg_iseries(erg,[],10);
% set(hGUI.figH,'Position',[-1712 1 1483 1007])
%%
%%
%% population curves

close all; clear; clear classes; clc
dirData={...
%     '20160928/20160928_wl05_2_eml1het/' ...   % no b-wave guy
%     '20160928/20160928_wl05_3_wt/' ...          % small responses overall; clipped range
    '20161007/20161007_wl06_10/' ...    
    '20161007/20161007_wl06_13/' ...
    '20161021/20161021_wl05_36_wt/' ...
    '20161021/20161021_wl05_37_eml1het/' ...    % small responses overall
    '20161118/20161128_wl05_40_wt/' ...
    '20161118/20161128_wl05_42_eml1het/' ...
    '20170301/20170301_wl05_100_eml1ko/' ...
    '20170301/20170301_wl05_103_eml1het/' ...
    '20170301/20170301_wl05_106_wt/' ...
     };
dirFile={...
%     '20160928_wl05_2_01_iSscotdark' ...
%     '20160928_wl05_3_01_iSscotdark' ...
    '01_iSeries' ...
    '01_iSeriesCyExt' ...
    '01_iSeries' ...
    '01_iSeries' ...
    '01_iSeriesScotopic' ...
    '01_iSeriesScotopic' ...
    '01_iSeriesScotopic' ...
    '01_iSeriesScotopic' ...
    '01_iSeriesScotopic' ...
    };
erg=cell(1,length(dirData));
for i=1:length(dirData)
    erg{i}=ERGobj(dirData{i},dirFile{i});
end
%% population curves using Xenon lamp (20170309)

close all; clear; clear classes; clc
dirData={...
    '20170309/20170309_wl05_102_eml1ko/' ...
    '20170309/20170309_wl05_107_wt/' ...
    '20170309/20170309_wl05_109_eml1het/' ...
     };
dirFile={...
    '01_iSeriesScotopicXe' ...
    '01_iSeriesScotopicStitch' ...
    '01_iSeriesScotopicXe' ...
    };
erg=cell(1,length(dirData));
for i=1:length(dirData)
    erg{i}=ERGobj(dirData{i},dirFile{i});
end


%%
hGUI=erg_iseries(erg{3},[],10);

%%
hGUI=erg_issummary(erg,[],10);
% set(hGUI.figH,'Position',[-1712 1 1483 1007])
%%
% % % % makeAxisStruct(hGUI.figData.plotL2,'IsMB001pre_L',sprintf('erg/squirrel/invivo/Sq922'));
% % % % makeAxisStruct(hGUI.figData.plotR2,'IsMB001pre_R',sprintf('erg/squirrel/invivo/Sq922'));
