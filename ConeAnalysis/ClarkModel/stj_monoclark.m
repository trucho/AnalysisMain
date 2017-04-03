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
em_resp=EyeMovementsExample.Mean(1:skippts:end)+5;
% em_resp=-(EyeMovementsExample.Mean(1:skippts:end))*i2V(2);
% em_resp=em_resp+i2V(1);

em_tme=em_tme(1:2550);
em_stm=em_stm(1:2550);
em_resp=em_resp(1:2550);

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
    8.7/1000 ...  tauy
    22/1000 ... tauz
    3.72 ...    ny
    1.73 ...    nz
    80/1000 ...   gamma
    1/1000 ... tauR
    9.04 ...     alpha
    278/1000 ...    beta
    81/1000 ...     gamma2
    0.244 ...     tauzslow
    0.901 ...     nzslow
    ];
% 
ccoeffs=[...
    6.34/1000 ...  tauy
    4.6/1000 ... tauz
    3.49 ...    ny
    3.16 ...    nz
    80/1000 ...   gamma
    1/1000 ... tauR
    10.2 ...     alpha
    444/1000 ...    beta
    285/1000 ...     gamma2
    0.0937 ...     tauzslow
    .912 ...     nzslow
    ];


ccoeffs=[44.8 14.6 430 286 122 36.6  57 206];
ccoeffs=[46.5 951 328 125 752 99.9 448 493];

em_firsttry=cModelUni(ccoeffs,em_tme,em_stm,dt);

runlsq=0;
runfmc=0;

em_fitcoeffs=[];
em_fit=nan(1,length(em_tme));
if runlsq
    % lsq
    fprintf('Started lsq fitting.....\n')
    lsqfun=@(optcoeffs,em_tme)cModelUni(optcoeffs,em_tme,em_stm,dt);
    LSQ.objective=lsqfun;
    LSQ.x0=ccoeffs;
    LSQ.xdata=em_tme;
    LSQ.ydata=em_resp;
    LSQ.lb=[0 0 0 0 0 0 0 0];
%     LSQ.ub=[00001 1000 10000 100 100];
    
    LSQ.solver='lsqcurvefit';
    LSQ.options=optimset('TolX',1e-20,'TolFun',1e-20,'MaxFunEvals',20000);
    em_fitcoeffs=lsqcurvefit(LSQ);
    
%     BIPBIP();
    fprintf('\nccoeffs=[%3.3g %3.3g %3.3g %3.3g %3.3g %3.3g %3.3g %3.3g];\n',em_fitcoeffs)
end

if runfmc
    % fmincon
    fprintf('Started fmincon.....\n')
    optfx=@(optcoeffs)cModelUni(optcoeffs,em_tme,em_stm,dt);
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
    fprintf('\nccoeffs=[%3.3g %3.3g %3.3g %3.3g %3.3g %3.3g %3.3g %3.3g];\n',em_fitcoeffs)
end


em_stm2=[ones(1,1000)*em_stm(1) em_stm];
em_tme2=(1:1:length(em_stm2)).*dt;
em_firsttry2=cModelUni(ccoeffs,em_tme2,em_stm2,dt);
em_firsttry2=em_firsttry2(1001:end);

if ~isempty(em_fitcoeffs)
    em_fit=cModelUni(em_fitcoeffs,em_tme,em_stm,dt);
else
    em_fit=cModelUni(ccoeffs,em_tme,em_stm,dt);
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

if max(em_fit)>1000
    ylim([-10 100])
end

f4=getfigH(4);
set(get(f4,'XLabel'),'String','Time (s)')
set(get(f4,'YLabel'),'String','R*/dt')
lH=line(em_tme,em_stm,'Parent',f4);
set(lH,'Color','k','DisplayName','stim','LineWidth',2);

figure(3)
legend('Data','Guess','Fit')
% BIPBIP()
fprintf('Acabé\n')
