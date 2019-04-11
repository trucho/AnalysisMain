% function tree=vFamilyAnalysis(dir)
global ANALYSIS_FILTER_VIEW_FOLDER %#ok<*NUSED>
%% Voltage Steps
clear
startup
dir.li_dbroot='/Users/angueyraaristjm/Documents/LiData/Organoids/';
dir.exp='all_vPF.mat';
params.exp='vFamily';
list=riekesuite.analysis.loadEpochList([[dir.li_dbroot],dir.exp],[dir.li_dbroot]);
fprintf('List loaded: %s\n',dir.exp);
% 
%% write epoch start times since experiment started


% %
% labelSplitter=@(epoch)splitonCellLabel_addDate(epoch);
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

% labelSplitter=@(epoch)(epoch.cell.label);
labelSplitter=@(epoch)splitonCellLabel_addDate(epoch);
labelMap = riekesuite.util.SplitValueFunctionAdapter.buildMap(list,labelSplitter);

tree = riekesuite.analysis.buildTree(list,{labelMap,rcMap,'protocolSettings(pulseSignal)'});
% tree = riekesuite.analysis.buildTree(list,{labelMap,'protocolSettings(pulseSignal)'});
fprintf('Tree: \n');
% tree.visualize
BIPBIP();
%%
%% General stuff on cell level
clear list
disp(['running ''generic_preanalysis'' ...']);
params=struct;
for i=1:tree.children.length
    fprintf('Running %s: %g of %g   \n',getcellname(tree.children(i)),i,tree.children.length);
    generic_preanalysis(tree.children(i),params);
end
BIPBIP;
%%
gui = epochTreeGUI(tree);
% gui.figure.Position=[50 5 1255 828];
gui.figure.Position=[-2379        -409        2112        1415];

% I'm in 20190227c01
%% single one
figure(10)
set(gcf,'Position',[0 224 1111 835]);
node = tree.childBySplitValue('20190121c15').childBySplitValue(false).children(1);
generic_screenepochs(node,10,0,params);
%% Getting mean from selected epochs for each light level
fprintf('running screenepochs...\n');
params=struct;
params.plotMean=1;
params.silent = 1;
figure(10)
set(gcf,'Position',[0 224 1111 835]);
for c=1%:tree.children.length
    fprintf('%s\n',getcellname(tree.children(c)));
    % get mean values on non-autoRC epochs
    leaves=tree.children(c).childBySplitValue(false).leafNodes.elements;
    for i=1%:length(leaves)
        fprintf('   %d of %d: %4.0d mV:   ',i,length(leaves),leaves(i).splitValue);
        generic_screenepochs(leaves(i),10,0,params);
    end
end
BIPBIP;
close(figure(10))
%%
i = 19;
node = tree.children(i).childBySplitValue(false);

% NOTE: Selected epochs trying to avoind run down, but may have biased results towards non CsMs perfused epochs.
% cellname (type - internal) -> comment
% 20181216c01 (cone - KAsp) -> bad leak subtraction
% 20181218c01 (cone) -> not great, but IV is not terrible
% 20181218c02 (idk) -> bad leak subtraction (over)
% 20181218c03 (type) -> bad leak subtraction (over)
% 20190121c01 (Cone - CsMs) -> OK-ish
% 20190121c04 (idk - CsMs) -> small inward currents. OK-ish I guess
% 20190121c06 (cone - CsMs) -> no inward current. OK-ish
% 20190121c08 (cone - CsMs) -> good. big currents
% 20190121c09 (cone - CsMs) -> no inward but ok
% 20190121c12 (cone - CsMs) -> good. big current
% 20190121c13 (cone - CsMs) -> good. almost no currents. Some Ih
% 20190121c14 (cone - CsMs) -> good. no inward (but seems like steady state inactivation)
% 20190121c15 (cone - CsMs) -> very good. big current
% 20190121c17 (rod - CsMs) -> finally a rod. no inward, small currents overall but some outward and some Ih
% 20190123c01 (cone - CsMs) -> big Ih, but not much outward. is it late in recording?
% 20190123c02 (cone - CsMs) -> good. big currents. huge Ih and smaller outward (midway during recording?)
% 20190123c03 (cone - CsMs) -> good. small inward but probably because of steady-state inactivation. small outward but big Ih
% 20190123c04 (rod - CsMs) -> small currents, no inward but some outward and some Ih
% 20190123c05 (rod - CsMs) -> small currents, some leak subtraction artifact. No inward, some Ih but no outward.
fprintf('%s\n',getcellname(node));
hGUI=vPulses_leakSub(node,[],10);
% set(hGUI.figH,'Position',[-2379        -409        2112        1415])
%%

node = tree.childBySplitValue('c09').childBySplitValue(true);
hGUI=vRC_browseFilters(node,[],10);

%% Pulses
r=struct;
% r.node = tree.childBySplitValue('noRC').childBySplitValue('squirrellab.protocols.vPulseFamily');
% r.node = tree.childBySplitValue('noRC').childBySplitValue('squirrellab.protocols.vTails');

r.node = tree.childBySplitValue('c15').childBySplitValue(false);
% r.node = tree.children(1).childBySplitValue('squirrellab.protocols.vTails');

r.prepts=getProtocolSetting(r.node,'prepts');
r.stmpts=getProtocolSetting(r.node,'stmpts');
r.datapts=getProtocolSetting(r.node,'datapts');

i=1;
lfcut=30;
r.Data=BaselineSubtraction(riekesuite.getResponseVector(r.node.epochList.elements(i),'Amp1')',1,r.prepts);
r.Stim=riekesuite.getStimulusVector(r.node.epochList.elements(i),'Amp1')*1;
r.tAx= (0:length(r.Data)-1).*getSamplingInterval(node);
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








% end
