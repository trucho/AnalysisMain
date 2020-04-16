classdef fit_vanHat < vanHatfitGUI
   properties
       
   end
   
   methods
       function hGUI=fit_vanHat(params,fign)
           % INITIALIZATION
           if nargin == 0
               params = struct;
               fign=10;
           elseif nargin == 1
               fign=10;
           end
           
           hGUI@vanHatfitGUI(fign);
           set(hGUI.figH,'KeyPressFcn',@hGUI.detectKey);
           
           % initialize properties
           hGUI.modelFx = @hGUI.vhModel;    
           
           
           hGUI.n = 5;
           hGUI.names = {...
               '<html>hillA</html>',...
               '<html>&sigma;</html>',...
               '<html>&eta;</html>',...
               '<html>iDark</html>',...
               '<html>&gamma;</html>',...
               };

           params=checkStructField(params,'ini',[536 230 8585 136 13]);
           
           params=checkStructField(params,'lower',[0 0 0 0 0]);
           params=checkStructField(params,'upper',[]);
           params=checkStructField(params,'ak_subflag',0);
           
           hGUI.ini = params.ini;
           hGUI.curr = params.ini;
           hGUI.fit = NaN(1,hGUI.n);
           hGUI.upper = params.upper;
           hGUI.lower = params.lower;
           hGUI.ak_subflag = params.ak_subflag;
           
           hGUI.loadData;
           hGUI.createObjects;
       end
   end
   
   methods (Static=true)
       function [ios]=vhModel(coef,time,stim,varargin)
           ios = vhModel6(coef,time,stim,0);
       end
   end
   
end
