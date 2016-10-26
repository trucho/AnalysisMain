function tree=vStepsAnalysis(dir,ANALYSIS_FILTER_VIEW_FOLDER)
%% Voltage Steps
clear
startup
dir.exp='/20161012A_vPulseFamily.mat';
dir.exp='/20161025A_vStepsBa.mat';
params.exp='vSteps';
list=riekesuite.analysis.loadEpochList([[dir.li_sy2root,'/00_MatlabExports'],dir.exp],[dir.li_sy2root]);
fprintf('List loaded: %s\n',dir.exp(2:end-4));

%% write epoch start times since experiment started
%
labelSplitter=@(epoch)(epoch.cell.label);
labelMap = riekesuite.util.SplitValueFunctionAdapter.buildMap(list,labelSplitter);
tree = riekesuite.analysis.buildTree(list,{labelMap});
for i=1:tree.children.length
    sT{i}=writestartTime(tree.children(i),1);
end
BIPBIP;
%
%%
list=list.sortedBy('protocolSettings(user:startTime)');

rcSplitter=@(epoch)splitAutoRC(epoch);
rcMap = riekesuite.util.SplitValueFunctionAdapter.buildMap(list,rcSplitter);


labelSplitter=@(epoch)(epoch.cell.label);
labelMap = riekesuite.util.SplitValueFunctionAdapter.buildMap(list,labelSplitter);



tree = riekesuite.analysis.buildTree(list,{labelMap,rcMap,'protocolSettings(pulseSignal)'});
fprintf('Tree: \n');
tree.visualize
BIPBIP();
%%
%% General stuff on cell level
clear list
disp(['running ''sqerg_preanalysis'' ...']);
params=struct;
for i=1:tree.children.length
    fprintf('Running %s: %g of %g   \n',getcellname(tree.children(i)),i,tree.children.length);
    generic_preanalysis(tree.children(i),params);
end
BIPBIP;
%%
gui = epochTreeGUI(tree);
% gui.figure.Position=[50 5 1255 828];
gui.figure.Position=[-1710 1 1604 1035];

% %% single one
% figure(10)
% set(gcf,'Position',[0 224 1111 835]);
% node = tree.childBySplitValue('c01').childBySplitValue(true).children(1);
% generic_screenepochs(node,10,0,params);
%% Getting mean from selected epochs for each light level
fprintf('running eyemovements_screenepochs...\n');
params=struct;
params.plotMean=1;
leaves=tree.leafNodes.elements;
figure(10)
set(gcf,'Position',[0 224 1111 835]);
for i=1:length(leaves)
    fprintf('%d of %d \n',i,length(leaves));
    generic_screenepochs(leaves(i),10,0,params);
end
BIPBIP;
close(figure(10))
%%
node=tree.children(3);
hGUI=vPulses_leakSub(node,[],10);
%%


%% vLinearFilter
node_wn = tree.childBySplitValue('c06').childBySplitValue(true);


prepts=getProtocolSetting(node_wn,'prepts');
stmpts=getProtocolSetting(node_wn,'stmpts');
datapts=getProtocolSetting(node_wn,'datapts');
freqcut=node_wn.epochList.elements(1).protocolSettings('stimuli:Amp1:freqCutoff');
samplingInterval=getSamplingInterval(node_wn);

Data=riekesuite.getResponseMatrix(node_wn.epochList,'Amp1');
Data=BaselineSubtraction(Data,1,prepts);
Stim=riekesuite.getStimulusMatrix(node_wn.epochList,'Amp1');

tAx=(0:length(Data)-1).*samplingInterval;
%
clear tempLF* ModelData
inc=1:size(Data,1);
inc=[1];
cnt=0;
shortpts=2000;
for i=inc
    cnt=cnt+1;
    tempLF(cnt,:)=LinearFilterFinder(Stim(i,prepts:prepts+stmpts),Data(i,prepts:prepts+stmpts),1/samplingInterval,freqcut*2.0);
    tempLF2(cnt,:)=LinearFilterFinder(Stim(i,prepts:prepts+shortpts),Data(i,prepts:prepts+shortpts),1/samplingInterval,freqcut*2.0);
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
lH=lineH(tAx(1:stmpts+1),LinearFilter,f1);
lH.linemarkers;
lH=lineH(tAx(1:shortpts+1),LinearFilter2,f1);
lH.line;lH.color([0 0 0]);
lH=lineH(tAx(1:stmpts+1),circshift(LinearFilter,[0,20]),f1);
lH.linemarkers;
f1.XLim=[0 .005];


for i=1:size(Data,1)
    ModelData(i,:)=ifft((fft(Stim(i,prepts:prepts+stmpts))).*samplingInterval.*fft(LinearFilter).*samplingInterval)./samplingInterval;
end
ModelData=BaselineSubtraction(ModelData,1,prepts);

i=1;
f2=getfigH(2);
lH=lineH(tAx(1:stmpts+1),Data(i,prepts:prepts+stmpts),f2);
lH.line;

lH=lineH(tAx(1:stmpts+1),ModelData(i,:),f2);
lH.line;
lH.color([0 0 0]);
f2.XLim=[0.1 .11];
%% Pulses
r=struct;
% r.node = tree.childBySplitValue('noRC').childBySplitValue('squirrellab.protocols.vPulseFamily');
% r.node = tree.childBySplitValue('noRC').childBySplitValue('squirrellab.protocols.vTails');

r.node = tree.childBySplitValue('c06').childBySplitValue(false);
% r.node = tree.children(1).childBySplitValue('squirrellab.protocols.vTails');

r.prepts=getProtocolSetting(r.node,'prepts');
r.stmpts=getProtocolSetting(r.node,'stmpts');
r.datapts=getProtocolSetting(r.node,'datapts');

i=1;
lfcut=30;
r.Data=BaselineSubtraction(riekesuite.getResponseVector(r.node.epochList.elements(i),'Amp1')',1,r.prepts);
r.Stim=riekesuite.getStimulusVector(r.node.epochList.elements(i),'Amp1')*1;
r.tAx= (0:length(r.Data)-1).*samplingInterval;
r.lf= zeros(size(r.tAx));
r.lf(1:lfcut)=LinearFilter(1:lfcut);
% r.lf(end-lfcut:end)=LinearFilter(end-lfcut:end);
r.lf=r.lf;
r.mData=real(ifft((fft(r.Stim)).*samplingInterval.*fft(r.lf).*samplingInterval)./samplingInterval);
r.mData=BaselineSubtraction(r.mData,1,r.prepts);

f4=getfigH(4);
lH=lineH(r.tAx,r.Stim,f4);
lH.linemarkers;

f3=getfigH(3);
lH=lineH(r.tAx,r.Data,f3);
lH.line;

lH=lineH(r.tAx,r.mData,f3);
lH.line;
lH.color([0 0 0]);
f3.XLim=[r.prepts*samplingInterval-0.005 r.prepts*samplingInterval+.025];
% f3.XLim = [0 1];
end


function tree=vStepsAnalysis3(dir,ANALYSIS_FILTER_VIEW_FOLDER)
%% Voltage Steps
clear
startup
dir.exp='/20161012A_vPulseFamily.mat';
dir.exp='/20161025A_vStepsBa.mat';
params.exp='vSteps';
list=riekesuite.analysis.loadEpochList([[dir.li_sy2root,'/00_MatlabExports'],dir.exp],[dir.li_sy2root]);
fprintf('List loaded: %s\n',dir.exp(2:end-4));

%% write epoch start times since experiment started
%
labelSplitter=@(epoch)(epoch.cell.label);
labelMap = riekesuite.util.SplitValueFunctionAdapter.buildMap(list,labelSplitter);
tree = riekesuite.analysis.buildTree(list,{labelMap});
for i=1:tree.children.length
    sT{i}=writestartTime(tree.children(i),1);
end
BIPBIP;
%
%%
list=list.sortedBy('protocolSettings(user:startTime)');

rcSplitter=@(epoch)splitAutoRC(epoch);
rcMap = riekesuite.util.SplitValueFunctionAdapter.buildMap(list,rcSplitter);


labelSplitter=@(epoch)(epoch.cell.label);
labelMap = riekesuite.util.SplitValueFunctionAdapter.buildMap(list,labelSplitter);



tree = riekesuite.analysis.buildTree(list,{labelMap,rcMap,'protocolSettings(pulseSignal)'});
fprintf('Tree: \n');
tree.visualize
BIPBIP();
%%
%% General stuff on cell level
clear list
disp(['running ''sqerg_preanalysis'' ...']);
params=struct;
for i=1:tree.children.length
    fprintf('Running %s: %g of %g   \n',getcellname(tree.children(i)),i,tree.children.length);
    generic_preanalysis(tree.children(i),params);
end
BIPBIP;
%%
gui = epochTreeGUI(tree);
% gui.figure.Position=[50 5 1255 828];
gui.figure.Position=[-1710 1 1604 1035];
%%
%% Getting mean from selected epochs for each light level
fprintf('running eyemovements_screenepochs...\n');
params=struct;
params.plotMean=1;
leaves=tree.leafNodes.elements;
figure(10)
set(gcf,'Position',[0 224 1111 835]);
for i=1:length(leaves)
    fprintf('%d of %d \n',i,length(leaves));
    generic_screenepochs(leaves(i),10,0,params);
end
BIPBIP;
close(figure(10))
%%
node=tree.children(3);
hGUI=vPulses_leakSub(node,[],10);
%%
end


function tree=vStepsAnalysis2(dir,ANALYSIS_FILTER_VIEW_FOLDER)
%% Voltage Steps
clear
startup
dir.exp='/vSteps_SCone.mat';
params.exp='vSteps';
list=riekesuite.analysis.loadEpochList([[dir.li_dbroot,'/OvationExports'],dir.exp],[dir.li_dbroot]);
fprintf('List loaded: %s\n',dir.exp(2:end-4));
% 
%% write epoch start times since experiment started
%
labelSplitter=@(epoch)(epoch.cell.label);
splitMap = riekesuite.util.SplitValueFunctionAdapter.buildMap(list,labelSplitter);
tree = riekesuite.analysis.buildTree(list,{splitMap});
for i=1:tree.children.length
    sT{i}=writestartTime(tree.children(i),1);
end
%
%%
list=list.sortedBy('protocolSettings(user:startTime)');
labelSplitter=@(epoch)(epoch.cell.label);
splitMap = riekesuite.util.SplitValueFunctionAdapter.buildMap(list,labelSplitter);

tree = riekesuite.analysis.buildTree(list,{splitMap,'protocolSettings(pulseSignal)'});
fprintf('Tree: \n');
% tree.visualize
BIPBIP();
%%
%% General stuff on cell level
clear list
disp(['running ''sqerg_preanalysis'' ...']);
params=struct;
for i=1:tree.children.length
    fprintf('Running %s: %g of %g   \n',getcellname(tree.children(i)),i,tree.children.length);
    generic_preanalysis(tree.children(i),params);
end
BIPBIP;
%%

a=49;
b=100;

a=540;
b=560;


% Data plot
spdata=findobj('tag','spdata');
set(spdata,'XLim',[a b])
% SubData plot
spsub=findobj('tag','spsub');
set(spsub,'XLim',[a b])
% Stimulus
spstim=findobj('tag','spstim');
set(spstim,'XLim',[a b])

end
