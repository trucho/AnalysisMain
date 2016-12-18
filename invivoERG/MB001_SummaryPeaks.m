%% Summary MB-001 Aug_2016 

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
% erg_screentrials(Sq922.vpre,[],10);
% erg_screentrials(Sq922.vpost,[],10);
% erg_screentrials(Sq922.dpre,[],10);
% erg_screentrials(Sq821.dpost,[],10);
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
% Sq813
    % Bleached eye
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
% Sq813
    % Unbleached eye
    Sq813.results.vpre.ua_peak=temp.Ra_peak;
    Sq813.results.vpre.ua_t=temp.Ra_t;
    Sq813.results.vpre.ub_peak=temp.Rb_peak;
    Sq813.results.vpre.ub_t=temp.Rb_t;
    
    temp=Sq813.vpost.Iseries_abpeaks();
    Sq813.results.vpost.iF=temp.iF;
    Sq813.results.vpost.ua_peak=temp.Ra_peak;
    Sq813.results.vpost.ua_t=temp.Ra_t;
    Sq813.results.vpost.ub_peak=temp.Rb_peak;
    Sq813.results.vpost.ub_t=temp.Rb_t;

    temp=Sq813.dpre.Iseries_abpeaks();
    Sq813.results.dpre.iF=temp.iF;
    Sq813.results.dpre.ua_peak=temp.La_peak;
    Sq813.results.dpre.ua_t=temp.La_t;
    Sq813.results.dpre.ub_peak=temp.Lb_peak;
    Sq813.results.dpre.ub_t=temp.Lb_t;

    temp=Sq813.dpost.Iseries_abpeaks();
    Sq813.results.dpost.iF=temp.iF;
    Sq813.results.dpost.ua_peak=temp.La_peak;
    Sq813.results.dpost.ua_t=temp.La_t;
    Sq813.results.dpost.ub_peak=temp.Lb_peak;
    Sq813.results.dpost.ub_t=temp.Lb_t;

%Sq 821
    % Bleached eye
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
%Sq 821
    % Unleached eye
    temp=Sq821.vpre.Iseries_abpeaks();
    Sq821.results.vpre.iF=temp.iF;
    Sq821.results.vpre.ua_peak=temp.Ra_peak;
    Sq821.results.vpre.ua_t=temp.Ra_t;
    Sq821.results.vpre.ub_peak=temp.Rb_peak;
    Sq821.results.vpre.ub_t=temp.Rb_t;

    temp=Sq821.vpost.Iseries_abpeaks();
    Sq821.results.vpost.iF=temp.iF;
    Sq821.results.vpost.ua_peak=temp.Ra_peak;
    Sq821.results.vpost.ua_t=temp.Ra_t;
    Sq821.results.vpost.ub_peak=temp.Rb_peak;
    Sq821.results.vpost.ub_t=temp.Rb_t;

    temp=Sq821.dpre.Iseries_abpeaks();
    Sq821.results.dpre.iF=temp.iF;
    Sq821.results.dpre.ua_peak=temp.La_peak;
    Sq821.results.dpre.ua_t=temp.La_t;
    Sq821.results.dpre.ub_peak=temp.Lb_peak;
    Sq821.results.dpre.ub_t=temp.Lb_t;

    temp=Sq821.dpost.Iseries_abpeaks();
    Sq821.results.dpost.iF=temp.iF;
    Sq821.results.dpost.ua_peak=temp.La_peak;
    Sq821.results.dpost.ua_t=temp.La_t;
    Sq821.results.dpost.ub_peak=temp.Lb_peak;
    Sq821.results.dpost.ub_t=temp.Lb_t;


% Sq852
    % Bleached eye
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
% Sq852
    % Unbleached eye
    temp=Sq852.vpre.Iseries_abpeaks();
    Sq852.results.vpre.iF=temp.iF;
    Sq852.results.vpre.ua_peak=temp.La_peak;
    Sq852.results.vpre.ua_t=temp.La_t;
    Sq852.results.vpre.ub_peak=temp.Lb_peak;
    Sq852.results.vpre.ub_t=temp.Lb_t;

    temp=Sq852.vpost.Iseries_abpeaks();
    Sq852.results.vpost.iF=temp.iF;
    Sq852.results.vpost.ua_peak=temp.La_peak;
    Sq852.results.vpost.ua_t=temp.La_t;
    Sq852.results.vpost.ub_peak=temp.Lb_peak;
    Sq852.results.vpost.ub_t=temp.Lb_t;

    temp=Sq852.dpre.Iseries_abpeaks();
    Sq852.results.dpre.iF=temp.iF;
    Sq852.results.dpre.ua_peak=temp.Ra_peak;
    Sq852.results.dpre.ua_t=temp.Ra_t;
    Sq852.results.dpre.ub_peak=temp.Rb_peak;
    Sq852.results.dpre.ub_t=temp.Rb_t;

    temp=Sq852.dpost.Iseries_abpeaks();
    Sq852.results.dpost.iF=temp.iF;
    Sq852.results.dpost.ua_peak=temp.Ra_peak;
    Sq852.results.dpost.ua_t=temp.Ra_t;
    Sq852.results.dpost.ub_peak=temp.Rb_peak;
    Sq852.results.dpost.ub_t=temp.Rb_t;

%Sq 922
    % Bleached eye
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
%Sq 922 
    % Unbleached eye
    temp=Sq922.vpre.Iseries_abpeaks();
    Sq922.results.vpre.iF=temp.iF;
    Sq922.results.vpre.ua_peak=temp.La_peak;
    Sq922.results.vpre.ua_t=temp.La_t;
    Sq922.results.vpre.ub_peak=temp.Lb_peak;
    Sq922.results.vpre.ub_t=temp.Lb_t;

    temp=Sq922.vpost.Iseries_abpeaks();
    Sq922.results.vpost.iF=temp.iF;
    Sq922.results.vpost.ua_peak=temp.La_peak;
    Sq922.results.vpost.ua_t=temp.La_t;
    Sq922.results.vpost.ub_peak=temp.Lb_peak;
    Sq922.results.vpost.ub_t=temp.Lb_t;

    temp=Sq922.dpre.Iseries_abpeaks();
    Sq922.results.dpre.iF=temp.iF;
    Sq922.results.dpre.ua_peak=temp.Ra_peak;
    Sq922.results.dpre.ua_t=temp.Ra_t;
    Sq922.results.dpre.ub_peak=temp.Rb_peak;
    Sq922.results.dpre.ub_t=temp.Rb_t;

    temp=Sq922.dpost.Iseries_abpeaks();
    Sq922.results.dpost.iF=temp.iF;
    Sq922.results.dpost.ua_peak=temp.Ra_peak;
    Sq922.results.dpost.ua_t=temp.Ra_t;
    Sq922.results.dpost.ub_peak=temp.Rb_peak;
    Sq922.results.dpost.ub_t=temp.Rb_t;


%%
% colors=pmkmp(size(fields(Is),1),'CubicL');
% colors=pmkmp(size(fields(Is),1),'LinLhot');
colors = [[.5 .5 .5];[0 0 0];[1 .5 .5];[1 0 0];];

results = Sq813.results;

f1=getfigH(1);
set(f1,'XScale','log')
setLabels(f1,'I_{Flash} (cd/m^2)','Left a_{peak} (\muV)')

lH=lineH(results.vpre.iF,(-results.vpre.a_peak),f1);
lH.color(colors(1,:));
set(lH.h,'DisplayName','avpre')
lH=lineH(results.vpost.iF,(-results.vpost.a_peak),f1);
lH.color(colors(2,:));
set(lH.h,'DisplayName','avpost')
lH=lineH(results.dpre.iF,(-results.dpre.a_peak),f1);
lH.color(colors(3,:));
set(lH.h,'DisplayName','adpre')
lH=lineH(results.dpost.iF,(-results.dpost.a_peak),f1);
lH.color(colors(4,:));
set(lH.h,'DisplayName','adpost')

%
f2=getfigH(2);
set(f2,'XScale','log')
setLabels(f2,'I_{Flash} (cd/m^2)','Left b_{peak} (\muV)')

lH=lineH(results.vpre.iF,(results.vpre.b_peak),f2);
lH.color(colors(1,:));
set(lH.h,'DisplayName','bvpre')
lH=lineH(results.vpost.iF,(results.vpost.b_peak),f2);
lH.color(colors(2,:));
set(lH.h,'DisplayName','bvpost')
lH=lineH(results.dpre.iF,(results.dpre.b_peak),f2);
lH.color(colors(3,:));
set(lH.h,'DisplayName','bdpre')
lH=lineH(results.dpost.iF,(results.dpost.b_peak),f2);
lH.color(colors(4,:));
set(lH.h,'DisplayName','bdpost')

%% Collect ratios across intensities
Avg=struct();
Avg.iF=unique([Sq813.results.vpost.iF, Sq821.results.vpost.iF, Sq852.results.vpost.iF, Sq922.results.vpost.iF, ...
    Sq813.results.dpre.iF, Sq821.results.dpre.iF, Sq852.results.dpost.iF, Sq922.results.dpost.iF]);

Avg.va=NaN(4,size(Avg.iF,2));
Avg.vb=NaN(4,size(Avg.iF,2));
Avg.da=NaN(4,size(Avg.iF,2));
Avg.db=NaN(4,size(Avg.iF,2));

Avg.uva=NaN(4,size(Avg.iF,2));
Avg.uvb=NaN(4,size(Avg.iF,2));
Avg.uda=NaN(4,size(Avg.iF,2));
Avg.udb=NaN(4,size(Avg.iF,2));

for i=1:length(Avg.iF);
    %Sq813
    i_pre=find(Sq813.results.vpre.iF==Avg.iF(i));
    i_post=find(Sq813.results.vpost.iF==Avg.iF(i));
    if ~isempty(i_pre) && ~isempty(i_post)
        Avg.va(1,i)= Sq813.results.vpre.a_peak(i_pre)/Sq813.results.vpost.a_peak(i_post);
        Avg.vb(1,i)= Sq813.results.vpre.b_peak(i_pre)/Sq813.results.vpost.b_peak(i_post);
        
        Avg.uva(1,i)= Sq813.results.vpre.ua_peak(i_pre)/Sq813.results.vpost.ua_peak(i_post);
        Avg.uvb(1,i)= Sq813.results.vpre.ub_peak(i_pre)/Sq813.results.vpost.ub_peak(i_post);
    end
    i_pre=find(Sq813.results.dpre.iF==Avg.iF(i));
    i_post=find(Sq813.results.dpost.iF==Avg.iF(i));
    if ~isempty(i_pre) && ~isempty(i_post)
        Avg.da(1,i)= Sq813.results.dpre.a_peak(i_pre)/Sq813.results.dpost.a_peak(i_post);
        Avg.db(1,i)= Sq813.results.dpre.b_peak(i_pre)/Sq813.results.dpost.b_peak(i_post);
        
        Avg.uda(1,i)= Sq813.results.dpre.ua_peak(i_pre)/Sq813.results.dpost.ua_peak(i_post);
        Avg.udb(1,i)= Sq813.results.dpre.ub_peak(i_pre)/Sq813.results.dpost.ub_peak(i_post);
    end
    
    %Sq821
    i_pre=find(Sq821.results.vpre.iF==Avg.iF(i));
    i_post=find(Sq821.results.vpost.iF==Avg.iF(i));
    if ~isempty(i_pre) && ~isempty(i_post)
        Avg.va(2,i)= Sq821.results.vpre.a_peak(i_pre)/Sq821.results.vpost.a_peak(i_post);
        Avg.vb(2,i)= Sq821.results.vpre.b_peak(i_pre)/Sq821.results.vpost.b_peak(i_post);
        
        Avg.uva(2,i)= Sq821.results.vpre.ua_peak(i_pre)/Sq821.results.vpost.ua_peak(i_post);
        Avg.uvb(2,i)= Sq821.results.vpre.ub_peak(i_pre)/Sq821.results.vpost.ub_peak(i_post);
    end
    i_pre=find(Sq821.results.dpre.iF==Avg.iF(i));
    i_post=find(Sq821.results.dpost.iF==Avg.iF(i));
    if ~isempty(i_pre) && ~isempty(i_post)
        Avg.da(2,i)= Sq821.results.dpre.a_peak(i_pre)/Sq821.results.dpost.a_peak(i_post);
        Avg.db(2,i)= Sq821.results.dpre.b_peak(i_pre)/Sq821.results.dpost.b_peak(i_post);
        
        Avg.uda(2,i)= Sq821.results.dpre.ua_peak(i_pre)/Sq821.results.dpost.ua_peak(i_post);
        Avg.udb(2,i)= Sq821.results.dpre.ub_peak(i_pre)/Sq821.results.dpost.ub_peak(i_post);
    end
    
    %Sq852
    i_pre=find(Sq852.results.vpre.iF==Avg.iF(i));
    i_post=find(Sq852.results.vpost.iF==Avg.iF(i));
    if ~isempty(i_pre) && ~isempty(i_post)
        Avg.va(3,i)= Sq852.results.vpre.a_peak(i_pre)/Sq852.results.vpost.a_peak(i_post);
        Avg.vb(3,i)= Sq852.results.vpre.b_peak(i_pre)/Sq852.results.vpost.b_peak(i_post);
        
        Avg.uva(3,i)= Sq852.results.vpre.ua_peak(i_pre)/Sq852.results.vpost.ua_peak(i_post);
        Avg.uvb(3,i)= Sq852.results.vpre.ub_peak(i_pre)/Sq852.results.vpost.ub_peak(i_post);
    end
    i_pre=find(Sq852.results.dpre.iF==Avg.iF(i));
    i_post=find(Sq852.results.dpost.iF==Avg.iF(i));
    if ~isempty(i_pre) && ~isempty(i_post)
        Avg.da(3,i)= Sq852.results.dpre.a_peak(i_pre)/Sq852.results.dpost.a_peak(i_post);
        Avg.db(3,i)= Sq852.results.dpre.b_peak(i_pre)/Sq852.results.dpost.b_peak(i_post);
        
        Avg.uda(3,i)= Sq852.results.dpre.ua_peak(i_pre)/Sq852.results.dpost.ua_peak(i_post);
        Avg.udb(3,i)= Sq852.results.dpre.ub_peak(i_pre)/Sq852.results.dpost.ub_peak(i_post);
    end
    
    %Sq922
    i_pre=find(Sq922.results.vpre.iF==Avg.iF(i));
    i_post=find(Sq922.results.vpost.iF==Avg.iF(i));
    if ~isempty(i_pre) && ~isempty(i_post)
        Avg.va(4,i)= Sq922.results.vpre.a_peak(i_pre)/Sq922.results.vpost.a_peak(i_post);
        Avg.vb(4,i)= Sq922.results.vpre.b_peak(i_pre)/Sq922.results.vpost.b_peak(i_post);
        
        Avg.uva(4,i)= Sq922.results.vpre.ua_peak(i_pre)/Sq922.results.vpost.ua_peak(i_post);
        Avg.uvb(4,i)= Sq922.results.vpre.ub_peak(i_pre)/Sq922.results.vpost.ub_peak(i_post);
    end
    i_pre=find(Sq922.results.dpre.iF==Avg.iF(i));
    i_post=find(Sq922.results.dpost.iF==Avg.iF(i));
    if ~isempty(i_pre) && ~isempty(i_post)
        Avg.da(4,i)= Sq922.results.dpre.a_peak(i_pre)/Sq922.results.dpost.a_peak(i_post);
        Avg.db(4,i)= Sq922.results.dpre.b_peak(i_pre)/Sq922.results.dpost.b_peak(i_post);
        
        Avg.uda(4,i)= Sq922.results.dpre.ua_peak(i_pre)/Sq922.results.dpost.ua_peak(i_post);
        Avg.udb(4,i)= Sq922.results.dpre.ub_peak(i_pre)/Sq922.results.dpost.ub_peak(i_post);
    end
end
%%
%% Plot ratios pre/post
f5=getfigH(5);
set(f5,'XScale','log')
setLabels(f5,'I_{Flash} (cd/m^2)','Ratio pre/post a_{peak} (\muV)')
lH = lineH(Sq821.results.vpre.iF,ones(size(Sq821.results.vpre.iF)),f5);
lH.linedash;


lH=lineH(Avg.iF,nanmean(Avg.va,1),f5);
lH.color([0 0 0]);
set(lH.h,'DisplayName','a_veh')
eh=lH.errorbars(Avg.iF,nanmean(Avg.va,1),nanstd(Avg.va,1)./sqrt(4),[0 0 0],f5,'a_vehsd');

lH=lineH(Avg.iF,nanmean(Avg.uva,1),f5);
lH.color([.5 .5 .5]);lH.openmarkers;
set(lH.h,'DisplayName','a_veh_u')
eh=lH.errorbars(Avg.iF,nanmean(Avg.uva,1),nanstd(Avg.uva,1)./sqrt(4),[.5 .5 .5],f5,'a_vehsd_u');

lH=lineH(Avg.iF,nanmean(Avg.da,1),f5);
lH.color([1 0 0]);
set(lH.h,'DisplayName','a_drug')
eh=lH.errorbars(Avg.iF,nanmean(Avg.da,1),nanstd(Avg.da,1)./sqrt(4),[1 0 0],f5,'a_drugsd');

lH=lineH(Avg.iF,nanmean(Avg.uda,1),f5);
lH.color([1 .5 .5]);lH.openmarkers;
set(lH.h,'DisplayName','a_drug_u')
eh=lH.errorbars(Avg.iF,nanmean(Avg.uda,1),nanstd(Avg.uda,1)./sqrt(4),[1 .5 .5],f5,'a_drugsd_u');

f6=getfigH(6);
set(f6,'XScale','log')
setLabels(f6,'I_{Flash} (cd/m^2)','Ratio pre/post b_{peak} (\muV)')
lH = lineH(Sq821.results.vpre.iF,ones(size(Sq821.results.vpre.iF)),f6);
lH.linedash;


lH=lineH(Avg.iF,nanmean(Avg.vb,1),f6);
lH.color([0 0 0]);
set(lH.h,'DisplayName','b_veh')
eh=lH.errorbars(Avg.iF,nanmean(Avg.vb,1),nanstd(Avg.vb,1)./sqrt(4),[0 0 0],f6,'b_vehsd');

lH=lineH(Avg.iF,nanmean(Avg.uvb,1),f6);
lH.color([.5 .5 .5]);lH.openmarkers;
set(lH.h,'DisplayName','b_veh_u')
eh=lH.errorbars(Avg.iF,nanmean(Avg.uvb,1),nanstd(Avg.uvb,1)./sqrt(4),[.5 .5 .5],f6,'b_vehsd_u');

lH=lineH(Avg.iF,nanmean(Avg.db,1),f6);
lH.color([1 0 0]);
set(lH.h,'DisplayName','b_drug')
eh=lH.errorbars(Avg.iF,nanmean(Avg.db,1),nanstd(Avg.db,1)./sqrt(4),[1 0 0],f6,'b_drugsd');

lH=lineH(Avg.iF,nanmean(Avg.udb,1),f6);
lH.color([1 .5 .5]);lH.openmarkers;
set(lH.h,'DisplayName','b_drug_u')
eh=lH.errorbars(Avg.iF,nanmean(Avg.udb,1),nanstd(Avg.udb,1)./sqrt(4),[1 .5 .5],f6,'b_drugsd_u');
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
    x=Avg.va(:,i);
    y=Avg.da(:,i);
    [p.avd(i),h.avd(i)]=ranksum(x(~isnan(x)), y(~isnan(y)));
    
    x=Avg.va(:,i);
    y=Avg.uva(:,i);
    [p.avbu(i),h.avbu(i)]=ranksum(x(~isnan(x)), y(~isnan(y)));
    
    x=Avg.da(:,i);
    y=Avg.uda(:,i);
    [p.adbu(i),h.adbu(i)]=ranksum(x(~isnan(x)), y(~isnan(y)));
    
    x=Avg.vb(:,i);
    y=Avg.db(:,i);
    [p.bvd(i),h.bvd(i)]=ranksum(x(~isnan(x)), y(~isnan(y)));
    
    x=Avg.vb(:,i);
    y=Avg.uvb(:,i);
    [p.bvbu(i),h.bvbu(i)]=ranksum(x(~isnan(x)), y(~isnan(y)));
    
    x=Avg.db(:,i);
    y=Avg.udb(:,i);
    [p.bdbu(i),h.bdbu(i)]=ranksum(x(~isnan(x)), y(~isnan(y)));
end


%% Export to Igor for collaboration
% Panel plans: 
% a b
% c d
% e f
% g h
% a) DMSO: Iseries was i. Pre ii. PostBleach
% b) MB-001: Iseries was i. Pre ii. PostBleach
% c) a_peak: DMSO pre/post + MB-001 pre/post
% d) a_ttp
% e) b_peak
% f) b_ttp
% g) a_ratios
% h) b_ratios
makeAxisStruct(f1,'c_aPeak',sprintf('erg/squirrel/invivo/MB001'));
makeAxisStruct(f2,'e_bPeak',sprintf('erg/squirrel/invivo/MB001'));
makeAxisStruct(f5,'g_aRatios',sprintf('erg/squirrel/invivo/MB001'));
makeAxisStruct(f6,'h_bRatios',sprintf('erg/squirrel/invivo/MB001'));

%% iSeries vehicle pre-bleaching
hGUI=erg_iseries(Sq821.vpre,[],10);
drawnow
makeAxisStruct(hGUI.figData.plotL2,'a_vPre',sprintf('erg/squirrel/invivo/MB001'));
%% iSeries vehicle post-bleaching
hGUI=erg_iseries(Sq821.vpost,[],10);
drawnow
makeAxisStruct(hGUI.figData.plotL2,'a_vPost',sprintf('erg/squirrel/invivo/MB001'));
%% iSeries vehicle pre-bleaching
hGUI=erg_iseries(Sq821.dpre,[],10);
drawnow
makeAxisStruct(hGUI.figData.plotR2,'b_dPre',sprintf('erg/squirrel/invivo/MB001'));
%% iSeries vehicle pre-bleaching
hGUI=erg_iseries(Sq821.dpost,[],10);
drawnow
makeAxisStruct(hGUI.figData.plotR2,'b_dPost',sprintf('erg/squirrel/invivo/MB001'));



%%
%% Collect differences across intensities
Diff=struct();
Diff.iF=unique([Sq813.results.vpost.iF, Sq821.results.vpost.iF, Sq852.results.vpost.iF, Sq922.results.vpost.iF, ...
    Sq813.results.dpre.iF, Sq821.results.dpre.iF, Sq852.results.dpost.iF, Sq922.results.dpost.iF]);

Diff.va=NaN(4,size(Diff.iF,2));
Diff.vb=NaN(4,size(Diff.iF,2));
Diff.da=NaN(4,size(Diff.iF,2));
Diff.db=NaN(4,size(Diff.iF,2));

Diff.uva=NaN(4,size(Diff.iF,2));
Diff.uvb=NaN(4,size(Diff.iF,2));
Diff.uda=NaN(4,size(Diff.iF,2));
Diff.udb=NaN(4,size(Diff.iF,2));

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
eh=lH.errorbars(Diff.iF,nanmean(Diff.va,1),nanstd(Diff.va,1)./sqrt(4),[0 0 0],f5,'a_vehsd');

lH=lineH(Diff.iF,nanmean(Diff.uva,1),f5);
lH.color([.5 .5 .5]);lH.openmarkers;
set(lH.h,'DisplayName','a_veh_unbleached')
eh=lH.errorbars(Diff.iF,nanmean(Diff.uva,1),nanstd(Diff.uva,1)./sqrt(4),[.5 .5 .5],f5,'a_vehsd_unbleached');

lH=lineH(Diff.iF,nanmean(Diff.da,1),f5);
lH.color([1 0 0]);
set(lH.h,'DisplayName','a_drug')
eh=lH.errorbars(Diff.iF,nanmean(Diff.da,1),nanstd(Diff.da,1)./sqrt(4),[1 0 0],f5,'a_drugsd');

lH=lineH(Diff.iF,nanmean(Diff.uda,1),f5);
lH.color([1 .5 .5]);lH.openmarkers;
set(lH.h,'DisplayName','a_drug_unbleached')
eh=lH.errorbars(Diff.iF,nanmean(Diff.uda,1),nanstd(Diff.uda,1)./sqrt(4),[1 .5 .5],f5,'a_drugsd_unbleached');

f6=getfigH(6);
set(f6,'XScale','log')
setLabels(f6,'I_{Flash} (cd/m^2)','Ratio pre/post b_{peak} (\muV)')
lH = lineH(Sq821.results.vpre.iF,ones(size(Sq821.results.vpre.iF)),f6);
lH.linedash;


lH=lineH(Diff.iF,nanmean(Diff.vb,1),f6);
lH.color([0 0 0]);
set(lH.h,'DisplayName','a_veh')
eh=lH.errorbars(Diff.iF,nanmean(Diff.vb,1),nanstd(Diff.vb,1)./sqrt(4),[0 0 0],f6,'a_vehsd');

lH=lineH(Diff.iF,nanmean(Diff.uvb,1),f6);
lH.color([.5 .5 .5]);lH.openmarkers;
set(lH.h,'DisplayName','a_veh_unbleached')
eh=lH.errorbars(Diff.iF,nanmean(Diff.uvb,1),nanstd(Diff.uvb,1)./sqrt(4),[.5 .5 .5],f6,'a_vehsd_unbleached');

lH=lineH(Diff.iF,nanmean(Diff.db,1),f6);
lH.color([1 0 0]);
set(lH.h,'DisplayName','a_drug')
eh=lH.errorbars(Diff.iF,nanmean(Diff.db,1),nanstd(Diff.db,1)./sqrt(4),[1 0 0],f6,'a_drugsd');

lH=lineH(Diff.iF,nanmean(Diff.udb,1),f6);
lH.color([1 .5 .5]);lH.openmarkers;
set(lH.h,'DisplayName','a_drug_unbleached')
eh=lH.errorbars(Diff.iF,nanmean(Diff.udb,1),nanstd(Diff.udb,1)./sqrt(4),[1 .5 .5],f6,'a_drugsd_unbleached');
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


