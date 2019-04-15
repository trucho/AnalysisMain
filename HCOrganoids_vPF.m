% function tree=vFamilyAnalysis(dir)
global ANALYSIS_FILTER_VIEW_FOLDER %#ok<*NUSED>
%% Voltage Steps
clear
startup
dir.li_dbroot='/Users/angueyraaristjm/Documents/LiData/Organoids/';
dir.exp='all_vPF.mat';
params.exp='vFamily';
fprintf('Loading list....');
list=riekesuite.analysis.loadEpochList([[dir.li_dbroot],dir.exp],[dir.li_dbroot]);
fprintf('List loaded: %s\n',dir.exp);
% 
%% write epoch start times since experiment started


% %
% labelSplitter=@(epoch)splitonCellLabel_addDate(epoch);
% splitMap = riekesuite.util.SplitValueFunctionAdapter.buildMap(list,labelSplitter);
% tree = riekesuite.analysis.buildTree(list,{splitMap});
% for i=1:tree.children.length
%     sT{i}=writestartTime(tree.children(i),1);
% end
% BIPBIP;


% %
%%
list=list.sortedBy('protocolSettings(user:startTime)');
rcSplitter=@(epoch)splitAutoRC(epoch);
rcMap = riekesuite.util.SplitValueFunctionAdapter.buildMap(list,rcSplitter);

% labelSplitter=@(epoch)(epoch.cell.label);
labelSplitter=@(epoch)splitonCellLabel_addDate(epoch);
labelMap = riekesuite.util.SplitValueFunctionAdapter.buildMap(list,labelSplitter);

tree = riekesuite.analysis.buildTree(list,{labelMap,rcMap,'protocolSettings(pulseSignal)'});
% tree = riekesuite.analysis.buildTree(list,{labelMap,'protocolSettings(pulseSignal)'});
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
%%
gui = epochTreeGUI(tree);
% gui.figure.Position=[50 5 1255 828];
gui.figure.Position=[-2379        -409        2112        1415];


%% single one
figure(10)
params=struct;
params.plotMean=1;
params.silent = 0;
set(gcf,'Position',[0 224 1111 835]);
node = tree.childBySplitValue('20190127c05').childBySplitValue(false).children(15);
generic_screenepochs(node,10,0,params);
%% Getting mean from selected epochs for each light level
fprintf('running screenepochs...\n');
params=struct;
params.plotMean=1;
params.silent = 1;
figure(10)
set(gcf,'Position',[0 224 1111 835]);
for c=1%:tree.children.length
    fprintf('%s\n',getcellname(tree.children(c)));
    % get mean values on non-autoRC epochs
    leaves=tree.children(c).childBySplitValue(false).leafNodes.elements;
    for i=1:length(leaves)
        fprintf('   %02d of %02d: %+04d mV:   ',i,length(leaves),leaves(i).splitValue);
        generic_screenepochs(leaves(i),10,0,params);
    end
end
BIPBIP;
close(figure(10))
%%
i = 30; %n(cells) = 36
node = tree.children(i).childBySplitValue(false);

% NOTE: Selected epochs trying to avoind run down, but may have biased results towards non CsMs perfused epochs.
% cellname (type - internal) -> comment
% 20181216c01 (cone - KAsp - Organoid prep) -> bad leak subtraction

% 20181218c01 (cone - KAsp - Organoid prep) -> not great, but IV is not terrible
% 20181218c02 (cone - KAsp - Organoid prep) -> bad leak subtraction (over)
% 20181218c03 (cone  - KAsp - Organoid prep) -> bad leak subtraction (over)

% 20190121c01 (Cone - CsMs - Organoid_01) -> OK-ish
% 20190121c04 (Cone - CsMs - Organoid_01) -> small inward currents. OK-ish I guess
% 20190121c06 (cone - CsMs - Organoid_01) -> no inward current. OK-ish
% 20190121c08 (cone - CsMs - Organoid_01) -> good. big currents
% 20190121c09 (cone - CsM - Organoid_01) -> no inward but ok
% 20190121c12 (cone - CsMs - Organoid_01) -> good. big current
% 20190121c13 (cone - CsMs - Organoid_01) -> good. almost no currents. Some Ih
% 20190121c14 (cone - CsMs - Organoid_01) -> good. no inward (but seems like steady state inactivation)
% 20190121c15 (cone - CsMs - Organoid_01) -> very good. big current
% 20190121c17 (rod - CsMs - Organoid_01) -> finally a rod. no inward, small currents overall but some outward and some Ih

% 20190123c01 (cone - CsMs - Organoid01) -> big Ih, but not much outward. is it late in recording?
% 20190123c02 (cone - CsMs - Organoid01) -> good. big currents. huge Ih and smaller outward (midway during recording?)
% 20190123c03 (cone - CsMs - Organoid01) -> good. small inward but probably because of steady-state inactivation. small outward but big Ih
% 20190123c04 (rod - CsMs - Organoid01) -> small currents, no inward but some outward and some Ih
% 20190123c05 (rod - CsMs - Organoid01) -> small currents, some leak subtraction artifact. No inward, some Ih but no outward.

% 20190127c01 (rod - CsMs - 9cisRAL_01) -> small currents. some artifacts, not much Ih

% 20190127c04 (rod - CsMs - alltransRA_01) -> good outward current, not much CaV
% 20190127c05 (cone - CsMs - alltransRA_01) -> good leak subtraction, no outward current. inward seems to be inactivated at rest
% 20190127c06 (rod - CsMs - alltransRA_01) -> some artifacts at low voltages; very small currents
% 20190127c07 (rod - CsMs - alltransRA_01) -> transient subtraction not very good. almost no currents otherwise
% 20190127c08 (rod - CsMs - alltransRA_01) -> bad leak traces make data noisy but no currents discernible
% 20190127c09 (cone - CsMs - alltransRA_01) -> no inward but beatiful Ih and outward. EXAMPLE??

% 20190128c01 (rod - CsMs - 9cisRAL_Organoid01) -> good iH and outward. inward plot could be leak sub artifact
% 20190128c02 (cone - CsMs - 9cisRAL_Organoid01) -> good Ih, small outward, good inward
% 20190128c03 (rod - CsMs - 9cisRAL_Organoid01) -> small, almost no Ih
% 20190128c04 (rod - CsMs - 9cisRAL_Organoid01) -> good rod, almost no inward or Ih, good outward
% 20190128c05 (cone - CsMs - 9cisRAL_Organoid01) -> a little weird for K+ currents (leak artifact)
% 20190128c06 (rod - CsMs - 9cisRAL_Organoid01) -> can't trust >0mV and almost no currents otherwise. Discard?
% 20190128c08 (rod - CsMs - 9cisRAL_Organoid01) -> no currents

% 20190128c09 (cone - CsMs - alltransRA_Organoid02) -> great currents, good IVs, nice leak subtraction. Example cell?
% 20190128c10 (rod - CsMs - alltransRA_Organoid02) -> tiny currents, not sure IV is really reflective of what is happening
% 20190128c11 (big rod or small cone - CsMs - alltransRA_Organoid02) -> no Ih, and small currents with so so IV.



fprintf('%s %s %s\n',getcellname(node),...
    node.epochList.elements(1).protocolSettings('source:parent:label'),...
    node.epochList.elements(1).protocolSettings('source:parent:parent:label'));
hGUI=vPulses_leakSub(node,[],10);
% set(hGUI.figH,'Position',[-2379        -409        2112        1415])


%% Reorganizing data for Holly and Ryan
% cellname (type - internal) -> comment

% Dummy organoids:
    % Rejected cells:
        % 20181216c01 (cone - KAsp - Organoid prep) -> bad leak subtraction
        % 20181218c02 (cone - KAsp - Organoid prep) -> bad leak subtraction (over)
        % 20181218c03 (cone  - KAsp - Organoid prep) -> bad leak subtraction (over)
    % Cones:
        % 20181218c01 (cone - KAsp - Organoid prep) -> not great, but IV is not terrible
        % 20190121c01 (Cone - CsMs - Organoid_01) -> OK-ish
        % 20190121c04 (Cone - CsMs - Organoid_01) -> small inward currents. OK-ish I guess
        % 20190121c06 (cone - CsMs - Organoid_01) -> no inward current. OK-ish
        % 20190121c08 (cone - CsMs - Organoid_01) -> good. big currents
        % 20190121c09 (cone - CsM - Organoid_01) -> no inward but ok
        % 20190121c12 (cone - CsMs - Organoid_01) -> good. big current
        % 20190121c13 (cone - CsMs - Organoid_01) -> good. almost no currents. Some Ih
        % 20190121c14 (cone - CsMs - Organoid_01) -> good. no inward (but seems like steady state inactivation)
        % 20190121c15 (cone - CsMs - Organoid_01) -> very good. big current
        % 20190123c01 (cone - CsMs - Organoid01) -> big Ih, but not much outward. is it late in recording?
        % 20190123c02 (cone - CsMs - Organoid01) -> good. big currents. huge Ih and smaller outward (midway during recording?)
        % 20190123c03 (cone - CsMs - Organoid01) -> good. small inward but probably because of steady-state inactivation. small outward but big Ih
    % Rods:
        % 20190121c17 (rod - CsMs - Organoid_01) -> finally a rod. no inward, small currents overall but some outward and some Ih
        % 20190123c04 (rod - CsMs - Organoid01) -> small currents, no inward but some outward and some Ih
        % 20190123c05 (rod - CsMs - Organoid01) -> small currents, some leak subtraction artifact. No inward, some Ih but no outward.

% 9cis:
    % Cones:
        % 20190128c02 (cone - CsMs - 9cisRAL_Organoid01) -> good Ih, small outward, good inward
        % 20190128c05 (cone - CsMs - 9cisRAL_Organoid01) -> a little weird for K+ currents (leak artifact)
    % Rods:
       % 20190127c01 (rod - CsMs - 9cisRAL_01) -> small currents. some artifacts, not much Ih
       % 20190128c01 (rod - CsMs - 9cisRAL_Organoid01) -> good iH and outward. inward plot could be leak sub artifact
        % 20190128c03 (rod - CsMs - 9cisRAL_Organoid01) -> small, almost no Ih
        % 20190128c04 (rod - CsMs - 9cisRAL_Organoid01) -> good rod, almost no inward or Ih, good outward
        % 20190128c06 (rod - CsMs - 9cisRAL_Organoid01) -> can't trust >0mV and almost no currents otherwise. Discard?
        % 20190128c08 (rod - CsMs - 9cisRAL_Organoid01) -> no currents

% allTrans:
    % Cones:
        % 20190127c05 (cone - CsMs - alltransRA_01) -> good leak subtraction, no outward current. inward seems to be inactivated at rest
        % 20190127c09 (cone - CsMs - alltransRA_01) -> no inward but beatiful Ih and outward. EXAMPLE??
        % 20190128c09 (cone - CsMs - alltransRA_Organoid02) -> great currents, good IVs, nice leak subtraction. Example cell?
    % Rods:
        % 20190127c04 (rod - CsMs - alltransRA_01) -> good outward current, not much CaV
        % 20190127c06 (rod - CsMs - alltransRA_01) -> some artifacts at low voltages; very small currents
        % 20190127c07 (rod - CsMs - alltransRA_01) -> transient subtraction not very good. almost no currents otherwise
        % 20190127c08 (rod - CsMs - alltransRA_01) -> bad leak traces make data noisy but no currents discernible
        % 20190128c10 (rod - CsMs - alltransRA_Organoid02) -> tiny currents, not sure IV is really reflective of what is happening
        % 20190128c11 (big rod or small cone - CsMs - alltransRA_Organoid02) -> no Ih, and small currents with so so IV.

clear organoidMap

organoidMap = struct(...
    'dummy',struct(),...
    'nineCis',struct(),...
    'allTrans',struct()...
);


organoidMap.dummy.rejected = {'20181216c01'; '20181216c02'; '20181216c03'};
organoidMap.dummy.cones = {'20181218c01'; '20190121c01'; '20190121c04'; '20190121c06'; '20190121c08'; '20190121c09'; '20190121c12'; '20190121c13'; '20190121c14'; '20190121c15'; '20190123c01'; '20190123c02'; '20190123c03';};
organoidMap.dummy.rods = {'20190121c17'; '20190123c04'; '20190123c05'; };

organoidMap.nineCis.rejected = {};
organoidMap.nineCis.cones = {'20190128c02'; '20190128c05'; };
organoidMap.nineCis.rods = {'20190127c01'; '20190128c01'; '20190128c03'; '20190128c04'; '20190128c06'; '20190128c08';};

organoidMap.allTrans.rejected = {};
organoidMap.allTrans.cones = {'20190127c05'; '20190127c09'; '20190128c09'; };
organoidMap.allTrans.rods = {'20190127c04'; '20190127c06'; '20190127c07'; '20190127c08'; '20190128c10'; '20190128c11';};

%% Pulses
r=struct;
% r.node = tree.childBySplitValue('noRC').childBySplitValue('squirrellab.protocols.vPulseFamily');
% r.node = tree.childBySplitValue('noRC').childBySplitValue('squirrellab.protocols.vTails');

r.node = tree.childBySplitValue('c15').childBySplitValue(false);
% r.node = tree.children(1).childBySplitValue('squirrellab.protocols.vTails');

r.prepts=getProtocolSetting(r.node,'prepts');
r.stmpts=getProtocolSetting(r.node,'stmpts');
r.datapts=getProtocolSetting(r.node,'datapts');

i=1;
lfcut=30;
r.Data=BaselineSubtraction(riekesuite.getResponseVector(r.node.epochList.elements(i),'Amp1')',1,r.prepts);
r.Stim=riekesuite.getStimulusVector(r.node.epochList.elements(i),'Amp1')*1;
r.tAx= (0:length(r.Data)-1).*getSamplingInterval(node);
r.lf= zeros(size(r.tAx));
r.lf(1:lfcut)=LinearFilter(1:lfcut);
% r.lf(end-lfcut:end)=LinearFilter(end-lfcut:end);
r.lf=r.lf;
r.mData=real(ifft((fft(r.Stim)).*samplingInterval.*fft(r.lf).*samplingInterval)./samplingInterval);
r.mData=BaselineSubtraction(r.mData,1,r.prepts);

f4=getfigH(4);
lH=lineH(r.tAx,r.Stim,f4);
lH.linemarkers;

f3=getfigH(3);
lH=lineH(r.tAx,r.Data,f3);
lH.line;

lH=lineH(r.tAx,r.mData,f3);
lH.line;
lH.color([0 0 0]);
f3.XLim=[r.prepts*samplingInterval-0.005 r.prepts*samplingInterval+.025];
% f3.XLim = [0 1];








% end
