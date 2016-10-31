%%
node_wn = tree.childBySplitValue('c02').childBySplitValue(true);

prepts=getProtocolSetting(node_wn,'prepts');
stmpts=getProtocolSetting(node_wn,'stmpts');
datapts=getProtocolSetting(node_wn,'datapts');
freqcut=node_wn.epochList.elements(1).protocolSettings('stimuli:Amp1:freqCutoff');
samplingInterval=getSamplingInterval(node_wn);

Data=riekesuite.getResponseMatrix(node_wn.epochList,'Amp1');
Data=BaselineSubtraction(Data,1,prepts);
Stim=riekesuite.getStimulusMatrix(node_wn.epochList,'Amp1');
Stim=BaselineSubtraction(Stim,1,prepts);

tAx=(0:length(Data)-1).*samplingInterval;
%
clear tempLF* ModelData
inc=1:size(Data,1);
inc=[2];
cnt=0;
shortpts=2000;
for i=inc
    cnt=cnt+1;
    tempLF(cnt,:)=LinearFilterFinder(Stim(i,prepts:prepts+stmpts-1),Data(i,prepts:prepts+stmpts-1),1/samplingInterval,freqcut*1);
    tempLF2(cnt,:)=LinearFilterFinder(Stim(i,prepts:prepts+shortpts),Data(i,prepts:prepts+shortpts),1/samplingInterval,freqcut*1);
end
if size(tempLF,1)==1
    LinearFilter = tempLF;
    LinearFilter2 = tempLF2;
else
    LinearFilter = mean(tempLF);
    LinearFilter2 = mean(tempLF2);
end
circLF=circshift(LinearFilter,[0,60]);
LinearFilter=LinearFilter - mean(circLF(120:end));
% LinearFilter(200:end-200)=0;
% LinearFilter(30:end-30)=0;
f1=getfigH(1);
lH=lineH(tAx(1:stmpts),LinearFilter,f1);
lH.linemarkers;
lH=lineH(tAx(1:shortpts+1),LinearFilter2,f1);
lH.line;lH.color([0 0 0]);
lH=lineH(tAx(1:stmpts),circshift(LinearFilter,[0,20]),f1);
lH.line;lH.color([.5 0 0]);
f1.XLim=[0 .005];


for i=1:size(Data,1)
    ModelData(i,:)=ifft((fft(Stim(i,prepts:prepts+stmpts-1))).*samplingInterval.*fft(LinearFilter).*samplingInterval)./samplingInterval;
end


i=1;
f2=getfigH(2);
lH=lineH(tAx(1:stmpts),Data(i,prepts:prepts+stmpts-1),f2);
lH.line;

lH=lineH(tAx(1:stmpts),ModelData(i,:),f2);
lH.line;
lH.color([0 0 0]);
f2.XLim=[0.1 .11];
%%
%% Pulses
lfcut=100;
r=struct;
r.node = tree.childBySplitValue('c02').childBySplitValue(false);


r.prepts=getProtocolSetting(r.node,'prepts');
r.stmpts=getProtocolSetting(r.node,'stmpts');
r.datapts=getProtocolSetting(r.node,'datapts');

i=1;

r.Data=BaselineSubtraction(riekesuite.getResponseVector(r.node.children(i).epochList.elements(1),'Amp1')',1,r.prepts);
r.Stim=riekesuite.getStimulusVector(r.node.children(i).epochList.elements(1),'Amp1');
r.Stim=BaselineSubtraction(r.Stim,1,r.prepts);
r.tAx= (0:length(r.Data)-1).*samplingInterval;
r.lf= zeros(size(r.tAx));
r.lf(1:lfcut)=LinearFilter(1:lfcut);
% r.lf(end-lfcut:end)=LinearFilter(end-lfcut:end);
r.mData=real(ifft((fft(r.Stim)).*samplingInterval.*fft(r.lf).*samplingInterval)./samplingInterval);

f4=getfigH(4);
lH=lineH(r.tAx,r.Stim,f4);
lH.linemarkers;

f3=getfigH(3);
lH=lineH(r.tAx,r.Data,f3);
lH.line;

lH=lineH(r.tAx,r.mData,f3);
lH.line;
lH.color([0 0 0]);
% f3.XLim=[r.prepts*samplingInterval-0.005 r.prepts*samplingInterval+.025];
% f4.XLim=[r.prepts*samplingInterval-0.005 r.prepts*samplingInterval+.025];
