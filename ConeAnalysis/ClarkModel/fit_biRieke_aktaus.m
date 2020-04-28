classdef fit_biRieke_aktaus < ephysGUI
    properties
        
        %         coeffs = [0500,220,2000,136,0400,0250]; % our best fit to stj example cell
        coeffs = [0500,220,2000,80,0400,0290]; %isetbio params with 56 pA discrepancy in fit to stj but using for ssi and gain adaptation fits
        %         coeffs = [0500,220,2000,350,0400,285]; % our closest fit to ak
        ib
        ib_lo = 1;
        ib_hi = 5.3;
        n = 100;
        nS
        colors
        wcolors
        normFlag = 1;
        padpts = 4000;
        
        f_delays = [0.1 0.2 0.3 0.5 1 2 3 5 10 20 30 50 100 200 300 500 600]./1000
        f_intensity = 10000;
        
        prepts
        stmpts
        tailpts
        datapts
        f_delaypts
        fpts
        prepts_darkf
        
        
        tme
        stm_s
        stm_f
        stm_sf
        stm_darkf
        dt = 1e-4
        
        ib_example = 10000;
        
        modelFx
        sResponses
        darkfResponses
        sfResponses
        fResponses
        
        modelOnGain
        modelOffGain
        
        modelOnFits
        modelOffFits
        
        modelOnTau
        modelOnCoeffs
        modelOffTau
        modelOffCoeffs
        
    end
    
    methods
        
        function hGUI=fit_biRieke_aktaus(fign)
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
            hGUI.wcolors = whithen(hGUI.colors,0.5);
            
            hGUI.nS = length(hGUI.f_delays);
            
            hGUI.prepts = 0.5/hGUI.dt;
            hGUI.stmpts = 1.0/hGUI.dt;
            hGUI.tailpts = 1.0/hGUI.dt;
            hGUI.datapts = hGUI.prepts + hGUI.stmpts + hGUI.tailpts;
            hGUI.f_delaypts = hGUI.f_delays/hGUI.dt;
            hGUI.fpts = 0.01/hGUI.dt;
            hGUI.prepts_darkf = 0.1/hGUI.dt;
            
            hGUI.tme = (0:hGUI.datapts-1)*hGUI.dt;
            
            hGUI.stm_s = zeros(1,hGUI.datapts);
            hGUI.stm_s(hGUI.prepts:hGUI.prepts+hGUI.stmpts) = 1;
            
            hGUI.stm_f = zeros(1,hGUI.datapts);
            
            hGUI.stm_darkf = zeros(1,hGUI.datapts);
            hGUI.stm_darkf(hGUI.prepts_darkf:hGUI.prepts_darkf+hGUI.fpts) = hGUI.f_intensity;
            
            hGUI.stm_sf = hGUI.stm_s + hGUI.stm_f;

            
            fprintf('Creating model data...\n')
            hGUI.createData;
            fprintf('Fitting on gain kinetics...\n')
            hGUI.fitTau_onGain;
            fprintf('Fitting off gain kinetics...\n')
            hGUI.fitTau_offGain;
            fprintf('Creating GUI...\n')
            hGUI.createObjects;
            fprintf('Done!\n')
        end
        
        
        
        function createData(hGUI,~,~)
            hGUI.sResponses = NaN(hGUI.n,length(hGUI.tme));
            
            
            % these may have to be 3d arrays!!
            hGUI.sfResponses = NaN(hGUI.n,length(hGUI.tme),hGUI.nS);
            hGUI.fResponses = NaN(hGUI.n,length(hGUI.tme),hGUI.nS);
           
            
            hGUI.modelOnGain = NaN(hGUI.n,hGUI.nS);
            hGUI.modelOffGain = NaN(hGUI.n,hGUI.nS);
            
            hGUI.modelOnTau = NaN(1,hGUI.n);
            hGUI.modelOffTau = NaN(1,hGUI.n);
            
            
            % dark flash without step
            tempstm=[zeros(1,hGUI.padpts) hGUI.stm_darkf]; %padding
            temptme=(1:1:length(tempstm))* hGUI.dt;
            tempfit=rModel6(hGUI.coeffs,temptme,tempstm,hGUI.dt,0);
            hGUI.darkfResponses = tempfit(hGUI.padpts+1:end);
            hGUI.darkfResponses = hGUI.darkfResponses - mean(hGUI.darkfResponses(1:hGUI.prepts_darkf));
            
            darkGain = max(hGUI.darkfResponses);
            
            for i = 1:hGUI.n
                
                % step response without flashes for subtraction
                tempstm=[ones(1,hGUI.padpts)*hGUI.stm_s(1)*hGUI.ib(i) hGUI.stm_s*hGUI.ib(i)]; %padding
                temptme=(1:1:length(tempstm))* hGUI.dt;
                tempfit=rModel6(hGUI.coeffs,temptme,tempstm,hGUI.dt,0);
                hGUI.sResponses(i,:) = tempfit(hGUI.padpts+1:end);

                for s = 1:hGUI.nS
                    hGUI.stm_f = zeros(1,hGUI.datapts);
                    hGUI.stm_f(hGUI.prepts+hGUI.f_delaypts(s):hGUI.prepts+hGUI.f_delaypts(s)+hGUI.fpts) = hGUI.f_intensity;
                    hGUI.stm_f(hGUI.prepts+hGUI.stmpts+hGUI.f_delaypts(s):hGUI.prepts+hGUI.stmpts+hGUI.f_delaypts(s)+hGUI.fpts) = hGUI.f_intensity;
                    % step response with flash
                    tempstm=[ones(1,hGUI.padpts)*hGUI.stm_s(1)*hGUI.ib(i) hGUI.stm_s*hGUI.ib(i)+hGUI.stm_f]; %padding
                    temptme=(1:1:length(tempstm))* hGUI.dt;
                    tempfit=rModel6(hGUI.coeffs,temptme,tempstm,hGUI.dt,0);
                    hGUI.sfResponses(i,:,s) = tempfit(hGUI.padpts+1:end);
                    
                    hGUI.fResponses(i,:,s) = hGUI.sfResponses(i,:,s) - hGUI.sResponses(i,:);
                    
                    hGUI.modelOnGain(i,s) = max(hGUI.fResponses(i,1:hGUI.prepts+hGUI.stmpts,s))/darkGain;
                    hGUI.modelOffGain(i,s) = max(hGUI.fResponses(i,hGUI.prepts+hGUI.stmpts:end,s))/darkGain;
                end
                
            end
            
        end
        
        function fitTau_onGain(hGUI,~,~)
            % Exponential fits
            hGUI.modelOnFits = NaN(hGUI.n,hGUI.nS);
            FMC = struct;
%             FMC.lb=[000 000 000];
%             FMC.ub=[002 200 002];
            FMC.solver='fmincon';
            FMC.options=optimset('Algorithm','interior-point',...
                'DiffMinChange',1e-40,'Display','none',...
                'TolX',1e-80,'TolFun',1e-40,'TolCon',1e-40,...
                'MaxFunEvals',2000);
            tAx=hGUI.f_delays;
            optfx=@(optcoeffs)((optcoeffs(1)*((exp(-optcoeffs(2).*tAx))))+optcoeffs(3));
            for i = 1:hGUI.n
                guess=[hGUI.modelOnGain(i,1)-hGUI.modelOnGain(i,end) 1 hGUI.modelOnGain(i,end)];
                FMC.x0=guess;
                errfx=@(optcoeffs)sum((optfx(optcoeffs)-hGUI.modelOnGain(i,:)).^2);
                FMC.objective=errfx;

                fitcoeffs=fmincon(FMC);
                hGUI.modelOnFits(i,:)=optfx(fitcoeffs);
    %             fprintf('\tOn_tau=%g ms \n',round((1/fitcoeffs(2))*100000)/100);
                hGUI.modelOnTau(i)=round((1/fitcoeffs(2))*100000)/100;
            end  
        end
        
        function fitTau_offGain(hGUI,~,~)
            % Exponential fits
            hGUI.modelOffFits = NaN(hGUI.n,hGUI.nS);
            FMC = struct;
%             FMC.lb=[000 000 000];
%             FMC.ub=[002 200 002];
            FMC.solver='fmincon';
            FMC.options=optimset('Algorithm','interior-point',...
                'DiffMinChange',1e-40,'Display','none',...
                'TolX',1e-80,'TolFun',1e-40,'TolCon',1e-40,...
                'MaxFunEvals',2000);
            tAx=hGUI.f_delays;
            optfx=@(optcoeffs)((optcoeffs(1)*(1-(exp(-optcoeffs(2).*tAx))))+optcoeffs(3));
            for i = 1:hGUI.n
                guess=[hGUI.modelOffGain(i,1)-hGUI.modelOffGain(i,end) 1 hGUI.modelOffGain(i,end)];
                FMC.x0=guess;
                errfx=@(optcoeffs)sum((optfx(optcoeffs)-hGUI.modelOffGain(i,:)).^2);
                FMC.objective=errfx;

                fitcoeffs=fmincon(FMC);
                hGUI.modelOffFits(i,:)=optfx(fitcoeffs);
    %             fprintf('\tOn_tau=%g ms \n',round((1/fitcoeffs(2))*100000)/100);
                hGUI.modelOffTau(i)=round((1/fitcoeffs(2))*100000)/100;
            end
        end
        
        
        function createObjects(hGUI,~,~)
            % GRAPHS
            h1 = 90;
            h2 = 175;
            
            h3 = 250;
            w0 = 160;
            w2 = 250;
            w1 = w2*2+45;
            
            l0 = 30;
            l1 = l0+w0+45;
            l2 = l1+w2+45;
            l5 = l2+w2+45;
            
            t1 = 900;
            t2 = 590;
            t3 = 370;
            t4 = 50;
            
            
            
            
            
            % step stim
            hGUI.createPlot(struct('Position',[l1 t1 w1 h1]./1000,'tag','p_sstim'));
            hGUI.hidex(hGUI.gObj.p_sstim)
            hGUI.labely(hGUI.gObj.p_sstim,'R*/s')
            hGUI.xlim(hGUI.gObj.p_sstim,hGUI.minmax(hGUI.tme))
            %             hGUI.ylim(hGUI.gObj.p_stim,hGUI.minmax(hGUI.sf_stm)./hGUI.dt)
            
            lH=lineH(hGUI.tme,hGUI.stm_s,hGUI.gObj.p_sstim);
            lH.linek;lH.setName('stim_s');lH.h.LineWidth=2;
            
            % flash stim
            hGUI.createPlot(struct('Position',[l1 t1-h1-20 w1 h1]./1000,'tag','p_fstim'));
            hGUI.hidex(hGUI.gObj.p_fstim)
            hGUI.labely(hGUI.gObj.p_fstim,'R*/s')
            hGUI.xlim(hGUI.gObj.p_fstim,hGUI.minmax(hGUI.tme))
            %             hGUI.ylim(hGUI.gObj.p_stim,hGUI.minmax(hGUI.sf_stm)./hGUI.dt)
            
            lH = lineH(hGUI.tme,hGUI.stm_darkf,hGUI.gObj.p_fstim);
            lH.color([0 0 0]);lH.h.LineWidth=2;
            
            
            % steps + flashes responses
            hGUI.createPlot(struct('Position',[l1 t2 w1 h2]./1000,'tag','p_resp'));
            hGUI.hidex(hGUI.gObj.p_resp)
            hGUI.labely(hGUI.gObj.p_resp,'i (pA)')
            hGUI.xlim(hGUI.gObj.p_resp,hGUI.minmax(hGUI.tme))
            %             hGUI.ylim(hGUI.gObj.p_resp,[-10 80])
            
            for i = 1:hGUI.n%hGUI.n:-1:1
                lH = lineH(hGUI.tme,hGUI.sResponses(i,:),hGUI.gObj.p_resp);
                lH.color(hGUI.wcolors(i,:));lH.h.LineWidth=2;
                
                lH = lineH(hGUI.tme,squeeze(hGUI.sfResponses(i,:,end-2)),hGUI.gObj.p_resp);
                lH.color(hGUI.colors(i,:));lH.h.LineWidth=2;
            end            

            % flash responses
            hGUI.createPlot(struct('Position',[l1 t3 w1 h2]./1000,'tag','p_fresp'));
            hGUI.labelx(hGUI.gObj.p_fresp,'Time (s)')
            hGUI.labely(hGUI.gObj.p_fresp,'i (pA)')
            hGUI.xlim(hGUI.gObj.p_fresp,hGUI.minmax(hGUI.tme))
            %             hGUI.ylim(hGUI.gObj.p_resp,[-10 80])
            

            lH = lineH(hGUI.tme,hGUI.darkfResponses,hGUI.gObj.p_fresp);
            lH.color([0 0 0]);lH.h.LineWidth=2;
            
            for i = 1:hGUI.n%hGUI.n:-1:1
                for s = 1:hGUI.nS
                    lH = lineH(hGUI.tme,squeeze(hGUI.fResponses(i,:,s)),hGUI.gObj.p_fresp);
                    lH.color(hGUI.colors(i,:));lH.h.LineWidth=2;
                end
            end            
           
            
            % onGain
            hGUI.createPlot(struct('Position',[l1 t4 w2 h3]./1000,'tag','p_onGain'));
            hGUI.labelx(hGUI.gObj.p_onGain,'dt (ms)')
            hGUI.labely(hGUI.gObj.p_onGain,'Norm. Gain')
            
            %             hGUI.xlim(hGUI.gObj.p_resp,hGUI.minmax(hGUI.tme))
            %             hGUI.ylim(hGUI.gObj.p_resp,[-10 80])
            
            for i = 1:hGUI.n
                if hGUI.normFlag
                    lH = lineH([0 hGUI.f_delays],normalize([1 hGUI.modelOnGain(i,:)]-hGUI.modelOnGain(i,end)),hGUI.gObj.p_onGain);
                    lH.markers;lH.color(hGUI.colors(i,:));lH.h.LineWidth=2;
                    
                    lH = lineH([0 hGUI.f_delays],normalize([1 hGUI.modelOnFits(i,:)]-hGUI.modelOnFits(i,end)),hGUI.gObj.p_onGain);
                    lH.line;lH.color(hGUI.colors(i,:));lH.h.LineWidth=2;
                else
                    lH = lineH([0 hGUI.f_delays],[1 hGUI.modelOnGain(i,:)],hGUI.gObj.p_onGain);
                    lH.markers;lH.color(hGUI.colors(i,:));lH.h.LineWidth=2;
                    
                    lH = lineH([0 hGUI.f_delays],[1 hGUI.modelOnFits(i,:)],hGUI.gObj.p_onGain);
                    lH.line;lH.color(hGUI.colors(i,:));lH.h.LineWidth=2;
                end
            end
            
            % onTaus
            hGUI.createPlot(struct('Position',[l0 t4 w0 h3]./1000,'tag','p_onTau'));
            hGUI.labelx(hGUI.gObj.p_onTau,'Background (R*/s)')
            hGUI.labely(hGUI.gObj.p_onTau,'onTau (ms)')
            hGUI.gObj.p_onTau.XScale='log';
            
            lH = lineH(hGUI.ib,hGUI.modelOnTau,hGUI.gObj.p_onTau);
            lH.linedash;lH.h.LineWidth=2;lH.setName('AllOnTaus');
            for i = 1:hGUI.n
                lH = lineH(hGUI.ib(i),hGUI.modelOnTau(i),hGUI.gObj.p_onTau);
                lH.markers;lH.color(hGUI.colors(i,:));lH.setName(sprintf('OnTaus_%g',round(hGUI.ib(i))));
            end
            
            % offGain
            hGUI.createPlot(struct('Position',[l2 t4 w2 h3]./1000,'tag','p_offGain'));
            hGUI.labelx(hGUI.gObj.p_offGain,'dt (ms)')
            hGUI.labely(hGUI.gObj.p_offGain,'Norm. Gain')
            
            %             hGUI.xlim(hGUI.gObj.p_resp,hGUI.minmax(hGUI.tme))
            %             hGUI.ylim(hGUI.gObj.p_resp,[-10 80])
            
            for i = 1:hGUI.n
                if hGUI.normFlag
                    lH = lineH(hGUI.f_delays,normalize(hGUI.modelOffGain(i,:)-hGUI.modelOffGain(i,1)),hGUI.gObj.p_offGain);
                    lH.markers;lH.color(hGUI.colors(i,:));lH.h.LineWidth=2;
                    
                    lH = lineH(hGUI.f_delays,normalize(hGUI.modelOffFits(i,:)-hGUI.modelOffFits(i,1)),hGUI.gObj.p_offGain);
                    lH.line;lH.color(hGUI.colors(i,:));lH.h.LineWidth=2;
                else
                    lH = lineH(hGUI.f_delays,hGUI.modelOffGain(i,:),hGUI.gObj.p_offGain);
                    lH.markers;lH.color(hGUI.colors(i,:));lH.h.LineWidth=2;
                    
                    lH = lineH(hGUI.f_delays,hGUI.modelOffFits(i,:),hGUI.gObj.p_offGain);
                    lH.line;lH.color(hGUI.colors(i,:));lH.h.LineWidth=2;
                end
            end
            
            
            % offTaus
            hGUI.createPlot(struct('Position',[l5 t4 w0 h3]./1000,'tag','p_offTau'));
            hGUI.labelx(hGUI.gObj.p_offTau,'Background (R*/s)')
            hGUI.labely(hGUI.gObj.p_offTau,'offTau (ms)')
            
            lH = lineH(hGUI.ib,hGUI.modelOffTau,hGUI.gObj.p_offTau);
            lH.linedash;lH.h.LineWidth=2;lH.setName('AllOffTaus');
            for i = 1:hGUI.n
                lH = lineH(hGUI.ib(i),hGUI.modelOffTau(i),hGUI.gObj.p_offTau);
                lH.markers;lH.color(hGUI.colors(i,:));lH.setName(sprintf('OffTaus_%g',round(hGUI.ib(i))));
            end
        end
        
        
        function akKinetics = saveCurveForAKPlot(hGUI,~,~)
            akKinetics = struct;
            akKinetics.ib = hGUI.ib;
            akKinetics.modelOnTau = hGUI.modelOnTau;
            akKinetics.modelOffTau = hGUI.modelOffTau;
            akKinetics.dt = [0 hGUI.f_delays];
            akKinetics.modelOnGain = hGUI.modelOnGain;
%             akKinetics.modelOnFits = hGUI.modelOnFits;
            akKinetics.modelOffGain = hGUI.modelOffGain;
%             akKinetics.modelOffFits = hGUI.modelOffFits;
        end
    end
    
    methods (Static=true)
        function [ios]=riekeModel(coef,time,stim,varargin)
            ios = rModel6(coef,time,stim,0);
        end
        
    end
    
end
