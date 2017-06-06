classdef fit_biRieke_hyst < riekefitGUI_hyst
   properties
       
   end
   
   methods
       function hGUI=fit_biRieke_hyst(params,fign)
           % INITIALIZATION
           if nargin == 0
               params = struct;
               fign=10;
           elseif nargin == 1
               fign=10;
           end
           
           hGUI@riekefitGUI_hyst(fign);
           set(hGUI.figH,'KeyPressFcn',@hGUI.detectKey);
           
           % initialize properties
           hGUI.modelFx = @hGUI.riekeModel;     
           hGUI.n = 5;
           hGUI.names = {...
               '<html>hillA</html>',...
               '<html>&sigma;</html>',...
               '<html>&eta;</html>',...
               '<html>gdark</html>',...
               '<html>&beta;2</html>',...
               };

           
           % from vanHat fitting (works great)
%            params=checkStructField(params,'ini',[.5358 23.3425 905.5436 23.8226]);
           
           % fitting coefficients and boundaries
%            params=checkStructField(params,'ini',[0.562  22 1073.1 19.2 1.94]); %hillslow = 1;
%            params=checkStructField(params,'ini',[0.5846,19.077,1504.3,12.4863,2.75]); %hillslow = 3;
            % using fit from vanHat
%           params=checkStructField(params,'ini',[536 233 905 192 100]); %hillslow = 1;%betaslow has no effect
%           params=checkStructField(params,'ini',[585 191 1504 198 27]); %hillslow = 3;
          params=checkStructField(params,'ini',[474 220 8538 125 280]);  %hillslow = 3;
                      
           
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
       function [ios]=riekeModel(coef,time,stim,varargin)
           ios = rModel5(coef,time,stim,0);
           ios = -ios;
       end
   end
   
end
