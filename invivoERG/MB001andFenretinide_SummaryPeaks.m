%% Summary MB-001 Aug_2017 
%% Need to update all of this for new MB001 recordings
% Probably should try to match figures from mouse (but they're ugly)
% Also try to NOT normalize data to match mouse?
%% Gather saved data to plot
clear; clear classes; clc
[d1Avg,d1Diff,d1Diff2,d1Sq] =  MB001Fen_collectAllDay1();
%%
%Pick treatment and squirrel
    thisone='Vehicle'; s=2;
%     thisone='MB001Low'; s=1;
%     thisone='MB001High'; s=2;
%     thisone='Fenretinide'; s=2;

%%
% colors=pmkmp(size(fields(Is),1),'CubicL');
% colors=pmkmp(size(fields(Is),1),'LinLhot');
%% Normalize curves by a-wave peak maximum and plot 1 squirrel data
% Probably normalization should be just using the prebleach results, right?
% Otherwise bleaching effects are taken off?

[Avg,Diff,Diff2,Sq] =  MB001Fen_collectAverages(thisone);

% colors = [[.5 .5 .5];[0 0 0];[.9 .5 .5];[1 0 0];];
colors = [[130 170 184];[128 128 128];[217 64 62];[233 139 58];]./255;

f1=getfigH(1);
set(f1,'XScale','log')
setLabels(f1,'I_{Flash} (cd/m^2)','Bleached eye a_{peak} (\muV)')

lH=lineH(Avg.iF,(Avg.ad1pre(s,:)),f1);
lH.openmarkers;lH.color(colors(1,:));
set(lH.h,'DisplayName','ad1pre')
lH=lineH(Avg.iF,(Avg.ad1post(s,:)),f1);
lH.openmarkers;lH.color(colors(2,:));
set(lH.h,'DisplayName','ad1post')
lH=lineH(Avg.iF,(Avg.ad3pre(s,:)),f1);
lH.openmarkers;lH.color(colors(3,:));
set(lH.h,'DisplayName','ad3pre')
lH=lineH(Avg.iF,(Avg.ad3post(s,:)),f1);
lH.openmarkers;lH.color(colors(4,:));
set(lH.h,'DisplayName','ad3post')

f2=getfigH(2);
set(f2,'XScale','log')
setLabels(f2,'I_{Flash} (cd/m^2)','Bleached eye b_{peak} (\muV)')

lH=lineH(Avg.iF,(Avg.bd1pre(s,:)),f2);
lH.openmarkers;lH.color(colors(1,:));
set(lH.h,'DisplayName','bvpre')
lH=lineH(Avg.iF,(Avg.bd1post(s,:)),f2);
lH.openmarkers;lH.color(colors(2,:));
set(lH.h,'DisplayName','bvpost')
lH=lineH(Avg.iF,(Avg.bd3pre(s,:)),f2);
lH.openmarkers;lH.color(colors(3,:));
set(lH.h,'DisplayName','bdpre')
lH=lineH(Avg.iF,(Avg.bd3post(s,:)),f2);
lH.openmarkers;lH.color(colors(4,:));
set(lH.h,'DisplayName','bdpost')

% Collect averages from normalized curves across intensities (new way)
% Plot Avg pre/post

aplot=1;
dplot=1;

f3=getfigH(3);
set(f3,'XScale','log')
setLabels(f3,'I_{Flash} (cd/m^2)','Average a_{peak} (\muV)')

if aplot
    lH=lineH(d1Avg.iF,nanmean(d1Avg.ad1pre,1),f3);
    lH.line;lH.color(colors(1,:));
    set(lH.h,'DisplayName','a_d1pre')
    lH.errorbars(d1Avg.iF,nanmean(d1Avg.ad1pre,1),nanstd(d1Avg.ad1pre,1)./sqrt(d1Avg.nSq),colors(1,:),f3,'a_d1presd');
%     lH.errorfillIgor(d1Avg.iF,nanmean(d1Avg.ad1pre,1),nanstd(d1Avg.ad1pre,1)./sqrt(d1Avg.nSq),whithen(colors(1,:),.5),f3,'a_d1presd');
    
    lH=lineH(d1Avg.iF,nanmean(d1Avg.ad1post,1),f3);
    lH.line;lH.color(colors(2,:));
    set(lH.h,'DisplayName','a_d1post')
    lH.errorbars(d1Avg.iF,nanmean(d1Avg.ad1post,1),nanstd(d1Avg.ad1post,1)./sqrt(d1Avg.nSq),colors(2,:),f3,'a_d1postsd');
%     lH.errorfillIgor(d1Avg.iF,nanmean(d1Avg.ad1post,1),nanstd(d1Avg.ad1post,1)./sqrt(d1Avg.nSq),whithen(colors(2,:),.5),f3,'a_d1postsd');
else
    lH=lineH(Avg.iF,nanmean(Avg.ad1pre,1),f3);
    lH.color(colors(1,:));
    set(lH.h,'DisplayName','a_d1pre')
    lH.errorbars(Avg.iF,nanmean(Avg.ad1pre,1),nanstd(Avg.ad1pre,1)./sqrt(Avg.nSq),colors(1,:),f3,'a_d1presd');
    
    lH=lineH(Avg.iF,nanmean(Avg.ad1post,1),f3);
    lH.color(colors(2,:));
    set(lH.h,'DisplayName','a_d1post')
    lH.errorbars(Avg.iF,nanmean(Avg.ad1post,1),nanstd(Avg.ad1post,1)./sqrt(Avg.nSq),colors(2,:),f3,'a_d1postsd');
end

% if dplot
%     lH=lineH(Avg.iF,nanmean(Avg.ad3pre,1),f3);
%     lH.color(colors(3,:));
%     set(lH.h,'DisplayName','a_d3pre')
%     lH.errorbars(Avg.iF,nanmean(Avg.ad3pre,1),nanstd(Avg.ad3pre,1)./sqrt(Avg.nSq),colors(3,:),f3,'a_d3presd');
%     
%     lH=lineH(Avg.iF,nanmean(Avg.ad3post,1),f3);
%     lH.color(colors(4,:));
%     set(lH.h,'DisplayName','a_d3post')
%     lH.errorbars(Avg.iF,nanmean(Avg.ad3post,1),nanstd(Avg.ad3post,1)./sqrt(Avg.nSq),colors(4,:),f3,'a_d3postsd');
% end
if dplot
    for i = 1:Avg.nSq
    lH=lineH(Avg.iF,Avg.ad3pre(i,:),f3);
    lH.color(colors(3,:));
    set(lH.h,'DisplayName',sprintf('a_d3pre%02.0g',i));
%     lH=lineH(Avg.iF,Avg.ad3pre(i,:),f3);
%     lH.line;lH.color(colors(3,:));
%     set(lH.h,'DisplayName',sprintf('a2_d3pre%02.0g',i));
    
    lH=lineH(Avg.iF,Avg.ad3post(i,:),f3);
    lH.color(colors(4,:));
    set(lH.h,'DisplayName',sprintf('a_d3post%02.0g',i));
%     lH=lineH(Avg.iF,Avg.ad3post(i,:),f3);
%     lH.line;lH.color(colors(4,:));
%     set(lH.h,'DisplayName',sprintf('a2_d3post%02.0g',i));
    end
end


f4=getfigH(4);
set(f4,'XScale','log')
setLabels(f4,'I_{Flash} (cd/m^2)','Average b_{peak} (\muV)')

if aplot
    lH=lineH(d1Avg.iF,nanmean(d1Avg.bd1pre,1),f4);
    lH.line;lH.color(colors(1,:));
    set(lH.h,'DisplayName','b_d1pre')
%     lH.errorfillIgor(d1Avg.iF,nanmean(d1Avg.bd1pre,1),nanstd(d1Avg.bd1pre,1)./sqrt(d1Avg.nSq),whithen(colors(1,:),.5),f4,'b_d1presd');
    lH.errorbars(d1Avg.iF,nanmean(d1Avg.bd1pre,1),nanstd(d1Avg.bd1pre,1)./sqrt(d1Avg.nSq),colors(1,:),f4,'b_d1presd');
    
    lH=lineH(d1Avg.iF,nanmean(d1Avg.bd1post,1),f4);
    lH.line;lH.color(colors(2,:));
    set(lH.h,'DisplayName','b_d1post')
    lH.errorbars(d1Avg.iF,nanmean(d1Avg.bd1post,1),nanstd(d1Avg.bd1post,1)./sqrt(d1Avg.nSq),colors(2,:),f4,'b_d1postsd');
%     lH.errorfillIgor(d1Avg.iF,nanmean(d1Avg.bd1post,1),nanstd(d1Avg.bd1post,1)./sqrt(d1Avg.nSq),whithen(colors(2,:),.5),f4,'b_d1postsd');
else
    lH=lineH(Avg.iF,nanmean(Avg.bd1pre,1),f4);
    lH.color(colors(1,:));
    set(lH.h,'DisplayName','b_d1pre')
    lH.errorbars(Avg.iF,nanmean(Avg.bd1pre,1),nanstd(Avg.bd1pre,1)./sqrt(Avg.nSq),colors(1,:),f4,'b_d1presd');
    
    lH=lineH(Avg.iF,nanmean(Avg.bd1post,1),f4);
    lH.color(colors(2,:));
    set(lH.h,'DisplayName','b_d1post')
    lH.errorbars(Avg.iF,nanmean(Avg.bd1post,1),nanstd(Avg.bd1post,1)./sqrt(Avg.nSq),colors(2,:),f4,'b_d1postsd');
end
% if dplot
%     lH=lineH(Avg.iF,nanmean(Avg.bd3pre,1),f4);
%     lH.color(colors(3,:));
%     set(lH.h,'DisplayName','b_d3pre')
%     lH.errorbars(Avg.iF,nanmean(Avg.bd3pre,1),nanstd(Avg.bd3pre,1)./sqrt(Avg.nSq),colors(3,:),f4,'b_d3presd');
%     
%     lH=lineH(Avg.iF,nanmean(Avg.bd3post,1),f4);
%     lH.color(colors(4,:));
%     set(lH.h,'DisplayName','b_d3post')
%     lH.errorbars(Avg.iF,nanmean(Avg.bd3post,1),nanstd(Avg.bd3post,1)./sqrt(Avg.nSq),colors(4,:),f4,'b_d3postsd');
% end
if dplot
for i = 1:Avg.nSq
    lH=lineH(Avg.iF,Avg.bd3pre(i,:),f4);
    lH.color(colors(3,:));
    set(lH.h,'DisplayName',sprintf('b_d3pre%02.0g',i));
    lH=lineH(Avg.iF,Avg.bd3pre(i,:),f4);
    lH.line;lH.color(colors(3,:));
    set(lH.h,'DisplayName',sprintf('b2_d3pre%02.0g',i));
    
    lH=lineH(Avg.iF,Avg.bd3post(i,:),f4);
    lH.color(colors(4,:));
    set(lH.h,'DisplayName',sprintf('b_d3post%02.0g',i));
    lH=lineH(Avg.iF,Avg.bd3post(i,:),f4);
    lH.line;lH.color(colors(4,:));
    set(lH.h,'DisplayName',sprintf('b2_d3post%02.0g',i));
end
end

% Plot differences pre/post
f7=getfigH(7);
set(f7,'XScale','log')
ylim([-200 200])
% xlim([.5e0 1e4])
setLabels(f7,'I_{Flash} (cd/m^2)','a_{peak} change (%)')
lH = lineH(Diff.iF,zeros(size(Diff.iF)),f7);
lH.linedash;

if aplot
    lH=lineH(d1Diff.iF,nanmean(d1Diff.ad1,1),f7);
    lH.line;lH.color(colors(2,:));
    set(lH.h,'DisplayName','a_d1')
    eh=lH.errorbars(d1Diff.iF,nanmean(d1Diff.ad1,1),nanstd(d1Diff.ad1,1)./sqrt(d1Diff.nSq),colors(2,:),f7,'a_d1sd');
%     eh=lH.errorfillIgor(d1Diff.iF,nanmean(d1Diff.ad1,1),nanstd(d1Diff.ad1,1)./sqrt(d1Diff.nSq),whithen(colors(2,:),.5),f7,'a_d1sd');
else
    lH=lineH(Diff.iF,nanmean(Diff.ad1,1),f7);
    lH.color(colors(2,:));
    set(lH.h,'DisplayName','a_d1')
    eh=lH.errorbars(Diff.iF,nanmean(Diff.ad1,1),nanstd(Diff.ad1,1)./sqrt(Diff.nSq),colors(2,:),f7,'a_d1sd');
end

for i = 1:Diff.nSq
lH=lineH(Diff.iF,Diff.ad3(i,:),f7);
lH.color(colors(4,:));
set(lH.h,'DisplayName',sprintf('a_d3%02.0g',i));
lH=lineH(Diff.iF,Diff.ad3(i,:),f7);
lH.line;lH.color(colors(4,:));
set(lH.h,'DisplayName',sprintf('a2_d3%02.0g',i));
end


f8=getfigH(8);
set(f8,'XScale','log')
ylim([-200 200])
% xlim([.5e0 1e4])
setLabels(f8,'I_{Flash} (cd/m^2)','b_{peak} change (%)')
lH = lineH(Diff.iF,zeros(size(Diff.iF)),f8);
lH.linedash;

if aplot
    lH=lineH(d1Diff.iF,nanmean(d1Diff.bd1,1),f8);
    lH.line;lH.color(colors(2,:));
    set(lH.h,'DisplayName','b_d1')
%     eh=lH.errorfillIgor(d1Diff.iF,nanmean(d1Diff.bd1,1),nanstd(d1Diff.bd1,1)./sqrt(d1Diff.nSq),whithen(colors(2,:),.5),f8,'b_d1sd');
    eh=lH.errorbars(d1Diff.iF,nanmean(d1Diff.bd1,1),nanstd(d1Diff.bd1,1)./sqrt(d1Diff.nSq),colors(2,:),f8,'b_d1sd');
else
    lH=lineH(Diff.iF,nanmean(Diff.bd1,1),f8);
    lH.color(colors(2,:));
    set(lH.h,'DisplayName','b_d1')
    eh=lH.errorbars(Diff.iF,nanmean(Diff.bd1,1),nanstd(Diff.bd1,1)./sqrt(Diff.nSq),colors(2,:),f8,'b_d1sd');
end

for i = 1:Diff.nSq
lH=lineH(Diff.iF,Diff.bd3(i,:),f8);
lH.color(colors(4,:));
set(lH.h,'DisplayName',sprintf('b_d3%02.0g',i));
lH=lineH(Diff.iF,Diff.bd3(i,:),f8);
lH.line;lH.color(colors(4,:));
set(lH.h,'DisplayName',sprintf('b2_d3%02.0g',i));
end

% Plot differences day1 vs day3
f9=getfigH(9);
set(f9,'XScale','log')
ylim([-200 200])
% xlim([.5e0 1e4])
setLabels(f9,'I_{Flash} (cd/m^2)','a_{peak} change (%)')
lH = lineH(Diff2.iF,zeros(size(Diff2.iF)),f9);
lH.linedash;

if aplot
%     lH=lineH(d1Diff2.iF,nanmean(d1Diff2.apre,1),f9);
%     lH.line;lH.color(colors(2,:));
%     set(lH.h,'DisplayName','a_pre')
%     eh=lH.errorfillIgor(d1Diff2.iF,nanmean(d1Diff2.apre,1),nanstd(d1Diff2.apre,1)./sqrt(d1Diff2.nSq),whithen(colors(2,:),.5),f9,'a_presd');
% else
%     lH=lineH(Diff2.iF,nanmean(Diff2.apre,1),f9);
%     lH.color(colors(2,:));
%     set(lH.h,'DisplayName','a_pre')
%     eh=lH.errorbars(Diff2.iF,nanmean(Diff2.apre,1),nanstd(Diff2.apre,1)./sqrt(Diff2.nSq),colors(2,:),f9,'a_presd');
end

for i = 1:Diff2.nSq
lH=lineH(Diff2.iF,Diff2.apre(i,:),f9);
lH.color(colors(2,:));
set(lH.h,'DisplayName',sprintf('a_pre%02.0g',i));
lH=lineH(Diff2.iF,Diff2.apre(i,:),f9);
lH.line;lH.color(colors(2,:));
set(lH.h,'DisplayName',sprintf('a2_pre%02.0g',i));
    
lH=lineH(Diff2.iF,Diff2.apost(i,:),f9);
lH.color(colors(4,:));
set(lH.h,'DisplayName',sprintf('a_post%02.0g',i));
lH=lineH(Diff2.iF,Diff2.apost(i,:),f9);
lH.line;lH.color(colors(4,:));
set(lH.h,'DisplayName',sprintf('a2_post%02.0g',i));
end


f10=getfigH(10);
set(f10,'XScale','log')
ylim([-200 200])
% xlim([.5e0 1e4])
setLabels(f10,'I_{Flash} (cd/m^2)','b_{peak} change (%)')
lH = lineH(Diff2.iF,zeros(size(Diff2.iF)),f10);
lH.linedash;

if aplot
%     lH=lineH(d1Diff2.iF,nanmean(d1Diff2.bpre,1),f10);
%     lH.line;lH.color(colors(2,:));
%     set(lH.h,'DisplayName','b_pre')
%     eh=lH.errorfillIgor(d1Diff2.iF,nanmean(d1Diff2.bpre,1),nanstd(d1Diff2.bpre,1)./sqrt(d1Diff2.nSq),whithen(colors(2,:),.5),f10,'b_presd');
% else
%     lH=lineH(Diff2.iF,nanmean(Diff2.bpre,1),f10);
%     lH.color(colors(2,:));
%     set(lH.h,'DisplayName','b_pre')
%     eh=lH.errorbars(Diff2.iF,nanmean(Diff2.bpre,1),nanstd(Diff2.bpre,1)./sqrt(Diff2.nSq),colors(2,:),f10,'b_presd');
end

for i = 1:Diff2.nSq
lH=lineH(Diff2.iF,Diff2.bpre(i,:),f10);
lH.color(colors(2,:));
set(lH.h,'DisplayName',sprintf('b_pre%02.0g',i));
lH=lineH(Diff2.iF,Diff2.bpre(i,:),f10);
lH.line;lH.color(colors(2,:));
set(lH.h,'DisplayName',sprintf('b2_pre%02.0g',i));

lH=lineH(Diff2.iF,Diff2.bpost(i,:),f10);
lH.color(colors(4,:));
set(lH.h,'DisplayName',sprintf('b_post%02.0g',i));
lH=lineH(Diff2.iF,Diff2.bpost(i,:),f10);
lH.line;lH.color(colors(4,:));
set(lH.h,'DisplayName',sprintf('b2_post%02.0g',i));
end
%
% %% Export to Igor for collaboration
% 
thisone = 'day1only';
makeAxisStruct(f1,'c_aPeak',sprintf('erg/squirrel/invivo/round2/%s',thisone));
makeAxisStruct(f2,'e_bPeak',sprintf('erg/squirrel/invivo/round2/%s',thisone));

makeAxisStruct(f3,'d_aPeakNorm',sprintf('erg/squirrel/invivo/round2/%s',thisone));
makeAxisStruct(f4,'f_bPeakNorm',sprintf('erg/squirrel/invivo/round2/%s',thisone));

% % % % % % makeAxisStruct(f5,'g_aRatios',sprintf('erg/squirrel/invivo/round2/%s',thisone));
% % % % % % makeAxisStruct(f6,'h_bRatios',sprintf('erg/squirrel/invivo/round2/%s',thisone));

makeAxisStruct(f7,'g_aDiffs',sprintf('erg/squirrel/invivo/round2/%s',thisone));
makeAxisStruct(f8,'h_bDiffs',sprintf('erg/squirrel/invivo/round2/%s',thisone));

makeAxisStruct(f9,'i_aPrePost',sprintf('erg/squirrel/invivo/round2/%s',thisone));
makeAxisStruct(f10,'j_bPrePost',sprintf('erg/squirrel/invivo/round2/%s',thisone));
%%
%% Collect averages from normalized curves across intensities (old way)

% Plot Avg pre/post



aplot=1;
vplot=0;
dplot=1;

f3=getfigH(3);
set(f3,'XScale','log')
setLabels(f3,'I_{Flash} (cd/m^2)','Average a_{peak} (\muV)')

if aplot
    lH=lineH(d1Avg.iF,nanmean(d1Avg.ad1pre,1),f3);
    lH.color(colors(1,:));
    set(lH.h,'DisplayName','a_d1pre')
    lH.errorbars(d1Avg.iF,nanmean(d1Avg.ad1pre,1),nanstd(d1Avg.ad1pre,1)./sqrt(d1Avg.nSq),colors(1,:),f3,'a_d1presd');
    
    lH=lineH(d1Avg.iF,nanmean(d1Avg.ad1post,1),f3);
    lH.color(colors(2,:));
    set(lH.h,'DisplayName','a_d1post')
    lH.errorbars(d1Avg.iF,nanmean(d1Avg.ad1post,1),nanstd(d1Avg.ad1post,1)./sqrt(d1Avg.nSq),colors(2,:),f3,'a_d1postsd');
end

if vplot
    lH=lineH(Avg.iF,nanmean(Avg.ad1pre,1),f3);
    lH.color(colors(1,:));
    set(lH.h,'DisplayName','a_d1pre')
    lH.errorbars(Avg.iF,nanmean(Avg.ad1pre,1),nanstd(Avg.ad1pre,1)./sqrt(Avg.nSq),colors(1,:),f3,'a_d1presd');
    
    lH=lineH(Avg.iF,nanmean(Avg.ad1post,1),f3);
    lH.color(colors(2,:));
    set(lH.h,'DisplayName','a_d1post')
    lH.errorbars(Avg.iF,nanmean(Avg.ad1post,1),nanstd(Avg.ad1post,1)./sqrt(Avg.nSq),colors(2,:),f3,'a_d1postsd');
end

if dplot
    lH=lineH(Avg.iF,nanmean(Avg.ad3pre,1),f3);
    lH.color(colors(3,:));
    set(lH.h,'DisplayName','a_d3pre')
    lH.errorbars(Avg.iF,nanmean(Avg.ad3pre,1),nanstd(Avg.ad3pre,1)./sqrt(Avg.nSq),colors(3,:),f3,'a_d3presd');
    
    lH=lineH(Avg.iF,nanmean(Avg.ad3post,1),f3);
    lH.color(colors(4,:));
    set(lH.h,'DisplayName','a_d3post')
    lH.errorbars(Avg.iF,nanmean(Avg.ad3post,1),nanstd(Avg.ad3post,1)./sqrt(Avg.nSq),colors(4,:),f3,'a_d3postsd');
end


f4=getfigH(4);
set(f4,'XScale','log')
setLabels(f4,'I_{Flash} (cd/m^2)','Average b_{peak} (\muV)')

if aplot
    lH=lineH(d1Avg.iF,nanmean(d1Avg.bd1pre,1),f4);
    lH.color(colors(1,:));
    set(lH.h,'DisplayName','b_d1pre')
    lH.errorbars(d1Avg.iF,nanmean(d1Avg.bd1pre,1),nanstd(d1Avg.bd1pre,1)./sqrt(d1Avg.nSq),colors(1,:),f4,'b_d1presd');
    
    lH=lineH(d1Avg.iF,nanmean(d1Avg.bd1post,1),f4);
    lH.color(colors(2,:));
    set(lH.h,'DisplayName','b_d1post')
    lH.errorbars(d1Avg.iF,nanmean(d1Avg.bd1post,1),nanstd(d1Avg.bd1post,1)./sqrt(d1Avg.nSq),colors(2,:),f4,'b_d1postsd');
end

if vplot
    lH=lineH(Avg.iF,nanmean(Avg.bd1pre,1),f4);
    lH.color(colors(1,:));
    set(lH.h,'DisplayName','b_d1pre')
    lH.errorbars(Avg.iF,nanmean(Avg.bd1pre,1),nanstd(Avg.bd1pre,1)./sqrt(Avg.nSq),colors(1,:),f4,'b_d1presd');
    
    lH=lineH(Avg.iF,nanmean(Avg.bd1post,1),f4);
    lH.color(colors(2,:));
    set(lH.h,'DisplayName','b_d1post')
    lH.errorbars(Avg.iF,nanmean(Avg.bd1post,1),nanstd(Avg.bd1post,1)./sqrt(Avg.nSq),colors(2,:),f4,'b_d1postsd');
end

if dplot
    lH=lineH(Avg.iF,nanmean(Avg.bd3pre,1),f4);
    lH.color(colors(3,:));
    set(lH.h,'DisplayName','b_d3pre')
    lH.errorbars(Avg.iF,nanmean(Avg.bd3pre,1),nanstd(Avg.bd3pre,1)./sqrt(Avg.nSq),colors(3,:),f4,'b_d3presd');
    
    lH=lineH(Avg.iF,nanmean(Avg.bd3post,1),f4);
    lH.color(colors(4,:));
    set(lH.h,'DisplayName','b_d3post')
    lH.errorbars(Avg.iF,nanmean(Avg.bd3post,1),nanstd(Avg.bd3post,1)./sqrt(Avg.nSq),colors(4,:),f4,'b_d3postsd');
end
%
% Plot differences pre/post
f7=getfigH(7);
set(f7,'XScale','log')
ylim([-200 200])
% xlim([.5e0 1e4])
setLabels(f7,'I_{Flash} (cd/m^2)','a_{peak} change (%)')
lH = lineH(Diff.iF,zeros(size(Diff.iF)),f7);
lH.linedash;

if aplot
    lH=lineH(d1Diff.iF,nanmean(d1Diff.ad1,1),f7);
    lH.color(colors(2,:));
    set(lH.h,'DisplayName','a_d1')
    eh=lH.errorfillIgor(d1Diff.iF,nanmean(d1Diff.ad1,1),nanstd(d1Diff.ad1,1)./sqrt(d1Diff.nSq),colors(2,:),f7,'a_d1sd');
end

if vplot
    lH=lineH(Diff.iF,nanmean(Diff.ad1,1),f7);
    lH.color(colors(2,:));
    set(lH.h,'DisplayName','a_d1')
    eh=lH.errorbars(Diff.iF,nanmean(Diff.ad1,1),nanstd(Diff.ad1,1)./sqrt(Diff.nSq),colors(2,:),f7,'a_d1sd');
end

lH=lineH(Diff.iF,nanmean(Diff.ad3,1),f7);
lH.color(colors(4,:));
set(lH.h,'DisplayName','a_d3')
eh=lH.errorbars(Diff.iF,nanmean(Diff.ad3,1),nanstd(Diff.ad3,1)./sqrt(Diff.nSq),colors(4,:),f7,'a_d3sd');


f8=getfigH(8);
set(f8,'XScale','log')
ylim([-200 200])
% xlim([.5e0 1e4])
setLabels(f8,'I_{Flash} (cd/m^2)','b_{peak} change (%)')
lH = lineH(Diff.iF,zeros(size(Diff.iF)),f8);
lH.linedash;

if aplot
    lH=lineH(d1Diff.iF,nanmean(d1Diff.bd1,1),f8);
    lH.color(colors(2,:));
    set(lH.h,'DisplayName','b_d1')
    eh=lH.errorbars(d1Diff.iF,nanmean(d1Diff.bd1,1),nanstd(d1Diff.bd1,1)./sqrt(d1Diff.nSq),colors(2,:),f8,'b_d1sd');
end

if vplot
    lH=lineH(Diff.iF,nanmean(Diff.bd1,1),f8);
    lH.color(colors(2,:));
    set(lH.h,'DisplayName','b_d1')
    eh=lH.errorbars(Diff.iF,nanmean(Diff.bd1,1),nanstd(Diff.bd1,1)./sqrt(Diff.nSq),colors(2,:),f8,'b_d1sd');
end

lH=lineH(Diff.iF,nanmean(Diff.bd3,1),f8);
lH.color(colors(4,:));
set(lH.h,'DisplayName','b_d3')
eh=lH.errorbars(Diff.iF,nanmean(Diff.bd3,1),nanstd(Diff.bd3,1)./sqrt(Diff.nSq),colors(4,:),f8,'b_d3sd');

% Plot differences day1 vs day3
f9=getfigH(9);
set(f9,'XScale','log')
ylim([-200 200])
% xlim([.5e0 1e4])
setLabels(f9,'I_{Flash} (cd/m^2)','a_{peak} change (%)')
lH = lineH(Diff2.iF,zeros(size(Diff2.iF)),f9);
lH.linedash;

if aplot
    lH=lineH(d1Diff2.iF,nanmean(d1Diff2.apre,1),f9);
    lH.color(colors(2,:));
    set(lH.h,'DisplayName','a_pre')
    eh=lH.errorbars(d1Diff2.iF,nanmean(d1Diff2.apre,1),nanstd(d1Diff2.apre,1)./sqrt(d1Diff2.nSq),colors(2,:),f9,'a_presd');
end

if vplot
    lH=lineH(Diff2.iF,nanmean(Diff2.apre,1),f9);
    lH.color(colors(2,:));
    set(lH.h,'DisplayName','a_pre')
    eh=lH.errorbars(Diff2.iF,nanmean(Diff2.apre,1),nanstd(Diff2.apre,1)./sqrt(Diff2.nSq),colors(2,:),f9,'a_presd');
end

lH=lineH(Diff2.iF,nanmean(Diff2.apost,1),f9);
lH.color(colors(4,:));
set(lH.h,'DisplayName','a_post')
eh=lH.errorbars(Diff2.iF,nanmean(Diff2.apost,1),nanstd(Diff2.apost,1)./sqrt(Diff2.nSq),colors(4,:),f9,'a_postsd');


f10=getfigH(10);
set(f10,'XScale','log')
ylim([-200 200])
% xlim([.5e0 1e4])
setLabels(f10,'I_{Flash} (cd/m^2)','b_{peak} change (%)')
lH = lineH(Diff2.iF,zeros(size(Diff2.iF)),f10);
lH.linedash;

if aplot
    lH=lineH(d1Diff2.iF,nanmean(d1Diff2.bpre,1),f10);
    lH.color(colors(2,:));
    set(lH.h,'DisplayName','b_pre')
    eh=lH.errorbars(d1Diff2.iF,nanmean(d1Diff2.bpre,1),nanstd(d1Diff2.bpre,1)./sqrt(d1Diff2.nSq),colors(2,:),f10,'b_presd');
end

if vplot
    lH=lineH(Diff2.iF,nanmean(Diff2.bpre,1),f10);
    lH.color(colors(2,:));
    set(lH.h,'DisplayName','b_pre')
    eh=lH.errorbars(Diff2.iF,nanmean(Diff2.bpre,1),nanstd(Diff2.bpre,1)./sqrt(Diff2.nSq),colors(2,:),f10,'b_presd');
end

lH=lineH(Diff2.iF,nanmean(Diff2.bpost,1),f10);
lH.color(colors(4,:));
set(lH.h,'DisplayName','b_post')
eh=lH.errorbars(Diff2.iF,nanmean(Diff2.bpost,1),nanstd(Diff2.bpost,1)./sqrt(Diff2.nSq),colors(4,:),f10,'b_postsd');

%% stats not done
%% stats: rank sum test (paired data, not normally distributed)
p=struct;
p.avd=NaN(13,1);
p.avbu=NaN(13,1);
p.adbu=NaN(13,1);

p.bvd=NaN(13,1);
p.bvbu=NaN(13,1);
p.bdbu=NaN(13,1);

h=struct;
h.avd=NaN(13,1);
h.avbu=NaN(13,1);
h.adbu=NaN(13,1);

h.bvd=NaN(13,1);
h.bvbu=NaN(13,1);
h.bdbu=NaN(13,1);

for i=2:13
    x=Diff.va(:,i);
    y=Diff.da(:,i);
    [p.avd(i),h.avd(i)]=ranksum(x(~(isnan(x)|isinf(x))), y(~(isnan(y)|isinf(y))));
    
    x=Diff.va(:,i);
    y=Diff.uva(:,i);
    [p.avbu(i),h.avbu(i)]=ranksum(x(~(isnan(x)|isinf(x))), y(~(isnan(y)|isinf(y))));
    
    x=Diff.da(:,i);
    y=Diff.uda(:,i);
    [p.adbu(i),h.adbu(i)]=ranksum(x(~(isnan(x)|isinf(x))), y(~(isnan(y)|isinf(y))));
    
    x=Diff.vb(:,i);
    y=Diff.db(:,i);
    [p.bvd(i),h.bvd(i)]=ranksum(x(~(isnan(x)|isinf(x))), y(~(isnan(y)|isinf(y))));
    
    x=Diff.vb(:,i);
    y=Diff.uvb(:,i);
    [p.bvbu(i),h.bvbu(i)]=ranksum(x(~(isnan(x)|isinf(x))), y(~(isnan(y)|isinf(y))));
    
    x=Diff.db(:,i);
    y=Diff.udb(:,i);
    [p.bdbu(i),h.bdbu(i)]=ranksum(x(~(isnan(x)|isinf(x))), y(~(isnan(y)|isinf(y))));
end





%% iSeries


% iSeries day1 pre-bleaching
hGUI=erg_iseries(Sq(s).d1pre,[],10);drawnow
makeAxisStruct(hGUI.figData.plotR2,sprintf('%s_d1Pre',Avg.id{s}),sprintf('erg/squirrel/invivo/round2/%s',thisone));
% iSeries day2 post-bleaching
hGUI=erg_iseries(Sq(s).d1post,[],10);drawnow
makeAxisStruct(hGUI.figData.plotR2,sprintf('%s_d1Post',Avg.id{s}),sprintf('erg/squirrel/invivo/round2/%s',thisone));
% iSeries day3 pre-bleaching
hGUI=erg_iseries(Sq(s).d3pre,[],10);drawnow
makeAxisStruct(hGUI.figData.plotL2,sprintf('%s_d3Pre',Avg.id{s}),sprintf('erg/squirrel/invivo/round2/%s',thisone));
% iSeries day3 pre-bleaching
hGUI=erg_iseries(Sq(s).d3post,[],10);drawnow
makeAxisStruct(hGUI.figData.plotL2,sprintf('%s_d3Post',Avg.id{s}),sprintf('erg/squirrel/invivo/round2/%s',thisone));

%% legend plots
f9=getfigH(9);

lH=lineH(0,0,f9);
lH.color(colors(1,:));
set(lH.h,'DisplayName','d1pre')
lH=lineH(0,0,f9);
lH.color(colors(2,:));
set(lH.h,'DisplayName','d1post')
lH=lineH(0,0,f9);
lH.color(colors(3,:));
set(lH.h,'DisplayName','d3pre')
lH=lineH(0,0,f9);
lH.color(colors(4,:));
set(lH.h,'DisplayName','d3post')

f11=getfigH(11);

lH=lineH(0,0,f11);
lH.color(colors(2,:));
set(lH.h,'DisplayName','d1')
lH=lineH(0,0,f11);
lH.color(colors(4,:));
set(lH.h,'DisplayName','d3')



f12=getfigH(12);

lH=lineH(0,0,f12);
lH.color(colors(2,:));
set(lH.h,'DisplayName','d1')
lH=lineH(0,0,f12);
lH.color(colors(4,:));
set(lH.h,'DisplayName','d3')

makeAxisStruct(f9,'avg_leg',sprintf('erg/squirrel/invivo/round2'));
makeAxisStruct(f11,'change_leg',sprintf('erg/squirrel/invivo/round2'));
makeAxisStruct(f12,'change_leg2',sprintf('erg/squirrel/invivo/round2'));


%%
%% iSeries all squirrels
%Sq813
    % iSeries vehicle pre-bleaching
    hGUI=erg_iseries(Sq813.vpre,[],10);drawnow
    makeAxisStruct(hGUI.figData.plotL2,'a_vPre813',sprintf('erg/squirrel/invivo/MB001'));
    % iSeries vehicle post-bleaching
    hGUI=erg_iseries(Sq813.vpost,[],10);drawnow
    makeAxisStruct(hGUI.figData.plotL2,'a_vPost813',sprintf('erg/squirrel/invivo/MB001'));
    % iSeries vehicle pre-bleaching
    hGUI=erg_iseries(Sq813.dpre,[],10);drawnow
    makeAxisStruct(hGUI.figData.plotR2,'b_dPre813',sprintf('erg/squirrel/invivo/MB001'));
    % iSeries vehicle pre-bleaching
    hGUI=erg_iseries(Sq813.dpost,[],10);drawnow
    makeAxisStruct(hGUI.figData.plotR2,'b_dPost813',sprintf('erg/squirrel/invivo/MB001'));

%Sq821
    % iSeries vehicle pre-bleaching
    hGUI=erg_iseries(Sq821.vpre,[],10);drawnow
    makeAxisStruct(hGUI.figData.plotL2,'a_vPre821',sprintf('erg/squirrel/invivo/MB001'));
    % iSeries vehicle post-bleaching
    hGUI=erg_iseries(Sq821.vpost,[],10);drawnow
    makeAxisStruct(hGUI.figData.plotL2,'a_vPost821',sprintf('erg/squirrel/invivo/MB001'));
    % iSeries vehicle pre-bleaching
    hGUI=erg_iseries(Sq821.dpre,[],10);drawnow
    makeAxisStruct(hGUI.figData.plotR2,'b_dPre821',sprintf('erg/squirrel/invivo/MB001'));
    % iSeries vehicle pre-bleaching
    hGUI=erg_iseries(Sq821.dpost,[],10);drawnow
    makeAxisStruct(hGUI.figData.plotR2,'b_dPost821',sprintf('erg/squirrel/invivo/MB001'));

%Sq852
    % iSeries vehicle pre-bleaching
    hGUI=erg_iseries(Sq852.vpre,[],10);drawnow
    makeAxisStruct(hGUI.figData.plotL2,'a_vPre852',sprintf('erg/squirrel/invivo/MB001'));
    % iSeries vehicle post-bleaching
    hGUI=erg_iseries(Sq852.vpost,[],10);drawnow
    makeAxisStruct(hGUI.figData.plotL2,'a_vPost852',sprintf('erg/squirrel/invivo/MB001'));
    % iSeries vehicle pre-bleaching
    hGUI=erg_iseries(Sq852.dpre,[],10);drawnow
    makeAxisStruct(hGUI.figData.plotR2,'b_dPre852',sprintf('erg/squirrel/invivo/MB001'));
    % iSeries vehicle pre-bleaching
    hGUI=erg_iseries(Sq852.dpost,[],10);drawnow
    makeAxisStruct(hGUI.figData.plotR2,'b_dPost852',sprintf('erg/squirrel/invivo/MB001'));
    
%Sq922
    % iSeries vehicle pre-bleaching
    hGUI=erg_iseries(Sq922.vpre,[],10);drawnow
    makeAxisStruct(hGUI.figData.plotL2,'a_vPre922',sprintf('erg/squirrel/invivo/MB001'));
    % iSeries vehicle post-bleaching
    hGUI=erg_iseries(Sq922.vpost,[],10);drawnow
    makeAxisStruct(hGUI.figData.plotL2,'a_vPost922',sprintf('erg/squirrel/invivo/MB001'));
    % iSeries vehicle pre-bleaching
    hGUI=erg_iseries(Sq922.dpre,[],10);drawnow
    makeAxisStruct(hGUI.figData.plotR2,'b_dPre922',sprintf('erg/squirrel/invivo/MB001'));
    % iSeries vehicle pre-bleaching
    hGUI=erg_iseries(Sq922.dpost,[],10);drawnow
    makeAxisStruct(hGUI.figData.plotR2,'b_dPost922',sprintf('erg/squirrel/invivo/MB001'));

%%


%%




%%
%%


%% DUMP of old stuff (just in case)
%% This is all outdated
% 
% Sq993=struct;
% dirData='20170829/20170829_Sq993_MB001Low';
% Sq993.d1pre=ERGobj(dirData,'01_IseriesPre');
% Sq993.d1post=ERGobj(dirData,'11_IseriesPost10min_merged');
% dirData='20170831/20170831_Sq993_MB001Low';
% Sq993.d3pre=ERGobj(dirData,'01_IseriesPre');
% Sq993.d3post=ERGobj(dirData,'14_IseriesPost10min');
% Sq993.results.d1pre=Sq993.d1pre.Iseries_abpeaks();
% Sq993.results.d1post=Sq993.d1post.Iseries_abpeaks();
% Sq993.results.d3pre=Sq993.d3pre.Iseries_abpeaks();
% Sq993.results.d3post=Sq993.d3post.Iseries_abpeaks();
% 
% Sq998=struct;
% dirData='20170830/20170830_Sq998_MB001Low';
% Sq998.d1pre=ERGobj(dirData,'01_IseriesPre');
% Sq998.d1post=ERGobj(dirData,'12_IseriesPost');
% dirData='20170901/20170901_Squirrel998_MB001Low';
% Sq998.d3pre=ERGobj(dirData,'01_IseriesPre');
% Sq998.d3post=ERGobj(dirData,'10_IseriesPost10min');
% Sq998.results.d1pre=Sq998.d1pre.Iseries_abpeaks();
% Sq998.results.d1post=Sq998.d1post.Iseries_abpeaks();
% Sq998.results.d3pre=Sq998.d3pre.Iseries_abpeaks();
% Sq998.results.d3post=Sq998.d3post.Iseries_abpeaks();
% 
% 
% Sq1006=struct;
% dirData='20170829/20170829_Sq1006_MB001High';
% Sq1006.d1pre=ERGobj(dirData,'01_IseriesPre_merged');
% Sq1006.d1post=ERGobj(dirData,'11_IseriesPost10min');
% dirData='20170831/20170831_Sq1006_MB001High';
% Sq1006.d3pre=ERGobj(dirData,'01_IseriesPre');
% Sq1006.d3post=ERGobj(dirData,'13_IseriesPost10min_merged');
% Sq1006.results.d1pre=Sq1006.d1pre.Iseries_abpeaks();
% Sq1006.results.d1post=Sq1006.d1post.Iseries_abpeaks();
% Sq1006.results.d3pre=Sq1006.d3pre.Iseries_abpeaks();
% Sq1006.results.d3post=Sq1006.d3post.Iseries_abpeaks();
% 
% Sq928=struct;
% dirData='20170830/20170830_Sq928_MB001High';
% Sq928.d1pre=ERGobj(dirData,'01_IseriesPre');
% Sq928.d1post=ERGobj(dirData,'12_IseriesPost10min');
% dirData='20170901/20170901_Squirrel928_MB001High';
% Sq928.d3pre=ERGobj(dirData,'01_IseriesPre');
% Sq928.d3post=ERGobj(dirData,'01_IseriesPre');
% Sq928.results.d1pre=Sq928.d1pre.Iseries_abpeaks();
% Sq928.results.d1post=Sq928.d1post.Iseries_abpeaks();
% Sq928.results.d3pre=Sq928.d3pre.Iseries_abpeaks();
% Sq928.results.d3post=Sq928.d3post.Iseries_abpeaks();
% 
% Sq1000=struct;
% dirData = '20170829/20170829_Sq1000_Veh';
% Sq1000.d1pre=ERGobj(dirData,'01_IseriesPre');
% Sq1000.d1post=ERGobj(dirData,'10_IseriesPost10min');
% dirData='20170831/20170831_Sq1000_Vehicle';
% Sq1000.d3pre=ERGobj(dirData,'01_IseriesPre');
% Sq1000.d3post=ERGobj(dirData,'13_IseriesPost10min');
% Sq1000.results.d1pre=Sq1000.d1pre.Iseries_abpeaks();
% Sq1000.results.d1post=Sq1000.d1post.Iseries_abpeaks();
% Sq1000.results.d3pre=Sq1000.d3pre.Iseries_abpeaks();
% Sq1000.results.d3post=Sq1000.d3post.Iseries_abpeaks();
% 
% 
% Sq992=struct;
% dirData = '20170830/20170830_Sq992_Veh';
% Sq992.d1pre=ERGobj(dirData,'01_IseriesPre');
% Sq992.d1post=ERGobj(dirData,'12_IseriesPost10min');
% dirData='20170901/20170901_Squirrel992_Vehicle';
% Sq992.d3pre=ERGobj(dirData,'01_IseriesPre');
% Sq992.d3post=ERGobj(dirData,'10_IseriesPost10min');
% Sq992.results.d1pre=Sq992.d1pre.Iseries_abpeaks();
% Sq992.results.d1post=Sq992.d1post.Iseries_abpeaks();
% Sq992.results.d3pre=Sq992.d3pre.Iseries_abpeaks();
% Sq992.results.d3post=Sq992.d3post.Iseries_abpeaks();
% 
% Sq999=struct;
% dirData = '20170905/20170905_Sq999_Vehicle';
% Sq999.d1pre=ERGobj(dirData,'01_IseriesPre');
% Sq999.d1post=ERGobj(dirData,'10_IseriesPost10min20s');
% dirData='20170907/20170907_Sq999_Vehicle';
% Sq999.d3pre=ERGobj(dirData,'01_IseriesPre');
% Sq999.d3post=ERGobj(dirData,'10_IseriesPost10min');
% Sq999.results.d1pre=Sq999.d1pre.Iseries_abpeaks();
% Sq999.results.d1post=Sq999.d1post.Iseries_abpeaks();
% Sq999.results.d3pre=Sq999.d3pre.Iseries_abpeaks();
% Sq999.results.d3post=Sq999.d3post.Iseries_abpeaks();
% 
% 
% Sq990=struct;
% dirData = '20170905/20170905_Sq990_Fenretinide';
% Sq990.d1pre=ERGobj(dirData,'01_IseriesPre');
% Sq990.d1post=ERGobj(dirData,'10_IseriesPost10min');
% dirData='20170907/20170907_Sq990_Fenretinide';
% Sq990.d3pre=ERGobj(dirData,'01_IseriesPre');
% Sq990.d3post=ERGobj(dirData,'10_IseriesPost10min');
% Sq990.results.d1pre=Sq990.d1pre.Iseries_abpeaks();
% Sq990.results.d1post=Sq990.d1post.Iseries_abpeaks();
% Sq990.results.d3pre=Sq990.d3pre.Iseries_abpeaks();
% Sq990.results.d3post=Sq990.d3post.Iseries_abpeaks();
% 
% 
% Sq995=struct;
% dirData = '20170905/20170905_Sq995_Fenretinide';
% Sq995.d1pre=ERGobj(dirData,'01_IseriesPre');
% Sq995.d1post=ERGobj(dirData,'10_IseriesPost10min');
% dirData='20170907/20170907_Sq995_Fenretinide';
% Sq995.d3pre=ERGobj(dirData,'01_IseriesPre');
% Sq995.d3post=ERGobj(dirData,'10_IseriesPost10min');
% Sq995.results.d1pre=Sq995.d1pre.Iseries_abpeaks();
% Sq995.results.d1post=Sq995.d1post.Iseries_abpeaks();
% Sq995.results.d3pre=Sq995.d3pre.Iseries_abpeaks();
% Sq995.results.d3post=Sq995.d3post.Iseries_abpeaks();
%%
%% Collect ratios across intensities
Ratios=struct();
%Fenretinide
Ratios.iF=unique([Sq990.results.d3post.iF, Sq995.results.d3post.iF, ...
    Sq990.results.d1pre.iF, Sq995.results.d1pre.iF]);

nSq = 2;

Ratios.d1a=NaN(nSq,size(Ratios.iF,2));
Ratios.d1b=NaN(nSq,size(Ratios.iF,2));
Ratios.d3a=NaN(nSq,size(Ratios.iF,2));
Ratios.d3b=NaN(nSq,size(Ratios.iF,2));

Ratios.ud1a=NaN(nSq,size(Ratios.iF,2));
Ratios.ud1b=NaN(nSq,size(Ratios.iF,2));
Ratios.ud3a=NaN(nSq,size(Ratios.iF,2));
Ratios.ud3b=NaN(nSq,size(Ratios.iF,2));

for i=1:length(Ratios.iF);
    %Sq990
    i_pre=find(Sq990.results.d1pre.iF==Ratios.iF(i));
    i_post=find(Sq990.results.d1post.iF==Ratios.iF(i));
    if ~isempty(i_pre) && ~isempty(i_post)
        Ratios.d1a(1,i)= Sq990.results.d1pre.Ra_peak(i_pre)/Sq990.results.d1post.Ra_peak(i_post);
        Ratios.d1b(1,i)= Sq990.results.d1pre.Rb_peak(i_pre)/Sq990.results.d1post.Rb_peak(i_post);
        
        Ratios.ud1a(1,i)= Sq990.results.d1pre.La_peak(i_pre)/Sq990.results.d1post.La_peak(i_post);
        Ratios.ud1b(1,i)= Sq990.results.d1pre.Lb_peak(i_pre)/Sq990.results.d1post.Lb_peak(i_post);
    end
    i_pre=find(Sq990.results.d3pre.iF==Ratios.iF(i));
    i_post=find(Sq990.results.d3post.iF==Ratios.iF(i));
    if ~isempty(i_pre) && ~isempty(i_post)
        Ratios.d3a(1,i)= Sq990.results.d3pre.Ra_peak(i_pre)/Sq990.results.d3post.Ra_peak(i_post);
        Ratios.d3b(1,i)= Sq990.results.d3pre.Rb_peak(i_pre)/Sq990.results.d3post.Rb_peak(i_post);
        
        Ratios.ud3a(1,i)= Sq990.results.d3pre.La_peak(i_pre)/Sq990.results.d3post.La_peak(i_post);
        Ratios.ud3b(1,i)= Sq990.results.d3pre.Lb_peak(i_pre)/Sq990.results.d3post.Lb_peak(i_post);
    end
    
    %Sq995
    i_pre=find(Sq995.results.d1pre.iF==Ratios.iF(i));
    i_post=find(Sq995.results.d1post.iF==Ratios.iF(i));
    if ~isempty(i_pre) && ~isempty(i_post)
        Ratios.d1a(2,i)= Sq995.results.d1pre.Ra_peak(i_pre)/Sq995.results.d1post.Ra_peak(i_post);
        Ratios.d1b(2,i)= Sq995.results.d1pre.Rb_peak(i_pre)/Sq995.results.d1post.Rb_peak(i_post);
        
        Ratios.ud1a(2,i)= Sq995.results.d1pre.La_peak(i_pre)/Sq995.results.d1post.La_peak(i_post);
        Ratios.ud1b(2,i)= Sq995.results.d1pre.Lb_peak(i_pre)/Sq995.results.d1post.Lb_peak(i_post);
    end
    i_pre=find(Sq995.results.d3pre.iF==Ratios.iF(i));
    i_post=find(Sq995.results.d3post.iF==Ratios.iF(i));
    if ~isempty(i_pre) && ~isempty(i_post)
        Ratios.d3a(2,i)= Sq995.results.d3pre.Ra_peak(i_pre)/Sq995.results.d3post.Ra_peak(i_post);
        Ratios.d3b(2,i)= Sq995.results.d3pre.Rb_peak(i_pre)/Sq995.results.d3post.Rb_peak(i_post);
        
        Ratios.ud3a(2,i)= Sq995.results.d3pre.La_peak(i_pre)/Sq995.results.d3post.La_peak(i_post);
        Ratios.ud3b(2,i)= Sq995.results.d3pre.Lb_peak(i_pre)/Sq995.results.d3post.Lb_peak(i_post);
    end
end

% Plot ratios pre/post
f5=getfigH(5);
set(f5,'XScale','log')
setLabels(f5,'I_{Flash} (cd/m^2)','Ratio pre/post a_{peak} (\muV)')
f5.YLim=[0 3];
lH = lineH(Sq990.results.d1pre.iF,ones(size(Sq990.results.d1pre.iF)),f5); %Unity line
lH.linedash;


lH=lineH(Ratios.iF,nanmean(Ratios.d1a,1),f5);
lH.color([0 0 0]);
set(lH.h,'DisplayName','a_d1')
eh=lH.errorbars(Ratios.iF,nanmean(Ratios.d1a,1),nanstd(Ratios.d1a,1)./sqrt(nSq),[0 0 0],f5,'a_d1sd');

lH=lineH(Ratios.iF,nanmean(Ratios.ud1a,1),f5);
lH.color([.5 .5 .5]);lH.openmarkers;
set(lH.h,'DisplayName','a_d1_u')
eh=lH.errorbars(Ratios.iF,nanmean(Ratios.ud1a,1),nanstd(Ratios.ud1a,1)./sqrt(nSq),[.5 .5 .5],f5,'a_d1sd_u');

lH=lineH(Ratios.iF,nanmean(Ratios.d3a,1),f5);
lH.color([1 0 0]);
set(lH.h,'DisplayName','a_d3')
eh=lH.errorbars(Ratios.iF,nanmean(Ratios.d3a,1),nanstd(Ratios.d3a,1)./sqrt(nSq),[1 0 0],f5,'a_drugsd');

lH=lineH(Ratios.iF,nanmean(Ratios.ud3a,1),f5);
lH.color([1 .5 .5]);lH.openmarkers;
set(lH.h,'DisplayName','a_d3_u')
eh=lH.errorbars(Ratios.iF,nanmean(Ratios.ud3a,1),nanstd(Ratios.ud3a,1)./sqrt(nSq),[1 .5 .5],f5,'a_d3sd_u');

f6=getfigH(6);
set(f6,'XScale','log')
setLabels(f6,'I_{Flash} (cd/m^2)','Ratio pre/post b_{peak} (\muV)')
f6.YLim=[0 3];
lH = lineH(Sq990.results.d1pre.iF,ones(size(Sq990.results.d1pre.iF)),f6); %Unity line
lH.linedash;


lH=lineH(Ratios.iF,nanmean(Ratios.d1b,1),f6);
lH.color([0 0 0]);
set(lH.h,'DisplayName','b_d1')
eh=lH.errorbars(Ratios.iF,nanmean(Ratios.d1b,1),nanstd(Ratios.d1b,1)./sqrt(nSq),[0 0 0],f6,'b_d1');

lH=lineH(Ratios.iF,nanmean(Ratios.ud1b,1),f6);
lH.color([.5 .5 .5]);lH.openmarkers;
set(lH.h,'DisplayName','b_d1_u')
eh=lH.errorbars(Ratios.iF,nanmean(Ratios.ud1b,1),nanstd(Ratios.ud1b,1)./sqrt(nSq),[.5 .5 .5],f6,'b_d1sd_u');

lH=lineH(Ratios.iF,nanmean(Ratios.d3b,1),f6);
lH.color([1 0 0]);
set(lH.h,'DisplayName','b_d3')
eh=lH.errorbars(Ratios.iF,nanmean(Ratios.d3b,1),nanstd(Ratios.d3b,1)./sqrt(nSq),[1 0 0],f6,'b_d3sd');

lH=lineH(Ratios.iF,nanmean(Ratios.ud3b,1),f6);
lH.color([1 .5 .5]);lH.openmarkers;
set(lH.h,'DisplayName','b_d3_u')
eh=lH.errorbars(Ratios.iF,nanmean(Ratios.ud3b,1),nanstd(Ratios.ud3b,1)./sqrt(nSq),[1 .5 .5],f6,'b_d3sd_u');
%% stats not modified
%% stats: rank sum test (paired data, not normally distributed)
p=struct;
p.avd=NaN(13,1);
p.avbu=NaN(13,1);
p.adbu=NaN(13,1);

p.bvd=NaN(13,1);
p.bvbu=NaN(13,1);
p.bdbu=NaN(13,1);

h=struct;
h.avd=NaN(13,1);
h.avbu=NaN(13,1);
h.adbu=NaN(13,1);

h.bvd=NaN(13,1);
h.bvbu=NaN(13,1);
h.bdbu=NaN(13,1);

for i=2:13
    x=Ratios.va(:,i);
    y=Ratios.da(:,i);
    [p.avd(i),h.avd(i)]=ranksum(x(~isnan(x)), y(~isnan(y)));
    
    x=Ratios.va(:,i);
    y=Ratios.uva(:,i);
    [p.avbu(i),h.avbu(i)]=ranksum(x(~isnan(x)), y(~isnan(y)));
    
    x=Ratios.da(:,i);
    y=Ratios.uda(:,i);
    [p.adbu(i),h.adbu(i)]=ranksum(x(~isnan(x)), y(~isnan(y)));
    
    x=Ratios.vb(:,i);
    y=Ratios.db(:,i);
    [p.bvd(i),h.bvd(i)]=ranksum(x(~isnan(x)), y(~isnan(y)));
    
    x=Ratios.vb(:,i);
    y=Ratios.uvb(:,i);
    [p.bvbu(i),h.bvbu(i)]=ranksum(x(~isnan(x)), y(~isnan(y)));
    
    x=Ratios.db(:,i);
    y=Ratios.udb(:,i);
    [p.bdbu(i),h.bdbu(i)]=ranksum(x(~isnan(x)), y(~isnan(y)));
end
%%
%% Collect percent differences across intensities (using this one for paper)
% Diff=struct();
% %Fenretinide
% Diff.iF=unique([Sq990.results.d3post.iF, Sq995.results.d3post.iF, ...
%     Sq990.results.d1pre.iF, Sq995.results.d1pre.iF]);
% nSq=2;
% 
% 
% Diff.d1a=NaN(nSq,size(Diff.iF,2));
% Diff.d1b=NaN(nSq,size(Diff.iF,2));
% Diff.d3a=NaN(nSq,size(Diff.iF,2));
% Diff.d3b=NaN(nSq,size(Diff.iF,2));
% 
% Diff.ud1a=NaN(nSq,size(Diff.iF,2));
% Diff.ud1b=NaN(nSq,size(Diff.iF,2));
% Diff.ud3a=NaN(nSq,size(Diff.iF,2));
% Diff.ud3b=NaN(nSq,size(Diff.iF,2));
% 
% for i=1:length(Diff.iF);
%     %Sq990
%     i_pre=find(Sq990.results.d1pre.iF==Diff.iF(i));
%     i_post=find(Sq990.results.d1post.iF==Diff.iF(i));
%     if ~isempty(i_pre) && ~isempty(i_post)
%         Diff.d1a(1,i)= 100*(Sq990.results.d1pre.Ra_peak(i_pre)-Sq990.results.d1post.Ra_peak(i_post))./Sq990.results.d1pre.Ra_peak(i_pre);
%         Diff.d1b(1,i)= 100*(Sq990.results.d1pre.Rb_peak(i_pre)-Sq990.results.d1post.Rb_peak(i_post))./Sq990.results.d1pre.Ra_peak(i_pre);
%         
%         Diff.ud1a(1,i)= 100*(Sq990.results.d1pre.La_peak(i_pre)-Sq990.results.d1post.La_peak(i_post))./Sq990.results.d3pre.La_peak(i_pre);
%         Diff.ud1b(1,i)= 100*(Sq990.results.d1pre.Lb_peak(i_pre)-Sq990.results.d1post.Lb_peak(i_post))./Sq990.results.d3pre.La_peak(i_pre);
%     end
%     i_pre=find(Sq990.results.d3pre.iF==Diff.iF(i));
%     i_post=find(Sq990.results.d3post.iF==Diff.iF(i));
%     if ~isempty(i_pre) && ~isempty(i_post)
%         Diff.d3a(1,i)= 100*(Sq990.results.d3pre.Ra_peak(i_pre)-Sq990.results.d3post.Ra_peak(i_post))./Sq990.results.d1pre.Ra_peak(i_pre);
%         Diff.d3b(1,i)= 100*(Sq990.results.d3pre.Rb_peak(i_pre)-Sq990.results.d3post.Rb_peak(i_post))./Sq990.results.d1pre.Ra_peak(i_pre);
%         
%         Diff.ud3a(1,i)= 100*(Sq990.results.d3pre.La_peak(i_pre)-Sq990.results.d3post.La_peak(i_post))./Sq990.results.d3pre.La_peak(i_pre);
%         Diff.ud3b(1,i)= 100*(Sq990.results.d3pre.Lb_peak(i_pre)-Sq990.results.d3post.Lb_peak(i_post))./Sq990.results.d3pre.La_peak(i_pre);
%     end
%     
%     %Sq995
%     i_pre=find(Sq995.results.d1pre.iF==Diff.iF(i));
%     i_post=find(Sq995.results.d1post.iF==Diff.iF(i));
%     if ~isempty(i_pre) && ~isempty(i_post)
%         Diff.d1a(2,i)= 100*(Sq995.results.d1pre.Ra_peak(i_pre)-Sq995.results.d1post.Ra_peak(i_post))./Sq995.results.d1pre.Ra_peak(i_pre);
%         Diff.d1b(2,i)= 100*(Sq995.results.d1pre.Rb_peak(i_pre)-Sq995.results.d1post.Rb_peak(i_post))./Sq995.results.d1pre.Ra_peak(i_pre);
%         
%         Diff.ud1a(2,i)= 100*(Sq995.results.d1pre.La_peak(i_pre)-Sq995.results.d1post.La_peak(i_post))./Sq995.results.d3pre.La_peak(i_pre);
%         Diff.ud1b(2,i)= 100*(Sq995.results.d1pre.Lb_peak(i_pre)-Sq995.results.d1post.Lb_peak(i_post))./Sq995.results.d3pre.La_peak(i_pre);
%     end
%     i_pre=find(Sq995.results.d3pre.iF==Diff.iF(i));
%     i_post=find(Sq995.results.d3post.iF==Diff.iF(i));
%     if ~isempty(i_pre) && ~isempty(i_post)
%         Diff.d3a(2,i)= 100*(Sq995.results.d3pre.Ra_peak(i_pre)-Sq995.results.d3post.Ra_peak(i_post))./Sq995.results.d1pre.Ra_peak(i_pre);
%         Diff.d3b(2,i)= 100*(Sq995.results.d3pre.Rb_peak(i_pre)-Sq995.results.d3post.Rb_peak(i_post))./Sq995.results.d1pre.Ra_peak(i_pre);
%         
%         Diff.ud3a(2,i)= 100*(Sq995.results.d3pre.La_peak(i_pre)-Sq995.results.d3post.La_peak(i_post))./Sq995.results.d3pre.La_peak(i_pre);
%         Diff.ud3b(2,i)= 100*(Sq995.results.d3pre.Lb_peak(i_pre)-Sq995.results.d3post.Lb_peak(i_post))./Sq995.results.d3pre.La_peak(i_pre);
%     end
%     
%    
% end
%%
%% Collect absolute differences across intensities
Diff=struct();
Diff.iF=unique([Sq813.results.vpost.iF, Sq821.results.vpost.iF, Sq852.results.vpost.iF, Sq922.results.vpost.iF, ...
    Sq813.results.dpre.iF, Sq821.results.dpre.iF, Sq852.results.dpost.iF, Sq922.results.dpost.iF]);

Diff.va=NaN(nSq,size(Diff.iF,2));
Diff.vb=NaN(nSq,size(Diff.iF,2));
Diff.da=NaN(nSq,size(Diff.iF,2));
Diff.db=NaN(nSq,size(Diff.iF,2));

Diff.uva=NaN(nSq,size(Diff.iF,2));
Diff.uvb=NaN(nSq,size(Diff.iF,2));
Diff.uda=NaN(nSq,size(Diff.iF,2));
Diff.udb=NaN(nSq,size(Diff.iF,2));

for i=1:length(Diff.iF);
    %Sq813
    i_pre=find(Sq813.results.vpre.iF==Diff.iF(i));
    i_post=find(Sq813.results.vpost.iF==Diff.iF(i));
    if ~isempty(i_pre) && ~isempty(i_post)
        Diff.va(1,i)= Sq813.results.vpre.a_peak(i_pre)-Sq813.results.vpost.a_peak(i_post);
        Diff.vb(1,i)= Sq813.results.vpre.b_peak(i_pre)-Sq813.results.vpost.b_peak(i_post);
        
        Diff.uva(1,i)= Sq813.results.vpre.ua_peak(i_pre)-Sq813.results.vpost.ua_peak(i_post);
        Diff.uvb(1,i)= Sq813.results.vpre.ub_peak(i_pre)-Sq813.results.vpost.ub_peak(i_post);
    end
    i_pre=find(Sq813.results.dpre.iF==Diff.iF(i));
    i_post=find(Sq813.results.dpost.iF==Diff.iF(i));
    if ~isempty(i_pre) && ~isempty(i_post)
        Diff.da(1,i)= Sq813.results.dpre.a_peak(i_pre)-Sq813.results.dpost.a_peak(i_post);
        Diff.db(1,i)= Sq813.results.dpre.b_peak(i_pre)-Sq813.results.dpost.b_peak(i_post);
        
        Diff.uda(1,i)= Sq813.results.dpre.ua_peak(i_pre)-Sq813.results.dpost.ua_peak(i_post);
        Diff.udb(1,i)= Sq813.results.dpre.ub_peak(i_pre)-Sq813.results.dpost.ub_peak(i_post);
    end
    
    %Sq821
    i_pre=find(Sq821.results.vpre.iF==Diff.iF(i));
    i_post=find(Sq821.results.vpost.iF==Diff.iF(i));
    if ~isempty(i_pre) && ~isempty(i_post)
        Diff.va(2,i)= Sq821.results.vpre.a_peak(i_pre)-Sq821.results.vpost.a_peak(i_post);
        Diff.vb(2,i)= Sq821.results.vpre.b_peak(i_pre)-Sq821.results.vpost.b_peak(i_post);
        
        Diff.uva(2,i)= Sq821.results.vpre.ua_peak(i_pre)-Sq821.results.vpost.ua_peak(i_post);
        Diff.uvb(2,i)= Sq821.results.vpre.ub_peak(i_pre)-Sq821.results.vpost.ub_peak(i_post);
    end
    i_pre=find(Sq821.results.dpre.iF==Diff.iF(i));
    i_post=find(Sq821.results.dpost.iF==Diff.iF(i));
    if ~isempty(i_pre) && ~isempty(i_post)
        Diff.da(2,i)= Sq821.results.dpre.a_peak(i_pre)-Sq821.results.dpost.a_peak(i_post);
        Diff.db(2,i)= Sq821.results.dpre.b_peak(i_pre)-Sq821.results.dpost.b_peak(i_post);
        
        Diff.uda(2,i)= Sq821.results.dpre.ua_peak(i_pre)-Sq821.results.dpost.ua_peak(i_post);
        Diff.udb(2,i)= Sq821.results.dpre.ub_peak(i_pre)-Sq821.results.dpost.ub_peak(i_post);
    end
    
    %Sq852
    i_pre=find(Sq852.results.vpre.iF==Diff.iF(i));
    i_post=find(Sq852.results.vpost.iF==Diff.iF(i));
    if ~isempty(i_pre) && ~isempty(i_post)
        Diff.va(3,i)= Sq852.results.vpre.a_peak(i_pre)-Sq852.results.vpost.a_peak(i_post);
        Diff.vb(3,i)= Sq852.results.vpre.b_peak(i_pre)-Sq852.results.vpost.b_peak(i_post);
        
        Diff.uva(3,i)= Sq852.results.vpre.ua_peak(i_pre)-Sq852.results.vpost.ua_peak(i_post);
        Diff.uvb(3,i)= Sq852.results.vpre.ub_peak(i_pre)-Sq852.results.vpost.ub_peak(i_post);
    end
    i_pre=find(Sq852.results.dpre.iF==Diff.iF(i));
    i_post=find(Sq852.results.dpost.iF==Diff.iF(i));
    if ~isempty(i_pre) && ~isempty(i_post)
        Diff.da(3,i)= Sq852.results.dpre.a_peak(i_pre)-Sq852.results.dpost.a_peak(i_post);
        Diff.db(3,i)= Sq852.results.dpre.b_peak(i_pre)-Sq852.results.dpost.b_peak(i_post);
        
        Diff.uda(3,i)= Sq852.results.dpre.ua_peak(i_pre)-Sq852.results.dpost.ua_peak(i_post);
        Diff.udb(3,i)= Sq852.results.dpre.ub_peak(i_pre)-Sq852.results.dpost.ub_peak(i_post);
    end
    
    %Sq922
    i_pre=find(Sq922.results.vpre.iF==Diff.iF(i));
    i_post=find(Sq922.results.vpost.iF==Diff.iF(i));
    if ~isempty(i_pre) && ~isempty(i_post)
        Diff.va(4,i)= Sq922.results.vpre.a_peak(i_pre)-Sq922.results.vpost.a_peak(i_post);
        Diff.vb(4,i)= Sq922.results.vpre.b_peak(i_pre)-Sq922.results.vpost.b_peak(i_post);
        
        Diff.uva(4,i)= Sq922.results.vpre.ua_peak(i_pre)-Sq922.results.vpost.ua_peak(i_post);
        Diff.uvb(4,i)= Sq922.results.vpre.ub_peak(i_pre)-Sq922.results.vpost.ub_peak(i_post);
    end
    i_pre=find(Sq922.results.dpre.iF==Diff.iF(i));
    i_post=find(Sq922.results.dpost.iF==Diff.iF(i));
    if ~isempty(i_pre) && ~isempty(i_post)
        Diff.da(4,i)= Sq922.results.dpre.a_peak(i_pre)-Sq922.results.dpost.a_peak(i_post);
        Diff.db(4,i)= Sq922.results.dpre.b_peak(i_pre)-Sq922.results.dpost.b_peak(i_post);
        
        Diff.uda(4,i)= Sq922.results.dpre.ua_peak(i_pre)-Sq922.results.dpost.ua_peak(i_post);
        Diff.udb(4,i)= Sq922.results.dpre.ub_peak(i_pre)-Sq922.results.dpost.ub_peak(i_post);
    end
end
%%
%% Plot ratios pre/post
f5=getfigH(5);
set(f5,'XScale','log')
setLabels(f5,'I_{Flash} (cd/m^2)','Diff pre-post a_{peak} (\muV)')
lH = lineH(Sq821.results.vpre.iF,ones(size(Sq821.results.vpre.iF)),f5);
lH.linedash;


lH=lineH(Diff.iF,nanmean(Diff.va,1),f5);
lH.color([0 0 0]);
set(lH.h,'DisplayName','a_veh')
eh=lH.errorbars(Diff.iF,nanmean(Diff.va,1),nanstd(Diff.va,1)./sqrt(nSq),[0 0 0],f5,'a_vehsd');

% lH=lineH(Diff.iF,nanmean(Diff.uva,1),f5);
% lH.color([.5 .5 .5]);lH.openmarkers;
% set(lH.h,'DisplayName','a_veh_unbleached')
% eh=lH.errorbars(Diff.iF,nanmean(Diff.uva,1),nanstd(Diff.uva,1)./sqrt(nSq),[.5 .5 .5],f5,'a_vehsd_unbleached');

lH=lineH(Diff.iF,nanmean(Diff.da,1),f5);
lH.color([1 0 0]);
set(lH.h,'DisplayName','a_drug')
eh=lH.errorbars(Diff.iF,nanmean(Diff.da,1),nanstd(Diff.da,1)./sqrt(nSq),[1 0 0],f5,'a_drugsd');

% lH=lineH(Diff.iF,nanmean(Diff.uda,1),f5);
% lH.color([1 .5 .5]);lH.openmarkers;
% set(lH.h,'DisplayName','a_drug_unbleached')
% eh=lH.errorbars(Diff.iF,nanmean(Diff.uda,1),nanstd(Diff.uda,1)./sqrt(nSq),[1 .5 .5],f5,'a_drugsd_unbleached');

f6=getfigH(6);
set(f6,'XScale','log')
setLabels(f6,'I_{Flash} (cd/m^2)','Ratio pre/post b_{peak} (\muV)')
lH = lineH(Sq821.results.vpre.iF,ones(size(Sq821.results.vpre.iF)),f6);
lH.linedash;


lH=lineH(Diff.iF,nanmean(Diff.vb,1),f6);
lH.color([0 0 0]);
set(lH.h,'DisplayName','a_veh')
eh=lH.errorbars(Diff.iF,nanmean(Diff.vb,1),nanstd(Diff.vb,1)./sqrt(nSq),[0 0 0],f6,'a_vehsd');

% lH=lineH(Diff.iF,nanmean(Diff.uvb,1),f6);
% lH.color([.5 .5 .5]);lH.openmarkers;
% set(lH.h,'DisplayName','a_veh_unbleached')
% eh=lH.errorbars(Diff.iF,nanmean(Diff.uvb,1),nanstd(Diff.uvb,1)./sqrt(nSq),[.5 .5 .5],f6,'a_vehsd_unbleached');

lH=lineH(Diff.iF,nanmean(Diff.db,1),f6);
lH.color([1 0 0]);
set(lH.h,'DisplayName','a_drug')
eh=lH.errorbars(Diff.iF,nanmean(Diff.db,1),nanstd(Diff.db,1)./sqrt(nSq),[1 0 0],f6,'a_drugsd');

% lH=lineH(Diff.iF,nanmean(Diff.udb,1),f6);
% lH.color([1 .5 .5]);lH.openmarkers;
% set(lH.h,'DisplayName','a_drug_unbleached')
% eh=lH.errorbars(Diff.iF,nanmean(Diff.udb,1),nanstd(Diff.udb,1)./sqrt(nSq),[1 .5 .5],f6,'a_drugsd_unbleached');
%% stats: rank sum test (paired data, not normally distributed)
pDiff=struct;
pDiff.avd=NaN(13,1);
pDiff.avbu=NaN(13,1);
pDiff.adbu=NaN(13,1);

pDiff.bvd=NaN(13,1);
pDiff.bvbu=NaN(13,1);
pDiff.bdbu=NaN(13,1);

hDiff=struct;
hDiff.avd=NaN(13,1);
hDiff.avbu=NaN(13,1);
hDiff.adbu=NaN(13,1);

hDiff.bvd=NaN(13,1);
hDiff.bvbu=NaN(13,1);
hDiff.bdbu=NaN(13,1);

for i=2:13
    x=Diff.va(:,i);
    y=Diff.da(:,i);
    [pDiff.avd(i),hDiff.avd(i)]=ranksum(x(~isnan(x)), y(~isnan(y)));
    
    x=Diff.va(:,i);
    y=Diff.uva(:,i);
    [pDiff.avbu(i),hDiff.avbu(i)]=ranksum(x(~isnan(x)), y(~isnan(y)));
    
    x=Diff.da(:,i);
    y=Diff.uda(:,i);
    [pDiff.adbu(i),hDiff.adbu(i)]=ranksum(x(~isnan(x)), y(~isnan(y)));
    
    x=Diff.vb(:,i);
    y=Diff.db(:,i);
    [pDiff.bvd(i),hDiff.bvd(i)]=ranksum(x(~isnan(x)), y(~isnan(y)));
    
    x=Diff.vb(:,i);
    y=Diff.uvb(:,i);
    [pDiff.bvbu(i),hDiff.bvbu(i)]=ranksum(x(~isnan(x)), y(~isnan(y)));
    
    x=Diff.db(:,i);
    y=Diff.udb(:,i);
    [pDiff.bdbu(i),hDiff.bdbu(i)]=ranksum(x(~isnan(x)), y(~isnan(y)));
end
