function invivoERG20160605()
%%
clear; startup;
load('/Users/angueyraaristjm/Documents/LiData/invivoERG/erg20150605.mat')


%% run1-9 is Iseries before bleaching
colors=pmkmp(9,'CubicLQuarter');
f1=getfigH(1);
xlim([0 150])
ylim([-200 500])
f2=getfigH(2);
xlim([0 150])
ylim([-200 500])

f3=getfigH(3);
f4=getfigH(4);

for r=1:9
    runname=sprintf('run%02g',r);
    
    lH=line(erg.(runname).t,mean(erg.(runname).l,2),'Parent',f1);
    set(lH,'Marker','none','LineStyle','-','LineWidth',1,'Color',colors(r,:))
    
    lH=line(erg.(runname).t,mean(erg.(runname).r,2),'Parent',f2);
    set(lH,'Marker','none','LineStyle','-','LineWidth',1,'Color',colors(r,:))
   
    apeakl(r)=-min(mean(erg.(runname).l,2));
    bpeakl(r)=max(mean(erg.(runname).l,2));
    apeakr(r)=-min(mean(erg.(runname).r,2));
    bpeakr(r)=max(mean(erg.(runname).r,2));
end

lH=line(1:9,apeakl,'Parent',f3);
set(lH,'Marker','o','LineStyle','none','LineWidth',1,'Color','k')
lH=line(1:9,apeakr,'Parent',f4);
set(lH,'Marker','o','LineStyle','none','LineWidth',1,'Color','k')

lH=line(1:9,bpeakl,'Parent',f3);
set(lH,'Marker','o','LineStyle','none','LineWidth',1,'Color','b')
lH=line(1:9,bpeakr,'Parent',f4);
set(lH,'Marker','o','LineStyle','none','LineWidth',1,'Color','b')

%% run10 is bleach/recovery 2x runs (but where did bleach happen?)
runname='run10';
nEp=size(erg.(runname).l,2);
nEp=28;
colors=pmkmp(nEp,'CubicL');

f1=getfigH(1);
% xlim([0 150])
ylim([-300 600])

f2=getfigH(2);
% xlim([0 150])
ylim([-300 600])

for i=[1:nEp]%nEp
    lH(i)=line(erg.(runname).t,erg.(runname).l(:,i),'Parent',f1);
    set(lH(i),'Marker','none','LineStyle','-','LineWidth',1,'Color',colors(i,:))
    
    lH(i)=line(erg.(runname).t,erg.(runname).r(:,i),'Parent',f2);
    set(lH(i),'Marker','none','LineStyle','-','LineWidth',1,'Color',colors(i,:))
%     i
%     pause
end

f3=getfigH(3);
lH(i)=line(1:nEp,min(erg.(runname).l(:,1:nEp)),'Parent',f3);
set(lH(i),'Marker','.','LineStyle','none','LineWidth',1,'Color','k')

f4=getfigH(4);
lH(i)=line(1:nEp,min(erg.(runname).r(:,1:nEp)),'Parent',f4);
set(lH(i),'Marker','.','LineStyle','none','LineWidth',1,'Color','k')

%% run 13 is 1s steps

f1=getfigH(1);
xlabel('Time (s)')
ylabel('TRP (uV)')
% xlim([0 150])
% ylim([-300 600])
f2=getfigH(2);
xlabel('Time (s)')
ylabel('TRP (uV)')
% xlim([0 150])
% ylim([-300 600])

for r=13
    runname=sprintf('run%02g',r);
    colors=pmkmp(size(erg.run13.l,2),'CubicLQuarter');
    for i=1:size(erg.run13.l,2)
        lHl=line(erg.(runname).t./1000,erg.(runname).l(:,i),'Parent',f1);
        set(lHl,'Marker','none','LineStyle','-','LineWidth',1,'Color','k')
        lHr=line(erg.(runname).t./1000,erg.(runname).r(:,i),'Parent',f2);
        set(lHr,'Marker','none','LineStyle','-','LineWidth',1,'Color','k')
    end
end

f3=getfigH(3);
stim=zeros(size(erg.(runname).t./1000));
stim(erg.(runname).t./1000>0 & erg.(runname).t./1000<=1)=1;
lHl=line(erg.(runname).t./1000,stim,'Parent',f3);
set(lHl,'Marker','none','LineStyle','-','LineWidth',1,'Color','k')

makeAxisStruct(f1,sprintf('erg20150605_13step'),sprintf('erg/squirrel/invivo/'))
makeAxisStruct(f3,sprintf('erg20150605_13stim'),sprintf('erg/squirrel/invivo/'))

%% run11-12 is I don't know
colors=pmkmp(2,'CubicLQuarter');
f1=getfigH(1);
% xlim([0 150])
% ylim([-300 600])
f2=getfigH(2);
% xlim([0 150])
% ylim([-300 600])
f3=getfigH(3);
f4=getfigH(4);

clear apeak* bpeak*
cnt=0;
for r=11:12
    
    runname=sprintf('run%02g',r);
    lHl=line(erg.(runname).t,erg.(runname).l(:,1),'Parent',f1);
    set(lHl,'Marker','none','LineStyle','-','LineWidth',1,'Color',colors(r-10,:))
    lHr=line(erg.(runname).t,erg.(runname).r(:,1),'Parent',f2);
    set(lHr,'Marker','none','LineStyle','-','LineWidth',1,'Color',colors(r-10,:))
    
    cnt=cnt+1;
    apeakl(cnt)=-min(erg.(runname).l(:,1));
    bpeakl(cnt)=max(erg.(runname).l(:,1));
    apeakr(cnt)=-min(erg.(runname).r(:,1));
    bpeakr(cnt)=max(erg.(runname).r(:,1));
end

lH=line(1:2,apeakl,'Parent',f3);
set(lH,'Marker','o','LineStyle','none','LineWidth',1,'Color','k')
lH=line(1:2,apeakr,'Parent',f4);
set(lH,'Marker','o','LineStyle','none','LineWidth',1,'Color','k')

lH=line(1:2,bpeakl,'Parent',f3);
set(lH,'Marker','o','LineStyle','none','LineWidth',1,'Color','b')
lH=line(1:2,bpeakr,'Parent',f4);
set(lH,'Marker','o','LineStyle','none','LineWidth',1,'Color','b')
%% run14 16 is I don't know
colors=pmkmp(3,'CubicLQuarter');
f1=getfigH(1);
% xlim([0 150])
% ylim([-300 600])
f2=getfigH(2);
% xlim([0 150])
% ylim([-300 600])
f3=getfigH(3);
f4=getfigH(4);

clear apeak* bpeak*
cnt=0;
for r=14:16
    
    runname=sprintf('run%02g',r);
    lHl=line(erg.(runname).t,erg.(runname).l(:,1),'Parent',f1);
    set(lHl,'Marker','none','LineStyle','-','LineWidth',1,'Color',colors(r-13,:))
    lHr=line(erg.(runname).t,erg.(runname).r(:,1),'Parent',f2);
    set(lHr,'Marker','none','LineStyle','-','LineWidth',1,'Color',colors(r-13,:))
    
    cnt=cnt+1;
    apeakl(cnt)=-min(erg.(runname).l(:,1));
    bpeakl(cnt)=max(erg.(runname).l(:,1));
    apeakr(cnt)=-min(erg.(runname).r(:,1));
    bpeakr(cnt)=max(erg.(runname).r(:,1));
end

lH=line(1:3,apeakl,'Parent',f3);
set(lH,'Marker','o','LineStyle','none','LineWidth',1,'Color','k')
lH=line(1:3,apeakr,'Parent',f4);
set(lH,'Marker','o','LineStyle','none','LineWidth',1,'Color','k')

lH=line(1:3,bpeakl,'Parent',f3);
set(lH,'Marker','o','LineStyle','none','LineWidth',1,'Color','b')
lH=line(1:3,bpeakr,'Parent',f4);
set(lH,'Marker','o','LineStyle','none','LineWidth',1,'Color','b')
