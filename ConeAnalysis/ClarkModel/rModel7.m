
function [ios]=rModel7(coef,time,stim,varargin)
% function [ios]=rmodel(coef,time,stim,gdark)
% Modified Dec_2019 Angueyra
% On Dec_2019:
% Found big discrepancies in quality of fit with rModel5, so trying to go back to previous version to keep those fits.
% To do so, getting things from isetbio, since it was code to generate linearization
% 1) Removed attempts to make slow Ca-feedback stronger (ie hillslow and slowboost).

if size(time)~=size(stim)
    error('Time and stimulus have to be the same size');
end


%% REWROTE USING AdaptationModel/RiekeModel.m

hillcoef = coef(1);		%hillaffinity % affinity for Ca2+ (~0.5*dark Calcium)
sigma = coef(2);			% rhodopsin activity decay rate constant (1/sec) ()
phi = sigma;              % phosphodiesterase activity decay rate constant (1/sec) ()
eta = coef(3);				% phosphodiesterase activation rate constant (1/sec) ()
% eta/phi~duration of response (50ms) (main determinant of response kinetics)
darkCurrent= coef(4);
betaSlow=coef(5);

% Fixed parameters
cdark=0.5; % dark calcium concentration (in uM????) <1uM (~300 -500 nM)
cgmphill=3;
cgmp2cur = 10e-3;%8e-3;		% constant relating cGMP to current
% gdark and cgmp2cur trade with each other to set dark current
beta = 9;
gdark = (2 * darkCurrent / cgmp2cur)^(1/cgmphill);
hillaffinity = 0.3;
gamma = 10; %opsin gain


cur2ca = beta * cdark / darkCurrent;                % get q using steady state
smax = eta/phi * gdark * (1 + (cdark / hillaffinity)^hillcoef);		% get smax using steady state

clear g s c p r

NumPts=length(time);
TimeStep=time(2)-time(1);

%initializing variables
r = NaN(1,NumPts);
p = NaN(1,NumPts);
c = NaN(1,NumPts);
cslow = NaN(1,NumPts);
s = NaN(1,NumPts);
g = NaN(1,NumPts);


% initial conditions
g(1) = gdark;
s(1) = gdark * eta/phi;		
c(1) = cdark;
p(1) = eta/phi;
r(1) = 0;
cslow(1) = cdark;



% solve difference equations
for pnt = 2:NumPts
    r(pnt) = r(pnt-1) + TimeStep * (-sigma * r(pnt-1));
%     Adding Stim
    r(pnt) = r(pnt) + TimeStep * (gamma * stim(pnt-1));
    p(pnt) = p(pnt-1) + TimeStep * (r(pnt-1) + eta - phi * p(pnt-1));
% 	c(pnt) = c(pnt-1) + TimeStep * (cur2ca * cgmp2cur * g(pnt-1)^cgmphill - beta * c(pnt-1));
    c(pnt) = c(pnt-1) + TimeStep * (cur2ca * cgmp2cur * g(pnt-1)^cgmphill /(1+(cslow(pnt-1)/cdark)) - beta * c(pnt-1));
    cslow(pnt) = cslow(pnt-1) - TimeStep * (betaSlow * (cslow(pnt-1)-c(pnt-1)));
    s(pnt) = smax / (1 + (c(pnt) / hillaffinity)^hillcoef);
    g(pnt) = g(pnt-1) + TimeStep * (s(pnt-1) - p(pnt-1) * g(pnt-1));
end
% determine current change
% ios = cgmp2cur * g.^cgmphill * 2 ./ (2 + cslow ./ cdark);
ios = -cgmp2cur * g.^cgmphill * 1 ./ (1 + (cslow ./ cdark));




% display all model parameters
if nargin == 4
    verbose=varargin{1};
    if verbose
        fprintf ('Fit paramaters for riekeModel are:\n')
        fprintf('\tsigma\t\t=\t%g\n',sigma)
        fprintf('\tphi\t\t=\t%g\n',phi)
        fprintf('\teta\t\t=\t%g\n',eta)
        fprintf('\tk\t\t=\t%g\n',k)
        fprintf('\th\t\t=\t%g\n',h)
        fprintf('\tbeta\t\t=\t%g\n',beta)
        fprintf('\tq\t\t=\t%g\n',q)
        fprintf('\tsmax\t\t=\t%g\n',smax)
        fprintf('\tKgc\t\t=\t%g\n',kGc)
        fprintf('\tm\t\t=\t%g\n',n)
        fprintf('\tbeta slow\t=\t%g\n',betaSlow)
        fprintf('\tCadark\t\t=\t%g\n',cdark)
        fprintf('\tcGMPdark\t=\t%g\n',gdark)
    end
end

end

