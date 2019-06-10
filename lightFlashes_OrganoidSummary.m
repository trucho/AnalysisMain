classdef lightFlashes_OrganoidSummary < ephysGUI
    % plots saved averages for all leaves underneath node?
    properties
        node
        results
        I
        treeresults
    end
    
    methods
        % Constructor (gui objects and initial plotting)
        function hGUI=lightFlashes_OrganoidSummary(node,params,fign)
            params=checkStructField(params,'PlotNow',1);
            params=checkStructField(params,'Normalize',1);
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
            tableData=cell(nV,3);
            for i=1:nV
                RowNames{i}=sprintf('<html><font color=rgb(%d,%d,%d)>%s</font></html>',tcolors(i,1),tcolors(i,2),tcolors(i,3),node.children(i).splitValue);
                tableData{i,1} = char(organoidMap(node.children(i).splitValue,:).organoid);
                tableData{i,2} = char(organoidMap(node.children(i).splitValue,:).celltype);
                tableData{i,3} = true;
                if strcmp(tableData{i,1},'dummy')
                    colors(i,:) = [.5 .5 .5];
                elseif strcmp(tableData{i,1},'9cis')
                    colors(i,:) = [.2 .2 1];
                elseif strcmp(tableData{i,1},'allTrans')
                    colors(i,:) = [1 .2 .2];
                end
                Selected = node.children(i).custom.get('results').get('Selected')';
                temp = node.children(i).custom.get('results').get('EpochTime')';
                hGUI.treeresults.EpochTimes{i} = temp(Selected);
                temp = node.children(i).custom.get('results').get('Vmemb')';
                hGUI.treeresults.iHold{i} = temp(Selected);
                temp = node.children(i).custom.get('results').get('VmembSD')';
                hGUI.treeresults.iHoldSD{i} = temp(Selected);
                hGUI.treeresults.n{i} = node.children(i).custom.get('results').get('n')';
            end
            
            
            
            tIn=struct;
            tIn.tag='infoTable';
            tIn.Position=[.01, .01, .17, .50];
            tIn.FontSize=10;
            tIn.ColumnWidth={40};
            tIn.Data=tableData;
            tIn.ColumnName={'Exp','Type','Plot'};
            tIn.ColumnEditable=[false,false,true];
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
            p.left3 = p.left2+p.half_width+.025;
            
            
            p.half_top1=.555;
            p.half_top2=.08;
            p.half_height=.43;
            
            
            p.third_top1=.08;
            p.third_top2=.400;
            p.third_top3=.700;
            p.third_height=.26;
            
            
            % ----------------------------------------------------------------------------- %
            
            %iHold plot
            ploti0=struct('Position',[0.04 .8 .16 .16],'tag','ploti0');
            hGUI.createPlot(ploti0);
            hGUI.labelx(hGUI.gObj.ploti0,'');
            hGUI.labely(hGUI.gObj.ploti0,'i (pA)');
            hGUI.xlim(hGUI.gObj.ploti0,[0.5 2.5]);
            set(hGUI.gObj.ploti0,'XTick',[1 2],'XTickLabels',{'cones','rods'})
            
            iHold_initial = cellfun(@(x) x(1),hGUI.treeresults.iHold);
            jitter=NaN(1,nV);
            for i = 1:nV
                cellname = node.children(i).splitValue;
                jitter(i) = randn(1)*.15;
                if strcmp(tableData{i,2},'cone')
                    lH=line(1+jitter(i),iHold_initial(i),'Parent',hGUI.gObj.ploti0);
                    hGUI.markerc(lH,wcolors(i,:));
                    set(lH,'DisplayName',sprintf('i0_%s',cellname))
                elseif strcmp(tableData{i,2},'rod')
                    lH=line(2+jitter(i),iHold_initial(i),'Parent',hGUI.gObj.ploti0);
                    hGUI.markerc(lH,wcolors(i,:));
                    set(lH,'DisplayName',sprintf('i0_%s',cellname))
                end
            end
            
%             %Stim
%             plotStim=struct('Position',[p.left 1-p.half_height/4-.05 p.width p.half_height/4],'tag','plotStim');
%             hGUI.createPlot(plotStim);
%             hGUI.labelx(hGUI.gObj.plotStim,'time (s)');
%             hGUI.labely(hGUI.gObj.plotStim,'V');
%             hGUI.xlim(hGUI.gObj.plotStim,[0 1]);
            
            %Data Cones
            plotDataCones=struct('Position',[p.left p.half_top1 p.width p.half_height],'tag','plotDataCones');
            hGUI.createPlot(plotDataCones);
            hGUI.labelx(hGUI.gObj.plotDataCones,'time (s)');
            hGUI.labely(hGUI.gObj.plotDataCones,'i (pA)');
            hGUI.xlim(hGUI.gObj.plotDataCones,[0 1]);
            
            %Data Rods
            plotDataRods=struct('Position',[p.left p.half_top2 p.width p.half_height],'tag','plotDataRods');
            hGUI.createPlot(plotDataRods);
            hGUI.labelx(hGUI.gObj.plotDataRods,'time (s)');
            hGUI.labely(hGUI.gObj.plotDataRods,'i (pA)');
            hGUI.xlim(hGUI.gObj.plotDataRods,[0 2]);
                       
            %I Cones
            plotIcone=struct('Position',[p.left2 p.half_top1 p.width p.half_height],'tag','plotIcone');
            hGUI.createPlot(plotIcone);
            hGUI.labelx(hGUI.gObj.plotIcone,'I_b (pA)');
            hGUI.labely(hGUI.gObj.plotIcone,'I_f (pA)');
            hGUI.xlim(hGUI.gObj.plotIcone,[-3 4]);
            hGUI.ylim(hGUI.gObj.plotIcone,[-3 4]);
            %I Rods
            plotIrod=struct('Position',[p.left2 p.half_top2 p.width p.half_height],'tag','plotIrod');
            hGUI.createPlot(plotIrod);
            hGUI.labelx(hGUI.gObj.plotIrod,'I_b (pA)');
            hGUI.labely(hGUI.gObj.plotIrod,'I_f (pA)');
            hGUI.xlim(hGUI.gObj.plotIrod,get(hGUI.gObj.plotIcone,'xlim'));
            hGUI.ylim(hGUI.gObj.plotIrod,get(hGUI.gObj.plotIcone,'ylim'));
            
            %SNR
            plotSNR=struct('Position',[0.04 .60 .16 .16],'tag','plotSNR');
            hGUI.createPlot(plotSNR);
            hGUI.labelx(hGUI.gObj.plotSNR,'');
            hGUI.labely(hGUI.gObj.plotSNR,'SNR');
            hGUI.xlim(hGUI.gObj.plotSNR,[0.5 2.5]);
            set(hGUI.gObj.plotSNR,'XTick',[1 2],'XTickLabels',{'cones','rods'})

            
            lH=line(-3:5,-3:5,'Parent',hGUI.gObj.plotIcone);
            hGUI.linec(lH,[.5 .5 .5]);
            set(lH,'DisplayName',sprintf('UnityCone'))
            
            lH=line(-3:5,-3:5,'Parent',hGUI.gObj.plotIrod);
            hGUI.linec(lH,[.5 .5 .5]);
            set(lH,'DisplayName',sprintf('UnityRod'))
            
            I=struct('pre',NaN(nV,1),'preSD',NaN(nV,1),'preSEM',NaN(nV,1),...
                'flash',NaN(nV,1),'flashSD',NaN(nV,1),'flashSEM',NaN(nV,1),...
                'post',NaN(nV,1),'postSD',NaN(nV,1),'postSEM',NaN(nV,1),...
                'Signal',NaN(nV,1),'Noise',NaN(nV,1),'SNR',NaN(nV,1),...
                'preLim',[.05 .25],'flashLim',[.25 .45],'postLim',[.8 1]);
            for i = 1:nV
                cellname = node.children(i).splitValue;
                tAxis = node.children(i).custom.get('results').get('tAxis');
                Data = node.children(i).custom.get('results').get('Mean');
                Data = LowPassFilter(Data,200,getSamplingInterval(node.children(i)));
                
%                 Stim = node.children(i).custom.get('results').get('Stim');
%                 lH=line(tAxis,Stim,'Parent',hGUI.gObj.plotStim);
%                 hGUI.linec(lH,wcolors(i,:));
%                 set(lH,'DisplayName',sprintf('Stim_%s',cellname))
                

                I.pre(i) = mean(Data(tAxis>=I.preLim(1) & tAxis <I.preLim(2)));
                I.preSD(i) = std(Data(tAxis>=I.preLim(1) & tAxis <I.preLim(2)));
%                 I.preSD(i) = I.preSD(i)./sqrt(sum(tAxis>=I.preLim(1) & tAxis <I.preLim(2)));
                
                I.flash(i) = mean(Data(tAxis>=I.flashLim(1) & tAxis <I.flashLim(2)));
                I.flashSD(i) = std(Data(tAxis>=I.flashLim(1) & tAxis <I.flashLim(2)));
%                 I.flashSD(i) = I.flashSD(i)./sqrt(sum(tAxis>=I.flashLim(1) & tAxis <I.flashLim(2)));
                
                I.post(i) = mean(Data(tAxis>=I.postLim(1) & tAxis <I.postLim(2)));
                I.postSD(i) = std(Data(tAxis>=I.postLim(1) & tAxis <I.postLim(2)));
%                 I.postSD(i) = I.postSD(i)./sqrt(sum(tAxis>=I.postLim(1) & tAxis <I.postLim(2)));
                
                % This calculates SNR of the mean, which is greatly affected by how many traces were used for averaging
%                 I.SNR(i) = (mean([I.flash(i)-I.pre(i) I.flash(i)-I.post(i)])) / (I.postSD(i));
                
                % This calculates SNR using signal from mean and then relating it to average noise in the raw data, which should be the true SNR
                % The problem is that accuracy of signal measurement is funky
                I.Signal(i) = mean([I.flash(i)-I.pre(i) I.flash(i)-I.post(i)]);
                tempNoise = node.children(i).custom.get('results').get('VmembSD');
                I.Noise(i) = mean(tempNoise(node.children(i).custom.get('results').get('Selected')));
                I.SNR(i) = I.Signal(i) / (I.Noise(i));
                
                if strcmp(tableData{i,2},'cone')
                    lH=line(tAxis,Data,'Parent',hGUI.gObj.plotDataCones);
                    hGUI.linec(lH,wcolors(i,:));
                    set(lH,'DisplayName',sprintf('Data_%s',cellname))
                    
                    lH=line(I.pre(i),I.flash(i),'Parent',hGUI.gObj.plotIcone);
                    hGUI.markerc(lH,wcolors(i,:));
                    set(lH,'DisplayName',sprintf('I_%s',cellname))
                    
                    lH=line([I.pre(i)-I.preSD(i) I.pre(i)+I.preSD(i)],[I.flash(i) I.flash(i)],'Parent',hGUI.gObj.plotIcone);
                    hGUI.linec(lH,wcolors(i,:));
                    set(lH,'DisplayName',sprintf('IpreSD_%s',cellname))
                    
                    lH=line([I.pre(i) I.pre(i)],[I.flash(i)-I.flashSD(i) I.flash(i)+I.flashSD(i)],'Parent',hGUI.gObj.plotIcone);
                    hGUI.linec(lH,wcolors(i,:));
                    set(lH,'DisplayName',sprintf('IpostSD_%s',cellname))
                    
                    lH=line(1+jitter(i),I.SNR(i),'Parent',hGUI.gObj.plotSNR);
                    hGUI.markerc(lH,wcolors(i,:));
                    set(lH,'DisplayName',sprintf('SNR_%s',cellname))
                    
                elseif strcmp(tableData{i,2},'rod')
                    lH=line(tAxis,Data,'Parent',hGUI.gObj.plotDataRods);
                    hGUI.linec(lH,wcolors(i,:));
                    set(lH,'DisplayName',sprintf('Data_%s',cellname))
                    
                    lH=line(I.pre(i),I.flash(i),'Parent',hGUI.gObj.plotIrod);
                    hGUI.markerc(lH,wcolors(i,:));
                    set(lH,'DisplayName',sprintf('I_%s',cellname))
                    
                    lH=line([I.pre(i)-I.preSD(i) I.pre(i)+I.preSD(i)],[I.flash(i) I.flash(i)],'Parent',hGUI.gObj.plotIrod);
                    hGUI.linec(lH,wcolors(i,:));
                    set(lH,'DisplayName',sprintf('IpreSD_%s',cellname))
                    
                    lH=line([I.pre(i) I.pre(i)],[I.flash(i)-I.flashSD(i) I.flash(i)+I.flashSD(i)],'Parent',hGUI.gObj.plotIrod);
                    hGUI.linec(lH,wcolors(i,:));
                    set(lH,'DisplayName',sprintf('IpostSD_%s',cellname))
                    
                    lH=line(2+jitter(i),I.SNR(i),'Parent',hGUI.gObj.plotSNR);
                    hGUI.markerc(lH,wcolors(i,:));
                    set(lH,'DisplayName',sprintf('SNR_%s',cellname))
                end
            end
            
            hGUI.I = I;
 
            hGUI.updatePlots;
        end
        
        function updatePlots(hGUI,~,~)
            
            infoData = hGUI.gObj.infoTable.Data;
            Selected = cell2mat(infoData(:,3));
            nV=hGUI.node.children.length;
            
            for i = 1:nV
                lineName = sprintf('Data_%s',hGUI.node.children(i).splitValue);
                i0Name = sprintf('i0_%s',hGUI.node.children(i).splitValue);
                IName = sprintf('I_%s',hGUI.node.children(i).splitValue);
                IpreName = sprintf('IpreSD_%s',hGUI.node.children(i).splitValue);
                IpostName = sprintf('IpostSD_%s',hGUI.node.children(i).splitValue);
                snrName = sprintf('SNR_%s',hGUI.node.children(i).splitValue);
                if Selected(i)
                    hGUI.showTrace(lineName);
                    hGUI.showTrace(i0Name);
                    hGUI.showTrace(IName);
                    hGUI.showTrace(IpreName);
                    hGUI.showTrace(IpostName);
                    hGUI.showTrace(snrName);
                else
                    hGUI.hideTrace(lineName);
                    hGUI.hideTrace(i0Name);
                    hGUI.hideTrace(IName);
                    hGUI.hideTrace(IpreName);
                    hGUI.hideTrace(IpostName);
                    hGUI.hideTrace(snrName);
                end
            end
            

            
        end
        
        
%         function SNR = SNRcalculator(hGUI,i)
%             cellnode = hGUI.node.children(i);
%             
%             cellresults=toMatlabStruct(cellnode.custom.get('results'));
%             Data = riekesuite.getResponseMatrix(cellnode.epochList,'Amp1');
%             Data = Data(cellresults.Selected,:);
%             tAxis = cellresults.tAxis;
%             
%             
%             hGUI.I.pre(i) = mean(Data(tAxis>=hGUI.I.preLim(1) & tAxis <hGUI.I.preLim(2)));
%             hGUI.I.preSD(i) = std(Data(tAxis>=hGUI.I.preLim(1) & tAxis <hGUI.I.preLim(2)));
%             %hGUI.I.preSD(i) = hGUI.I.preSD(i)./sqrt(sum(tAxis>=hGUI.I.preLim(1) & tAxis <hGUI.I.preLim(2)));
%             
%             hGUI.I.flash(i) = mean(Data(tAxis>=hGUI.I.flashLim(1) & tAxis <hGUI.I.flashLim(2)));
%             hGUI.I.flashSD(i) = std(Data(tAxis>=hGUI.I.flashLim(1) & tAxis <hGUI.I.flashLim(2)));
%             %hGUI.I.flashSD(i) = hGUI.I.flashSD(i)./sqrt(sum(tAxis>=hGUI.I.flashLim(1) & tAxis <hGUI.I.flashLim(2)));
%             
%             hGUI.I.post(i) = mean(Data(tAxis>=hGUI.I.postLim(1) & tAxis <hGUI.I.postLim(2)));
%             hGUI.I.postSD(i) = std(Data(tAxis>=hGUI.I.postLim(1) & tAxis <hGUI.I.postLim(2)));
%             %hGUI.I.postSD(i) = hGUI.I.postSD(i)./sqrt(sum(tAxis>=hGUI.I.postLim(1) & tAxis <hGUI.I.postLim(2)));
%             
%             hGUI.I.SNR(i) = (mean([hGUI.I.flash(i)-hGUI.I.pre(i) hGUI.I.flash(i)-hGUI.I.post(i)])) / (hGUI.I.postSD(i));`
%         end
        
       
    end
    
    methods (Static=true)
        
        function subSelection = getSubSelection(infoData,oTag,cTag)
            subSelection = strcmp(infoData(:,1),oTag) & strcmp(infoData(:,2),cTag) & cell2mat(infoData(:,3));
        end
        
        function organoidMap = getOrganoidMap()
            tempMap = readtable('/Users/angueyraaristjm/matlab/AnalysisMain/ConeAnalysis/organoidMap_lightFlashes.csv');
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
