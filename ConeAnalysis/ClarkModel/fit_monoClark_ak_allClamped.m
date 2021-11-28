classdef fit_monoClark_ak_allClamped < akfitGUI
   properties
       
   end
   
   methods
       function hGUI=fit_monoClark_ak_allClamped(params,fign)
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
           
           
%            params=checkStructField(params,'ini',[448,194,360]);
%            params=checkStructField(params,'ini',[448,8000,5000]);
           
%            best fit with params with stj fit:
%            tauy = 45 / 10000;
%            ny = 433 / 100;
%            tauR = 48 / 10000;
%            tauz = 166 / 1000;
%            nz = 100 / 100;
%            gamma = 448 / 100;
%            alpha = 19.4 / 100;
%            beta = 36/ 100;
           params=checkStructField(params,'ini',[31]); %modified scaling on Aug 13 for alpha and beta
%            params=checkStructField(params,'ini',[806,6440,3520]);
          
           
           params=checkStructField(params,'lower',[0]);
           params=checkStructField(params,'upper',[]);
           params=checkStructField(params,'plotFlag',0);
           params=checkStructField(params,'modelName','monoClark');
           
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
           ios = cModelUni_allclamped(coeffs,time,stim,dt);
           ios = ios * 290/136;
       end
   end
   
end
