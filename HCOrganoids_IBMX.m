% function tree=vFamilyAnalysis(dir)
global ANALYSIS_FILTER_VIEW_FOLDER %#ok<*NUSED>
%% Voltage Steps
clear
startup
dir.li_dbroot='/Users/angueyraaristjm/Documents/LiData/Organoids/';
dir.exp='all_IBMX.mat';
params.exp='vFamily';
fprintf('Loading list....\n');
list=riekesuite.analysis.loadEpochList([[dir.li_dbroot],dir.exp],[dir.li_dbroot]);
fprintf('List loaded: %s\n',dir.exp);
% 
%% write epoch start times since experiment started


% labelSplitter=@(epoch)splitonCellLabel_addDate(epoch);
% splitMap = riekesuite.util.SplitValueFunctionAdapter.buildMap(list,labelSplitter);
% tree = riekesuite.analysis.buildTree(list,{splitMap});
% for i=1:tree.children.length
%     sT{i}=writestartTime(tree.children(i),1);
% end
% BIPBIP;
% %%



list=list.sortedBy('protocolSettings(user:startTime)');

% labelSplitter=@(epoch)(epoch.cell.label);
labelSplitter=@(epoch)splitonCellLabel_addDate(epoch);
labelMap = riekesuite.util.SplitValueFunctionAdapter.buildMap(list,labelSplitter);

tree = riekesuite.analysis.buildTree(list,{labelMap});
fprintf('Tree: \n');
% tree.visualize
BIPBIP();
%%



p=struct;
p.Position = [-3199          48        1450         900];
p.Normalize = 0;
hGUI=ibmx_OneCell(tree.children(6),p,2);



% % % %% General stuff on cell level -> Not required here
% % % clear list
% % % disp(['running ''generic_preanalysis'' ...']);
% % % params=struct;
% % % for i=1:tree.children.length
% % %     fprintf('Running %s: %g of %g   \n',getcellname(tree.children(i)),i,tree.children.length);
% % %     generic_preanalysis(tree.children(i),params);
% % % end
% % % BIPBIP;
%% Getting mean from selected epochs for cell (SILENTLY)
fprintf('running screenepochs...\n');
p=struct;
p.saveResults = 1;
p.silent = 1;
figure(10)
set(gcf,'Position',[0 224 1111 835]);
% process data (hard coded)
for i=1:tree.children.length
    fprintf('%s',getcellname(tree.children(i)));
    ibmx_OneCell(tree.children(i),p,10);
end
BIPBIP;
close(figure(10))
%% one by one (to visually inspect and check results)
figure(10)
clf
params=struct;
params.plotMean = 0;
params.preSelectAll = 0;
params.silent = 0;
set(gcf,'Position',[0 224 1111 835]);
node = tree.children(10);
hGUI=ibmx_OneCell(node,params,10);

%% all cells
p=struct;
p.Position = [-3199          48        1450         900];
p.Normalize = 1;
hGUI=ibmx_OrganoidSummary(tree,p,2);
hGUI.formatForPublication;

%%
i = 1; %n(cells) = 24
node = tree.children(i);

% cellname (type - internal) -> comment
% 20181216c01 (cone - KAsp - Organoid prep) -> bad leak subtraction

% Just start by making a plotter for all of them similar to OrganoidSummary
%  Then figure out how to quantify
