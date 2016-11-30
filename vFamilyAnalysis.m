function tree=vFamilyAnalysis(dir)
global ANALYSIS_FILTER_VIEW_FOLDER
%% Voltage Steps
clear
startup
dir.exp='/20161123A_Ivabradine.mat';
params.exp='vFamily';
list=riekesuite.analysis.loadEpochList([[dir.li_sy2root,'/00_MatlabExports'],dir.exp],[dir.li_sy2root]);
fprintf('List loaded: %s\n',dir.exp(2:end-4));
% 
% %% write epoch start times since experiment started
% %
% labelSplitter=@(epoch)(epoch.cell.label);
% splitMap = riekesuite.util.SplitValueFunctionAdapter.buildMap(list,labelSplitter);
% tree = riekesuite.analysis.buildTree(list,{splitMap});
% for i=1:tree.children.length
%     sT{i}=writestartTime(tree.children(i),1);
% end
% BIPBIP;
% %
%%
list=list.sortedBy('protocolSettings(user:startTime)');
rcSplitter=@(epoch)splitAutoRC(epoch);
rcMap = riekesuite.util.SplitValueFunctionAdapter.buildMap(list,rcSplitter);

labelSplitter=@(epoch)(epoch.cell.label);
labelMap = riekesuite.util.SplitValueFunctionAdapter.buildMap(list,labelSplitter);

tree = riekesuite.analysis.buildTree(list,{labelMap,rcMap,'protocolSettings(pulseSignal)'});
% tree = riekesuite.analysis.buildTree(list,{labelMap,'protocolSettings(pulseSignal)'});
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
gui = epochTreeGUI(tree);
gui.figure.Position=[50 5 1255 828];
% gui.figure.Position=[-1710 1 1604 1035];

% %% single one
% figure(10)
% set(gcf,'Position',[0 224 1111 835]);
% node = tree.childBySplitValue('c01').childBySplitValue(true).children(1);
% generic_screenepochs(node,10,0,params);
%% Getting mean from selected epochs for each light level
fprintf('running eyemovements_screenepochs...\n');
params=struct;
params.plotMean=1;
figure(10)
set(gcf,'Position',[0 224 1111 835]);
for c=8%1:tree.children.length
    % get mean values on non-autoRC epochs
    leaves=tree.children(c).childBySplitValue(false).leafNodes.elements;
    for i=1:length(leaves)
        fprintf('%d of %d \n',i,length(leaves));
        generic_screenepochs(leaves(i),10,0,params);
    end
end
BIPBIP;
close(figure(10))
%%
node = tree.childBySplitValue('c03').childBySplitValue(false);
hGUI=vPulses_screenLeakNoiseSine(node,[],10);
% hGUI=vPulses_leakSub(node,[],10);
% set(hGUI.figH,'Position',[-1526        -117        1189         889])
%%

node = tree.childBySplitValue('c09').childBySplitValue(true);
hGUI=vRC_browseFilters(node,[],10);

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
