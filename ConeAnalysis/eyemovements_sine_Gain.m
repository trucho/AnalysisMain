function eyemovements_sine_Gain(node,figH,doInit,params)
% function eyemovements_sine_MeanDiff(node,figH,doInit,params)
% Created Jul_2013 Angueyra
% jauimodel & epochTreeGui compatible


if isfield(params,'decimation') && ~isempty(params.decimation)
    decimation=params.decimation;
else 
    decimation=200;
end

guiClass=guiClassifier(node);

if ~strcmpi(guiClass,'leaf') %Single Contrast
    fprintf('Click on single contrast\n')
else
    % create new panel slider, info table
    delete(get(figH, 'Children'));
    figData.currentFunction = mfilename;
    l = .0001; %left position
    w = .9999; %width
    
    [StimTime,Stim]=getSaccadeSineTrajectory(node);
    led=getStimStreamName(node);
    subStim=subStimParser(node.epochList.firstValue,led{1});
    cnt=0;
    for i=1:length(subStim)
        PrePts_sub(i)=subStim{i}.prepts;
        if strcmpi(subStim{i}.type,'Pulse')
            cnt=cnt+1;
            fixs(cnt)=i;
        end
    end

    fixstart=PrePts_sub(fixs(2:end));
    fixend=[PrePts_sub(fixs(3:end)) size(StimTime,2)];
    transitions_index=[2,4,6,8];
    transitions_ib=NaN(size(transitions_index));
    cnt=0;
    for g=transitions_index
        cnt=cnt+1;
        transitions_ib(cnt)=round(mean(Stim(fixend(g):fixend(g))));
    end

    Rows=cnt;
    colors=round(pmkmp(Rows,'CubicLQuarter')./1.2.*255);
%     colors=round(lbmap(4,'RedBlueBrown')./1.2.*255);
    Selected=false(Rows,1);
    Selected(1)=true;
    Selected(2)=true;
    Selected(3)=true;
    Selected(4)=true;
    for i=1:Rows
        RowNames{i}=sprintf('<html><font color=rgb(%d,%d,%d)>%d</font></html>',colors(i,1),colors(i,2),colors(i,3),transitions_ib(i));
    end
    
    infoData = Selected;
    figData.infoTable = uitable('Parent', figH, ...
        'Units', 'normalized', ...
        'Position', [0.01, .005, 0.07, .985], ...
        'FontSize',8,...
        'ColumnWidth','auto',...
        'Data', infoData, ...
        'ColumnName',{'S'},...
        'RowName', RowNames,...
        'ColumnEditable', true(1,Rows),...
        'ColumnWidth',{12},...
        'CellEditCallback',{@table_callBack});
    figData.panel = uipanel('Parent', figH, ...
        'Units', 'normalized', ...
        'UserData',node, ...
        'Position', [l 0.00001 w 1]);
    set(figH, 'UserData', figData, 'ResizeFcn',{@canvasResizeFcn,figData});
    modifyUITableHeaderWidth(figData.infoTable,40);
    
    if strcmpi(node.epochList.firstValue.protocolSettings('user:ampMode'),'iclamp') %transform to mV for ease
        iclamp=1;
    else
        iclamp=0;
    end

    % Data plot
    sp = axes('Position',[.745 .265 .25 .35],'Parent', figData.panel,'tag','sp');
    set(sp,'XScale','linear','YScale','linear')
    if iclamp
        set(get(sp,'YLabel'),'string','Vmemb (mV)')
    else
        set(get(sp,'YLabel'),'string','i (pA)','FontSize',8)
    end
    set(get(sp,'XLabel'),'string','Time (s)','FontSize',8)
    set(sp,'FontSize',8)
    set(sp,'YAxisLocation','left','XTickLabel',[])
     
    % Stimulus
    sp2 = axes('Position',[.745 .08 .25 .14],'Parent', figData.panel,'tag','sp2');
    set(sp2,'XScale','linear','YScale','linear')
    set(sp2,'XLim',[min(StimTime) max(StimTime)],'YLim',[floor(min(Stim)/100)*100 ceil(max(Stim)/100)*100])
    set(get(sp2,'XLabel'),'string','Time (s)','FontSize',8)
    set(get(sp2,'YLabel'),'string','R*/s','FontSize',8)
    set(sp2,'FontSize',8)
    set(sp2,'YAxisLocation','left')
    
    line_handle=line(StimTime,Stim,'Parent',sp2);
    set(line_handle,'LineStyle','-','Marker','none','LineWidth',2,'MarkerSize',5,'Color',[0 0 0])
    
    
    % Transitions_Stim plot
    sp_stim = axes('Position',[.14 .87 .55 .10],'Parent', figData.panel,'tag','sp_stim');
    set(sp_stim,'XScale','linear','YScale','linear')
%     set(get(sp_stim,'XLabel'),'string','Time (s)')
    set(sp_stim,'XTickLabel',[])
    set(get(sp_stim,'YLabel'),'string','R*/s')
    
    % Transitions plot
    sp_data = axes('Position',[.14 .54 .55 .30],'Parent', figData.panel,'tag','sp_data');
    set(sp_data,'XScale','linear','YScale','linear')
    set(sp_data,'XTickLabel',[])
    if iclamp
        set(get(sp_data,'YLabel'),'string','Vmemb (mV)')
    else
        set(get(sp_data,'YLabel'),'string','i (pA)')
    end
    
    % Gain plot
    sp_gain = axes('Position',[.14 .28 .55 .22],'Parent', figData.panel,'tag','sp_gain');
    set(sp_gain,'XScale','linear','YScale','linear')
%     set(get(sp_gain,'XLabel'),'string','Time (s)')
    if iclamp
        set(get(sp_gain,'YLabel'),'string','mV/R*')
    else
        set(get(sp_gain,'YLabel'),'string','pA/R*')
    end
    set(sp_gain,'XTickLabel',[])

% Difference plot
    sp_diff = axes('Position',[.14 .07 .55 .18],'Parent', figData.panel,'tag','sp_diff');
    set(sp_diff,'XScale','linear','YScale','linear')
    set(get(sp_diff,'XLabel'),'string','Time (s)')
    set(get(sp_diff,'YLabel'),'string','(Delta)i (pA)')
%     set(sp_diff,'XTickLabel',[])

    plotOne(figData.infoTable);

end
end

function plotOne(hObject,eventdata)
figData=get(get(hObject,'Parent'),'UserData');
% decimation=get(figData.tagButton,'UserData');
decimation=100;
node=get(figData.panel,'UserData');
cellname=getcellname(node);
Selected=get(figData.infoTable,'Data');
results=toMatlabStruct(node.custom.get('results'));
nullresults=toMatlabStruct(node.parent.childBySplitValue('Null').custom.get('results'));
cellresults=toMatlabStruct(node.parent.custom.get('results'));
SampleEpoch = node.epochList.firstValue;
SamplingInterval=getSamplingInterval(node);
[StimTime,Stim]=getSaccadeSineTrajectory(node);
led=getStimStreamName(node);
subStim=subStimParser(SampleEpoch,led{1});
% fixs=false(1,length(subStim));
cnt=0;
for i=1:length(subStim)
    PrePts_sub(i)=subStim{i}.prepts;
    StmPts_sub(i)=subStim{i}.stmpts;
    TailPts_sub(i)=subStim{i}.tailpts;
    if strcmpi(subStim{i}.type,'Pulse')
        cnt=cnt+1;
       fixs(cnt)=i;
    end
end
%%
EpochTimes=getEpochTimesByCell(node,[]);


Data=riekesuite.getResponseMatrix(node.epochList,'Amp_1');
if strcmpi(node.epochList.firstValue.protocolSettings('user:ampMode'),'iclamp') %transform to mV for ease
    iclamp=1;
    Data = Data*1000;
else
    iclamp=0;
end

TimeAxis=(0:size(Data(1,:),2)-1)*SamplingInterval;

Vmemb=mean(Data(:,max(TailPts_sub):length(Data)),2);
VmembSD=std(Data(:,max(TailPts_sub):length(Data)),1,2);

% Using last long fixation for baseline subtraction
Data=BaselineSubtraction(Data,max(TailPts_sub),length(Data));
% Using first fixation for baseline subtraction (hopefully it's dark current)
% prepts_sorted=sort(PrePts_sub);
% Data=BaselineSubtraction(Data,prepts_sorted(3)+50,prepts_sorted(4));

% Data plot
sp=findobj('tag','sp');
delete(get(sp,'Children'));
% set(sp,'XLim',[min(TimeAxis) max(TimeAxis)])

if isfield(results,'Mean')
%     fill_handle=fill(decimate([results.TimeAxis fliplr(results.TimeAxis)],decimation),...
%         decimate([results.Mean-results.SD fliplr(results.Mean+results.SD)],decimation),'k','Parent',sp);
%     set(fill_handle,'EdgeColor',[.7 .7 .7],'FaceColor',[.7 .7 .7],'FaceAlpha',0.5);
%     set(sp,'tag','sp');
    line_handle=line(decimate(results.TimeAxis,decimation),decimate(results.Mean,decimation),'Parent',sp);
    set(line_handle,'DisplayName','Data','LineStyle','-','Marker','none','Color',[0 0 0])
    line_handle=line(decimate(results.TimeAxis,decimation),decimate(results.Mean-results.SD,decimation),'Parent',sp);
    set(line_handle,'DisplayName','SDminus','LineStyle','-','Marker','none','Color',[.5 .5 .5])
    line_handle=line(decimate(results.TimeAxis,decimation),decimate(results.Mean+results.SD,decimation),'Parent',sp);
    set(line_handle,'DisplayName','SDplus','LineStyle','-','Marker','none','Color',[.5 .5 .5])
else
    fprintf('Run screenepochs and calculate mean first')
    BIPBIP();
end

%% HACK!!!!
if 0
% replacing results.Mean by Linear Model to see what changes!
if exist(sprintf('/Users/juan/matlab/matlab-analysis/trunk/users/juan/Cones_savedfits/DimFlashes/%s.mat',cellname),'file')==2 
    load(sprintf('/Users/juan/matlab/matlab-analysis/trunk/users/juan/Cones_savedfits/DimFlashes/%s.mat',cellname))
    saved_coeffs=DimFlash.coeffs;
    LinearFilter=-ConeEmpiricalDimFlash(DimFlash.coeffs,results.TimeAxis);
    
    FilterFFT=fft(LinearFilter).* SamplingInterval;
    StimFFT=fft(results.Stim).* SamplingInterval;
    LinearModel=ifft(FilterFFT .* StimFFT) ./ SamplingInterval;
    
%     a=find(results.TimeAxis>=0.90,1,'first');
%     b=find(results.TimeAxis<=1.00,1,'last');
    
    a=find(results.TimeAxis>=1.40,1,'first');
    b=find(results.TimeAxis<=1.50,1,'last');

    rescale=mean(results.Mean(a:b))./mean(LinearModel(a:b));
    results.Mean=LinearModel.*rescale;
else
    rescale=1;
end

if isfield(results,'Mean')
% %     fill_handle=fill(decimate([results.TimeAxis fliplr(results.TimeAxis)],decimation),...
% %         decimate([results.Mean-results.SD fliplr(results.Mean+results.SD)],decimation),'k','Parent',sp);
% %     set(fill_handle,'EdgeColor',[.7 .7 .7],'FaceColor',[.7 .7 .7],'FaceAlpha',0.5);
% %     set(sp,'tag','sp');
% 
% 
% 
%     line_handle=line(decimate(results.TimeAxis,decimation),decimate(results.Mean,decimation),'Parent',sp);
%     set(line_handle,'DisplayName','LinData','LineStyle','-','Marker','none','Color',[1 0 0])
%     line_handle=line(decimate(results.TimeAxis,decimation),decimate(results.Mean-results.SD,decimation),'Parent',sp);
%     set(line_handle,'DisplayName','LinSDminus','LineStyle','-','Marker','none','Color',[.8 .5 .5])
%     line_handle=line(decimate(results.TimeAxis,decimation),decimate(results.Mean+results.SD,decimation),'Parent',sp);
%     set(line_handle,'DisplayName','LinSDplus','LineStyle','-','Marker','none','Color',[.8 .5 .5])
%     
%     line_handle=line(decimate(results.TimeAxis,decimation),decimate(results.Mean./rescale,decimation),'Parent',sp);
%     set(line_handle,'DisplayName','UnscaledLinData','LineStyle','-','Marker','none','Color',[.7 .5 .7])

    MeanLPF=LowPassFilter(results.Mean,100,getSamplingInterval(node));
    SDLPF=LowPassFilter(results.SD,100,getSamplingInterval(node));
    
    
    line_handle=line(decimate(results.TimeAxis,decimation),decimate(MeanLPF,decimation),'Parent',sp);
    set(line_handle,'DisplayName','LinData','LineStyle','-','Marker','none','Color',[1 0 0])
    line_handle=line(decimate(results.TimeAxis,decimation),decimate(MeanLPF-SDLPF,decimation),'Parent',sp);
    set(line_handle,'DisplayName','LinSDminus','LineStyle','-','Marker','none','Color',[.8 .5 .5])
    line_handle=line(decimate(results.TimeAxis,decimation),decimate(MeanLPF+SDLPF,decimation),'Parent',sp);
    set(line_handle,'DisplayName','LinSDplus','LineStyle','-','Marker','none','Color',[.8 .5 .5])
    
    line_handle=line(decimate(results.TimeAxis,decimation),decimate(MeanLPF./rescale,decimation),'Parent',sp);
    set(line_handle,'DisplayName','UnscaledLinData','LineStyle','-','Marker','none','Color',[.7 .5 .7])
else
    fprintf('Run screenepochs and calculate mean first')
    BIPBIP();
end

end
%%
colors=pmkmp(node.epochList.length,'CubicL');

fixstart=PrePts_sub(fixs(2:end));
fixend=[PrePts_sub(fixs(3:end)) size(Data,2)];
fixduration=fixend-fixstart;


sp_data=findobj('tag','sp_data');
sp_diff=findobj('tag','sp_diff');
% sp_diff=getfigH(3);
% set(sp_diff,'YLim',[-5 5])
sp_stim=findobj('tag','sp_stim');
sp_gain=findobj('tag','sp_gain');

delete(get(sp_data,'Children'))
delete(get(sp_diff,'Children'))
delete(get(sp_gain,'Children'))
clear transitions* temp*
cnt=0;
colors2=pmkmp(4,'CubicLQuarter');
% colors2=lbmap(4,'RedBlueBrown');
colors2=colors2([2 3 1 4],:);
wcolors2=whithen(colors2,.5);
transitions_index=[2,4,6,8];
transitions_ib=NaN(size(transitions_index));
transitions_size=min(fixend(transitions_index+3)-fixend(transitions_index));
transitions=NaN(length(transitions_index),transitions_size);
transitionsSD=NaN(length(transitions_index),transitions_size);
nulltransitions=NaN(length(transitions_index),transitions_size);
nulltransitionsSD=NaN(length(transitions_index),transitions_size);
transitionstime=(0:transitions_size-1).*SamplingInterval;
transitionstime=transitionstime-((transitions_size/3).*SamplingInterval);
transitions_stim=NaN(length(transitions_index),transitions_size);
transitions_step=NaN(length(transitions_index),transitions_size);
transitions_sine=NaN(length(transitions_index),transitions_size);
%To subtract null responses
global subNull
if strcmpi(node.splitValue,'Null')
    subNull=0;
end

for g=transitions_index(Selected)
    cnt=cnt+1;
    
    %steps only
    tempmean=nullresults.Mean(fixend(g-1):fixend(g+2));
    nulltransitions(cnt,:)=tempmean(1:transitions_size);
    tempSD=nullresults.SD(fixend(g-1):fixend(g+2));
    nulltransitionsSD(cnt,:)=tempSD(1:transitions_size);
    
    %steps and current sine
    tempmean=results.Mean(fixend(g-1):fixend(g+2));
    transitions(cnt,:)=tempmean(1:transitions_size);
    tempSD=results.SD(fixend(g-1):fixend(g+2));
    transitionsSD(cnt,:)=tempSD(1:transitions_size);
    
    transitions_ib(cnt)=mean(Stim(fixend(g):fixend(g)));
    
    nulltransitions_lpf=LowPassFilter(nulltransitions,100,getSamplingInterval(node));
    if ~subNull %HACK to subtract null responses (don't plot null)
%         ltH(cnt)=line(transitionstime,nulltransitions(cnt,:),'Parent',sp_data);
        ltH(cnt)=line(transitionstime,nulltransitions_lpf(cnt,:),'Parent',sp_data);
        set(ltH(cnt),'Color',wcolors2(cnt,:),'LineWidth',2,'Marker','none')
        set(ltH(cnt),'DisplayName',sprintf('nulltrans_%g',round(transitions_ib(cnt))))
        fprintf('nulltrans_%g\n',round(transitions_ib(cnt)))
    elseif subNull %HACK to subtract null responses
        transitions(cnt,:)=transitions(cnt,:)-nulltransitions(cnt,:);
    end
    transitions_lpf=LowPassFilter(transitions,100,getSamplingInterval(node));
    transitionsSD_lpf=LowPassFilter(transitionsSD,100,getSamplingInterval(node));
    
    ltH(cnt)=line(transitionstime,transitions_lpf(cnt,:),'Parent',sp_data);
    set(ltH(cnt),'Color',colors2(cnt,:),'LineWidth',2,'Marker','none')
    set(ltH(cnt),'DisplayName',sprintf('trans_%g',round(transitions_ib(cnt))))
    
%     ltsdH(cnt)=line(transitionstime,transitions(cnt,:)-transitionsSD(cnt,:),'Parent',sp_data);
%     set(ltsdH(cnt),'Color',colors2(cnt,:),'LineWidth',2,'Marker','none')
%     set(ltsdH(cnt),'DisplayName',sprintf('vMsd_%g_1',round(transitions_ib(cnt))))
%     
%     ltsdH(cnt)=line(transitionstime,transitions(cnt,:)+transitionsSD(cnt,:),'Parent',sp_data);
%     set(ltsdH(cnt),'Color',colors2(cnt,:),'LineWidth',2,'Marker','none')
%     set(ltsdH(cnt),'DisplayName',sprintf('vMsd_%g_2',round(transitions_ib(cnt))))
    
    % stimulus
    tempstim=results.Stim(fixend(g-1):fixend(g+2)); % combined
    transitions_stim(cnt,:)=tempstim(1:transitions_size);
    tempstim = nullresults.Stim(fixend(g-1):fixend(g+2));
    transitions_step(cnt,:)=tempstim(1:transitions_size); % step only    
    transitions_sine(cnt,:)=transitions_stim(cnt,:)-transitions_step(cnt,:); % sine only
    
    
    lsH(cnt)=line(transitionstime,transitions_stim(cnt,:),'Parent',sp_stim);
    set(lsH(cnt),'Color',colors2(cnt,:),'LineWidth',2,'Marker','none')
    set(lsH(cnt),'DisplayName',sprintf('stim_%g',round(transitions_ib(cnt))))
end
clear temp* dprime

% REFERENCE FOR SUBTRACTION (Angueyra 2016)
ref=find(transitions_ib<=min(transitions_ib),1,'first');
% ref=find(transitions_ib>=max(transitions_ib),1,'last');
fprintf('reference background is: %g\n',transitions_ib(ref))

keyboard
cnt=0;
for g=transitions_index(Selected)
    cnt=cnt+1;
    ltsdH(cnt)=line(transitionstime,transitionsSD_lpf(cnt,:),'Parent',sp_gain);
    set(ltsdH(cnt),'Color',colors2(cnt,:),'LineWidth',2,'Marker','none')
    set(ltsdH(cnt),'DisplayName',sprintf('sd_%g_1',round(transitions_ib(cnt))))
   
%     mean_diff(cnt,:)=abs(transitions(ref,:)-transitions(cnt,:));
    mean_diff(cnt,:)=(transitions(ref,:)-transitions(cnt,:));
    dprime(cnt,:)=abs(transitions(ref,:)-transitions(cnt,:))./((transitionsSD(ref,:)+transitionsSD(cnt,:))./2);
    
    mean_diff_lpf=LowPassFilter(mean_diff,100,getSamplingInterval(node));
    
%     if strcmpi(node.splitValue,'Null')
        ltsdH(cnt)=line(transitionstime,mean_diff_lpf(cnt,:),'Parent',sp_diff);
        set(ltsdH(cnt),'Color',colors2(cnt,:),'LineWidth',2,'Marker','none')
        set(ltsdH(cnt),'DisplayName',sprintf('MeanDiff_%g_1',round(transitions_ib(cnt))))
%     end
end

global savediffs
if savediffs
    results.means_ib=transitions_ib;
    results.means_ref=ref;
    results.means=transitions;
    results.meansSD=transitionsSD;
    results.means_dprime=dprime;
    results.means_diff=mean_diff;
    results.means_tAxis=transitionstime;
    node.custom.put('results',riekesuite.util.toJavaMap(results));
    
    fprintf('Saved means diffs to results\n')
end
    


%% plotting dprime at the sine peaks 
if 0%~strcmpi(node.splitValue,'Null')
cnt=0;
for g=transitions_index(Selected)
    cnt=cnt+1;
    
    if strcmpi(node.splitValue,'0000')
        phi=1;
    elseif strcmpi(node.splitValue,'0090')
        phi=2;
    elseif strcmpi(node.splitValue,'0180')
        phi=3;
    elseif strcmpi(node.splitValue,'0270')
        phi=4;
    end
    
    if subNull
        %current peaks on subtracted sine
        lpH(cnt)=line(cellresults.tPeaks{g}(phi),cellresults.Peaks{g}(phi),'Parent',sp_data);
        set(lpH(cnt),'Color',colors2(cnt,:),'LineWidth',1,'LineStyle','none','Marker','.')
        set(lpH(cnt),'DisplayName',sprintf('sine_peaks_%g',round(transitions_ib(cnt))))
        % current error bars
        ebx=repmat(cellresults.tPeaks{g}(phi),1,3);
        eby=[cellresults.Peaks{g}(phi)-cellresults.PeaksSD{g}(phi),...
            cellresults.Peaks{g}(phi),...
            cellresults.Peaks{g}(phi)+cellresults.PeaksSD{g}(phi)];
        for i=1:length(ebx)
            lgsdH(cnt)=line(ebx(i,:),eby(i,:),'Parent',sp_data);
            set(lgsdH(cnt),'Color',colors2(cnt,:),'LineWidth',1,'LineStyle','-','Marker','none')
            set(lgsdH(cnt),'DisplayName',sprintf('sine_sd_%g_%g',round(transitions_ib(cnt)),i))
        end
        
        %left flank peaks on subtracted sine
        lplH(cnt)=line(cellresults.tPeaks{g-1}(phi)-.5,cellresults.Peaks{g-1}(phi),'Parent',sp_data);
        set(lplH(cnt),'Color',colors2(cnt,:),'LineWidth',1,'LineStyle','none','Marker','.')
        set(lplH(cnt),'DisplayName',sprintf('sine_peaksl_%g',round(transitions_ib(cnt))))
        % left flank error bars
        ebx=repmat(cellresults.tPeaks{g-1}(phi)-.5,1,3);
        eby=[cellresults.Peaks{g-1}(phi)-cellresults.PeaksSD{g-1}(phi),...
            cellresults.Peaks{g-1}(phi),...
            cellresults.Peaks{g-1}(phi)+cellresults.PeaksSD{g-1}(phi)];
        for i=1:length(ebx)
            lgsldH(cnt)=line(ebx(i,:),eby(i,:),'Parent',sp_data);
            set(lgsldH(cnt),'Color',colors2(cnt,:),'LineWidth',1,'LineStyle','-','Marker','none')
            set(lgsldH(cnt),'DisplayName',sprintf('sinel_sd_%g_%g',round(transitions_ib(cnt)),i))
        end
        
        
        
        %right peaks on subtracted sine
        lprH(cnt)=line(cellresults.tPeaks{g+1}(phi)+.5,cellresults.Peaks{g+1}(phi),'Parent',sp_data);
        set(lprH(cnt),'Color',colors2(cnt,:),'LineWidth',1,'LineStyle','none','Marker','.')
        set(lprH(cnt),'DisplayName',sprintf('sine_peaksr_%g',round(transitions_ib(cnt))))
        % left flank error bars
        ebx=repmat(cellresults.tPeaks{g-1}(phi)+.5,1,3);
        eby=[cellresults.Peaks{g+1}(phi)-cellresults.PeaksSD{g+1}(phi),...
            cellresults.Peaks{g+1}(phi),...
            cellresults.Peaks{g+1}(phi)+cellresults.PeaksSD{g+1}(phi)];
        for i=1:length(ebx)
            lgsrdH(cnt)=line(ebx(i,:),eby(i,:),'Parent',sp_data);
            set(lgsrdH(cnt),'Color',colors2(cnt,:),'LineWidth',1,'LineStyle','-','Marker','none')
            set(lgsrdH(cnt),'DisplayName',sprintf('siner_sd_%g_%g',round(transitions_ib(cnt)),i))
        end
    end
    
    % current dprime
    ltdppH(cnt)=line(cellresults.DPT{g},cellresults.DP{g},'Parent',sp_diff);
    set(ltdppH(cnt),'Color',colors2(cnt,:),'LineWidth',1,'LineStyle','none','Marker','.')
    set(ltdppH(cnt),'DisplayName',sprintf('dprime_peaks_%g',round(transitions_ib(cnt))))
    
    %left flank dprime
    ltdppH(cnt)=line(cellresults.DPT{g-1}-.5,cellresults.DP{g-1},'Parent',sp_diff);
    set(ltdppH(cnt),'Color',colors2(cnt,:),'LineWidth',1,'LineStyle','none','Marker','.')
    set(ltdppH(cnt),'DisplayName',sprintf('dprime_peaks_left%g',round(transitions_ib(cnt))))
    
    %right flank dprime
    ltdppH(cnt)=line(cellresults.DPT{g+1}+.5,cellresults.DP{g+1},'Parent',sp_diff);
    set(ltdppH(cnt),'Color',colors2(cnt,:),'LineWidth',1,'LineStyle','none','Marker','.')
    set(ltdppH(cnt),'DisplayName',sprintf('dprime_peaks_right%g',round(transitions_ib(cnt))))  
end
end
%%

% %% Trying out exponential fitting
% % f1=getfigH(1);
% % f2=getfigH(2);
% if strcmpi(node.splitValue,'Null')
% fprintf('\n\n')
% for i=1:4
%     if i~=ref
%         
%         dp=dprime(i,fixend(2):fixend(2)+fixduration(2));
%         tAx=transitionstime(1:length(dp))+.5;
%         
%         % guess=[mean(dprime(i,29000:30000)) ...
%         %     20 ...
%         %     mean(dprime(i,19000:20000))];
%         % fitfx=@(optcoeffs,tAx)(1-((optcoeffs(1)*(1-(exp(-optcoeffs(2).*tAx))))-optcoeffs(3)));
%         
%         guess=[mean(dprime(i,fixend(2)-100:fixend(2))) 20];
%         
%         fitfx=@(optcoeffs,tAx)(optcoeffs(1)*(exp(-optcoeffs(2).*tAx)));
%         guessfit=fitfx(guess,tAx);
%         
%         
%         % fmincon
%         FMC.x0=guess;
%         FMC.lb=[0000 0000];
%         FMC.ub=[1000 1000];
%         FMC.solver='fmincon';
%         FMC.options=optimset('Algorithm','interior-point',...
%             'DiffMinChange',1e-40,'Display','none',...
%             'TolX',1e-80,'TolFun',1e-40,'TolCon',1e-40,...
%             'MaxFunEvals',2000);
%         
%         
%         %     optfx=@(optcoeffs)(1-((optcoeffs(1)*(1-(exp(-optcoeffs(2).*tAx))))-optcoeffs(3)));
%         optfx=@(optcoeffs)(optcoeffs(1)*(exp(-optcoeffs(2).*tAx)));
%         errfx=@(optcoeffs)sum((optfx(optcoeffs)-dp).^2);
%         FMC.objective=errfx;
%         
%         fitcoeffs=fmincon(FMC);
%         fit=optfx(fitcoeffs);
%         fprintf('tau=%g ms \n',round((1/fitcoeffs(2))*100000)/100);
%         dDown(i)=round((1/fitcoeffs(2))*100000)/100;
%         
%         
%         lH=line(tAx+.5,fit,'Parent',sp_diff);
%         set(lH,'DisplayName',sprintf('expfitDown_%g',transitions_ib(i)),'Color',colors2(i,:)/2);
%         
%         dp=dprime(i,fixend(2)-fixduration:fixend(2));
%         tAx=transitionstime(1:length(dp))+.5;
%         
%         guess=[mean(dprime(i,fixend(2)-fixduration-100:fixend(2)-fixduration)) ...
%             10];
%         fitfx=@(optcoeffs,tAx)(((optcoeffs(1)*(1-(exp(-optcoeffs(2).*tAx))))));
%         guessfit=fitfx(guess,tAx);
%         
%         
%         % fmincon
%         FMC.x0=guess;
%         FMC.lb=[0000 0000];
%         FMC.ub=[1000 1000];
%         FMC.solver='fmincon';
%         FMC.options=optimset('Algorithm','interior-point',...
%             'DiffMinChange',1e-40,'Display','none',...
%             'TolX',1e-80,'TolFun',1e-40,'TolCon',1e-40,...
%             'MaxFunEvals',2000);
%         
%         
%         
%         colors=pmkmp(9);
%         optfx=@(optcoeffs)(((optcoeffs(1)*(1-(exp(-optcoeffs(2).*tAx))))));
%         errfx=@(optcoeffs)sum((optfx(optcoeffs)-dp).^2);
%         FMC.objective=errfx;
%         
%         fitcoeffs=fmincon(FMC);
%         fit=optfx(fitcoeffs);
%         
%         fprintf('tau=%g ms \n',round((1/fitcoeffs(2))*100000)/100);
%         dUp(i)=round((1/fitcoeffs(2))*100000)/100;
%         
%         lH=line(tAx,fit,'Parent',sp_diff);
%         set(lH,'DisplayName',sprintf('expfitUp_%g',transitions_ib(i)),'Color',colors2(i,:)/2);
%     else
%         dDown(i)=0;
%         dUp(i)=0;
%     end
% end
% 
% cellresults.tauUp_Lum_Ib=transitions_ib;
% cellresults.tauUp_Lum=dUp;
% cellresults.tauDown_Lum=dDown;
% 
% node.parent.custom.put('results',riekesuite.util.toJavaMap(cellresults));
% end
%%
% set(sp_data,'XLim',[min(transitionstime) max(transitionstime)])
% set(sp_diff,'XLim',[min(transitionstime) max(transitionstime)])
% set(sp_stim,'XLim',[min(transitionstime) max(transitionstime)])
% set(sp_gain,'XLim',[min(transitionstime) max(transitionstime)])

set(sp_data,'XLim',[-0.05 max(transitionstime)])
set(sp_diff,'XLim',[-0.05 max(transitionstime)])
set(sp_stim,'XLim',[-0.05 max(transitionstime)])
set(sp_gain,'XLim',[-0.05 max(transitionstime)])


leg3=legend(ltH,cellstr(num2str(round(transitions_ib)','%-d')));
set(leg3,'Box','off')

% Stimulus Limits
ylims3=get(sp_data,'ylim');
ylims4=get(sp_diff,'ylim');
ylims4=[-2 2];
ylims5=get(sp_gain,'ylim');

fixlims=(fixend(5:6)-fixend(4))./20000;
rampstart=PrePts_sub(fixs);

lH=line([0 0],ylims3,'Parent',sp_data);
set(lH,'DisplayName','RampStart0','LineStyle','--','LineWidth',1,'Marker','none','Color',[0 0 0])

lH=line([fixlims(1) fixlims(1)],ylims3,'Parent',sp_data);
set(lH,'DisplayName','RampStart1','LineStyle','--','LineWidth',1,'Marker','none','Color',[0 0 0])

lH=line([fixlims(2) fixlims(2)],ylims3,'Parent',sp_data);
set(lH,'DisplayName','RampStart2','LineStyle','--','LineWidth',1,'Marker','none','Color',[0 0 0])


lH=line([0 0],ylims4,'Parent',sp_diff);
set(lH,'DisplayName','RampStart0','LineStyle','--','LineWidth',1,'Marker','none','Color',[0 0 0])

lH=line([fixlims(1) fixlims(1)],ylims4,'Parent',sp_diff);
set(lH,'DisplayName','RampStart1','LineStyle','--','LineWidth',1,'Marker','none','Color',[0 0 0])

lH=line([fixlims(2) fixlims(2)],ylims4,'Parent',sp_diff);
set(lH,'DisplayName','RampStart2','LineStyle','--','LineWidth',1,'Marker','none','Color',[0 0 0])


lH=line([0 0],ylims5,'Parent',sp_gain);
set(lH,'DisplayName','RampStart0','LineStyle','--','LineWidth',1,'Marker','none','Color',[0 0 0])

lH=line([fixlims(1) fixlims(1)],ylims5,'Parent',sp_gain);
set(lH,'DisplayName','RampStart1','LineStyle','--','LineWidth',1,'Marker','none','Color',[0 0 0])

lH=line([fixlims(2) fixlims(2)],ylims5,'Parent',sp_gain);
set(lH,'DisplayName','RampStart2','LineStyle','--','LineWidth',1,'Marker','none','Color',[0 0 0])

end



function Info=getInformation(range,binsize,fix_n,fix_mean,fix_sd, plot_flag)
% geting p(R) [across all ibs]
sp_diff=findobj('tag','sp_diff');

colors=pmkmp(fix_n);

for n=1:fix_n
    % p(R) modelled as the sum of little gaussians
    pR_sub(n,:)=normpdf(range,fix_mean(n),fix_sd(n))./fix_n.*binsize;
    % p(R/S) for each ib
    pR_S(n,:)=normpdf(range,fix_mean(n),fix_sd(n)).*binsize;
    %     lH=line(pR_S(n,:)./fix_n,range,'Parent',sp_diff);
    if plot_flag
        lH=line(pR_S(n,:),range,'Parent',sp_diff);
        set(lH,'Marker','none','LineStyle','-','linewidth',2,'Color',colors(n,:))
    end
end
pR=sum(pR_sub);

if plot_flag
    lH=line(pR,range,'Parent',sp_diff);
    set(lH,'Marker','none','LineStyle','-','linewidth',2,'Color',[0 0 0])
end
% Method #1
for n=1:fix_n
    % entropy derived from each stim (H(S/R))
    EntropySR(n)=-nansum(pR_S(n,:).*log2(pR_S(n,:)./(fix_n*pR)))./fix_n;
end
Info=log2(fix_n)-sum(EntropySR);

%{
h=hist(reshape(fixvm,1,numel(fixvm)),range);
h=h./numel(fixvm);

% p(R) modelled as a big gaussian (not good enough probably because of limited stimuli)
% pRGaussian=normpdf(range,fix_allmean,fix_allsd).*delta;
% lH=line(range,pRGaussian,'Parent',f1);
% set(lH,'Marker','.','LineStyle','none','Color',[0 0 1])
lH=line(range,pR,'Parent',f1);
set(lH,'Marker','.','LineStyle','none','Color',[0 0 0])
[sr,sh]=stairs(range,h);
lH=line(sr,sh,'Parent',f1);
set(lH,'Color',[1 0 0])

% Method #2
EntropyR=-nansum(pR.*log2(pR));
for n=1:fix_n
    % entropy derived from each stim (H(S/R))
    EntropyRS(n)=-nansum(pR_S(n,:).*log2(pR_S(n,:)))./fix_n;
end
Info2(b)=EntropyR-sum(EntropyRS);
% Then next step is to see evolution of information across 30-50ms bins
% into fixation
end



f2=getfigH(2);
lH=line(binsize,Info,'Parent',f2);
set(lH,'Marker','o','Color',[0 0 1]);
lH=line(binsize,Info2,'Parent',f2);
set(lH,'Marker','.','Color',[0 0 0]);

f3=getfigH(3);
for n=1:fix_n
lH=line(range,(pR_S(n,:)./(fix_n.*pR)).*log2(pR_S(n,:)./(fix_n.*pR)),'Parent',f3);
set(lH,'Marker','.','Color',colors(n,:))
%}
end

function table_callBack(hObject,eventdata)
disableGui(hObject);
plotOne(hObject)
enableGui(hObject);
end
function disableGui(hObject)
set(findobj('-property','Enable'),'Enable','off')
drawnow
end
function enableGui(hObject)
set(findobj('-property','Enable'),'Enable','on')
drawnow
end
function canvasResizeFcn(panel, event, figData)
end
