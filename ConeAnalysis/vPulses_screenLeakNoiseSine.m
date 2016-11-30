classdef vPulses_screenLeakNoiseSine < ephysGUI & linfiltFX
    % screen epochs from vProtocols and check leakSubtraction using noise + sine.
    % Will tag epochs with 'include' for further analysis and save
    % leakData and subData in node.custom('results').
    % Requires that node contains vPulseFamily underneath and sister branch
    % contains matching RCepochs
    properties
        node
        rcnode
        results = struct
        Selected
        lH = struct
    end
    
    properties (Hidden = true)
        colors
        wcolors
        tcolors
        mcolors
        mhcolors
        nV
    end
    
    methods
        % Constructor
        function hGUI=vPulses_screenLeakNoiseSine(node,params,fign)
            params=checkStructField(params,'PlotNow',1);
            params=checkStructField(params,'silent',0);
            params=checkStructField(params,'lftime',1); %in ms
            hGUI@ephysGUI(fign);
            hGUI.node = node;
            hGUI.rcnode = node.parent.childBySplitValue(true);
            
            hGUI.nV=node.children.length;
            hGUI.mcolors=pmkmp(hGUI.nV,'LinLhot');
            hGUI.mhcolors=round(hGUI.mcolors./1.2.*255);
            [hGUI.results.rcFilter, hGUI.results.lftAx,...
                hGUI.results.rcModel, hGUI.results.rctAx,...
                hGUI.results.rcData] = hGUI.getlfNoiseSine(hGUI.rcnode,params.lftime);
            hGUI.results.tAx = hGUI.getTimeAxis(node);
            
            if ~params.silent
               hGUI.layoutGUI(node); 
            end
        end
        
        function hGUI = layoutGUI(hGUI,node)
            
            vNames=cell(size(hGUI.nV));
            for i=1:hGUI.nV
                vNames{i}=sprintf('<html><font color=rgb(%d,%d,%d)>%g</font></html>',hGUI.mhcolors(i,1),hGUI.mhcolors(i,2),hGUI.mhcolors(i,3),round(node.children(i).splitValue));
            end
                     
%             % This could also be a nice cell selector if input was whole tree
%             % instead of node
%             ddinput=struct;
%             ddinput.Position=[0.01, .65, 0.105, .05];
%             ddinput.FontSize=14;
%             ddinput.String=RowNames;
%             ddinput.Callback=@hGUI.updateMenu;
%             hGUI.createDropdown(ddinput);

            ddinput=struct;
            ddinput.Position=[0.01, .65, 0.105, .05];
            ddinput.FontSize=14;
            ddinput.String=vNames;
            ddinput.Callback=@hGUI.updateMenu;
            hGUI.createDropdown(ddinput);
            
            tIn2=struct;
            tIn2.tag='cellinfo';
            tIn2.Position=[.005, .855, .135, .135];
            tIn2.FontSize=10;
            tIn2.ColumnWidth={80};
            tIn2.Data=hGUI.getcellinfo(node);
            tIn2.ColumnName={''};
            tIn2.RowName={'date','cellName','type','subtype','internal'};
            tIn2.headerWidth=62;
            tIn2.CellEditCallback=@hGUI.updatePlots;
            hGUI.createTable(tIn2);

            
            % buttons
            hGUI.nextButton;
            hGUI.prevButton;
            hGUI.lockButton;
            hGUI.acceptButton;

            % plot creation
            p=struct;
            p.left=.180;
            p.width=.35;
            p.height=.32;
            p.height2=.20;
            p.top=.66;
            p.top2=.32;
            p.top3=.08;
            
            % Data
            plotData=struct('Position',[p.left p.top p.width p.height],'tag','plotData');
            hGUI.createPlot(plotData);
            hGUI.labely(hGUI.gObj.plotData,'i (pA)');
            hGUI.gObj.plotData.XTick=[];
            
            % Leak Subtracted Data
            plotSub=struct('Position',[p.left p.top2 p.width p.height],'tag','plotSub');
            hGUI.createPlot(plotSub);
            hGUI.labely(hGUI.gObj.plotSub,'i (pA)');
            hGUI.gObj.plotSub.XTick=[];

            % Stimulus
            plotStim=struct('Position',[p.left p.top3 p.width p.height2],'tag','plotStim');
            hGUI.createPlot(plotStim);
            hGUI.labelx(hGUI.gObj.plotStim,'Time (s)');
            hGUI.labely(hGUI.gObj.plotStim,'Vm (mV)');
            
            p.lleft = p.left+p.width+.05;
            p.lwidth = 1 - p.lleft-.025;
            % plot Filters
            plotFilters=struct('Position',[p.lleft p.top3 p.lwidth p.height],'tag','plotFilters');
            hGUI.createPlot(plotFilters);
            hGUI.labelx(hGUI.gObj.plotFilters,'Time (ms)');
            hGUI.labely(hGUI.gObj.plotFilters,'R (pA/mV = 1/M\Omega)');
            hGUI.gObj.plotFilters.XLim=[min(hGUI.results.lftAx) max(hGUI.results.lftAx)]/1e-3;
                        
            % plot RCepoch linear estimation
            plotRC=struct('Position',[p.lleft p.top-p.height*5/8 p.lwidth p.height],'tag','plotRC');
            hGUI.createPlot(plotRC);
            hGUI.labelx(hGUI.gObj.plotRC,'Time');
            hGUI.labely(hGUI.gObj.plotRC,'i (pA)')
            
            tAx = hGUI.getTimeAxis(node);
            % Filters and RClinear estimation
            fcolors = pmkmp(size(hGUI.results.rcFilter,1),'LinLHotDark');
            wfcolors = whithen(fcolors,.5);
            
            
            for i = 2%:size(hGUI.results.rcFilter,1)
                hGUI.lH.rcFilters(i) = line(hGUI.results.lftAx/1e-3,hGUI.results.rcFilter(i,:),'Parent',hGUI.gObj.plotFilters);
                hGUI.linec(hGUI.lH.rcFilters(i),fcolors(i,:));
                
                rc.nst = 1000 - 100;
                rc.nend = rc.nst + 1200;%4100;
                rc.nd = rc.nend - rc.nst+1;
                rc.sst = 7000 - 100;
                rc.send = rc.sst + 20000;
                rc.sd = rc.send - rc.sst+1;
                % plot linear estimation and rcData for noise
%                 hGUI.lH.rcData(i) = line(hGUI.results.rctAx(1:rc.nd),hGUI.results.rcData(i,rc.nst:rc.nend),'Parent',hGUI.gObj.plotRC);
%                 hGUI.linec(hGUI.lH.rcData(i),fcolors(i,:));
%                 hGUI.lH.rcModel(i) = line(hGUI.results.rctAx(1:rc.nd),hGUI.results.rcModel(i,rc.nst:rc.nend),'Parent',hGUI.gObj.plotRC);
%                 hGUI.linec(hGUI.lH.rcModel(i),wfcolors(i,:));

                % plot linear estimation and rcData for sine
                hGUI.lH.rcData(i) = line(hGUI.results.rctAx(1:rc.sd),hGUI.results.rcData(i,rc.sst:rc.send),'Parent',hGUI.gObj.plotRC);
                hGUI.linec(hGUI.lH.rcData(i),fcolors(i,:));
                hGUI.lH.rcModel(i) = line(hGUI.results.rctAx(1:rc.sd),hGUI.results.rcModel(i,rc.sst:rc.send),'Parent',hGUI.gObj.plotRC);
                hGUI.linec(hGUI.lH.rcModel(i),wfcolors(i,:));
                
                % plot linear estimation vs rcData
%                 hGUI.lH.rcModeln(i) = line(hGUI.results.rcModel(i,rc.sst:rc.send),hGUI.results.rcData(i,rc.sst:rc.send),'Parent',hGUI.gObj.plotRC);
%                 hGUI.markerc(hGUI.lH.rcModeln(i),fcolors(i,:));
                
%                 hGUI.lH.rcModels(i) = line(hGUI.results.rcModel(i,rc.nst:rc.nend),hGUI.results.rcData(i,rc.nst:rc.nend),'Parent',hGUI.gObj.plotRC);
%                 hGUI.markerc(hGUI.lH.rcModels(i),wfcolors(i,:));
            end
            
%             hGUI.lH.unity = line([-max(abs(hGUI.results.rcData(i,:))) max(abs(hGUI.results.rcData(i,:)))],...
%                 [-max(abs(hGUI.results.rcData(i,:))) max(abs(hGUI.results.rcData(i,:)))],...
%                 'Parent',hGUI.gObj.plotRC);
%             hGUI.linec(hGUI.lH.unity,[1 0 0]);
            
            % Overview
            plotOV=struct('Position',[p.lleft p.top+p.height/2 p.lwidth p.height/2],'tag','plotOV');
            hGUI.createPlot(plotOV);
            hGUI.labelx(hGUI.gObj.plotOV,'\Deltat (s)');
            hGUI.labely(hGUI.gObj.plotOV,'bias (pA or mV)')
            
            hGUI.plotOverview(node.parent,hGUI.gObj.plotOV);
            
            blank = NaN(size(tAx));
            hGUI.lH.StimNow = line(tAx,blank,'Parent',hGUI.gObj.plotStim);
            hGUI.lH.Stim=gobjects(node.children.length);
            for i = 1:node.children.length
                Stim = riekesuite.getStimulusVector(node.children(i).epochList.elements(1),char(getStimStreamName(node)));
                hGUI.lH.Stim(i) = line(tAx,Stim,'Parent',hGUI.gObj.plotStim);
                hGUI.lH.Stim(i).Color = [.3 .3 .3];
            end
            
            hGUI.gObj.plotData.XLim=[min(tAx) max(tAx)];
            hGUI.gObj.plotSub.XLim=[min(tAx) max(tAx)];
            hGUI.gObj.plotStim.XLim=[min(tAx) max(tAx)];
            hGUI.updateMenu;
        end
        
        function updatePlots(hGUI,~,~)
            delete(hGUI.gObj.plotData.Children);
            delete(hGUI.gObj.plotSub.Children);
            delete(hGUI.gObj.plotOV.Children);
            hGUI.plotOverview(hGUI.node.parent,hGUI.gObj.plotOV);
            
            [vNow, vInd] = hGUI.getMenuValue(hGUI.gObj.DropDown);
            vNode = hGUI.node.childBySplitValue(str2double(vNow));
            nEp = vNode.epochList.length;
            exE = vNode.epochList.elements(1);
            Selected = hGUI.gObj.infoTable.Data;  %#ok<*PROPLC>
            
            hGUI.lH.StimNow.YData = riekesuite.getStimulusVector(exE,char(getStimStreamName(vNode)));
            hGUI.linec(hGUI.lH.StimNow,hGUI.mcolors(vInd,:));
            
            prepts=getProtocolSetting(vNode.epochList.firstValue,'prepts');
            tAx = hGUI.getTimeAxis(vNode);
            Data = riekesuite.getResponseMatrix(vNode.epochList,char(getStimStreamName(vNode)));

            epT=getstartTime(vNode);
            bias=mean(Data(:,1:prepts),2);
            biasSD=std(Data(:,1:prepts),0,2);
            
            Data = BaselineSubtraction(Data,1,prepts);
            hGUI.lH.Data=gobjects(nEp);
            hGUI.lH.subData=gobjects(nEp);
            hGUI.lH.leakData=gobjects(nEp);
            for i = 1:nEp
                if Selected(i)
                    hGUI.lH.Data(i) = line(tAx,Data(i,:),'Parent',hGUI.gObj.plotData);
                    hGUI.linec(hGUI.lH.Data(i),hGUI.colors(i,:));
                    
                    hGUI.lH.leakData(i) = line(tAx,hGUI.results.leakData(i,:),'Parent',hGUI.gObj.plotData);
                    hGUI.linec(hGUI.lH.leakData(i),hGUI.wcolors(i,:));
                    
                    hGUI.lH.subData(i) = line(tAx,hGUI.results.subData(i,:),'Parent',hGUI.gObj.plotSub);
                    hGUI.linec(hGUI.lH.subData(i),hGUI.colors(i,:));
                    
                    hGUI.lH.Bias(i) = line(epT(i),bias(i),'Parent',hGUI.gObj.plotOV);
                    hGUI.markerc(hGUI.lH.Bias(i),hGUI.colors(i,:));
                    
                    hGUI.lH.BiasSD(i) = line([epT(i) epT(i)],[bias(i)-biasSD(i) bias(i)+biasSD(i)],'Parent',hGUI.gObj.plotOV);
                    hGUI.linec(hGUI.lH.BiasSD(i),hGUI.colors(i,:));
                end
            end
            
            
        end
        
        function hGUI = updateMenu(hGUI,~,~)
            %re-create infoTable
            vNow = hGUI.getMenuValue(hGUI.gObj.DropDown);
            vNode = hGUI.node.childBySplitValue(str2double(vNow));
            nEp = vNode.epochList.length;
            
            hGUI.colors = pmkmp(nEp,'CubicL');
            hGUI.wcolors=whithen(hGUI.colors,.5);
            hGUI.tcolors=round(hGUI.colors./1.2.*255);
            
            rowNames=cell(size(nEp));
            hGUI.Selected = false(nEp,1);
            for i=1:nEp
                rowNames{i}=sprintf('<html><font color=rgb(%d,%d,%d)>Ep%g</font></html>',hGUI.tcolors(i,1),hGUI.tcolors(i,2),hGUI.tcolors(i,3),i);
                hGUI.Selected(i) = vNode.epochList.elements(i).keywords.contains('include');
            end
            
            tIn=struct;
            tIn.tag='infoTable';
            tIn.Position=[.005, .01, .12, .65];
            tIn.FontSize=10;
            tIn.ColumnWidth={50};
            tIn.Data=hGUI.Selected;
            tIn.ColumnName={'Sel'};
            tIn.RowName=rowNames;
            tIn.headerWidth=30;
            tIn.CellEditCallback=@hGUI.updatePlots;
            hGUI.createTable(tIn);
            
            hGUI.leakSubtract;
            hGUI.updatePlots;
        end
       
        function hGUI = leakSubtract(hGUI)
            vNow = hGUI.getMenuValue(hGUI.gObj.DropDown);
            vNode = hGUI.node.childBySplitValue(str2double(vNow));
            rcMatch = hGUI.getRCIndex(vNode);
            nEp = vNode.epochList.length;
            hGUI.results.leakData = NaN(nEp,size(hGUI.results.tAx,2));
            Stim = riekesuite.getStimulusVector(vNode.epochList.elements(1),char(getStimStreamName(vNode)));
            for i = 1:nEp
                hGUI.results.leakData(i,:) = hGUI.getLinearEstimation(Stim,...
                    hGUI.results.rcFilter(rcMatch(i),:),...
                    getProtocolSetting(vNode,'prepts'),...
                    getSamplingInterval(vNode));
            end
            
            Data = riekesuite.getResponseMatrix(vNode.epochList,char(getStimStreamName(vNode)));
            Data = BaselineSubtraction(Data,1,getProtocolSetting(vNode,'prepts'));
            hGUI.results.subData = Data - hGUI.results.leakData;
        end
        
    end
    
    methods (Static=true)
        
        function rcEpochIndex = getRCIndex(node)
            % assumes node contains identical vPulses, with parent of parent is a cell-node and that underneath epoch have
            % been split by RCepoch true vs. false
            if ~strcmpi(node.parent.parent.splitKey,'@(epoch)splitAutoRC(epoch)')
                error('node.parent.parent does not contain autoRC branch');
            end
            
            noderc = node.parent.parent.childBySplitValue(true); %autoRC branch
            for r = 1:noderc.epochList.length
                rctimest(r) = noderc.epochList.elements(r).protocolSettings('epochBlock:startTime'); %#ok<AGROW>
            end
            rcEpochIndex = NaN(node.epochList.length,1);
            for e = 1:node.epochList.length
                matches = false(noderc.epochList.length,1);
                timest = node.epochList.elements(e).protocolSettings('epochBlock:startTime');
                for r = 1:noderc.epochList.length
                    if (timest.compareTo(rctimest(r)))==0
                        matches(r) = true;
                    end
                end
                rcEpochIndex(e) = find(matches,1,'first');
            end
        end
        
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

