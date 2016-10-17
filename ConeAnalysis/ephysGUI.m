classdef ephysGUI < handle
    % Generic GUI to analyze electrophysiology data from photoreceptors
    % GUI_handle = ephysGUI (fig_number)
    % Created Oct_2016 (angueyra@nih.gov)
    properties
        figH
        params
        figData=struct;
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
            set(hGUI.figH,'KeyPressFcn',@hGUI.detectKey);
            
            % set the base panel for ui interactions
            hGUI.figData.panel = uipanel('Parent', hGUI.figH, ...
                'Units', 'normalized', ...
                'UserData',[], ...
                'Position', [.0001 .0001 .9999 .9999],...
                'tag','panel');
        end
        
        
        function keyPress = detectKey(hGUI, ~, handles)
            % determine the key that was pressed
            keyPress = handles.Key;
            if strcmp(keyPress,'rightarrow')&&~isempty(hGUI.figData.nextButton)
                hGUI.nextButtonCall;
            elseif strcmp(keyPress,'leftarrow')&&~isempty(hGUI.figData.prevButton)
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
            tableinput=checkStructField(tableinput,'ColumnEditable',true(1,3));
            tableinput=checkStructField(tableinput,'CellEditCallback',@hGUI.updateTable);
            tableinput=checkStructField(tableinput,'Data',false(3,3));
            tableinput=checkStructField(tableinput,'headerWidth',25);
              
            hGUI.figData.infoTable = uitable('Parent', tableinput.Parent, ...
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
            modifyUITableHeaderWidth(hGUI.figData.infoTable,tableinput.headerWidth,'right');
        end
        
        function createPlot(hGUI,plotstruct,varargin)
            if nargin < 2
                plotstruct=struct;
                plotstruct.tag='mainPlot';
            else
                plotstruct=checkStructField(plotstruct,'tag','mainPlot');
            end
            % if same exists, delete it
            delete(findobj('tag',plotstruct.tag))
            % plot properties
            plotstruct.Parent=hGUI.figData.panel;
            plotstruct=checkStructField(plotstruct,'Position',[.27 .55 .60 .43]);
            plotstruct=checkStructField(plotstruct,'FontSize',12);
            plotstruct=checkStructField(plotstruct,'XScale','linear');
            plotstruct=checkStructField(plotstruct,'YScale','linear');
            hGUI.figData.(plotstruct.tag)=axes(plotstruct);
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
            hGUI.figData.(tableName) = uitable('Parent', tableinput.Parent, ...
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
            modifyUITableHeaderWidth(hGUI.figData.(tableName),tableinput.headerWidth,'right');
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
           sldstruct.Parent=hGUI.figData.panel;
           sldstruct=checkStructField(sldstruct,'Min',0);
           sldstruct=checkStructField(sldstruct,'Max',1);
           sldstruct=checkStructField(sldstruct,'Value',0);
           sldstruct=checkStructField(sldstruct,'Position',[.27 .001 .48 .10]);
           sldstruct=checkStructField(sldstruct,'Callback',@hGUI.defaultCall);
           sliderName=sprintf('%s',sldstruct.tag);
           hGUI.figData.(sliderName) = uicontrol(sldstruct.Parent,'Style','slider','Units','normalized',sldstruct);
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
            hGUI.figData.(buttonName) = uicontrol(buttonstruct.Parent,'Units','normalized',buttonstruct);
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
           hGUI.figData.(ddownName) = uicontrol(ddownstruct.Parent,'Units','normalized',ddownstruct);
        end
        
        function updateTable(hGUI,~,~)
            % Override this method to update uiTable
            hGUI.disableGui;
            hGUI.enableGui;
        end
        
        function refocusTable(hGUI,focusindex)
            % For very long tables, modify scrolling position
            jTable=findjobj(findobj('tag','infoTable'));
            jScrollPanel = jTable.getComponent(0);
            scrollEnd=jScrollPanel.getViewSize.height;
            jscrollNow=java.awt.Point(0,(focusindex-5)*scrollEnd/size(get(hGUI.figData.infoTable,'RowName'),1));
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
       
       function currIndex=getCurrIndex(hGUI,~,~)
           % Get current selection in infoTable
           if isfield(hGUI.figData,'infoTable')
               Selected=get(hGUI.figData.infoTable,'Data');
               currIndex=find(cell2mat(Selected(:,end)));
           end
       end
       
       function currRowName=getRowName(hGUI,~,~)
           % Get current row name in infoTable
           if isfield(hGUI.figData,'infoTable')
               currIndex=hGUI.getCurrIndex();
               rowNames=get(hGUI.figData.infoTable,'RowName');
               currWaveNamestart=regexp(rowNames{currIndex},')>')+2;
               currWaveNameend=regexp(rowNames{currIndex},'</font')-1;
               currRowName=rowNames{currIndex}(currWaveNamestart:currWaveNameend);
           end
       end
       
       function nowSel = getMenuValue(hGUI,source,~) %#ok<INUSL>
           % Get current selection in menu (exclude html tags for color)
           options = get(source,'String');
           nowValue = get(source,'Value');
           htmlpattern='<[^>]*>';
           nowSel = char(options(nowValue));
           nowSel = regexprep(nowSel,htmlpattern,'');
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
           buttonstruct=checkStructField(buttonstruct,'Position',[.005 .705 .11 .07]);
           buttonstruct=checkStructField(buttonstruct,'Style','pushbutton');
           buttonstruct=checkStructField(buttonstruct,'string','--->');
           buttonstruct=checkStructField(buttonstruct,'FontSize',10);
           buttonstruct=checkStructField(buttonstruct,'UserData',[]);
           %create button
           buttonName=sprintf('%sButton',buttonstruct.tag);
           hGUI.figData.(buttonName) = uicontrol(buttonstruct.Parent,'Units','normalized',buttonstruct);
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
           buttonstruct=checkStructField(buttonstruct,'Position',[.005 .775 .11 .07]);
           buttonstruct=checkStructField(buttonstruct,'Style','pushbutton');
           buttonstruct=checkStructField(buttonstruct,'string','<---');
           buttonstruct=checkStructField(buttonstruct,'FontSize',10);
           buttonstruct=checkStructField(buttonstruct,'UserData',[]);
           %create button
           buttonName=sprintf('%sButton',buttonstruct.tag);
           hGUI.figData.(buttonName) = uicontrol(buttonstruct.Parent,'Units','normalized',buttonstruct);
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
           buttonstruct=checkStructField(buttonstruct,'Position',[.005 .93 .11 .07]);
           buttonstruct=checkStructField(buttonstruct,'Style','pushbutton');
           buttonstruct=checkStructField(buttonstruct,'String','Lock&Save');
           buttonstruct=checkStructField(buttonstruct,'FontSize',10);
           buttonstruct=checkStructField(buttonstruct,'UserData',[]);
           %create button
           buttonName=sprintf('%sButton',buttonstruct.tag);
           hGUI.figData.(buttonName) = uicontrol(buttonstruct.Parent,'Units','normalized',buttonstruct);
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
           buttonstruct=checkStructField(buttonstruct,'Position',[.005 .85 .11 .07]);
           buttonstruct=checkStructField(buttonstruct,'Style','pushbutton');
           buttonstruct=checkStructField(buttonstruct,'String','Accept');
           buttonstruct=checkStructField(buttonstruct,'FontSize',10);
           buttonstruct=checkStructField(buttonstruct,'UserData',[]);
           %create button
           buttonName=sprintf('%sButton',buttonstruct.tag);
           hGUI.figData.(buttonName) = uicontrol(buttonstruct.Parent,'Units','normalized',buttonstruct);
       end
       
       % Callback functions
       function nextButtonCall(hGUI,~,~)
            hGUI.disableGui;
            ddOptions = get(hGUI.figData.DropDown,'String');
            nowValue = get(hGUI.figData.DropDown,'Value');
            if nowValue+1>size(ddOptions,1)
                nextValue=1;
            else
                nextValue=nowValue+1;
            end
            set(hGUI.figData.DropDown,'Value',nextValue);
            hGUI.updateMenu();
            hGUI.enableGui;
       end
        
        function prevButtonCall(hGUI,~,~)
            hGUI.disableGui;
            ddOptions = get(hGUI.figData.DropDown,'String');
            nowValue = get(hGUI.figData.DropDown,'Value');
            if nowValue-1<1
                prevValue=size(ddOptions,1);
            else
                prevValue=nowValue-1;
            end
            set(hGUI.figData.DropDown,'Value',prevValue);
            hGUI.updateMenu();
            hGUI.enableGui;
        end
        
        function lockButtonCall(hGUI,~,~)
            hGUI.disableGui;
            fprintf('This method needs overriding\n')
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
            hGUI.figData.infoTable.RowName=RowNames;
        end
        
    end
    
    methods (Static=true)
        
        function theRowName=getRowNamebyIndex(hGUI,index)
            % Get row name in infoTable by providing index
            rowNames=get(hGUI.figData.infoTable,'RowName');
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
        
        function labelx(plothandle,xlabel)
            set(get(plothandle,'XLabel'),'string',xlabel,'fontsize',12)
        end
        
        function labely(plothandle,ylabel)
            set(get(plothandle,'YLabel'),'string',ylabel,'fontsize',12)
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
