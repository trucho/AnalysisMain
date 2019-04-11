classdef vPulses_leakSub < ephysGUI
    % plots saved averages for all leaves underneath node?
    properties
        node
        results
    end
    
    methods
        % Constructor (gui objects and initial plotting)
        function hGUI=vPulses_leakSub(node,params,fign)
            params=checkStructField(params,'PlotNow',1);
            hGUI@ephysGUI(fign);
            hGUI.node = node;
            
            nV=node.children.length;
            colors=pmkmp(nV,'CubicL');
            wcolors=whithen(colors,.5);
            tcolors=round(colors./1.2.*255);
            
            RowNames=cell(size(nV));
            for i=1:nV
                RowNames{i}=sprintf('<html><font color=rgb(%d,%d,%d)>%g</font></html>',tcolors(i,1),tcolors(i,2),tcolors(i,3),round(node.children(i).splitValue));
            end
                     
%             % Steps as drop-down
%             ddinput=struct;
%             ddinput.Position=[0.01, .65, 0.105, .05];
%             ddinput.FontSize=14;
%             ddinput.String=RowNames;
%             ddinput.Callback=@hGUI.updateMenu;
%             hGUI.createDropdown(ddinput);
            
            tIn=struct;
            tIn.tag='infoTable';
            tIn.Position=[.01, .01, .12, .65];
            tIn.FontSize=10;
            tIn.ColumnWidth={50};
            tIn.Data=[true(nV,1) false(nV,1)];
            tIn.ColumnName={'Vm','lp'};
            tIn.RowName=RowNames;
            tIn.headerWidth=30;
            tIn.CellEditCallback=@hGUI.updatePlots;
            hGUI.createTable(tIn);
            
            text(0.1,0.9,'c06');
            
            tIn2=struct;
            tIn2.tag='cellinfo';
            tIn2.Position=[.01, .80, .12, .18];
            tIn2.FontSize=10;
            tIn2.ColumnWidth={80};
            tIn2.Data=hGUI.getcellinfo(node);
            tIn2.ColumnName={''};
            tIn2.RowName={'date','cellName','type','subtype','internal'};
            tIn2.headerWidth=60;
            tIn2.CellEditCallback=@hGUI.updatePlots;
            hGUI.createTable(tIn2);

            
            % buttons
%             hGUI.nextButton;
%             hGUI.prevButton;
%             hGUI.lockButton;
%             
%             accStruct=struct('callback',@hGUI.acceptButtonCall);
%             hGUI.acceptButton;

            % plot creation
            p=struct;
            p.width=.35;
            p.half_width = .17;
            
            p.left=.180;
            p.left2 = p.left+p.width+.07;
            p.left3 = p.left2+p.half_width+.05;
            
            
            p.half_top1=.555;
            p.half_top2=.08;
            p.half_height=.43;
            
            
            p.third_top1=.08;
            p.third_top2=.400;
            p.third_top3=.700;
            p.third_height=.26;
            
            
            
            
            
            
            % Data
            plotData=struct('Position',[p.left p.third_top2 p.width p.third_height],'tag','plotData');
            hGUI.createPlot(plotData);
            hGUI.labelx(hGUI.gObj.plotData,'Time (ms)');
            hGUI.labely(hGUI.gObj.plotData,'i (pA)');
            
            % Stimulus
            plotStim=struct('Position',[p.left p.third_top1 p.width p.third_height],'tag','plotStim');
            hGUI.createPlot(plotStim);
            hGUI.labelx(hGUI.gObj.plotStim,'Time (ms)');
            hGUI.labely(hGUI.gObj.plotStim,'Vm (mV)');
            
            % Leak subtracted data
            plotLeak=struct('Position',[p.left p.third_top3 p.width p.third_height],'tag','plotLeak');
            hGUI.createPlot(plotLeak);
            hGUI.labelx(hGUI.gObj.plotLeak,'Time (ms)');
            hGUI.labely(hGUI.gObj.plotLeak,'i (pA)');
            
            
            % Peak data
            plotPeak=struct('Position',[p.left2 p.half_top1 p.half_width p.half_height],'tag','plotPeak');
            hGUI.createPlot(plotPeak);
            hGUI.labelx(hGUI.gObj.plotPeak,'Time (ms)');
            hGUI.labely(hGUI.gObj.plotPeak,'i (pA)');
            
            % Steady data
            plotSteady=struct('Position',[p.left3 p.half_top1 p.half_width p.half_height],'tag','plotSteady');
            hGUI.createPlot(plotSteady);
            hGUI.labelx(hGUI.gObj.plotSteady,'Time (ms)');
            hGUI.labely(hGUI.gObj.plotSteady,'i (pA)');
            
            %IV curve
            plotIV=struct('Position',[p.left2 p.half_top2 p.width p.half_height],'tag','plotIV');
            hGUI.createPlot(plotIV);
            hGUI.labelx(hGUI.gObj.plotIV,'Vm (mV)');
            hGUI.labely(hGUI.gObj.plotIV,'i (pA)');
            
            hGUI.results.tAx = hGUI.node.children(1).custom.get('results').get('tAxis')';
            hGUI.results.Data = NaN(nV,size(hGUI.results.tAx,2));
            hGUI.results.Stim = NaN(nV,size(hGUI.results.tAx,2));
            hGUI.results.leakData = NaN(nV,size(hGUI.results.tAx,2));
            hGUI.results.subData = NaN(nV,size(hGUI.results.tAx,2));
            hGUI.results.pulseV = NaN(nV,1);
            
            
            % data plotting
            % get pulse Amplitude/Strength/Mean
            sampleEpoch = node.epochList.firstValue;
            pulseMean = sampleEpoch.stimuli(getStimStreamName(node.epochList.firstValue)).parameters('mean');
            pts = struct('pre',[],'stim',[],'tail',[]);
            pts.pre = sampleEpoch.protocolSettings.get('preTime')/getSamplingInterval(sampleEpoch)/1e3;
            pts.stim = sampleEpoch.protocolSettings.get('stimTime')/getSamplingInterval(sampleEpoch)/1e3;
            pts.tail = sampleEpoch.protocolSettings.get('tailTime')/getSamplingInterval(sampleEpoch)/1e3;
            pts.peakLowLim = pts.pre + .0008/getSamplingInterval(sampleEpoch);
            pts.peakHiLimNeg = pts.pre + .002/getSamplingInterval(sampleEpoch);
            pts.peakHiLimPos = pts.pre + .006/getSamplingInterval(sampleEpoch);
            pts.steadyLowLim = pts.pre + pts.stim - .01/getSamplingInterval(sampleEpoch);
            pts.steadyHiLim = pts.pre + pts.stim;
             
            % get rest of the data
            for i = 1:nV
                hGUI.results.Data(i,:) = hGUI.node.children(i).custom.get('results').get('Mean')';
                hGUI.results.Stim(i,:) = hGUI.node.children(i).custom.get('results').get('Stim')';
                hGUI.results.pulseV(i) = hGUI.node.children(i).splitValue;
                hGUI.results.pulseAmp(i) = hGUI.results.pulseV(i) - pulseMean;
            end
            % do the leak subtraction
            [hGUI.results.leakData, hGUI.results.subData] = hGUI.leakSubtract(hGUI.results.Data,hGUI.results.pulseAmp');
            % get the relevant current values
            [hGUI.results.iPeak, hGUI.results.iPeak_i, hGUI.results.iSteady, hGUI.results.iSteady_i] = hGUI.measureCurrent(hGUI.results.subData, pts, hGUI.results.pulseV);
            
            %set plot limits
            hGUI.gObj.plotData.XLim=[min(hGUI.results.tAx) max(hGUI.results.tAx)];
            hGUI.gObj.plotStim.XLim=[min(hGUI.results.tAx) max(hGUI.results.tAx)];
            hGUI.gObj.plotLeak.XLim=[min(hGUI.results.tAx) max(hGUI.results.tAx)];
            
            hGUI.gObj.plotPeak.XLim=[sampleEpoch.protocolSettings.get('preTime')/1e3 sampleEpoch.protocolSettings.get('preTime')/1e3+.01];
            hGUI.gObj.plotSteady.XLim=[(sampleEpoch.protocolSettings.get('preTime')+sampleEpoch.protocolSettings.get('stimTime'))/1e3-.025 (sampleEpoch.protocolSettings.get('preTime')+sampleEpoch.protocolSettings.get('stimTime'))/1e3+.025];
            
            hGUI.gObj.plotPeak.YLim=[min(min(hGUI.results.subData)) max(max(hGUI.results.subData))];
            hGUI.gObj.plotSteady.YLim=[min(min(hGUI.results.subData)) max(max(hGUI.results.subData))];
                     
            % IV curve
            lH=line(hGUI.results.pulseV,hGUI.results.iPeak,'Parent',hGUI.gObj.plotIV);
            set(lH,'LineStyle','--','Marker','none','LineWidth',1,'Color',[.5 .5 .5])
            set(lH,'DisplayName',sprintf('IV_peak'))

            lH=line(hGUI.results.pulseV,hGUI.results.iSteady,'Parent',hGUI.gObj.plotIV);
            set(lH,'LineStyle',':','Marker','none','LineWidth',1,'Color',[.5 .5 .5])
            set(lH,'DisplayName',sprintf('IV_steadystate'))
                
                
            for i = 1:nV
                % Averages
                lH=line(hGUI.results.tAx,hGUI.results.Data(i,:),'Parent',hGUI.gObj.plotData);
                set(lH,'LineStyle','-','Marker','none','LineWidth',2,'MarkerSize',5,'Color',colors(i,:))
                set(lH,'DisplayName',sprintf('d%g',hGUI.results.pulseV(i)))
                
                % Stimulus
                lH=line(hGUI.results.tAx,hGUI.results.Stim(i,:),'Parent',hGUI.gObj.plotStim);
                set(lH,'LineStyle','-','Marker','none','LineWidth',2,'MarkerSize',5,'Color',colors(i,:))
                set(lH,'DisplayName',sprintf('s%g',hGUI.results.pulseV(i)))
                
                % Leak prediction
                lH=line(hGUI.results.tAx,hGUI.results.leakData(i,:),'Parent',hGUI.gObj.plotData);
                set(lH,'LineStyle','-','Marker','none','LineWidth',1,'MarkerSize',5,'Color',wcolors(i,:))
                set(lH,'DisplayName',sprintf('lp%g',hGUI.results.pulseV(i)))
                
                % leak-subtracted Data
                lH=line(hGUI.results.tAx,hGUI.results.subData(i,:),'Parent',hGUI.gObj.plotLeak);
                set(lH,'LineStyle','-','Marker','none','LineWidth',2,'MarkerSize',5,'Color',colors(i,:))
                set(lH,'DisplayName',sprintf('sub%g',hGUI.results.pulseV(i)))
                
                lH=line(hGUI.results.tAx,hGUI.results.subData(i,:),'Parent',hGUI.gObj.plotPeak);
                set(lH,'LineStyle','-','Marker','none','LineWidth',2,'MarkerSize',5,'Color',colors(i,:))
                set(lH,'DisplayName',sprintf('sub%g',hGUI.results.pulseV(i)))
                
                lH=line(hGUI.results.tAx,hGUI.results.subData(i,:),'Parent',hGUI.gObj.plotSteady);
                set(lH,'LineStyle','-','Marker','none','LineWidth',2,'MarkerSize',5,'Color',colors(i,:))
                set(lH,'DisplayName',sprintf('sub%g',hGUI.results.pulseV(i)))
                
                %overlay of IV data
                lH=line(hGUI.results.tAx(hGUI.results.iPeak_i(i)),hGUI.results.iPeak(i),'Parent',hGUI.gObj.plotPeak);
                set(lH,'LineStyle','none','Marker','^','LineWidth',1,'MarkerSize',8,'Color',[.5 .5 .5],'MarkerFaceColor',colors(i,:))
                set(lH,'DisplayName',sprintf('Peak%g',hGUI.results.pulseV(i)))
                
                lH=line(hGUI.results.tAx(hGUI.results.iSteady_i),hGUI.results.iSteady(i),'Parent',hGUI.gObj.plotSteady);
                set(lH,'LineStyle','none','Marker','o','LineWidth',1,'MarkerSize',8,'Color',[0 0 0],'MarkerFaceColor',colors(i,:))
                set(lH,'DisplayName',sprintf('Steady%g',hGUI.results.pulseV(i)))
                
                
                % IV curve
                lH=line(hGUI.results.pulseV(i),hGUI.results.iPeak(i),'Parent',hGUI.gObj.plotIV);
                set(lH,'LineStyle','none','Marker','^','LineWidth',1,'MarkerSize',8,'Color',[.5 .5 .5],'MarkerFaceColor',colors(i,:))
                set(lH,'DisplayName',sprintf('Peak%g',hGUI.results.pulseV(i)))
                
                lH=line(hGUI.results.pulseV(i),hGUI.results.iSteady(i),'Parent',hGUI.gObj.plotIV);
                set(lH,'LineStyle','none','Marker','o','LineWidth',1,'MarkerSize',8,'Color',[.5 .5 .5],'MarkerFaceColor',colors(i,:))
                set(lH,'DisplayName',sprintf('Steady%g',hGUI.results.pulseV(i)))
            end
            
            hGUI.updatePlots;
        end
        
        function updatePlots(hGUI,~,~)
            
            infoData = hGUI.gObj.infoTable.Data;
            Selected = infoData(:,1);
            leakSelected = infoData (:,2);
            nV=hGUI.node.children.length;
            
            for i = 1:nV
                dName = sprintf('d%g',hGUI.results.pulseV(i));
                sName = sprintf('s%g',hGUI.results.pulseV(i));
                lpName = sprintf('lp%g',hGUI.results.pulseV(i));
                subName = sprintf('sub%g',hGUI.results.pulseV(i));
                if Selected(i)
                    hGUI.showTrace(dName);
                    hGUI.showTrace(sName);
                    hGUI.showTrace(lpName);
                    hGUI.showTrace(subName);
                else
                    hGUI.hideTrace(dName);
                    hGUI.hideTrace(sName);
                    hGUI.hideTrace(lpName);
                    hGUI.hideTrace(subName);
                end
                if leakSelected(i)
                    hGUI.showTrace(lpName);
                else
                    hGUI.hideTrace(lpName);
                end
            end
            
        end
        
        
       
        
       
    end
    
    methods (Static=true)
        
        function [leakData, subData] = leakSubtract(Data,vPulse)
            i_leakpos = (vPulse==5);
            i_leakneg = (vPulse==-5);
            
            leakBase = mean([Data(i_leakpos,:);-Data(i_leakneg,:)],1)./5; %per mV of stimulus
%             leakBase = mean([Data(i_leakpos,:)],1)./5; %per mV of stimulus
            leakBase = repmat(leakBase,size(Data,1),1);
            leakData = leakBase .* repmat(vPulse,1,size(Data,2));
            
            subData = Data - leakData;
        end
        
        function cellInfo = getcellinfo(node)
            cellInfo=cell(4,1);
            pSet=node.epochList.firstValue.protocolSettings;
            cellType=pSet.get('source:type');
            cellInfo{1}=datestr(pSet.get('source:parent:time'),'yyyy_mm_dd');
            cellInfo{2}=pSet.get('source:label');
            cellInfo{3}=cellType(1:regexp(cellType,'\')-1);
            cellInfo{4}=cellType(regexp(cellType,'\')+1:end);
            cellInfo{5}=pSet.get('epochGroup:pipetteSolution');
            
        end
        
        function [iPeak, iPeak_i, iSteady, iSteady_i] = measureCurrent(subData, pts, pulseV)
            nV=length(pulseV);
            iPeak = NaN(1,nV);
            iPeak_i = NaN(1,nV);
            iSteady = NaN(1,nV);
            
            iSteady_i =mean(pts.steadyLowLim:pts.steadyHiLim);
            
            for i=1:length(pulseV)
                if pulseV(i) < -60
                    iPeak(i) = min(subData(i,pts.peakLowLim:pts.peakHiLimNeg));
                    iPeak_i(i) = find(subData(i,pts.peakLowLim:pts.peakHiLimNeg)==iPeak(i),1)+pts.peakLowLim-1;
                else
                    iPeak(i) = min(subData(i,pts.peakLowLim:pts.peakHiLimPos));
                    iPeak_i(i) = find(subData(i,pts.peakLowLim:pts.peakHiLimPos)==iPeak(i),1)+pts.peakLowLim-1;
                end
                iSteady(i) =mean(subData(i,pts.steadyLowLim:pts.steadyHiLim));
            end
            
        end
        
        function hideTrace(traceName)
            set(findobj('DisplayName',traceName),'Visible','off')
        end
        
        function showTrace(traceName)
            set(findobj('DisplayName',traceName),'Visible','on')
        end
    end
end
