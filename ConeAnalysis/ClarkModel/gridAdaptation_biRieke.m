classdef gridAdaptation_biRieke < adapt_riekefitGUI
   properties
       
   end
   
   methods
       function hGUI=gridAdaptation_biRieke(params,fign)
           % INITIALIZATION
           if nargin == 0
               params = struct;
               fign=10;
           elseif nargin == 1
               fign=10;
           end
           
           hGUI@adapt_riekefitGUI(fign);
           set(hGUI.figH,'KeyPressFcn',@hGUI.detectKey);
           
           % initialize properties
           hGUI.modelFx = @rModel6_clamped;     
           hGUI.n = 2;
           hGUI.names = {...
               '<html>iDark</html>',...
               '<html>opnGain</html>',...
               };

          params=checkStructField(params,'iDark',[150]); % dark current: low, high, step
          params=checkStructField(params,'opsinGain',[1,10,1]); % opsin Gain: low, high, step
           
          hGUI.ini = [params.iDark(1), params.opsinGain(1)];
          
          hGUI.loadData;
          hGUI.createObjects;
       end
   end
   
   methods (Static=true)

   end
   
end
