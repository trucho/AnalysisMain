%% Trying to figure out what is failing with vRCfilters

% Pick a good cell (first noRC compensation)
node = tree.childBySplitValue('c04').childBySplitValue(false);
samplingInterval=getSamplingInterval(node);
% Get average of -5 and +5mV vSteps
f = linfiltFX();
g = ephysGUI(10);
g.createPlot(struct('Position',[0.05 0.55 .55 .43],'tag','plotMain'));
g.gObj.plotMain.XLim=[0.099 0.11];
% g.gObj.plotMain.XLim=[0.099 0.2];
% g.gObj.plotMain.XLim=[0.095 0.8];
g.createPlot(struct('Position',[0.05 0.05 .55 .43],'tag','plotSub'));
g.createPlot(struct('Position',[0.63 0.05 .35 .43],'tag','plotFilter'));
g.gObj.plotSub.XLim = g.gObj.plotMain.XLim;

n=struct;
n.Sel=3;
n.fCorr=0;%1000;%600;
n.node = node.parent.childBySplitValue(true);
n.lftime = 1.5;
[n.Filter, n.tAx] = f.getLinearFilter(n.node,n.lftime);
n.Filter = n.Filter(n.Sel,:)+n.fCorr;
% n.Filter = BaselineSubtraction(n.Filter,30,40);
lH=lineH(n.tAx,n.Filter,g.gObj.plotFilter);
lH.linemarkers;


l=struct;
l.Sel=(1:4)+4*(n.Sel-1);
l.node = node.childBySplitValue(-55);
l.prepts=getProtocolSetting(l.node,'prepts');
l.Data=riekesuite.getResponseMatrix(l.node.epochList,'Amp1');
l.DataSD=std(l.Data(l.Sel,:),1);
l.Data=mean(l.Data(l.Sel,:));
l.Stim=riekesuite.getStimulusVector(l.node.epochList.elements(1),'Amp1');
l.tAx=g.getTimeAxis(l.node);

lH=lineH(l.tAx,BaselineSubtraction(l.Data,1,l.prepts),g.gObj.plotMain);
lH.linek;lH.h.LineWidth=3;
% eH=lH.errorfill(l.tAx,BaselineSubtraction(l.Data,1,l.prepts),l.DataSD,[.5 .5 .5],g.gObj.plotMain);

l.mData = f.getLinearEstimation(l.Stim,n.Filter,l.prepts,samplingInterval);
lH=lineH(l.tAx,l.mData,g.gObj.plotMain);
lH.line;lH.h.Color=[.8 0 0 .5];lH.h.LineWidth=2;

lH=lineH(l.tAx,BaselineSubtraction(l.Data,1,l.prepts)-l.mData,g.gObj.plotSub);
lH.liner;
%%
% Then try it on other voltages
g = ephysGUI(10);
g.createPlot(struct('Position',[0.05 0.55 .55 .43],'tag','plotMain'));
% g.gObj.plotMain.XLim=[0.099 0.11];
% % g.gObj.plotMain.XLim=[0.099 0.2];
% g.gObj.plotMain.XLim=[0.095 0.8];
g.createPlot(struct('Position',[0.05 0.05 .55 .43],'tag','plotSub'));
g.createPlot(struct('Position',[0.63 0.05 .35 .43],'tag','plotFilter'));
g.gObj.plotSub.XLim = g.gObj.plotMain.XLim;
g.gObj.plotSub.YLim = [-200 400];
lH=lineH(n.tAx,n.Filter,g.gObj.plotFilter);
lH.linemarkers;

colors = pmkmp(node.children.length);
wcolors = whithen(colors,.5);
for i=9:17%1:8%:node.children.length
    v=struct;
    v.Sel = 3;
    % v.node = node.childBySplitValue(-20);
    v.node = node.children(i);
    v.prepts=getProtocolSetting(v.node,'prepts');
    v.Data=riekesuite.getResponseVector(v.node.epochList.elements(v.Sel),'Amp1')';
    v.Stim=riekesuite.getStimulusVector(v.node.epochList.elements(v.Sel),'Amp1');
    v.tAx=g.getTimeAxis(v.node);
    
    lH=lineH(v.tAx,BaselineSubtraction(v.Data,1,v.prepts),g.gObj.plotMain);
    lH.line;lH.h.Color=colors(i,:);
    
    v.mData = f.getLinearEstimation(v.Stim,n.Filter,v.prepts,samplingInterval);
    lH=lineH(v.tAx,v.mData,g.gObj.plotMain);
    lH.line;lH.h.Color=wcolors(i,:);
    
    lH=lineH(v.tAx,BaselineSubtraction(v.Data,1,v.prepts)-v.mData,g.gObj.plotSub);
    lH.line;lH.h.Color=colors(i,:);
end
