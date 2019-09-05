classdef fit_monoClarkKy < clarkfitGUI
   properties
       
   end
   
   methods
       function hGUI=fit_monoClarkKy(params,fign)
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
           hGUI.modelFx = @cModelKy;     
           hGUI.n = 4;
           hGUI.names = {'<html>&tau;Y</html>',...
               '<html>ny</html>',...
               '<html>&tau;R</html>',...
               '<html>&alpha;</html>'};
           
           
           % from stj
           params=checkStructField(params,'ini',[44.8,0433,47.8,1800]); % faster version
           % from fitting
%            params=checkStructField(params,'ini',[29,367,275,100]);   % slower version
%            params=checkStructField(params,'ini',[94,270,10,10000]);   % slower version crashes cs
%            params=checkStructField(params,'ini',[94,270,10,100]);   % slower version
%            params=checkStructField(params,'ini',[22,510,282,1515]);   % slower version

           
           
           params=checkStructField(params,'lower',[0 0 0 0]);
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
       
   end
   
end
