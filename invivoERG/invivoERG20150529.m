function invivoERG20150529()
%%
clear; startup;

%% Xenon flashes
load('/Users/angueyraaristjm/Documents/LiData/invivoERG/erg20150529_Xe.mat')
% run2-12 is Iseries
colors=pmkmp(11,'CubicLQuarter');
f1=getfigH(1);
xlim([0 150])
ylim([-400 700])
f2=getfigH(2);
xlim([0 150])
ylim([-400 700])

f3=getfigH(3);
set(f3,'xscale','log')
f4=getfigH(4);
set(f4,'xscale','log')

clear apeak* bpeak*
cnt=0;
for r=2:12
    cnt=cnt+1;
    runname=sprintf('run%02g',r);
    
    lH=line(erg.(runname).t,mean(erg.(runname).l,2),'Parent',f1);
    set(lH,'Marker','none','LineStyle','-','LineWidth',1,'Color',colors(cnt,:))
    
    lH=line(erg.(runname).t,mean(erg.(runname).r,2),'Parent',f2);
    set(lH,'Marker','none','LineStyle','-','LineWidth',1,'Color',colors(cnt,:))
   
    apeakl(cnt)=-min(mean(erg.(runname).l,2));
    bpeakl(cnt)=max(mean(erg.(runname).l,2));
    apeakr(cnt)=-min(mean(erg.(runname).r,2));
    bpeakr(cnt)=max(mean(erg.(runname).r,2));
end

If=[0.01,0.03,0.1,0.3,1,3,10,30,100,300,1000];

lH=line(If,apeakl,'Parent',f3);
set(lH,'Marker','o','LineStyle','none','LineWidth',1,'Color','k')
lH=line(If,apeakr,'Parent',f4);
set(lH,'Marker','o','LineStyle','none','LineWidth',1,'Color','k')

lH=line(If,bpeakl,'Parent',f3);
set(lH,'Marker','o','LineStyle','none','LineWidth',1,'Color','b')
lH=line(If,bpeakr,'Parent',f4);
set(lH,'Marker','o','LineStyle','none','LineWidth',1,'Color','b')

%% Green LED flashes
g=load('/Users/angueyraaristjm/Documents/LiData/invivoERG/erg20150529_Green.mat');
% run1-7 is Iseries
erg_g=g.erg;
colors=pmkmp(11,'CubicLQuarter');
f1=getfigH(1);
xlim([0 150])
ylim([-400 700])
f2=getfigH(2);
xlim([0 150])
ylim([-400 700])

% f3=getfigH(3);
% set(f3,'xscale','log')
% f4=getfigH(4);
% set(f4,'xscale','log')

apeakl_g=NaN(7,1);
bpeakl_g=NaN(7,1);
apeakr_g=NaN(7,1);
bpeakr_g=NaN(7,1);
cnt=0;
for r=1:7
    cnt=cnt+1;
    runname=sprintf('run%02g',r);
    
    lH=line(erg_g.(runname).t,mean(erg_g.(runname).l,2),'Parent',f1);
    set(lH,'Marker','none','LineStyle','-','LineWidth',1,'Color',colors(cnt,:))
    
    lH=line(erg_g.(runname).t,mean(erg_g.(runname).r,2),'Parent',f2);
    set(lH,'Marker','none','LineStyle','-','LineWidth',1,'Color',colors(cnt,:))
   
    apeakl_g(cnt)=-min(mean(erg_g.(runname).l,2));
    bpeakl_g(cnt)=max(mean(erg_g.(runname).l,2));
    apeakr_g(cnt)=-min(mean(erg_g.(runname).r,2));
    bpeakr_g(cnt)=max(mean(erg_g.(runname).r,2));
end

If_g=[0.01,0.03,0.1,0.3,1,3,10];

lH=line(If_g,apeakl_g,'Parent',f3);
set(lH,'Marker','x','LineStyle','none','LineWidth',1,'Color','k')
lH=line(If_g,apeakr_g,'Parent',f4);
set(lH,'Marker','x','LineStyle','none','LineWidth',1,'Color','k')

lH=line(If_g,bpeakl_g,'Parent',f3);
set(lH,'Marker','x','LineStyle','none','LineWidth',1,'Color','b')
lH=line(If_g,bpeakr_g,'Parent',f4);
set(lH,'Marker','x','LineStyle','none','LineWidth',1,'Color','b')
