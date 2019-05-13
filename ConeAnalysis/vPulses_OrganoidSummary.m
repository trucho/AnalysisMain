classdef vPulses_OrganoidSummary < ephysGUI
    % plots saved averages for all leaves underneath node?
    properties
        node
        results
        treeresults
    end
    
    methods
        % Constructor (gui objects and initial plotting)
        function hGUI=vPulses_OrganoidSummary(node,params,fign)
            params=checkStructField(params,'PlotNow',1);
            hGUI@ephysGUI(fign);
            hGUI.node = node;
            nV=node.children.length;
            
            organoidMap = hGUI.getOrganoidMap();
            hGUI.treeresults = struct('pulseV',[],'iPeak',[],'iSteady',[]);
            
            colorDummy = [.5 .5 .5];
            color9cis = [.5 .5 1];
            colorAllTrans = [1 .5 .5];
            
%             colors=flipud(pmkmp(nV,'CubicL'));
            colors=NaN(nV,3);
            for i=1:nV
                if strcmp(char(organoidMap(node.children(i).splitValue,:).organoid),'dummy')
                    colors(i,:) = colorDummy;
                elseif strcmp(char(organoidMap(node.children(i).splitValue,:).organoid),'9cis')
                    colors(i,:) = color9cis;
                elseif strcmp(char(organoidMap(node.children(i).splitValue,:).organoid),'allTrans')
                    colors(i,:) = colorAllTrans;
                end
                if strcmp(node.children(i).splitValue,'20181216c01')
                    temp = node.children(i).childBySplitValue(false).custom.get('results').get('pulseV')';
                    hGUI.treeresults.pulseV(i,:) = temp(3:22);
                    temp = node.children(i).childBySplitValue(false).custom.get('results').get('iPeak')';
                    hGUI.treeresults.iPeak(i,:) = temp(3:22);
                    temp = node.children(i).childBySplitValue(false).custom.get('results').get('iSteady')';
                    hGUI.treeresults.iSteady(i,:) = temp(3:22);
                else
                    hGUI.treeresults.pulseV(i,:) = node.children(i).childBySplitValue(false).custom.get('results').get('pulseV')';
                    hGUI.treeresults.iPeak(i,:) = node.children(i).childBySplitValue(false).custom.get('results').get('iPeak')';
                    hGUI.treeresults.iSteady(i,:) = node.children(i).childBySplitValue(false).custom.get('results').get('iSteady')';
                end
            end
            
            wcolors=whithen(colors,.5);
            tcolors=round(colors./1.2.*255);
            
            RowNames=cell(size(nV));
            Data=cell(nV,2);
            for i=1:nV
                RowNames{i}=sprintf('<html><font color=rgb(%d,%d,%d)>%s</font></html>',tcolors(i,1),tcolors(i,2),tcolors(i,3),node.children(i).splitValue);
                Data{i,1} = char(organoidMap(node.children(i).splitValue,:).organoid);
                Data{i,2} = char(organoidMap(node.children(i).splitValue,:).celltype);
%                 if strcmp(Data{i,1},'allTrans') && strcmp(Data{i,2},'rod')
%                 if ~strcmp(Data{i,1},'dummy') && (strcmp(Data{i,2},'cone') || strcmp(Data{i,2},'rod'))
                if (strcmp(Data{i,2},'cone') || strcmp(Data{i,2},'rod'))
                    Data{i,3} = true;
                else
                    Data{i,3} = false;
                end
                if strcmp(Data{i,1},'dummy')
                    colors(i,:) = [.5 .5 .5];
                elseif strcmp(Data{i,1},'9cis')
                    colors(i,:) = [.2 .2 1];
                elseif strcmp(Data{i,1},'allTrans')
                    colors(i,:) = [1 .2 .2];
                end
            end
            
            
            
            tIn=struct;
            tIn.tag='infoTable';
            tIn.Position=[.01, .01, .14, .75];
            tIn.FontSize=10;
            tIn.ColumnWidth={40};
            tIn.Data=Data;
            tIn.ColumnName={'Exp','Type','Plot'};
            tIn.RowName=RowNames;
            tIn.headerWidth=82;
            tIn.CellEditCallback=@hGUI.updatePlots;
            hGUI.createTable(tIn);
            
            
            % buttons


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
            
            
                       
            %IV curve early cone
            plotIV01cone=struct('Position',[p.left p.half_top1 p.width p.half_height],'tag','plotIV01cone');
            hGUI.createPlot(plotIV01cone);
            hGUI.labelx(hGUI.gObj.plotIV01cone,'Vm (mV)');
            hGUI.labely(hGUI.gObj.plotIV01cone,'i (pA)');
            
            %IV curve early rod
            plotIV01rod=struct('Position',[p.left p.half_top2 p.width p.half_height],'tag','plotIV01rod');
            hGUI.createPlot(plotIV01rod);
            hGUI.labelx(hGUI.gObj.plotIV01rod,'Vm (mV)');
            hGUI.labely(hGUI.gObj.plotIV01rod,'i (pA)');
                       
            %IV curve late
            plotIV02cone=struct('Position',[p.left2 p.half_top1 p.width p.half_height],'tag','plotIV02cone');
            hGUI.createPlot(plotIV02cone);
            hGUI.labelx(hGUI.gObj.plotIV02cone,'Vm (mV)');
            hGUI.labely(hGUI.gObj.plotIV02cone,'i (pA)');
            
            %IV curve late
            plotIV02rod=struct('Position',[p.left2 p.half_top2 p.width p.half_height],'tag','plotIV02rod');
            hGUI.createPlot(plotIV02rod);
            hGUI.labelx(hGUI.gObj.plotIV02rod,'Vm (mV)');
            hGUI.labely(hGUI.gObj.plotIV02rod,'i (pA)');
            
            hGUI.ylim(hGUI.gObj.plotIV01cone,[-200 40]);
            hGUI.ylim(hGUI.gObj.plotIV01rod,[-200 40]);
            hGUI.ylim(hGUI.gObj.plotIV02cone,[-500 400]);
            hGUI.ylim(hGUI.gObj.plotIV02rod,[-500 400]);
            
            
            
            
            for i = 1:nV
                cellname = node.children(i).splitValue;
                if strcmp(Data{i,2},'cone')
                    % IV curve
                    lH=line(hGUI.treeresults.pulseV(i,:),hGUI.treeresults.iPeak(i,:),'Parent',hGUI.gObj.plotIV01cone);
                    set(lH,'LineStyle','-','Marker','none','LineWidth',1,'Color',wcolors(i,:))
                    set(lH,'DisplayName',sprintf('%s_IV_peak',cellname))

                    lH=line(hGUI.treeresults.pulseV(i,:),hGUI.treeresults.iSteady(i,:),'Parent',hGUI.gObj.plotIV02cone);
                    set(lH,'LineStyle','-','Marker','none','LineWidth',1,'Color',wcolors(i,:))
                    set(lH,'DisplayName',sprintf('%s_IV_ss',cellname))
                elseif strcmp(Data{i,2},'rod')
                     % IV curve
                    lH=line(hGUI.treeresults.pulseV(i,:),hGUI.treeresults.iPeak(i,:),'Parent',hGUI.gObj.plotIV01rod);
                    set(lH,'LineStyle','-','Marker','none','LineWidth',1,'Color',wcolors(i,:))
                    set(lH,'DisplayName',sprintf('%s_IV_peak',cellname))

                    lH=line(hGUI.treeresults.pulseV(i,:),hGUI.treeresults.iSteady(i,:),'Parent',hGUI.gObj.plotIV02rod);
                    set(lH,'LineStyle','-','Marker','none','LineWidth',1,'Color',wcolors(i,:))
                    set(lH,'DisplayName',sprintf('%s_IV_ss',cellname))
                    
                end
                
            end
            
            % IV average curves
            IVblank = NaN(size(hGUI.treeresults.pulseV(i,:)));
            lH=line(hGUI.treeresults.pulseV(i,:),IVblank,'Parent',hGUI.gObj.plotIV01cone);
            set(lH,'LineStyle','-','Marker','none','LineWidth',2,'Color',colorDummy)
            set(lH,'DisplayName',sprintf('meanIV_peak_dummy_cone'))
            
            lH=line(hGUI.treeresults.pulseV(i,:),IVblank,'Parent',hGUI.gObj.plotIV01cone);
            set(lH,'LineStyle','-','Marker','none','LineWidth',2,'Color',color9cis)
            set(lH,'DisplayName',sprintf('meanIV_peak_9cis_cone'))
            
            lH=line(hGUI.treeresults.pulseV(i,:),IVblank,'Parent',hGUI.gObj.plotIV01cone);
            set(lH,'LineStyle','-','Marker','none','LineWidth',2,'Color',colorAllTrans)
            set(lH,'DisplayName',sprintf('meanIV_peak_allTrans_cone'))
            
            
            lH=line(hGUI.treeresults.pulseV(i,:),IVblank,'Parent',hGUI.gObj.plotIV02cone);
            set(lH,'LineStyle','-','Marker','none','LineWidth',2,'Color',colorDummy)
            set(lH,'DisplayName',sprintf('meanIV_ss_dummy_cone'))
            
            lH=line(hGUI.treeresults.pulseV(i,:),IVblank,'Parent',hGUI.gObj.plotIV02cone);
            set(lH,'LineStyle','-','Marker','none','LineWidth',2,'Color',color9cis)
            set(lH,'DisplayName',sprintf('meanIV_ss_9cis_cone'))
            
            lH=line(hGUI.treeresults.pulseV(i,:),IVblank,'Parent',hGUI.gObj.plotIV02cone);
            set(lH,'LineStyle','-','Marker','none','LineWidth',2,'Color',colorAllTrans)
            set(lH,'DisplayName',sprintf('meanIV_ss_allTrans_cone'))
            
            % IV curve
            lH=line(hGUI.treeresults.pulseV(i,:),IVblank,'Parent',hGUI.gObj.plotIV01rod);
            set(lH,'LineStyle','-','Marker','none','LineWidth',2,'Color',colorDummy)
            set(lH,'DisplayName',sprintf('meanIV_peak_dummy_rod'))
            
            lH=line(hGUI.treeresults.pulseV(i,:),IVblank,'Parent',hGUI.gObj.plotIV01rod);
            set(lH,'LineStyle','-','Marker','none','LineWidth',2,'Color',color9cis)
            set(lH,'DisplayName',sprintf('meanIV_peak_9cis_rod'))
            
            lH=line(hGUI.treeresults.pulseV(i,:),IVblank,'Parent',hGUI.gObj.plotIV01rod);
            set(lH,'LineStyle','-','Marker','none','LineWidth',2,'Color',colorAllTrans)
            set(lH,'DisplayName',sprintf('meanIV_peak_allTrans_rod'))
            
            
            lH=line(hGUI.treeresults.pulseV(i,:),IVblank,'Parent',hGUI.gObj.plotIV02rod);
            set(lH,'LineStyle','-','Marker','none','LineWidth',2,'Color',colorDummy)
            set(lH,'DisplayName',sprintf('meanIV_ss_dummy_rod'))
            
            lH=line(hGUI.treeresults.pulseV(i,:),IVblank,'Parent',hGUI.gObj.plotIV02rod);
            set(lH,'LineStyle','-','Marker','none','LineWidth',2,'Color',color9cis)
            set(lH,'DisplayName',sprintf('meanIV_ss_9cis_rod'))
            
            lH=line(hGUI.treeresults.pulseV(i,:),IVblank,'Parent',hGUI.gObj.plotIV02rod);
            set(lH,'LineStyle','-','Marker','none','LineWidth',2,'Color',colorAllTrans)
            set(lH,'DisplayName',sprintf('meanIV_ss_allTrans_rod'))
                
 
            hGUI.updatePlots;
        end
        
        function updatePlots(hGUI,~,~)
            
            infoData = hGUI.gObj.infoTable.Data;
            Selected = cell2mat(infoData(:,3));
            nV=hGUI.node.children.length;
            
            for i = 1:nV
                peakName = sprintf('%s_IV_peak',hGUI.node.children(i).splitValue);
                ssName = sprintf('%s_IV_ss',hGUI.node.children(i).splitValue);
                if Selected(i)
                    hGUI.showTrace(peakName);
                    hGUI.showTrace(ssName);
                else
                    hGUI.hideTrace(peakName);
                    hGUI.hideTrace(ssName);
                end
            end
            
            hGUI.updateSpecificMean('dummy','cone');
            hGUI.updateSpecificMean('dummy','rod');
            hGUI.updateSpecificMean('9cis','cone');
            hGUI.updateSpecificMean('9cis','rod');
            hGUI.updateSpecificMean('allTrans','cone');
            hGUI.updateSpecificMean('allTrans','rod');

            
        end
        
        
        function updateSpecificMean(hGUI,oTag,cTag)
           subSelection = hGUI.getSubSelection(hGUI.gObj.infoTable.Data,oTag,cTag);
            if sum(subSelection) == 0
                set(findobj('DisplayName',sprintf('meanIV_peak_%s_%s',oTag,cTag)),'YData',NaN(1,size(hGUI.treeresults.iPeak,2)));
                set(findobj('DisplayName',sprintf('meanIV_ss_%s_%s',oTag,cTag)),'YData',NaN(1,size(hGUI.treeresults.iSteady,2)));
            elseif sum(subSelection) == 1
                set(findobj('DisplayName',sprintf('meanIV_peak_%s_%s',oTag,cTag)),'YData',hGUI.treeresults.iPeak(subSelection,:));
                set(findobj('DisplayName',sprintf('meanIV_ss_%s_%s',oTag,cTag)),'YData',hGUI.treeresults.iSteady(subSelection,:));
            else
                set(findobj('DisplayName',sprintf('meanIV_peak_%s_%s',oTag,cTag)),'YData',mean(hGUI.treeresults.iPeak(subSelection,:)));
                set(findobj('DisplayName',sprintf('meanIV_ss_%s_%s',oTag,cTag)),'YData',mean(hGUI.treeresults.iSteady(subSelection,:)));
            end 
        end
        
       
    end
    
    methods (Static=true)
        
        function subSelection = getSubSelection(infoData,oTag,cTag)
            subSelection = strcmp(infoData(:,1),oTag) & strcmp(infoData(:,2),cTag) & cell2mat(infoData(:,3));
        end
        
        function organoidMap = getOrganoidMap()
            tempMap = readtable('/Users/angueyraaristjm/matlab/AnalysisMain/ConeAnalysis/organoidMap.csv');
            organoid = tempMap.organoid;
            celltype = tempMap.celltype;
            organoidMap = table(organoid,celltype,'RowName',tempMap.cellname);
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
        
    end
end
