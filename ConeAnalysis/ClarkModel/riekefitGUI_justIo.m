classdef riekefitGUI_justIo < ephysGUI
   properties
       modelFx
       i2V = [135] % holding current in darkness and scaling factor
       
       ini
       curr
       fit
       upper
       lower
       
       
       gain_dt
       gain_tme
       gain_Ibs
       gain_stm
       gain_iflashes
       gain_cflashes
       gain_iGain
       gain_iIo
       gain_cGain
       
       
       ssi_dt
       ssi_tme
       ssi_Ibs
       ssi_stm
       ssi_steps
       ssi_i
       ssi_iFit
       
       df_stm
       df_tme
       df_resp
       df_dt
       
       df_ifit
       df_cfit
       df_ffit

       n
       names
       tnames
       colors 
       tcolors
   end
   
   methods
       function hGUI=riekefitGUI_justIo(fign)
           hGUI@ephysGUI(fign);
       end
       
       function loadData(hGUI,~,~)
           % DATA LOADING AND INITIAL FITS

           % dim flash response
           DF=load('/Users/angueyraaristjm/matlab/matlab-analysis/trunk/users/juan/ConeModel/BiophysicalModel/EyeMovementsExampleDF_092413Fc12vClamp.mat');
           DF=DF.DF_raw;
           
           hGUI.df_tme = DF.TimeAxis;
           hGUI.df_dt = (hGUI.df_tme(2)-hGUI.df_tme(1));
           hGUI.df_resp = DF.Mean - hGUI.i2V(1) - 1; %for biRieke
           hGUI.df_stm = zeros(size(hGUI.df_tme)); hGUI.df_stm(10/(1000*hGUI.df_dt)) = 1/hGUI.df_dt; %10 ms prepts
           
           tempstm=[zeros(1,40000) hGUI.df_stm];
           temptme=(1:1:length(tempstm)).* hGUI.df_dt;
           tempfit=hGUI.modelFx(hGUI.ini,temptme,tempstm);
           hGUI.df_ifit = tempfit(40001:end);
           hGUI.df_cfit = hGUI.df_ifit;
           hGUI.df_ffit = hGUI.df_ifit;
           
           % gain
           fprintf('gainVSib...');
           hGUI.gaininitial;
           fprintf('...Done!\n');
           
           % ssi
%            fprintf('ssi...');
%            hGUI.ssiinitial;
%            fprintf('...Done!\n');
       end
       
       function createObjects(hGUI,~,~)
           % define remaining gui properties
           hGUI.colors = pmkmp(hGUI.n,'CubicL');
           hGUI.tcolors = round((pmkmp(hGUI.n,'CubicL'))./1.2.*255);
           hGUI.tnames = regexprep(hGUI.names,'<[^>]*>',''); %initialize
           for i=1:hGUI.n
               hGUI.tnames{i} = sprintf('<html><font color=rgb(%d,%d,%d)>%s</font></html>',...
                   hGUI.tcolors(i,1),hGUI.tcolors(i,2),hGUI.tcolors(i,3),...
                   hGUI.tnames{i});
           end
           
           % GUI OBJECTS
           hGUI.coeffTable;     % table

           % GRAPHS
                      
           
           % df plot
           hGUI.createPlot(struct('Position',[730 475 255 200]./1000,'tag','dfp'));
           hGUI.labelx(hGUI.gObj.dfp,'Time (s)')
           hGUI.labely(hGUI.gObj.dfp,'i (pA)')
%            hGUI.xlim(hGUI.gObj.dfp,hGUI.minmax(hGUI.df_tme));
           hGUI.xlim(hGUI.gObj.dfp,[0 0.4]);
           
           lH = lineH(hGUI.df_tme,hGUI.df_resp - hGUI.df_resp(1),hGUI.gObj.dfp);  % df response
           lH.lineg;lH.h.LineWidth=1;lH.setName('df');
           lH = lineH(hGUI.df_tme,hGUI.df_ifit - hGUI.df_ifit(1),hGUI.gObj.dfp);  % df initial fit
           lH.lineg;lH.h.LineWidth=2;lH.setName('df_ifit');
           
           
           
           % gain plot
           
           hGUI.createPlot(struct('Position',[710 405 120 30]./1000,'tag','gfs_stim'));
           hGUI.xlim(hGUI.gObj.gfs_stim,[-.2 1])
           
           hGUI.createPlot(struct('Position',[710 265 120 120]./1000,'tag','gfs'));
           hGUI.labelx(hGUI.gObj.gfs,'Time (s)')
           hGUI.labely(hGUI.gObj.gfs,'Norm. gain')
           hGUI.xlim(hGUI.gObj.gfs,[-.2 1])
           
           hGUI.createPlot(struct('Position',[865 265 120 160]./1000,'tag','gwf','XScale','log','YScale','linear'));
           hGUI.labelx(hGUI.gObj.gwf,'Ib (R*/s)')
           hGUI.labely(hGUI.gObj.gwf,'Norm. gain')
           
           % steady-state current plot
           hGUI.createPlot(struct('Position',[710 190 120 30]./1000,'tag','ssi_stim'));
           hGUI.xlim(hGUI.gObj.ssi_stim,[-1 4])
           
           hGUI.createPlot(struct('Position',[710 045 120 120]./1000,'tag','ssi'));
           hGUI.labelx(hGUI.gObj.ssi,'Time (s)')
           hGUI.labely(hGUI.gObj.ssi,'i (pA)')
           hGUI.xlim(hGUI.gObj.ssi,[-1 4])
           
           hGUI.createPlot(struct('Position',[865 045 120 160]./1000,'tag','ssiibs','XScale','log','YScale','linear'));
           hGUI.labelx(hGUI.gObj.ssiibs,'Ib (R*/s)')
           hGUI.labely(hGUI.gObj.ssiibs,'Steady-state current (pA)')
           
           hGUI.gploti;
           hGUI.ssiploti;

       end
      
           
       function coeffTable(hGUI)
           tableinput = struct;
           tableinput.tag = 'coefftable';
           tableinput.Position = [5, 650, 187.3, 262]./1000;
           tableinput.ColumnName = {'initial','curr','fit'};
           tableinput.RowName = hGUI.tnames;
           tableinput.Data = [hGUI.ini;hGUI.curr;hGUI.fit]';
           tableinput.headerWidth = 24;
           ColWidth = 60;
           tableinput.ColumnWidth = {ColWidth,ColWidth,ColWidth};
           
           hGUI.infoTable(tableinput);
       end
       
       % callback functions
       
       % overriding detectKey to run fitting just once
       function keyPress = detectKey(hGUI, ~, handles)
            % determine the key that was pressed
            keyPress = handles.Key;
            if strcmp(keyPress,'return')
                hGUI.updatePlots;
            end
        end
       
      
       
       function dfNorm(hGUI,~,~)
           dfH = findobj(hGUI.gObj.dfp,'tag','df');
           dfiH = findobj(hGUI.gObj.dfp,'tag','df_ifit');
           dfcH = findobj(hGUI.gObj.dfp,'tag','df_cfit');
           dffH = findobj(hGUI.gObj.dfp,'tag','df_ffit');
           if hGUI.gObj.dfnormButton.Value == 0
               hGUI.gObj.dfnormButton.String = 'Norm';
               dfH.YData = hGUI.df_resp;
               dfiH.YData = hGUI.df_ifit;
               dfcH.YData = hGUI.df_cfit;
               dffH.YData = hGUI.df_ffit;
           else
               hGUI.gObj.dfnormButton.String = 'Original';
%                dfH.YData = normalize(hGUI.df_resp-hGUI.df_resp(1));
%                dfiH.YData = normalize(hGUI.df_ifit-hGUI.df_ifit(1));
%                dfcH.YData = normalize(hGUI.df_cfit-hGUI.df_cfit(1));
%                dffH.YData = normalize(hGUI.df_ffit-hGUI.df_ffit(1));
               dfH.YData = (hGUI.df_resp-hGUI.df_resp(1));
               dfiH.YData = (hGUI.df_ifit-hGUI.df_ifit(1));
               dfcH.YData = (hGUI.df_cfit-hGUI.df_cfit(1));
               dffH.YData = (hGUI.df_ffit-hGUI.df_ffit(1));
          end
       end
       function updatePlots(hGUI,~,~)

       end
       
       function runLSQ(hGUI,~,~)
           % least-squares fitting
           fprintf('Started lsq fitting.....\n')
           lsqfun=@(optcoeffs,tme)hGUI.modelFx(optcoeffs,hGUI.stj_tme,hGUI.stj_stm);
           LSQ.objective=lsqfun;
           LSQ.x0=hGUI.curr;
           LSQ.xdata=hGUI.stj_tme;
           LSQ.ydata=hGUI.stj_resp;
           LSQ.lb=hGUI.lower;
           LSQ.ub=hGUI.upper;
           
           LSQ.solver='lsqcurvefit';
           LSQ.options=optimset('TolX',1e-20,'TolFun',1e-20,'MaxFunEvals',500);
           hGUI.fit=lsqcurvefit(LSQ);
           hGUI.showResults(hGUI.fit);
           
           
           hGUI.gObj.infoTable.Data(:,3) = hGUI.fit;
           hGUI.updateFits;
       end
       
       
       
       
       function gaininitial(hGUI,~,~)
           gainstruct = hGUI.gainparams;
           
                   
           t=gainstruct.start:gainstruct.dt:gainstruct.end;   % s
                         
           Stim = NaN(length(gainstruct.Ibs),length(t));
           ios = NaN(length(gainstruct.Ibs),length(t));
           ios_f = NaN(length(gainstruct.Ibs),length(t));
%            Ibs = gainstruct.Ibs  * gainstruct.dt;
           Ibs = gainstruct.Ibs;
           
           for i=1:length(gainstruct.Ibs)
               I_b = ones(1,length(t)) * Ibs(i);

               % gain changes
               tempstm=[ones(1,100000) * Ibs(i) I_b];
               temptme=(1:1:length(tempstm)).* gainstruct.dt;
               tempfit=hGUI.modelFx(hGUI.ini,temptme,tempstm);
               ios_step=tempfit(100001:end);

               
           
               Stim(i,:)=I_b;
               Stim(i,t>=gainstruct.fstart &t<gainstruct.fend) =  Ibs(i) +  gainstruct.f(i)*1000;% 1000 converts from R*/flash(0.1ms) to R*/s
               
               tempstm=[ones(1,100000) * Ibs(i) Stim(i,:)];
               temptme=(1:1:length(tempstm)).* gainstruct.dt;
               tempfit=hGUI.modelFx(hGUI.ini,temptme,tempstm);
               ios(i,:)=tempfit(100001:end);

               ios_f(i,:)=ios(i,:)-ios_step; 
               % Converting to gain directly
               ios_f(i,:)=ios_f(i,:)./gainstruct.f(i);
           end

           
           hGUI.gain_dt = gainstruct.dt;
           hGUI.gain_tme = t - gainstruct.fstart;
           hGUI.gain_stm = Stim;
           hGUI.gain_Ibs = gainstruct.Ibs;
           
           hGUI.gain_iflashes = ios_f;
           hGUI.gain_cflashes = ios_f;
                      
           hGUI.gain_iGain = max(hGUI.gain_iflashes,[],2)'./max(hGUI.gain_iflashes(1,:));
           hGUI.gain_cGain = max(hGUI.gain_iflashes,[],2)'./max(hGUI.gain_iflashes(1,:));
           
           % Fit to Weber-Fechner function
           lsqfun=@hGUI.WeberFechner;
           LSQ.objective=lsqfun;
           LSQ.x0=5000;
           LSQ.xdata=hGUI.gain_Ibs(hGUI.gain_Ibs<1e6);
           LSQ.ydata=hGUI.gain_iGain(hGUI.gain_Ibs<1e6);
           LSQ.lb=[];
           LSQ.ub=[];
           
           LSQ.solver='lsqcurvefit';
           LSQ.options=optimset('TolX',1e-40,'TolFun',1e-40,'MaxFunEvals',5000,'Display','off');
           WFfit=lsqcurvefit(LSQ);
           hGUI.gain_iIo = WFfit;
           fprintf('Weber Fechner: Io=%g\n',WFfit)
       end
       
       function ssiinitial(hGUI,~,~)
           ssistruct = hGUI.ssiparams;
           
                   
           t=ssistruct.start:ssistruct.dt:ssistruct.end;   % s
                         
           Stim = NaN(length(ssistruct.Ibs),length(t));
           ios = NaN(length(ssistruct.Ibs),length(t));
           Ibs = ssistruct.Ibs;
           
           for i=1:length(ssistruct.Ibs)
               Stim(i,:)=0;
               Stim(i,t>=ssistruct.Ibstart &t<ssistruct.Ibend) =  Ibs(i);
               
               tempstm=[zeros(1,40000) Stim(i,:)];
               temptme=(1:1:length(tempstm)).* ssistruct.dt;
               tempfit=hGUI.modelFx(hGUI.ini,temptme,tempstm);
               ios(i,:)=tempfit(40001:end);
           end

           
           hGUI.ssi_dt = ssistruct.dt;
           hGUI.ssi_tme = t - ssistruct.Ibstart;
           hGUI.ssi_stm = Stim;
           hGUI.ssi_Ibs = ssistruct.Ibs;
           hGUI.ssi_steps = ios;
                      
           hGUI.ssi_i = mean(ios(:,hGUI.ssi_tme>2&hGUI.ssi_tme<3),2);
           
           % Fit to Felice's function
           lsqfun=@hGUI.HillEqFeliceUnnormalized;
           LSQ.objective=lsqfun;
           LSQ.x0=[45000, 0.7, 135];
           LSQ.xdata=hGUI.ssi_Ibs(:);
           LSQ.ydata=hGUI.ssi_i(:);
           LSQ.lb=[];
           LSQ.ub=[];
           
           LSQ.solver='lsqcurvefit';
           LSQ.options=optimset('TolX',1e-40,'TolFun',1e-40,'MaxFunEvals',5000,'Display','off');
           Hfit=lsqcurvefit(LSQ);
           hGUI.ssi_iFit = Hfit;
           fprintf('Hill fit: Io=%g; n=%g; iDark=%g\n',Hfit(1),Hfit(2),Hfit(3))
       end
       
       
       
       function dfcurrent(hGUI,~,~)
           tempstm=[zeros(1,5000) hGUI.df_stm];
           temptme=(1:1:length(tempstm)).* hGUI.df_dt;
           tempfit=hGUI.modelFx(hGUI.curr,temptme,tempstm);
           hGUI.df_cfit = tempfit(5001:end);
       end
       
       
       function gploti(hGUI,~,~)
           nIbs = length(hGUI.gain_Ibs);
           gcolors = pmkmp(nIbs,'CubicLQuarterBlack');
           normFactor = max(hGUI.gain_iflashes(1,:));
           
           lH=lineH(hGUI.gain_tme,normalize(hGUI.gain_stm(1,:)),hGUI.gObj.gfs_stim);
           lH.linek;lH.setName('stim');
           
           % plot initial fit
           for i=1:nIbs
               lH=lineH(hGUI.gain_tme,hGUI.gain_iflashes(i,:)./normFactor,hGUI.gObj.gfs);
               lH.line; lH.color(gcolors(i,:));lH.h.LineWidth=2;lH.setName(sprintf('gf_%d',round(hGUI.gain_Ibs(i))));
               
               lH=lineH(hGUI.gain_Ibs(i),hGUI.gain_iGain(i),hGUI.gObj.gwf);
               lH.markers;lH.color(gcolors(i,:));lH.setName(sprintf('gwf_%d',round(hGUI.gain_Ibs(i))));
           end
           lH=lineH(hGUI.gain_Ibs,hGUI.WeberFechner(hGUI.gain_iIo,hGUI.gain_Ibs),hGUI.gObj.gwf);
           lH.liner;lH.setName('gwf_fit');
           
           lH=lineH(hGUI.gain_Ibs,hGUI.WeberFechner(2250,hGUI.gain_Ibs),hGUI.gObj.gwf);
           lH.lineg;lH.setName('gwf_AR2013');
           
           lH=lineH(hGUI.gain_Ibs,hGUI.WeberFechner(3330,hGUI.gain_Ibs),hGUI.gObj.gwf);
           lH.linedash;lH.setName('gwf_Cao2014');
           
       end
       
       function ssiploti(hGUI,~,~)
           nIbs = length(hGUI.ssi_Ibs);
           gcolors = pmkmp(nIbs,'CubicLQuarterBlack');
           
           lH=lineH(hGUI.ssi_tme,normalize(hGUI.ssi_stm(end,:)),hGUI.gObj.ssi_stim);
           lH.linek;lH.setName('stim');
           
           % plot initial fit
           for i=1:nIbs
               lH=lineH(hGUI.ssi_tme,hGUI.ssi_steps(i,:),hGUI.gObj.ssi);
               lH.line; lH.color(gcolors(i,:));lH.h.LineWidth=2;lH.setName(sprintf('ssi_%d',round(hGUI.ssi_Ibs(i))));
               
               lH=lineH(hGUI.ssi_Ibs(i),hGUI.ssi_i(i),hGUI.gObj.ssiibs);
               lH.markers;lH.color(gcolors(i,:));lH.setName(sprintf('ssiibs_%d',round(hGUI.ssi_Ibs(i))));
           end
           lH=lineH(hGUI.ssi_Ibs,hGUI.HillEqFeliceUnnormalized(hGUI.ssi_iFit,hGUI.ssi_Ibs),hGUI.gObj.ssiibs);
           lH.liner;lH.setName('hill_fit');
           
%            lH=lineH(hGUI.ssi_Ibs,hGUI.HillEqFeliceUnnormalized([45000,0.7,134],hGUI.ssi_Ibs),hGUI.gObj.ssiibs);
           lH=lineH(hGUI.ssi_Ibs,hGUI.HillEqFeliceUnnormalized([45000,0.7,hGUI.ini(4)],hGUI.ssi_Ibs),hGUI.gObj.ssiibs);
           lH.lineg;lH.setName('hill_DR2007');
           
       end
   end
   
   methods (Static=true)
              
       function gainstruct = gainparams()
           gainstruct=struct;
           
           gainstruct.dt = 1e-5;
           gainstruct.start = 0;
           gainstruct.end = 4;
           
           gainstruct.Ibstart = 1;
           gainstruct.Ibend = 4;
           gainstruct.fstart = 2.5;
           gainstruct.fend = gainstruct.fstart+1e-4;
%            gainstruct.Ibs=[000, 001, 003, 010, 030, 100, 300, 1e3, 3e3, 1e4, 3e4, 1e5, 3e5, 1e6, 3e6, 5e6];
%            gainstruct.f = [010, 010, 010, 010, 010, 010, 010, 010, 012, 015, 027, 080, 200, 500, 20000, 30000];%gain has to be calculated because little to no response at high intensities make it look like deviations from Weber behaviour
           gainstruct.Ibs=[000, 001, 003, 010, 030, 100, 300, 1e3, 3e3, 1e4, 5e3, 3e4, 1e5, 3e5, 1e6, 3e6, 5e6];
           gainstruct.f = [010, 010, 010, 010, 010, 010, 010, 010, 012, 015, 015, 027, 080, 200, 500, 20000, 30000];%gain has to be calculated because little to no response at high intensities make it look like deviations from Weber behaviour
       end
       
       function ssistruct = ssiparams()
           ssistruct=struct;
           
           ssistruct.dt = 1e-5;
           ssistruct.start = 0;
           ssistruct.end = 5;
           
           ssistruct.Ibstart = 1;
           ssistruct.Ibend = 4;
           
           ssistruct.Ibs=[000, 001, 003, 005, 010, 030, 100, 300, 1e3, 3e3, 1e4, 3e4, 1e5, 3e5, 1e6, 3e6, 5e6];
%            ssistruct.Ibs=[logspace(0,6,18), 3e6, 5e6];
       end
       
       function NormSensitivity=WeberFechner(Io,Ib)
           % function NormSensitivity=WeberFechner(Io,Ib)
           % NormSensitivity=1./(1+(Ib./Io));
           % Weber Fechner function in which Sensitivity to each background has been
           % normalized by Sensitivity in Darkness.
           % Io is the half-desensitizing background
           % Ib in the intensity of the background
           
           NormSensitivity=1./(1+(Ib./Io));
       end
       
       function fit=AmplitudeToBackground(coeffs,Ib)
           % fit=AmplitudeToBackground([a b c],Ib)
           % Following Dunn, 2007, empirical fit to describe the dependence of
           % response amplitude to background intesity
           % a = accounts for the increase in amplitude with backgrounds
           % b = determines where increase begins and the magnitude of this increase
           % c = sets where adaptation begins
           % For L-cones a = 100, b = 1.3 and c = 0.00029
           
           % if exist('coeffs','var')
           %     if ~isempty(coeffs)
           %         [a,b,c]=coeffs;
           %     else
           %         a=100;
           %         b=1.3;
           %         c=0.00029;
           %     end
           % else
           %     a=100;
           %     b=1.3;
           %     c=0.00029;
           % end
           a=coeffs(1);
           b=coeffs(2);
           c=coeffs(3);
           
           fit = ((abs(a) + (b.*Ib))./(abs(a) + Ib)) .* (1./(c.*Ib + 1));
       end
       
       function NormX=HillEqFelice(coeffs,Ib)
           % function NormSensitivity=FeliceHill([Io,n],Ib)
           % Hill relationship for steady state current of cones from Dunn et al, 2007
           % Best fit parameters are Io=45 000 R*/s and n= 0.7
           % normalized by current in darkness.
           % Io is the half-desensitizing background
           % n is the cooperativity (Hill exponent)
           % Ib in the intensity of the background
           
           Io = coeffs(1);
           n = coeffs(2);
           
           NormX=1./(1+(Io./Ib).^n);
       end
       
       function NotNormX=HillEqFeliceUnnormalized(coeffs,Ib)
           % function NotNormSensitivity=FeliceHill([Io,n,iDark],Ib)
           % Hill relationship for steady state current of cones from Dunn et al, 2007
           % Best fit parameters are Io=45 000 R*/s and n= 0.7
           % normalized by current in darkness.
           % Io is the half-desensitizing background
           % n is the cooperativity (Hill exponent)
           % Ib in the intensity of the background
           
           Io = coeffs(1);
           n = coeffs(2);
           iDark = coeffs(3);
           
           NotNormX=((1./(1+(Io./Ib).^n))-1)*iDark;
       end
       
       function showResults(fitcoeffs)
           fprintf('\nccoeffs=[');fprintf('%04.3g,',fitcoeffs);fprintf('];\n')
       end
   end
   
end
