classdef clarkfitGUI < ephysGUI
   properties
       modelFx
       
       ini
       curr
       fit
       upper
       lower
       
       stj_stm
       stj_tme
       stj_resp
       stj_skipts
       dt
       
       stj_ifit
       stj_cfit
       stj_ffit
       
       ak_stm
       ak_stepstm
       ak_tme
       ak_dt
       ak_delays
       ak_iresp
       ak_istep
       ak_iflashes
       
       ak_cresp
       ak_cstep
       ak_cflashes
       
       ak_subflag
       
       cs_stmup
       cs_stmdown
       cs_tme
       cs_dt
       cs_iup
       cs_idown
       
       cs_cup
       cs_cdown
       cs_fup
       cs_fdown
       
       df_stm
       df_tme
       df_resp
       df_dt
       
       df_ifit
       df_cfit
       df_ffit

       n
       names
       tnames
       colors 
       tcolors
   end
   
   methods
       function hGUI=clarkfitGUI(fign)
           hGUI@ephysGUI(fign);
       end
       
       function loadData(hGUI,~,~)
           % DATA LOADING AND INITIAL FITS

           % load saccade trajectory data
           stjdata=load('~/matlab/matlab-analysis/trunk/users/juan/ConeModel/BiophysicalModel/EyeMovementsExample_092413Fc12vClamp.mat');
           stjdata = stjdata.EyeMovementsExample;
           hGUI.stj_skipts=20;
           hGUI.dt=hGUI.stj_skipts*(stjdata.TimeAxis(2)-stjdata.TimeAxis(1));
           
           hGUI.stj_tme=stjdata.TimeAxis(1:hGUI.stj_skipts:end);
           %stimulus is calibrated in R*/s, so for model, have to convert it to R*/dt
           hGUI.stj_stm=stjdata.Stim(1:hGUI.stj_skipts:end).*hGUI.dt;
           hGUI.stj_resp=stjdata.Mean(1:hGUI.stj_skipts:end)+5; % manually correcting trace so that darkness = 0 pA
           
%            hGUI.stj_tme=hGUI.stj_tme(1:2550);
%            hGUI.stj_stm=hGUI.stj_stm(1:2550);
%            hGUI.stj_resp=hGUI.stj_resp(1:length(hGUI.stj_tme)-1);
           
           % initial fit
           tempstm=[ones(1,1000)*hGUI.stj_stm(1) hGUI.stj_stm];
           temptme=(1:1:length(tempstm)).*hGUI.dt;
           hGUI.stj_ifit=hGUI.modelFx(hGUI.ini,temptme,tempstm,hGUI.dt);
           hGUI.stj_ifit=hGUI.stj_ifit(1001:end);
           %current fit
           hGUI.stj_cfit=hGUI.stj_ifit;
           hGUI.stj_ffit=hGUI.stj_ifit;
           

           % dim flash response
           DF=load('/Users/angueyraaristjm/matlab/matlab-analysis/trunk/users/juan/ConeModel/BiophysicalModel/EyeMovementsExampleDF_092413Fc12vClamp.mat');
           DF=DF.DF_raw;
           
           hGUI.df_tme = DF.TimeAxis;
           hGUI.df_dt = (hGUI.df_tme(2)-hGUI.df_tme(1));
           hGUI.df_resp = DF.Mean;
           hGUI.df_stm = zeros(size(hGUI.df_tme)); hGUI.df_stm(10/(1000*hGUI.df_dt)) = 1; %10 ms prepts
           
           tempstm=[zeros(1,2000) hGUI.df_stm];
           temptme=(1:1:length(tempstm)).* hGUI.df_dt;
           tempfit=hGUI.modelFx(hGUI.ini,temptme,tempstm,hGUI.df_dt);
           hGUI.df_ifit = tempfit(10001:end);
           hGUI.df_cfit = hGUI.df_ifit;
           hGUI.df_ffit = hGUI.df_ifit;
           
           
           % adaptation kinetics
           hGUI.akinitial;
           
           % 100% contrast step
           hGUI.csinitial;
       end
       
       function createObjects(hGUI,~,~)
           % define remaining gui properties
           hGUI.colors = pmkmp(hGUI.n,'CubicL');
           hGUI.tcolors = round((pmkmp(hGUI.n,'CubicL'))./1.2.*255);
           hGUI.tnames = regexprep(hGUI.names,'<[^>]*>',''); %initialize
           for i=1:hGUI.n
               hGUI.tnames{i} = sprintf('<html><font color=rgb(%d,%d,%d)>%s</font></html>',...
                   hGUI.tcolors(i,1),hGUI.tcolors(i,2),hGUI.tcolors(i,3),...
                   hGUI.tnames{i});
           end
           
           % GUI OBJECTS
           hGUI.coeffTable;     % table
           hGUI.lsqButton;      % buttons
           hGUI.fmcButton;
           hGUI.okfitButton;
           hGUI.revertButton;
           hGUI.dfnormButton;
           hGUI.createSliders;  % sliders

           % GRAPHS
           
           % stj stim
           hGUI.createPlot(struct('Position',[230 835 450 150]./1000,'tag','stpstim'));
           hGUI.hidex(hGUI.gObj.stpstim)
           hGUI.labely(hGUI.gObj.stpstim,'R*/s')
           hGUI.xlim(hGUI.gObj.stpstim,hGUI.minmax(hGUI.stj_tme))
           
           lH=lineH(hGUI.stj_tme,hGUI.stj_stm/hGUI.dt,hGUI.gObj.stpstim);
           lH.linek;lH.setName('stjstim');lH.h.LineWidth=2;
           
           % stj plot
           hGUI.createPlot(struct('Position',[230 475 450 350]./1000,'tag','stp'));
           hGUI.labelx(hGUI.gObj.stp,'Time (s)')
           hGUI.labely(hGUI.gObj.stp,'i (pA)')
           hGUI.xlim(hGUI.gObj.stp,hGUI.minmax(hGUI.stj_tme))
           hGUI.ylim(hGUI.gObj.stp,[-10 80])
           
           lH=lineH(hGUI.stj_tme,hGUI.stj_resp,hGUI.gObj.stp); % stj response
           lH.linek;lH.setName('stjresp');lH.h.LineWidth=2;
           lH=lineH(hGUI.stj_tme,hGUI.stj_ifit,hGUI.gObj.stp); % stj initial fit
           lH.line;lH.setName('stj_ifit');lH.h.LineWidth=1;
           lH.color([.5 .5 .5]);
           lH=lineH(hGUI.stj_tme,hGUI.stj_ffit,hGUI.gObj.stp); % stj fit fit
           lH.lineb;lH.h.LineWidth=2;lH.setName('stj_ffit');
           lH=lineH(hGUI.stj_tme,hGUI.stj_cfit,hGUI.gObj.stp); % stj current fit
           lH.liner;lH.setName('stj_cfit');lH.h.LineWidth=1;
           
           
           % df plot
           hGUI.createPlot(struct('Position',[730 475 255 200]./1000,'tag','dfp'));
           hGUI.labelx(hGUI.gObj.dfp,'Time (s)')
           hGUI.labely(hGUI.gObj.dfp,'i (pA)')
%            hGUI.xlim(hGUI.gObj.dfp,hGUI.minmax(hGUI.df_tme));
           hGUI.xlim(hGUI.gObj.dfp,[0 0.4]);
           
           lH = lineH(hGUI.df_tme,hGUI.df_resp,hGUI.gObj.dfp);  % df response
           lH.lineg;lH.h.LineWidth=1;lH.setName('df');
           lH = lineH(hGUI.df_tme,hGUI.df_ifit,hGUI.gObj.dfp);  % df initial fit
           lH.lineg;lH.h.LineWidth=2;lH.setName('df_ifit');
           lH = lineH(hGUI.df_tme,hGUI.df_ffit,hGUI.gObj.dfp);  % df fit fit
           lH.lineb;lH.h.LineWidth=2;lH.setName('df_ffit');
           lH = lineH(hGUI.df_tme,hGUI.df_cfit,hGUI.gObj.dfp);  % df current fit
           lH.liner;lH.h.LineWidth=2;lH.setName('df_cfit');
           
           
           
           % ak plot
           hGUI.createPlot(struct('Position',[230 065 750 350]./1000,'tag','ak'));
           hGUI.labelx(hGUI.gObj.ak,'Time (s)')
           hGUI.labely(hGUI.gObj.ak,'i (pA)')
           hGUI.xlim(hGUI.gObj.ak,[min(hGUI.ak_tme) max(hGUI.ak_tme)])
           
           if hGUI.ak_subflag
               hGUI.akploti_flashes;
           else
               hGUI.akploti;
           end
           
           % cs plot
           hGUI.createPlot(struct('Position',[730 730 255 250]./1000,'tag','csp'));
           hGUI.labelx(hGUI.gObj.csp,'Time (s)')
           hGUI.labely(hGUI.gObj.csp,'i (pA)')
           
           hGUI.csploti;

       end
       
       function createSliders(hGUI)
           sliders = struct('Orientation',{0 0 0 0 0 0 0 0},...
               'Minimum',{0 0 0 0 0 0 0 0},...
               'Maximum',{1000 1000 1000 1000 1000 1000 1000 1000},...
               'Callback',[],...
               'Position',[],...
               'Tag',[],...
               'Color',[],...
               'ToolTipText',[],...
               'Value',[]);
           
           for i=1:hGUI.n
               sliders(i).Callback = @hGUI.slidercCall;
               sliders(i).Value = hGUI.curr(i);
               sliders(i).Position = [2 650-(58*i) 190 60]./1000;
               sliders(i).tag = sprintf('slider%02g',i);
               sliders(i).Color = hGUI.colors(i,:)./1.2;
               sliders(i).ToolTipText = hGUI.tnames{i};
               
               hGUI.jSlider(sliders(i));
           end
           
       end
       
       function dfnormButton(hGUI)
           dfnstruct = struct;
           dfnstruct.tag = 'dfnormButton';
           dfnstruct.Callback = @hGUI.dfNorm;
           dfnstruct.Position = [930 620 50 50]./1000;
           dfnstruct.string = 'Norm';
           dfnstruct.Style = 'togglebutton';
           
           hGUI.createButton(dfnstruct);
       end
       
       function okfitButton(hGUI)
           okfittruct = struct;
           okfittruct.tag = 'okfitButton';
           okfittruct.Callback = @hGUI.okFit;
           okfittruct.Position = [90 955 100 40]./1000;
           okfittruct.string = 'accept fit';
           
           hGUI.createButton(okfittruct);
       end
       
       function revertButton(hGUI)
           okfittruct = struct;
           okfittruct.tag = 'revertButton';
           okfittruct.Callback = @hGUI.revertFit;
           okfittruct.Position = [90 915 100 40]./1000;
           okfittruct.string = 'revert to ini';
           
           hGUI.createButton(okfittruct);
       end
       
       function lsqButton(hGUI)
           lsqstruct = struct;
           lsqstruct.tag = 'lsqButton';
           lsqstruct.Callback = @hGUI.runLSQ;
           lsqstruct.Position = [5 955 80 40]./1000;
           lsqstruct.string = 'lsq';
           
           hGUI.createButton(lsqstruct);
       end
       
       function fmcButton(hGUI)
           fmcstruct = struct;
           fmcstruct.tag = 'fmcButton';
           fmcstruct.Callback = @hGUI.runFMC;
           fmcstruct.Position = [5 915 80 40]./1000;
           fmcstruct.string = 'fmc';
           
           hGUI.createButton(fmcstruct);
       end
           
       function coeffTable(hGUI)
           tableinput = struct;
           tableinput.tag = 'coefftable';
           tableinput.Position = [5, 650, 187.3, 262]./1000;
           tableinput.ColumnName = {'initial','curr','fit'};
           tableinput.RowName = hGUI.tnames;
           tableinput.Data = [hGUI.ini;hGUI.curr;hGUI.fit]';
           tableinput.headerWidth = 24;
           ColWidth = 60;
           tableinput.ColumnWidth = {ColWidth,ColWidth,ColWidth};
           
           hGUI.infoTable(tableinput);
       end
       
       % callback functions
       
       % overriding detectKey to run fitting just once
       function keyPress = detectKey(hGUI, ~, handles)
            % determine the key that was pressed
            keyPress = handles.Key;
            if strcmp(keyPress,'return')
                hGUI.updatePlots;
            end
        end
       
      function slidercCall(hGUI,~,~)
           if isfield(hGUI.gObj,sprintf('slider%02g',hGUI.n)) %check if all sliders have been created
               newcurr = NaN(1,hGUI.n);
               for i=1:hGUI.n
                   slidername = sprintf('slider%02g',i);
                   newcurr(i) = hGUI.gObj.(slidername).Value;
               end
               hGUI.gObj.infoTable.Data(:,2) = newcurr;
               hGUI.curr = newcurr;
               
           end
       end
       
       function resetSliders(hGUI,~,~)
           for i=1:hGUI.n
               slidername = sprintf('slider%02g',i);
               hGUI.gObj.(slidername).Value = hGUI.curr(i);
           end
       end
       
       function dfNorm(hGUI,~,~)
           dfH = findobj(hGUI.gObj.dfp,'tag','df');
           dfiH = findobj(hGUI.gObj.dfp,'tag','df_ifit');
           dfcH = findobj(hGUI.gObj.dfp,'tag','df_cfit');
           dffH = findobj(hGUI.gObj.dfp,'tag','df_ffit');
           if hGUI.gObj.dfnormButton.Value == 0
               hGUI.gObj.dfnormButton.String = 'Norm';
               dfH.YData = hGUI.df_resp;
               dfiH.YData = hGUI.df_ifit;
               dfcH.YData = hGUI.df_cfit;
               dffH.YData = hGUI.df_ffit;
           else
               hGUI.gObj.dfnormButton.String = 'Original';
               dfH.YData = normalize(hGUI.df_resp);
               dfiH.YData = normalize(hGUI.df_ifit);
               dfcH.YData = normalize(hGUI.df_cfit);
               dffH.YData = normalize(hGUI.df_ffit);
          end
       end
       function updatePlots(hGUI,~,~)
           % saccade trajectory
           lH = findobj('tag','stj_cfit');
           tempstm=[ones(1,1000)*hGUI.stj_stm(1) hGUI.stj_stm];
           temptme=(1:1:length(tempstm)).*hGUI.dt;
           tempfit=hGUI.modelFx(hGUI.curr,temptme,tempstm,hGUI.dt);
           hGUI.stj_cfit=tempfit(1001:end);
           
           lH.YData = hGUI.stj_cfit;
           lH.LineWidth = 2;
           
           lH = findobj('tag','stj_ffit');
           lH.LineWidth = 2;
           
           % constrast steps
           hGUI.cscurrent;
           csH = findobj(hGUI.gObj.csp,'tag','cs_cup');
           csH.YData = hGUI.cs_cup;
           csH.LineWidth=5;
           
           csH = findobj(hGUI.gObj.csp,'tag','cs_cdown');
           csH.YData = hGUI.cs_cdown;
           csH.LineWidth=5;
       end
       
       function runLSQ(hGUI,~,~)
           % least-squares fitting
           fprintf('Started lsq fitting.....\n')
           lsqfun=@(optcoeffs,tme)hGUI.modelFx(optcoeffs,hGUI.stj_tme,hGUI.stj_stm,hGUI.dt);
           LSQ.objective=lsqfun;
           LSQ.x0=hGUI.curr;
           LSQ.xdata=hGUI.stj_tme;
           LSQ.ydata=hGUI.stj_resp;
           LSQ.lb=hGUI.lower;
           LSQ.ub=hGUI.upper;
           
           LSQ.solver='lsqcurvefit';
           LSQ.options=optimset('TolX',1e-20,'TolFun',1e-20,'MaxFunEvals',500);
           hGUI.fit=lsqcurvefit(LSQ);
           hGUI.showResults(hGUI.fit);
           
           hGUI.gObj.infoTable.Data(:,3) = hGUI.fit;
           hGUI.updateFits;
       end
       
       function runFMC(hGUI,~,~)
           % fmincon minimizing squared distances
           fprintf('Started fmincon.....\n')
           optfx=@(optcoeffs)hGUI.modelFx(optcoeffs,hGUI.df_tme,hGUI.df_stm,hGUI.df_dt);
           errfx=@(optcoeffs)sum((optfx(optcoeffs)-hGUI.df_resp).^2);
           FMC.objective=errfx;
           FMC.x0=hGUI.curr;
           FMC.lb=hGUI.lower;
           FMC.ub=hGUI.upper;
           
           FMC.solver='fmincon';
           FMC.options=optimset('Algorithm','interior-point',...
               'DiffMinChange',1e-16,'Display','iter-detailed',...
               'TolX',1e-20,'TolFun',1e-20,'TolCon',1e-20,...
               'MaxFunEvals',500);
           hGUI.fit=fmincon(FMC);
           hGUI.showResults(hGUI.fit);
           
           hGUI.gObj.infoTable.Data(:,3) = hGUI.fit;
           hGUI.updateFits;
       end
       
       function revertFit(hGUI,~,~)
           hGUI.curr=hGUI.ini;
           hGUI.gObj.infoTable.Data(:,2)=hGUI.ini;
           % redo stj
           hGUI.updatePlots;
           
           % recalculate df
           hGUI.dfcurrent;
           %replace df plots
           dfH = findobj(hGUI.gObj.dfp,'tag','df_ffit');
           dfH.YData = hGUI.df_ffit;
           dfH.LineWidth=1;
           
           %recalculate ak
           hGUI.akcurrent; 
           % replace ak plots
           if hGUI.ak_subflag
               % just flashes
               for i = 1:length(hGUI.ak_delays)
                   lH = findobj(hGUI.gObj.ak,'DisplayName',sprintf('ak_cstep%02g',i));
                   lH.YData = hGUI.ak_cflashes(i,:);
               end
           else
               % step + flashes
               lH = findobj(hGUI.gObj.ak,'DisplayName',sprintf('ak_cstep'));
               lH.YData = hGUI.ak_cstep;
               for i = 1:length(hGUI.ak_delays)
                   lH = findobj(hGUI.gObj.ak,'DisplayName',sprintf('ak_cstep%02g',i));
                   lH.YData = hGUI.ak_cresp(i,:);
               end
           end

           % reset sliders
           hGUI.resetSliders;
       end
       
       function okFit(hGUI,~,~)
           if sum(~isnan(hGUI.gObj.infoTable.Data(:,3)))==size(hGUI.gObj.infoTable.Data(:,3),1)
               hGUI.curr=hGUI.gObj.infoTable.Data(:,3);
               hGUI.gObj.infoTable.Data(:,2)=hGUI.curr;
           end
           % redo stj
           hGUI.updatePlots;
           
           % recalculate df
           hGUI.dfcurrent;
           %replace df plots
           dfH = findobj(hGUI.gObj.dfp,'tag','df_ffit');
           dfH.YData = hGUI.df_ffit;
           dfH.LineWidth=1;
           
           %recalculate ak
           hGUI.akcurrent; 
           % replace ak plots
           if hGUI.ak_subflag
               % just flashes
               for i = 1:length(hGUI.ak_delays)
                   lH = findobj(hGUI.gObj.ak,'DisplayName',sprintf('ak_cstep%02g',i));
                   lH.YData = hGUI.ak_cflashes(i,:);
               end
           else
               % step + flashes
               lH = findobj(hGUI.gObj.ak,'DisplayName',sprintf('ak_cstep'));
               lH.YData = hGUI.ak_cstep;
               for i = 1:length(hGUI.ak_delays)
                   lH = findobj(hGUI.gObj.ak,'DisplayName',sprintf('ak_cstep%02g',i));
                   lH.YData = hGUI.ak_cresp(i,:);
               end
           end
           
           
           % reset sliders
           hGUI.resetSliders;
       end
       
       function updateFits(hGUI,~,~)
           % stj
           lH = findobj('tag','stj_ffit');
           
           tempstm=[ones(1,1000)*hGUI.stj_stm(1) hGUI.stj_stm];
           temptme=(1:1:length(tempstm)).*hGUI.dt;
           tempfit=hGUI.modelFx(hGUI.fit,temptme,tempstm,hGUI.dt);
           hGUI.stj_ffit=tempfit(1001:end);
           
           lH.YData = hGUI.stj_ffit;
           lH.LineWidth=5;
           
           % dim flash
           tempstm=[zeros(1,2000) hGUI.df_stm];
           temptme=(1:1:length(tempstm)).* hGUI.df_dt;
           tempfit=hGUI.modelFx(hGUI.fit,temptme,tempstm,hGUI.df_dt);
           hGUI.df_ffit = tempfit(10001:end); 
           
           dfH = findobj(hGUI.gObj.dfp,'tag','df_ffit');
           dfH.YData = hGUI.df_ffit;
           dfH.LineWidth=5;
           % adaptation kinetics
           % will update when fit is accepted by just modifying current
           
           % constrast steps
           hGUI.csfit;
           csH = findobj(hGUI.gObj.csp,'tag','cs_fup');
           csH.YData = hGUI.cs_fup;
           csH.LineWidth=5;
           
           csH = findobj(hGUI.gObj.csp,'tag','cs_fdown');
           csH.YData = hGUI.cs_fdown;
           csH.LineWidth=5;
       end
       
       function akinitial(hGUI,~,~)
           akstruct = hGUI.akparams;
           
           Ib=0;
           Istep=10; %100;
           IFlashes=20; %150;
           
           t=akstruct.start:akstruct.dt:akstruct.end;   % s
           I_step=Ib*ones(1,length(t));   % in R*
           I_step(t >= akstruct.step_on & t < akstruct.step_off) = Istep+Ib;
           
           ios_step=hGUI.modelFx(hGUI.ini,t,I_step,akstruct.dt);

           Stim = NaN(length(akstruct.delays),length(I_step));
           ios = NaN(length(akstruct.delays),length(I_step));
           ios_f = NaN(length(akstruct.delays),length(I_step));
           for i=1:length(akstruct.delays)
               I=I_step;
               % PreFlash
               ind=find(t >= akstruct.flash_on(1),1,'first');
               I(ind:ind+(akstruct.flash_dur/akstruct.dt))=IFlashes+Ib;
               %     I(t >= tstruct.flash_on(1) & t <= tstruct.flash_off(1))=IFlashes+Ib;
               % OnFlash
               ind=find(t >= akstruct.flash_on(2)+akstruct.delays(i),1,'first');
               I(ind:ind+(akstruct.flash_dur/akstruct.dt))=IFlashes+Istep+Ib;
               % StepFlash
               ind=find(t >= akstruct.flash_on(3));
               I(ind:ind+(akstruct.flash_dur/akstruct.dt))=IFlashes+Istep+Ib;
               % OffFlash
               ind=find(t >= akstruct.flash_on(4)+akstruct.delays(i),1,'first');
               I(ind:ind+(akstruct.flash_dur/akstruct.dt))=IFlashes+Ib;
               % PostFlash
               ind=find(t >= akstruct.flash_on(5),1,'first');
               I(ind:ind+(akstruct.flash_dur/akstruct.dt))=IFlashes+Ib;
               
               Stim(i,:)=I;
               
               ios(i,:)=hGUI.modelFx(hGUI.ini,t,I,akstruct.dt);
               
               ios_f(i,:)=ios(i,:)-ios_step; 
           end
           
           hGUI.ak_dt = akstruct.dt;
           hGUI.ak_tme = t;
           hGUI.ak_stm = Stim;
           hGUI.ak_stepstm = I_step;
           hGUI.ak_delays = akstruct.delays;
           hGUI.ak_istep = ios_step;
           hGUI.ak_iresp = ios;
           hGUI.ak_iflashes = ios_f;
           
           hGUI.ak_cstep = ios_step;
           hGUI.ak_cresp = ios;
           hGUI.ak_cflashes = ios_f;
       end
       
       function csinitial(hGUI,~,~)
           csstruct = hGUI.csparams;
           
           Ib=60;
           Istep=60; %100;
           
           t=csstruct.start:csstruct.dt:csstruct.end;   % s
           Iup=Ib*ones(1,length(t));   % in R*/dt
           Iup(t >= csstruct.step_on & t < csstruct.step_off) = Ib + Istep;
           Idown=Ib*ones(1,length(t));   % in R*/dt
           Idown(t >= csstruct.step_on & t < csstruct.step_off) = Ib - Istep;
           
           tempstm=[ones(1,10000)*Ib Iup];
           temptme=(1:1:length(tempstm)).* csstruct.dt;
           tempfit=hGUI.modelFx(hGUI.ini,temptme,tempstm,csstruct.dt);
           ios_up = tempfit(10001:end);
           
           tempstm=[ones(1,10000)*Ib Idown];
           tempfit=hGUI.modelFx(hGUI.ini,temptme,tempstm,csstruct.dt);
           ios_down = tempfit(10001:end);
           
           hGUI.cs_stmup = Iup;
           hGUI.cs_stmdown = Idown;
           hGUI.cs_tme = t;
           hGUI.cs_dt = csstruct.dt;
           hGUI.cs_iup = ios_up;
           hGUI.cs_idown = ios_down;
           
           hGUI.cs_cup = ios_up;
           hGUI.cs_cdown = ios_down;
           hGUI.cs_fup = ios_up;
           hGUI.cs_fdown = ios_down;
       end
       
       function akcurrent(hGUI,~,~)
           hGUI.ak_cstep=hGUI.modelFx(hGUI.curr,hGUI.ak_tme,hGUI.ak_stepstm,hGUI.ak_dt);
           
           hGUI.ak_cresp = NaN(length(hGUI.ak_delays),length(hGUI.ak_stepstm));
           hGUI.ak_cflashes = NaN(length(hGUI.ak_delays),length(hGUI.ak_stepstm));
           for i=1:length(hGUI.ak_delays)    
               hGUI.ak_cresp(i,:)=hGUI.modelFx(hGUI.curr,hGUI.ak_tme,hGUI.ak_stm(i,:),hGUI.ak_dt);
               hGUI.ak_cflashes(i,:)=hGUI.ak_cresp(i,:)-hGUI.ak_cstep; 
           end
       end
       
       function cscurrent(hGUI,~,~)
           tempstm=[ones(1,10000)*hGUI.cs_stmup(1) hGUI.cs_stmup];
           temptme=(1:1:length(tempstm)).* hGUI.cs_dt;
           tempfit=hGUI.modelFx(hGUI.curr,temptme,tempstm,hGUI.cs_dt);
           hGUI.cs_cup = tempfit(10001:end);
           
           tempstm=[ones(1,10000)*hGUI.cs_stmup(1) hGUI.cs_stmdown];
           tempfit=hGUI.modelFx(hGUI.curr,temptme,tempstm,hGUI.cs_dt);
           hGUI.cs_cdown = tempfit(10001:end);
       end
       
       function csfit(hGUI,~,~)
           tempstm=[ones(1,10000)*hGUI.cs_stmup(1) hGUI.cs_stmup];
           temptme=(1:1:length(tempstm)).* hGUI.cs_dt;
           tempfit=hGUI.modelFx(hGUI.fit,temptme,tempstm,hGUI.cs_dt);
           hGUI.cs_fup = tempfit(10001:end);
           
           tempstm=[ones(1,10000)*hGUI.cs_stmup(1) hGUI.cs_stmdown];
           tempfit=hGUI.modelFx(hGUI.fit,temptme,tempstm,hGUI.cs_dt);
           hGUI.cs_fdown = tempfit(10001:end);
       end
       
       function dfcurrent(hGUI,~,~)
           tempstm=[zeros(1,2000) hGUI.df_stm];
           temptme=(1:1:length(tempstm)).* hGUI.df_dt;
           tempfit=hGUI.modelFx(hGUI.curr,temptme,tempstm,hGUI.df_dt);
           hGUI.df_cfit = tempfit(10001:end);
       end
       
       function akploti(hGUI,~,~)
           % plot initial fit
           lH=lineH(hGUI.ak_tme,hGUI.ak_istep,hGUI.gObj.ak);
           lH.linek;lH.h.LineWidth=2;lH.setName('ak_istep');
           for i = 1:length(hGUI.ak_delays)
               ccolor=[0 0 0] + (.75/length(hGUI.ak_delays))*i;
               lH=lineH(hGUI.ak_tme,hGUI.ak_iresp(i,:),hGUI.gObj.ak);
               lH.linek;lH.color(ccolor);lH.h.LineWidth=2;lH.setName(sprintf('ak_istep%02g',i));
           end
       
           % preplot current fit
           lH=lineH(hGUI.ak_tme,hGUI.ak_cstep,hGUI.gObj.ak);
           lH.liner;lH.h.LineWidth=1;lH.setName('ak_cstep');
           for i = 1:length(hGUI.ak_delays)
               ccolor=[.75-(.75/length(hGUI.ak_delays))*i 0 0] ;
               lH=lineH(hGUI.ak_tme,hGUI.ak_cresp(i,:),hGUI.gObj.ak);
               lH.liner;lH.color(ccolor);lH.h.LineWidth=1;lH.setName(sprintf('ak_cstep%02g',i));
           end
       end
       
       function akploti_flashes(hGUI,~,~)
           % plot initial fit
           for i = 1:length(hGUI.ak_delays)
               ccolor=[0 0 0] + (.75/length(hGUI.ak_delays))*i;
               lH=lineH(hGUI.ak_tme,hGUI.ak_iflashes(i,:),hGUI.gObj.ak);
               lH.linek;lH.color(ccolor);lH.h.LineWidth=2;lH.setName(sprintf('ak_istep%02g',i));
           end
           % preplot current fit
           for i = 1:length(hGUI.ak_delays)
               ccolor=[.75-(.75/length(hGUI.ak_delays))*i 0 0] ;
               lH=lineH(hGUI.ak_tme,hGUI.ak_iflashes(i,:),hGUI.gObj.ak);
               lH.liner;lH.color(ccolor);lH.h.LineWidth=1;lH.setName(sprintf('ak_cstep%02g',i));
           end
       end
       
       function csploti(hGUI,~,~)
           % plot initial fit
           lH=lineH(hGUI.cs_tme,hGUI.cs_iup,hGUI.gObj.csp);
           lH.lineg;lH.h.LineWidth=2;lH.setName('cs_iup');
           lH=lineH(hGUI.cs_tme,hGUI.cs_idown,hGUI.gObj.csp);
           lH.lineg;lH.h.LineWidth=2;lH.setName('cs_idown');
           % preplot fit fit
           lH=lineH(hGUI.cs_tme,hGUI.cs_cup,hGUI.gObj.csp);
           lH.lineb;lH.h.LineWidth=2;lH.setName('cs_fup');
           lH=lineH(hGUI.cs_tme,hGUI.cs_cdown,hGUI.gObj.csp);
           lH.lineb;lH.h.LineWidth=2;lH.setName('cs_fdown');
           % preplot current fit
           lH=lineH(hGUI.cs_tme,hGUI.cs_cup,hGUI.gObj.csp);
           lH.liner;lH.h.LineWidth=2;lH.setName('cs_cup');
           lH=lineH(hGUI.cs_tme,hGUI.cs_cdown,hGUI.gObj.csp);
           lH.liner;lH.h.LineWidth=2;lH.setName('cs_cdown');
       end
   end
   
   methods (Static=true)
       function akstruct = akparams()
           akstruct=struct;
           
           akstruct.dt=1e-3;  %in s
           akstruct.start=0; %in s
           akstruct.end=6;   % in s
           
           akstruct.step_on=1.5;    % in s
           akstruct.step_dur=2; %in s
           akstruct.step_off=akstruct.step_on+akstruct.step_dur;    % in s
           
           
           akstruct.flash_on=[.4 akstruct.step_on akstruct.step_on+1.5 akstruct.step_off akstruct.step_off+1.5]; %in s
           akstruct.flash_dur=0.01; %in s
           akstruct.flash_off=akstruct.flash_on+akstruct.flash_dur; %in s
           
           akstruct.delays=[0.01:0.1:0.90];
       end
       
       function csstruct = csparams()
           csstruct=struct;
           
           csstruct.dt=1e-3;  %in s
           csstruct.start=0; %in s
           csstruct.end=2;   % in s
           
           csstruct.step_on=0.5;    % in s
           csstruct.step_dur=1; %in s
           csstruct.step_off=csstruct.step_on+csstruct.step_dur;    % in s
       end
       
       function showResults(fitcoeffs)
           fprintf('\nccoeffs=[');fprintf('%04.3g,',fitcoeffs);fprintf('];\n')
       end
   end
   
end
