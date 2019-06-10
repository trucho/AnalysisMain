classdef ibmx_OneCell < ephysGUI
     % plots saved averages for all leaves underneath node?
    properties
        node
        results
        selected
        ibmxFlag
    end
    
    methods
        % Constructor (gui objects and initial plotting)
        function hGUI=ibmx_OneCell(node,params,fign)
            params=checkStructField(params,'silent',0);
            params=checkStructField(params,'saveResults',0);
            hGUI@ephysGUI(fign);
            hGUI.node = node;
            
            nV=node.epochList.length;

            samplingInterval=getSamplingInterval(node);
            
            hGUI.results.Data=riekesuite.getResponseMatrix(node.epochList,'Amp1');
            hGUI.results.tAx=(0:size(hGUI.results.Data(1,:),2)-1)*samplingInterval;
%             sampleEpoch = node.epochList.firstValue;
%             hGUI.results.Stim=riekesuite.getStimulusVector(sampleEpoch,'Amp1');
            hGUI.results.EpochTimes=getstartTimeUser(node);
            
            delta = .5; % in s
            deltaPts = delta / samplingInterval;
            nIntervals = floor(size(hGUI.results.Data,2)/deltaPts);
            

            hGUI.results.iH_tAx = repmat(0:delta:delta*(nIntervals-1),nV,1) + hGUI.results.EpochTimes';
            hGUI.results.ibmx = false(size(hGUI.results.iH_tAx));
            hGUI.results.iH = NaN(size(hGUI.results.iH_tAx));
            hGUI.results.iH_sd = NaN(size(hGUI.results.iH_tAx));
            
            hGUI.ibmxFlag = false(nV,1);
            hGUI.selected = false(nV,1);
            
            for i = 1:nV
                hGUI.results.iH(i,:)=mean(reshape(hGUI.results.Data(i,1:deltaPts*nIntervals),deltaPts,nIntervals));
                hGUI.results.iH_sd(i,:)=std(reshape(hGUI.results.Data(i,1:deltaPts*nIntervals),deltaPts,nIntervals));
                if node.epochList.valueByIndex(i).keywords.contains('IBMX')
                   hGUI.results.ibmx(i,:) = true(size(hGUI.results.ibmx(i,:)));
                   hGUI.ibmxFlag(i) = true;
                end
                if node.epochList.valueByIndex(1).keywords.contains('include')
                    hGUI.selected(i) = true;
                end
            end
            
            ibmx = struct(...
                'preX',1,'preY',[0,1],...
                'ibmxX',1,'ibmxY',[0,1],...
                'postX',1,'postY',[0,1]);
            % hard coding final results and plots
            if strcmp(getcellname(hGUI.node),'20190123c01')
                hGUI.selected = false(nV,1);
                hGUI.selected(2:3,:) = true;
                
                ibmx.preX = 2;
                ibmx.preY = [0,4];%1:8;
                
                ibmx.ibmxX = 2;
                ibmx.ibmxY = [5,10];%10:20;
                
                ibmx.postX = 3;
                ibmx.postY = [0,4];%1:8;

            elseif strcmp(getcellname(hGUI.node),'20190123c02')
                hGUI.selected = false(nV,1);
                hGUI.selected([3,4],:) = true;
                
                ibmx.preX = 3;
                ibmx.preY = [0,2];%1:4;
                
                ibmx.ibmxX = 3;
                ibmx.ibmxY = [3,9];%6:18;
                
                ibmx.postX = 4;
                ibmx.postY = [0.5,1];%1:2;
                
            elseif strcmp(getcellname(hGUI.node),'20190123c03')
                % opposite effect
                hGUI.selected = false(nV,1);
                hGUI.selected([4:6],:) = true;
                
                ibmx.preX = 4;
                ibmx.preY = [0,4.5];%1:9;
                
                ibmx.ibmxX = 5;
                ibmx.ibmxY = [2,3.5];%4:7;
                
                ibmx.postX = 6;
                ibmx.postY = [7,10];%14:20;
                
            elseif strcmp(getcellname(hGUI.node),'20190123c04')
                hGUI.selected = false(nV,1);
                hGUI.selected([4:7],:) = true;
                
                ibmx.preX = 4;
                ibmx.preY = [0,10];%1:20;
                
                ibmx.ibmxX = 5;
                ibmx.ibmxY = [5,10];%10:20;
                
                ibmx.postX = 7;
                ibmx.postY = [0,5];%1:10;
                
            elseif strcmp(getcellname(hGUI.node),'20190123c05')
                hGUI.selected = false(nV,1);
                hGUI.selected([3:5],:) = true;
                
                ibmx.preX = 3;
                ibmx.preY = [0,4];%1:8;
                
                ibmx.ibmxX = 4;
                ibmx.ibmxY = [0,4];%1:8;
                
                ibmx.postX = 5;
                ibmx.postY = [0,4];%1:8;
                
            elseif strcmp(getcellname(hGUI.node),'20190127c01')
                hGUI.selected = false(nV,1);
                hGUI.selected([3:5],:) = true;
                
                ibmx.preX = 3;
                ibmx.preY = [0,3];%1:6;
                
                ibmx.ibmxX = 3;
                ibmx.ibmxY = [5,10];%10:20;
                
                ibmx.postX = 5;
                ibmx.postY = [0,4];%1:8;
                
            elseif strcmp(getcellname(hGUI.node),'20190127c04')
                hGUI.selected = false(nV,1);
                hGUI.selected([3:5],:) = true;
                
                ibmx.preX = 3;
                ibmx.preY = [0,2];%1:4;
                
                ibmx.ibmxX = 3;
                ibmx.ibmxY = [4,10];%8:20;
                
                ibmx.postX = 5;
                ibmx.postY = [0,5];%1:10;
                
            elseif strcmp(getcellname(hGUI.node),'20190127c05')
                % EXCLUDE THIS CELL. UNSTABLE RECORDING
                
            elseif strcmp(getcellname(hGUI.node),'20190127c06')
                hGUI.selected = false(nV,1);
                hGUI.selected([2:6],:) = true;
                
                ibmx.preX = 2;
                ibmx.preY = [0,10];%1:20;
                
                ibmx.ibmxX = 3;
                ibmx.ibmxY = [3,7];%6:14;
                
                ibmx.postX = 6;
                ibmx.postY = [0,4];%1:8;
                
            elseif strcmp(getcellname(hGUI.node),'20190128c02')
                % Do Not Believe kinetics of this
                hGUI.selected = false(nV,1);
                hGUI.selected([2:4],:) = true;
                
                ibmx.preX = 2;
                ibmx.preY = [0,10];%1:20;
                
                ibmx.ibmxX = 3;
                ibmx.ibmxY = [6,10];%12:20;
                
                ibmx.postX = 4;
                ibmx.postY = [6,10];%12:20;
                
            elseif strcmp(getcellname(hGUI.node),'20190128c03')
                hGUI.selected = false(nV,1);
                hGUI.selected([2:4],:) = true;
                
                ibmx.preX = 2;
                ibmx.preY = [0,10];%1:20;
                
                ibmx.ibmxX = 4;
                ibmx.ibmxY = [5,10];%10:20;
                
                ibmx.postX = 3;
                ibmx.postY = [0,4];%1:8;

            end
            
%             ibmx.tAx_pre = hGUI.results.iH_tAx(ibmx.preX,ibmx.preY);
%             ibmx.iH_pre = hGUI.results.iH(ibmx.preX,ibmx.preY);
%             
%             ibmx.tAx_ibmx = hGUI.results.iH_tAx(ibmx.ibmxX,ibmx.ibmxY);
%             ibmx.iH_ibmx = hGUI.results.iH(ibmx.ibmxX,ibmx.ibmxY);
%             
%             ibmx.tAx_post = hGUI.results.iH_tAx(ibmx.postX,ibmx.postY);
%             ibmx.iH_post = hGUI.results.iH(ibmx.postX,ibmx.postY);

            
            ibmx.pre = mean(hGUI.results.Data(ibmx.preX,1+ibmx.preY(1)/samplingInterval:ibmx.preY(2)/samplingInterval));
            ibmx.ibmx = mean(hGUI.results.Data(ibmx.ibmxX,1+ibmx.ibmxY(1)/samplingInterval:ibmx.ibmxY(2)/samplingInterval));
            ibmx.post = mean(hGUI.results.Data(ibmx.postX,1+ibmx.postY(1)/samplingInterval:ibmx.postY(2)/samplingInterval));
            
            ibmx.pre_sd = std(hGUI.results.Data(ibmx.preX,1+ibmx.preY(1)/samplingInterval:ibmx.preY(2)/samplingInterval));
            ibmx.ibmx_sd = std(hGUI.results.Data(ibmx.ibmxX,1+ibmx.ibmxY(1)/samplingInterval:ibmx.ibmxY(2)/samplingInterval));
            ibmx.post_sd = std(hGUI.results.Data(ibmx.postX,1+ibmx.postY(1)/samplingInterval:ibmx.postY(2)/samplingInterval));
            
            
            hGUI.results.ibmx = ibmx;

            
            if params.saveResults
               hGUI.lockButtonCall(); 
            end
            if ~params.silent
                hGUI.drawPlots();
            end
            
            
            
        end
        
        function drawPlots(hGUI,~,~)
            nV=hGUI.node.epochList.length;
            
            colors=pmkmp(nV,'CubicL');
            wcolors=whithen(colors,.5);
            tcolors=round(colors./1.2.*255);
            
            RowNames=cell(size(nV));
            for i=1:nV
                RowNames{i}=sprintf('<html><font color=rgb(%d,%d,%d)>Ep%d</font></html>',tcolors(i,1),tcolors(i,2),tcolors(i,3),i);
            end
                     
            tIn=struct;
            tIn.tag='infoTable';
            tIn.Position=[.01, .01, .12, .65];
            tIn.FontSize=10;
            tIn.ColumnWidth={50};
            tIn.Data=[hGUI.selected hGUI.ibmxFlag];
            tIn.ColumnName={'Selected','IBMX'};
            tIn.RowName=RowNames;
            tIn.headerWidth=30;
            tIn.CellEditCallback=@hGUI.updatePlots;
            hGUI.createTable(tIn);

            
            tIn2=struct;
            tIn2.tag='cellinfo';
            tIn2.Position=[.01, .80, .12, .18];
            tIn2.FontSize=10;
            tIn2.ColumnWidth={80};
            tIn2.Data=hGUI.getcellinfo(hGUI.node);
            tIn2.ColumnName={''};
            tIn2.RowName={'date','cellName','type','subtype','internal','organoid'};
            tIn2.headerWidth=80;
            tIn2.CellEditCallback=@hGUI.updatePlots;
            hGUI.createTable(tIn2);

            
            % buttons
%             hGUI.nextButton;
%             hGUI.prevButton;
            hGUI.lockButton(struct('Position',[.005 .71 .132 .04]));


            % plot creation
            p=struct;
            p.width=.80;
            p.half_width = .50;
            
            p.left=.180;
            p.left2 = p.left+p.half_width+.05;
            p.left3 = p.left2+p.half_width+.05;
            
            
            p.half_top1=.555;
            p.half_top2=.08;
            p.half_height=.43;
            
            
            p.third_top1=.06;
            p.third_top2=.380;
            p.third_top3=.650;
            p.third_height=.26;
            
            
            
            % iHold
            plotiH=struct('Position',[p.left p.third_top3 p.width p.third_height],'tag','plotiH');
            hGUI.createPlot(plotiH);
            hGUI.labelx(hGUI.gObj.plotiH,'Time (ms)');
            hGUI.labely(hGUI.gObj.plotiH,'i (pA)');
            
            % IBMX
            plotIBMX=struct('Position',[p.left .94 p.width .04],'tag','plotIBMX');
            hGUI.createPlot(plotIBMX);
%             hGUI.hidex(hGUI.gObj.plotIBMX);
%             hGUI.hidey(hGUI.gObj.plotIBMX);
            hGUI.hideAxis(hGUI.gObj.plotIBMX);
%             hGUI.labelx(hGUI.gObj.plotIBMX,'Time (ms)');
%             hGUI.labely(hGUI.gObj.plotIBMX,'i (pA)');
            
            % Data
            plotData = struct('Position',[p.left p.third_top1 p.half_width p.third_height*2],'tag','plotData');
            hGUI.createPlot(plotData);
            hGUI.labelx(hGUI.gObj.plotData,'Time (ms)');
            hGUI.labely(hGUI.gObj.plotData,'i (pA)');

            
            for i = 1:nV
                hGUI.plotErrorBar(hGUI.results.iH_tAx(i,:),hGUI.results.iH(i,:),hGUI.results.iH_sd(i,:),hGUI.gObj.plotiH,sprintf('Ep%g_iHsd',i),[.5 .5 .5]);
                
                lH=line(hGUI.results.iH_tAx(i,:),ones(size(hGUI.results.iH_tAx(i,:))),'Parent',hGUI.gObj.plotIBMX);
                hGUI.markerc_noFace(lH,[.5 .5 .5]);
                
                lH=line(hGUI.results.iH_tAx(i,:),hGUI.results.iH(i,:),'Parent',hGUI.gObj.plotiH);
                hGUI.markerc(lH,colors(i,:)); set(lH,'DisplayName',sprintf('Ep%g_iH',i));
                if hGUI.node.epochList.valueByIndex(i).keywords.contains('IBMX')
                   set(lH,'Color',[0 0 0]);
                   
                   lH=line(hGUI.results.iH_tAx(i,:),ones(size(hGUI.results.iH_tAx(i,:))),'Parent',hGUI.gObj.plotIBMX);
                   hGUI.markerc(lH,[0 0 0]);
                end
                
                lH=line(hGUI.results.tAx,hGUI.results.Data(i,:),'Parent',hGUI.gObj.plotData);
                hGUI.linec(lH,colors(i,:));set(lH,'DisplayName',sprintf('Data%g',i));
            end
              
            tempLim = get(hGUI.gObj.plotData,'ylim');
            hGUI.ylim(hGUI.gObj.plotData,[tempLim(1) 0]);
            
            
            % Collected Data
            plotPharm = struct('Position',[p.left2 p.third_top1 0.25 p.third_height*2],'tag','plotPharm');
            hGUI.createPlot(plotPharm);
            hGUI.labelx(hGUI.gObj.plotPharm,'');
            hGUI.labely(hGUI.gObj.plotPharm,'i (pA)');
            hGUI.xlim(hGUI.gObj.plotPharm,[0.5 3]);
            
            hGUI.plotErrorBar(1,hGUI.results.ibmx.pre,hGUI.results.ibmx.pre_sd,hGUI.gObj.plotPharm,'preSD',[0 0 0]);
            hGUI.plotErrorBar(2,hGUI.results.ibmx.ibmx,hGUI.results.ibmx.ibmx_sd,hGUI.gObj.plotPharm,'ibmxSD',[0 0 0]);
            hGUI.plotErrorBar(3,hGUI.results.ibmx.post,hGUI.results.ibmx.post_sd,hGUI.gObj.plotPharm,'postSD',[0 0 0]);
            
            
            lH=line(1,hGUI.results.ibmx.pre,'Parent',hGUI.gObj.plotPharm);
            hGUI.markerc(lH,[0 0 0]); set(lH,'DisplayName',sprintf('pre'));
            
            lH=line(2,hGUI.results.ibmx.ibmx,'Parent',hGUI.gObj.plotPharm);
            hGUI.markerc(lH,[0 0 0]); set(lH,'DisplayName',sprintf('ibmx'));
            
            lH=line(3,hGUI.results.ibmx.post,'Parent',hGUI.gObj.plotPharm);
            hGUI.markerc(lH,[0 0 0]); set(lH,'DisplayName',sprintf('post'));
            
%             tempLim = get(hGUI.gObj.plotPharm,'ylim');
%             hGUI.ylim(hGUI.gObj.plotPharm,[tempLim(1) 0]);
            
            hGUI.updatePlots;
            
            

        end
        
        function updatePlots(hGUI,~,~)
            
            infoData = hGUI.gObj.infoTable.Data;
            hGUI.selected = infoData(:,1);
            nV=hGUI.node.epochList.length;
            
            for i = 1:nV
                iName = sprintf('Ep%g_iH',i);
                dName = sprintf('Data%g',i);
                if hGUI.selected(i)
                    hGUI.showTrace(iName);
                    hGUI.showTrace(dName);
                else
                    hGUI.hideTrace(iName);
                    hGUI.hideTrace(dName);
                end
            end
            
            if sum(hGUI.selected)>1
                hGUI.xlim(hGUI.gObj.plotiH,[hGUI.results.iH_tAx(find(hGUI.selected==1,1,'first'),1)-1 hGUI.results.iH_tAx(find(hGUI.selected==1,1,'last'),end)+1]);
            end
                hGUI.xlim(hGUI.gObj.plotIBMX,get(hGUI.gObj.plotiH,'xlim'));
            
        end
        
        function lockButtonCall(hGUI,~,~)
            hGUI.disableGui;
            hGUI.node.custom.put('results',riekesuite.util.toJavaMap(hGUI.results));
            fprintf('%s: saved results\n',getcellname(hGUI.node))
            hGUI.enableGui;
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
            cellInfo{6}=pSet.get('source:parent:parent:label');
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
        
        
    end
end
