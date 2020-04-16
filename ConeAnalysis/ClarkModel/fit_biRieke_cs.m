classdef fit_biRieke_cs < ephysGUI
    properties
        coeffs = [0500,220,2000,80,0400,0290]; %isetbio params with 56 pA discrepancy in fit to stj but using for ssi and gain adaptation fits
%         coeffs = [0500,220,2000,136,0400,0250]; % our best fit to stj example cell
%         coeffs = [0500,220,2000,350,0400,285]; % our closest fit to ak
        ib
        ib_lo = 1;
        ib_hi = 5.6;
        n = 100;
        colors
        padpts = 10000;
        
        prepts = 10000;
        stmpts1 = 10000;
        interpts = 20000;
        stmpts2 = 10000;
        tailpts = 10000;
        datapts
        
        bls = 0; %baselinesubtraction
        
        tme
        stm
        dt = 5.0000e-05
        
        modelFx
        modelResponses
        
        modelRatio
        mu
        muAbove
        muBelow
    end
    
    methods
        
        function hGUI=fit_biRieke_cs(fign)
            % INITIALIZATION
            if nargin == 0
                fign=10;
            end
            hGUI@ephysGUI(fign);
            
            set(hGUI.figH,'KeyPressFcn',@hGUI.detectKey);
            
            % initialize properties
            hGUI.modelFx = @hGUI.riekeModel;
            hGUI.ib = logspace(hGUI.ib_lo,hGUI.ib_hi,hGUI.n);
            hGUI.colors = pmkmp(hGUI.n,'CubicL');
            
            hGUI.datapts = hGUI.prepts + hGUI.stmpts1 + hGUI.interpts + hGUI.stmpts2 + hGUI.tailpts;
            
            hGUI.stm = ones (1,hGUI.datapts);
            hGUI.stm(hGUI.prepts:hGUI.prepts+hGUI.stmpts1) = 2;
            hGUI.stm(hGUI.prepts+hGUI.stmpts1+hGUI.interpts:hGUI.prepts+hGUI.stmpts1+hGUI.interpts+hGUI.stmpts2) = 0;
            hGUI.tme = (0:hGUI.datapts-1).*hGUI.dt;
            
            hGUI.createData;
            hGUI.createObjects;
        end
        
        function createData(hGUI,~,~)
            hGUI.modelResponses = NaN(hGUI.n,length(hGUI.tme));
            hGUI.modelRatio = NaN(1,hGUI.n);
            hGUI.mu = NaN(1,hGUI.n);
            hGUI.muAbove = NaN(1,hGUI.n);
            hGUI.muBelow = NaN(1,hGUI.n);
            for i = 1:hGUI.n

                tempstm=[ones(1,hGUI.padpts).*hGUI.stm(1).*hGUI.ib(i) hGUI.stm.*hGUI.ib(i)]; %padding
                temptme=(1:1:length(tempstm)).* hGUI.dt;
                tempfit=rModel6(hGUI.coeffs,temptme,tempstm,hGUI.dt,0);
                tempfit = tempfit(hGUI.padpts+1:end);
                hGUI.modelResponses(i,:)=tempfit;

                hGUI.mu(i) = mean(tempfit(1:hGUI.prepts));
                
                
                            
                hGUI.muAbove(i) = mean(tempfit(hGUI.prepts+hGUI.stmpts1/2:hGUI.prepts+hGUI.stmpts1)); %average on the second half of response
                hGUI.muBelow(i) = mean(tempfit(hGUI.prepts+hGUI.stmpts1+hGUI.interpts+hGUI.stmpts2/2:hGUI.prepts+hGUI.stmpts1+hGUI.interpts+hGUI.stmpts2)); %average on the second half of response
                
                hGUI.modelRatio(i) = (abs(hGUI.muBelow(i) - hGUI.mu(i)) / abs(hGUI.muAbove(i) - hGUI.mu(i))); % Ratio
                
            end

        end
        
        function createObjects(hGUI,~,~)
            % GRAPHS
            h1 = 200;
            h2 = 350;
            h3 = 250;
            w1 = 500;
            w2 = 275;
            l1 = 230;
            l2 = l1+w2+45;
            t1 = 780;
            t2 = 390;
            t3 = 50;
            
            
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
                if hGUI.bls
                    lH = lineH(hGUI.tme,hGUI.modelResponses(i,:)-hGUI.mu(i),hGUI.gObj.p_resp);
                    lolim = min(hGUI.modelResponses(end,:)-hGUI.mu(end))*1.05;
                    hilim = max(hGUI.modelResponses(end,:)-hGUI.mu(end))*1.10;
                else
                    lH = lineH(hGUI.tme,hGUI.modelResponses(i,:),hGUI.gObj.p_resp);
                    lolim = min(hGUI.modelResponses(1,1:hGUI.prepts))*1.05;
                    hilim = 0;
                end
                lH.color(hGUI.colors(i,:));lH.h.LineWidth=2;
            end
            
            % vertical limits
            lH=lineH([hGUI.prepts+hGUI.stmpts1/2 hGUI.prepts+hGUI.stmpts1/2].*hGUI.dt,[lolim hilim],hGUI.gObj.p_resp);
            lH.linedash; lH.color([0.75,0,0]);lH.setName('vLine01');lH.h.LineWidth=2;
            
            lH=lineH([hGUI.prepts+hGUI.stmpts1 hGUI.prepts+hGUI.stmpts1].*hGUI.dt,[lolim hilim],hGUI.gObj.p_resp);
            lH.linedash; lH.color([0.75,0,0]);lH.setName('vLine02');lH.h.LineWidth=2;
            
            lH=lineH([hGUI.prepts+hGUI.stmpts1+hGUI.interpts+hGUI.stmpts2/2 hGUI.prepts+hGUI.stmpts1+hGUI.interpts+hGUI.stmpts2/2].*hGUI.dt,[lolim hilim],hGUI.gObj.p_resp);
            lH.linedash; lH.color([0 0.4431 0.7373]);lH.setName('vLine03');lH.h.LineWidth=2;
            
            lH=lineH([hGUI.prepts+hGUI.stmpts1+hGUI.interpts+hGUI.stmpts2 hGUI.prepts+hGUI.stmpts1+hGUI.interpts+hGUI.stmpts2].*hGUI.dt,[lolim hilim],hGUI.gObj.p_resp);
            lH.linedash; lH.color([0 0.4431 0.7373]);lH.setName('vLine04');lH.h.LineWidth=2;
            
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
            

            if hGUI.bls
                lH = lineH(hGUI.ib,hGUI.mu-hGUI.mu,hGUI.gObj.p_ssi);
                lH.linedash;
                
                lH = lineH(hGUI.ib,hGUI.muAbove-hGUI.mu,hGUI.gObj.p_ssi);
                lH.liner;
                
                lH = lineH(hGUI.ib,hGUI.muBelow-hGUI.mu,hGUI.gObj.p_ssi);
                lH.lineb;
                
                lH = lineH(hGUI.ib,hGUI.modelRatio,hGUI.gObj.p_ratio);
                lH.linedash;
                
                for i = hGUI.n:-1:1
                    lH = lineH(hGUI.ib(i),hGUI.mu(i)-hGUI.mu(i),hGUI.gObj.p_ssi);
                    lH.markers;lH.color(hGUI.colors(i,:));
                    
                    lH = lineH(hGUI.ib(i),hGUI.modelRatio(i),hGUI.gObj.p_ratio);
                    lH.markers;lH.color(hGUI.colors(i,:));
                end
            else
                lH = lineH(hGUI.ib,hGUI.mu,hGUI.gObj.p_ssi);
                lH.linedash;
                
                lH = lineH(hGUI.ib,hGUI.muAbove,hGUI.gObj.p_ssi);
                lH.liner;
                
                lH = lineH(hGUI.ib,hGUI.muBelow,hGUI.gObj.p_ssi);
                lH.lineb;
                
                lH = lineH(hGUI.ib,hGUI.modelRatio,hGUI.gObj.p_ratio);
                lH.linedash;
                
                for i = hGUI.n:-1:1
                    lH = lineH(hGUI.ib(i),hGUI.mu(i),hGUI.gObj.p_ssi);
                    lH.markers;lH.color(hGUI.colors(i,:));
                    
                    lH = lineH(hGUI.ib(i),hGUI.modelRatio(i),hGUI.gObj.p_ratio);
                    lH.markers;lH.color(hGUI.colors(i,:));
                end
            end
            

        end
        
        function csRatio = saveCurveForAsymmetryPlot(hGUI,~,~)
            csRatio = struct;
            csRatio.ib = hGUI.ib;
            csRatio.mu = hGUI.mu;
            csRatio.muAbove = hGUI.muAbove;
            csRatio.muBelow = hGUI.muBelow;
            csRatio.ratio = hGUI.modelRatio;
        end
    end
    
   methods (Static=true)
       function [ios]=riekeModel(coef,time,stim,varargin)
           ios = rModel6(coef,time,stim,0);
       end

   end
   
end
