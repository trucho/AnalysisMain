load('/Users/angueyraaristjm/Dropbox/ConeNoiseMechanism/2016_EyeMovements/ModelFitting/BinaryNoiseExmapleData/BinaryNoiseClarkSingle.mat')
fH = getfigH(2);
% lH=lineH(hGUI.exTime,AdaptingStepResponse,fH); 
% lH.linek;lH.h.LineWidth=1;
lH=lineH(hGUI.exTime,AdaptingStepPrediction,fH); 
lH.liner;lH.h.LineWidth=2;
% lH=lineH(hGUI.exTime,hGUI.exData(2,:)*1.6,fH); 
% lH.lineg;lH.h.LineWidth=1;
lH=lineH(hGUI.exTime,hGUI.exModel(2,:)*1.73,fH); 
lH.lineb;lH.h.LineWidth=1;
%%
figure(2)
plot(hGUI.exModel(2,:)./AdaptingStepPrediction)
%%
load('/Users/angueyraaristjm/Dropbox/ConeNoiseMechanism/2016_EyeMovements/ModelFitting/SineExampleData/SineClarkSingle.mat')
fH = getfigH(2);
i = 4 ;
lH=lineH(hGUI.coneExTme,AdaptingStepResponse(1+length(hGUI.coneExTme)*(i-1):length(hGUI.coneExTme)*i),fH); 
% lH=lineH(1:length(AdaptingStepResponse),AdaptingStepResponse,fH); 
lH.linek;lH.h.LineWidth=1;
lH=lineH(hGUI.coneExTme,AdaptingStepPrediction(1+length(hGUI.coneExTme)*(i-1):length(hGUI.coneExTme)*i),fH); 
% lH=lineH(1:length(AdaptingStepResponse),AdaptingStepPrediction,fH); 
lH.liner;lH.h.LineWidth=2;
lH=lineH(hGUI.coneExTme,15+hGUI.coneExData(i,:)*1.0,fH); 
lH.lineg;lH.h.LineWidth=1;
lH=lineH(hGUI.coneExTme-0.05,15+hGUI.coneExFit(i,:)*1.0,fH); 
lH.lineb;lH.h.LineWidth=1;