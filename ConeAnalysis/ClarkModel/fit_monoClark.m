classdef fit_monoClark < ephysGUI
   properties
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
       
       ak_resp
       ak_stim
       
       ak_ifit
       ak_cfit
       
       n = 8
       names = {'<html>&tau;Y</html>',...
               '<html>&tau;Z</html>',...
               '<html>ny</html>',...
               '<html>nz</html>',...
               '<html>&gamma;</html>',...
               '<html>&tau;R</html>',...
               '<html>&alpha;</html>',...
               '<html>&beta;</html>'}
       tnames
       colors = pmkmp(8,'CubicL')
       tcolors = round((pmkmp(8,'CubicL'))./1.2.*255)
       
%        n = 8
%        names = {'tauy','tauz','ny','nz','gamma','tauR','alpha','beta'}
%        
%        colors = pmkmp(n,'CubicL')
%        tcolors=round(colors.*255)
   end
   
   methods
       function hGUI=fit_monoClark(params,fign)
           if nargin == 0
               params = struct;
               fign=10;
           end
           
           if nargin == 1
               fign=10;
           end
           hGUI@ephysGUI(fign);
           set(hGUI.figH,'KeyPressFcn',@hGUI.detectKey);
           
           % load saccade trajectory data
           stjdata=load('~/matlab/matlab-analysis/trunk/users/juan/ConeModel/BiophysicalModel/EyeMovementsExample_092413Fc12vClamp.mat');
           stjdata = stjdata.EyeMovementsExample;
           hGUI.stj_stm
           hGUI.stj_skipts=20;
           hGUI.dt=hGUI.stj_skipts*(stjdata.TimeAxis(2)-stjdata.TimeAxis(1));
           
           hGUI.stj_tme=stjdata.TimeAxis(1:hGUI.stj_skipts:end);
           %stimulus is calibrated in R*/s, so for model, have to convert it to R*/dt
           hGUI.stj_stm=stjdata.Stim(1:hGUI.stj_skipts:end).*hGUI.dt;
           hGUI.stj_resp=stjdata.Mean(1:hGUI.stj_skipts:end)+5; % manually correcting trace so that darkness = 0 pA
           
%            hGUI.stj_tme=hGUI.stj_tme(1:2550);
%            hGUI.stj_stm=hGUI.stj_stm(1:2550);
%            hGUI.stj_resp=hGUI.stj_resp(1:2550);

           
           % fitting coefficients and boundaries
%            params=checkStructField(params,'ini',[0.0063,0.0046,3.4900,3.1600,0.0800,0.0010,10.2000,0.4440]);
           params=checkStructField(params,'ini',[63,46,349,316,80,10,102,444]);
           params=checkStructField(params,'lower',[]);
           params=checkStructField(params,'upper',[]);
           
           
           hGUI.ini = params.ini;
           hGUI.curr = params.ini;
           hGUI.fit = NaN(1,hGUI.n);
           hGUI.upper = params.upper;
           hGUI.lower = params.lower;
           
           hGUI.tnames = {...
               sprintf('<html><font color=rgb(%d,%d,%d)>&tau;Y</font></html>',hGUI.tcolors(1,1),hGUI.tcolors(1,2),hGUI.tcolors(1,3)),...
               sprintf('<html><font color=rgb(%d,%d,%d)>&tau;Z</font></html>',hGUI.tcolors(2,1),hGUI.tcolors(2,2),hGUI.tcolors(2,3)),...
               sprintf('<html><font color=rgb(%d,%d,%d)>ny</font></html>',hGUI.tcolors(3,1),hGUI.tcolors(3,2),hGUI.tcolors(3,3)),...
               sprintf('<html><font color=rgb(%d,%d,%d)>nz</font></html>',hGUI.tcolors(4,1),hGUI.tcolors(4,2),hGUI.tcolors(4,3)),...
               sprintf('<html><font color=rgb(%d,%d,%d)>&gamma;</font></html>',hGUI.tcolors(5,1),hGUI.tcolors(5,2),hGUI.tcolors(5,3)),...
               sprintf('<html><font color=rgb(%d,%d,%d)>&tau;R</font></html>',hGUI.tcolors(6,1),hGUI.tcolors(6,2),hGUI.tcolors(6,3)),...
               sprintf('<html><font color=rgb(%d,%d,%d)>&alpha;</font></html>',hGUI.tcolors(7,1),hGUI.tcolors(7,2),hGUI.tcolors(7,3)),...
               sprintf('<html><font color=rgb(%d,%d,%d)>&beta;</font></html>',hGUI.tcolors(8,1),hGUI.tcolors(8,2),hGUI.tcolors(8,3)),...
               };

           
           
           % table with coefficients
           hGUI.coeffTable;
           % buttons for LSQ and FMINCON and acceptFit 
           hGUI.lsqButton;
           hGUI.fmcButton;
           hGUI.okfitButton;
           % create sliders to control parameters
           hGUI.createSliders;
           
           % graphs
           hGUI.createPlot(struct('Position',[230 835 450 150]./1000,'tag','stpstim'));
           hGUI.hidex(hGUI.gObj.stpstim)
           hGUI.labely(hGUI.gObj.stpstim,'R*/s')
           hGUI.xlim(hGUI.gObj.stpstim,hGUI.minmax(hGUI.stj_tme))
           % stimulus
           lH=lineH(hGUI.stj_tme,hGUI.stj_stm,hGUI.gObj.stpstim);
           lH.linek;lH.setName('stjstim');lH.h.LineWidth=2;
           
           
           hGUI.createPlot(struct('Position',[230 475 450 350]./1000,'tag','stp'));
           hGUI.labelx(hGUI.gObj.stp,'Time (s)')
           hGUI.labely(hGUI.gObj.stp,'i (pA)')
           hGUI.xlim(hGUI.gObj.stp,hGUI.minmax(hGUI.stj_tme))
           hGUI.ylim(hGUI.gObj.stp,[-10 80])
           % response
           lH=lineH(hGUI.stj_tme,hGUI.stj_resp,hGUI.gObj.stp);
           lH.linek;lH.setName('stjresp');lH.h.LineWidth=2;
           % initial fit
           tempstm=[ones(1,1000)*hGUI.stj_stm(1) hGUI.stj_stm];
           temptme=(1:1:length(tempstm)).*hGUI.dt;
           hGUI.stj_ifit=cModelUni(hGUI.ini,temptme,tempstm,hGUI.dt);
           hGUI.stj_ifit=hGUI.stj_ifit(1001:end);
           lH=lineH(hGUI.stj_tme,hGUI.stj_ifit,hGUI.gObj.stp);
           lH.line;lH.setName('stjifit');lH.h.LineWidth=1;
           lH.color([.5 .5 .5]);
           %current fit
           hGUI.stj_cfit=hGUI.stj_ifit;
           lH=lineH(hGUI.stj_tme,hGUI.stj_cfit,hGUI.gObj.stp);
           lH.liner;lH.setName('stjcfit');lH.h.LineWidth=1;
           
           hGUI.createPlot(struct('Position',[230 065 450 350]./1000,'tag','ak'));
           hGUI.labelx(hGUI.gObj.ak,'Time (s)')
           hGUI.labely(hGUI.gObj.ak,'i (pA)')
           
           hGUI.figH.Position=hGUI.figH.Position;
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
               sliders(i).Position = [2 670-(75*i) 190 60]./1000;
               sliders(i).tag = sprintf('slider%02g',i);
               sliders(i).Color = hGUI.colors(i,:)./1.2;
               sliders(i).ToolTipText = hGUI.tnames{i};
               
               hGUI.jSlider(sliders(i));
           end
           
       end
       
       function okfitButton(hGUI)
           okfittruct = struct;
           okfittruct.tag = 'okfitButton';
%            lsqbt.Callback = @hGUI.runLSQ;
           okfittruct.Position = [5 940 165 50]./1000;
           okfittruct.string = 'accept fit';
           
           hGUI.createButton(okfittruct);
       end
       
       function lsqButton(hGUI)
           lsqstruct = struct;
           lsqstruct.tag = 'lsqButton';
%            lsqbt.Callback = @hGUI.runLSQ;
           lsqstruct.Position = [5 890 80 50]./1000;
           lsqstruct.string = 'lsq';
           
           hGUI.createButton(lsqstruct);
       end
       
       function fmcButton(hGUI)
           fmcstruct = struct;
           fmcstruct.tag = 'fmcButton';
%            lsqbt.Callback = @hGUI.runLSQ;
           fmcstruct.Position = [90 890 80 50]./1000;
           fmcstruct.string = 'fmincon';
           
           hGUI.createButton(fmcstruct);
       end
           
       function coeffTable(hGUI)
           tableinput = struct;
           tableinput.tag = 'coefftable';
           tableinput.Position = [10, 680, 155, 200]./1000;
           tableinput.ColumnName = {'initial','curr','fit'};
           tableinput.RowName = hGUI.tnames;
           tableinput.Data = [hGUI.ini;hGUI.curr;hGUI.fit]';
           tableinput.headerWidth = 30;
           tableinput.ColumnWidth = {40,40,40};
           
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
           if isfield(hGUI.gObj,'slider08') %check if all sliders have been created
               newcurr = NaN(1,8);
               for i=1:hGUI.n
                   slidername = sprintf('slider%02g',i);
                   newcurr(i) = hGUI.gObj.(slidername).Value;
               end
               hGUI.gObj.infoTable.Data(:,2) = newcurr;
               hGUI.curr = newcurr;
               
           end
       end
       
       function updatePlots(hGUI,~,~)
           lH = findobj('tag','stjcfit');
           
           tempstm=[ones(1,1000)*hGUI.stj_stm(1) hGUI.stj_stm];
           temptme=(1:1:length(tempstm)).*hGUI.dt;
           hGUI.stj_cfit=cModelUni(hGUI.curr,temptme,tempstm,hGUI.dt);
           hGUI.stj_cfit=hGUI.stj_cfit(1001:end);
           
           lH.YData = hGUI.stj_cfit;
       end
       
   end
   
   methods (Static=true)
       
   end
   
end
