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
           
           params=checkStructField(params,'ini',[0.0063,0.0046,3.4900,3.1600,0.0800,0.0010,10.2000,0.4440,0.2850,0.0937,0.9120]);
           params=checkStructField(params,'lower',[]);
           params=checkStructField(params,'upper',[]);
           
           hGUI.ini = params.ini;
           hGUI.curr = params.ini;
           hGUI.upper = params.upper;
           hGUI.lower = params.lower;
           
           % table with coefficients
           hGUI.coeffTable;
           % buttons for LSQ and FMINCON and acceptFit 
           hGUI.lsqButton;
           hGUI.fmcButton;
           hGUI.acceptFitButton;
           % create sliders to control parameters
           hGUI.createSliders;
           
           % graphs
       end
       
       function coeffTable(hGUI)
           
           for i=1:
           
           tableinput = struct;
           tableinput.tag = 'coefftable';
           tableinput.Position = [0.01, .005, 0.185, .500];
           tableinput.ColumnName = {'Parameter','initial','curr','fit'};
           tableinput.xxxx = 'xxxxx';
           tableinput.xxxx = 'xxxxx';
           tableinput.xxxx = 'xxxxx';
           tableinput.xxxx = 'xxxxx';
           tableinput.xxxx = 'xxxxx';
           
       end
   end
   
   methods (Static=true)
       
   end
   
end
