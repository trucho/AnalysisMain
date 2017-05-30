function tree=StepsAndSines_2017(dir,ANALYSIS_FILTER_VIEW_FOLDER)
%% EyeMovements: LED Saccade Trajectory from vanHat's db
clear, startup
global expname
dir.exp='/EyeMovements/Saccade_vC_all.mat'; expname = 'SaccadeTrajectory';
% dir.exp='/EyeMovements/Saccade_vC_example.mat'; expname = 'SaccadeTrajectory';
% dir.exp='/EyeMovements/Saccade_iC_example.mat';expname = 'SaccadeTrajectory';
% dir.exp='/EyeMovements/SaccadeTrajectory_EGTA2.mat'; expname = 'SaccadeTrajectoryEGTA';
% dir.exp='/EyeMovements/SaccadePerfPatch_Hysteresis.mat'; expname = 'Hysteresis';
% dir.exp='/EyeMovements/SaccadePerfPatch.mat'; expname = 'SaccadeTrajectoryPerfPatch';
% % % dir.exp='/EyeMovements/SaccadeSine_vC_021814.mat'; expname = 'vC_hDown';
% dir.exp='/EyeMovements/SaccadeSine_iC_Down.mat'; expname = 'iC_hDown';
dir.exp='/EyeMovements/SaccadeSine_iC_Up.mat'; expname = 'iC_hUp';

list=riekesuite.analysis.loadEpochList([dir.dbroot,dir.exp],[dir.dbroot,'/']);
list=list.sortedBy('protocolSettings(acquirino:epochNumber)');
BIPBIP()

% %% CALIBRATION: if needed
% tree=riekesuite.analysis.buildTree(list,{'protocolSettings(acquirino:cellBasename)'});
% ampmode=cell(tree.children.length,1);
% for i=1:tree.children.length
%     r(i,:)=calibrateSaccadeTrajectory(tree.children.valueByIndex(i),[]);
% %     %if this wasn't done before during tagging
% %     ampmode{i}=writeAmpMode(tree.children.valueByIndex(i),1); 
% %     % For Saccade Trajectory + Sine
% %     phase{i}=writeSinePhase(tree.children.valueByIndex(i),1);
% end
% BIPBIP;
% % %%
%% get data, split and make tree
% %% For Saccade Trajectory (Steps + Ramps)
tree =riekesuite.analysis.buildTree(list,{'protocolSettings(acquirino:cellBasename)','protocolSettings(user:rstar:Max)'});
printCellnamesAndSplitValues(tree)
% BIPBIP();
%% For Saccade Trajectory + Sine
% Need to split by light level, trajectory and 5 phases
tree =riekesuite.analysis.buildTree(list,{'protocolSettings(acquirino:cellBasename)','protocolSettings(user:rstar:MaxStep)','protocolSettings(user:SinePhase)'});
printCellnamesAndSplitValues(tree)
%% Hyst Down example cell
tree =riekesuite.analysis.buildTree(tree.childBySplitValue('040114Fc03').epochList,{'protocolSettings(acquirino:cellBasename)','protocolSettings(user:rstar:MaxStep)','protocolSettings(user:SinePhase)'});
%% Hyst Up example cell
tree=riekesuite.analysis.buildTree(tree.childBySplitValue('061014Fc08').epochList,{'protocolSettings(acquirino:cellBasename)','protocolSettings(user:rstar:MaxStep)','protocolSettings(user:SinePhase)'});
%%
%% General stuff on cell level
clear list
disp(['running ''eyemovements_analysis'' ...']);
params=struct;
params.expname = expname;
for i=1:tree.children.length
    fprintf('Running %s: %g of %g   \n',getcellname(tree.children(i)),i,tree.children.length);
    eyemovements_analysis(tree.children(i),params);
end
BIPBIP;
%% Getting mean from selected epochs for each light level
fprintf('running eyemovements_screenepochs...\n');
params=struct;
params.plotMean=1;
params.expname = expname;
leaves=tree.leafNodes.elements;
figure(10)
set(gcf,'Position',[0 224 1111 835]);
for i=1:length(leaves)
    fprintf('%d of %d \n',i,length(leaves));
    eyemovements_screenepochs(leaves(i),10,0,params);
end
BIPBIP;
close(figure(10))
%% Running sine peak detection after subtraction
for i=1:tree.children.length
    fprintf('%s (%g of %g)   \n',getcellname(tree.children(i)),i,tree.children.length);
    for j=1:tree.children(i).children.length
        fprintf('Running peak detection @%.2f R*/s:  %g of %g   \n',round(tree.children(i).children(j).splitValue*100)/100,j,tree.children(i).children.length);
        eyemovements_findPeaks(tree.children(i).children(j),[]);
        if strcmpi(getcellname(tree.children(i)),'040114Fc03') && (round(tree.children(i).children(j).splitValue*100)/100==103380.46)
            fprintf('Detecting peaks for model...\n')
            eyemovements_findPeaksModel(tree.children(i).children(j),[]);
        elseif strcmpi(getcellname(tree.children(i)),'061014Fc08') && (round(tree.children(i).children(j).splitValue*100)/100==141404.77)
            fprintf('Detecting peaks for model...\n')
            eyemovements_findPeaksModel(tree.children(i).children(j),[]);
        end
    end
end
BIPBIP();
fprintf('Really done!\n')
% d' calculation
for i=1:tree.children.length
    for j=1:tree.children(i).children.length
        node=tree.children(i).children(j);
        cellresults=toMatlabStruct(node.custom.get('results'));
        dprime=cell(1,9);
        dprimetime=cell(1,9);
        for g=1:9
            temp=[];
            tempfilt=[];
            tempt=[];
            for k=1:4
                tempt=[tempt cellresults.tPeaks{g}(k)'];
                temp=[temp cellresults.dprimePeaks{g}(k)'];
            end
            [dprimetime{g},order]=sort(tempt);
            dprime{g}=temp(order);
        end
        
        cellresults.DPT=dprimetime;
        cellresults.DP=dprime;
        
        node.custom.put('results',riekesuite.util.toJavaMap(cellresults));
        
    end
end
fprintf('Saved reordered dprime values in cellresults\n')
%% calculate mean differences

% in sine leaves
global subNull
subNull=1;

global savediffs
savediffs=1;

fprintf('running eyemovements_sine_MeanDiff...\n');
params=struct;
params.plotMean=1;
leaves=tree.leafNodes.elements;

figure(10)
set(gcf,'Position',[0 224 1111 835]);
for c=1:tree.children.length
    fprintf('Cone #%d:\n',c);
    for j=1:4
    fprintf('\t%d of %d \n',j,4);
    eyemovements_sine_MeanDiff(tree.children(c).children(1).children(j),10,0,params);
    end
end
BIPBIP;

% in step only leaves
subNull=0;

fprintf('running eyemovements_sine_MeanDiff...\n');
params=struct;
params.plotMean=1;
leaves=tree.leafNodes.elements;
figure(10)
set(gcf,'Position',[0 224 1111 835]);
for c=1:tree.children.length
    fprintf('Cone #%d:\n',c);
    for j=5
    fprintf('\t%d of %d \n',j,5);
    eyemovements_sine_MeanDiff(tree.children(c).children(1).children(j),10,0,params);
    end
end
BIPBIP;
close(10)
%% all panels ready for Igor export (May 2017)

hGUI=eyemovements_sineClipped(tree.children(7).children(1),struct('phase','0000','plotflag',0),10);


end


function CalculateGainFromSines()
%%
global subNull
subNull=1;

global savediffs
savediffs=1;

fprintf('running eyemovements_sine_MeanDiff...\n');
params=struct;
params.plotMean=1;
leaves=tree.leafNodes.elements;

figure(10)
set(gcf,'Position',[0 224 1111 835]);
for c=4%1:tree.children.length
    for j=1%1:4
    fprintf('%d of %d \n',c,length(leaves));
    eyemovements_sine_Gain(tree.children(c).children(1).children(j),10,0,params);
    end
end
BIPBIP;


end
