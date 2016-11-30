classdef rcLeakObj < handle
    %RCLEAKOBJ stores all relevant data to perform leak subtraction from
    %sine and noise RC epochs
    
    properties
        rcnode
        
        lf
        lftAx
        lfpts
        
        rcntAx
        rcnData
        rcnModel
        rcnStim
        
        rcstAx
        rcsData
        rcsModel
        rcsStim
        
        prepts
        sinepts
        interpts
        noisepts
        tailpts
        freqcut
        sineFreq
        sinePhase
        sinecycles
        sinecyclepts
        samplingInterval
        
    end
    
    methods
        function obj = rcLeakObj(rcNode,lftime)
            if ~strcmp(rcNode.parent.splitKey,'@(epoch)splitAutoRC(epoch)') || ...
                    ~rcNode.splitValue
                error('provided node is not autoRC node')
            end
            obj.rcnode = rcNode;
            obj.prepts=getProtocolSetting(rcNode,'RCprepts');
            obj.sinepts=getProtocolSetting(rcNode,'RCsinepts');
            obj.interpts=getProtocolSetting(rcNode,'RCinterpts');
            obj.noisepts=getProtocolSetting(rcNode,'RCnoisepts');
            obj.tailpts=getProtocolSetting(rcNode,'RCtailpts');
            obj.freqcut=rcNode.epochList.elements(1).protocolSettings('RCfreqcutoff');
            obj.sineFreq=rcNode.epochList.elements(1).protocolSettings('RCsineFreq');
            obj.sinePhase=rcNode.epochList.elements(1).protocolSettings('RCphaseShift');
            obj.samplingInterval=getSamplingInterval(rcNode);
            
            obj.lfpts = round(lftime * 1e-3 / obj.samplingInterval);
            
            
            stimName = char(getStimStreamName(rcNode));
            rcData = riekesuite.getResponseMatrix(rcNode.epochList,stimName);
            rcData = BaselineSubtraction(rcData,1,obj.prepts);
            Stim=riekesuite.getStimulusMatrix(rcNode.epochList,stimName);
            Stim = BaselineSubtraction(Stim,1,obj.prepts);
            tempLF = NaN(size(rcData,1),obj.noisepts+1);
            rcModel = NaN(size(rcData));
            obj.lf = NaN(size(rcData,1),obj.lfpts);
            for i = 1:size(rcData,1)
                tempLF(i,:) = obj.LinearFilterFinder(...
                    Stim(i,obj.prepts:obj.prepts+obj.noisepts),...
                    rcData(i,obj.prepts:obj.prepts+obj.noisepts),...
                    1/obj.samplingInterval,...
                    obj.freqcut*1.0);
                obj.lf(i,:) = tempLF(i,1:obj.lfpts);
                rcModel(i,:) = obj.getLinearEstimation(Stim(i,:),obj.lf(i,:),obj.prepts,obj.samplingInterval);
            end
            obj.lftAx = (0:obj.lfpts-1)*obj.samplingInterval;
            
            obj.rcnData = rcData(:,1:obj.prepts+obj.noisepts+obj.interpts);
            obj.rcnModel = rcModel(:,1:obj.prepts+obj.noisepts+obj.interpts);
            obj.rcnStim = Stim(1:obj.prepts+obj.noisepts+obj.interpts);
            obj.rcntAx = (0:size(obj.rcnData,2)-1)*obj.samplingInterval;
            
            obj.sinecycles = 1/(obj.sineFreq*obj.samplingInterval);
            obj.sinecyclepts = obj.sinepts / obj.sinecycles;
            
            %working on averaging sine responses
            obj.rcnData = rcData(:,1:obj.prepts+obj.noisepts+obj.interpts);
            obj.rcnModel = rcModel(:,1:obj.prepts+obj.noisepts+obj.interpts);
            obj.rcnStim = Stim(1:obj.prepts+obj.noisepts+obj.interpts);
            obj.rcntAx = (0:size(obj.rcnData,2)-1)*obj.samplingInterval;
            
        end
    end
    
    methods (Static = true)
        
        function rcEpochIndex = getRCEpochs(node)
            % Matches epochs in node to appropriate RCfilter
            % assumes node contains the vPulses, with parent is a cell-node and that underneath epoch have
            % been split by RCepoch true vs. false
            if ~strcmpi(node.parent.splitKey,'@(epoch)splitAutoRC(epoch)')
                error('node.parent does not contain autoRC branch');
            end
            
            noderc = node.parent.childBySplitValue(true); %autoRC branch
            for r = 1:noderc.epochList.length
                rctstart(r) = noderc.epochList.elements(r).protocolSettings('epochBlock:startTime'); %#ok<AGROW>
            end
            rcEpochIndex = NaN(node.epochList.length,1);
            for e = 1:node.epochList.length
                matches = false(noderc.epochList.length,1);
                tstart = node.epochList.elements(e).protocolSettings('epochBlock:startTime');
                for r = 1:noderc.epochList.length
                    if (tstart.compareTo(rctstart(r)))==0
                        matches(r) = true;
                    end
                end
                rcEpochIndex(e) = find(matches,1,'first');
            end
        end
        
        function linearFilter=LinearFilterFinder(signal,response, samplerate, freqcutoff)
            filterFft = mean((fft(response,[],2).*1/samplerate.*conj(fft(signal,[],2).*1/samplerate)),1)./...
                mean(fft(signal,[],2).*1/samplerate.*conj(fft(signal,[],2).*1/samplerate),1);
            freqcutoff_adjusted = round(freqcutoff/(samplerate/length(signal))); % this adjusts the freq cutoff for the length
            filterFft(:,1+freqcutoff_adjusted:length(signal)-freqcutoff_adjusted) = 0 ;
            linearFilter = real(ifft(filterFft).*samplerate) ;
        end
       
        function modelData = getLinearEstimation(Stim, filter, prepts, samplingInterval)
            paddedFilter = zeros(1,size(Stim,2));
            paddedFilter(1:length(filter)) = filter;
            modelData = NaN(size(Stim));
            for i=1:size(Stim,1)
                modelData(i,:)=ifft((fft(Stim(i,:))).*samplingInterval.*fft(paddedFilter).*samplingInterval)./samplingInterval;
            end
            modelData=BaselineSubtraction(modelData,1,prepts);
        end
    end
end

