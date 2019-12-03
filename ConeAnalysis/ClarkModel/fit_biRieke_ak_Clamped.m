classdef fit_biRieke_ak_Clamped < akfitGUI
   properties
       
   end
   
   methods
       function hGUI=fit_biRieke_ak_Clamped(params,fign)
           % INITIALIZATION
           if nargin == 0
               params = struct;
               fign=10;
           elseif nargin == 1
               fign=10;
           end
           
           hGUI@akfitGUI(fign);
           set(hGUI.figH,'KeyPressFcn',@hGUI.detectKey);
           
           % initialize properties
           hGUI.modelFx = @rModel_clamped;     
           hGUI.n = 2;
           hGUI.names = {...
               '<html>gdark</html>',...
               '<html>opnGain</html>',...
               };

           
           params=checkStructField(params,'ini',[264 10]);
           
           params=checkStructField(params,'lower',[0 0]);
           params=checkStructField(params,'upper',[]);
           params=checkStructField(params,'plotFlag',0);
           
           hGUI.ini = params.ini;
           hGUI.curr = params.ini;
           hGUI.fit = NaN(1,hGUI.n);
           hGUI.upper = params.upper;
           hGUI.lower = params.lower;
           hGUI.plotFlag = params.plotFlag;
           
           hGUI.i2V = [350 1]; % holding current in darkness and scaling factor
           
           hGUI.loadData;
           hGUI.createObjects;
       end
   end
   
   methods (Static=true)

   end
   
end
