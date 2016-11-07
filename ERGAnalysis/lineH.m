classdef lineH < handle
    %lH=lineH(x,y,figH) 
    %   creates line handle object
    %   use lH.markers to use default filled circles
    %   use lH.line to use remove markers and use line
    
    properties
        h
        Parent
    end
    
    methods
        function lh = lineH (XData,YData,figH)
            if isempty(XData)
                XData = 0:length(YData)-1;
            end
            lh.Parent=figH;
            lh.h = line(XData,YData,'Parent',lh.Parent);
            lh.markers();
        end
        
        function lh = markers(lh)
            set(lh.h,...
                'LineStyle','none',...
                'Marker','o',...
                'Color',[0 0.4470 0.7410],...
                'MarkerFaceColor',[0 0.4470 0.7410]...
                );  
        end
        
        function lh = line(lh)
            set(lh.h,...
                'LineStyle','-',...
                'LineWidth',1,...
                'Marker','none',...
                'Color',[0 0.4470 0.7410],...
                'MarkerFaceColor',[0 0.4470 0.7410]...
                );  
        end
        
        function lh = linek(lh)
            set(lh.h,...
                'LineStyle','-',...
                'LineWidth',1,...
                'Marker','none',...
                'Color',[0 0 0],...
                'MarkerFaceColor',[0 0 0]...
                );  
        end
        
        function lh = liner(lh)
            set(lh.h,...
                'LineStyle','-',...
                'LineWidth',1,...
                'Marker','none',...
                'Color',[.75 0 0],...
                'MarkerFaceColor',[0 0 0]...
                );  
        end
        
        function lh = lineb(lh)
            set(lh.h,...
                'LineStyle','-',...
                'LineWidth',1,...
                'Marker','none',...
                'Color',[0 0 .75],...
                'MarkerFaceColor',[0 0 0]...
                );  
        end
        
        function lh = linemarkers(lh)
            set(lh.h,...
                'LineStyle','-',...
                'LineWidth',1,...
                'Marker','o',...
                'Color',[0 0.4470 0.7410],...
                'MarkerFaceColor',[0 0.4470 0.7410]...
                );  
        end
        
        function lh = color(lh,colors)
            set(lh.h,'Color',colors,'MarkerFaceColor',colors);  
        end
        
        function lh = marker(lh,mstyle)
            set(lh.h,'Marker',mstyle);  
        end
        
        function lh = markercolormap(lh,varargin)
            % from http://undocumentedmatlab.com/blog/plot-markers-transparency-and-color-gradient
            if nargin==1
                cmap=pmkmp(length(lh.h.XData),'CubicL');
            else
                cmap=varargin{1};
            end
            cmap=[cmap ones(size(cmap,1),1)]';
            mhandles = lh.h.MarkerHandle;
            set(mhandles,'FaceColorBinding','interpolated',...
                'FaceColorData',uint8(cmap*255),...
                'EdgeColorBinding','interpolated',...
                'EdgeColorData',uint8(cmap*255));  
        end
        
        function lh = setName(lh,name)
            if ~ischar(name)
                error('no name provided as string')
            end
            set(lh.h,'DisplayName',name,'tag',name)
        end
    end
    methods (Static = true)
        function eh=errorfill(XData,YData,YError,fillColor,figH)
            if isempty(XData)
                XData = 0:length(YData)-1;
            end
            if isempty(fillColor)
                fillColor = [.5 .75 .75];
            end
            if length(YData)>1000
               XData = decimate(XData,10);
               YData = decimate(YData,10);
               YError = decimate(YError,10);
            end
            eh.Parent=figH;
            XFill = [XData fliplr(XData)];
            YFill = [YData+YError fliplr(YData-YError)];
            eh.h = patch(XFill,YFill,fillColor,'Parent',eh.Parent);
            eh.h.FaceAlpha = 1;
            eh.h.LineStyle = 'none';
            uistack(eh.h,'down');
        end
    end
end

