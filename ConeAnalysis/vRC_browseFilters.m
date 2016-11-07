classdef vRC_browseFilters < ephysGUI & linfiltFX
    % plots saved averages for all leaves underneath node?
    properties
        node
        results
    end
    
    methods
        % Constructor (gui objects and initial plotting)
        function hGUI=vRC_browseFilters(node,params,fign)
            params=checkStructField(params,'PlotNow',1);
            params=checkStructField(params,'lftime',5); %in ms
            hGUI@ephysGUI(fign);
            hGUI.node = node;
            
            stimName = char(getStimStreamName(node));
            hGUI.results.Data = riekesuite.getResponseMatrix(node.epochList,stimName);
            nT=size(hGUI.results.Data,1);
            hGUI.results.tAx=(0:size(hGUI.results.Data(1,:),2)-1)*getSamplingInterval(node);
            hGUI.results.Stim=riekesuite.getStimulusMatrix(node.epochList,stimName);
            hGUI.results.Selected = NaN(nT,1);
            hGUI.results.rcFilter = hGUI.getLinearFilter(hGUI.node,params.lftime);
            hGUI.results.rctAx = (0:size(hGUI.results.rcFilter(1,:),2)-1)*getSamplingInterval(node);
            hGUI.results.modelData = NaN(size(hGUI.results.Data));
            for i=1:nT
                hGUI.results.modelData(i,:) = hGUI.getLinearEstimation(...
                    hGUI.results.Stim(i,:),...
                    hGUI.results.rcFilter(i,:),...
                    getProtocolSetting(hGUI.node,'prepts'),...
                    getSamplingInterval(node));
                hGUI.results.modelData(i,:) = hGUI.results.modelData(i,:) + mean(hGUI.results.Data(i,1:getProtocolSetting(hGUI.node,'prepts')));
            end
            
            colors=pmkmp(nT,'CubicL');
            wcolors=whithen(colors,.5);
            tcolors=round(colors./1.2.*255);
            
            RowNames=cell(size(nT));
            for i=1:nT
                RowNames{i}=sprintf('<html><font color=rgb(%d,%d,%d)>Ep%g</font></html>',tcolors(i,1),tcolors(i,2),tcolors(i,3),i);
            end
            
            tIn=struct;
            tIn.tag='infoTable';
            tIn.Position=[.01, .01, .12, .65];
            tIn.FontSize=10;
            tIn.ColumnWidth={50};
            tIn.Data=[true(nT,1) true(nT,1)];
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
            
            % rcFilters
            plotFilter=struct('Position',[p.lleft p.top2 p.lwidth p.lheight],'tag','plotFilter');
            hGUI.createPlot(plotFilter);
            hGUI.labelx(hGUI.gObj.plotFilter,'Time (ms)');
            hGUI.labely(hGUI.gObj.plotFilter,'i (pA)');
            
            hGUI.gObj.plotData.XLim=[min(hGUI.results.tAx) max(hGUI.results.tAx)];
            hGUI.gObj.plotStim.XLim=[min(hGUI.results.tAx) max(hGUI.results.tAx)];
            
%             pret=getProtocolSetting(hGUI.node,'prepts')*getSamplingInterval(hGUI.node);
%             hGUI.gObj.plotData.XLim=[pret-.001 pret+.015];
%             hGUI.gObj.plotStim.XLim=[pret-.001 pret+.015];

            hGUI.gObj.plotLeak.XLim=[min(hGUI.results.rctAx) max(hGUI.results.rctAx)];
            
            % data plotting
            for i = 1:nT
                % Raw Data
                lH=line(hGUI.results.tAx,hGUI.results.Data(i,:),'Parent',hGUI.gObj.plotData);
                set(lH,'LineStyle','-','Marker','none','LineWidth',2,'MarkerSize',5,'Color',colors(i,:))
                set(lH,'DisplayName',sprintf('data%g',i))
                
                % Noise Stimulus
                lH=line(hGUI.results.tAx,hGUI.results.Stim(i,:),'Parent',hGUI.gObj.plotStim);
                set(lH,'LineStyle','-','Marker','none','LineWidth',2,'MarkerSize',5,'Color',colors(i,:))
                set(lH,'DisplayName',sprintf('stim%g',i))
                
                % rc Filters
                lH=line(hGUI.results.rctAx,hGUI.results.rcFilter(i,:),'Parent',hGUI.gObj.plotFilter);
                set(lH,'LineStyle','-','Marker','o','LineWidth',2,'MarkerSize',5,'Color',colors(i,:))
                set(lH,'DisplayName',sprintf('filter%g',i))
                
                % Model Data
                lH=line(hGUI.results.tAx,hGUI.results.modelData(i,:),'Parent',hGUI.gObj.plotData);
                set(lH,'LineStyle','-','Marker','none','LineWidth',1,'MarkerSize',5,'Color',wcolors(i,:))
                set(lH,'DisplayName',sprintf('modelData%g',i))
            end
            
%             hGUI.updatePlots;
        end
        
        function updatePlots(hGUI,~,~)
            
            infoData = hGUI.gObj.infoTable.Data;
            Selected = infoData(:,1);
            leakSelected = infoData (:,2);
            nV=hGUI.node.epochList.length;
            
            for i = 1:nV
                dName = sprintf('data%g',i);
                sName = sprintf('stim%g',i);
                fName = sprintf('filter%g',i);
                mdName = sprintf('modelData%g',i);
                if Selected(i)
                    hGUI.showTrace(dName);
                    hGUI.showTrace(sName);
                    hGUI.showTrace(fName);
                    hGUI.showTrace(mdName);
                else
                    hGUI.hideTrace(dName);
                    hGUI.hideTrace(sName);
                    hGUI.hideTrace(fName);
                    hGUI.hideTrace(mdName);
                end
                if leakSelected(i)
                    hGUI.showTrace(fName);
                else
                    hGUI.hideTrace(fName);
                end
            end
            
        end
        
%         function lf = getRCFilter(hGUI, lftime)
%             prepts=getProtocolSetting(hGUI.node,'prepts');
%             stmpts=getProtocolSetting(hGUI.node,'stmpts');
%             freqcut=hGUI.node.epochList.elements(1).protocolSettings('stimuli:Amp1:freqCutoff');
%             samplingInterval=getSamplingInterval(hGUI.node);
%             lfpts = round(lftime * 1e-3 / samplingInterval);
%             
%             tempLF = NaN(size(hGUI.results.Data,1),stmpts+1);
%             lf = NaN(size(hGUI.results.Data,1),lfpts);
%             for i = 1:size(hGUI.results.Data,1)
%                 tempLF(i,:) = hGUI.LinearFilterFinder(...
%                     hGUI.results.Stim(i,prepts:prepts+stmpts),...
%                     hGUI.results.Data(i,prepts:prepts+stmpts),...
%                     1/samplingInterval,...
%                     freqcut*1.0);
%                 lf(i,:) = tempLF(i,1:lfpts);
%             end
%         end
       
    end
    
    methods (Static=true)
        
%         function LinearFilter=LinearFilterFinder(signal,response, samplerate, freqcutoff)
%             FilterFft = mean((fft(response,[],2).*1/samplerate.*conj(fft(signal,[],2).*1/samplerate)),1)./...
%                 mean(fft(signal,[],2).*1/samplerate.*conj(fft(signal,[],2).*1/samplerate),1);
%             freqcutoff_adjusted = round(freqcutoff/(samplerate/length(signal))); % this adjusts the freq cutoff for the length
%             FilterFft(:,1+freqcutoff_adjusted:length(signal)-freqcutoff_adjusted) = 0 ;
%             LinearFilter = real(ifft(FilterFft).*samplerate) ;
%         end
        
        
        function cellInfo = getcellinfo(node)
            cellInfo=cell(4,1);
            pSet=node.epochList.firstValue.protocolSettings;
            cellType=pSet.get('source:type');
            cellInfo{1}=datestr(pSet.get('source:parent:time'),'yyyy_mm_dd');
            cellInfo{2}=pSet.get('source:label');
%             cellInfo{3}=cellType(1:regexp(cellType,'\')-1);
%             cellInfo{4}=cellType(regexp(cellType,'\')+1:end);
%             cellInfo{5}=pSet.get('epochGroup:pipetteSolution');
            
        end
        
        function hideTrace(traceName)
            set(findobj('DisplayName',traceName),'Visible','off')
        end
        
        function showTrace(traceName)
            set(findobj('DisplayName',traceName),'Visible','on')
        end
    end
end
