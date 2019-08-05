classdef fit_monoClark_ak < akfitGUI
   properties
       
   end
   
   methods
       function hGUI=fit_monoClark_ak(params,fign)
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
           hGUI.modelFx = @cModelUni;     
           hGUI.n = 8;
           hGUI.names = {'<html>&tau;Y</html>',...
               '<html>&tau;Z</html>',...
               '<html>ny</html>',...
               '<html>nz</html>',...
               '<html>&gamma;</html>',...
               '<html>&tau;R</html>',...
               '<html>&alpha;</html>',...
               '<html>&beta;</html>'};
           
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
%            params=checkStructField(params,'ini',[49.4,0124,0407,0.505,0341,41.7,0140,0223,0657,0132,20.8]);

            % fit directly to hyst data
%            params=checkStructField(params,'ini',[0115,0209,0276,14.1,37.9,0148,0907,0861,0707,15.2,0307]);
            
            % refitting to stj starting from params just above and keeping +5 pA
%            params=checkStructField(params,'ini',[67.5,0375,0249,0.0807,0252,71.2,0824,0778,0674,13.9,0130]);
           
            % refitting to stj starting from params just above and using +12 pA
           params=checkStructField(params,'ini',[87.1,0215,0236,0.0507,0334,82.3,1.26e+03,0932]);
          
           
           params=checkStructField(params,'lower',[0 0 0 0 0 0 0 0]);
           params=checkStructField(params,'upper',[]);
           params=checkStructField(params,'plotFlag',0);
           
           hGUI.ini = params.ini;
           hGUI.curr = params.ini;
           hGUI.fit = NaN(1,hGUI.n);
           hGUI.upper = params.upper;
           hGUI.lower = params.lower;
           hGUI.plotFlag = params.plotFlag;
           
           hGUI.i2V = [0 1]; % holding current in darkness and scaling factor
           
           hGUI.loadData;
           hGUI.createObjects;
       end
   end
   
   methods (Static=true)
       
   end
   
end
