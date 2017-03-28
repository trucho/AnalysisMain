classdef ephysGUI < handle
    % Generic GUI to analyze electrophysiology data from photoreceptors
    % GUI_handle = ephysGUI (fig_number)
    % Created Oct_2016 (angueyra@nih.gov)
    properties
        figH
        params
        gObj=struct;
    end
    
    properties (SetAccess = private)
        
    end
    
    methods       
        function hGUI=ephysGUI(fign)
            if isempty(fign)
                fign=10;
            end
            figure(fign);clf;
            hGUI.figH=gcf;
            set(hGUI.figH,'WindowStyle','normal');
            set(hGUI.figH,'Position',[250 450 1111 800]);
            delete(get(hGUI.figH, 'Children')); %delete every ui object whithin figure
            set(hGUI.figH,'UserData',hGUI);
%             set(hGUI.figH,'KeyPressFcn',@hGUI.detectKey);
            
            % set the base panel for ui interactions
            hGUI.gObj.panel = uipanel('Parent', hGUI.figH, ...
                'Units', 'normalized', ...
                'UserData',[], ...
                'Position', [.0001 .0001 .9999 .9999],...
                'tag','panel');
        end
        
        
        function keyPress = detectKey(hGUI, ~, handles)
            % determine the key that was pressed
            keyPress = handles.Key;
            if strcmp(keyPress,'rightarrow')&&~isempty(hGUI.gObj.nextButton)
                hGUI.nextButtonCall;
            elseif strcmp(keyPress,'leftarrow')&&~isempty(hGUI.gObj.prevButton)
                hGUI.prevButtonCall;
            end
        end
        
        function infoTable(hGUI,tableinput)
            % Create main navigation table
            if nargin == 0
                tableinput=struct;
            end
            % if previous infoTable exist, delete it
            delete(findobj('tag','infoTable'))
            % unchangeable parameters (overwrites if different)
            tableinput.Parent=hGUI.figH;
            tableinput.Units='normalized';
            tableinput.tag='infoTable';
            tableinput=checkStructField(tableinput,'Position',[0.01, .005, 0.185, .985]);
            tableinput=checkStructField(tableinput,'FontSize',10);
            tableinput=checkStructField(tableinput,'ColumnWidth',{20,20,20});
            tableinput=checkStructField(tableinput,'ColumnName',{'a','b','c'});
            tableinput=checkStructField(tableinput,'ColumnFormat',{});
            tableinput=checkStructField(tableinput,'RowName',{'1','2','3'});
            tableinput=checkStructField(tableinput,'CellEditCallback',@hGUI.updateTable);
            tableinput=checkStructField(tableinput,'Data',false(3,3));
            tableinput=checkStructField(tableinput,'ColumnEditable',true(1,size(tableinput.Data,2)));
            tableinput=checkStructField(tableinput,'headerWidth',25);
              
            hGUI.gObj.infoTable = uitable('Parent', tableinput.Parent, ...
                'Data', tableinput.Data, ...
                'Tag','infoTable',...
                'Units', tableinput.Units, ...
                'Position', tableinput.Position, ...
                'FontSize',tableinput.FontSize,...
                'ColumnWidth',tableinput.ColumnWidth,...
                'ColumnName',tableinput.ColumnName,...
                'ColumnFormat',tableinput.ColumnFormat,...
                'RowName', tableinput.RowName,...
                'ColumnEditable', tableinput.ColumnEditable,...
                'CellEditCallback',tableinput.CellEditCallback);
            modifyUITableHeaderWidth(hGUI.gObj.infoTable,tableinput.headerWidth,'right');
        end
        
        function createPlot(hGUI,plotstruct,varargin)
            if nargin < 2
                plotstruct=struct;
                plotstruct.tag='plotMain';
            else
                plotstruct=checkStructField(plotstruct,'tag','plotMain');
            end
            % if same exists, delete it
            delete(findobj('tag',plotstruct.tag))
            % plot properties
            plotstruct.Parent=hGUI.gObj.panel;
            plotstruct=checkStructField(plotstruct,'Position',[.27 .55 .60 .43]);
            plotstruct=checkStructField(plotstruct,'FontSize',12);
            plotstruct=checkStructField(plotstruct,'XScale','linear');
            plotstruct=checkStructField(plotstruct,'YScale','linear');
            hGUI.gObj.(plotstruct.tag)=axes(plotstruct);
        end
        
        function createTable(hGUI,tableinput)
            % Create extra uitable (not infoTable)
            if nargin == 0
                tableinput=struct;
            end
            % unchangeable parameters (overwrites if different)
            tableinput.Parent=hGUI.figH;
            tableinput.Units='normalized';
            tableinput=checkStructField(tableinput,'tag','uitable0');
            tableinput=checkStructField(tableinput,'Position',[0.01, .005, 0.185, .985]);
            tableinput=checkStructField(tableinput,'FontSize',10);
            tableinput=checkStructField(tableinput,'ColumnWidth',{20,20,20});
            tableinput=checkStructField(tableinput,'ColumnName',{'a','b','c'});
            tableinput=checkStructField(tableinput,'ColumnFormat',{});
            tableinput=checkStructField(tableinput,'RowName',{'1','2','3'});
            tableinput=checkStructField(tableinput,'ColumnEditable',true(1,3));
            tableinput=checkStructField(tableinput,'CellEditCallback',@hGUI.defaultCall);
            tableinput=checkStructField(tableinput,'Data',false(3,3));
            tableinput=checkStructField(tableinput,'headerWidth',25);
            tableName=sprintf('%s',tableinput.tag);
                        
            % if same exists, delete it
            delete(findobj('tag',tableinput.tag))
            %create uitable
            hGUI.gObj.(tableName) = uitable('Parent', tableinput.Parent, ...
                'Data', tableinput.Data, ...
                'Tag',tableinput.tag,...
                'Units', tableinput.Units, ...
                'Position', tableinput.Position, ...
                'FontSize',tableinput.FontSize,...
                'ColumnWidth',tableinput.ColumnWidth,...
                'ColumnName',tableinput.ColumnName,...
                'ColumnFormat',tableinput.ColumnFormat,...
                'RowName', tableinput.RowName,...
                'ColumnEditable', tableinput.ColumnEditable,...
                'CellEditCallback',tableinput.CellEditCallback);
            modifyUITableHeaderWidth(hGUI.gObj.(tableName),tableinput.headerWidth,'right');
        end
        
        function createSlider(hGUI,sldstruct,varargin)
            if nargin < 2
                sldstruct=struct;
                sldstruct.tag='Slider';
            else
                sldstruct=checkStructField(sldstruct,'tag','Slider');
           end
           % if same exists, delete it
           delete(findobj('tag',sldstruct.tag))
           % plot properties
           sldstruct.Parent=hGUI.gObj.panel;
           sldstruct=checkStructField(sldstruct,'Min',0);
           sldstruct=checkStructField(sldstruct,'Max',1);
           sldstruct=checkStructField(sldstruct,'Value',0);
           sldstruct=checkStructField(sldstruct,'Position',[.27 .001 .48 .10]);
           sldstruct=checkStructField(sldstruct,'Callback',@hGUI.defaultCall);
           sliderName=sprintf('%s',sldstruct.tag);
           hGUI.gObj.(sliderName) = uicontrol(sldstruct.Parent,'Style','slider','Units','normalized',sldstruct);
        end
        
        function createButton(hGUI,buttonstruct)
            if nargin < 2
                buttonstruct=struct;
                buttonstruct.tag='Button';
            else
                buttonstruct=checkStructField(buttonstruct,'tag','Button');
            end
            % if same exists, delete it
            delete(findobj('tag',buttonstruct.tag))
            % button definition
            buttonstruct.Parent=hGUI.figH;
            buttonstruct=checkStructField(buttonstruct,'Callback',@hGUI.defaultCall);
            buttonstruct=checkStructField(buttonstruct,'Position',[.895 .01 0.10 .10]);
            buttonstruct=checkStructField(buttonstruct,'Style','pushbutton');
            buttonstruct=checkStructField(buttonstruct,'String',sprintf('%s',buttonstruct.tag));
            buttonstruct=checkStructField(buttonstruct,'FontSize',10);
            buttonstruct=checkStructField(buttonstruct,'UserData',[]);
            %create button
            buttonName=sprintf('%s',buttonstruct.tag);
            hGUI.gObj.(buttonName) = uicontrol(buttonstruct.Parent,'Units','normalized',buttonstruct);
        end
        
        function createDropdown(hGUI,ddownstruct)
           if nargin < 2
               ddownstruct=struct;
               ddownstruct.tag='DropDown';
           else
               ddownstruct=checkStructField(ddownstruct,'tag','DropDown');
           end
           % if same exists, delete it
           delete(findobj('tag',ddownstruct.tag))
           % button definition
           ddownstruct.Parent=hGUI.figH;
           ddownstruct=checkStructField(ddownstruct,'Callback',@hGUI.defaultMenuCall);
           ddownstruct=checkStructField(ddownstruct,'Position',[.895 .01 0.10 .10]);
           ddownstruct=checkStructField(ddownstruct,'Style','popupmenu');
           ddownstruct=checkStructField(ddownstruct,'String',{'Option0', 'Option1','Option2'});
           ddownstruct=checkStructField(ddownstruct,'FontSize',10);
           ddownstruct=checkStructField(ddownstruct,'UserData',[]);
           %create menu
           ddownName=sprintf('%s',ddownstruct.tag);
           hGUI.gObj.(ddownName) = uicontrol(ddownstruct.Parent,'Units','normalized',ddownstruct);
        end
        
        function updateTable(hGUI,~,~)
            % Override this method to update uiTable
            hGUI.disableGui;
            hGUI.enableGui;
        end
        
        function updateMenu(hGUI,~,~)
            % Override this method to update DropDown Menu
            hGUI.disableGui;
            hGUI.enableGui;
        end
        
        function refocusTable(hGUI,focusindex)
            % For very long tables, modify scrolling position
            jTable=findjobj(findobj('tag','infoTable'));
            jScrollPanel = jTable.getComponent(0);
            scrollEnd=jScrollPanel.getViewSize.height;
            jscrollNow=java.awt.Point(0,(focusindex-5)*scrollEnd/size(get(hGUI.gObj.infoTable,'RowName'),1));
            jScrollPanel.setViewPosition(jscrollNow);
        end
        
       function nowSel = defaultMenuCall(hGUI,source,~)
           % Get current selection in menu
           hGUI.disableGui;
           nowSel = hGUI.getMenuValue(source);
           hGUI.enableGui;
       end
       
       function defaultCall(hGUI,~,~)
           hGUI.disableGui;
           fprintf('Works!\n')
           hGUI.enableGui;
       end
       
       function defaultjSliderCall(~,jSlider,~)
           fprintf('Current Value = %g\n',jSlider.getValue)
       end
       
       function currIndex=getCurrIndex(hGUI,~,~)
           % Get current selection in infoTable
           if isfield(hGUI.gObj,'infoTable')
               Selected=get(hGUI.gObj.infoTable,'Data');
               currIndex=find(cell2mat(Selected(:,end)));
           end
       end
       
       function currRowName=getRowName(hGUI,~,~)
           % Get current row name in infoTable
           if isfield(hGUI.gObj,'infoTable')
               currIndex=hGUI.getCurrIndex();
               rowNames=get(hGUI.gObj.infoTable,'RowName');
               currWaveNamestart=regexp(rowNames{currIndex},')>')+2;
               currWaveNameend=regexp(rowNames{currIndex},'</font')-1;
               currRowName=rowNames{currIndex}(currWaveNamestart:currWaveNameend);
           end
       end
       
       function [nowSel,nowInd,nTotal] = getMenuValue(hGUI,source,~) %#ok<INUSL>
           % Get current selection in menu (exclude html tags for color)
           options = get(source,'String');
           nowValue = get(source,'Value');
           htmlpattern='<[^>]*>';
           nowSel = char(options(nowValue));
           nowSel = regexprep(nowSel,htmlpattern,'');
           nowInd = source.Value;
           nTotal = size(source.String,1);
       end
       
       
            
       function nextButton(hGUI,buttonstruct)
           if nargin < 2
               buttonstruct=struct;
               buttonstruct.tag='next';
           else
               buttonstruct=checkStructField(buttonstruct,'tag','next');
           end
           % if same exists, delete it
           delete(findobj('tag',buttonstruct.tag))
           % button definition
           buttonstruct.Parent=hGUI.figH;
           buttonstruct.callback=@hGUI.nextButtonCall;
           buttonstruct=checkStructField(buttonstruct,'Position',[.07 .706 .066 .06]);
           buttonstruct=checkStructField(buttonstruct,'Style','pushbutton');
%            buttonstruct=checkStructField(buttonstruct,'string','<html>&#10143</html>');
           buttonstruct=checkStructField(buttonstruct,'string','<html>&#10230</html>');
           buttonstruct=checkStructField(buttonstruct,'FontSize',12);
           buttonstruct=checkStructField(buttonstruct,'UserData',[]);
           %create button
           buttonName=sprintf('%sButton',buttonstruct.tag);
           hGUI.gObj.(buttonName) = uicontrol(buttonstruct.Parent,'Units','normalized',buttonstruct);
       end
       
       function prevButton(hGUI,buttonstruct)
           if nargin < 2
               buttonstruct=struct;
               buttonstruct.tag='prev';
           else
               buttonstruct=checkStructField(buttonstruct,'tag','prev');
           end
           % if same exists, delete it
           delete(findobj('tag',buttonstruct.tag))
           % button definition
           buttonstruct.Parent=hGUI.figH;
           buttonstruct.callback=@hGUI.prevButtonCall;
           buttonstruct=checkStructField(buttonstruct,'Position',[.004 .706 .066 .06]);
           buttonstruct=checkStructField(buttonstruct,'Style','pushbutton');
           buttonstruct=checkStructField(buttonstruct,'string','<html>&#10229</html>');
           buttonstruct=checkStructField(buttonstruct,'FontSize',12);
           buttonstruct=checkStructField(buttonstruct,'UserData',[]);
           %create button
           buttonName=sprintf('%sButton',buttonstruct.tag);
           hGUI.gObj.(buttonName) = uicontrol(buttonstruct.Parent,'Units','normalized',buttonstruct);
       end
       
       function lockButton(hGUI,buttonstruct)
           if nargin < 2
               buttonstruct=struct;
               buttonstruct.tag='lock';
           else
               buttonstruct=checkStructField(buttonstruct,'tag','lock');
           end
           % if same exists, delete it
           delete(findobj('tag',buttonstruct.tag))
           % button definition
           buttonstruct.Parent=hGUI.figH;
           buttonstruct.callback=@hGUI.lockButtonCall;
           buttonstruct=checkStructField(buttonstruct,'Position',[.005 .81 .132 .04]);
           buttonstruct=checkStructField(buttonstruct,'Style','pushbutton');
           buttonstruct=checkStructField(buttonstruct,'String','Lock&Save');
           buttonstruct=checkStructField(buttonstruct,'FontSize',10);
           buttonstruct=checkStructField(buttonstruct,'UserData',[]);
           %create button
           buttonName=sprintf('%sButton',buttonstruct.tag);
           hGUI.gObj.(buttonName) = uicontrol(buttonstruct.Parent,'Units','normalized',buttonstruct);
       end
       
       function acceptButton(hGUI,buttonstruct)
           if nargin < 2
               buttonstruct=struct;
               buttonstruct.tag='accept';
           else
               buttonstruct=checkStructField(buttonstruct,'tag','accept');
           end
           % if same exists, delete it
           delete(findobj('tag',buttonstruct.tag))
           % button definition
           buttonstruct.Parent=hGUI.figH;
           buttonstruct.callback=@hGUI.acceptButtonCall;
           buttonstruct=checkStructField(buttonstruct,'Position',[.004 .77 .132 .04]);
           buttonstruct=checkStructField(buttonstruct,'Style','pushbutton');
           buttonstruct=checkStructField(buttonstruct,'String','Accept');
           buttonstruct=checkStructField(buttonstruct,'FontSize',10);
           buttonstruct=checkStructField(buttonstruct,'UserData',[]);
           %create button
           buttonName=sprintf('%sButton',buttonstruct.tag);
           hGUI.gObj.(buttonName) = uicontrol(buttonstruct.Parent,'Units','normalized',buttonstruct);
       end
       
       function jSlider(hGUI,sliderstruct)
           if nargin < 2
               sliderstruct=struct;
               sliderstruct.tag='slider';
           else
               sliderstruct=checkStructField(sliderstruct,'tag','slider');
           end
           % if same exists, delete it
           delete(findobj('tag',sliderstruct.tag))
           % button definition
           sliderstruct.Parent=hGUI.figH;
           sliderstruct=checkStructField(sliderstruct,'Callback',@hGUI.defaultjSliderCall);
           sliderstruct=checkStructField(sliderstruct,'Position',[2 100 150 50]./1000);
           sliderstruct=checkStructField(sliderstruct,'Value',10);
           sliderstruct=checkStructField(sliderstruct,'Minimum',0);
           sliderstruct=checkStructField(sliderstruct,'Maximum',1000);
%            sliderstruct=checkStructField(sliderstruct,'MajorTickSpacing',100);
%            sliderstruct=checkStructField(sliderstruct,'MinorTickSpacing',100);
           sliderstruct=checkStructField(sliderstruct,'Paintlabels',1);
           sliderstruct=checkStructField(sliderstruct,'PaintTicks',1);
           sliderstruct=checkStructField(sliderstruct,'Orientation',0);
           sliderstruct=checkStructField(sliderstruct,'Color',[0,0,0]);
           sliderstruct=checkStructField(sliderstruct,'ToolTipText',sliderstruct.tag);
           %create slider
           jS = uicomponent ('style','slider',...
               'StateChangedCallback',sliderstruct.Callback, ...
               'Position',[20 100 150 50], ...
               'Value',sliderstruct.Value, ...
               'Minimum',sliderstruct.Minimum, ...
               'Maximum',sliderstruct.Maximum, ...
               'MajorTickSpacing',sliderstruct.Maximum/5, ...
               'MinorTickSpacing',sliderstruct.Maximum/20, ...
               'Paintlabels',sliderstruct.Paintlabels, ...
               'PaintTicks',sliderstruct.PaintTicks, ...
               'Orientation',sliderstruct.Orientation, ...
               'ToolTipText',sliderstruct.ToolTipText ...
               );
           sliderName=sprintf('%s',sliderstruct.tag);
           hGUI.gObj.(sliderName) = jS;
           hGUI.gObj.(sliderName).Tag = sliderName;
           set(hGUI.gObj.(sliderName), 'Foreground',java.awt.Color(sliderstruct.Color(1),sliderstruct.Color(2),sliderstruct.Color(3)));
           set(hGUI.gObj.(sliderName),'Units','normalized');
           set(hGUI.gObj.(sliderName),'Position',sliderstruct.Position);
       end
       
       % Callback functions
       function nextButtonCall(hGUI,~,~)
            hGUI.disableGui;
            ddOptions = get(hGUI.gObj.DropDown,'String');
            nowValue = get(hGUI.gObj.DropDown,'Value');
            if nowValue+1>size(ddOptions,1)
                nextValue=1;
            else
                nextValue=nowValue+1;
            end
            set(hGUI.gObj.DropDown,'Value',nextValue);
            hGUI.updateMenu();
            hGUI.enableGui;
       end
        
        function prevButtonCall(hGUI,~,~)
            hGUI.disableGui;
            ddOptions = get(hGUI.gObj.DropDown,'String');
            nowValue = get(hGUI.gObj.DropDown,'Value');
            if nowValue-1<1
                prevValue=size(ddOptions,1);
            else
                prevValue=nowValue-1;
            end
            set(hGUI.gObj.DropDown,'Value',prevValue);
            hGUI.updateMenu();
            hGUI.enableGui;
        end
        
        function lockButtonCall(hGUI,~,~)
            hGUI.disableGui;
            fprintf('lockButtonCall() method needs overriding\n')
            BIPBIP();
            hGUI.enableGui;
        end
        
        function acceptButtonCall(hGUI,~,~)
            hGUI.disableGui;
            fprintf('acceptButtonCall() method needs overriding\n')
            BIPBIP();
            hGUI.enableGui;
        end
        
        function replaceTableNames(hGUI, waveNames)
            Rows=size(waveNames,1);
            colors=pmkmp(Rows,'CubicL');
            tcolors=round(colors./1.2.*255);
            RowNames=cell(size(Rows));
            for i=1:Rows
                RowNames{i}=sprintf('<html><font color=rgb(%d,%d,%d)>%s</font></html>',tcolors(i,1),tcolors(i,2),tcolors(i,3),waveNames{i});
            end
            hGUI.gObj.infoTable.RowName=RowNames;
        end
        
    end
    
    methods (Static=true)
        
        function theRowName=getRowNamebyIndex(hGUI,index)
            % Get row name in infoTable by providing index
            rowNames=get(hGUI.gObj.infoTable,'RowName');
            currWaveNamestart=regexp(rowNames{index},')>')+2;
            currWaveNameend=regexp(rowNames{index},'</font')-1;
            theRowName=rowNames{index}(currWaveNamestart:currWaveNameend);
        end
        function [hX,hY]=calculateHist(wave,nbins,edgemin,edgemax)
            bins=linspace(edgemin*1.25,edgemax*1.25,nbins);
            histcurr=histc(wave,bins)';
            [hX,hY]=stairs(bins,histcurr);
            hY=hY/(length(wave));
        end
        
        function plotOverview(cellnode,plotHandle)
            cellEpT = getstartTime(cellnode);
            cellData = riekesuite.getResponseMatrix(cellnode.epochList,char(getStimStreamName(cellnode)));
            prepts = getProtocolSetting(cellnode,'prepts');
            bias = mean(cellData(:,1:prepts),2)';
            biasSD = std(cellData(:,1:prepts),0,2)';
            ebx=repmat(cellEpT,2,1);
            eby=[bias+biasSD;bias-biasSD];
            for i=1:length(ebx)
                line_handle=line(ebx(:,i),eby(:,i),'Parent',plotHandle);
                set(line_handle,'LineStyle','-','LineWidth',2,'Marker','none','Color',[0.7 0.7 1])
            end
        end
        
        function tAx = getTimeAxis(node)
           exE = node.epochList.elements(1);
           Stim = riekesuite.getStimulusVector(exE,char(getStimStreamName(node)));
           tAx = (0:length(Stim)-1)*getSamplingInterval(node);
        end
        
        function linek(lineH)
           set(lineH,'Marker','none','LineWidth',2,'Color',[0 0 0])
        end
        
        function linec(lineH,linecolor)
           set(lineH,'Marker','none','LineWidth',2,'Color',linecolor)
        end
        
        function markerc(lineH,markercolor)
           set(lineH,'Marker','o','LineStyle','none','Color',markercolor,'MarkerFaceColor',markercolor)
        end
        
        function labelx(plothandle,xlabel)
            set(get(plothandle,'XLabel'),'string',xlabel,'fontsize',12)
        end
        
        function labely(plothandle,ylabel)
            set(get(plothandle,'YLabel'),'string',ylabel,'fontsize',12)
        end
        
        function xlim(plothandle,xlim)
            set(plothandle,'xlim',xlim)
        end
        
        function ylim(plothandle,xlim)
            set(plothandle,'ylim',xlim)
        end
        
        function hidex(plothandle)
            set(plothandle,'XTickLabel',[])
        end
        
        function hidey(plothandle)
            set(plothandle,'YTickLabel',[])
        end
        
        function disableGui
            set(findobj('-property','Enable'),'Enable','off')
            % drawnow
        end
        function enableGui
            set(findobj('-property','Enable'),'Enable','on')
            % drawnow
        end
    end
end
