function ergSquirrel()
%%
clear
startup
dir.exp='/ergtest.mat';
params.exp='erg';
list=riekesuite.analysis.loadEpochList([[dir.li_dbroot,'/OvationExports'],dir.exp],[dir.li_dbroot]);
labelSplitter=@(epoch)(epoch.cell.label);
splitMap = riekesuite.util.SplitValueFunctionAdapter.buildMap(list,labelSplitter);
stmptsSplitter=@(epoch)(getProtocolSetting(epoch,'datapts'));
splitMap2 = riekesuite.util.SplitValueFunctionAdapter.buildMap(list,stmptsSplitter);
tree2 = riekesuite.analysis.buildTree(list,{splitMap,splitMap2});
tree2.visualize
BIPBIP();
%% Tagging as flash vs. step
tree=tree2;


%%
end