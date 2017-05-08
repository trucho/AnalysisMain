classdef hystObj < handle
    % post-analysis data of steps and sines from macaque cones
    % made for easy retrieval and plotting
    properties
        cellname
        expname
        Ib
        mean
        sd
        n
        stim
        phase
        tAx
        
        % paths
        dirData='~/Documents/Data/StepsSines/';
        dirFile
    end
    
    methods
        function hdata=hystObj(dirFile)
            if nargin == 0
                % don't do anything
                beep
                fprintf('creating empty hysObj\n')
            else
                % load previously saved data
                if ~ischar(dirFile)
                    fprintf('filename must be a string (e.g. ''021814Fc01_hDown5947.mat'')\n')

                else
                    if exist(sprintf('%s%s.mat',hdata.dirData,dirFile),'file')==2
                        temp_hdata=load(sprintf('%s%s',hdata.dirData,dirFile));
                        hdata=temp_hdata.hdata;
                    else
                        error('file <%s.mat> does not exist in <%s>',dirFile,hdata.dirData)
                    end
                end
            end
        end
        
        function hdata=HYSTcreate(hdata,node,expname)
            if ~ischar(expname)
                error ('provide experiment name: hdata.HYSTcreate(node,expname)')
            elseif ~strcmpi(class(node),'edu.washington.rieke.jauimodel.AuiEpochTree')
                error ('provide an aui node object: hdata.HYSTcreate(node,expname)')
            else
                results = cell(1,node.children.length);
                for i=1:node.children.length
                    results{i}=toMatlabStruct(node.children(i).custom.get('results'));
                end
                hdata.expname =expname;
                hdata.cellname = node.parent.splitValue;
                hdata.Ib = round(node.splitValue);
                hdata.tAx=results{end}.TimeAxis;
                hdata.mean = NaN(node.children.length,length(results{end}.Mean));
                hdata.sd = NaN(node.children.length,length(results{end}.Mean));
                hdata.stim = NaN(node.children.length,length(results{end}.Mean));
                hdata.n = NaN(node.children.length,1);
                for i=1:node.children.length
                    hdata.mean(i,:)=results{i}.Mean;
                    hdata.sd(i,:)=results{i}.SD;
                    hdata.stim(i,:)=results{i}.Stim;
                    hdata.n(i)=results{i}.n;
                    hdata.phase(i,:)=node.children(i).splitValue;
                end
                hdata.phase=cellstr(char(hdata.phase));
            end
        end
        
        function hdata=HYSTsave(hdata)
            hdata.dirFile=sprintf('%s_%s%s',hdata.cellname,hdata.expname,num2str(hdata.Ib));
            save(sprintf('%s%s',hdata.dirData,hdata.dirFile),'hdata')
            fprintf('Saved to %s%s\n',hdata.dirData,hdata.dirFile);
        end
        
        function hdata=HYSTload(hdata,dirFile)
            
        end
    end
    
    methods (Static=true)
    end
end