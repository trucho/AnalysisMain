classdef eyemovements_sineClipped < ephysGUI
    % simplified figures for Steps+Sines
    properties
        node
        results
        phase
        plotflag
        tlimits
        
        colors
        wcolors
        tcolors
        
        tAxis
        tMask
    end
    
    methods
        function hGUI=eyemovements_sineClipped(node,params,fign)
            params=checkStructField(params,'plotflag',0);
            params=checkStructField(params,'phase','0000');
            hGUI@ephysGUI(fign);
            hGUI.layPlots();
            hGUI.node = node;
            hGUI.plotflag = params.plotflag;
            hGUI.phase = params.phase;
            
            results=toMatlabStruct(node.childBySplitValue(hGUI.phase).custom.get('results'));
            tAxis = results.means_tAxis;
            if hGUI.plotflag
                tMask = tAxis>-0.05 & tAxis<0.5;
            else
                tMask = tAxis>0.45 & tAxis<1;
                tAxis = tAxis - 0.5;
            end
           
            for i=4:-1:1
                ib = results.means_ib(i);
                ib_color=hGUI.colors(sort(results.means_ib)==ib,:);
                % stimulus
                lH=lineH(tAxis(tMask),results.means_stim(i,(tMask)),hGUI.gObj.plotStim);
                lH.line;lH.color(ib_color);lH.setName(sprintf('stim%s',round(ib)));lH.h.LineWidth=2;
                % isolated sines
                lH=lineH(tAxis(tMask),results.means(i,(tMask)),hGUI.gObj.plotData);
                lH.line;lH.color(ib_color);lH.setName(sprintf('data%s',round(ib)));lH.h.LineWidth=2;
                % response difference
                lH=lineH(tAxis(tMask),results.means_diff(i,(tMask)),hGUI.gObj.plotDiff);
                lH.line;lH.color(ib_color);lH.setName(sprintf('data%s',round(ib)));lH.h.LineWidth=2;
            end
            
            hGUI.tAxis = tAxis;
        end
        
        function layPlots(hGUI,~,~)
            hGUI.colors=pmkmp(4,'CubicLQuarter');
            hGUI.wcolors=whithen(hGUI.colors,.5);
            hGUI.tcolors=round(hGUI.colors./1.2.*255);
            
            % plot creation
            p=struct;
            p.left=.150;
            p.width=.70;
            p.height=.27;
            p.top=.05;
            p.hor = 0.32;
            
            % Stimulus
            plotStim=struct('Position',[p.left p.top+(p.hor*2) p.width p.height],'tag','plotStim');
            hGUI.createPlot(plotStim);
            hGUI.labelx(hGUI.gObj.plotStim,'Time (ms)');
            hGUI.labely(hGUI.gObj.plotStim,'I_b (R*/s)');
            
            % Data
            plotData=struct('Position',[p.left p.top+(p.hor) p.width p.height],'tag','plotData');
            hGUI.createPlot(plotData);
            hGUI.labelx(hGUI.gObj.plotData,'Time (ms)');
            hGUI.labely(hGUI.gObj.plotData,'i (pA)');
            
            % Difference
            plotDiff=struct('Position',[p.left p.top p.width p.height],'tag','plotDiff');
            hGUI.createPlot(plotDiff);
            hGUI.labelx(hGUI.gObj.plotDiff,'Time (ms)');
            hGUI.labely(hGUI.gObj.plotDiff,'i (pA)');
        end
    end
    
    methods (Static=true)
    end
end
