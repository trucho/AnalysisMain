function [ios]=riekemodelstim3(coef,time,stim,gdark)


if size(time)~=size(stim)
    error('Time and stimulus have to be the same size');
end

% cdark            
% gdark;			% concentration of cGMP in darkness

beta = coef(1);             % rate constant for calcium removal in 1/sec (tau>10ms)
hillcoef = coef(2);			% effective Ca2+ cooperativity to GC (2-4)
hillaffinity = coef(3);		% affinity for Ca2+ (~0.5*dark Calcium)
sigma = coef(4);			% rhodopsin activity decay rate constant (1/sec) ()
phi = coef(5);              % phosphodiesterase activity decay rate constant (1/sec) ()
eta = coef(6);				% phosphodiesterase activation rate constant (1/sec) ()

% eta/phi~duration of response (50ms) (main determinant of response kinetics)

betaSlow=coef(7);

% Fixed parameters
cdark=0.5; % dark calcium concentration (in uM????) <1uM (~300 -500 nM)
cgmphill=3;
cgmp2cur = 10e-3;%8e-3;		% constant relating cGMP to current
% gdark and cgmp2cur trade with each other to set dark current

cur2ca = beta * cdark / (cgmp2cur * gdark^cgmphill);                % get q using steady state
smax = eta/phi * gdark * (1 + (cdark / hillaffinity)^hillcoef);		% get smax using steady state

clear g s c p r

% initial conditions
g(1) = gdark;
s(1) = gdark * eta/phi;		
c(1) = cdark;
p(1) = eta/phi;
r(1) = 0;
cslow(1) = cdark;

NumPts=length(time);
TimeStep=time(2)-time(1);

% solve difference equations
for pnt = 2:NumPts
	r(pnt) = r(pnt-1) + TimeStep * (-sigma * r(pnt-1));
%     Adding Stim
    r(pnt) = r(pnt) + stim(pnt);
	p(pnt) = p(pnt-1) + TimeStep * (r(pnt-1) + eta - phi * p(pnt-1));
	c(pnt) = c(pnt-1) + TimeStep * (cur2ca * cgmp2cur * g(pnt-1)^3 - beta * c(pnt-1));
    cslow(pnt) = cslow(pnt-1) - TimeStep * (betaSlow * (cslow(pnt-1)-c(pnt-1)));
	s(pnt) = smax / (1 + (c(pnt) / hillaffinity)^hillcoef);
	g(pnt) = g(pnt-1) + TimeStep * (s(pnt-1) - p(pnt-1) * g(pnt-1));
end
% determine current change
% ios = cgmp2cur * g.^cgmphill * 2 ./ (2 + cslow ./ cdark);
ios = cgmp2cur * g.^cgmphill * 1 ./ (1 + cslow ./ cdark);

end

