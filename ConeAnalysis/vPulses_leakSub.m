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
            
            tableinput=struct;
            tableinput.tag='infoTable';
            tableinput.Position=[.01, .01, .105, .65];
            tableinput.FontSize=10;
            tableinput.ColumnWidth={60};
            tableinput.Data=true(nV,1);
            tableinput.ColumnName={'Vmemb'};
            tableinput.RowName=RowNames;
            tableinput.headerWidth=42;
            tableinput.CellEditCallback=@hGUI.updatePlots;
            hGUI.createTable(tableinput);
            
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
            
            hGUI.results.tAx = hGUI.node.children(1).custom.get('results').get('tAxis')';
            hGUI.results.Data = NaN(nV,size(hGUI.results.tAx,2));
            hGUI.results.Stim = NaN(nV,size(hGUI.results.tAx,2));
            hGUI.results.leakData = NaN(nV,size(hGUI.results.tAx,2));
            hGUI.results.subData = NaN(nV,size(hGUI.results.tAx,2));
            hGUI.results.pulseV = NaN(nV,1);
            
            hGUI.figData.plotData.XLim=[min(hGUI.results.tAx) max(hGUI.results.tAx)];
            hGUI.figData.plotStim.XLim=[min(hGUI.results.tAx) max(hGUI.results.tAx)];
            hGUI.figData.plotLeak.XLim=[min(hGUI.results.tAx) max(hGUI.results.tAx)];
            
%             hGUI.figData.plotData.XLim=[min(hGUI.results.tAx) 1];
%             hGUI.figData.plotStim.XLim=[min(hGUI.results.tAx) 1];
%             hGUI.figData.plotLeak.XLim=[min(hGUI.results.tAx) 1];
            
            
            % data plotting
            for i = 1:nV
                hGUI.results.Data(i,:) = hGUI.node.children(i).custom.get('results').get('Mean')';
                hGUI.results.Stim(i,:) = hGUI.node.children(i).custom.get('results').get('Stim')';
                hGUI.results.pulseV(i) = hGUI.node.children(i).splitValue;
            end
            [hGUI.results.leakData, hGUI.results.subData] = hGUI.leakSubtract(hGUI.results.Data,hGUI.results.pulseV);
            
            
            for i = 1:nV
                    % Averages
                    lH=line(hGUI.results.tAx,hGUI.results.Data(i,:),'Parent',hGUI.figData.plotData);
                    set(lH,'LineStyle','-','Marker','none','LineWidth',2,'MarkerSize',5,'Color',colors(i,:))
                    set(lH,'DisplayName',sprintf('d%g',hGUI.results.pulseV(i)))
                    
                    % Stimulus
                    lH=line(hGUI.results.tAx,hGUI.results.Stim(i,:),'Parent',hGUI.figData.plotStim);
                    set(lH,'LineStyle','-','Marker','none','LineWidth',2,'MarkerSize',5,'Color',colors(i,:))
                    set(lH,'DisplayName',sprintf('s%g',hGUI.results.pulseV(i)))
                    
                    % leak-subtracted Data
                    lH=line(hGUI.results.tAx,hGUI.results.subData(i,:),'Parent',hGUI.figData.plotLeak);
                    set(lH,'LineStyle','-','Marker','none','LineWidth',2,'MarkerSize',5,'Color',colors(i,:))
                    set(lH,'DisplayName',sprintf('sub%g',hGUI.results.pulseV(i)))
            end
        end
        
        function updatePlots(hGUI,~,~)
            
            Selected = hGUI.figData.infoTable.Data;
            nV=hGUI.node.children.length;
            
            for i = 1:nV
                dName = sprintf('d%g',hGUI.results.pulseV(i));
                sName = sprintf('s%g',hGUI.results.pulseV(i));
                subName = sprintf('sub%g',hGUI.results.pulseV(i));
                if Selected(i)
                    hGUI.showTrace(dName);
                    hGUI.showTrace(sName);
                    hGUI.showTrace(subName);
                else
                    hGUI.hideTrace(dName);
                    hGUI.hideTrace(sName);
                    hGUI.hideTrace(subName);
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
        
        function hideTrace(traceName)
            set(findobj('DisplayName',traceName),'Visible','off')
        end
        
        function showTrace(traceName)
            set(findobj('DisplayName',traceName),'Visible','on')
        end
    end
end
