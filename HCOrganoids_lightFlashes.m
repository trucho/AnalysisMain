% function tree=vFamilyAnalysis(dir)
global ANALYSIS_FILTER_VIEW_FOLDER %#ok<*NUSED>
%% Voltage Steps
clear
startup
dir.li_dbroot='/Users/angueyraaristjm/Documents/LiData/Organoids/';
dir.exp='all_lightFlashes.mat';
params.exp='flashes';
fprintf('Loading list....\n');
list=riekesuite.analysis.loadEpochList([[dir.li_dbroot],dir.exp],[dir.li_dbroot]);
fprintf('List loaded: %s\n',dir.exp);
% % 
% %% write epoch start times since experiment started
% 
% 
% labelSplitter=@(epoch)splitonCellLabel_addDate(epoch);
% splitMap = riekesuite.util.SplitValueFunctionAdapter.buildMap(list,labelSplitter);
% tree = riekesuite.analysis.buildTree(list,{splitMap});
% for i=1:tree.children.length
%     sT{i}=writestartTime(tree.children(i),1);
% end
% BIPBIP;
%%



list=list.sortedBy('protocolSettings(user:startTime)');

% labelSplitter=@(epoch)(epoch.cell.label);
labelSplitter=@(epoch)splitonCellLabel_addDate(epoch);
labelMap = riekesuite.util.SplitValueFunctionAdapter.buildMap(list,labelSplitter);

tree = riekesuite.analysis.buildTree(list,{labelMap});
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
%% Getting mean from selected epochs for cell
fprintf('running screenepochs...\n');
params=struct;
params.plotMean = 1;
params.silent = 1;
figure(10)
set(gcf,'Position',[0 224 1111 835]);
% get mean values
leaves=tree.leafNodes.elements;
for i=1:length(leaves)
    fprintf('%s',getcellname(tree.children(i)));
    fprintf('   %02d of %02d:   ',i,length(leaves));
    generic_screenepochs(leaves(i),10,0,params);
end
BIPBIP;
close(figure(10))
%% single one
figure(10)
params=struct;
params.plotMean = 0;
params.preSelectAll = 0;
params.silent = 0;
set(gcf,'Position',[0 224 1111 835]);
node = tree.childBySplitValue('20190121c12');
% node = tree.children(8);
generic_screenepochs(node,10,0,params);
% 20190121c12 -> different tailPts; light Response!!!???
% 20190121c13 -> LED off on the first epochs; rest are 8V
% 20190121c15 -> remove (LED off)
% 20190127c02 -> badCell
% 20190128c02 -> review. disjointed length

%% all cells
p=struct;
p.Position = [-3199          48        1450         900];
p.Normalize = 1;
hGUI=lightFlashes_OrganoidSummary(tree,p,2);
hGUI.formatForPublication;

%%
i = 1; %n(cells) = 24
node = tree.children(i);

% cellname (type - internal) -> comment
% 20181216c01 (cone - KAsp - Organoid prep) -> bad leak subtraction

% Just start by making a plotter for all of them similar to OrganoidSummary
%  Then figure out how to quantify
