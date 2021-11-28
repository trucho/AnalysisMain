classdef fit_monoClark_sine_allClamped < ephysGUI
    properties
        
        coeffs = [65]; % coeffs for best fit to stj
        guesscoeffs = [65]; % manual fit

        
%         > Fred Rieke: Sep4th, 2020
%             Here are estimates of dark currents for since cells.  
%             These are approximate as I did not always record a saturating flash at the start.
%                 c1: 110 pA
%                 c2: 115 pA
%                 c3: 160 pA
%                 c4: skip
%                 c5: 150 pA
%                 c6: 125 pA
%                 c7: 150 pA
        
        ib
        ib_lo = 1;
        ib_hi = 4.7;
        n = 100;
        nS
        colors
        padpts = 4000;
        
        prepts
        stmpts
        tailpts
        
        tme
        stm
        dt
        
        ib_example = 10000;
        
        modelFx
        modelResponses
        modelManualTimeCorrection = -0.05;
        modelColor = [077 221 169]./255
        
        modelRatio
        mu
        muAbove
        muBelow
        
        modelRatio_Ex
        mu_Ex
        muAbove_Ex
        muBelow_Ex
        
        coneRatio
        coneIbs
        coneExData
        coneExTme
        coneExStim
        coneExInd = 7
        coneExFit
        
        fit
    end
    
    methods
        
        function hGUI=fit_monoClark_sine_allClamped(fign)
            % INITIALIZATION
            if nargin == 0
                fign=10;
            end
            hGUI@ephysGUI(fign);
            
            set(hGUI.figH,'KeyPressFcn',@hGUI.detectKey);
            
            % initialize properties
            hGUI.modelFx =  @hGUI.cmodel;
            hGUI.ib = logspace(hGUI.ib_lo,hGUI.ib_hi,hGUI.n);
            hGUI.colors = pmkmp(hGUI.n,'CubicL');
            
            sineStim = load('/Users/angueyraaristjm/matlab/AnalysisMain/ConeAnalysis/ClarkModel/sineStim.mat');
            sineStim = sineStim.sineStim;
            hGUI.tme = sineStim.tAx;
            hGUI.dt = sineStim.dt;
            hGUI.stm = sineStim.stm;
            hGUI.stm = hGUI.stm.*hGUI.dt; % for clark models only
            hGUI.prepts = sineStim.prepts;
            hGUI.stmpts = sineStim.stmpts;
            hGUI.tailpts = sineStim.tailpts;
            hGUI.nS = size(hGUI.stm,1);
            
            hGUI.createData;
            hGUI.createObjects;
        end
        
        function createData(hGUI,~,~)
            hGUI.modelResponses = NaN(hGUI.n,length(hGUI.tme));
            
            % for standard model (using coeffs)
            hGUI.modelRatio = NaN(1,hGUI.n);
            hGUI.mu = NaN(1,hGUI.n);
            hGUI.muAbove = NaN(1,hGUI.n);
            hGUI.muBelow = NaN(1,hGUI.n);
            
            
            for i = 1:hGUI.n
                tempmu = NaN(1,hGUI.nS);
                tempmuAbove = NaN(1,hGUI.nS);
                tempmuBelow = NaN(1,hGUI.nS);
                tempRatio = NaN(1,hGUI.nS);
                for s = 1:hGUI.nS
                    tempstm=[ones(1,hGUI.padpts)*hGUI.stm(s,1)*hGUI.ib(i) hGUI.stm(s,:)*hGUI.ib(i)]; %padding
                    temptme=(1:1:length(tempstm))* hGUI.dt;
                    tempfit=hGUI.modelFx(hGUI.coeffs,temptme,tempstm,hGUI.dt,0);
                    tempfit = tempfit(hGUI.padpts+1:end);
                    
                    tempmu(s) = mean(tempfit(1:hGUI.prepts));
                    
                    %% OPTION 1: use similar strategy than binary noise (mean above/mean below)
                    %                     muAbove_ind= tempfit>tempmu(s);
                    %                     muAbove_ind(1:hGUI.prepts) = 0; muAbove_ind(hGUI.prepts+hGUI.stmpts:end) = 0;
                    %                     muBelow_ind= tempfit<tempmu(s);
                    %                     muBelow_ind(1:hGUI.prepts) = 0; muBelow_ind(hGUI.prepts+hGUI.stmpts:end) = 0;
                    %
                    %                     tempmuAbove(s) = mean(tempfit(muAbove_ind));
                    %                     tempmuBelow(s) = mean(tempfit(muBelow_ind));
                    
                    %% OPTION 2: peak to peak
%                     tempmuAbove(s) = max(tempfit(hGUI.prepts:hGUI.prepts+hGUI.stmpts));
%                     tempmuBelow(s) = min(tempfit(hGUI.prepts:hGUI.prepts+hGUI.stmpts));
%                     
%                     
%                     tempRatio(s) = (abs(tempmuBelow(s) - tempmu(s)) / abs(tempmuAbove(s) - tempmu(s))); % Ratio
                    %% OPTION 3: min/max
%                     temptempfit = tempfit(hGUI.prepts*1.5:hGUI.prepts+hGUI.stmpts) - mean(tempfit(1:hGUI.prepts));
%                     tempmuAbove(s) = max(temptempfit);
%                     tempmuBelow(s) = -min(temptempfit);
%                     
%                     
%                     tempRatio(s) = tempmuBelow(s) / tempmuAbove(s); % Ratio
                    
                    %% OPTION 4: do the same as cone data: 1% percentiles
                    temptempfit = tempfit(hGUI.prepts*1.5:hGUI.prepts+hGUI.stmpts) - mean(tempfit(1:hGUI.prepts));
                    tempmuAbove(s) = mean(temptempfit(temptempfit>prctile(temptempfit,99)));
                    
                    tempmuBelow(s) = mean(temptempfit(temptempfit<prctile(temptempfit,1)));
                    
                    
                    tempRatio(s) = -tempmuBelow(s) / tempmuAbove(s); % Ratio
                end

                % only saving last modelResponse
                hGUI.modelResponses(i,:)=tempfit;
                
                hGUI.mu(i) = mean(tempmu);
                
                hGUI.muAbove(i) = mean(tempmuAbove);
                hGUI.muBelow(i) = mean(tempmuBelow);
                
                hGUI.modelRatio(i) = mean(tempRatio);
                
            end
            
            % for example cell model (using guesscoeffs)
            hGUI.modelRatio_Ex = NaN(1,hGUI.n);
            hGUI.mu_Ex = NaN(1,hGUI.n);
            hGUI.muAbove_Ex = NaN(1,hGUI.n);
            hGUI.muBelow_Ex = NaN(1,hGUI.n);
            
            for i = 1:hGUI.n
                tempmu = NaN(1,hGUI.nS);
                tempmuAbove = NaN(1,hGUI.nS);
                tempmuBelow = NaN(1,hGUI.nS);
                tempRatio = NaN(1,hGUI.nS);
                for s = 1:hGUI.nS
                    tempstm=[ones(1,hGUI.padpts)*hGUI.stm(s,1)*hGUI.ib(i) hGUI.stm(s,:)*hGUI.ib(i)]; %padding
                    temptme=(1:1:length(tempstm))* hGUI.dt;
                    tempfit=hGUI.modelFx(hGUI.guesscoeffs,temptme,tempstm,hGUI.dt,0);
                    tempfit = tempfit(hGUI.padpts+1:end);
                    
                    tempmu(s) = mean(tempfit(1:hGUI.prepts));
                    
                    %% OPTION 1: use similar strategy than binary noise (mean above/mean below)
                    %                     muAbove_ind= tempfit>tempmu(s);
                    %                     muAbove_ind(1:hGUI.prepts) = 0; muAbove_ind(hGUI.prepts+hGUI.stmpts:end) = 0;
                    %                     muBelow_ind= tempfit<tempmu(s);
                    %                     muBelow_ind(1:hGUI.prepts) = 0; muBelow_ind(hGUI.prepts+hGUI.stmpts:end) = 0;
                    %
                    %                     tempmuAbove(s) = mean(tempfit(muAbove_ind));
                    %                     tempmuBelow(s) = mean(tempfit(muBelow_ind));
                    
                    %% OPTION 2: peak to peak
%                     tempmuAbove(s) = max(tempfit(hGUI.prepts:hGUI.prepts+hGUI.stmpts));
%                     tempmuBelow(s) = min(tempfit(hGUI.prepts:hGUI.prepts+hGUI.stmpts));
%                     
%                     
%                     tempRatio(s) = (abs(tempmuBelow(s) - tempmu(s)) / abs(tempmuAbove(s) - tempmu(s))); % Ratio
                    %% OPTION 3: min/max
%                     temptempfit = tempfit(hGUI.prepts*1.5:hGUI.prepts+hGUI.stmpts) - mean(tempfit(1:hGUI.prepts));
%                     tempmuAbove(s) = max(temptempfit);
%                     tempmuBelow(s) = -min(temptempfit);
%                     
%                     
%                     tempRatio(s) = tempmuBelow(s) / tempmuAbove(s); % Ratio
                    
                    %% OPTION 4: do the same as cone data: 1% percentiles
                    temptempfit = tempfit(hGUI.prepts*1.5:hGUI.prepts+hGUI.stmpts) - mean(tempfit(1:hGUI.prepts));
                    tempmuAbove(s) = mean(temptempfit(temptempfit>prctile(temptempfit,99)));
                    
                    tempmuBelow(s) = mean(temptempfit(temptempfit<prctile(temptempfit,1)));
                    
                    
                    tempRatio(s) = -tempmuBelow(s) / tempmuAbove(s); % Ratio
                end

                
                hGUI.mu_Ex(i) = mean(tempmu);
                
                hGUI.muAbove_Ex(i) = mean(tempmuAbove);
                hGUI.muBelow_Ex(i) = mean(tempmuBelow);
                
                hGUI.modelRatio_Ex(i) = mean(tempRatio);
                
            end
            
            hGUI.loadConeData();
        end
        
        function loadConeData(hGUI,~,~)
            ConeSineResps = load('/Users/angueyraaristjm/matlab/AnalysisMain/ConeAnalysis/ClarkModel/ConeSineResps.mat');
            ConeSineResps = ConeSineResps.ConeSineResps;

            nIbs = size(ConeSineResps,2);
            nCones = size(ConeSineResps{1}.Responses,1);
            hGUI.coneIbs = NaN(nIbs,nCones);
            hGUI.coneRatio = NaN(nIbs,nCones);
            for i=1:nIbs
                for j = 1:nCones
                    currR = ConeSineResps{i}.Responses(j,:);
                    indUp = currR>prctile(currR,99);
                    indDown = currR<prctile(currR,1);

                    hGUI.coneRatio(i,j) = abs(mean(currR(indDown))./mean(currR(indUp)));
                    hGUI.coneIbs(i,j) = ConeSineResps{i}.MeanIntensity;
                    if j ==hGUI.coneExInd
                        hGUI.coneExData(i,:) = currR;
                    end
                end
            end
            hGUI.coneExTme = (0:length(currR)-1)*1e-4;
            hGUI.coneExStim = zeros(size(hGUI.coneExTme));
            hGUI.coneExStim(2501:end-2500) = sin(2*pi*2.5*hGUI.coneExTme(1:end-5000));
%             hGUI.coneExStim() = ; 
%             keyboard
%             %%
%                             tAx = (0:length(ConeSineResps{1}.Responses)-1)*1e-4;
%                             f2 = getfigH(2);
%                             for i=1:4
%                             for j = 5%:nCones
%                                 currR = ConeSineResps{i}.Responses(j,:);
%                                 indUp = currR>prctile(currR,95);
%                                 indDown = currR<prctile(currR,5);
%                                 lH=lineH(tAx,currR,f2);
%                                 lH.line;lH.setName('coneResp');
% 
%                                 lH=lineH(tAx(indUp),currR(indUp),f2);
%                                 lH.markers;lH.color([1 0 0]);lH.setName('peaksUp');
% 
%                                 lH=lineH(tAx(indDown),currR(indDown),f2);
%                                 lH.markers;lH.color([1 0 1]);lH.setName('peaksDown');
%                             end
%                             end
            
                            
        end
        
        
        function createObjects(hGUI,~,~)
            % GRAPHS
            h1 = 200;
            h2 = 350;
            h3 = 250;
            h4 = 110;
            w1 = 500;
            w2 = 275;
            w3 = 200;
            l1 = 230;
            l2 = l1+w2+45;
            l3 = l1+w1+45;
            t1 = 780;
            t2 = 390;
            t3 = 50;
            
            
            % stim
            hGUI.createPlot(struct('Position',[l1 t1 w1 h1]./1000,'tag','p_stim'));
            hGUI.hidex(hGUI.gObj.p_stim)
            hGUI.labely(hGUI.gObj.p_stim,'R*/s')
            hGUI.xlim(hGUI.gObj.p_stim,hGUI.minmax(hGUI.tme))
            %             hGUI.ylim(hGUI.gObj.p_stim,hGUI.minmax(hGUI.sf_stm)./hGUI.dt)
            
            lH=lineH(hGUI.tme+hGUI.modelManualTimeCorrection,hGUI.stm(end,:),hGUI.gObj.p_stim);
            lH.linek;lH.setName('stim_s');lH.h.LineWidth=2;
            
            %             for i=1:hGUI.nf
            %                 lH=lineH(hGUI.tme,hGUI.sf_stm(i,:)/hGUI.dt,hGUI.gObj.p_stim);
            %                 lH.line;lH.color(hGUI.pcolors(i,:));lH.setName(sprintf('stim_f%02g',i));lH.h.LineWidth=1;
            %             end
            
            
            
            % responses
            hGUI.createPlot(struct('Position',[l1 t2 w1 h2]./1000,'tag','p_resp'));
            hGUI.labelx(hGUI.gObj.p_resp,'Time (s)')
            hGUI.labely(hGUI.gObj.p_resp,'i (pA)')
            hGUI.xlim(hGUI.gObj.p_resp,hGUI.minmax(hGUI.tme))
            %             hGUI.ylim(hGUI.gObj.p_resp,[-10 80])
            for i = 1:hGUI.n%hGUI.n:-1:1
                lH = lineH(hGUI.tme,hGUI.modelResponses(i,:),hGUI.gObj.p_resp);
                lH.color(hGUI.colors(i,:));lH.h.LineWidth=2;
            end
            
            % vertical limits
            lH=lineH([hGUI.prepts hGUI.prepts].*hGUI.dt,[min(hGUI.modelResponses(1,1:hGUI.prepts))*1.05 0],hGUI.gObj.p_resp);
            lH.linedash;lH.setName('vLine01');lH.h.LineWidth=2;
            
            lH=lineH([hGUI.prepts+hGUI.stmpts hGUI.prepts+hGUI.stmpts].*hGUI.dt,[min(hGUI.modelResponses(1,1:hGUI.prepts))*1.05 0],hGUI.gObj.p_resp);
            lH.linedash;lH.setName('vLine02');lH.h.LineWidth=2;
            
            % steady-state current vs ib
            hGUI.createPlot(struct('Position',[l1 t3 w2 h3]./1000,'tag','p_ssi'));
            hGUI.labelx(hGUI.gObj.p_ssi,'Ib (R*/s)')
            hGUI.labely(hGUI.gObj.p_ssi,'i (pA)')
            hGUI.gObj.p_ssi.XScale='log';
            %             hGUI.xlim(hGUI.gObj.p_resp,hGUI.minmax(hGUI.tme))
            %             hGUI.ylim(hGUI.gObj.p_resp,[-10 80])
            
            
            lH = lineH(hGUI.ib,hGUI.mu,hGUI.gObj.p_ssi);
            lH.linedash;
            
            for i = hGUI.n:-1:1
                lH = lineH(hGUI.ib(i),hGUI.mu(i),hGUI.gObj.p_ssi);
                lH.markers;lH.color(hGUI.colors(i,:));
            end
            
            % on/off ratio vs ib
            hGUI.createPlot(struct('Position',[l2 t3 w2 h3]./1000,'tag','p_ratio'));
            hGUI.labelx(hGUI.gObj.p_ratio,'Ib (R*/s)')
            hGUI.labely(hGUI.gObj.p_ratio,'Asymmetry Ratio')
            hGUI.gObj.p_ratio.XScale='log';
            %             hGUI.xlim(hGUI.gObj.p_resp,hGUI.minmax(hGUI.tme))
            %             hGUI.ylim(hGUI.gObj.p_resp,[-10 80])
            
            lH = lineH(hGUI.ib,hGUI.modelRatio,hGUI.gObj.p_ratio);
            lH.linedash;lH.setName('modelRatio');
            lH = lineH(hGUI.ib,hGUI.modelRatio_Ex,hGUI.gObj.p_ratio);
            lH.linedash;lH.setName('modelRatioEx');
            
            for i = hGUI.n:-1:1
                lH = lineH(hGUI.ib(i),hGUI.modelRatio(i),hGUI.gObj.p_ratio);
                lH.markers;lH.color(hGUI.colors(i,:));lH.setName(sprintf('mR_%g',round(hGUI.ib(i))));
            end
            
             lH = lineH(hGUI.coneIbs(:,[1,2,3,5,6,7]),hGUI.coneRatio(:,[1,2,3,5,6,7]),hGUI.gObj.p_ratio);
             lH.markers;lH.color([.75,.75,.75]);lH.setName('coneRatio_All');

%             thiscolors = pmkmp(size(hGUI.coneIbs,2),'IsoL');
%             for i = [1,2,3,5,6,7]%1:size(hGUI.coneIbs,2)
%                 lH = lineH(hGUI.coneIbs(:,i),hGUI.coneRatio(:,i),hGUI.gObj.p_ratio);
%                 lH.linemarkers;lH.color(thiscolors(i,:));lH.setName(sprintf('coneRatio_Ex%g',i));
%             end
            
            lH = lineH(hGUI.coneIbs(:,hGUI.coneExInd),hGUI.coneRatio(:,hGUI.coneExInd),hGUI.gObj.p_ratio);
            lH.markers;lH.color([0,0,0]);lH.setName('coneRatio_ExampleCell');
            
            lH = lineH(hGUI.minmax(hGUI.ib),[1 1],hGUI.gObj.p_ratio);
            lH.linedash;lH.color([.75,.75,.75]);lH.setName('uLine');
            
            % example cell responses
            hGUI.createPlot(struct('Position',[l3 t1+(h4+50) w3 h4/2]./1000,'tag','p_exStim'));
            hGUI.xlim(hGUI.gObj.p_exStim,[0,2.5])
%             hGUI.ylim(hGUI.gObj.p_exResp01,[-70 40])
            
            lH = lineH(hGUI.coneExTme,hGUI.coneExStim,hGUI.gObj.p_exStim);
            lH.linek;lH.h.LineWidth=2;
            
            hGUI.createPlot(struct('Position',[l3 t1-(h4+50)*0 w3 h4]./1000,'tag','p_exResp01'));
            hGUI.xlim(hGUI.gObj.p_exResp01,[0,2.5])
            hGUI.ylim(hGUI.gObj.p_exResp01,[-70 40])
            
            lH = lineH(hGUI.coneExTme,hGUI.coneExData(1,:),hGUI.gObj.p_exResp01);
            lH.linek;lH.h.LineWidth=2;lH.setName('Resp');
            
            tempstm=[ones(1,hGUI.padpts)*hGUI.coneIbs(1,1) (1+hGUI.coneExStim)*hGUI.coneIbs(1,1)]; %padding
            tempstm=tempstm*hGUI.dt; % for clrak models only
            temptme=(1:1:length(tempstm))* hGUI.dt;
            tempfit=hGUI.modelFx(hGUI.guesscoeffs,temptme,tempstm,hGUI.dt,0);
            tempfit = BaselineSubtraction(tempfit(hGUI.padpts+1:end),1,10);
            hGUI.coneExFit(1,:) = tempfit;
            
            lH = lineH(hGUI.coneExTme+hGUI.modelManualTimeCorrection,tempfit,hGUI.gObj.p_exResp01);
            lH.liner;lH.h.LineWidth=2;lH.setName('Model');
            lH.color(hGUI.modelColor);
            
            hGUI.createPlot(struct('Position',[l3 t1-(h4+50)*1 w3 h4]./1000,'tag','p_exResp02'));
            hGUI.xlim(hGUI.gObj.p_exResp02,[0,2.5])
            hGUI.ylim(hGUI.gObj.p_exResp02,[-70 40])
            
            lH = lineH(hGUI.coneExTme,hGUI.coneExData(2,:),hGUI.gObj.p_exResp02);
            lH.linek;lH.h.LineWidth=2;lH.setName('Resp');
            
            tempstm=[ones(1,hGUI.padpts)*hGUI.coneIbs(2,1) (1+hGUI.coneExStim)*hGUI.coneIbs(2,1)]; %padding
            tempstm=tempstm*hGUI.dt; % for clrak models only
            temptme=(1:1:length(tempstm))* hGUI.dt;
            tempfit=hGUI.modelFx(hGUI.guesscoeffs,temptme,tempstm,hGUI.dt,0);
            tempfit = BaselineSubtraction(tempfit(hGUI.padpts+1:end),1,10);
            hGUI.coneExFit(2,:) = tempfit;
            
            lH = lineH(hGUI.coneExTme+hGUI.modelManualTimeCorrection,tempfit,hGUI.gObj.p_exResp02);
            lH.liner;lH.h.LineWidth=2;lH.setName('Model');
            lH.color(hGUI.modelColor);
            
            hGUI.createPlot(struct('Position',[l3 t1-(h4+50)*2 w3 h4]./1000,'tag','p_exResp03'));
            hGUI.xlim(hGUI.gObj.p_exResp03,[0,2.5])
            hGUI.ylim(hGUI.gObj.p_exResp03,[-70 40])
            
            lH = lineH(hGUI.coneExTme,hGUI.coneExData(3,:),hGUI.gObj.p_exResp03);
            lH.linek;lH.h.LineWidth=2;lH.setName('Resp');
            
            
            tempstm=[ones(1,hGUI.padpts)*hGUI.coneIbs(3,1) (1+hGUI.coneExStim)*hGUI.coneIbs(3,1)]; %padding
            tempstm=tempstm*hGUI.dt; % for clrak models only
            temptme=(1:1:length(tempstm))* hGUI.dt;
            tempfit=hGUI.modelFx(hGUI.guesscoeffs,temptme,tempstm,hGUI.dt,0);
            tempfit = BaselineSubtraction(tempfit(hGUI.padpts+1:end),1,10);
            hGUI.coneExFit(3,:) = tempfit;
            
            lH = lineH(hGUI.coneExTme+hGUI.modelManualTimeCorrection,tempfit,hGUI.gObj.p_exResp03);
            lH.liner;lH.h.LineWidth=2;lH.setName('Model');
            lH.color(hGUI.modelColor);
            
            hGUI.createPlot(struct('Position',[l3 t1-(h4+50)*3 w3 h4]./1000,'tag','p_exResp04'));
            hGUI.xlim(hGUI.gObj.p_exResp04,[0,2.5])
            hGUI.ylim(hGUI.gObj.p_exResp04,[-70 40])
            
            lH = lineH(hGUI.coneExTme,hGUI.coneExData(4,:),hGUI.gObj.p_exResp04);
            lH.linek;lH.h.LineWidth=2;lH.setName('Resp');
            
            tempstm=[ones(1,hGUI.padpts)*hGUI.coneIbs(4,1) (1+hGUI.coneExStim)*hGUI.coneIbs(4,1)]; %padding
            tempstm=tempstm*hGUI.dt; % for clrak models only
            temptme=(1:1:length(tempstm))* hGUI.dt;
            tempfit=hGUI.modelFx(hGUI.guesscoeffs,temptme,tempstm,hGUI.dt,0);
            tempfit = BaselineSubtraction(tempfit(hGUI.padpts+1:end),1,10);
            hGUI.coneExFit(4,:) = tempfit;
            
            lH = lineH(hGUI.coneExTme+hGUI.modelManualTimeCorrection,tempfit,hGUI.gObj.p_exResp04);
            lH.liner;lH.h.LineWidth=2;lH.setName('Model');
            lH.color(hGUI.modelColor);
        end
        
        function runLSQ(hGUI,~,~)
           % least-squares fitting
           
           fprintf('Started lsq fitting.....\n')
           LSQ = struct;
           i2use = 1;
           lsqstm = (1+hGUI.coneExStim) *hGUI.coneIbs(i2use,1) * hGUI.dt;
           LSQ.ydata=hGUI.coneExData(i2use,:);%-prctile(hGUI.exData(i2use,:),3);
           lsqfun=@(optcoeffs,tme)hGUI.modelFx(optcoeffs,hGUI.coneExTme,lsqstm,hGUI.dt);
           
%            keyboard
           LSQ.lb=[0 0 0];
           LSQ.ub=[1000 1000 1000];
           LSQ.objective=lsqfun;
           LSQ.x0=hGUI.coeffs;
           LSQ.xdata=hGUI.coneExTme+hGUI.modelManualTimeCorrection;

           
           LSQ.solver='lsqcurvefit';
           LSQ.options=optimset('TolX',1e-20,'TolFun',1e-20,'MaxFunEvals',500);
           hGUI.fit=lsqcurvefit(LSQ);
           disp(round(hGUI.fit));
           
           
           
       end
        
        function sineRatio = saveCurveForAsymmetryPlot(hGUI,~,~)
            sineRatio = struct;
            sineRatio.ib = hGUI.ib;
            sineRatio.mu = hGUI.mu;
            sineRatio.muAbove = hGUI.muAbove;
            sineRatio.muBelow = hGUI.muBelow;
            sineRatio.ratio = hGUI.modelRatio;
            exInd = find(hGUI.ib>=hGUI.ib_example,1,'first');
            sineRatio.ex_ib = hGUI.ib(exInd);
            sineRatio.ex_tme = hGUI.tme;
            sineRatio.ex_stm = hGUI.stm*sineRatio.ex_ib;
            sineRatio.ex_model = hGUI.modelResponses(exInd,:);
            
            sineRatio.coneibs = hGUI.coneIbs;
            sineRatio.coneRatio = hGUI.coneRatio;
        end
    end
    
    methods (Static=true)
        function [ios]=cmodel(coeffs,time,stim,dt, verboseflag)
           ios = cModelUni_allclamped(coeffs,time,stim,dt,verboseflag);
           ios = ios * 150/136;
       end

    end
    
end
