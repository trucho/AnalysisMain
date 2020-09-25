function [params]=RiekeModel_FredAug2020(params)

if (params.biophysFlag == 1)
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
else   % linear
    % Compute the response
    filter = params.ScFact .* (((params.tme./params.TauR).^3)./(1+((params.tme./params.TauR).^3))) .* exp(-((params.tme./params.TauD))); 
    params.response = real(ifft(fft(params.stm) .* fft(filter))) - params.darkCurrent;
end

end

