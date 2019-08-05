classdef fit_monoClarkKyClamped < clarkfitGUI
   properties
       
   end
   
   methods
       function hGUI=fit_monoClarkKyClamped(params,fign)
           % INITIALIZATION
           if nargin == 0
               params = struct;
               fign=10;
           elseif nargin == 1
               fign=10;
           end
           hGUI@clarkfitGUI(fign);
           set(hGUI.figH,'KeyPressFcn',@hGUI.detectKey);
           
           % initialize properties
           hGUI.modelFx = @cModelUni_Ky_clamped;     
           hGUI.n = 5;
           hGUI.names = {'<html>&tau;Z</html>',...
               '<html>nz</html>',...
               '<html>&gamma;</html>',...
               '<html>&alpha;</html>',...
               '<html>&beta;</html>'};
           
           
           % Aug_2019 (using [tau_y = 26, ny = 367, tau_r = 275]
%            params=checkStructField(params,'ini',[0400,0100,0846,0891,0771]); %this one has nz < 1 as optimal fit
%            params=checkStructField(params,'ini',[0178,0100,0790,0851,0950]); % restricting gamma c[0,1] and nz > 1; seems like these are really the best fit params but model is definitely trying to get average good behavior

           % Aug_2019 (using [tau_y = 45, ny = 433, tau_r = 48]
           
           params=checkStructField(params,'ini',[0166,0100,0448,0194,0360]); % restricting gamma c[0,1] and nz > 1; seems like these are really the best fit params but model is definitely trying to get average good behavior
           params=checkStructField(params,'ini',[0357,2.28e-14,0518,0203,0261]); %this one has nz < 1 as optimal fit but it's almost the same

           
           
           params=checkStructField(params,'lower',[0 0 0 0 0]);
%            params=checkStructField(params,'lower',[0 0 100 0 0]);
           params=checkStructField(params,'upper',[Inf Inf Inf Inf Inf ]);
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
       
   end
   
end
