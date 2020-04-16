function [ios]=vhModel6(coef,time,stim,varargin)
% function [ios]=rmodel6(coef,time,stim,gdark)
% Modified Apr_2020 Angueyra
% Updating to match rModel6 after revision to match isetbio
if size(time)~=size(stim)
    error('Time and stimulus have to be the same size');
end

% cdark            
% gdark;			% concentration of cGMP in darkness

% hillaffinity = coef(1);		% affinity for Ca2+ (~0.5*dark Calcium)
% sigma = coef(2);			% rhodopsin activity decay rate constant (1/sec) ()
% phi = sigma;              % phosphodiesterase activity decay rate constant (1/sec) ()
% eta = coef(3);				% phosphodiesterase activation rate constant (1/sec) ()
% % eta/phi~duration of response (50ms) (main determinant of response kinetics)
% gdark= coef(4);

%% REWROTE TO MATCH ISETBIO
% rescaling to get parameters into similar ranges Dec_2019
kGc = coef(1)/1000;		%hillaffinity % affinity for Ca2+ (~0.5*dark Calcium)
sigma = coef(2)/10;			% rhodopsin activity decay rate constant (1/sec) ()
phi = sigma;              % phosphodiesterase activity decay rate constant (1/sec) ()
eta = coef(3);				% phosphodiesterase activation rate constant (1/sec) ()
% eta/phi~duration of response (50ms) (main determinant of response kinetics)
gamma = coef(5)/100; %opsin gain %so stimulus can be in R*/sec (this is rate of increase in opsin activity per R*/sec)

%MODIFICATION HERE
% gdark= coef(4)/10;
darkCurrent= coef(4);

% Fixed parameters
n = 4;			%hillcoeff;  effective Ca2+ cooperativity to GC (2-4)
cdark=1; % dark calcium concentration (in uM) <1uM (~300 -500 nM)
h=3; %cgmphill


% This is rModel6
% k = 0.02;		%cgmp2cur % constant relating cGMP to current % gdark and cgmp2cur trade with each other to set dark current
% beta=9;
% gdark = (2 * darkCurrent / k)^(1/h);
% q = 2.0 * beta * cdark / (k * gdark^h); % cur2ca %rate constant for calcium removal in 1/sec (tau>10ms)  %isetbio has a factor of 2 because of how second feedback affect calcium
% smax = eta / phi * gdark * (1.0 + (cdark / kGc)^n);		% get smax using steady state
% I think here all factors of 2 disappear
k = 0.02;		%cgmp2cur % constant relating cGMP to current % gdark and cgmp2cur trade with each other to set dark current
beta=9;
gdark = (darkCurrent / k)^(1/h);
q = beta * cdark / (k * gdark^h); % cur2ca %rate constant for calcium removal in 1/sec (tau>10ms)  %isetbio has a factor of 2 because of how second feedback affect calcium
smax = eta / phi * gdark * (1.0 + (cdark / kGc)^n);		% get smax using steady state


clear g s c p r
NumPts=length(time);
timeStep=time(2)-time(1);

%initializing variables
opsin = NaN(1,NumPts);
pde = NaN(1,NumPts);
ca = NaN(1,NumPts);
s = NaN(1,NumPts);
cGMP = NaN(1,NumPts);


% initial conditions
cGMP(1) = gdark;
s(1) = gdark * eta/phi;		
ca(1) = cdark;
pde(1) = eta/phi;
opsin(1) = 0;




% solve difference equations
for pnt = 2:NumPts
    opsin(pnt) = opsin(pnt-1) + timeStep * (gamma * stim(pnt) - sigma * opsin(pnt-1)); %from isetbio -> stim in R*/s
	pde(pnt) = pde(pnt-1) + timeStep * (opsin(pnt-1) + eta - phi * pde(pnt-1));
    ca(pnt) = ca(pnt-1) + timeStep * ( (q * k * cGMP(pnt-1)^h) - beta * ca(pnt-1) );
	s(pnt) = smax / (1 + (ca(pnt) / kGc)^n);
	cGMP(pnt) = cGMP(pnt-1) + timeStep * (s(pnt-1) - pde(pnt-1) * cGMP(pnt-1));
end
ios = - k * cGMP.^h;



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
        fprintf('\tCadark\t\t=\t%g\n',cdark)
        fprintf('\tcGMPdark\t=\t%g\n',gdark)
    end
end

end

