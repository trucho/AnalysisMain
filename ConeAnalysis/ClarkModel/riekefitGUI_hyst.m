classdef riekefitGUI_hyst < ephysGUI
   properties
       modelFx
       i2V = [135 1] % holding current in darkness and scaling factor
       plotFlag
       
       ini
       curr
       fit
       upper
       lower
       
       tme
       skipts
       dt
       
       full_ss_stm
       full_ss
       
       full_ss_ifit
       full_ss_cfit
       full_ss_ffit
           
       full_steps_stm
       full_steps
       full_sines_stm
       full_sines
       
       full_steps_ifit
       full_sines_ifit
       
       tme2
       
       ss_up
       steps_up
       sines_up
       
       ss_down
       steps_down
       sines_down
       
       ss_up_ifit
       steps_up_ifit
       sines_up_ifit
       
       ss_down_ifit
       steps_down_ifit
       sines_down_ifit
       
       diff_steps_up
       diff_sines_up
       diff_steps_up_ifit
       diff_sines_up_ifit
       
       diff_steps_down
       diff_sines_down
       diff_steps_down_ifit
       diff_sines_down_ifit
       
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
       function hGUI=riekefitGUI_hyst(fign)
           hGUI@ephysGUI(fign);
       end
       
       function loadData(hGUI,~,~)
           % DATA LOADING AND INITIAL FITS
           % immediate problem: data in i_clamp, model is ios!
           % 040114Fc03
           i=1;
           ssdata = load('~/matlab/AnalysisMain/ConeAnalysis/ClarkModel/StepsAndSines/HystSine_iC_ex.mat');
           ssdata = ssdata.HystData;
           hGUI.skipts=20;
           hGUI.dt=hGUI.skipts*(ssdata.tAxis(2)-ssdata.tAxis(1));
           
           hGUI.tme=ssdata.tAxis(1:hGUI.skipts:end);
           
           %stimulus is calibrated in R*/s, so for model, have to convert it to R*/dt
           hGUI.full_ss_stm=ssdata.stim(i,1:hGUI.skipts:end).*hGUI.dt/2; % why dt/2??? Just making less bright for model?
           hGUI.full_steps_stm=ssdata.stim(5,1:hGUI.skipts:end).*hGUI.dt/2; % why dt/2??? Just making less bright for model?

           % hGUI.full_ss=ssdata.mean(i,1:hGUI.skipts:end)-45.5; % manually correcting for Vm_dark (estimated guess from data)
           hGUI.full_ss=(ssdata.mean(i,1:hGUI.skipts:end)*7)-1; % faking voltage to ios scaling
           hGUI.full_ss=-(hGUI.full_ss./hGUI.i2V(2)) - hGUI.i2V(1);
           
           hGUI.full_steps=(ssdata.mean(5,1:hGUI.skipts:end)*7)-1; % faking voltage to ios scaling
           hGUI.full_steps=-(hGUI.full_steps./hGUI.i2V(2)) - hGUI.i2V(1);
           
           hGUI.full_sines = hGUI.full_ss - hGUI.full_steps;
           
           % initial fit
           tempstm=[ones(1,1000)*hGUI.full_ss_stm(1) hGUI.full_ss_stm];
           temptme=(1:1:length(tempstm)).*hGUI.dt;
           hGUI.full_ss_ifit=hGUI.modelFx(hGUI.ini,temptme,tempstm,hGUI.dt);
           hGUI.full_ss_ifit=hGUI.full_ss_ifit(1001:end);
           
           tempstm=[ones(1,1000)*hGUI.full_steps_stm(1) hGUI.full_steps_stm];
           temptme=(1:1:length(tempstm)).*hGUI.dt;
           hGUI.full_steps_ifit = hGUI.modelFx(hGUI.ini,temptme,tempstm,hGUI.dt);
           hGUI.full_steps_ifit=hGUI.full_steps_ifit(1001:end);
           
           hGUI.full_sines_ifit = hGUI.full_ss_ifit - hGUI.full_steps_ifit;
           
           %current fit
           hGUI.full_ss_cfit=hGUI.full_ss_ifit;
           hGUI.full_ss_ffit=hGUI.full_ss_ifit;
           
           
           % parsing long epoch into segments
           hGUI.tme2 = -0.05:hGUI.dt:0.5-hGUI.dt;
           for k = 1:4
               seq = [3,1,2,4];
               lims_start = find(hGUI.tme>=1*(seq(k))-0.05,1,'first');
               lims_end = find(hGUI.tme<=0.5+(1*(seq(k))),1,'last');
               
               hGUI.ss_up(k,:) = hGUI.full_ss(lims_start:lims_end);
               hGUI.steps_up(k,:) = hGUI.full_steps(lims_start:lims_end);
               hGUI.sines_up(k,:) = hGUI.full_sines(lims_start:lims_end);
               
               hGUI.ss_up_ifit(k,:) = hGUI.full_ss_ifit(lims_start:lims_end);
               hGUI.steps_up_ifit(k,:) = hGUI.full_steps_ifit(lims_start:lims_end);
               hGUI.sines_up_ifit(k,:) = hGUI.full_sines_ifit(lims_start:lims_end);
               
               
               lims_start = find(hGUI.tme>=0.5+1*(seq(k))-0.05,1,'first');
               lims_end = find(hGUI.tme<=0.5+0.5+(1*(seq(k))),1,'last');
               
               hGUI.ss_down(k,:) = hGUI.full_ss(lims_start:lims_end);
               hGUI.steps_down(k,:) = hGUI.full_steps(lims_start:lims_end);
               hGUI.sines_down(k,:) = hGUI.full_sines(lims_start:lims_end);
               
               hGUI.ss_down_ifit(k,:) = hGUI.full_ss_ifit(lims_start:lims_end);
               hGUI.steps_down_ifit(k,:) = hGUI.full_steps_ifit(lims_start:lims_end);
               hGUI.sines_down_ifit(k,:) = hGUI.full_sines_ifit(lims_start:lims_end);
           end
           
           % calculation of differences
           for k = 1:4
               hGUI.diff_steps_up(k,:) = hGUI.steps_up(k,:) - hGUI.steps_up(1,:);
               hGUI.diff_sines_up(k,:) = hGUI.sines_up(k,:) - hGUI.sines_up(1,:);
               hGUI.diff_steps_up_ifit(k,:) = hGUI.steps_up_ifit(k,:) - hGUI.steps_up_ifit(1,:);
               hGUI.diff_sines_up_ifit(k,:) = hGUI.sines_up_ifit(k,:) - hGUI.sines_up_ifit(1,:);
               
               hGUI.diff_steps_down(k,:) = hGUI.steps_down(k,:) - hGUI.steps_down(1,:);
               hGUI.diff_sines_down(k,:) = hGUI.sines_down(k,:) - hGUI.sines_down(1,:);
               hGUI.diff_steps_down_ifit(k,:) = hGUI.steps_down_ifit(k,:) - hGUI.steps_down_ifit(1,:);
               hGUI.diff_sines_down_ifit(k,:) = hGUI.sines_down_ifit(k,:) - hGUI.sines_down_ifit(1,:);
           end
           
           
           % dim flash response
           DF=load('/Users/angueyraaristjm/matlab/matlab-analysis/trunk/users/juan/ConeModel/BiophysicalModel/EyeMovementsExampleDF_092413Fc12vClamp.mat');
           DF=DF.DF_raw;
           
           hGUI.df_tme = DF.TimeAxis;
           hGUI.df_dt = (hGUI.df_tme(2)-hGUI.df_tme(1));
%            hGUI.df_resp = DF.Mean - hGUI.i2V(1) + 1.2;
           hGUI.df_resp = DF.Mean - hGUI.i2V(1)+ 0.81;
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
           
           % steps + sines stim
           hGUI.createPlot(struct('Position',[230 920 450 60]./1000,'tag','full_stim'));
           hGUI.hidex(hGUI.gObj.full_stim)
           hGUI.labely(hGUI.gObj.full_stim,'R*/s')
           hGUI.xlim(hGUI.gObj.full_stim,hGUI.minmax(hGUI.tme))
           hGUI.ylim(hGUI.gObj.full_stim,hGUI.minmax(hGUI.full_ss_stm)./hGUI.dt)
           
           lH=lineH(hGUI.tme,hGUI.full_ss_stm/hGUI.dt,hGUI.gObj.full_stim);
           lH.linek;lH.setName('full_stim');lH.h.LineWidth=2;
           
           % steps + sines plot
           hGUI.createPlot(struct('Position',[230 730 450 175]./1000,'tag','full_ss'));
           hGUI.labelx(hGUI.gObj.full_ss,'Time (s)')
           hGUI.labely(hGUI.gObj.full_ss,'i (pA)')
           hGUI.xlim(hGUI.gObj.full_ss,hGUI.minmax(hGUI.tme))
%            hGUI.ylim(hGUI.gObj.full_ss,[-10 80])
           
           lH=lineH(hGUI.tme,hGUI.full_ss,hGUI.gObj.full_ss); % response
           lH.linek;lH.setName('stjresp');lH.h.LineWidth=2;
           lH=lineH(hGUI.tme,hGUI.full_ss_ifit,hGUI.gObj.full_ss); % initial fit
           lH.line;lH.setName('full_ss_ifit');lH.h.LineWidth=1;
           lH.color([.5 .5 .5]);
           lH=lineH(hGUI.tme,hGUI.full_ss_ffit,hGUI.gObj.full_ss); % fit fit
           lH.lineb;lH.h.LineWidth=2;lH.setName('full_ss_ffit');
           lH=lineH(hGUI.tme,hGUI.full_ss_cfit,hGUI.gObj.full_ss); % current fit
           lH.liner;lH.setName('full_ss_cfit');lH.h.LineWidth=1;
           
           
           % df plot
           hGUI.createPlot(struct('Position',[730 785 255 200]./1000,'tag','dfp'));
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
           
           h = 175;
           w = 360;
           l1 = 230;
           l2 = 630;
           t1 = 500;
           t2 = 280;
           t3 = 60;
           
           c = pmkmp(4,'CubicLQuarter');
           % stim plot
           hGUI.createPlot(struct('Position',[l1 t1 w h]./1000,'tag','pstim'));
           hGUI.labelx(hGUI.gObj.pstim,'Time (s)')
           hGUI.labely(hGUI.gObj.pstim,'R*/s')
           hGUI.xlim(hGUI.gObj.pstim,hGUI.minmax(hGUI.tme2))

           % ss plot
           hGUI.createPlot(struct('Position',[l2 t1 w h]./1000,'tag','pss'));
           hGUI.labelx(hGUI.gObj.pss,'Time (s)')
           hGUI.labely(hGUI.gObj.pss,'i (pA)')
           hGUI.xlim(hGUI.gObj.pss,hGUI.minmax(hGUI.tme2))
           
           % step plot
           hGUI.createPlot(struct('Position',[l1 t2 w h]./1000,'tag','pstep'));
           hGUI.labelx(hGUI.gObj.pstep,'Time (s)')
           hGUI.labely(hGUI.gObj.pstep,'i (pA)')
           hGUI.xlim(hGUI.gObj.pstep,hGUI.minmax(hGUI.tme2))
           
           % stepdiff plot
           hGUI.createPlot(struct('Position',[l2 t2 w h]./1000,'tag','pstepdiff'));
           hGUI.labelx(hGUI.gObj.pstepdiff,'Time (s)')
           hGUI.labely(hGUI.gObj.pstepdiff,'i (pA)')
           hGUI.xlim(hGUI.gObj.pstepdiff,hGUI.minmax(hGUI.tme2))
           hGUI.ylim(hGUI.gObj.pstepdiff,[-15 15])
           
           % sine plot
           hGUI.createPlot(struct('Position',[l1 t3 w h]./1000,'tag','psine'));
           hGUI.labelx(hGUI.gObj.psine,'Time (s)')
           hGUI.labely(hGUI.gObj.psine,'i (pA)')
           hGUI.xlim(hGUI.gObj.psine,hGUI.minmax(hGUI.tme2))
           
           % sinediff plot
           hGUI.createPlot(struct('Position',[l2 t3 w h]./1000,'tag','psinediff'));
           hGUI.labelx(hGUI.gObj.psinediff,'Time (s)')
           hGUI.labely(hGUI.gObj.psinediff,'i (pA)')
           hGUI.xlim(hGUI.gObj.psinediff,hGUI.minmax(hGUI.tme2))
           hGUI.ylim(hGUI.gObj.psinediff,[-15 15])
           
           for k = 1:4
               if hGUI.plotFlag
                   % stim
%                    lH = lineH(hGUI.tme2,hGUI.ss_up_stm,hGUI.gObj.pstim);
%                    lH.line;lH.color(c(i,:));lH.h.LineWidth=1;lH.setName(sprintf('stim_up%g',round(k)));

                   % steps + sines
                   lH = lineH(hGUI.tme2,hGUI.ss_up_ifit(k,:),hGUI.gObj.pss);
                   lH.line;lH.color(c(k,:));lH.h.LineWidth=2;lH.setName(sprintf('ss_up%g',round(k)));
                   % steps
                   lH = lineH(hGUI.tme2,hGUI.steps_up_ifit(k,:),hGUI.gObj.pstep);
                   lH.line;lH.color(c(k,:));lH.h.LineWidth=2;lH.setName(sprintf('step_up%g',round(k)));
                   % sines
                   lH = lineH(hGUI.tme2,hGUI.sines_up_ifit(k,:),hGUI.gObj.psine);
                   lH.line;lH.color(c(k,:));lH.h.LineWidth=2;lH.setName(sprintf('sine_up%g',round(k)));
                   
                   % differences steps
                   lH = lineH(hGUI.tme2,hGUI.diff_steps_up_ifit(k,:),hGUI.gObj.pstepdiff);
                   lH.line;lH.color(c(k,:));lH.h.LineWidth=2;lH.setName(sprintf('step_up%g',round(k)));
                   % differences sines
                   lH = lineH(hGUI.tme2,hGUI.diff_sines_up_ifit(k,:),hGUI.gObj.psinediff);
                   lH.line;lH.color(c(k,:));lH.h.LineWidth=2;lH.setName(sprintf('sine_up%g',round(k)));
               else
                   % stim
%                    lH = lineH(hGUI.tme2,hGUI.ss_down_stm,hGUI.gObj.pstim);
%                    lH.line;lH.color(c(i,:));lH.h.LineWidth=1;lH.setName(sprintf('stim_down%g',round(k)));
                   
                   % steps + sines
                   lH = lineH(hGUI.tme2,hGUI.ss_down_ifit(k,:),hGUI.gObj.pss);
                   lH.line;lH.color(c(k,:));lH.h.LineWidth=2;lH.setName(sprintf('ss_down%g',round(k)));
                   % steps
                   lH = lineH(hGUI.tme2,hGUI.steps_down_ifit(k,:),hGUI.gObj.pstep);
                   lH.line;lH.color(c(k,:));lH.h.LineWidth=2;lH.setName(sprintf('step_down%g',round(k)));
                   % sines
                   lH = lineH(hGUI.tme2,hGUI.sines_down_ifit(k,:),hGUI.gObj.psine);
                   lH.line;lH.color(c(k,:));lH.h.LineWidth=2;lH.setName(sprintf('sine_down%g',round(k)));
                   
                   % differences steps
                   lH = lineH(hGUI.tme2,hGUI.diff_steps_down_ifit(k,:),hGUI.gObj.pstepdiff);
                   lH.line;lH.color(c(k,:));lH.h.LineWidth=2;lH.setName(sprintf('step_down%g',round(k)));
                   % differences sines
                   lH = lineH(hGUI.tme2,hGUI.diff_sines_down_ifit(k,:),hGUI.gObj.psinediff);
                   lH.line;lH.color(c(k,:));lH.h.LineWidth=2;lH.setName(sprintf('sine_down%g',round(k)));
               end
           end
           
       end
       
       function createSliders(hGUI)
           sliders = struct('Orientation',{0 0 0 0 0},...
               'Minimum',{0 0 0 0 0},...
               'Maximum',{5000 2000 20000 1000 5000},...
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
           % saccade trajectory
           lH = findobj('tag','full_ss_cfit');
           tempstm=[ones(1,1000)*hGUI.full_ss_stm(1) hGUI.full_ss_stm];
           temptme=(1:1:length(tempstm)).*hGUI.dt;
           tempfit=hGUI.modelFx(hGUI.curr,temptme,tempstm,hGUI.dt);
           hGUI.full_ss_cfit=tempfit(1001:end);
           
           lH.YData = hGUI.full_ss_cfit;
           lH.LineWidth = 2;
           
           lH = findobj('tag','full_ss_ffit');
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
           lsqfun=@(optcoeffs,tme)hGUI.modelFx(optcoeffs,hGUI.tme,hGUI.full_ss_stm,hGUI.dt);
           LSQ.objective=lsqfun;
           LSQ.x0=hGUI.curr;
           LSQ.xdata=hGUI.tme;
           LSQ.ydata=hGUI.full_ss;
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
               
           % reset sliders
           hGUI.resetSliders;
       end
       
       function updateFits(hGUI,~,~)
           % stj
           lH = findobj('tag','full_ss_ffit');
           
           tempstm=[ones(1,1000)*hGUI.full_ss_stm(1) hGUI.full_ss_stm];
           temptme=(1:1:length(tempstm)).*hGUI.dt;
           tempfit=hGUI.modelFx(hGUI.fit,temptme,tempstm,hGUI.dt);
           hGUI.full_ss_ffit=tempfit(1001:end);
           
           lH.YData = hGUI.full_ss_ffit;
           lH.LineWidth=5;
           
           % dim flash
           tempstm=[zeros(1,40000) hGUI.df_stm];
           temptme=(1:1:length(tempstm)).* hGUI.df_dt;
           tempfit=hGUI.modelFx(hGUI.fit,temptme,tempstm,hGUI.df_dt);
           hGUI.df_ffit = tempfit(40001:end); 
           
           dfH = findobj(hGUI.gObj.dfp,'tag','df_ffit');
           dfH.YData = hGUI.df_ffit;
           dfH.LineWidth=5;
           % adaptation kinetics
           % will update when fit is accepted by just modifying current
           
          
       end
              
       function dfcurrent(hGUI,~,~)
           tempstm=[zeros(1,5000) hGUI.df_stm];
           temptme=(1:1:length(tempstm)).* hGUI.df_dt;
           tempfit=hGUI.modelFx(hGUI.curr,temptme,tempstm,hGUI.df_dt);
           hGUI.df_cfit = tempfit(5001:end);
       end
       
   end
   
   methods (Static=true)
       
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
