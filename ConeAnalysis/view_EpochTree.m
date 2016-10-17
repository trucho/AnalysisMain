classdef view_EpochTree < ephysGUI
    % plots saved averages for all leaves underneath node?
    properties
        node
        results
    end
    
    methods
        % Constructor (gui objects and initial plotting)
        function hGUI=view_EpochTree(node,params,fign)
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

            % plots
            pleft=.180;
            pwidth=.45;
            pheight=.43;
            ptop=.555;
            ptop2=.08;
            

            plotData=struct('Position',[pleft ptop pwidth pheight],'tag','plotData');
            hGUI.createPlot(plotData);
            hGUI.labelx(hGUI.figData.plotData,'Time (ms)');
            hGUI.labely(hGUI.figData.plotData,'i (pA)');
            

            plotStim=struct('Position',[pleft ptop2 pwidth pheight],'tag','plotStim');
            hGUI.createPlot(plotStim);
            hGUI.labelx(hGUI.figData.plotStim,'Time (ms)');
            hGUI.labely(hGUI.figData.plotStim,'i (pA)');
            
            hGUI.results.tAx = hGUI.node.children(1).custom.get('results').get('tAxis')';
            hGUI.results.Data = NaN(nV,size(hGUI.results.tAx,2));
            hGUI.results.Stim = NaN(nV,size(hGUI.results.tAx,2));
            hGUI.results.pulseV = NaN(nV,1);
            
            %             hGUI.figData.plotData.XLim=[min(tAx) max(tAx)];
            %             hGUI.figData.plotStim.XLim=[min(tAx) max(tAx)];
            
            hGUI.figData.plotData.XLim=[min(hGUI.results.tAx) 1];
            hGUI.figData.plotStim.XLim=[min(hGUI.results.tAx) 1];
            
            for i = 1:nV
                hGUI.results.Data(i,:) = hGUI.node.children(i).custom.get('results').get('Mean')';
                hGUI.results.Stim(i,:) = hGUI.node.children(i).custom.get('results').get('Stim')';
                hGUI.results.pulseV(i) = hGUI.node.children(i).splitValue;
            end
            
            for i = 1:nV
                    % Averages
                    lH=line(hGUI.results.tAx,hGUI.results.Data(i,:),'Parent',hGUI.figData.plotData);
                    set(lH,'LineStyle','-','Marker','none','LineWidth',2,'MarkerSize',5,'Color',colors(i,:))
                    set(lH,'DisplayName',sprintf('d%g',hGUI.results.pulseV(i)))
                    
                    % Stimulus
                    lH=line(hGUI.results.tAx,hGUI.results.Stim(i,:),'Parent',hGUI.figData.plotStim);
                    set(lH,'LineStyle','-','Marker','none','LineWidth',2,'MarkerSize',5,'Color',colors(i,:))
                    set(lH,'DisplayName',sprintf('s%g',hGUI.results.pulseV(i)))
            end
        end
        
        function updatePlots(hGUI,~,~)
            
            Selected = hGUI.figData.infoTable.Data;
            nV=hGUI.node.children.length;
            
            for i = 1:nV
                dName = sprintf('d%g',hGUI.results.pulseV(i));
                sName = sprintf('s%g',hGUI.results.pulseV(i));
                if Selected(i)
                    hGUI.showTrace(dName);
                    hGUI.showTrace(sName);
                else
                    hGUI.hideTrace(dName);
                    hGUI.hideTrace(sName);
                end
            end
            
        end
        
        
       
        
       
    end
    
    methods (Static=true)
        
        function hideTrace(traceName)
            set(findobj('DisplayName',traceName),'Visible','off')
        end
        
        function showTrace(traceName)
            set(findobj('DisplayName',traceName),'Visible','on')
        end
    end
end
