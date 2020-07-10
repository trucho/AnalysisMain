classdef fit_biRieke < riekefitGUI
   properties
       
   end
   
   methods
       function hGUI=fit_biRieke(params,fign)
           % INITIALIZATION
           if nargin == 0
               params = struct;
               fign=10;
           elseif nargin == 1
               fign=10;
           end
           
           hGUI@riekefitGUI(fign);
           set(hGUI.figH,'KeyPressFcn',@hGUI.detectKey);
           
           % initialize properties
           hGUI.modelFx = @hGUI.riekeModel;
           hGUI.n = 6;
           hGUI.names = {...
               '<html>hillA</html>',...
               '<html>&sigma;</html>',...
               '<html>&eta;</html>',...
               '<html>iDark</html>',...
               '<html>&beta;2</html>',...
               '<html>&gamma;</html>',...
               };

%           params=checkStructField(params,'ini',[0300,220,2000,136,0400,0290]);  %pre-thesis params and rModel6
          params=checkStructField(params,'ini',[0500,220,2000,136,0400,1090]);  %pre-thesis params and rModel6
                      
           
           params=checkStructField(params,'lower',[0 0 0 0 0 0]);
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
       function [ios]=riekeModel(coef,time,stim,varargin)
           ios = rModel6(coef,time,stim,0);
       end
   end
   
end
