function tree=StemEyeCups(dir,ANALYSIS_FILTER_VIEW_FOLDER)
%% Voltage Steps
clear
startup
dir.exp='/stec_20150423_vSteps.mat';
params.exp='stec';
list=riekesuite.analysis.loadEpochList([[dir.li_dbroot,'/OvationExports'],dir.exp],[dir.li_dbroot,'/stemEyecups']);
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
% %
% %%
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

% a=540;
% b=560;


% Data plot
spdata=findobj('tag','spdata');
set(spdata,'XLim',[a b])
% SubData plot
spsub=findobj('tag','spsub');
set(spsub,'XLim',[a b])
% Stimulus
spstim=findobj('tag','spstim');
set(spstim,'XLim',[a b])



%%

for i=1:node.children.length
    results{i}=toMatlabStruct(node.children(i).custom.get('results'));
end

leakresults=toMatlabStruct(node.childBySplitValue(-70).custom.get('results'));

vH=node.children(1).epochList.elements(1).protocolSettings('stimuli:Amp1:mean');
for i=1:node.children.length
   vS(i)=node.children(i).splitValue; 
end
vSdelta=-(vS-vH)/10;


f1=getfigH(1);

i=8;
lH=line(results{1}.tAxis,results{i}.Mean,'Parent',f1);
set(lH,'DisplayName','MyNameIs','Line','-','LineWidth',1,'Marker','none','Color',[0 0 0])
lH=line(results{1}.tAxis,leakresults.Mean*vSdelta(i),'Parent',f1);
set(lH,'DisplayName','MyNameIs','Line','-','LineWidth',1,'Marker','none','Color',[0.5 0.5 0.5])









%% All protocols
clear
startup
dir.exp='/stec_20150423.mat';
params.exp='stec';
list=riekesuite.analysis.loadEpochList([[dir.li_dbroot,'/OvationExports'],dir.exp],[dir.li_dbroot,'/stemEyecups']);
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
% dpsplitter=@(epoch)(getProtocolSetting(epoch,'datapts'));
% dpMap = riekesuite.util.SplitValueFunctionAdapter.buildMap(list,dpsplitter);
% tree = riekesuite.analysis.buildTree(list,{splitMap,'protocolSettings(displayName)',dpMap});
tree = riekesuite.analysis.buildTree(list,{splitMap,'protocolSettings(displayName)'});
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
%%
%%
