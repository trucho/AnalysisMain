function [params]=rModel_Aug2020(params)

% Fixed parameters
cdark= 1; % was 0.5 % dark calcium concentration (in uM????) <1uM (~300 -500 nM)
cgmphill=3;
cgmp2cur = 10e-3;%8e-3;		% constant relating cGMP to current
% gdark and cgmp2cur trade with each other to set dark current

params.gdark = (2 * params.darkCurrent / cgmp2cur)^(1/cgmphill);

cur2ca = params.beta * cdark / params.darkCurrent;                % get q using steady state
smax = params.eta/params.phi * params.gdark * (1 + (cdark / params.hillaffinity)^params.hillcoef);		% get smax using steady state

clear g s c p r

% initial conditions
g(1) = params.gdark;
s(1) = params.gdark * params.eta/params.phi;		
c(1) = cdark;
p(1) = params.eta/params.phi;
r(1) = 0;
cslow(1) = cdark;

NumPts=length(params.tme);
TimeStep=params.tme(2)-params.tme(1);

% solve difference equations
for pnt = 2:NumPts
    r(pnt) = r(pnt-1) + TimeStep * (-params.sigma * r(pnt-1));
%     Adding Stim
    r(pnt) = r(pnt) + params.gamma * params.stm(pnt-1);
    p(pnt) = p(pnt-1) + TimeStep * (r(pnt-1) + params.eta - params.phi * p(pnt-1));
% 	c(pnt) = c(pnt-1) + TimeStep * (cur2ca * cgmp2cur * g(pnt-1)^cgmphill - beta * c(pnt-1));
    c(pnt) = c(pnt-1) + TimeStep * (cur2ca * cgmp2cur * g(pnt-1)^cgmphill /(1+(cslow(pnt-1)/cdark)) - params.beta * c(pnt-1));
    cslow(pnt) = cslow(pnt-1) - TimeStep * (params.betaSlow * (cslow(pnt-1)-c(pnt-1)));
    s(pnt) = smax / (1 + (c(pnt) / params.hillaffinity)^params.hillcoef);
    g(pnt) = g(pnt-1) + TimeStep * (s(pnt-1) - p(pnt-1) * g(pnt-1));
end
% determine current change
% ios = cgmp2cur * g.^cgmphill * 2 ./ (2 + cslow ./ cdark);
params.response = -cgmp2cur * g.^cgmphill * 1 ./ (1 + (cslow ./ cdark));


end


% % % % % % % 
% % % % % % % function [ios]=rModel_Aug2020(coef,time,stim,varargin)
% % % % % % % % function [ios]=rmodel(coef,time,stim,gdark)
% % % % % % % % Modified Dec_2019 Angueyra
% % % % % % % % On Dec_2019:
% % % % % % % % Found big discrepancies in quality of fit with rModel5, so trying to go back to previous version to keep those fits.
% % % % % % % % To do so, getting things from isetbio, since it was code to generate linearization
% % % % % % % % 1) Removed attempts to make slow Ca-feedback stronger (ie hillslow and slowboost).
% % % % % % % % Aug_2020:
% % % % % % % % Based off rModel6.m but forcing to match code that Fred uses
% % % % % % % % Will also remove weird scaling used for automatic fitting. Legacy code saved 
% % % % % % % 
% % % % % % % if size(time)~=size(stim)
% % % % % % %     error('Time and stimulus have to be the same size');
% % % % % % % end
% % % % % % % 
% % % % % % % 
% % % % % % % %% REWROTE TO MATCH ISETBIO
% % % % % % % % rescaling to get parameters into similar ranges Dec_2019
% % % % % % % kGc = coef(1)/1000;		%hillaffinity % affinity for Ca2+ (~0.5*dark Calcium)
% % % % % % % sigma = coef(2)/10;			% rhodopsin activity decay rate constant (1/sec) ()
% % % % % % % phi = sigma;              % phosphodiesterase activity decay rate constant (1/sec) ()
% % % % % % % eta = coef(3);				% phosphodiesterase activation rate constant (1/sec) ()
% % % % % % % % eta/phi~duration of response (50ms) (main determinant of response kinetics)
% % % % % % % betaSlow=coef(5)/1000;
% % % % % % % gamma = coef(6)/100; %opsin gain %so stimulus can be in R*/sec (this is rate of increase in opsin activity per R*/sec)
% % % % % % % 
% % % % % % % 
% % % % % % % %MODIFICATION HERE
% % % % % % % % gdark= coef(4)/10;
% % % % % % % darkCurrent= coef(4);
% % % % % % % 
% % % % % % % 
% % % % % % % % Fixed parameters
% % % % % % % n = 4;			%hillcoeff;  effective Ca2+ cooperativity to GC (2-4)
% % % % % % % cdark=1; % dark calcium concentration (in uM) <1uM (~300 -500 nM)
% % % % % % % h=3; %cgmphill
% % % % % % % 
% % % % % % % 
% % % % % % % k = 0.01;	%cgmp2cur % constant relating cGMP to current % gdark and cgmp2cur trade with each other to set dark current % was k = 0.02 in rModel6.m
% % % % % % % beta=9;
% % % % % % % gdark = (2 * darkCurrent / k)^(1/h);
% % % % % % % q = beta * cdark / darkCurrent;  % cur2ca %rate constant for calcium removal in 1/sec (tau>10ms)  %isetbio has a factor of 2 because of how second feedback affect calcium %rModel6.m has equivalent equation: q = 2.0 * beta * cdark / (k * gdark^h);
% % % % % % % smax = eta / phi * gdark * (1.0 + (cdark / kGc)^n);		% get smax using steady state
% % % % % % % 
% % % % % % % 
% % % % % % % 
% % % % % % % clear g s c p r
% % % % % % % NumPts=length(time);
% % % % % % % timeStep=time(2)-time(1);
% % % % % % % 
% % % % % % % %initializing variables
% % % % % % % opsin = NaN(1,NumPts);
% % % % % % % pde = NaN(1,NumPts);
% % % % % % % ca = NaN(1,NumPts);
% % % % % % % caSlow = NaN(1,NumPts);
% % % % % % % s = NaN(1,NumPts);
% % % % % % % cGMP = NaN(1,NumPts);
% % % % % % % 
% % % % % % % % initial conditions
% % % % % % % cGMP(1) = gdark;
% % % % % % % s(1) = gdark * eta/phi;		
% % % % % % % ca(1) = cdark;
% % % % % % % pde(1) = eta/phi;
% % % % % % % opsin(1) = 0;
% % % % % % % caSlow(1) = cdark;
% % % % % % % 
% % % % % % % % solve difference equations
% % % % % % % for pnt = 2:NumPts
% % % % % % %     opsin(pnt) = opsin(pnt-1) + timeStep * (gamma * stim(pnt) - sigma * opsin(pnt-1)); %from isetbio -> stim in R*/s
% % % % % % % 	pde(pnt) = pde(pnt-1) + timeStep * (opsin(pnt-1) + eta - phi * pde(pnt-1));
% % % % % % %     ca(pnt) = ca(pnt-1) + timeStep * (( (q * k * cGMP(pnt-1)^h) / ...
% % % % % % %         (1.0 + (caSlow(pnt-1)/cdark))) - beta * ca(pnt-1));
% % % % % % %     caSlow(pnt) = caSlow(pnt-1) - timeStep * (betaSlow * (caSlow(pnt-1)-ca(pnt-1)));
% % % % % % % 	s(pnt) = smax / (1 + (ca(pnt) / kGc)^n);
% % % % % % % 	cGMP(pnt) = cGMP(pnt-1) + timeStep * (s(pnt-1) - pde(pnt-1) * cGMP(pnt-1));
% % % % % % % end
% % % % % % % ios = - k * cGMP.^h * 1 ./ (1.0 + (caSlow ./ cdark));
% % % % % % % 
% % % % % % % 
% % % % % % % % display all model parameters
% % % % % % % if nargin == 4
% % % % % % %     verbose=varargin{1};
% % % % % % %     if verbose
% % % % % % %         fprintf ('Fit paramaters for riekeModel are:\n')
% % % % % % %         fprintf('\tsigma\t\t=\t%g\n',sigma)
% % % % % % %         fprintf('\tphi\t\t=\t%g\n',phi)
% % % % % % %         fprintf('\teta\t\t=\t%g\n',eta)
% % % % % % %         fprintf('\tk\t\t=\t%g\n',k)
% % % % % % %         fprintf('\th\t\t=\t%g\n',h)
% % % % % % %         fprintf('\tbeta\t\t=\t%g\n',beta)
% % % % % % %         fprintf('\tq\t\t=\t%g\n',q)
% % % % % % %         fprintf('\tsmax\t\t=\t%g\n',smax)
% % % % % % %         fprintf('\tKgc\t\t=\t%g\n',kGc)
% % % % % % %         fprintf('\tm\t\t=\t%g\n',n)
% % % % % % %         fprintf('\tbeta slow\t=\t%g\n',betaSlow)
% % % % % % %         fprintf('\tCadark\t\t=\t%g\n',cdark)
% % % % % % %         fprintf('\tcGMPdark\t=\t%g\n',gdark)
% % % % % % %     end
% % % % % % % end
% % % % % % % 
% % % % % % % end
% % % % % % % 
