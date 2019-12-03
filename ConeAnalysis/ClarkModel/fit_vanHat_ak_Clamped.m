classdef fit_vanHat_ak_Clamped < akfitGUI
   properties
       
   end
   
   methods
       function hGUI=fit_vanHat_ak_Clamped(params,fign)
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
           hGUI.modelFx = @vhModel_clamped;     
           hGUI.n = 3;
           hGUI.names = {...
               '<html>gdark</html>',...
               '<html>&eta;</html>',...
               '<html>OpsinGain</html>',...
               };

           
           params=checkStructField(params,'ini',[330 8585 10]);
           
           params=checkStructField(params,'lower',[0 0 0]);
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
       function [ios]=vhModel(coef,time,stim,varargin)
           ios = vhModel5(coef,time,stim,0);
           ios = -ios;
       end
   end
   
end
