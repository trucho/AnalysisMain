classdef eyemovements_sineClipped < ephysGUI
    % simplified figures for Steps+Sines
    properties
        node
        results
        nullresults
        phase
        plotflag
        tlimits
        lpf_freq
        
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
            params=checkStructField(params,'lpf_freq',200);
            hGUI@ephysGUI(fign);
            hGUI.params = params;
            hGUI.layPlots();
            hGUI.node = node;
            hGUI.plotflag = params.plotflag;
            hGUI.phase = params.phase;
            hGUI.lpf_freq = params.lpf_freq;
            
            
            
            nullresults = toMatlabStruct(node.childBySplitValue('Null').custom.get('results'));
            results=toMatlabStruct(node.childBySplitValue(hGUI.phase).custom.get('results'));
            
            tAxis = nullresults.means_tAxis;
            if hGUI.plotflag
                tMask = tAxis>-0.05 & tAxis<0.5;
            else
                tMask = tAxis>0.45 & tAxis<1;
                tAxis = tAxis - 0.5;
            end
            
            for i=4:-1:1
                ib = results.means_ib(i);
                ib_color=hGUI.colors(sort(results.means_ib)==ib,:);
                ib_wcolor=hGUI.wcolors(sort(results.means_ib)==ib,:);
                
                % stimuli
                lH=lineH(tAxis(tMask),nullresults.means_stim(i,(tMask)),hGUI.gObj.pStim);
                lH.line;lH.color(ib_wcolor);lH.setName(sprintf('stepstim%g',round(ib)));lH.h.LineWidth=2;
                
                lH=lineH(tAxis(tMask),results.means_stim(i,(tMask)),hGUI.gObj.pStim);
                lH.line;lH.color(ib_color);lH.setName(sprintf('stim%g',round(ib)));lH.h.LineWidth=2;
                
                % combined data
                lH=lineH(tAxis(tMask),nullresults.means(i,(tMask)),hGUI.gObj.pData);
                lH.line;lH.color(ib_wcolor);lH.setName(sprintf('steps%g',round(ib)));lH.h.LineWidth=2;
                lH.lowPassFilter(hGUI.lpf_freq,1/20000);
                lH=lineH(tAxis(tMask),results.means_combined(i,(tMask)),hGUI.gObj.pData);
                lH.line;lH.color(ib_color);lH.setName(sprintf('combo%g',round(ib)));lH.h.LineWidth=2;
                lH.lowPassFilter(hGUI.lpf_freq,1/20000);
                
                % steps
                lH=lineH(tAxis(tMask),nullresults.means(i,(tMask)),hGUI.gObj.pStepData);
                lH.line;lH.color(ib_color);lH.setName(sprintf('steps%g',round(ib)));lH.h.LineWidth=2;
                lH.lowPassFilter(hGUI.lpf_freq,1/20000);
                % steps difference
                lH=lineH(tAxis(tMask),nullresults.means_diff(i,(tMask)),hGUI.gObj.pStepDiff);
                lH.line;lH.color(ib_color);lH.setName(sprintf('diff%g',round(ib)));lH.h.LineWidth=2;
                lH.lowPassFilter(hGUI.lpf_freq,1/20000);
                               
                % isolated sines
                lH=lineH(tAxis(tMask),results.means(i,(tMask)),hGUI.gObj.pSineData);
                lH.line;lH.color(ib_color);lH.setName(sprintf('sines%g',round(ib)));lH.h.LineWidth=2;
                lH.lowPassFilter(hGUI.lpf_freq,1/20000);
                % sines difference
                lH=lineH(tAxis(tMask),results.means_diff(i,(tMask)),hGUI.gObj.pSineDiff);
                lH.line;lH.color(ib_color);lH.setName(sprintf('diff%g',round(ib)));lH.h.LineWidth=2;
                lH.lowPassFilter(hGUI.lpf_freq,1/20000);
            end
            
            hGUI.tAxis = tAxis;
            hGUI.gObj.pStim.YLim=hGUI.gObj.pStim.YLim;
            
            hGUI.tLines;
            hGUI.results=results;
            hGUI.nullresults=nullresults;
        end
        
        function layPlots(hGUI)
            hGUI.colors=pmkmp(4,'CubicLQuarter');
            hGUI.wcolors=whithen(hGUI.colors,.5);
            hGUI.tcolors=round(hGUI.colors./1.2.*255);
            
            % plot creation
            p=struct;
            p.left=.06;
            p.left2=.55;
            p.width=.43;
            p.height=.27;
            p.top=.05;
            p.hor = 0.32;
            
            % Stimulus overlay
            pStim=struct('Position',[p.left p.top+(p.hor*2) p.width p.height],'tag','pStim');
            hGUI.createPlot(pStim);
            hGUI.labelx(hGUI.gObj.pStim,'Time (ms)');
            hGUI.labely(hGUI.gObj.pStim,'I_b (R*/s)');
            hGUI.gObj.pStim.XLim=[-0.05 0.5];
            
            % Combined data
            pData=struct('Position',[p.left2 p.top+(p.hor*2) p.width p.height],'tag','pData');
            hGUI.createPlot(pData);
            hGUI.labelx(hGUI.gObj.pData,'Time (ms)');
            hGUI.labely(hGUI.gObj.pData,'V_m (mV)');
            hGUI.gObj.pData.XLim=[-0.05 0.5];
            
            % Data
            pStepData=struct('Position',[p.left p.top+(p.hor) p.width p.height],'tag','pStepData');
            hGUI.createPlot(pStepData);
            hGUI.labelx(hGUI.gObj.pStepData,'Time (ms)');
            hGUI.labely(hGUI.gObj.pStepData,'V_m (mV)');
            hGUI.gObj.pStepData.XLim=[-0.05 0.5];
            
            pSineData=struct('Position',[p.left p.top p.width p.height],'tag','pSineData');
            hGUI.createPlot(pSineData);
            hGUI.labelx(hGUI.gObj.pSineData,'Time (ms)');
            hGUI.labely(hGUI.gObj.pSineData,'V_m (mV)');
            hGUI.gObj.pSineData.XLim=[-0.05 0.5];
            
            
            % Difference
            pStepDiff=struct('Position',[p.left2 p.top+(p.hor) p.width p.height],'tag','pStepDiff');
            hGUI.createPlot(pStepDiff);
            hGUI.labelx(hGUI.gObj.pStepDiff,'Time (ms)');
            hGUI.labely(hGUI.gObj.pStepDiff,'V_m (mV)');
            hGUI.gObj.pStepDiff.XLim=[-0.05 0.5];
            hGUI.gObj.pStepDiff.YLim=[-2 2];
            
            pSineDiff=struct('Position',[p.left2 p.top p.width p.height],'tag','pSineDiff');
            hGUI.createPlot(pSineDiff);
            hGUI.labelx(hGUI.gObj.pSineDiff,'Time (ms)');
            hGUI.labely(hGUI.gObj.pSineDiff,'V_m (mV)');
            hGUI.gObj.pSineDiff.XLim=[-0.05 0.5];
            hGUI.gObj.pSineDiff.YLim=[-2 2];
        end
        
        function tLines(hGUI)
            ti = repmat(hGUI.tAxis(find(hGUI.tAxis>=-0.05,1,'first')),1,2);
            to = repmat(hGUI.tAxis(find(hGUI.tAxis>=+0.00,1,'first')),1,2);
            tp = repmat(hGUI.tAxis(find(hGUI.tAxis<=+0.50,1,'last')),1,2);

            hGUI.doLines(ti,to,tp,hGUI.gObj.pData);
            hGUI.doLines(ti,to,tp,hGUI.gObj.pStepData);
            hGUI.doLines(ti,to,tp,hGUI.gObj.pStepDiff);
            hGUI.doLines(ti,to,tp,hGUI.gObj.pSineData);
            hGUI.doLines(ti,to,tp,hGUI.gObj.pSineDiff);
            
            hGUI.oLine(hGUI.gObj.pStepDiff);
            hGUI.oLine(hGUI.gObj.pSineData);
            hGUI.oLine(hGUI.gObj.pSineDiff);
        end
        
        function export2Igor(hGUI)
            global expname
            cellname = getcellname(hGUI.node);
            dir_h5 = '/Users/angueyraaristjm/hdf5/';
            dir_sines = 'EyeMovements/2019_StepsSines/';
            
            
            if exist(sprintf('%s%s%s/%s',dir_h5,dir_sines,expname,cellname),'dir')~=7
                mkdir(sprintf('%s%s%s/%s',dir_h5,dir_sines,expname,cellname));
            end

            if strcmpi(expname,'iC_hDown')
                if hGUI.params.plotflag
                    expsubname = 'hi2los';
                    hGUI.params.saveflag = 1;
                else
                    expsubname = 'los2hi';
                    hGUI.params.saveflag = 1;
                end
            elseif strcmpi(expname,'iC_hUp')
                if hGUI.params.plotflag
                    expsubname = 'lo2his';
                    hGUI.params.saveflag = 1;
                else
                    expsubname = 'his2lo';
                    hGUI.params.saveflag = 1;
                end
            end
            
            if ~ hGUI.params.saveflag
                error('Experiment not recognized');
            else
                makeAxisStruct(hGUI.gObj.pStim, sprintf('%sStim',expsubname) ,sprintf('%s%s/%s',dir_sines,expname,cellname));
                makeAxisStruct(hGUI.gObj.pData, sprintf('%sData',expsubname) ,sprintf('%s%s/%s',dir_sines,expname,cellname));
                makeAxisStruct(hGUI.gObj.pStepData, sprintf('%sStep',expsubname) ,sprintf('%s%s/%s',dir_sines,expname,cellname));
                makeAxisStruct(hGUI.gObj.pSineData, sprintf('%sSine',expsubname) ,sprintf('%s%s/%s',dir_sines,expname,cellname));
                makeAxisStruct(hGUI.gObj.pStepDiff, sprintf('%sStepDiff',expsubname) ,sprintf('%s%s/%s',dir_sines,expname,cellname));
                makeAxisStruct(hGUI.gObj.pSineDiff, sprintf('%sSineDiff',expsubname) ,sprintf('%s%s/%s',dir_sines,expname,cellname));
            end
        end
        
        
        function layPlotsOld(hGUI,~,~)
            hGUI.colors=pmkmp(4,'CubicLQuarter');
            hGUI.wcolors=whithen(hGUI.colors,.5);
            hGUI.tcolors=round(hGUI.colors./1.2.*255);
            
            % plot creation
            p=struct;
            p.left=.06;
            p.left2=.55;
            p.width=.43;
            p.height=.27;
            p.top=.05;
            p.hor = 0.32;
            
            % Step only
            % Stimulus
            pStim=struct('Position',[p.left p.top+(p.hor*2) p.width p.height],'tag','pStim');
            hGUI.createPlot(pStim);
            hGUI.labelx(hGUI.gObj.pStim,'Time (ms)');
            hGUI.labely(hGUI.gObj.pStim,'I_b (R*/s)');
            hGUI.gObj.pStim.XLim=[-0.05 0.5];
            % Data
            pStepData=struct('Position',[p.left p.top+(p.hor) p.width p.height],'tag','pStepData');
            hGUI.createPlot(pStepData);
            hGUI.labelx(hGUI.gObj.pStepData,'Time (ms)');
            hGUI.labely(hGUI.gObj.pStepData,'V_m (mV)');
            hGUI.gObj.pStepData.XLim=[-0.05 0.5];
            % Difference
            pStepDiff=struct('Position',[p.left p.top p.width p.height],'tag','pStepDiff');
            hGUI.createPlot(pStepDiff);
            hGUI.labelx(hGUI.gObj.pStepDiff,'Time (ms)');
            hGUI.labely(hGUI.gObj.pStepDiff,'V_m (mV)');
            hGUI.gObj.pStepDiff.XLim=[-0.05 0.5];
            hGUI.gObj.pStepDiff.YLim=[-2 2];
        
            % Sines (after isolation)
            % Stimulus
            pStim=struct('Position',[p.left2 p.top+(p.hor*2) p.width p.height],'tag','pStim');
            hGUI.createPlot(pStim);
            hGUI.labelx(hGUI.gObj.pStim,'Time (ms)');
            hGUI.labely(hGUI.gObj.pStim,'I_b (R*/s)');
            hGUI.gObj.pStim.XLim=[-0.05 0.5];
            % Data
            pSineData=struct('Position',[p.left2 p.top+(p.hor) p.width p.height],'tag','pSineData');
            hGUI.createPlot(pSineData);
            hGUI.labelx(hGUI.gObj.pSineData,'Time (ms)');
            hGUI.labely(hGUI.gObj.pSineData,'V_m (mV)');
            hGUI.gObj.pSineData.XLim=[-0.05 0.5];
            % Difference
            pSineDiff=struct('Position',[p.left2 p.top p.width p.height],'tag','pSineDiff');
            hGUI.createPlot(pSineDiff);
            hGUI.labelx(hGUI.gObj.pSineDiff,'Time (ms)');
            hGUI.labely(hGUI.gObj.pSineDiff,'V_m (mV)');
            hGUI.gObj.pSineDiff.XLim=[-0.05 0.5];
            hGUI.gObj.pSineDiff.YLim=[-2 2];
        end
    end
    
    methods (Static=true)
        function doLines(ti,to,tp,plotH)
            lH=lineH(ti,plotH.YLim,plotH);
            lH.lineg;lH.setName(sprintf('lim_i'));lH.h.LineWidth=2;
            lH=lineH(to,plotH.YLim,plotH);
            lH.lineg;lH.setName(sprintf('lim_o'));lH.h.LineWidth=2;
            lH=lineH(tp,plotH.YLim,plotH);
            lH.lineg;lH.setName(sprintf('lim_p'));lH.h.LineWidth=2;     
        end
        
        function oLine(plotH)
            lH=lineH(plotH.XLim,[0 0],plotH);
            lH.linek;lH.setName(sprintf('oLine'));lH.h.LineWidth=2;
        end
    end
end
