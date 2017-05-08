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
           hGUI.n = 4;
           hGUI.names = {...
               '<html>hillA</html>',...
               '<html>&sigma;</html>',...
               '<html>&eta;</html>',...
               '<html>gdark</html>',...
               };

           
           % fitting coefficients and boundaries
           % these are fits of rieke model
%            params=checkStructField(params,'ini',[0.562  22 1073.1 19.2 1.94]); %hillslow = 1;
%            params=checkStructField(params,'ini',[0.5846,19.077,1504.3,12.4863,2.75]); %hillslow = 3;
           
           % starting somewhere
%            params=checkStructField(params,'ini',[536 230 906 238]);
           params=checkStructField(params,'ini',[536 230 8585 238]);
           
           params=checkStructField(params,'lower',[0 0 0 0]);
           params=checkStructField(params,'upper',[]);
           
           hGUI.ini = params.ini;
           hGUI.curr = params.ini;
           hGUI.fit = NaN(1,hGUI.n);
           hGUI.upper = params.upper;
           hGUI.lower = params.lower;
           
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
