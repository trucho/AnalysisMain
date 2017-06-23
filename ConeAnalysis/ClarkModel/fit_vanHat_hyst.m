classdef fit_vanHat_hyst < hystfitGUI
   properties
       
   end
   
   methods
       function hGUI=fit_vanHat_hyst(params,fign)
           % INITIALIZATION
           if nargin == 0
               params = struct;
               fign=10;
           elseif nargin == 1
               fign=10;
           end
           
           hGUI@hystfitGUI(fign);
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
           % starting somewhere
%            params=checkStructField(params,'ini',[536 230 906 238]);
%            params=checkStructField(params,'ini',[536 230 8585 238]);
           % direct fit here
%            params=checkStructField(params,'ini',[650,0189,13400,0237]);
           
           %from biRieke
%            params=checkStructField(params,'ini',[474 220 8538 125]);  %hillslow = 3;
%            params=checkStructField(params,'ini',[474 220 8538 238]);  %hillslow = 3;
           % and fit starting from there
           params=checkStructField(params,'ini',[0635,0188,1.3e+04,0237]);  %hillslow = 3;
           
           
           params=checkStructField(params,'lower',[0 0 0 0]);
           params=checkStructField(params,'upper',[]);
           params=checkStructField(params,'plotFlag',0);
           
           hGUI.ini = params.ini;
           hGUI.curr = params.ini;
           hGUI.fit = NaN(1,hGUI.n);
           hGUI.upper = params.upper;
           hGUI.lower = params.lower;
           hGUI.plotFlag = params.plotFlag;
           
           hGUI.i2V = [135 1]; % holding current in darkness and scaling factor
           
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
