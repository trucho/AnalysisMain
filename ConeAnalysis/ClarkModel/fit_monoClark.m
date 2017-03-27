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
       stj_dt
       
       stj_ifit
       stj_cfit
       
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
           hGUI.createPlot(struct('Position',[220 830 450 150]./1000,'tag','stjstim'));
           hGUI.createPlot(struct('Position',[220 470 450 350]./1000,'tag','stjresp'));
           
           hGUI.createPlot(struct('Position',[220 470 450 350]./1000,'tag','stjresp'));
           
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
           tableinput.ColumnWidth = {45,45,45};
           
           hGUI.infoTable(tableinput);
       end
       
       % callback functions
       function slidercCall(hGUI,~,~)
           if isfield(hGUI.gObj,'slider08') %check if all sliders have been created
               newcurr = NaN(1,8);
               for i=1:hGUI.n
                   slidername = sprintf('slider%02g',i);
                   newcurr(i) = hGUI.gObj.(slidername).Value;
               end
               hGUI.gObj.infoTable.Data(:,2) = newcurr;
           end
       end
       
   end
   
   methods (Static=true)
       
   end
   
end
