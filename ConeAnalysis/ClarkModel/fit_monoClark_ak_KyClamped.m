classdef fit_monoClark_ak_KyClamped < akfitGUI
   properties
       
   end
   
   methods
       function hGUI=fit_monoClark_ak_KyClamped(params,fign)
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
           hGUI.modelFx = @cModelUni_clamped;     
           hGUI.n = 3;
           hGUI.names = {'<html>&gamma;</html>',...
               '<html>&alpha;</html>',...
               '<html>&beta;</html>'};
           
           
           params=checkStructField(params,'ini',[448,194,360]);
%            params=checkStructField(params,'ini',[448,8000,5000]);
          
           
           params=checkStructField(params,'lower',[0 0 0]);
           params=checkStructField(params,'upper',[]);
           params=checkStructField(params,'plotFlag',0);
           
           hGUI.ini = params.ini;
           hGUI.curr = params.ini;
           hGUI.fit = NaN(1,hGUI.n);
           hGUI.upper = params.upper;
           hGUI.lower = params.lower;
           hGUI.plotFlag = params.plotFlag;
           
           hGUI.i2V = [0 1]; % holding current in darkness and scaling factor
           
           hGUI.loadData;
           hGUI.createObjects;
       end
   end
   
   methods (Static=true)
       
   end
   
end
