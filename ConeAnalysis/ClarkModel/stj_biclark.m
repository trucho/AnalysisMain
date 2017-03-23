%% Trying to fit a biophysical Inspired model to Saccade Trajectory data
% Jun_2015 Juan Angueyra
%% Checking coeffs used for dim flash response against SaccadeTrajectory
load('/Users/angueyraaristjm/matlab/matlab-analysis/trunk/users/juan/ConeModel/BiophysicalModel/EyeMovementsExample_092413Fc12vClamp.mat')
skippts=20;
dt=skippts*(EyeMovementsExample.TimeAxis(2)-EyeMovementsExample.TimeAxis(1));
i2V=[130 1];


em_tme=EyeMovementsExample.TimeAxis(1:skippts:end);
%stimulus is calibrated in R*/s, so for model, have to convert it to R*/dt
em_stm=EyeMovementsExample.Stim(1:skippts:end).*dt;
%%%
% Problem right now is that 0 is not dark current, it's rather response to
% first dim background. if these 2 would match (or could be estimated as
% response above dark current) fitting owuld be easier
%%%
em_resp=EyeMovementsExample.Mean(1:skippts:end)+5;
% em_resp=-(EyeMovementsExample.Mean(1:skippts:end))*i2V(2);
% em_resp=em_resp+i2V(1);

% em_tme=em_tme(1:2550);
% em_stm=em_stm(1:2550);
% em_resp=em_resp(1:2550);

% em_tme=em_tme(1:521);
% em_stm=em_stm(480:1000);
% em_resp=em_resp(480:1000);

% % Trying Fred's parameters from dropbox Clark file Oct 2016?
% ccoeffs=[...
%     0.0071...   tauy
%     0.0145...   tauz
%     2.828...    ny
%     1.4745...   nz
%     0.055...    gamma
%     0.001...    tauR
%     12.95...    alpha
%     0.248...    beta
%     0.0751...   gamma2
%     0.243...    tauzslow
%     0.83...     nzslow
%     ];

% Palying with parameters
% ccoeffs=[...
%     0.005...   tauy
%     0.01...   tauz
%     4.00...    ny
%     1.0...      nz
%     0.01...    gamma
%     0.012...    tauR
%     5.0...    alpha
%     0.3...    beta
%     0.1...   gamma2
%     0.3...    tauzslow
%     1.0...     nzslow
%     ];

% Playing with parameters
ccoeffs=[...
    7/1000 ...  tauy
    14/1000 ... tauz
    3.00 ...    ny
    1.50 ...    nz
    55/1000 ...   gamma
    1/1000 ... tauR
    13.0 ...     alpha
    248/1000 ...    beta
    75/1000 ...     gamma2
    0.3 ...     tauzslow
    1.0 ...     nzslow
    ];
% 
ccoeffs =[...
	0.009 ... 	tauy
	0.039 ... 	tauz
	3.220 ... 	ny
	1.310 ... 	nz
	0.020 ... 	gamma
	0.001 ... 	tauR
	18.300 ... 	alpha
	0.265 ... 	beta
	0.100 ... 	gamma2
	0.029 ... 	tauz_slow
	1.000 ... 	nz_slow
];

ccoeffs =[...
	0.009 ... 	tauy
	0.039 ... 	tauz
	3.220 ... 	ny
	1.310 ... 	nz
	0.030 ... 	gamma
	0.001 ... 	tauR
	18.300 ... 	alpha
	0.265 ... 	beta
	0.100 ... 	gamma2
	0.029 ... 	tauz_slow
	1.000 ... 	nz_slow
];


em_firsttry=cModelBi(ccoeffs,em_tme,em_stm,dt);

runlsq=0;
runfmc=0;

em_fitcoeffs=[];
em_fit=nan(1,length(em_tme));
if runlsq
    % lsq
    fprintf('Started lsq fitting.....\n')
    lsqfun=@(optcoeffs,em_tme,em_stm,dt)rModel4(optcoeffs,em_tme,em_stm,dt);
    LSQ.objective=lsqfun;
    LSQ.x0=ccoeffs;
    LSQ.xdata=em_tme;
    LSQ.ydata=em_resp;
    LSQ.lb=[0.005 0000 00000 000 000];
    LSQ.ub=[00001 1000 10000 100 100];
    
    LSQ.solver='lsqcurvefit';
    LSQ.options=optimset('TolX',1e-20,'TolFun',1e-20,'MaxFunEvals',200);
    em_fitcoeffs=lsqcurvefit(LSQ);
    
    BIPBIP();
    fprintf('\nccoeffs=[%3.3g %3.3g %3.3g %3.3g %3.3g %3.3g %3.3g %3.3g %3.3g %3.3g %3.3g];\n',em_fitcoeffs)
end

if runfmc
    % fmincon
    fprintf('Started fmincon.....\n')
    optfx=@(optcoeffs)cModelBi(optcoeffs,em_tme,em_stm,dt);
    errfx=@(optcoeffs)sum((optfx(optcoeffs)-em_resp).^2);
    FMC.objective=errfx;
    FMC.x0=ccoeffs;
    FMC.lb=[0 0 0 0 0 0 0 0 0 0 0];
%     FMC.ub=[00001 1000 10000 500 100];
    
    FMC.solver='fmincon';
    FMC.options=optimset('Algorithm','interior-point',...
        'DiffMinChange',1e-16,'Display','iter-detailed',...
        'TolX',1e-20,'TolFun',1e-20,'TolCon',1e-20,...
        'MaxFunEvals',20000);
    em_fitcoeffs=fmincon(FMC);

%     BIPBIP();
    fprintf('\nccoeffs=[%3.3g %3.3g %3.3g %3.3g %3.3g %3.3g %3.3g %3.3g %3.3g %3.3g %3.3g];\n',em_fitcoeffs)
end


em_stm2=[ones(1,1000)*em_stm(1) em_stm];
em_tme2=(1:1:length(em_stm2)).*dt;
em_firsttry2=cModelBi(ccoeffs,em_tme2,em_stm2,dt);
em_firsttry2=em_firsttry2(1001:end);

if ~isempty(em_fitcoeffs)
    em_fit=cModelBi(em_fitcoeffs,em_tme,em_stm,dt,1);
else
    em_fit=cModelBi(ccoeffs,em_tme,em_stm,dt,1);
end

%
f3=getfigH(3);
set(get(f3,'XLabel'),'String','Time (s)')
set(get(f3,'YLabel'),'String','i (pA)')


rn_color=pmkmp(256,'IsoL');
rn_color=rn_color(randi(256),:);

lH=line(em_tme,em_resp,'Parent',f3);
set(lH,'Color','k','DisplayName','response','linewidth',3,'marker','.');
lH=line(em_tme,em_firsttry2,'Parent',f3);
set(lH,'Color',rn_color,'LineStyle','-','linewidth',2,'marker','none','DisplayName','rm');
lH=line(em_tme,em_fit,'Parent',f3);
set(lH,'Color',[.5 0 .5],'LineStyle','-','linewidth',2);


f4=getfigH(4);
set(get(f4,'XLabel'),'String','Time (s)')
set(get(f4,'YLabel'),'String','R*/dt')
lH=line(em_tme,em_stm,'Parent',f4);
set(lH,'Color','k','DisplayName','stim','LineWidth',2);

figure(3)
legend('Data','Guess','Fit')
% BIPBIP()
% fprintf('Acabé\n')

%%
makeAxisStruct(f3,'RiekeModel','ConeModel/SaccadeTrajectory')
makeAxisStruct(f4,'Stim','ConeModel/SaccadeTrajectory')



%% Fitting Battle

f3=getfigH(3);
set(get(f3,'XLabel'),'String','Time (s)')
set(get(f3,'YLabel'),'String','i (pA)')
lH=line(em_tme,-em_resp,'Parent',f3);
set(lH,'Color','k','DisplayName','response','linewidth',3,'marker','.');
lH=line(em_tme,-em_firsttry2,'Parent',f3);
set(lH,'Color',[1 0 0],'LineStyle','-','linewidth',2,'marker','none','DisplayName','rm');


makeAxisStruct(f3,'stj',sprintf('FittingBattle/%s',savepath))
%% checking how well this model does against its own dim flash response
load('/Users/angueyraaristjm/matlab/matlab-analysis/trunk/users/juan/ConeModel/BiophysicalModel/EyeMovementsExampleDF_092413Fc12vClamp.mat')

i2V=[130 1];

df_real=DF_raw.Mean;
df_tme=DF_raw.TimeAxis;
df_stm=zeros(size(df_tme));
df_stm(5)=1;

dfdt=df_tme(2)-df_tme(1);

df_stm2=[zeros(1,10000) df_stm];
df_tme2=(1:1:length(df_stm2)).*dfdt;
df_firsttry2=rModel4(ccoeffs,df_tme2,df_stm2);
df_rmodel=df_firsttry2(10001:end);


% df_rmodel=rModel4(rmcoeffs,df_tme,df_stm);

% Although not perfect, predicts peak amplitude and has good kinetics!
f5=getfigH(5);
set(get(f5,'XLabel'),'String','Time (s)')
set(get(f5,'YLabel'),'String','R*/dt')
lH=line(df_tme,df_real-(mean(df_rmodel(1:10))),'Parent',f5);
set(lH,'Color','k','DisplayName','df_real');
lH=line(df_tme,-df_rmodel-0.005,'Parent',f5);
set(lH,'Color',[.5 0 .5],'linewidth',2,'DisplayName','df_rModel');
%%

%% Trying to recreate adaptation kinetics with this particular model
clear I t ios Stim

tstruct=struct;

tstruct.dt=1e-3;  %in s        
tstruct.start=0; %in s
tstruct.end=7;   % in s

tstruct.step_on=1.5;    % in s
tstruct.step_dur=2; %in s
tstruct.step_off=tstruct.step_on+tstruct.step_dur;    % in s


tstruct.flash_on=[.4 tstruct.step_on tstruct.step_on+1.5 tstruct.step_off tstruct.step_off+1.5]; %in s
tstruct.flash_dur=0.01; %in s
tstruct.flash_off=tstruct.flash_on+tstruct.flash_dur; %in s

Ib=0;
Istep=100;
IFlashes=150;

t=tstruct.start:tstruct.dt:tstruct.end;   % s
I_step=Ib*ones(1,length(t));   % in R*
I_step(t >= tstruct.step_on & t < tstruct.step_off) = Istep+Ib;

ios_step=-rModel4(ccoeffs,t,I_step);

f2=getfigH(2);
lH=line(t,ios_step,'Parent',f2);
set(lH,'DisplayName','step','Line','-','LineWidth',2,'Marker','none','Color',[.6 .6 .6])

f3=getfigH(3);

f4=getfigH(4);


delay=[0.01:0.1:0.90];

% delay=[0.50];

colors=pmkmp(length(delay));
for i=1:length(delay)
    I=I_step;
    % PreFlash
    ind=find(t >= tstruct.flash_on(1),1,'first');
    I(ind:ind+(tstruct.flash_dur/tstruct.dt))=IFlashes+Ib;
%     I(t >= tstruct.flash_on(1) & t <= tstruct.flash_off(1))=IFlashes+Ib;
    % OnFlash
    ind=find(t >= tstruct.flash_on(2)+delay(i),1,'first');
    I(ind:ind+(tstruct.flash_dur/tstruct.dt))=IFlashes+Istep+Ib;  
    % StepFlash
    ind=find(t >= tstruct.flash_on(3));
    I(ind:ind+(tstruct.flash_dur/tstruct.dt))=IFlashes+Istep+Ib;
    % OffFlash
    ind=find(t >= tstruct.flash_on(4)+delay(i),1,'first');
    I(ind:ind+(tstruct.flash_dur/tstruct.dt))=IFlashes+Ib;
    % PostFlash
    ind=find(t >= tstruct.flash_on(5),1,'first');
    I(ind:ind+(tstruct.flash_dur/tstruct.dt))=IFlashes+Ib;
    
    Stim(i,:)=I;
    
    ios(i,:)=-rModel4(ccoeffs,t,I);
    
    ios_f(i,:)=ios(i,:)-ios_step;
    
    
    lH=line(t,ios(i,:),'Parent',f2);
    set(lH,'DisplayName','stepsandflashes','Line','-','LineWidth',2,'Marker','none','Color',colors(i,:))
    
    lH=line(t,ios_f(i,:),'Parent',f3);
    set(lH,'DisplayName','flashes','Line','-','LineWidth',2,'Marker','none','Color',colors(i,:))
    
    lH=line(t,Stim(i,:),'Parent',f4);
    set(lH,'DisplayName','RodModelAndAK_Stim','Line','-','LineWidth',2,'Marker','none','Color',colors(i,:))
    
    drawnow
    fprintf('Done with %g of %g: Delay = %g ms\n',i,length(delay),delay(i)*1000)    
end

%%
%% Trying to recreate ON/OFF asymmetries with this particular model
clear I t ios_step Stim

tstruct=struct;

tstruct.dt=1e-3;  %in s        
tstruct.start=0; %in s
tstruct.end=6;   % in s

tstruct.step_dur=1; %in s

tstruct.minus_on=1.5;    % in s
tstruct.minus_off=tstruct.minus_on+tstruct.step_dur;    % in s

tstruct.plus_on=4;    % in s
tstruct.plus_off=tstruct.plus_on+tstruct.step_dur;    % in s

t=tstruct.start:tstruct.dt:tstruct.end;   % s

f2=getfigH(2);
f4=getfigH(4);

Ib=100;
contrast=[0.1:0.1:1.0];
colors=pmkmp(length(contrast));
for i=1:length(contrast)
    Istep=Ib*contrast(i);
    
    
    I(i,:)=Ib*ones(1,length(t));   % in R*
    ind_minus=find(t>=tstruct.minus_on,1,'first');
    I(i,ind_minus:ind_minus+tstruct.step_dur/tstruct.dt) = Ib-Istep;
    ind_plus=find(t>=tstruct.plus_on,1,'first');
    I(i,ind_plus:ind_plus+tstruct.step_dur/tstruct.dt) = Ib+Istep;
    
%     I(i,t>=tstruct.minus_on & t<tstruct.minus_off) = Ib-Istep;
%     I(i,t>=tstruct.plus_on & t<tstruct.plus_off) = Ib+Istep;
    
    ios_step(i,:)=-rModel4(ccoeffs,t,I(i,:));
    
    
    lH=line(t,ios_step(i,:),'Parent',f2);
    set(lH,'DisplayName','cpm','Line','-','LineWidth',2,'Marker','none','Color',colors(i,:))
    
    
    lH=line(t,I(i,:),'Parent',f4);
    set(lH,'DisplayName','cpm_stim','Line','-','LineWidth',2,'Marker','none','Color',colors(i,:))
    
end
