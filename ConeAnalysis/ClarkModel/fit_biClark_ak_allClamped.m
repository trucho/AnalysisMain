classdef fit_biClark_ak_allClamped < akfitGUI
   properties
       
   end
   
   methods
       function hGUI=fit_biClark_ak_allClamped(params,fign)
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
           hGUI.modelFx = @hGUI.cmodel;     
           hGUI.n = 1;
           hGUI.names = {'<html>scaleFactor</html>'};
           

           
%            best fit with params with stj fit:
           params=checkStructField(params,'ini',[25.8]);
          
           
           params=checkStructField(params,'lower',[0 0 0 0]);
           params=checkStructField(params,'upper',[]);
           params=checkStructField(params,'plotFlag',0);
           params=checkStructField(params,'modelName','biClark');
           
           hGUI.ini = params.ini;
           hGUI.curr = params.ini;
           hGUI.fit = NaN(1,hGUI.n);
           hGUI.upper = params.upper;
           hGUI.lower = params.lower;
           hGUI.plotFlag = params.plotFlag;
           hGUI.modelName = params.modelName;
           
           hGUI.i2V = [0 1]; % holding current in darkness and scaling factor
           
           hGUI.loadData;
           hGUI.createObjects;
       end
   end
   
   methods (Static=true)
       function [ios]=cmodel(coeffs,time,stim,dt)
           ios = cModelBi_allclamped(coeffs,time,stim,dt);
           ios = ios * 290/136;
       end
   end
   
end
