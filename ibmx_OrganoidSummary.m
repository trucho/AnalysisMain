classdef ibmx_OrganoidSummary < ephysGUI
    % plots saved averages for all leaves underneath node?
    properties
        node
        results
        treeresults
    end
    
    methods
        % Constructor (gui objects and initial plotting)
        function hGUI=ibmx_OrganoidSummary(node,params,fign)
            params=checkStructField(params,'PlotNow',1);
            params=checkStructField(params,'Normalize',0);
            hGUI@ephysGUI(fign);
            hGUI.node = node;
            nV=node.children.length;
            
            organoidMap = hGUI.getOrganoidMap();
            hGUI.treeresults = struct('EpochTimes',[],'iHold',[],'iHoldSD',[],'n',[]);
            
            colorDummy = [.5 .5 .5];
            color9cis = [.5 .5 1];
            colorAllTrans = [1 .5 .5];
            
%             colors=flipud(pmkmp(nV,'CubicL'));
            colors=NaN(nV,3);
            for i=1:nV
                hGUI.results{i} = toMatlabStruct(node.children(i).custom.get('results'));
                if strcmp(char(organoidMap(getcellname(node.children(i)),:).organoid),'dummy')
                    colors(i,:) = colorDummy;
                elseif strcmp(char(organoidMap(getcellname(node.children(i)),:).organoid),'9cis')
                    colors(i,:) = color9cis;
                elseif strcmp(char(organoidMap(getcellname(node.children(i)),:).organoid),'allTrans')
                    colors(i,:) = colorAllTrans;
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
%                 if sum(strcmp(node.children(i).splitValue,{'20190121c02'; '20190121c03'; '20190121c04'; '20190121c06'; '20190121c16'; '20190128c10'}))
%                     Data{i,4} = false;
%                 else
                    Data{i,3} = true;
%                 end
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
            tIn.Position=[.01, .01, .17, .50];
            tIn.FontSize=10;
            tIn.ColumnWidth={40};
            tIn.Data=Data;
            tIn.ColumnName={'Exp','Type','cGMP','Plot'};
            tIn.ColumnEditable=[false,false,false,true];
            tIn.RowName=RowNames;
            tIn.headerWidth=82;
            tIn.CellEditCallback=@hGUI.updatePlots;
            hGUI.createTable(tIn);
            
            
            % buttons


            % plot creation
            p=struct;
            p.width=.35;
            p.half_width = .17;
            
            p.left=.240;
            p.left2 = p.left+p.width+.04;
            p.left3 = p.left2+p.half_width+.04;
            
            
            p.half_top1=.555;
            p.half_top2=.08;
            p.half_height=.43;
            
            
            p.third_top1=.08;
            p.third_top2=.400;
            p.third_top3=.700;
            p.third_height=.26;
            
            
            % ----------------------------------------------------------------------------- %
            
            %iHold plot
            ploti0Cones=struct('Position',[0.04 .8 .16 .16],'tag','ploti0Cones');
            hGUI.createPlot(ploti0Cones);
            hGUI.labelx(hGUI.gObj.ploti0Cones,'');
            hGUI.labely(hGUI.gObj.ploti0Cones,'i (pA)');
            hGUI.xlim(hGUI.gObj.ploti0Cones,[0.5 2.5]);
            
            
            iHold_initial = NaN(nV,1);
            for i = 1:nV
                cellname = node.children(i).splitValue;
                jitter = randn(1)*.05;
                iHold_initial(i) = hGUI.results{i}.iH(1);
                if strcmp(Data{i,2},'cone')
                    lH=line(1+jitter,iHold_initial(i),'Parent',hGUI.gObj.ploti0Cones);
                    hGUI.markerc(lH,colors(i,:));
                    set(lH,'DisplayName',sprintf('i0_%s',cellname))
                elseif strcmp(Data{i,2},'rod')
                    lH=line(2+jitter,iHold_initial(i),'Parent',hGUI.gObj.ploti0Cones);
                    hGUI.markerc(lH,colors(i,:));
                    set(lH,'DisplayName',sprintf('i0_%s',cellname))
                    
                end
            end
            
            
            i0.Cone = iHold_initial(strcmp('cone',Data(:,2)));
            i0.Rod = iHold_initial(strcmp('rod',Data(:,2)));
            
            hGUI.treeresults.iHold_t0 = i0;
            
            lH=line(1,mean(i0.Cone),'Parent',hGUI.gObj.ploti0Cones);
            hGUI.markerc(lH,[0 0 0]); set(lH,'DisplayName',sprintf('i0_cones'));
            
            
            lH=line(2,mean(i0.Rod),'Parent',hGUI.gObj.ploti0Cones);
            hGUI.markerc(lH,[0 0 0]); set(lH,'DisplayName',sprintf('i0_rods'));
            
            
            % ----------------------------------------------------------------------------- %
            
            
            %IBMX Cones
            plotcones=struct('Position',[p.left p.half_top1 p.width p.half_height],'tag','plotcones');
            hGUI.createPlot(plotcones);
            hGUI.labelx(hGUI.gObj.plotcones,'');
            hGUI.labely(hGUI.gObj.plotcones,'i (pA)');
            hGUI.xlim(hGUI.gObj.plotcones,[.5 3.5]);
            
            %IBMX Rods
            plotrods=struct('Position',[p.left p.half_top2 p.width p.half_height],'tag','plotrods');
            hGUI.createPlot(plotrods);
            hGUI.labelx(hGUI.gObj.plotrods,'');
            hGUI.labely(hGUI.gObj.plotrods,'i (pA)');
            hGUI.xlim(hGUI.gObj.plotrods,[.5 3.5]);
            
            if ~params.Normalize
                hGUI.ylim(hGUI.gObj.plotcones,[-60 0]);
                hGUI.ylim(hGUI.gObj.plotrods,[-60 0]);
                for i = 1:nV
                    ibmx = hGUI.results{i}.ibmx;
                    if strcmp(Data{i,2},'cone')
                        hGUI.plotErrorBar([1 2 3],[ibmx.pre, ibmx.ibmx, ibmx.post],[ibmx.pre_sd, ibmx.ibmx_sd, ibmx.post_sd],hGUI.gObj.plotcones,sprintf('%s',cellname));
                        lH=line([1 2 3],[ibmx.pre, ibmx.ibmx, ibmx.post],'Parent',hGUI.gObj.plotcones);
                        hGUI.linemarkerc(lH,colors(i,:));
                        set(lH,'DisplayName',sprintf('%s',cellname))
                    elseif strcmp(Data{i,2},'rod')
                        hGUI.plotErrorBar([1 2 3],[ibmx.pre, ibmx.ibmx, ibmx.post],[ibmx.pre_sd, ibmx.ibmx_sd, ibmx.post_sd],hGUI.gObj.plotrods,sprintf('%s',cellname));
                        lH=line([1 2 3],[ibmx.pre, ibmx.ibmx, ibmx.post],'Parent',hGUI.gObj.plotrods);
                        hGUI.linemarkerc(lH,colors(i,:));
                        set(lH,'DisplayName',sprintf('%s',cellname))
                    end
                end
            else
                hGUI.ylim(hGUI.gObj.plotcones,[.5 2]);
                hGUI.ylim(hGUI.gObj.plotrods,[.5 2]);
                for i = 1:nV
                    ibmx = hGUI.results{i}.ibmx;
                    if strcmp(Data{i,2},'cone')
                        hGUI.plotErrorBar([1 2 3],[ibmx.pre, ibmx.ibmx, ibmx.post]./ibmx.pre,[ibmx.pre_sd, ibmx.ibmx_sd, ibmx.post_sd]./ibmx.pre,hGUI.gObj.plotcones,sprintf('%s',cellname));
                        lH=line([1 2 3],[ibmx.pre, ibmx.ibmx, ibmx.post]./ibmx.pre,'Parent',hGUI.gObj.plotcones);
                        hGUI.linemarkerc(lH,colors(i,:));
                        set(lH,'DisplayName',sprintf('%s',cellname))
                    elseif strcmp(Data{i,2},'rod')
                        hGUI.plotErrorBar([1 2 3],[ibmx.pre, ibmx.ibmx, ibmx.post]./ibmx.pre,[ibmx.pre_sd, ibmx.ibmx_sd, ibmx.post_sd]./ibmx.pre,hGUI.gObj.plotrods,sprintf('%s',cellname));
                        lH=line([1 2 3],[ibmx.pre, ibmx.ibmx, ibmx.post]./ibmx.pre,'Parent',hGUI.gObj.plotrods);
                        hGUI.linemarkerc(lH,colors(i,:));
                        set(lH,'DisplayName',sprintf('%s',cellname))
                    end
                end
            end
%                 hGUI.ylim(hGUI.gObj.plotNocGcone,[0 3.5]);
%                 hGUI.ylim(hGUI.gObj.plotcGcone,[0 3.5]);
%                 hGUI.ylim(hGUI.gObj.plotNocGrod,[0 3.5]);
%                 hGUI.ylim(hGUI.gObj.plotcGrod,[0 3.5]);
%                 hGUI.labely(hGUI.gObj.plotNocGcone,'i(foldChange)');
%                 hGUI.labely(hGUI.gObj.plotcGcone,'i(foldChange)');
%                 hGUI.labely(hGUI.gObj.plotNocGrod,'i(foldChange)');
%                 hGUI.labely(hGUI.gObj.plotcGrod,'i(foldChange)');
%             end
%             
%             hGUI.treeresults.tAxsmooth = 0:.1:55;
%             hGUI.treeresults.iHoldsmooth = NaN(nV,size(hGUI.treeresults.tAxsmooth,2));
%             
%             
%             lH=line(hGUI.treeresults.tAxsmooth,ones(size(hGUI.treeresults.tAxsmooth)),'Parent',hGUI.gObj.plotNocGcone);
%             set(lH,'LineStyle','-.','Marker','none','LineWidth',1,'MarkerSize',5,'Color',[0 0 0]); set(lH,'DisplayName',sprintf('zeros_cones_nocG'));
%             
%             lH=line(hGUI.treeresults.tAxsmooth,ones(size(hGUI.treeresults.tAxsmooth)),'Parent',hGUI.gObj.plotcGcone);
%             set(lH,'LineStyle','-.','Marker','none','LineWidth',1,'MarkerSize',5,'Color',[0 0 0]); set(lH,'DisplayName',sprintf('cones_cG'));
%             
%             lH=line(hGUI.treeresults.tAxsmooth,ones(size(hGUI.treeresults.tAxsmooth)),'Parent',hGUI.gObj.plotNocGrod);
%             set(lH,'LineStyle','-.','Marker','none','LineWidth',1,'MarkerSize',5,'Color',[0 0 0]); set(lH,'DisplayName',sprintf('rods_nocG'));
%             
%             lH=line(hGUI.treeresults.tAxsmooth,ones(size(hGUI.treeresults.tAxsmooth)),'Parent',hGUI.gObj.plotcGrod);
%             set(lH,'LineStyle','-.','Marker','none','LineWidth',1,'MarkerSize',5,'Color',[0 0 0]); set(lH,'DisplayName',sprintf('rods_cG'));
%             
%             for i = 1:nV
%                 cellname = node.children(i).splitValue;
%                 hGUI.treeresults.iHoldsmooth(i,:) = interp1(hGUI.treeresults.EpochTimes{i},hGUI.treeresults.iHold{i},hGUI.treeresults.tAxsmooth);
%                 if strcmp(Data{i,2},'cone')
%                     if ~Data{i,3}
%                         lH=line(hGUI.treeresults.EpochTimes{i},hGUI.treeresults.iHold{i},'Parent',hGUI.gObj.plotNocGcone);
%                         hGUI.markerc(lH,wcolors(i,:));
%                         set(lH,'DisplayName',sprintf('%s',cellname))
%                         
%                         lH=line(hGUI.treeresults.tAxsmooth,hGUI.treeresults.iHoldsmooth(i,:),'Parent',hGUI.gObj.plotNocGcone);
%                         hGUI.linec(lH,wcolors(i,:));
%                         set(lH,'DisplayName',sprintf('%s_interp',cellname))
%                     else
%                         lH=line(hGUI.treeresults.EpochTimes{i},hGUI.treeresults.iHold{i},'Parent',hGUI.gObj.plotcGcone);
%                         hGUI.markerc(lH,wcolors(i,:));
%                         set(lH,'DisplayName',sprintf('%s',cellname))
%                         
%                         lH=line(hGUI.treeresults.tAxsmooth,hGUI.treeresults.iHoldsmooth(i,:),'Parent',hGUI.gObj.plotcGcone);
%                         hGUI.linec(lH,wcolors(i,:));
%                         set(lH,'DisplayName',sprintf('%s_interp',cellname))
%                     end
%                 elseif strcmp(Data{i,2},'rod')
%                     if ~Data{i,3}
%                         lH=line(hGUI.treeresults.EpochTimes{i},hGUI.treeresults.iHold{i},'Parent',hGUI.gObj.plotNocGrod);
%                         hGUI.markerc(lH,wcolors(i,:));
%                         set(lH,'DisplayName',sprintf('%s',cellname))
%                         
%                         lH=line(hGUI.treeresults.tAxsmooth,hGUI.treeresults.iHoldsmooth(i,:),'Parent',hGUI.gObj.plotNocGrod);
%                         hGUI.linec(lH,wcolors(i,:));
%                         set(lH,'DisplayName',sprintf('%s_interp',cellname))
%                     else
%                         lH=line(hGUI.treeresults.EpochTimes{i},hGUI.treeresults.iHold{i},'Parent',hGUI.gObj.plotcGrod);
%                         hGUI.markerc(lH,wcolors(i,:));
%                         set(lH,'DisplayName',sprintf('%s',cellname))
%                         
%                         lH=line(hGUI.treeresults.tAxsmooth,hGUI.treeresults.iHoldsmooth(i,:),'Parent',hGUI.gObj.plotcGrod);
%                         hGUI.linec(lH,wcolors(i,:));
%                         set(lH,'DisplayName',sprintf('%s_interp',cellname))
%                     end
%                       
%                 end
%             end
%             
%             Averages.Cone.NocG = nanmean(hGUI.treeresults.iHoldsmooth(strcmp('cone',Data(:,2))&~cell2mat(Data(:,3))&cell2mat(Data(:,4)),:));
%             Averages.Cone.cG = nanmean(hGUI.treeresults.iHoldsmooth(strcmp('cone',Data(:,2))&cell2mat(Data(:,3))&cell2mat(Data(:,4)),:));
%             Averages.Rod.NocG = nanmean(hGUI.treeresults.iHoldsmooth(strcmp('rod',Data(:,2))&~cell2mat(Data(:,3))&cell2mat(Data(:,4)),:));
%             Averages.Rod.cG = nanmean(hGUI.treeresults.iHoldsmooth(strcmp('rod',Data(:,2))&cell2mat(Data(:,3))&cell2mat(Data(:,4)),:));
%             
%             hGUI.treeresults.Averages = Averages;
%             
%             lH=line(hGUI.treeresults.tAxsmooth,Averages.Cone.NocG,'Parent',hGUI.gObj.plotNocGcone);
%             hGUI.linek(lH); set(lH,'DisplayName',sprintf('cones_nocG'));
%             
%             lH=line(hGUI.treeresults.tAxsmooth,Averages.Cone.cG,'Parent',hGUI.gObj.plotcGcone);
%             hGUI.linek(lH); set(lH,'DisplayName',sprintf('cones_cG'));
%             
%             lH=line(hGUI.treeresults.tAxsmooth,Averages.Rod.NocG,'Parent',hGUI.gObj.plotNocGrod);
%             hGUI.linek(lH); set(lH,'DisplayName',sprintf('rods_nocG'));
%             
%             lH=line(hGUI.treeresults.tAxsmooth,Averages.Rod.cG,'Parent',hGUI.gObj.plotcGrod);
%             hGUI.linek(lH); set(lH,'DisplayName',sprintf('rods_cG'));
%             
%  
%             hGUI.updatePlots;
        end
        
        function updatePlots(hGUI,~,~)
            
            infoData = hGUI.gObj.infoTable.Data;
            Selected = cell2mat(infoData(:,4));
            nV=hGUI.node.children.length;
            
            for i = 1:nV
                lineName = sprintf('%s',hGUI.node.children(i).splitValue);
                smoothName = sprintf('%s_interp',hGUI.node.children(i).splitValue);
                i0Name = sprintf('i0_%s',hGUI.node.children(i).splitValue);
                if Selected(i)
                    hGUI.showTrace(lineName);
                    hGUI.showTrace(smoothName);
                    hGUI.showTrace(i0Name);
                else
                    hGUI.hideTrace(lineName);
                    hGUI.hideTrace(smoothName);
                    hGUI.hideTrace(i0Name);
                end
            end
            
%             hGUI.updateSpecificMean('dummy','cone');
%             hGUI.updateSpecificMean('dummy','rod');
%             hGUI.updateSpecificMean('9cis','cone');
%             hGUI.updateSpecificMean('9cis','rod');
%             hGUI.updateSpecificMean('allTrans','cone');
%             hGUI.updateSpecificMean('allTrans','rod');

            
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
            tempMap = readtable('/Users/angueyraaristjm/matlab/AnalysisMain/ConeAnalysis/organoidMap_IBMX.csv');
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
