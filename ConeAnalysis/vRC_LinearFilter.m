classdef vRC_LinearFilter < ephysGUI
    % plots saved averages for all leaves underneath node?
    properties
        node
        results
    end
    
    methods
        % Constructor (gui objects and initial plotting)
        function hGUI=vRC_LinearFilter(node,params,fign)
            params=checkStructField(params,'PlotNow',1);
            params=checkStructField(params,'lfpts',30);
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

            % plot creation
            p=struct;
            p.left=.180;
            p.width=.35;
            p.height=.43;
            p.top=.555;
            p.top2=.08;
            
            % Data
            plotData=struct('Position',[p.left p.top p.width p.height],'tag','plotData');
            hGUI.createPlot(plotData);
            hGUI.labelx(hGUI.figData.plotData,'Time (ms)');
            hGUI.labely(hGUI.figData.plotData,'i (pA)');
            
            % Stimulus
            plotStim=struct('Position',[p.left p.top2 p.width p.height],'tag','plotStim');
            hGUI.createPlot(plotStim);
            hGUI.labelx(hGUI.figData.plotStim,'Time (ms)');
            hGUI.labely(hGUI.figData.plotStim,'Vm (mV)');
            
            p.lleft = p.left+p.width+.05;
            p.lwidth = 1 - p.lleft-.025;
            p.lheight = .9;
            
            % Leak subtracted data
            plotLeak=struct('Position',[p.lleft p.top2 p.lwidth p.lheight],'tag','plotLeak');
            hGUI.createPlot(plotLeak);
            hGUI.labelx(hGUI.figData.plotLeak,'Time (ms)');
            hGUI.labely(hGUI.figData.plotLeak,'i (pA)');
            
            nT=size(hGUI.results.Data(1,:);
            hGUI.results.Data = riekesuite.getResponseMatrix(node.epochList,getStimStreamName(node));
            hGUI.results.tAxis=(0:size(hGUI.results.Data(1,:),2)-1)*getSamplingInterval(node);
            hGUI.results.Stim=getStimulusVector(node.epochList.firstValue,getStimStreamName(node));
            hGUI.results.Selected = NaN(nT,1);
            hGUI.results.rcFilter = NaN(1,params.lfpts);
            
            hGUI.figData.plotData.XLim=[min(hGUI.results.tAx) max(hGUI.results.tAx)];
            hGUI.figData.plotStim.XLim=[min(hGUI.results.tAx) max(hGUI.results.tAx)];
            hGUI.figData.plotLeak.XLim=[min(hGUI.results.tAx) max(hGUI.results.tAx)];
            
%             hGUI.figData.plotData.XLim=[min(hGUI.results.tAx) 1.2];
%             hGUI.figData.plotStim.XLim=[min(hGUI.results.tAx) 1.2];
%             hGUI.figData.plotLeak.XLim=[min(hGUI.results.tAx) 1.2];
            
            
            % data plotting
            for i = 1:nV
                % Raw Data
                lH=line(hGUI.results.tAx,hGUI.results.Data(i,:),'Parent',hGUI.figData.plotData);
                set(lH,'LineStyle','-','Marker','none','LineWidth',2,'MarkerSize',5,'Color',colors(i,:))
                set(lH,'DisplayName',sprintf('d%g',hGUI.results.pulseV(i)))
                
                % Noise Stimulus
                lH=line(hGUI.results.tAx,hGUI.results.Stim(i,:),'Parent',hGUI.figData.plotStim);
                set(lH,'LineStyle','-','Marker','none','LineWidth',2,'MarkerSize',5,'Color',colors(i,:))
                set(lH,'DisplayName',sprintf('s%g',hGUI.results.pulseV(i)))
                
                % Leak prediction
                lH=line(hGUI.results.tAx,hGUI.results.leakData(i,:),'Parent',hGUI.figData.plotData);
                set(lH,'LineStyle','-','Marker','none','LineWidth',1,'MarkerSize',5,'Color',wcolors(i,:))
                set(lH,'DisplayName',sprintf('lp%g',hGUI.results.pulseV(i)))
                
                % leak-subtracted Data
                lH=line(hGUI.results.tAx,hGUI.results.subData(i,:),'Parent',hGUI.figData.plotLeak);
                set(lH,'LineStyle','-','Marker','none','LineWidth',2,'MarkerSize',5,'Color',colors(i,:))
                set(lH,'DisplayName',sprintf('sub%g',hGUI.results.pulseV(i)))
            end
            
%             hGUI.updatePlots;
        end
        
        function updatePlots(hGUI,~,~)
            
            infoData = hGUI.figData.infoTable.Data;
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
        
        function hideTrace(traceName)
            set(findobj('DisplayName',traceName),'Visible','off')
        end
        
        function showTrace(traceName)
            set(findobj('DisplayName',traceName),'Visible','on')
        end
    end
end
