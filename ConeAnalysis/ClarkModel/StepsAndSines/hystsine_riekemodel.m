%% Trying to fit a biophysical Inspired model to Hysteresis + Sine cone data
% May_2013 Juan Angueyra
%% Checking coeffs used for dim flash response against SaccadeTrajectory
load('/Users/juan/matlab/matlab-analysis/trunk/users/juan/ConeModel/BiophysicalModel/HystSine_iC_ex.mat')
skippts=20;
TimeStep=skippts*(HystData.tAxis(2)-HystData.tAxis(1));
% resp*12 and +250 ihold
rmcoeffs=[111    4  0.02  440   30   23   14.75];
gdark=36.82;
phase=1;
em_tme=HystData.tAxis(1:skippts:end);
%stimulus is calibrated in R*/s, so for model, have to convert it to R*/TimeStep
em_stm=HystData.stim(phase,1:skippts:end).*TimeStep;
em_resp=HystData.mean(phase,1:skippts:end)*12;
em_resp=em_resp+250;

 
% em_tme=em_tme(1:1151);
% em_stm=em_stm(400:1550);
% em_resp=em_resp(400:1550);

% em_tme=em_tme(1:521);
% em_stm=em_stm(480:1000);
% em_resp=em_resp(480:1000);

em_firsttry=riekemodelstim3(rmcoeffs,em_tme,em_stm,gdark);


runlsq=0;
runfmc=0;

tic
em_fit=nan(1,length(em_tme));
if runlsq
    % lsq
    fprintf('Started lsq fitting.....\n')
    lsqfun=@(optcoeffs,em_tme)riekemodelstim3(optcoeffs,em_tme,em_stm,gdark);
    LSQ.objective=lsqfun;
    LSQ.x0=rmcoeffs;
    LSQ.xdata=em_tme;
    LSQ.ydata=em_resp;
    LSQ.lb=[000 2.0 00 0000 0000 0000 000];
    LSQ.ub=[200 4.0 01 1000 1000 1000 100];
    
    LSQ.solver='lsqcurvefit';
    LSQ.options=optimset('TolX',1e-20,'TolFun',1e-20,'MaxFunEvals',1000);
    em_fitcoeffs=lsqcurvefit(LSQ);
    
    BIPBIP();
    disp(em_fitcoeffs);
    em_fit=riekemodelstim3(em_fitcoeffs,em_tme,em_stm,gdark);
end

if runfmc
    % fmincon
    fprintf('Started fmincon.....\n')
    optfx=@(optcoeffs)riekemodelstim3(optcoeffs,em_tme,em_stm,gdark);
    errfx=@(optcoeffs)sum((optfx(optcoeffs)-em_resp).^2);
    FMC.objective=errfx;
    FMC.x0=rmcoeffs;
    FMC.lb=[000 2.0000 00 0000 0000 0000 000];
    FMC.ub=[200 4.0001 01 1000 1000 1000 100];
    
    FMC.solver='fmincon';
    FMC.options=optimset('Algorithm','interior-point',...
        'DiffMinChange',1e-16,'Display','iter-detailed',...
        'TolX',1e-40,'TolFun',1e-40,'TolCon',1e-40,...
        'MaxFunEvals',200);
    em_fitcoeffs=fmincon(FMC);
    
    BIPBIP();
    disp(em_fitcoeffs);
    em_fit=riekemodelstim3(em_fitcoeffs,em_tme,em_stm,gdark);
end

toc

%
f3=getfigH(3);
set(get(f3,'XLabel'),'String','Time (s)')
set(get(f3,'YLabel'),'String','i (pA)')


lH=line(em_tme,em_resp,'Parent',f3);
set(lH,'Color','k','DisplayName','response','linewidth',2,'marker','o');
lH=line(em_tme,em_firsttry,'Parent',f3);
set(lH,'Color','r','LineStyle','-','linewidth',2,'marker','none');
lH=line(em_tme,em_fit,'Parent',f3);
set(lH,'Color',[.5 0 .5],'LineStyle','-','DisplayName','CaSlow','linewidth',2);

f4=getfigH(4);
set(get(f4,'XLabel'),'String','Time (s)')
set(get(f4,'YLabel'),'String','R*/timestep')
lH=line(em_tme,em_stm,'Parent',f4);
set(lH,'Color','k','DisplayName','stim');
%%


%% Run Hyst and Sine subtraction and isolate sinusoids
colors=[pmkmp(4); 0 0 0];

f1=getfigH(1);
set(get(f1,'XLabel'),'String','Time (s)')
set(get(f1,'YLabel'),'String','i (pA)')


f2=getfigH(2);
set(get(f2,'XLabel'),'String','Time (s)')
set(get(f2,'YLabel'),'String','i (pA)')

ModelData=NaN(size(HystData.mean(:,1:skippts:end)));
SubData=NaN(size(ModelData));
for i=5:-1:1 %phases
ModelData(i,:)=riekemodelstim3(rmcoeffs,HystData.tAxis(1:skippts:end),HystData.stim(i,1:skippts:end).*TimeStep,gdark);
SubData(i,:)=ModelData(i,:)-ModelData(5,:);

lH=line(HystData.tAxis(1:skippts:end),ModelData(i,:),'Parent',f1);
set(lH,'Color',colors(i,:),'DisplayName','response');

lH=line(HystData.tAxis(1:skippts:end),SubData(i,:),'Parent',f2);
set(lH,'Color',colors(i,:),'DisplayName','response');

end


%%

%% Trying to recreate adaptation kinetics with this particular model
clear I t ios

timestruct.dt=1e-3;          
timestruct.timestart=0;
timestruct.timeon=1;    % in s
timestruct.timeend=5;   % in s

background=0;
Istep=100;
IFlashes=100;
duration=2.5;           % in s

t=timestruct.timestart:timestruct.dt:timestruct.timeend;   % s
I_step=background*ones(1,length(t));   % in R*
I_step(t >= timestruct.timeon & t < timestruct.timeon+duration) = Istep+background;

ios_step=riekemodelstim3(rmcoeffs,t,I_step,gdark);


% Delay=[0.01 0.02 0.04 0.06 0.18 0.36]/timestruct.dt;
Delay=[0.20]/timestruct.dt;
for i=1:length(Delay)
    I=background*ones(1,length(t));   %Td
    I(t >= timestruct.timeon & t < timestruct.timeon+duration) = Istep+background;
    % PreFlash
    I(400:410)=IFlashes+background;
    % OnFlash
    I(1000+Delay(i):1000+Delay(i)+10)=IFlashes+Istep+background;  
    % StepFlash
    I(2800:2810)=IFlashes+Istep+background;
    % OffFlash
    I(3500+Delay(i):3500+Delay(i)+10)=IFlashes+background;
    % PostFlash
    I(4500:4510)=IFlashes+background;
    
    ios=riekemodelstim3(rmcoeffs,t,I,gdark);
    
    fprintf('Done with %g of %g: Delay = %g ms\n',i,length(Delay),Delay(i)/10)
    
    
end

f2=getfigH(2);
lH=line(t,-ios_step,'Parent',f2);
set(lH,'DisplayName','step','Line','-','LineWidth',2,'Marker','none','Color',[.6 .6 .6])
lH=line(t,-ios,'Parent',f2);
set(lH,'DisplayName','stepsandflashes','Line','-','LineWidth',2,'Marker','none','Color',[0 0 0])

f3=getfigH(3);
lH=line(t,I,'Parent',f3);
set(lH,'DisplayName','RodModelAndAK_Stim','Line','-','LineWidth',2,'Marker','none','Color',[0 0 0])

