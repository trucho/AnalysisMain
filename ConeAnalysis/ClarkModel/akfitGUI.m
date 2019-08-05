classdef akfitGUI < ephysGUI
    % still to do:
        % on and off plots
        % calculate adaptation taus
        % sub class for other models
   properties
       modelFx
       i2V
       plotFlag
       
       ini
       curr
       fit
       upper
       lower
       
       tme
       skipts
       dt
       ddelta
       dfix
       dstep
       dgap
       didelta
       difix
       distep
       digap
       
       s_stm
       sf_stm
       f_stm
       
       s
       s_ifit
       s_cfit
       s_ffit
       
       sf
       sf_ifit
       sf_cfit
       sf_ffit
       
       f
       f_ifit
       f_cfit
       f_ffit
       
       ftme
       
       fon
       fon_ifit
       fon_cfit
       fon_ffit
       
       foff
       foff_ifit
       foff_cfit
       foff_ffit
       
       ffix
       ffix_ifit
       ffix_cfit
       ffix_ffit
       
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
       wcolors
       tcolors
       
       pcolors
       pwcolors
       
       nf
   end
   
   methods
       function hGUI=akfitGUI(fign)
           hGUI@ephysGUI(fign);
           
           hGUI.pcolors = pmkmp(5,'CubicLQuarter');
           hGUI.pwcolors = whithen(hGUI.pcolors);
           hGUI.ddelta = [10,20,40,80,160]./1000;
           hGUI.dfix = [300,1290,2290]./1000;
           hGUI.dstep = [500,1500]./1000;
           hGUI.dgap = 500./1000;
       end
       
       function loadData(hGUI,~,~)
           % DATA LOADING AND INITIAL FITS
           akdata = load('~/matlab/AnalysisMain/ConeAnalysis/ClarkModel/AK_example.mat');
           akdata = akdata.AK_example;
           hGUI.skipts=1;
           hGUI.dt=hGUI.skipts*(akdata.tAxis(2)-akdata.tAxis(1));

           hGUI.didelta = round(hGUI.ddelta/hGUI.dt);
           hGUI.difix = round(hGUI.dfix/hGUI.dt);
           hGUI.distep = round(hGUI.dstep/hGUI.dt);
           hGUI.digap = round(hGUI.dgap/hGUI.dt);
           
           hGUI.tme=akdata.tAxis(1:hGUI.skipts:end);
           hGUI.tme = hGUI.tme+.5;
           hGUI.nf = size(akdata.Flash,1);
           
           %stimulus is calibrated in R*/s, so for model, have to convert it to R*/dt
           hGUI.s_stm=akdata.StepStim(1,1:hGUI.skipts:end).*hGUI.dt;
           hGUI.f_stm = (akdata.FlashStim(:,1:hGUI.skipts:end)+repmat(akdata.FlashLockedStim(:,1:hGUI.skipts:end),hGUI.nf,1))*100.*hGUI.dt; % 100 converts from R*/flash(10ms) to R*/s
           hGUI.sf_stm=repmat(hGUI.s_stm,hGUI.nf,1)+hGUI.f_stm;
           
           hGUI.s=(akdata.Step(:,1:hGUI.skipts:end)./hGUI.i2V(2)) - hGUI.i2V(1);
           hGUI.sf=(akdata.Flash(:,1:hGUI.skipts:end)./hGUI.i2V(2)) - hGUI.i2V(1);
           hGUI.f = hGUI.subflashes(hGUI.sf,hGUI.s);
           
           % initial fit
           tempstm=[ones(1,1000)*hGUI.s_stm(1) hGUI.s_stm];
           temptme=(1:1:length(tempstm)).*hGUI.dt;
           tempfit=hGUI.modelFx(hGUI.ini,temptme,tempstm,hGUI.dt);
           hGUI.s_ifit=tempfit(1001:end);
           hGUI.s_cfit=hGUI.s_ifit;
           hGUI.s_ffit=hGUI.s_ifit;
           
           for i=1:hGUI.nf
               tempstm=[ones(1,1000)*hGUI.sf_stm(i,1) hGUI.sf_stm(i,:)];
               temptme=(1:1:length(tempstm)).*hGUI.dt;
               tempfit=hGUI.modelFx(hGUI.ini,temptme,tempstm,hGUI.dt);
               hGUI.sf_ifit(i,:)=tempfit(1001:end);
               hGUI.sf_cfit(i,:)=hGUI.sf_ifit(i,:);
               hGUI.sf_ffit(i,:)=hGUI.sf_ifit(i,:);
           end

           hGUI.f_ifit = hGUI.subflashes(hGUI.sf_ifit,hGUI.s_ifit);
           hGUI.f_cfit = hGUI.subflashes(hGUI.sf_cfit,hGUI.s_cfit);
           hGUI.f_ffit = hGUI.subflashes(hGUI.sf_ffit,hGUI.s_ffit);
           
           
           % initialize
           hGUI.fon = NaN(hGUI.nf,hGUI.digap);
           hGUI.fon_ifit = NaN(hGUI.nf,hGUI.digap);
           hGUI.fon_cfit = NaN(hGUI.nf,hGUI.digap);
           hGUI.fon_ffit = NaN(hGUI.nf,hGUI.digap);
           
           hGUI.foff = NaN(hGUI.nf,hGUI.digap);
           hGUI.foff_ifit = NaN(hGUI.nf,hGUI.digap);
           hGUI.foff_cfit = NaN(hGUI.nf,hGUI.digap);
           hGUI.foff_ffit = NaN(hGUI.nf,hGUI.digap);
           
           hGUI.ffix = NaN(2,hGUI.digap);
           hGUI.ffix_ifit = NaN(2,hGUI.digap);
           hGUI.ffix_cfit = NaN(2,hGUI.digap);
           hGUI.ffix_ffit = NaN(2,hGUI.digap);
           
           hGUI.extractFlashes(); %Juan
           
           % dim flash response
           DF=load('/Users/angueyraaristjm/matlab/matlab-analysis/trunk/users/juan/ConeModel/BiophysicalModel/EyeMovementsExampleDF_092413Fc12vClamp.mat');
           DF=DF.DF_raw;
           
           hGUI.df_tme = DF.TimeAxis;
           hGUI.df_dt = (hGUI.df_tme(2)-hGUI.df_tme(1));
%            hGUI.df_resp = DF.Mean - hGUI.i2V(1) + 1.2;
%            hGUI.df_resp = DF.Mean - hGUI.i2V(1)+ 0.81;
           hGUI.df_resp = DF.Mean - hGUI.i2V(1)+ 0;
           hGUI.df_stm = zeros(size(hGUI.df_tme)); hGUI.df_stm(10/(1000*hGUI.df_dt)) = 1; %10 ms prepts
           
           tempstm=[zeros(1,40000) hGUI.df_stm];
           temptme=(1:1:length(tempstm)).* hGUI.df_dt;
           tempfit=hGUI.modelFx(hGUI.ini,temptme,tempstm,hGUI.df_dt);
           hGUI.df_ifit = tempfit(40001:end);
           hGUI.df_cfit = hGUI.df_ifit;
           hGUI.df_ffit = hGUI.df_ifit;
           
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
           h = 250;
           w1 = 550;
           w2 = 275;
           l1 = 230;
           l2 = l1+w2+45;
           t1 = 920;
           t2 = 655;
           t3 = 360;
           t4 = 50;
           
           % stim
           hGUI.createPlot(struct('Position',[l1 t1 w1 60]./1000,'tag','p_stim'));
           hGUI.hidex(hGUI.gObj.p_stim)
           hGUI.labely(hGUI.gObj.p_stim,'R*/s')
           hGUI.xlim(hGUI.gObj.p_stim,hGUI.minmax(hGUI.tme))
           hGUI.ylim(hGUI.gObj.p_stim,hGUI.minmax(hGUI.sf_stm)./hGUI.dt)
           
           lH=lineH(hGUI.tme,hGUI.s_stm/hGUI.dt,hGUI.gObj.p_stim);
           lH.linek;lH.setName('stim_s');lH.h.LineWidth=2;
           
           for i=1:hGUI.nf
               lH=lineH(hGUI.tme,hGUI.sf_stm(i,:)/hGUI.dt,hGUI.gObj.p_stim);
               lH.line;lH.color(hGUI.pcolors(i,:));lH.setName(sprintf('stim_f%02g',i));lH.h.LineWidth=1;
           end
           
           % responses
           hGUI.createPlot(struct('Position',[l1 t2 w1 h]./1000,'tag','p_resp'));
           hGUI.labelx(hGUI.gObj.p_resp,'Time (s)')
           hGUI.labely(hGUI.gObj.p_resp,'i (pA)')
           hGUI.xlim(hGUI.gObj.p_resp,hGUI.minmax(hGUI.tme))
%            hGUI.ylim(hGUI.gObj.p_resp,[-10 80])
                     
           for i = 1:hGUI.nf
              lH=lineH(hGUI.tme,hGUI.sf(i,:),hGUI.gObj.p_resp); % response
              lH.line;lH.color(hGUI.pwcolors(i,:));lH.setName(sprintf('sf%02g',i));lH.h.LineWidth=1;
           end
           lH=lineH(hGUI.tme,hGUI.s,hGUI.gObj.p_resp); % response
           lH.lineg;lH.setName('s');lH.h.LineWidth=2;
           
           
           for i = 1:hGUI.nf
              lH=lineH(hGUI.tme,hGUI.sf_ifit(i,:),hGUI.gObj.p_resp); % response
              lH.line;lH.color(hGUI.pcolors(i,:));lH.setName(sprintf('sf_ifit%02g',i));lH.h.LineWidth=2;
           end
           lH=lineH(hGUI.tme,hGUI.s_ifit,hGUI.gObj.p_resp); % initial fit
           lH.linek;lH.setName('s_ifit');lH.h.LineWidth=2;
           
           % sub flashes
           hGUI.createPlot(struct('Position',[l1 t3 w1 h]./1000,'tag','p_subf'));
           hGUI.labelx(hGUI.gObj.p_subf,'Time (s)')
           hGUI.labely(hGUI.gObj.p_subf,'i (pA)')
%            hGUI.xlim(hGUI.gObj.pstim,hGUI.minmax(hGUI.tme2))           
           for i = hGUI.nf:-1:1
              lH=lineH(hGUI.tme,hGUI.f(i,:),hGUI.gObj.p_subf); % response
              lH.line;lH.color(hGUI.pwcolors(i,:));lH.setName(sprintf('f%02g',i));lH.h.LineWidth=1;
           end
           
           for i = hGUI.nf:-1:1
              lH=lineH(hGUI.tme,hGUI.f_ifit(i,:),hGUI.gObj.p_subf); % response
              lH.line;lH.color(hGUI.pcolors(i,:));lH.setName(sprintf('f_ifit%02g',i));lH.h.LineWidth=2;
           end
           

           
           % on flashes
           hGUI.createPlot(struct('Position',[l1 t4 w2 h]./1000,'tag','p_on'));
           hGUI.labelx(hGUI.gObj.p_on,'Time (s)')
           hGUI.labely(hGUI.gObj.p_on,'i (pA)')
           
           %off flashes
           hGUI.createPlot(struct('Position',[l2 t4 w2 h]./1000,'tag','p_off'));
           hGUI.labelx(hGUI.gObj.p_off,'Time (s)')
           hGUI.labely(hGUI.gObj.p_off,'i (pA)')
           
           
           
           % df plot
           hGUI.createPlot(struct('Position',[l1+w1+45 785 165 200]./1000,'tag','dfp'));
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
           hGUI.dfNorm();
       end
       
       function createSliders(hGUI)
           switch func2str(hGUI.modelFx)
               case 'cModelUni'
                   slidermax = {5000 2000 2000 1000 5000 1000 5000 5000};
                   sliderorient = {0 0 0 0 0 0 0 0};
                   slidermin = {0 0 0 0 0 0 0 0};
               case 'cModelUni_clamped'
                   slidermax = {1000 5000 5000};
                   sliderorient = {0 0 0};
                   slidermin = {0 0 0};
               case 'cModelBi'
                   slidermax = {5000 2000 2000 1000 5000 1000 5000 5000 1000 100 1000};
                   sliderorient = {0 0 0 0 0 0 0 0 0 0 0};
                   slidermin = {0 0 0 0 0 0 0 0 0 0 0};
               case 'vhModel'
                   slidermax = {5000 2000 20000 1000 1000};
                   sliderorient = {0 0 0 0 0};
                   slidermin = {0 0 0 0 0};
               case 'riekeModel'
                   slidermax ={1000 1000 5000 1000};
                   sliderorient = {0 0 0 0};
                   slidermin = {0 0 0 0};
           end
                   
           
           sliders = struct('Orientation',sliderorient,...
               'Minimum',slidermin,...
               'Maximum',slidermax,...
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
           dfnstruct.Position = [930 930 50 50]./1000;
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
               dfH.YData = normalize(hGUI.df_resp-hGUI.df_resp(1));
               dfiH.YData = normalize(hGUI.df_ifit-hGUI.df_ifit(1));
               dfcH.YData = normalize(hGUI.df_cfit-hGUI.df_cfit(1));
               dffH.YData = normalize(hGUI.df_ffit-hGUI.df_ffit(1));
          end
       end
       function updatePlots(hGUI,~,~)
           lH = findobj('tag','s_ifit');%HACK!!! this should be cfit
           tempstm=[ones(1,1000)*hGUI.s_stm(1) hGUI.s_stm];
           temptme=(1:1:length(tempstm)).*hGUI.dt;
           tempfit=hGUI.modelFx(hGUI.curr,temptme,tempstm,hGUI.dt);
           hGUI.s_cfit=tempfit(1001:end); 
           
           lH.YData = hGUI.s_cfit;
           lH.LineWidth = 2;
               
               
           for i = 1:hGUI.nf
               lH = findobj('tag',sprintf('sf_ifit%02g',i));%HACK!!! this should be cfit
               tempstm=[ones(1,1000)*hGUI.sf_stm(i,1) hGUI.sf_stm(i,:)];
               temptme=(1:1:length(tempstm)).*hGUI.dt;
               tempfit=hGUI.modelFx(hGUI.curr,temptme,tempstm,hGUI.dt);
               hGUI.sf_cfit(i,:)=tempfit(1001:end);
               
               lH.YData = hGUI.sf_cfit(i,:);
               lH.LineWidth = 2;
           end
       end
       
       function runLSQ(hGUI,~,~)
           % least-squares fitting
           
           fprintf('Started lsq fitting.....\n')
           LSQ = struct;
           if true
               i2use = 2;
               LSQ.ydata=hGUI.sf(i2use,:);
               lsqfun=@(optcoeffs,tme)hGUI.modelFx(optcoeffs,hGUI.tme,hGUI.sf_stm(i2use,:),hGUI.dt);
           else
               LSQ.ydata=hGUI.s; %#ok<UNRCH>
               lsqfun=@(optcoeffs,tme)hGUI.modelFx(optcoeffs,hGUI.tme,hGUI.s_stm,hGUI.dt);
           end
           
           LSQ.lb=hGUI.lower;
           LSQ.ub=hGUI.upper;
           LSQ.objective=lsqfun;
           LSQ.x0=hGUI.curr;
           LSQ.xdata=hGUI.tme;

           
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
           optfx=@(optcoeffs)hGUI.modelFx(optcoeffs,hGUI.tme,hGUI.s_stm,hGUI.dt);
           errfx=@(optcoeffs)sum((optfx(optcoeffs)-hGUI.s).^2);
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
           % redo 
           hGUI.updatePlots;

           % reset sliders
           hGUI.resetSliders;
       end
       
       function okFit(hGUI,~,~)
           if sum(~isnan(hGUI.gObj.infoTable.Data(:,3)))==size(hGUI.gObj.infoTable.Data(:,3),1)
               hGUI.curr=hGUI.gObj.infoTable.Data(:,3);
               hGUI.gObj.infoTable.Data(:,2)=hGUI.curr;
           end
           % redo
           hGUI.updatePlots;
           % reset sliders
           hGUI.resetSliders;
       end
       
       function updateFits(hGUI,~,~)
           % 
           lH = findobj('tag','s_ifit'); %HACK!!! this should be ffit
           
           tempstm=[ones(1,1000)*hGUI.s_stm(1) hGUI.s_stm];
           temptme=(1:1:length(tempstm)).*hGUI.dt;
           tempfit=hGUI.modelFx(hGUI.fit,temptme,tempstm,hGUI.dt);
           hGUI.s_ffit=tempfit(1001:end);
           
           lH.YData = hGUI.s_ffit;
           lH.LineWidth=2;
           
           
           for i = 1:hGUI.nf
               lH = findobj('tag',sprintf('sf_ifit%02g',i));%HACK!!! this should be ffit
               tempstm=[ones(1,1000)*hGUI.sf_stm(i,1) hGUI.sf_stm(i,:)];
               temptme=(1:1:length(tempstm)).*hGUI.dt;
               tempfit=hGUI.modelFx(hGUI.fit,temptme,tempstm,hGUI.dt);
               hGUI.sf_ffit(i,:)=tempfit(1001:end);
               
               lH.YData = hGUI.sf_ffit(i,:);
               lH.LineWidth = 2;
           end
           
           hGUI.f_ffit=hGUI.subflashes(hGUI.sf_ffit,hGUI.s_ffit);
           for i = 1:hGUI.nf
               lH = findobj('tag',sprintf('f_ifit%02g',i));%HACK!!! this should be ffit
               
               lH.YData = hGUI.f_ffit(i,:);
               lH.LineWidth = 2;
           end
          
       end
              
       function dfcurrent(hGUI,~,~)
           tempstm=[zeros(1,5000) hGUI.df_stm];
           temptme=(1:1:length(tempstm)).* hGUI.df_dt;
           tempfit=hGUI.modelFx(hGUI.curr,temptme,tempstm,hGUI.df_dt);
           hGUI.df_cfit = tempfit(5001:end);
       end
       
       
       function extractFlashes(hGUI,~,~)
           for i=1:hGUI.nf
               fstart = hGUI.distep(1);%+hGUI.didelta(i);
               fend = fstart + hGUI.digap-1;
               hGUI.fon(i,:) = hGUI.f(i,fstart:fend);
               hGUI.fon_ifit(i,:) = hGUI.f_ifit(i,fstart:fend);
               hGUI.fon_cfit(i,:) = hGUI.f_cfit(i,fstart:fend);
               hGUI.fon_ffit(i,:) = hGUI.f_ffit(i,fstart:fend);
               
               fstart = hGUI.distep(2);%+hGUI.didelta(i);
               fend = fstart + hGUI.digap-1;
               hGUI.foff(i,:) = hGUI.f(i,fstart:fend);
               hGUI.foff_ifit(i,:) = hGUI.f_ifit(i,fstart:fend);
               hGUI.foff_cfit(i,:) = hGUI.f_cfit(i,fstart:fend);
               hGUI.foff_ffit(i,:) = hGUI.f_ffit(i,fstart:fend);
           end
           
           fstart =hGUI.difix(1);
           fend = fstart + hGUI.digap-1;
           hGUI.ffix(1,:) = hGUI.f(i,fstart:fend);
           
           fstart =hGUI.difix(2);
           fend = fstart + hGUI.digap-1;
           hGUI.ffix(2,:) = hGUI.f(i,fstart:fend);
           
           hGUI.ftme = [0:hGUI.digap]./hGUI.dt;
       end
   end
   
   methods (Static=true)
       
       function flashmat=subflashes(stepflashes,step) % subtraction to isolate flashes
           flashmat = stepflashes - repmat(step,size(stepflashes,1),1);
       end
       
       function showResults(fitcoeffs)
           fprintf('\nccoeffs=[');fprintf('%04.3g,',fitcoeffs);fprintf('];\n')
       end
   end
   
end
