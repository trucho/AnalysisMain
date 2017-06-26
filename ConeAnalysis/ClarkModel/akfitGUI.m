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
       end
       
       function loadData(hGUI,~,~)
           % DATA LOADING AND INITIAL FITS
           akdata = load('~/matlab/AnalysisMain/ConeAnalysis/ClarkModel/AK_example.mat');
           akdata = akdata.AK_example;
           hGUI.skipts=10;
           hGUI.dt=hGUI.skipts*(akdata.tAxis(2)-akdata.tAxis(1));
           
           hGUI.tme=akdata.tAxis(1:hGUI.skipts:end);
           hGUI.tme = hGUI.tme+.5;
           hGUI.nf = size(akdata.Flash,1);
           %stimulus is calibrated in R*/s, so for model, have to convert it to R*/dt
           hGUI.s_stm=akdata.StepStim(1,1:hGUI.skipts:end).*hGUI.dt;
           hGUI.f_stm = (akdata.FlashStim(:,1:hGUI.skipts:end)+repmat(akdata.FlashLockedStim(:,1:hGUI.skipts:end),hGUI.nf,1))*100.*hGUI.dt; % 100 converts from R*/flash(10ms) to R*/s
           hGUI.sf_stm=repmat(hGUI.s_stm,hGUI.nf,1)+hGUI.f_stm;
           
           hGUI.s=(akdata.Step(:,1:hGUI.skipts:end)./hGUI.i2V(2)) - hGUI.i2V(1);
           hGUI.sf=(akdata.Flash(:,1:hGUI.skipts:end)./hGUI.i2V(2)) - hGUI.i2V(1);
           hGUI.f = hGUI.isolatef(hGUI.sf,hGUI.s);
           
           
           
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

           hGUI.f_ifit = hGUI.isolatef(hGUI.sf_ifit,hGUI.s_ifit);
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
           h = 350;
           w1 = 360+40;
           w2 = 360-40;
           l1 = 230;
           l2 = 630+40;
           t1 = 920;
           t2 = 520;
           t3 = 100;
           
           % stim
           hGUI.createPlot(struct('Position',[l1 t1 w1 60]./1000,'tag','stim'));
           hGUI.hidex(hGUI.gObj.stim)
           hGUI.labely(hGUI.gObj.stim,'R*/s')
           hGUI.xlim(hGUI.gObj.stim,hGUI.minmax(hGUI.tme))
           hGUI.ylim(hGUI.gObj.stim,hGUI.minmax(hGUI.sf_stm)./hGUI.dt)
           
           lH=lineH(hGUI.tme,hGUI.s_stm/hGUI.dt,hGUI.gObj.stim);
           lH.linek;lH.setName('stim_s');lH.h.LineWidth=2;
           
           for i=1:hGUI.nf
               lH=lineH(hGUI.tme,hGUI.sf_stm(i,:)/hGUI.dt,hGUI.gObj.stim);
               lH.line;lH.color(hGUI.pcolors(i,:));lH.setName(sprintf('stim_f%02g',i));lH.h.LineWidth=1;
           end
           
           % responses
           hGUI.createPlot(struct('Position',[l1 t2 w1 h]./1000,'tag','resp'));
           hGUI.labelx(hGUI.gObj.resp,'Time (s)')
           hGUI.labely(hGUI.gObj.resp,'i (pA)')
           hGUI.xlim(hGUI.gObj.resp,hGUI.minmax(hGUI.tme))
%            hGUI.ylim(hGUI.gObj.resp,[-10 80])
                     
           for i = 1:hGUI.nf
              lH=lineH(hGUI.tme,hGUI.sf(i,:),hGUI.gObj.resp); % response
              lH.line;lH.color(hGUI.pwcolors(i,:));lH.setName(sprintf('sf%02g',i));lH.h.LineWidth=1;
           end
           lH=lineH(hGUI.tme,hGUI.s,hGUI.gObj.resp); % response
           lH.lineg;lH.setName('s');lH.h.LineWidth=2;
           
           
           for i = 1:hGUI.nf
              lH=lineH(hGUI.tme,hGUI.sf_ifit(i,:),hGUI.gObj.resp); % response
              lH.line;lH.color(hGUI.pcolors(i,:));lH.setName(sprintf('sf_ifit%02g',i));lH.h.LineWidth=2;
           end
           lH=lineH(hGUI.tme,hGUI.s_ifit,hGUI.gObj.resp); % initial fit
           lH.linek;lH.setName('s_ifit');lH.h.LineWidth=2;
           
           % isolated flashes
           hGUI.createPlot(struct('Position',[l1 t3 w1 h]./1000,'tag','respf'));
           hGUI.labelx(hGUI.gObj.respf,'Time (s)')
           hGUI.labely(hGUI.gObj.respf,'i (pA)')
%            hGUI.xlim(hGUI.gObj.pstim,hGUI.minmax(hGUI.tme2))           
           for i = hGUI.nf:-1:1
              lH=lineH(hGUI.tme,hGUI.f(i,:),hGUI.gObj.respf); % response
              lH.line;lH.color(hGUI.pwcolors(i,:));lH.setName(sprintf('f%02g',i));lH.h.LineWidth=1;
           end
           
           for i = hGUI.nf:-1:1
              lH=lineH(hGUI.tme,hGUI.f_ifit(i,:),hGUI.gObj.respf); % response
              lH.line;lH.color(hGUI.pcolors(i,:));lH.setName(sprintf('f_ifit%02g',i));lH.h.LineWidth=2;
           end
           

           
           % on flashes?
           hGUI.createPlot(struct('Position',[l2 t2 w2 h]./1000,'tag','on'));
           hGUI.labelx(hGUI.gObj.on,'Time (s)')
           hGUI.labely(hGUI.gObj.on,'i (pA)')
           
          
       end
       
       function createSliders(hGUI)
           switch func2str(hGUI.modelFx)
               case 'cModelUni'
                   slidermax = {5000 2000 2000 1000 5000 1000 5000 5000};
                   sliderorient = {0 0 0 0 0 0 0 0};
                   slidermin = {0 0 0 0 0 0 0 0};
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
               LSQ.ydata=hGUI.s;
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
           
           hGUI.f_ffit=hGUI.isolatef(hGUI.sf_ffit,hGUI.s_ffit);
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
       
   end
   
   methods (Static=true)
       
       function flashmat=isolatef(stepflashes,step) % subtraction to isolate flashes
           flashmat = stepflashes - repmat(step,size(stepflashes,1),1);
       end
       
       function showResults(fitcoeffs)
           fprintf('\nccoeffs=[');fprintf('%04.3g,',fitcoeffs);fprintf('];\n')
       end
   end
   
end
