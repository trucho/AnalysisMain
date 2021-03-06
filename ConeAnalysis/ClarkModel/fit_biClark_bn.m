classdef fit_biClark_bn < ephysGUI
    % main difference between models is that clark models require stim in R*/dt and does not have a holding current.
    
    properties

        coeffs = [0500,0205,0312,146]; % coeffs for best fit to stj
        
%         % just guessing
%         guesscoeffs = [...
%             448,194,360;...
%             448,124,360;...
%             448,94,360;...
%             ];
        
        % from lsq fit
        guesscoeffs = [...
            0500,02050,03120,146;...
            721,880,1700,60;... 1069,88,128;...
            599,770,1800,50;...299,77,280,46;...
            ];
        
        ib
        ib_lo = 1;
        ib_hi = 4.9;%5.6;
        n = 100;
        nS
        colors
        padpts = 10000;
        
        prepts = 10000;
        stmpts = 60000;
        tailpts = 20000;
        
        tme
        stm
        dt
        
        exTime
        exData
        exStim
        exdt
        exModel
        
        modelFx
        modelResponses
        fit
        
        modelRatio
        mu
        muAbove
        muBelow
        
        modelRatio_Ex
        mu_Ex
        muAbove_Ex
        muBelow_Ex
    end
    
    methods
        
        function hGUI=fit_biClark_bn(fign)
            % INITIALIZATION
            if nargin == 0
                fign=10;
            end
            hGUI@ephysGUI(fign);
            
            set(hGUI.figH,'KeyPressFcn',@hGUI.detectKey);
            
            % initialize properties
            hGUI.modelFx = @cModelBi_clamped;
            hGUI.ib = logspace(hGUI.ib_lo,hGUI.ib_hi,hGUI.n);
            hGUI.colors = pmkmp(hGUI.n,'CubicL');
            
            %load single stimulus and do calculation based on this one
            bnStim = load('/Users/angueyraaristjm/matlab/AnalysisMain/ConeAnalysis/ClarkModel/bnStimExample.mat');
            bnStim = bnStim.bnStim;
            hGUI.tme = bnStim.tAx;
            hGUI.dt = hGUI.tme(2) - hGUI.tme(1);
            hGUI.stm = bnStim.stim(:,:);
            hGUI.stm = hGUI.stm.*hGUI.dt;
            hGUI.nS = size(hGUI.stm,1);
            
            % load all data for example cell (there are 50% contrast traces at 160k R*/s
            BinaryEx = load('/Users/angueyraaristjm/matlab/AnalysisMain/ConeAnalysis/ClarkModel/BinaryEx.mat');
            BinaryEx = BinaryEx.BinaryEx;
            % seems like dark holding current is ~-168pA
            
            
            %let's try to see how vanHat model does to first response at 50k R*/s, while guessing opsinGain
            hGUI.exTime = BinaryEx.TimeAxis;
            hGUI.exdt = BinaryEx.TimeAxis(2)-BinaryEx.TimeAxis(1);
            exI = [2,1,1];
            hGUI.exData(1,:) = BinaryEx.Data10k(exI(1),:);
            
            hGUI.exStim(1,:) = BinaryEx.Stim10k(exI(1),:);
            hGUI.exStim(1,:) = hGUI.exStim(1,:)*10000/hGUI.exStim(1,1); %not sure about the units here. Should be that background is 10k, so converting to that
            
            hGUI.exData(2,:) = BinaryEx.Data50k(exI(2),:);
            
            hGUI.exStim(2,:) = BinaryEx.Stim50k(exI(2),:);
            hGUI.exStim(2,:) = hGUI.exStim(2,:)*50000/hGUI.exStim(2,1); %not sure about the units here. Should be that background is 10k, so converting to that
            
            hGUI.exData(3,:) = BinaryEx.Data160k(exI(3),:);
            hGUI.exStim(3,:) = BinaryEx.Stim160k(exI(3),:);
            hGUI.exStim(3,:) = hGUI.exStim(3,:)*160000/hGUI.exStim(3,1); %not sure about the units here. Should be that background is 10k, so converting to that
            
            
            hGUI.exStim = hGUI.exStim * hGUI.exdt;
            
%             hGUI.runLSQ;
            
            for i = 1:3
                tempstm=[ones(1,hGUI.padpts)*hGUI.exStim(i,1) hGUI.exStim(i,:)]; %padding
                temptme=(1:1:length(tempstm))* hGUI.exdt;
                tempfit=hGUI.modelFx(hGUI.guesscoeffs(i,:),temptme,tempstm,hGUI.exdt,0);
                hGUI.exModel(i,:) = tempfit(hGUI.padpts+1:end);
            end
            
            % subtracting baseline and adjusting to model baseline current
            hGUI.exData(1,:) = BaselineSubtraction(hGUI.exData(1,:),1,500) + mean(hGUI.exModel(1,1:500));
            hGUI.exData(2,:) = BaselineSubtraction(hGUI.exData(2,:),1,500) + mean(hGUI.exModel(2,1:500));
            hGUI.exData(3,:) = BaselineSubtraction(hGUI.exData(3,:),1,500) + mean(hGUI.exModel(3,1:500));
            
            
            hGUI.createData;
            hGUI.createObjects;
        end
        
        
        function runLSQ(hGUI,~,~)
           % least-squares fitting
           
           fprintf('Started lsq fitting.....\n')
           LSQ = struct;
           i2use = 2;
           LSQ.ydata=hGUI.exData(i2use,:)-prctile(hGUI.exData(i2use,:),3);
           lsqfun=@(optcoeffs,tme)hGUI.modelFx(optcoeffs,hGUI.exTime,hGUI.exStim(i2use,:),hGUI.exdt);
                    
           LSQ.lb=[0 0 0 0];
           LSQ.ub=[];
           LSQ.objective=lsqfun;
           LSQ.x0=hGUI.guesscoeffs(i2use,:);
           LSQ.xdata=hGUI.exTime;

           
           LSQ.solver='lsqcurvefit';
           LSQ.options=optimset('TolX',1e-20,'TolFun',1e-20,'MaxFunEvals',500);
           hGUI.fit=lsqcurvefit(LSQ);
           disp(round(hGUI.fit));
           
           
           
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
                    tempstm=[ones(1,hGUI.padpts)*hGUI.stm(s,1)*hGUI.ib(i) hGUI.stm(s,:)*hGUI.ib(i)]; %padding + already multiplied stm by dt
                    temptme=(1:1:length(tempstm))* hGUI.dt;
                    tempfit=hGUI.modelFx(hGUI.coeffs,temptme,tempstm,hGUI.dt,0);
                    tempfit = tempfit(hGUI.padpts+1:end);
                    
                    tempmu(s) = mean(tempfit(1:hGUI.prepts));
                    muAbove_ind= tempfit>tempmu(s);
                    muAbove_ind(1:hGUI.prepts) = 0; muAbove_ind(hGUI.prepts+hGUI.stmpts:end) = 0; 
                    muBelow_ind= tempfit<tempmu(s);
                    muBelow_ind(1:hGUI.prepts) = 0; muBelow_ind(hGUI.prepts+hGUI.stmpts:end) = 0; 

                    tempmuAbove(s) = mean(tempfit(muAbove_ind));
                    tempmuBelow(s) = mean(tempfit(muBelow_ind));

                    tempRatio(s) = (abs(tempmuBelow(s) - tempmu(s)) / abs(tempmuAbove(s) - tempmu(s))); % Ratio
                end
                
                % only saving last modelResponse
                hGUI.modelResponses(i,:)=tempfit;
                
                hGUI.mu(i) = mean(tempmu);
                            
                hGUI.muAbove(i) = mean(tempmuAbove);
                hGUI.muBelow(i) = mean(tempmuBelow);
                
                hGUI.modelRatio(i) = mean(tempRatio);
                
            end
            
            % for example cell fit model (using guesscoeffs i2use)
            i2use = 2;
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
                    tempstm=[ones(1,hGUI.padpts)*hGUI.stm(s,1)*hGUI.ib(i) hGUI.stm(s,:)*hGUI.ib(i)]; %padding + already multiplied stm by dt
                    temptme=(1:1:length(tempstm))* hGUI.dt;
                    tempfit=hGUI.modelFx(hGUI.guesscoeffs(i2use,:),temptme,tempstm,hGUI.dt,0);
                    tempfit = tempfit(hGUI.padpts+1:end);
                    
                    tempmu(s) = mean(tempfit(1:hGUI.prepts));
                    muAbove_ind= tempfit>tempmu(s);
                    muAbove_ind(1:hGUI.prepts) = 0; muAbove_ind(hGUI.prepts+hGUI.stmpts:end) = 0; 
                    muBelow_ind= tempfit<tempmu(s);
                    muBelow_ind(1:hGUI.prepts) = 0; muBelow_ind(hGUI.prepts+hGUI.stmpts:end) = 0; 

                    tempmuAbove(s) = mean(tempfit(muAbove_ind));
                    tempmuBelow(s) = mean(tempfit(muBelow_ind));

                    tempRatio(s) = (abs(tempmuBelow(s) - tempmu(s)) / abs(tempmuAbove(s) - tempmu(s))); % Ratio
                end
                
                % not saving modelResponse
                
                hGUI.mu_Ex(i) = mean(tempmu);
                            
                hGUI.muAbove_Ex(i) = mean(tempmuAbove);
                hGUI.muBelow_Ex(i) = mean(tempmuBelow);
                
                hGUI.modelRatio_Ex(i) = mean(tempRatio);
                
            end

        end
        
        function createObjects(hGUI,~,~)
            % GRAPHS
            h1 = 200;
            h2 = 350;
            h3 = 250;
            w1 = 450;
            w2 = 220;
            w3 = 350;
            l1 = 80;
            l2 = l1+w2+45;
            t1 = 780;
            t2 = 390;
            t3 = 50;
            l3 = l1+w1+70;
            
            
            % stim
            hGUI.createPlot(struct('Position',[l1 t1 w1 h1]./1000,'tag','p_stim'));
            hGUI.hidex(hGUI.gObj.p_stim)
            hGUI.labely(hGUI.gObj.p_stim,'R*/s')
            hGUI.xlim(hGUI.gObj.p_stim,hGUI.minmax(hGUI.tme))
%             hGUI.ylim(hGUI.gObj.p_stim,hGUI.minmax(hGUI.sf_stm)./hGUI.dt)
            
            lH=lineH(hGUI.tme,hGUI.stm(end,:),hGUI.gObj.p_stim);
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
            for i = hGUI.n:-1:1
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

            % on/off ratio vs ib
            hGUI.createPlot(struct('Position',[l2 t3 w2 h3]./1000,'tag','p_ratio'));
            hGUI.labelx(hGUI.gObj.p_ratio,'Ib (R*/s)')
            hGUI.labely(hGUI.gObj.p_ratio,'Asymmetry Ratio')
            hGUI.gObj.p_ratio.XScale='log';
%             hGUI.xlim(hGUI.gObj.p_resp,hGUI.minmax(hGUI.tme))
%             hGUI.ylim(hGUI.gObj.p_resp,[-10 80])
            


            lH = lineH(hGUI.ib,hGUI.mu,hGUI.gObj.p_ssi);
            lH.linedash;

            lH = lineH(hGUI.ib,hGUI.modelRatio,hGUI.gObj.p_ratio);
            lH.linedash; lH.setName('modelRatio');
            lH = lineH(hGUI.ib,hGUI.modelRatio_Ex,hGUI.gObj.p_ratio);
            lH.linedash; lH.setName('modelRatio_Ex');
            
            for i = hGUI.n:-1:1
                lH = lineH(hGUI.ib(i),hGUI.mu(i),hGUI.gObj.p_ssi);
                lH.markers;lH.color(hGUI.colors(i,:));
                
                lH = lineH(hGUI.ib(i),hGUI.modelRatio(i),hGUI.gObj.p_ratio);
                lH.markers;lH.color(hGUI.colors(i,:));
            end
            
            %example cone data and fit
            hGUI.createPlot(struct('Position',[l3 t1 w3 h1]./1000,'tag','p_ex10k'));
            hGUI.labelx(hGUI.gObj.p_ex10k,'Time (s)')
            hGUI.labely(hGUI.gObj.p_ex10k,'i (pA)')
            hGUI.xlim(hGUI.gObj.p_ex10k,hGUI.minmax(hGUI.exTime))
            
            lH = lineH(hGUI.exTime,hGUI.exData(1,:),hGUI.gObj.p_ex10k);
            lH.color([0,0,0]);lH.h.LineWidth=2;
            
            lH = lineH(hGUI.exTime,hGUI.exModel(1,:),hGUI.gObj.p_ex10k);
            lH.color([.8,0.1,0.2]);lH.h.LineWidth=2;
            
             %example stim
            hGUI.createPlot(struct('Position',[l3 t1-h1/2-50 w3 h1/4]./1000,'tag','p_ex50kStim'));
            hGUI.labelx(hGUI.gObj.p_ex50kStim,'Time (s)')
            hGUI.labely(hGUI.gObj.p_ex50kStim,'R*/s')
            hGUI.xlim(hGUI.gObj.p_ex50kStim,hGUI.minmax(hGUI.exTime))
            lH = lineH(hGUI.exTime,hGUI.exStim(2,:),hGUI.gObj.p_ex50kStim);
            lH.color([0,0,0]);lH.h.LineWidth=2;
            
            %example cone data and fit
            hGUI.createPlot(struct('Position',[l3 t2 w3 h1]./1000,'tag','p_ex50k'));
            hGUI.labelx(hGUI.gObj.p_ex50k,'Time (s)')
            hGUI.labely(hGUI.gObj.p_ex50k,'i (pA)')
            hGUI.xlim(hGUI.gObj.p_ex50k,hGUI.minmax(hGUI.exTime))
            
            lH = lineH(hGUI.exTime,hGUI.exData(2,:),hGUI.gObj.p_ex50k);
            lH.color([0,0,0]);lH.h.LineWidth=2;
            
            lH = lineH(hGUI.exTime,hGUI.exModel(2,:),hGUI.gObj.p_ex50k);
            lH.color([.8,0.1,0.2]);lH.h.LineWidth=2;
            
            %example cone data and fit
            hGUI.createPlot(struct('Position',[l3 t3 w3 h1]./1000,'tag','p_ex160k'));
            hGUI.labelx(hGUI.gObj.p_ex160k,'Time (s)')
            hGUI.labely(hGUI.gObj.p_ex160k,'i (pA)')
            hGUI.xlim(hGUI.gObj.p_ex160k,hGUI.minmax(hGUI.exTime))
            
            lH = lineH(hGUI.exTime,hGUI.exData(3,:),hGUI.gObj.p_ex160k);
            lH.color([0,0,0]);lH.h.LineWidth=2;
            
            lH = lineH(hGUI.exTime,hGUI.exModel(3,:),hGUI.gObj.p_ex160k);
            lH.color([.8,0.1,0.2]);lH.h.LineWidth=2;

        end
        
        function bnRatio = saveCurveForAsymmetryPlot(hGUI,~,~)
            bnRatio = struct;
            bnRatio.ib = hGUI.ib;
            bnRatio.mu = hGUI.mu;
            bnRatio.muAbove = hGUI.muAbove;
            bnRatio.muBelow = hGUI.muBelow;
            bnRatio.ratio = hGUI.modelRatio;
        end
        
       
    end
    
   methods (Static=true)

   end
   
end
