classdef akfitGUI < ephysGUI
    % still to do:
        % calculate adaptation taus
        % sub class for other models
   properties
       modelFx
       i2V
       plotFlag
       
       riekeFlag
       
       ini
       curr
       fit
       upper
       lower
       
       padpts = 2000;
       
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
       ffixtme
       
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
       
       onGain
       onGain_delta
       onGain_ttp
       
       offGain
       offGain_delta
       offGain_ttp
       
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
%            hGUI.dgap = 500./1000;
           hGUI.dgap = 150./1000; %Updated Aug_2019
       end
       
       function loadData(hGUI,~,~)
           % DATA LOADING AND INITIAL FITS
%            akdata = load('~/matlab/AnalysisMain/ConeAnalysis/ClarkModel/AK_example.mat'); % 111412Fc01
           akdata = load('~/matlab/AnalysisMain/ConeAnalysis/ClarkModel/AK_example02.mat'); % 111412Fc02
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
%          % UPDATE (DEC_2019): rieke model now takes R*/s but clark does not!!!


%            fprintf('This better be clark model!\n')
%            hGUI.riekeFlag = 0;
%            hGUI.s_stm=akdata.StepStim(1,1:hGUI.skipts:end).*hGUI.dt;
%            hGUI.f_stm = (akdata.FlashStim(:,1:hGUI.skipts:end)+repmat(akdata.FlashLockedStim(:,1:hGUI.skipts:end),hGUI.nf,1))*100.*hGUI.dt; % 100 converts from R*/flash(10ms) to R*/s

            fprintf('This better be rieke model!\n')
            hGUI.riekeFlag = 1;
            hGUI.s_stm=akdata.StepStim(1,1:hGUI.skipts:end);
            hGUI.f_stm = (akdata.FlashStim(:,1:hGUI.skipts:end)+repmat(akdata.FlashLockedStim(:,1:hGUI.skipts:end),hGUI.nf,1))*100; % 100 converts from R*/flash(10ms) to R*/s


           hGUI.sf_stm=repmat(hGUI.s_stm,hGUI.nf,1)+hGUI.f_stm;
           
           hGUI.s=(akdata.Step(:,1:hGUI.skipts:end)./hGUI.i2V(2)) - hGUI.i2V(1);
           hGUI.sf=(akdata.Flash(:,1:hGUI.skipts:end)./hGUI.i2V(2)) - hGUI.i2V(1);
           hGUI.f = hGUI.subflashes(hGUI.sf,hGUI.s);
           
           % initial fit
           tempstm=[ones(1,hGUI.padpts)*hGUI.s_stm(1) hGUI.s_stm]; %padding
           temptme=(1:1:length(tempstm)).*hGUI.dt;
           if hGUI.riekeFlag
               tempfit=hGUI.modelFx(hGUI.ini,temptme,tempstm);
           else
               tempfit=hGUI.modelFx(hGUI.ini,temptme,tempstm,hGUI.dt);
           end
           hGUI.s_ifit=tempfit(hGUI.padpts+1:end);
           hGUI.s_cfit=hGUI.s_ifit;
           hGUI.s_ffit=hGUI.s_ifit;
           
           for i=1:hGUI.nf
               tempstm=[ones(1,hGUI.padpts)*hGUI.s_stm(1) hGUI.sf_stm(i,:)];
               temptme=(1:1:length(tempstm)).*hGUI.dt;
               if hGUI.riekeFlag
                   tempfit=hGUI.modelFx(hGUI.ini,temptme,tempstm);
               else
                   tempfit=hGUI.modelFx(hGUI.ini,temptme,tempstm,hGUI.dt);
               end
               hGUI.sf_ifit(i,:)=tempfit(hGUI.padpts+1:end);
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
           
           hGUI.extractFlashes(); %Fixed Aug_2019
           
           % dim flash response
           DF=load('/Users/angueyraaristjm/matlab/matlab-analysis/trunk/users/juan/ConeModel/BiophysicalModel/EyeMovementsExampleDF_092413Fc12vClamp.mat');
           DF=DF.DF_raw;
           
           hGUI.df_tme = DF.TimeAxis;
           hGUI.df_dt = (hGUI.df_tme(2)-hGUI.df_tme(1));
%            hGUI.df_resp = DF.Mean - hGUI.i2V(1) + 1.2;
%            hGUI.df_resp = DF.Mean - hGUI.i2V(1)+ 0.81;
           hGUI.df_resp = DF.Mean - hGUI.i2V(1)+ 0;
%            hGUI.df_stm = zeros(size(hGUI.df_tme)); hGUI.df_stm(10/(1000*hGUI.df_dt)) = 1/hGUI.df_dt; %10 ms prepts
           hGUI.df_stm = zeros(size(hGUI.df_tme)); hGUI.df_stm(10/(1000*hGUI.df_dt)) = 1; %10 ms prepts
           
           tempstm=[zeros(1,40000) hGUI.df_stm];
           temptme=(1:1:length(tempstm)).* hGUI.df_dt;
           if hGUI.riekeFlag
               tempfit=hGUI.modelFx(hGUI.ini,temptme,tempstm);
           else
               tempfit=hGUI.modelFx(hGUI.ini,temptme,tempstm,hGUI.df_dt);
           end
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
           hGUI.createPlot(struct('Position',[l1 t1-10 w1 30]./1000,'tag','p_stimS'));
           hGUI.hidex(hGUI.gObj.p_stimS)
           hGUI.labely(hGUI.gObj.p_stimS,'R*/s')
           hGUI.xlim(hGUI.gObj.p_stimS,hGUI.minmax(hGUI.tme))
%            hGUI.ylim(hGUI.gObj.p_stimS,hGUI.minmax(hGUI.sf_stm)./hGUI.dt)
           
           lH=lineH(hGUI.tme,hGUI.s_stm,hGUI.gObj.p_stimS);
           lH.linek;lH.setName('stim_s');lH.h.LineWidth=2;
           
           hGUI.createPlot(struct('Position',[l1 t1+40 w1 30]./1000,'tag','p_stimF'));
           hGUI.hidex(hGUI.gObj.p_stimF)
           hGUI.labely(hGUI.gObj.p_stimF,'R*/s')
           hGUI.xlim(hGUI.gObj.p_stimF,hGUI.minmax(hGUI.tme))
%            hGUI.ylim(hGUI.gObj.p_stimF,hGUI.minmax(hGUI.sf_stm)./hGUI.dt)
           
           
           for i=1:hGUI.nf
               lH=lineH(hGUI.tme,hGUI.f_stm(i,:),hGUI.gObj.p_stimF);
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
           

           
           % on flashes (transformed to gain)
           hGUI.createPlot(struct('Position',[l1 t4 w2 h]./1000,'tag','p_on'));
           hGUI.labelx(hGUI.gObj.p_on,'Time (s)')
           hGUI.labely(hGUI.gObj.p_on,'Norm. Gain')
           hGUI.xlim(hGUI.gObj.p_on,[-0.1 1.01])
           hGUI.ylim(hGUI.gObj.p_on,[-0.1 1.1])
           
           lH=lineH([-0.1 1],[1 1],hGUI.gObj.p_on); % dark gain
           lH.linedash;lH.setName(sprintf('GainPre'));
%            lH=lineH([-0.1 1],[.1807 .1807],hGUI.gObj.p_on); % step gain 
           lH=lineH([-0.1 1],[.260 .260],hGUI.gObj.p_on); % step gain
           lH.linedash;lH.setName(sprintf('GainPost'));
           
           
           for i = hGUI.nf:-1:1
               lH=lineH(hGUI.ftme(i,:),hGUI.fon(i,:),hGUI.gObj.p_on); 
               lH.line;lH.color(hGUI.pwcolors(i,:));lH.setName(sprintf('fon%02g',i));lH.h.LineWidth=1;
               
               lH=lineH(hGUI.ftme(i,:),hGUI.fon_cfit(i,:),hGUI.gObj.p_on); 
               lH.line;lH.color(hGUI.pcolors(i,:));lH.setName(sprintf('fon_cfit%02g',i));lH.h.LineWidth=2;
           end
           lH=lineH(hGUI.ffixtme(1,:),hGUI.ffix(1,:),hGUI.gObj.p_on); 
           lH.line;lH.color([.75 .75 .75]);lH.setName(sprintf('fpre'));lH.h.LineWidth=1;
           lH=lineH(hGUI.ffixtme(1,:),hGUI.ffix_cfit(1,:),hGUI.gObj.p_on); 
           lH.line;lH.color([0 0 0]);lH.setName(sprintf('fpre_cfit'));lH.h.LineWidth=2;
           
           lH=lineH(hGUI.ffixtme(2,:),hGUI.ffix(2,:),hGUI.gObj.p_on); 
           lH.line;lH.color([.75 .75 .75]);lH.setName(sprintf('fpost'));lH.h.LineWidth=1;
           lH=lineH(hGUI.ffixtme(2,:),hGUI.ffix_cfit(2,:),hGUI.gObj.p_on);
           lH.line;lH.color([0 0 0]);lH.setName(sprintf('fpost_cfit'));lH.h.LineWidth=2;
           
           
           
           
           
           %off flashes (transformed to gain)
           hGUI.createPlot(struct('Position',[l2 t4 w2 h]./1000,'tag','p_off'));
           hGUI.labelx(hGUI.gObj.p_off,'Time (s)')
           hGUI.labely(hGUI.gObj.p_off,'Norm. Gain')
           hGUI.xlim(hGUI.gObj.p_off,[-0.1 1.01])
           hGUI.ylim(hGUI.gObj.p_off,[-0.1 1.1])
           
           lH=lineH([-0.1 1],[1 1],hGUI.gObj.p_off); % dark gain
           lH.linedash;lH.setName(sprintf('GainPre'));
%            lH=lineH([-0.1 1],[.1807 .1807],hGUI.gObj.p_off); % step gain
           lH=lineH([-0.1 1],[.260 .260],hGUI.gObj.p_off); % step gain
           lH.linedash;lH.setName(sprintf('GainPost'));
                      
           
           for i = hGUI.nf:-1:1
               lH=lineH(hGUI.ftme(i,:),hGUI.foff(i,:),hGUI.gObj.p_off); % off flashes
               lH.line;lH.color(hGUI.pwcolors(i,:));lH.setName(sprintf('foff%02g',i));lH.h.LineWidth=1;
               
               lH=lineH(hGUI.ftme(i,:),hGUI.foff_cfit(i,:),hGUI.gObj.p_off); % off flashes
               lH.line;lH.color(hGUI.pcolors(i,:));lH.setName(sprintf('foff_cfit%02g',i));lH.h.LineWidth=2;
           end
           lH=lineH(hGUI.ffixtme(1,:),hGUI.ffix(2,:),hGUI.gObj.p_off); 
           lH.line;lH.color([.75 .75 .75]);lH.setName(sprintf('fpre'));lH.h.LineWidth=1;
           lH=lineH(hGUI.ffixtme(1,:),hGUI.ffix_cfit(2,:),hGUI.gObj.p_off); 
           lH.line;lH.color([0 0 0]);lH.setName(sprintf('fpre_cfit'));lH.h.LineWidth=2;
           
           lH=lineH(hGUI.ffixtme(2,:),hGUI.ffix(1,:),hGUI.gObj.p_off); 
           lH.line;lH.color([.75 .75 .75]);lH.setName(sprintf('fpost'));lH.h.LineWidth=1;
           lH=lineH(hGUI.ffixtme(2,:),hGUI.ffix_cfit(1,:),hGUI.gObj.p_off);
           lH.line;lH.color([0 0 0]);lH.setName(sprintf('fpost_cfit'));lH.h.LineWidth=2;
           
           
           
           hGUI.mapGainCurve();
           
           % exponential fits to real data (from AdaptationKinetics.m) for 111412Fc01
%            lH=lineH(0:.01:1,((0.8316*(exp(-66.4785.*(0:.01:1))))+0.1683),hGUI.gObj.p_on); % tau = 15.04 ms
%            lH.lineg;lH.setName(sprintf('expGain'));lH.h.LineWidth=2;
%            
%            lH=lineH(0:.01:1,((0.8120*(1-exp(-11.4645.*(0:.01:1))))+0.1880),hGUI.gObj.p_off); % tau = 87.23 ms
%            lH.lineg;lH.setName(sprintf('expGain'));lH.h.LineWidth=2;
           

           % exponential fits to real data (from AdaptationKinetics.m) for 111412Fc02
           lH=lineH(0:.01:1,((0.7408*(exp(-44.1183.*(0:.01:1))))+0.2598),hGUI.gObj.p_on); % tau = 23.74 ms
           lH.lineg;lH.setName(sprintf('expGain'));lH.h.LineWidth=2;
           
           lH=lineH(0:.01:1,((0.7718*(1-exp(-11.2234.*(0:.01:1))))+0.2518),hGUI.gObj.p_off); % tau = 89.10 ms
           lH.lineg;lH.setName(sprintf('expGain'));lH.h.LineWidth=2;
           

           lH=lineH([0 hGUI.onGain_ttp],[1 hGUI.onGain],hGUI.gObj.p_on);
           lH.liner;lH.setName(sprintf('modelGain'));lH.h.LineWidth=2;
           
           lH=lineH([0 hGUI.offGain_ttp],[hGUI.onGain(end) hGUI.offGain],hGUI.gObj.p_off);
           lH.liner;lH.setName(sprintf('modelGain'));lH.h.LineWidth=2;
           
           
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
               case 'cModelUni_clamped'
                   slidermax = {1000 5000 5000};
               case 'cModelBi_clamped'
                   slidermax = {1000 5000 5000 5000};
               case 'cModelBi'
                   slidermax = {5000 2000 2000 1000 5000 1000 5000 5000 1000 100 1000};
               case 'vhModel'
                   slidermax = {5000 2000 20000 1000 1000};
               case '@(varargin)hGUI.vhModel(varargin{:})'
                   slidermax = {5000 2000 20000 1000 1000};
               case '@(varargin)hGUI.riekeModel(varargin{:})'
                   slidermax = {5000 2000 20000 1000 1000 1000};
               case 'vhModel_clamped'
                   slidermax = {5000 50000 1000};
               case 'rModel_clamped'
                   slidermax = {5000 50};
               case 'rModel6_clamped'
                   slidermax = {500 1000};
               case 'riekeModel'
                   slidermax ={1000 1000 20000 1000 1000};
               case 'rModel_notClamped'
                   slidermax ={1000 1000 20000 1000 1000};
           end
           sliderorient = cell(1,hGUI.n);
           sliderorient(1,:) = {0};
           slidermin = sliderorient;
           
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
           tempstm=[ones(1,hGUI.padpts)*hGUI.s_stm(1) hGUI.s_stm];
           temptme=(1:1:length(tempstm)).*hGUI.dt;
           if hGUI.riekeFlag
               tempfit=hGUI.modelFx(hGUI.curr,temptme,tempstm);
           else
               tempfit=hGUI.modelFx(hGUI.curr,temptme,tempstm,hGUI.dt);
           end          
           hGUI.s_cfit=tempfit(hGUI.padpts+1:end); 
           
           lH.YData = hGUI.s_cfit;
           lH.LineWidth = 2;
               
               
           for i = 1:hGUI.nf
               lH = findobj('tag',sprintf('sf_ifit%02g',i));%HACK!!! this should be cfit
               tempstm=[ones(1,hGUI.padpts)*hGUI.sf_stm(i,1) hGUI.sf_stm(i,:)];
               temptme=(1:1:length(tempstm)).*hGUI.dt;
               if hGUI.riekeFlag
                   tempfit=hGUI.modelFx(hGUI.curr,temptme,tempstm);
               else
                   tempfit=hGUI.modelFx(hGUI.curr,temptme,tempstm,hGUI.dt);
               end
               hGUI.sf_cfit(i,:)=tempfit(hGUI.padpts+1:end);
               
               lH.YData = hGUI.sf_cfit(i,:);
               lH.LineWidth = 2;
           end
       end
       
       function runLSQ(hGUI,~,~)
           % least-squares fitting
           
           fprintf('Started lsq fitting.....\n')
           LSQ = struct;
           if true%==false
               i2use = 2;
               fprintf('Fitting to steps + flashes #%g\n',i2use)
               LSQ.ydata=hGUI.sf(i2use,:);
               if hGUI.riekeFlag
                   lsqfun=@(optcoeffs,tme)hGUI.modelFx(optcoeffs,hGUI.tme,hGUI.sf_stm(i2use,:));
               else
                   lsqfun=@(optcoeffs,tme)hGUI.modelFx(optcoeffs,hGUI.tme,hGUI.sf_stm(i2use,:),hGUI.dt);
               end
           else
               LSQ.ydata=hGUI.s; %#ok<UNRCH>
               fprintf('Fitting to step (no flashes)\n')
               if hGUI.riekeFlag
                   lsqfun=@(optcoeffs,tme)hGUI.modelFx(optcoeffs,hGUI.tme,hGUI.s_stm);
               else
                   lsqfun=@(optcoeffs,tme)hGUI.modelFx(optcoeffs,hGUI.tme,hGUI.s_stm,hGUI.dt);
               end
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
           if hGUI.riekeFlag
               optfx=@(optcoeffs)hGUI.modelFx(optcoeffs,hGUI.tme,hGUI.s_stm);
           else
               optfx=@(optcoeffs)hGUI.modelFx(optcoeffs,hGUI.tme,hGUI.s_stm,hGUI.dt);
           end
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
           fprintf('Fitted to step (no flashes)\n')
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
           
           tempstm=[ones(1,hGUI.padpts)*hGUI.s_stm(1) hGUI.s_stm];
           temptme=(1:1:length(tempstm)).*hGUI.dt;
           if hGUI.riekeFlag
               tempfit=hGUI.modelFx(hGUI.fit,temptme,tempstm);
           else
               tempfit=hGUI.modelFx(hGUI.fit,temptme,tempstm,hGUI.dt);
           end
           hGUI.s_ffit=tempfit(hGUI.padpts+1:end);
           
           lH.YData = hGUI.s_ffit;
           lH.LineWidth=2;
           
           
           for i = 1:hGUI.nf
               lH = findobj('tag',sprintf('sf_ifit%02g',i));%HACK!!! this should be ffit
               tempstm=[ones(1,hGUI.padpts)*hGUI.sf_stm(i,1) hGUI.sf_stm(i,:)];
               temptme=(1:1:length(tempstm)).*hGUI.dt;
               if hGUI.riekeFlag
                   tempfit=hGUI.modelFx(hGUI.fit,temptme,tempstm);
               else
                   tempfit=hGUI.modelFx(hGUI.fit,temptme,tempstm,hGUI.dt);
               end
               hGUI.sf_ffit(i,:)=tempfit(hGUI.padpts+1:end);
               
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
           if hGUI.riekeFlag
               tempfit=hGUI.modelFx(hGUI.curr,temptme,tempstm);
           else
               tempfit=hGUI.modelFx(hGUI.curr,temptme,tempstm,hGUI.df_dt);
           end
           hGUI.df_cfit = tempfit(5001:end);
       end
       
       
       function extractFlashes(hGUI,~,~)
            % Pre and Post flashes
            fstart =hGUI.difix(1);
            fend = fstart + hGUI.digap-1;
            hGUI.ffix(1,:) = hGUI.f(1,fstart:fend);
            hGUI.ffix_ifit(1,:) = hGUI.f_ifit(1,fstart:fend);
            hGUI.ffix_cfit(1,:) = hGUI.f_cfit(1,fstart:fend);
            hGUI.ffix_ffit(1,:) = hGUI.f_ffit(1,fstart:fend);
            
            fstart =hGUI.difix(2);
            fend = fstart + hGUI.digap-1;
            hGUI.ffix(2,:) = hGUI.f(1,fstart:fend);
            hGUI.ffix_ifit(2,:) = hGUI.f_ifit(1,fstart:fend);
            hGUI.ffix_cfit(2,:) = hGUI.f_cfit(1,fstart:fend);
            hGUI.ffix_ffit(2,:) = hGUI.f_ffit(1,fstart:fend);
            
            hGUI.ffixtme(1,:) = (0:hGUI.digap-1).*hGUI.dt-0.1;
            hGUI.ffixtme(2,:) = (0:hGUI.digap-1).*hGUI.dt+0.8;
            
            dG = max(hGUI.ffix(1,:));
            dGi = max(hGUI.ffix_ifit(1,:));
            dGc = max(hGUI.ffix_cfit(1,:));
            dGf = max(hGUI.ffix_ffit(1,:));
            
            hGUI.ffix(1,:) = hGUI.ffix(1,:)./dG;
            hGUI.ffix_ifit(1,:) = hGUI.ffix_ifit(1,:)./dGi;
            hGUI.ffix_cfit(1,:) = hGUI.ffix_cfit(1,:)./dGc;
            hGUI.ffix_ffit(1,:) = hGUI.ffix_ffit(1,:)./dGf;
            
            hGUI.ffix(2,:) = hGUI.ffix(2,:)./dG./2; %for example cell on flashes are double intensity
            hGUI.ffix_ifit(2,:) = hGUI.ffix_ifit(2,:)./dGi./2;
            hGUI.ffix_cfit(2,:) = hGUI.ffix_cfit(2,:)./dGc./2;
            hGUI.ffix_ffit(2,:) = hGUI.ffix_ffit(2,:)./dGf./2;
            
            
            for i=1:hGUI.nf
                fstart = hGUI.distep(1)+hGUI.didelta(i);
                fend = fstart + hGUI.digap-1;
                hGUI.fon(i,:) = hGUI.f(i,fstart:fend)./dG./2; %for example cell on flashes are double intensity
                hGUI.fon_ifit(i,:) = hGUI.f_ifit(i,fstart:fend)./dGi./2;
                hGUI.fon_cfit(i,:) = hGUI.f_cfit(i,fstart:fend)./dGc./2;
                hGUI.fon_ffit(i,:) = hGUI.f_ffit(i,fstart:fend)./dGf./2;
                
                fstart = hGUI.distep(2)+hGUI.didelta(i);
                fend = fstart + hGUI.digap-1;
                hGUI.foff(i,:) = hGUI.f(i,fstart:fend)./dG;
                hGUI.foff_ifit(i,:) = hGUI.f_ifit(i,fstart:fend)./dGi;
                hGUI.foff_cfit(i,:) = hGUI.f_cfit(i,fstart:fend)./dGc;
                hGUI.foff_ffit(i,:) = hGUI.f_ffit(i,fstart:fend)./dGf;
                
                hGUI.ftme(i,:) = ([0:hGUI.digap-1]+hGUI.didelta(i)).*hGUI.dt;
            end
           
           
       end
   
       function mapGainCurve(hGUI,~,~)
            s_stim = hGUI.s_stm;
            s_start = find(s_stim==max(s_stim),1,'first');
            f_pts = sum(hGUI.f_stm(1,1:8000)==max(hGUI.f_stm(1,1:8000)));
            f_amp = max(hGUI.f_stm(1,:));
            f_start = find(s_stim==max(s_stim),1,'first');
            f_end = find(s_stim==max(s_stim),1,'last');
            f_stim = zeros(size(s_stim));
            f_stim(f_start:f_start+f_pts) = f_amp;
            f_circpts = 100;
            f_n = floor((f_end - f_start)*.98/f_circpts);
            s_pts = f_end - f_start;
            
            % step only
            tempstm=[ones(1,hGUI.padpts)*hGUI.s_stm(1) (s_stim)]; %padding
            temptme=(1:1:length(tempstm)).*hGUI.dt;
            if hGUI.riekeFlag
                tempfit=hGUI.modelFx(hGUI.ini,temptme,tempstm);
            else
                tempfit=hGUI.modelFx(hGUI.ini,temptme,tempstm,hGUI.dt);
            end
            s_fit=tempfit(hGUI.padpts+1:end);
            sf_fit = NaN(f_n,length(s_fit));
            f_fit = NaN(f_n,length(s_fit));
            % dark flash (to get dark gain and making half as bright to match data)
            tempstm=[zeros(1,hGUI.padpts) circshift(f_stim,-round(.1/hGUI.dt))./2]; %padding
            temptme=(1:1:length(tempstm)).*hGUI.dt;
            if hGUI.riekeFlag
                tempfit=hGUI.modelFx(hGUI.ini,temptme,tempstm);
            else
                tempfit=hGUI.modelFx(hGUI.ini,temptme,tempstm,hGUI.dt);
            end
            fdark_fit=tempfit(hGUI.padpts+1:end);
            darkGain = max(fdark_fit-fdark_fit(end)) ./ (f_amp/2);
            % light-adapted flash (to get steady-state gain)
            tempstm=[ones(1,hGUI.padpts)*hGUI.s_stm(1) (s_stim + circshift(f_stim,+round(.9/hGUI.dt)))]; %padding
            temptme=(1:1:length(tempstm)).*hGUI.dt;
%             tempfit=hGUI.modelFx(hGUI.ini,temptme,tempstm,hGUI.dt);
%             flight_fit=tempfit(hGUI.padpts+1:end)-s_fit;
%             lightGain = max(flight_fit-fdark_fit(end)) ./ (f_amp);
                        
%             figure(2)
%             clf
%             hold all

            hGUI.onGain = NaN(1,f_n);
            hGUI.onGain_delta = NaN(1,f_n);
            hGUI.onGain_ttp = NaN(1,f_n);
            
            hGUI.offGain = NaN(1,f_n);
            hGUI.offGain_delta = NaN(1,f_n);
            hGUI.offGain_ttp = NaN(1,f_n);
            for i = 1:f_n
                % step onset
                tempstm=[ones(1,hGUI.padpts)*hGUI.s_stm(1) (s_stim + circshift(f_stim,f_circpts*(i-1)))]; %padding
                temptme=(1:1:length(tempstm)).*hGUI.dt;
                if hGUI.riekeFlag
                    tempfit=hGUI.modelFx(hGUI.ini,temptme,tempstm);
                else
                    tempfit=hGUI.modelFx(hGUI.ini,temptme,tempstm,hGUI.dt);
                end
                sf_fit(i,:)=tempfit(hGUI.padpts+1:end);
                f_fit(i,:) = sf_fit(i,:) - s_fit; %subtract step response
                hGUI.onGain(i) = max(f_fit(i,:)) ./ (f_amp) ./ darkGain;
                hGUI.onGain_ttp (i) = find(f_fit(i,:)==max(f_fit(i,:)),1,'first');
                hGUI.onGain_ttp (i) = (hGUI.onGain_ttp (i) - s_start) * hGUI.dt;
                hGUI.onGain_delta(i) = i * (f_circpts * hGUI.dt);
                
                %step offset
                tempstm=[ones(1,hGUI.padpts)*hGUI.s_stm(1) (s_stim + circshift(f_stim./2,s_pts + f_circpts*(i-1)))]; %padding and making flash half as bright
                temptme=(1:1:length(tempstm)).*hGUI.dt;
                if hGUI.riekeFlag
                    tempfit=hGUI.modelFx(hGUI.ini,temptme,tempstm);
                else
                    tempfit=hGUI.modelFx(hGUI.ini,temptme,tempstm,hGUI.dt);
                end
                sf_fit(i,:)=tempfit(hGUI.padpts+1:end);
                f_fit(i,:) = sf_fit(i,:) - s_fit; %subtract step response
                hGUI.offGain(i) = max(f_fit(i,:)) ./ (f_amp./2) ./ darkGain; %flash half as bright
                hGUI.offGain_ttp (i) = find(f_fit(i,:)==max(f_fit(i,:)),1,'first');
                hGUI.offGain_ttp (i) = (hGUI.offGain_ttp (i) - f_end) * hGUI.dt;
                hGUI.offGain_delta(i) = i * (f_circpts * hGUI.dt);
% %                 plot(sf_fit(i,:),'-','LineWidth',2);
%                 plot(f_fit(i,:),'-','LineWidth',2);
            end
% %             plot(s_fit,'k-','LineWidth',2);
%             plot(fdark_fit,'k-','LineWidth',2);
%             figure(1)
%             clf
%             hold all
%             plot([0 hGUI.offGain_ttp 1],[darkGain/darkGain hGUI.onGain lightGain/darkGain],'o--');
%             plot([0 hGUI.offGain_ttp 1],[lightGain/darkGain hGUI.offGain darkGain/darkGain],'o--');
            
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
