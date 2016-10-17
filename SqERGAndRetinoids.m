function tree=SqERGAndRetinoids(dir,ANALYSIS_FILTER_VIEW_FOLDER)
%%
clear
startup
dir.exp='/ergsq_hiba_11cis.mat';
% dir.exp='/ergsq_hiba_11cis2.mat';
% dir.exp='/ergsq_ames_11cis3.mat';
% dir.exp='/ergsq_flashes.mat';
params.exp='erg';
list=riekesuite.analysis.loadEpochList([[dir.li_dbroot,'/OvationExports'],dir.exp],[dir.li_dbroot]);
% 
% %% write epoch start times since experiment started
% %
% labelSplitter=@(epoch)(epoch.cell.label);
% splitMap = riekesuite.util.SplitValueFunctionAdapter.buildMap(list,labelSplitter);
% tree = riekesuite.analysis.buildTree(list,{splitMap});
% for i=1:tree.children.length
%     sT=writestartTime(tree.children(i),1);
% end
% %
%%
list=list.sortedBy('protocolSettings(user:startTime)');
labelSplitter=@(epoch)(epoch.cell.label);
splitMap = riekesuite.util.SplitValueFunctionAdapter.buildMap(list,labelSplitter);
ergtagSplitter=@(epoch)splitonERGTag(epoch);
splitMap2 = riekesuite.util.SplitValueFunctionAdapter.buildMap(list,ergtagSplitter);
% stmptsSplitter=@(epoch)(getProtocolSetting(epoch,'datapts'));
% splitMap3 = riekesuite.util.SplitValueFunctionAdapter.buildMap(list,stmptsSplitter);
ledtagSplitter=@(epoch)splitonledsOFFtag(epoch);
splitMap4 = riekesuite.util.SplitValueFunctionAdapter.buildMap(list,ledtagSplitter);
% tree = riekesuite.analysis.buildTree(list,{splitMap,splitMap2,splitMap3,splitMap4});
tree = riekesuite.analysis.buildTree(list,{splitMap,splitMap2,splitMap4});
% tree.visualize
BIPBIP();
%%
%% General stuff on cell level
clear list
disp(['running ''sqerg_preanalysis'' ...']);
params=struct;
for i=1:tree.children.length
    fprintf('Running %s: %g of %g   \n',getcellname(tree.children(i)),i,tree.children.length);
    sqerg_preanalysis(tree.children(i),params);
end
BIPBIP;
%%
cellname='20150225Ac01';
node=tree.childBySplitValue(cellname).childBySplitValue('01_PreBleach');
lpfreq=500;
% rOFF=toMatlabStruct(node.childBySplitValue('OFF').custom.get('results'));

rArtifact=toMatlabStruct(tree.childBySplitValue(cellname).childBySplitValue('00_Artifact').childBySplitValue('ON').custom.get('results'));
rPre=toMatlabStruct(tree.childBySplitValue(cellname).childBySplitValue('01_PreBleach').childBySplitValue('ON').custom.get('results'));
rPost=toMatlabStruct(tree.childBySplitValue(cellname).childBySplitValue('02_PostBleach01').childBySplitValue('ON').custom.get('results'));
rRet=toMatlabStruct(tree.childBySplitValue(cellname).childBySplitValue('03_PostRetinal').childBySplitValue('ON').custom.get('results'));
rAmes=toMatlabStruct(tree.childBySplitValue(cellname).childBySplitValue('09_PostBleach06Ames').childBySplitValue('ON').custom.get('results'));

mArtifact=LowPassFilter(rArtifact.Mean,lpfreq,getSamplingInterval(node));
mPre=LowPassFilter(rPre.Mean,lpfreq,getSamplingInterval(node));
mPost=LowPassFilter(rPost.Mean,lpfreq,getSamplingInterval(node));
mRet=LowPassFilter(rRet.Mean,lpfreq,getSamplingInterval(node));
mAmes=LowPassFilter(rAmes.Mean,lpfreq,getSamplingInterval(node));

mArtifact=BandPassFilter(mArtifact,59,61,getSamplingInterval(node));
mPre=BandPassFilter(mPre,59,61,getSamplingInterval(node));
mPost=BandPassFilter(mPost,59,61,getSamplingInterval(node));
mRet=BandPassFilter(mRet,59,61,getSamplingInterval(node));
mAmes=BandPassFilter(mAmes,59,61,getSamplingInterval(node));


f1=getfigH(1);
set(f1,'FontSize',16)
set(get(f1,'XLabel'),'string','Time (s)','FontSize',16)
set(get(f1,'YLabel'),'string','Trans-retinal Potential (uV)','FontSize',16)
lH=line(rArtifact.tAxis,mPre-mArtifact,'Parent',f1);
set(lH,'DisplayName','Pre-Bleaching','Line','-','LineWidth',1,'Marker','none','Color',[0 0 0])
lH=line(rArtifact.tAxis,mPost-mArtifact,'Parent',f1);
set(lH,'DisplayName','Post-Bleaching','Line','-','LineWidth',1,'Marker','none','Color',[.5 .5 .5])
lH=line(rArtifact.tAxis,mRet-mArtifact,'Parent',f1);
set(lH,'DisplayName','Post-11-cis','Line','-','LineWidth',1,'Marker','none','Color',[.5 .5 1])
lH=line(rArtifact.tAxis,mAmes-mArtifact,'Parent',f1);
set(lH,'DisplayName','Ames','Line','-','LineWidth',1,'Marker','none','Color',[.5 0 0])


f2=getfigH(2);
set(f2,'FontSize',16)
set(get(f2,'XLabel'),'string','Time (s)','FontSize',16)
set(get(f2,'YLabel'),'string','Trans-retinal Potential (uV)','FontSize',16)
lH=line(rArtifact.tAxis,mArtifact,'Parent',f2);
set(lH,'DisplayName','Pre-Bleaching','Line','-','LineWidth',1,'Marker','none','Color',[0.5 1 0.5])
lH=line(rArtifact.tAxis,mPre,'Parent',f2);
set(lH,'DisplayName','Pre-Bleaching','Line','-','LineWidth',1,'Marker','none','Color',[0 0 0])
lH=line(rArtifact.tAxis,mPost,'Parent',f2);
set(lH,'DisplayName','Post-Bleaching','Line','-','LineWidth',1,'Marker','none','Color',[.5 .5 .5])
lH=line(rArtifact.tAxis,mRet,'Parent',f2);
set(lH,'DisplayName','Post-11-cis','Line','-','LineWidth',1,'Marker','none','Color',[.5 .5 1])
lH=line(rArtifact.tAxis,mAmes,'Parent',f2);
set(lH,'DisplayName','Ames','Line','-','LineWidth',1,'Marker','none','Color',[.5 0 0])
%%
makeAxisStruct(f1,sprintf('ergdiff_%s',cellname),sprintf('erg/squirrel/retinal/'))
makeAxisStruct(f2,sprintf('ergraw_%s',cellname),sprintf('erg/squirrel/retinal/'))
%%
%%
%%
fstim=findobj('tag','spstim');
fmeans=findobj('tag','sp');
fsubmeans=findobj('tag','spsub');

% cellname='20150225Ac01';
% cellname='20150302Ac02';
% cellname='20150303Ac01';

makeAxisStruct(fstim,sprintf('erg%s_stim',cellname),sprintf('erg/squirrel/retinal/'))
makeAxisStruct(fmeans,sprintf('erg%s_mean',cellname),sprintf('erg/squirrel/retinal/'))
makeAxisStruct(fsubmeans,sprintf('erg%s_diff',cellname),sprintf('erg/squirrel/retinal/'))

%%

%% Single epoch vs. mean

cellname='20150303Ac01';
node=tree.childBySplitValue(cellname).childBySplitValue('02_PreBleaching').childBySplitValue('ON');
results=toMatlabStruct(node.custom.get('results'));

d=riekesuite.getResponseVector(node.epochList.firstValue,'Amp1')'*1000;
prepts=getProtocolSetting(node.epochList.firstValue,'prepts');
d=BaselineSubtraction(d,1,prepts);
d=DriftCorrection(lpd,1,prepts);
lpd=LowPassFilter(d,500,getSamplingInterval(node));
lpd=BandPassFilter(d,59,61,getSamplingInterval(node));
m=results.Mean;
t=results.tAxis;
lpm=LowPassFilter(m,500,getSamplingInterval(node));
lpm=BandPassFilter(m,59,61,getSamplingInterval(node));

f1=getfigH(1);
lH=line(t,lpd,'Parent',f1);
set(lH,'DisplayName','SingleEpoch','Line','-','LineWidth',1,'Marker','none','Color',[.5 .5 .5])
lH=line(t,lpm,'Parent',f1);
set(lH,'DisplayName','Mean','Line','-','LineWidth',1,'Marker','none','Color',[0 0 0])

end



function flashes_example()
%%
cellname='20150303Ac01';
node=tree.childBySplitValue(cellname).childBySplitValue('02_PreBleaching');
lpfreq=500;
% rOFF=toMatlabStruct(node.childBySplitValue('OFF').custom.get('results'));

rArtifact=toMatlabStruct(tree.childBySplitValue(cellname).childBySplitValue('02_PreBleaching').childBySplitValue('OFF').custom.get('results'));
rPre=toMatlabStruct(tree.childBySplitValue(cellname).childBySplitValue('02_PreBleaching').childBySplitValue('ON').custom.get('results'));
rRet=toMatlabStruct(tree.childBySplitValue(cellname).childBySplitValue('08_PostRetinal').childBySplitValue('ON').custom.get('results'));

mArtifact=LowPassFilter(rArtifact.Mean,lpfreq,getSamplingInterval(node));
mPre=LowPassFilter(rPre.Mean,lpfreq,getSamplingInterval(node));
mRet=LowPassFilter(rRet.Mean,lpfreq,getSamplingInterval(node));

mArtifact=BandPassFilter(mArtifact,59,61,getSamplingInterval(node));
mPre=BandPassFilter(mPre,59,61,getSamplingInterval(node));
mRet=BandPassFilter(mRet,59,61,getSamplingInterval(node));


f1=getfigH(1);
set(f1,'FontSize',16)
set(get(f1,'XLabel'),'string','Time (s)','FontSize',16)
set(get(f1,'YLabel'),'string','Trans-retinal Potential (uV)','FontSize',16)
lH=line(rArtifact.tAxis,mPre-mArtifact,'Parent',f1);
set(lH,'DisplayName','Pre-Bleaching','Line','-','LineWidth',1,'Marker','none','Color',[0 0 0])
lH=line(rArtifact.tAxis,mRet-mArtifact,'Parent',f1);
set(lH,'DisplayName','Post-11-cis','Line','-','LineWidth',1,'Marker','none','Color',[.5 .5 1])


f2=getfigH(2);
set(f2,'FontSize',16)
set(get(f2,'XLabel'),'string','Time (s)','FontSize',16)
set(get(f2,'YLabel'),'string','Trans-retinal Potential (uV)','FontSize',16)
lH=line(rArtifact.tAxis,mArtifact,'Parent',f2);
set(lH,'DisplayName','Pre-Bleaching','Line','-','LineWidth',1,'Marker','none','Color',[0.5 1 0.5])
lH=line(rArtifact.tAxis,mPre,'Parent',f2);
set(lH,'DisplayName','Pre-Bleaching','Line','-','LineWidth',1,'Marker','none','Color',[0 0 0])
lH=line(rArtifact.tAxis,mRet,'Parent',f2);
set(lH,'DisplayName','Post-11-cis','Line','-','LineWidth',1,'Marker','none','Color',[.5 .5 1])
end
