classdef vPulses_leakSubFilter < ephysGUI & linfiltFX
    % plots saved averages for all leaves underneath node?
    properties
        node
        results
    end
    
    methods
        % Constructor (gui objects and initial plotting)
        function hGUI=vPulses_leakSubFilter(node,params,fign)
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
            p.left=.180;
            p.width=.35;
            p.height=.43;
            p.top=.555;
            p.top2=.08;
            
            % Data
            plotData=struct('Position',[p.left p.top p.width p.height],'tag','plotData');
            hGUI.createPlot(plotData);
            hGUI.labelx(hGUI.gObj.plotData,'Time (ms)');
            hGUI.labely(hGUI.gObj.plotData,'i (pA)');
            
            % Stimulus
            plotStim=struct('Position',[p.left p.top2 p.width p.height],'tag','plotStim');
            hGUI.createPlot(plotStim);
            hGUI.labelx(hGUI.gObj.plotStim,'Time (ms)');
            hGUI.labely(hGUI.gObj.plotStim,'Vm (mV)');
            
            p.lleft = p.left+p.width+.05;
            p.lwidth = 1 - p.lleft-.025;
            p.lheight = .9;
            % Leak subtracted data
            plotLeak=struct('Position',[p.lleft p.top2 p.lwidth p.lheight],'tag','plotLeak');
            hGUI.createPlot(plotLeak);
            hGUI.labelx(hGUI.gObj.plotLeak,'Time (ms)');
            hGUI.labely(hGUI.gObj.plotLeak,'i (pA)');
            
            hGUI.results.tAx = hGUI.node.children(1).custom.get('results').get('tAxis')';
            hGUI.results.Data = NaN(nV,size(hGUI.results.tAx,2));
            hGUI.results.Stim = NaN(nV,size(hGUI.results.tAx,2));
            hGUI.results.leakData = NaN(nV,size(hGUI.results.tAx,2));
            hGUI.results.subData = NaN(nV,size(hGUI.results.tAx,2));
            hGUI.results.pulseV = NaN(nV,1);
            
%             hGUI.gObj.plotData.XLim=[min(hGUI.results.tAx) max(hGUI.results.tAx)];
%             hGUI.gObj.plotStim.XLim=[min(hGUI.results.tAx) max(hGUI.results.tAx)];
%             hGUI.gObj.plotLeak.XLim=[min(hGUI.results.tAx) max(hGUI.results.tAx)];
%             
            hGUI.gObj.plotData.XLim=[min(hGUI.results.tAx) 1.2];
            hGUI.gObj.plotStim.XLim=[min(hGUI.results.tAx) 1.2];
            hGUI.gObj.plotLeak.XLim=[min(hGUI.results.tAx) 1.2];
            
            
            % data plotting
            pulseMean = node.epochList.firstValue.stimuli(getStimStreamName(node.epochList.firstValue)).parameters('mean');
            for i = 1:nV
                hGUI.results.Data(i,:) = hGUI.node.children(i).custom.get('results').get('Mean')';
                hGUI.results.Stim(i,:) = hGUI.node.children(i).custom.get('results').get('Stim')';
                hGUI.results.pulseV(i) = hGUI.node.children(i).splitValue;
                hGUI.results.pulseAmp(i) = hGUI.results.pulseV(i) - pulseMean;
            end
            [hGUI.results.leakData, hGUI.results.subData] = hGUI.leakSubtract(hGUI.results.Data,hGUI.results.pulseAmp');
            
            
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

