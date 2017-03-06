%% GridSpots
%% BuildTree
close all; clear; clear classes; clc; startup
global dir
% dir.exp='/00_MatlabExports/20160831A_GridSpots.mat';
dir.exp='/00_MatlabExports/20160921A_GridSpots2by2.mat';
params.exp='RFs';
list=riekesuite.analysis.loadEpochList([dir.li_sy2root,dir.exp],[dir.li_sy2root]);
list=list.sortedBy('protocolSettings(user:startTime)');
% %%
% tic
% fprintf('Building tree\n');
% tree = riekesuite.analysis.buildTree(list,{'protocolSettings(source:label)'});
% fprintf('cellnames\n'); toc, beep, pause(0.1), beep, pause(0.1), beep
% getSplitValues(tree)
% toc
% %% Tagging stuff
% for i=1:tree.children.length
% %     % Writing protocolSetting for vclamp vs iclamp
%     ampmode{i}=writeAxopatchMode(tree.children(i),1);
%     stT{i}=writestartTime(tree.children(i),1);
% end
% 
% BIPBIP();

% %% Calibration if needed (NOT READY FOR THIS)
% tic
% params.cola=0.6; %Assumed collecting area
% Leaves=tree.leafNodes.elements;
% for leaf = 1:length(Leaves)
%     node = Leaves(leaf);
%     rstarFlash{leaf}=calibrateFlashEpochs(node,params);
% end
% toc
% BIPBIP();

%% get data, split and make tree
LEDSplitter = @(epoch)splitonLED(epoch);
LEDSplitter = riekesuite.util.SplitValueFunctionAdapter.buildMap(list, LEDSplitter);
% for 20160831
% tree =riekesuite.analysis.buildTree(list,{'protocolSettings(source:label)',LEDSplitter,'protocolSettings(user:currentX)','protocolSettings(user:currentY)'});
% for 20160921
tree =riekesuite.analysis.buildTree(list,{'protocolSettings(source:label)',LEDSplitter,'protocolSettings(spotRadius)','protocolSettings(currentX)','protocolSettings(currentY)'});
selectAll(tree);
%% General stuff on cell level
clear list LEDSplitter
disp(['running ''generic_preanalysis'' ...']);
params=struct;
for i=1:tree.children.length
    fprintf('Running %s: %g of %g   \n',getcellname(tree.children(i)),i,tree.children.length);
    generic_preanalysis(tree.children(i),params);
end
BIPBIP;
% %% GUI
% gui = epochTreeGUI(tree);
% set(gcf,'Position',[46           5        1287         828])
%% Screen epochs
leaves=tree.leafNodes.elements;
figure(10)
set(gcf,'Position',[0 224 1111 835]);
params.plotMean=1;
params.noPlot=1;
for i=1:length(leaves)
    fprintf('%d of %d \n',i,length(leaves));
    rf_screenepochs(leaves(i),10,0,params);
end
%% Display RF
node=tree.childBySplitValue('c06').childBySplitValue('led530').children(1);
% node=tree.childBySplitValue('c06').childBySplitValue('led455').children(2);
% node=tree.childBySplitValue('c08').childBySplitValue('led530').children(1);
figure(10)
set(gcf,'Position',[0 224 1111 835]);
rf_Display(node,10,0,params);







% % % % % %%
% % % % % %% Trying to fix bug in current Y for 20160831A
% % % % % node=tree.children(1).children(1)
% % % % % el=node.epochList;
% % % % % el=el.sortedBy('protocolSettings(user:startTime)');
% % % % % Data=riekesuite.getResponseMatrix(el,'Amp1');
% % % % % tAxis=(0:size(Data(1,:),2)-1)*getSamplingInterval(node);
% % % % % %%
% % % % % clc
% % % % % for i=1:el.length
% % % % %     fprintf('%g\t',i)
% % % % %     fprintf('t = %g\t',el.elements(i).protocolSettings('user:startTime'))
% % % % %     fprintf('X = %g\t',el.elements(i).protocolSettings('currentX'))
% % % % %     fprintf('Y = %g\n\n',el.elements(i).protocolSettings('currentY'))
% % % % % end
% % % % % 
% % % % % %% manually rewriting new protocol settings
% % % % % gridY=sort(repmat([106 110 114 118 122],1,5));
% % % % % gridY=[gridY gridY];
% % % % % for i=1:el.length
% % % % %     el.elements(i).setProtocolSetting('user:currentX',el.elements(i).protocolSettings('currentX'));
% % % % %     el.elements(i).setProtocolSetting('user:currentY',gridY(i));
% % % % % end
% % % % % 
% % % % % %%
% % % % % colors=pmkmp(50,'CubicL');
% % % % % f1=getfigH(1);
% % % % % lH=cell(1,50);
% % % % % cnt=0;
% % % % % for i=1:50
% % % % %     cnt=cnt+1;
% % % % %     lH{cnt}=line(tAxis,Data(i,:),'Parent',f1,'color',colors(cnt,:));
% % % % % end
