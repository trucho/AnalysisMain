% screening (1 by 1 unfortunately)

%% MB001 High dose
%Sq1040
dirData = '20171023/20171023_Sq1040_MB001High';
dirFile = '02_FlashesPre';
dirFile = '03_FlashesPost0s';
dirFile = '04_FlashesPost1min09s';
dirFile = '05_FlashesPost2min38s';
dirFile = '06_FlashesPost4min07s';
dirFile = '07_FlashesPost5min35s';
dirFile = '08_FlashesPost7min05s';
dirFile = '09_FlashesPost8min34s';
dirFile = '11_FlashesPost14min29s';
dirFile = '12_FlashesPost16min12s';

dirData = '20171025/20171025_Sq1040_MB001High';
dirFile = '02_FlashPre';
dirFile = '03_FlashPost0s';
dirFile = '04_FlashPost1min19s';
dirFile = '05_FlashPost2min53s';
dirFile = '06_FlashPost4min20s';
dirFile = '07_FlashPost5min48s';
dirFile = '08_FlashPost7min14s';
dirFile = '09_FlashPost8min37s';
dirFile = '11_FlashPost13min55s';
dirFile = '12_FlashPost15min23s';

%% Vehicle
%Sq999
% dirData = '20170905/20170905_Sq999_Vehicle';
% dirFile = '02_FlashesPre';
% dirFile = '03_FlashesPost0s';
% dirFile = '04_FlashesPost1min18s';
% dirFile = '05_FlashesPost2min43s';
% dirFile = '06_FlashesPost4min08s';
% dirFile = '07_FlashesPost5min32s';
% dirFile = '08_FlashesPost6min58s';
% dirFile = '09_FlashesPost8min24s';
% dirFile = '11_FlashesPost13min14s';
% dirFile = '12_FlashesPost15min32s';
% 
% 
% dirData = '20170907/20170907_Sq999_Vehicle';
% dirFile = '02_FlashesPre';
% dirFile = '03_FlashesPost0s';
% dirFile = '04_FlashesPost1min16s';
% dirFile = '05_FlashesPost2min42s';
% dirFile = '06_FlashesPost4min15s';
% dirFile = '07_FlashesPost5min41s';
% dirFile = '08_FlashesPost7min04s';
% dirFile = '09_FlashesPost8min35s';
% dirFile = '11_FlashesPost14min43s';
% dirFile = '12_FlashesPost16min00s';

%Sq1000
% dirData = '20170829/20170829_Sq1000_Veh';
% dirFile = '03_FlahesPre';
% dirFile = '04_FlahesPost0s';
% dirFile = '05_FlahesPost30s';
% dirFile = '06_FlahesPost1min30s';
% dirFile = '07_FlahesPost3min';
% dirFile = '08_FlahesPost5min';
% dirFile = '09_FlahesPost7min15s';
% % 
% dirData = '20170831/20170831_Sq1000_Vehicle';
% dirFile = '02_FlashesPre';
% dirFile = '03_FlashesPost0s';
% dirFile = '04_FlashesPost40s';
% dirFile = '05_FlashesPost1min30s';
% dirFile = '06_FlashesPost2min30s';
% dirFile = '07_FlashesPost3min30s';
% dirFile = '08_FlashesPost4min30s';
% dirFile = '09_FlashesPost5min30s';
% dirFile = '10_FlashesPost6min30s';
% dirFile = '11_FlashesPost7min30s';
% dirFile = '12_FlashesPost8min30s';

%Sq992
dirData = '20170830/20170830_Sq992_Veh';
dirFile = '02_FlashesPre';
dirFile = '03_FlashesPost0s';
dirFile = '04_FlashesPost1min10s';
dirFile = '05_FlashesPost2min10s';
dirFile = '06_FlashesPost3min5s';
dirFile = '07_FlashesPost4min';
dirFile = '08_FlashesPost5min10s';
dirFile = '09_FlashesPost6min20s';
dirFile = '10_FlashesPost7min40s';
dirFile = '11_FlashesPost8min45s';
% 
% 
dirData = '20170901/20170901_Squirrel992_Vehicle';
dirFile = '02_FlashesPre';
% dirFile = '03_FlashesPost0s';
% dirFile = '04_FlashesPost1min20s';
% dirFile = '05_FlashesPost2min45s';
% dirFile = '06_FlashesPost4min15s';
% dirFile = '07_FlashesPost5min40s';
% dirFile = '08_FlashesPost7min06s';
% dirFile = '09_FlashesPost8min40s';
% dirFile = '11_FlashesPost13min50s';


erg=ERGobj(dirData,dirFile);

% %% first screen trials
hGUI=erg_screenrecovery(erg,[],10);
% set(hGUI.figH,'Position',[-1760 -43 1572 989])
% set(hGUI.figH,'Position',[0 100 900 989])
% set(hGUI.figH,'Position',[200 5 1169 800]) %1 screen

%% t delays
a=[...
    0,0;...
    0,0;...
    1,20;...
    2,45;...
    4,15;...
    5,40;...
    7,06;...
    8,40;...
    13,50;...
];

% a=[...
%     0,0;...
%     0,0;...
%     0,40;...
%     1,30;...
%     2,30;...
%     3,30;...
%     4,30;...
%     5,30;...
%     6,30;...
%     7,30;...
%     8,30;...
% ];


    
tdelays=(a(:,1).*60+a(:,2))';
fprintf('[');fprintf('%g,',tdelays)
fprintf(']\n')



%% concatenator
whichone='Sq1040';
% whichone='Sq999';
whichone='Sq1000';
% whichone='Sq992';
ergR=erg_recovery(whichone);
% title('MB001')
title('Vehicle')
