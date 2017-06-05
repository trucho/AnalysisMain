classdef fit_biClark < clarkfitGUI
   properties
       
   end
   
   methods
       function hGUI=fit_biClark(params,fign)
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
           hGUI.modelFx = @cModelBi;     
           hGUI.n = 11;
           hGUI.names = {'<html>&tau;Y</html>',...
               '<html>&tau;Z</html>',...
               '<html>ny</html>',...
               '<html>nz</html>',...
               '<html>&gamma;</html>',...
               '<html>&tau;R</html>',...
               '<html>&alpha;</html>',...
               '<html>&beta;</html>',...
               '<html>&gamma;2</html>',...
               '<html>&tau;2</html>',...
               '<html>nz2</html>'};
           
           % fitting coefficients and boundaries
           % these are all from uniClark
%            params=checkStructField(params,'ini',[0.0063,0.0046,3.4900,3.1600,0.0800,0.0010,10.2000,0.4440]);
%            params=checkStructField(params,'ini',[63,46,349,316,80,10,102,444]);
           % this is good for dim flash
%            params=checkStructField(params,'ini',[32.5,002,645,322,166,251,88.1,154]);
           % this is good for saccade trajectory
%            params=checkStructField(params,'ini',[46.5 95.1 328 125 752 99.9 448 493]);
           % slightly better fit but nz is almost null
%            params=checkStructField(params,'ini',[57.6,0259,0289,0.0128,0804,73.7,0571,0393]);

           % now for biClark
%            params=checkStructField(params,'ini',[57.6,0259,0289,0.0128,0804,73.7,0571,0393,285,94,91]);
%            params=checkStructField(params,'ini',[52.6,0182,0369,0.249,0453,50.5,0232,0350,0493,55.1,0139]);
           params=checkStructField(params,'ini',[49.4,0124,0407,0.505,0341,41.7,0140,0223,0657,0132,20.8]);
           
           params=checkStructField(params,'lower',[0 0 0 0 0 0 0 0 0 0 0]);
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
