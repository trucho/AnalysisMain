function tree=vStepsAnalysis(dir,ANALYSIS_FILTER_VIEW_FOLDER)
%% Voltage Steps
clear
startup
dir.exp='/20161012A_vPulseFamily.mat';
params.exp='vSteps';
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
gui = epochTreeGUI(tree);
gui.figure.Position=[50 5 1255 828];
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
