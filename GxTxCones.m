function GxTxCones()
%%
clear
startup
dir.exp='/gxtxcone.mat';
dir.exp='/hepescone.mat';
params.exp='gxtx';
list=riekesuite.analysis.loadEpochList([[dir.li_dbroot,'/OvationExports'],dir.exp],[dir.li_dbroot]);
labelSplitter=@(epoch)(epoch.cell.label);
splitMap = riekesuite.util.SplitValueFunctionAdapter.buildMap(list,labelSplitter);
stmptsSplitter=@(epoch)(round(getProtocolSetting(epoch,'datapts')));
splitMap2 = riekesuite.util.SplitValueFunctionAdapter.buildMap(list,stmptsSplitter);
tree = riekesuite.analysis.buildTree(list,{splitMap,splitMap2});
tree.visualize
BIPBIP();
%% Tagging stuff
for i=1:tree.children.length
    theseepochs=tree.children(i).epochList;
    for j=1:theseepochs.length
        if getProtocolSetting(theseepochs.elements(j),'datapts')==600
            theseepochs.elements(j).addKeywordTag('AccessStep');
        elseif round(getProtocolSetting(theseepochs.elements(j),'datapts'))==6000
            theseepochs.elements(j).addKeywordTag('vSteps');
        elseif getProtocolSetting(theseepochs.elements(j),'datapts')==7000
            theseepochs.elements(j).addKeywordTag('Flash');
        elseif getProtocolSetting(theseepochs.elements(j),'datapts')==35000
            theseepochs.elements(j).addKeywordTag('Step');
        elseif getProtocolSetting(theseepochs.elements(j),'datapts')==40000
            theseepochs.elements(j).addKeywordTag('Step');        
        end
    end
%     % Writing protocolSetting for vclamp vs iclamp
    ampmode{i}=writeAxopatchMode(tree.children(i),1);
    stT{i}=writestartTime(tree.children(i),1);
end

BIPBIP();
%%

%% Flashes only
clear
startup
dir.exp='/gxtx_20150806flash.mat';
dir.exp='/hepescone.mat';
params.exp='gxtx';
list=riekesuite.analysis.loadEpochList([[dir.li_dbroot,'/OvationExports'],dir.exp],[dir.li_dbroot]);
list=list.sortedBy('protocolSettings(user:startTime)');
labelSplitter=@(epoch)(epoch.cell.label);
splitMap = riekesuite.util.SplitValueFunctionAdapter.buildMap(list,labelSplitter);
stmptsSplitter=@(epoch)(round(getProtocolSetting(epoch,'datapts')));
splitMap2 = riekesuite.util.SplitValueFunctionAdapter.buildMap(list,stmptsSplitter);
modeSplitter=@(epoch)(epoch.responses('Amp1').externalDeviceMode);
splitMap3 = riekesuite.util.SplitValueFunctionAdapter.buildMap(list,modeSplitter);
tree = riekesuite.analysis.buildTree(list,{splitMap,splitMap2,splitMap3});
tree.visualize
BIPBIP();
%% Getting single cell and stimulus
tree=tree.childBySplitValue('20150806Ac02');
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

%% vSteps
clear
startup
dir.exp='/gxtx_20150806vSteps.mat';
params.exp='gxtx';
list=riekesuite.analysis.loadEpochList([[dir.li_dbroot,'/OvationExports'],dir.exp],[dir.li_dbroot]);
list=list.sortedBy('protocolSettings(user:startTime)');
labelSplitter=@(epoch)(epoch.cell.label);
splitMap = riekesuite.util.SplitValueFunctionAdapter.buildMap(list,labelSplitter);

egSplitter=@(epoch)(epoch.protocolSettings('pulseAmplitude'));
splitMap2 = riekesuite.util.SplitValueFunctionAdapter.buildMap(list,egSplitter);

tree = riekesuite.analysis.buildTree(list,{splitMap,splitMap2});
BIPBIP();
%%
for i=1:tree.children.length
    stT{i}=writestartTime(tree.children(i),1);
end

%% General stuff on cell level
clear list
disp(['running ''sqerg_preanalysis'' ...']);
params=struct;
for i=1:tree.children.length
    fprintf('Running %s: %g of %g   \n',getcellname(tree.children(i)),i,tree.children.length);
    generic_preanalysis(tree.children(i),params);
end
BIPBIP;
