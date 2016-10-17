function tree=overBufferingExample(dir,ANALYSIS_FILTER_VIEW_FOLDER)
%% Voltage Steps
clear
startup
dir.exp='/sq_BufferedCsMs.mat';
params.exp='Buffered';
list=riekesuite.analysis.loadEpochList([[dir.li_dbroot,'/OvationExports'],dir.exp],[dir.li_dbroot]);
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
%%
list=list.sortedBy('protocolSettings(user:startTime)');
labelSplitter=@(epoch)(epoch.cell.label);
splitMap = riekesuite.util.SplitValueFunctionAdapter.buildMap(list,labelSplitter);

tree = riekesuite.analysis.buildTree(list,{splitMap});
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
% gui=epochTreeGUI(tree);
%%
node=tree.childBySplitValue('20160609Ac03');
Data=riekesuite.getResponseMatrix(node.epochList,'Amp1');
Stim=getStimulusVector(node.epochList.elements(1),'LED_530');

tMin=0.15;
tMax=0.4;
ptsMin=round(tMin/getSamplingInterval(node));
ptsMax=round(tMax/getSamplingInterval(node));
Data=BaselineSubtraction(Data,1,ptsMin);
Data=Data(:,ptsMin:ptsMax);
Stim=Stim(ptsMin:ptsMax);

tAx=[0:size(Stim,2)-1].*getSamplingInterval(node);

epocht=round(node.custom.get('results').get('EpochTime'));
epocht=epocht-epocht(1);
epochmins=floor(epocht/60);
epochsec=floor(rem(epocht,60));

f1=getfigH(1);
setLabels(f1,'Time (s)','i (pA)')

Base=mean(Data(1:3,:));
dX=0.20;
dY=10;
for i=1:9
    lH=line(tAx+(dX*(i-1)),Data(i,:)+(dY*(i-1)),'Parent',f1);
%     set(lH,'LineWidth',2)%,'Color',[0 0 0])
    set(lH,'DisplayName',sprintf('Flash%gmin%gs',epochmins(i),epochsec(i)))
    lH=line(tAx+(dX*(i-1)),Base+(dY*(i-1)),'Parent',f1);
    set(lH,'Color',[.55 .55 .55])
    set(lH,'DisplayName',sprintf('Base%gmin%gs',epochmins(i),epochsec(i)))
end

%%

makeAxisStruct(f1,'overBuffer',sprintf('LiLab/HereThere'));
