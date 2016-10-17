function tree=ledLinearity(dir,ANALYSIS_FILTER_VIEW_FOLDER)
clear, startup
dir.exp='/OvationExports/ledCal_120114.mat';
dir.exp='/OvationExports/ledCal_20141204.mat';
% dir.exp='/OvationExports/tests.mat';


params.exp='ledLinearity';
list=riekesuite.analysis.loadEpochList([dir.li_dbroot,dir.exp],[dir.li_dbroot]);
% list=list.sortedBy('protocolSettings(acquirino:epochNumber)');
% tree =riekesuite.analysis.buildTree(list,{'cell.label','protocolSettings(led)','protocolSettings(lightAmplitude)'});
tree =riekesuite.analysis.buildTree(list,{'cell.label','protocolSettings(led)'});
BIPBIP();
%% Analysis
% cellname='120114Ac01';
cellname='20141204Ac01';
for i=1:tree.childBySplitValue(cellname).children.length
    node=tree.childBySplitValue(cellname).children(i);
%     Data{i}=riekesuite.getResponseMatrix(node.epochList,'Amp1');
    Data{i}=riekesuite.getResponseMatrix(node.epochList,'PMD');
    Stim{i}=riekesuite.getStimulusMatrix(node.epochList,node.splitValue);
end

%%
i=1;
tAxis=[1:size(Data{i},2)]./(node.epochList.firstValue.protocolSettings('sampleRate'));

prepts=getProtocolSetting(node,'prepts');
stmpts=getProtocolSetting(node,'prepts');
prepts=getProtocolSetting(node,'prepts');



f1=getfigH(1);
f2=getfigH(2);
cmap=pmkmp(size(Data{i},1));
for e=1:size(Data{i},1)
%     lH=line(tAxis,Data{i}(e,:),'Parent',f1);
%     set(lH,'Color',cmap(e,:));
    
    node=tree.childBySplitValue(cellname).children(i);
%     ledAmp{i}(e)=node.epochList.elements(e).protocolSettings('lightAmplitude');
    ledAmp{i}(e)=mean(Stim{i}(e,prepts+stmpts/2:prepts+stmpts));
    pmdOut{i}(e)=mean(Data{i}(e,prepts+stmpts/2:prepts+stmpts));
    
    lH=line(ledAmp{i}(e),pmdOut{i}(e),'Parent',f2);
    set(lH,'Marker','.','Color',cmap(e,:));
end

%%
end