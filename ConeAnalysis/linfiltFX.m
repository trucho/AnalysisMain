classdef linfiltFX < handle
    % linear filter derivation functions
    % linfiltFX
    % Created Oct_2016 (angueyra@nih.gov)
    properties
        
    end
    
    properties (SetAccess = private)
        
    end
    
    methods
        
        
        function [lf,tAx] = getLinearFilter(obj, node, lftime)
            if ~strcmp(node.parent.splitKey,'@(epoch)splitAutoRC(epoch)') || ...
                    ~node.splitValue
                error('provided node is not autoRC node')
            end
            prepts=getProtocolSetting(node,'prepts');
            stmpts=getProtocolSetting(node,'stmpts');
            freqcut=node.epochList.elements(1).protocolSettings('stimuli:Amp1:freqCutoff');
            samplingInterval=getSamplingInterval(node);
            lfpts = round(lftime * 1e-3 / samplingInterval);
            stimName = char(getStimStreamName(node));
            Data = riekesuite.getResponseMatrix(node.epochList,stimName);
            Data = Data(:,prepts:prepts+stmpts);
%             Data = BaselineSubtraction(Data,1,prepts);
            Stim=riekesuite.getStimulusMatrix(node.epochList,stimName);
            Stim = Stim(:,prepts:prepts+stmpts);
%             Stim = BaselineSubtraction(Stim,1,prepts);
            lf = NaN(size(Data,1),lfpts);
            
            for i = 1:size(Data,1)
                    tempLF(1,:) = obj.LinearFilterFinder(...
                        Stim(i,1:stmpts/2),Data(i,1:stmpts/2),...
                        1/samplingInterval,freqcut*1.0);
                    tempLF(2,:) = obj.LinearFilterFinder(...
                        Stim(i,stmpts/4+1:stmpts/4+stmpts/2),Data(i,stmpts/4+1:stmpts/4+stmpts/2),...
                        1/samplingInterval,freqcut*1.0);
                    tempLF(3,:) = obj.LinearFilterFinder(...
                        Stim(i,stmpts/2+1:stmpts),Data(i,stmpts/2+1:stmpts),...
                        1/samplingInterval,freqcut*1.0);
                lf(i,:) = mean(tempLF(:,1:lfpts));
            end
              
            tAx = (0:lfpts-1)*getSamplingInterval(node);
        end
        
        
        function [lf,tAx] = getLinearFilter2(obj, node, lftime)
            if ~strcmp(node.parent.splitKey,'@(epoch)splitAutoRC(epoch)') || ...
                    ~node.splitValue
                error('provided node is not autoRC node')
            end
            prepts=getProtocolSetting(node,'prepts');
            stmpts=getProtocolSetting(node,'stmpts');
            freqcut=node.epochList.elements(1).protocolSettings('stimuli:Amp1:freqCutoff');
            samplingInterval=getSamplingInterval(node);
            lfpts = round(lftime * 1e-3 / samplingInterval);
            stimName = char(getStimStreamName(node));
            Data = riekesuite.getResponseMatrix(node.epochList,stimName);
%             Data = BaselineSubtraction(Data,1,prepts);
            Stim=riekesuite.getStimulusMatrix(node.epochList,stimName);
%             Stim = BaselineSubtraction(Stim,1,prepts);
            tempLF = NaN(size(Data,1),stmpts+1);
            lf = NaN(size(Data,1),lfpts);
            for i = 1:size(Data,1)
                tempLF(i,:) = obj.LinearFilterFinder(...
                    Stim(i,prepts:prepts+stmpts),...
                    Data(i,prepts:prepts+stmpts),...
                    1/samplingInterval,...
                    freqcut*1.0);
                lf(i,:) = tempLF(i,1:lfpts);
            end
              
            tAx = (0:lfpts-1)*getSamplingInterval(node);
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

