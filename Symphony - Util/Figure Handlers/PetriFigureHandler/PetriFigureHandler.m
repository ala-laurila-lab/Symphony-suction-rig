classdef PetriFigureHandler < handle
    %LEDFIGUREHANDLER Summary of this class goes here
    %   Detailed explanation goes here
       
    properties (Hidden)
        %% The amplifier that you are using
        amp
        
        %% GUI variables
        gui
        guiObjects
        graph
        javaH
        originalWidth
        originalHeight
        
        %%The protocol
        protocolPlugin
        
        %% DONT CHANGE
        isHolding = false
        isMultiColored = false
        isPaused = false 
        
        graphsAdded = 0         % The number of graphs the user wants to see
        availableResponses      % Creating the available graphs (In the Symphony - Util\Figure Handlers\List folder)
        responseFields          % A variable that keeps the names of the graphs for easy access
        
        %Axis limits
        autoAxis
        
        % Saving graph
        canSave = false        
        graphsToSave = []
        savedGraphs = []
        
        multipleGraphsCanHold = false
        graphsToHold = []
        
        %% Variables for customisation
        
        % Do you want the grid on
        gridOn = false
        
        % Colors for the plot
        axesBackgroundColor = 'black'; % you can use [0 0 0] notation as well
        gridColor = 'white';
        BackgroundColor = [0.35 0.35 0.35];
        
        % Set autoAxisEnabled to false and set the limits if you want it
        % customised.
        autoAxisEnabled = true
        xAxisMin = 0
        xAxisMax = 0
        yAxisMin = 0
        yAxisMax = 0
    end
    
    methods
        %%Init Functions
        function obj = PetriFigureHandler( protocolPlugin , amp , varargin )
            obj.amp = amp;
            obj.protocolPlugin = protocolPlugin;
            obj.generateAvailableResponses();
            obj.showGui();
            obj.response_Callback();
        end

        % Iterating through all the m-files in the folder Symphony -
        % Util\Figure Handlers\List and initiating them
        function generateAvailableResponses(obj)
            obj.availableResponses = struct();
            responsePath = fileparts(mfilename('fullpath'));
            
            responseList = dir(fullfile(responsePath,'List'));
            responseListLength = length(responseList);
            
            if responseListLength > 2
                for d = 3:length(responseList)
                    name = responseList(d).name;
                    extension = '.m';
                    
                    if strfind(name, extension)
                        name = strrep(name, extension, '');
                        constructor = str2func(name);
                        obj.availableResponses.( name ) = constructor();
                    end
                    
                    if obj.availableResponses.( name ).canSave
                        obj.canSave = true;
                        obj.graphsToSave{end + 1} = name;
                    end
                    
                    if obj.availableResponses.( name ).multipleGraphsCanHold
                        obj.multipleGraphsCanHold = true;
                        obj.graphsToHold{end + 1} = name;
                    end                    
                end
            end
            
            obj.responseFields = fieldnames(obj.availableResponses);
        end
 
        
        %% GUI Functions
        % A function to draw the GUI
        function showGui(obj)
            dialogWidth = 1050;
            dialogHeight = 400;
            
            panelWidth = (dialogWidth*0.9)/3;
            
            checkBoxWidth = 110;
            checkBoxHeight = 15;
            
            obj.guiObjects = struct();
            
            %Construcing the GUI
            obj.gui = figure(...
                'Units', 'points', ...
                'Name', 'LED Interactive', ...
                'Menubar', 'figure', ...
                'NumberTitle', 'off', ...
                'Color', obj.BackgroundColor, ...
                'position',[dialogWidth, dialogHeight, dialogWidth, dialogHeight],...
                'Tag', 'figure', ...
                'resize', 'on', ...
                'ResizeFcn', @(hObject,eventdata)windowDidResize_Callback(obj,hObject,eventdata), ...
                'WindowKeyPressFcn', @(hObject, eventdata)setAxis_Callback(obj,hObject,eventdata), ...
                'CloseRequestFcn', '' ...
                );
            
            obj.originalWidth = dialogWidth;
            obj.originalHeight = dialogHeight;
            
            obj.graph = axes('Parent',obj.gui,'Position',[.05 .25 .9 .7], 'Color',obj.axesBackgroundColor);
            set(obj.graph, 'XColor', obj.gridColor);
            set(obj.graph, 'YColor', obj.gridColor);
            axis(obj.graph,'tight');
            
            %% Responses Column 1
            obj.guiObjects.responsePanel = uipanel(...
                'Parent', obj.gui, ...
                'Units', 'points', ...
                'FontSize', 12, ...
                'Title', 'Available Responses', ...
                'Tag', 'responsePanel', ...
                'Clipping', 'on', ...
                'Position', [55 5 panelWidth (5 *checkBoxHeight)]);
            
            checkboxYPos = 45;
            checkboxXPos = 2;
            
            % Currently the GUI only has place for six different graphs. So
            % we will take the first 6 in the list (or less if there are
            % less graphs)
            num = min(numel(obj.responseFields), 6);
            
            % Iterate through our graphs and add the checkbox for each one
            for i=1:num
                responseObject = obj.availableResponses.( obj.responseFields{i} );
                paramTag = obj.responseFields{i};
                obj.guiObjects.( paramTag ) = uicontrol(...
                    'Parent', obj.guiObjects.responsePanel, ...
                    'Units', 'points', ...
                    'FontSize', 8, ...
                    'Position', [checkboxXPos checkboxYPos checkBoxWidth checkBoxHeight], ...
                    'String', responseObject.caption, ...
                    'callback', @(hObject,eventdata)response_Callback(obj,hObject,eventdata), ...
                    'Value', responseObject.showResponse, ...
                    'Style', 'checkbox', ...
                    'Tag', obj.responseFields{i});
                
                checkboxYPos = checkboxYPos - 20;
                
                if i==3
                    checkboxXPos = 2+checkBoxWidth;
                    checkboxYPos = 45;
                end
            end
            
            %% Axis Column 2
            obj.javaH = struct();
            
            obj.guiObjects.axisPanel = uipanel(...
                'Parent', obj.gui, ...
                'Units', 'points', ...
                'FontSize', 12, ...
                'Title', 'Plot Axis', ...
                'Tag', 'axisPanel', ...
                'Clipping', 'on', ...
                'Position', [55+panelWidth 5 panelWidth (5 *checkBoxHeight)]);
            
            uicontrol(...
                'Parent', obj.guiObjects.axisPanel,...
                'Units', 'points', ...
                'FontSize', 12,...
                'Position', [2 35 checkBoxWidth checkBoxHeight], ...
                'String',  'X-Axis Min/Max',...
                'Style', 'text');
            
            uicontrol(...
                'Parent', obj.guiObjects.axisPanel,...
                'Units', 'points', ...
                'FontSize', 12,...
                'Position', [2 15 checkBoxWidth checkBoxHeight], ...
                'String',  'Y-Axis Min/Max',...
                'Style', 'text');
            
            paramTag = 'xAxisMin';
            obj.guiObjects.( paramTag ) = uicontrol(...
                'Parent', obj.guiObjects.axisPanel,...
                'Units', 'points', ...
                'FontSize', 12,...
                'HorizontalAlignment', 'left', ...
                'Position', [(checkBoxWidth+2) 35 ((checkBoxWidth - 15)/2) checkBoxHeight], ...
                'String',  num2str(obj.xAxisMin),...
                'Enable', 'off',...
                'Style', 'edit', ...
                'TooltipString', 'xAxisMin', ...
                'Tag', paramTag);
            
            paramTag = 'xAxisMax';
            obj.guiObjects.( paramTag ) = uicontrol(...
                'Parent', obj.guiObjects.axisPanel,...
                'Units', 'points', ...
                'FontSize', 12,...
                'HorizontalAlignment', 'left', ...
                'Position', [((checkBoxWidth+2)+checkBoxWidth/2) 35 ((checkBoxWidth - 15)/2) checkBoxHeight], ...
                'String',  num2str(obj.xAxisMax),...
                'Enable', 'off',...
                'Style', 'edit', ...
                'TooltipString', 'xAxisMax', ...
                'Tag', paramTag);
            
            paramTag = 'AutoAxis';
            obj.guiObjects.( paramTag ) = uicontrol(...
                'Parent', obj.guiObjects.axisPanel,...
                'Units', 'points', ...
                'Callback', @(hObject,eventdata)autoAxis_Callback(obj,hObject,eventdata), ...
                'Position', [((checkBoxWidth+2)+checkBoxWidth)+ 2 15 checkBoxWidth-35 checkBoxHeight*2+8], ...
                'String', 'Auto Axis (On)', ...
                'TooltipString', 'Auto Axis', ...
                'Tag', 'AutoAxis');
            
            paramTag = 'yAxisMin';
            obj.guiObjects.( paramTag ) = uicontrol(...
                'Parent', obj.guiObjects.axisPanel,...
                'Units', 'points', ...
                'FontSize', 12,...
                'HorizontalAlignment', 'left', ...
                'Position',[(checkBoxWidth+2) 15 ((checkBoxWidth - 15)/2) checkBoxHeight], ...
                'String',  num2str(obj.yAxisMin),...
                'Enable', 'off',...
                'Style', 'edit', ...
                'TooltipString', 'yAxisMin', ...
                'Tag', paramTag);
            
            paramTag = 'yAxisMax';
            obj.guiObjects.( paramTag ) = uicontrol(...
                'Parent', obj.guiObjects.axisPanel,...
                'Units', 'points', ...
                'FontSize', 12,...
                'HorizontalAlignment', 'left', ...
                'Position', [((checkBoxWidth+2)+checkBoxWidth/2) 15 ((checkBoxWidth - 15)/2) checkBoxHeight], ...
                'String',  num2str(obj.yAxisMax),...
                'Enable', 'off',...
                'Style', 'edit', ...
                'TooltipString', 'yAxisMax', ...
                'Tag', paramTag);
            
            %% Options Column 3
            obj.guiObjects.optionsPanel = uipanel(...
                'Parent', obj.gui, ...
                'Units', 'points', ...
                'FontSize', 12, ...
                'Title', 'Plot Options', ...
                'Tag', 'optionsPanel', ...
                'Clipping', 'on', ...
                'Position', [55+(2*panelWidth) 5 panelWidth (5 *checkBoxHeight)]);
            
            paramTag = 'OverlayResponses';
            obj.guiObjects.( paramTag ) = uicontrol(...
                'Parent', obj.guiObjects.optionsPanel, ...
                'Units', 'points', ...
                'FontSize', 8, ...
                'Position', [2 45 checkBoxWidth checkBoxHeight], ...
                'String', 'Overlay Responses', ...
                'Value', 0, ...
                'Enable', 'off', ...
                'callback', @(hObject,eventdata)overlayResponses_Callback(obj,hObject,eventdata), ...
                'Style', 'checkbox', ...
                'Tag', 'overlayResponses');
            
            paramTag = 'ShowGrid';
            obj.guiObjects.( paramTag ) = uicontrol(...
                'Parent', obj.guiObjects.optionsPanel, ...
                'Units', 'points', ...
                'FontSize', 8, ...
                'Position', [2 25 checkBoxWidth checkBoxHeight], ...
                'String', 'Show Grid', ...
                'Value', obj.gridOn, ...
                'callback', @(hObject,eventdata)showGrid_Callback(obj,hObject,eventdata), ...
                'Style', 'checkbox', ...
                'Tag', 'ShowGrid');
            
            
            paramTag = 'MultiColoredHold';
            obj.guiObjects.( paramTag ) = uicontrol(...
                'Parent', obj.guiObjects.optionsPanel, ...
                'Units', 'points', ...
                'FontSize', 8, ...
                'Position', [2 5 checkBoxWidth checkBoxHeight], ...
                'String', 'Multi Colored Hold (One Graph Only)', ...
                'Value', 0, ...
                'Enable', 'off', ...
                'callback', @(hObject,eventdata)multiColoredHold_Callback(obj,hObject,eventdata), ...
                'Style', 'checkbox', ...
                'Tag', 'MultiColoredHold');
            
            paramTag = 'PauseResponses';
            obj.guiObjects.( paramTag ) = uicontrol(...
                'Parent', obj.guiObjects.optionsPanel, ...
                'Units', 'points', ...
                'FontSize', 8, ...
                'Position', [(2+checkBoxWidth) 45 checkBoxWidth checkBoxHeight], ...
                'String', 'Pause Responses', ...
                'Value', 0, ...
                'Enable', 'on', ...
                'callback', @(hObject,eventdata)pauseResponses_Callback(obj,hObject,eventdata), ...
                'Style', 'checkbox', ...
                'Tag', 'pauseResponses');
            
            paramTag = 'SaveGraph';
            obj.guiObjects.( paramTag ) = uicontrol(...
                'Parent', obj.guiObjects.optionsPanel,...
                'Units', 'points', ...
                'Callback', @(hObject,eventdata)saveGraph_Callback(obj,hObject,eventdata), ...
                'Position', [(2+checkBoxWidth) 5 checkBoxWidth-25 25], ...
                'Enable', 'off', ...
                'String', 'Save Graph', ...
                'TooltipString', 'Save Graph', ...
                'Tag', 'SaveGraph');    
            
            paramTag = 'EraseGraph';
            obj.guiObjects.( paramTag ) = uicontrol(...
                'Parent', obj.guiObjects.optionsPanel,...
                'Units', 'points', ...
                'Callback', @(hObject,eventdata)eraseGraph_Callback(obj,hObject,eventdata), ...
                'Position', [((2*checkBoxWidth)-20) 5 checkBoxWidth 25], ...
                'String', 'Erase Graph', ...
                'TooltipString', 'Erase Graph', ...
                'Tag', 'EraseGraph');
            
            paramTag = 'EditGraph';
            obj.guiObjects.( paramTag ) = uicontrol(...
                'Parent', obj.guiObjects.optionsPanel,...
                'Units', 'points', ...
                'Callback', @(hObject,eventdata)editGraph_Callback(obj,hObject,eventdata), ...
                'Position', [((2*checkBoxWidth)-20) 35 checkBoxWidth 25], ...
                'String', 'Edit Graph', ...
                'TooltipString', 'Edit Graph', ...
                'Tag', 'EditGraph');
            
            obj.windowDidResize_Callback();
        end
        
        %This is a helper function to enable/disable all the axis text
        %boxes
        function setAxisTextEnabled( obj , state )
            set(obj.guiObjects.( 'xAxisMin' ), 'Enable', state);
            set(obj.guiObjects.( 'xAxisMax' ), 'Enable', state);
            set(obj.guiObjects.( 'yAxisMin' ), 'Enable', state);
            set(obj.guiObjects.( 'yAxisMax' ), 'Enable', state);
        end
        
        
        %% UI Control Functions
        % If you have 1 graph, and you are overlaying responses, you can
        % have each epoch a different color
        function multiColoredHold_Callback(obj,~,~)
            obj.isMultiColored = get(obj.guiObjects.MultiColoredHold, 'Value') == get(obj.guiObjects.MultiColoredHold, 'Max');
        end
        
        % Seeing what responses the user checked/unchecked and upating
        % values
        function response_Callback(obj,~,~)
            obj.graphsAdded = 0;
            obj.canSave = false;
            obj.multipleGraphsCanHold = false;
            
            for i=1:numel(obj.responseFields)
                paramTag =  obj.responseFields{i};
                responseObject = obj.availableResponses.( paramTag );
                
                responseObject.showResponse = get(obj.guiObjects.(paramTag), 'Value') == get(obj.guiObjects.(paramTag), 'Max');
                
                if responseObject.showResponse
                    obj.graphsAdded = obj.graphsAdded + 1;
                    if responseObject.canSave
                        obj.canSave = true;
                    end
                    
                    if responseObject.multipleGraphsCanHold
                        obj.multipleGraphsCanHold = true;
                    end
                end
            end
            
            if obj.graphsAdded == 1 || obj.multipleGraphsCanHold
                set(obj.guiObjects.OverlayResponses, 'Enable', 'on');
            elseif obj.graphsAdded ==0
                set(obj.guiObjects.OverlayResponses, 'Enable', 'off');
                set(obj.guiObjects.OverlayResponses, 'Value', false);
                obj.isHolding = false;
            end
            
            if (obj.graphsAdded > 1 || obj.graphsAdded == 0)
                obj.isMultiColored = false;
                set(obj.guiObjects.MultiColoredHold, 'Value', false);
                set(obj.guiObjects.MultiColoredHold, 'Enable', 'off');
            elseif obj.isHolding
                set(obj.guiObjects.MultiColoredHold, 'Enable', 'on');
            end
                        
            if obj.canSave
                set(obj.guiObjects.SaveGraph, 'Enable', 'on');
            else
                set(obj.guiObjects.SaveGraph, 'Enable', 'off');
            end
            
        end
        
        % the erase graph button
        function eraseGraph_Callback(obj,~,~)
            for g = 1:length(obj.savedGraphs)
               line = findobj('DisplayName',['save ' num2str(g)]);
               delete(line);
            end
            
            obj.savedGraphs = [];
            obj.clearFigure;
        end
        
        % This launches the plottools functionality
        function editGraph_Callback(obj,~,~)
            plotedit(obj.graph, 'on');
            plottools;
        end
        
        % If you have 1 graph, you can overlay each epochs responses
        function overlayResponses_Callback(obj,~,~)
            obj.isHolding = get(obj.guiObjects.OverlayResponses, 'Value') == get(obj.guiObjects.OverlayResponses, 'Max');
            
            if obj.graphsAdded > 1 || ~obj.isHolding
                obj.isMultiColored = false;
                set(obj.guiObjects.MultiColoredHold, 'Value', false);
                set(obj.guiObjects.MultiColoredHold, 'Enable', 'off');
            elseif obj.isHolding
                set(obj.guiObjects.MultiColoredHold, 'Enable', 'on');
            end
        end
        
        function saveGraph_Callback(obj,~,~)
            for g = 1:length(obj.graphsToSave)
                responseObject = obj.availableResponses.( char(obj.graphsToSave(g)) );
                obj.savedGraphs{end + 1} = responseObject.lastPlot;
            end
        end
        
        % To pause the pgraphing (ie. to stop graphing and hold the currently drawn figure)
        function pauseResponses_Callback(obj,~,~)
            obj.isPaused = get(obj.guiObjects.PauseResponses, 'Value') == get(obj.guiObjects.PauseResponses, 'Max');
        end
  
        %To show the grid in the plot, both verticle and horizontal
        function showGrid_Callback(obj,~,~)
            obj.gridOn = get(obj.guiObjects.ShowGrid, 'Value') == get(obj.guiObjects.ShowGrid, 'Max');
            
            if obj.gridOn == 1
                set(obj.graph,'XGrid','on')
                set(obj.graph,'YGrid','on')
            else
                set(obj.graph,'XGrid','off')
                set(obj.graph,'YGrid','off')
            end
        end
 
        % A function to redraw the control panel if the user resizes the
        % window
        function windowDidResize_Callback(obj,~,~)
            figPos = get(obj.gui, 'Position');
            plotPos = get(obj.graph, 'Position');
            
            figWidth = ceil(figPos(3));
            figHeight = ceil(figPos(4));
            
            plotWidthPerc = plotPos(3);
            plotHeighPerc = plotPos(4);
            
            plotHeightTop = plotPos(1);
            
            panelWidth = (figWidth*plotWidthPerc)/3;
            
            try
                responsePanel = get(obj.guiObjects.responsePanel, 'Position');
                responsePanel(2) = ((1-(plotHeighPerc+plotHeightTop)) * figHeight) - 100;
                responsePanel(3) = panelWidth;
                set(obj.guiObjects.responsePanel, 'Position', responsePanel);
            catch
            end
            try
                axisPanel = get(obj.guiObjects.axisPanel, 'Position');
                axisPanel(1) = 55 + panelWidth;
                axisPanel(2) = ((1-(plotHeighPerc+plotHeightTop)) * figHeight) - 100;
                axisPanel(3) = panelWidth;
                set(obj.guiObjects.axisPanel, 'Position', axisPanel);
            catch
            end
            try
                optionsPanel	= get(obj.guiObjects.optionsPanel, 'Position');
                optionsPanel(1) = 55 + 2*panelWidth;
                optionsPanel(2) = ((1-(plotHeighPerc+plotHeightTop)) * figHeight) - 100;
                optionsPanel(3) = panelWidth;
                set(obj.guiObjects.optionsPanel, 'Position', optionsPanel);
            catch
            end
        end
        
        % A function that is called when the axis button is clicked to
        % determin weather to use automatic axis or user defined
        function autoAxis_Callback(obj,~,~)
            if obj.autoAxisEnabled
                obj.autoAxisEnabled = false;
                set(obj.guiObjects.( 'AutoAxis' ), 'String', 'Auto Axis (Off)');
                obj.setAxisTextEnabled('on');
                axis(obj.graph,'manual');
            else
                obj.autoAxisEnabled = true;
                set(obj.guiObjects.( 'AutoAxis' ), 'String', 'Auto Axis (On)');
                obj.setAxisTextEnabled('off');
                axis(obj.graph,'tight');
            end
            
            obj.setAxis;
        end
        
       function setAxis_Callback( obj , ~ , eventdata )
            if strcmp(eventdata.Key, 'return')
                pause(0.01);
                obj.setAxis;
            end
       end
       
       %% Utility Functions     
       % This resets the figure (clears all drawn graphs) but retains the
       % background color and axis if they are in view.
       function setAxis(obj)
           try
               if obj.autoAxisEnabled
                   obj.autoAxis = axis(obj.graph);
                   obj.xAxisMin = obj.autoAxis(1);
                   obj.xAxisMax = obj.autoAxis(2);
                   obj.yAxisMin = obj.autoAxis(3);
                   obj.yAxisMax = obj.autoAxis(4);
               else
                   obj.xAxisMin = str2num(get(obj.guiObjects.( 'xAxisMin' ), 'String')); %#ok<ST2NM>
                   obj.xAxisMax = str2num(get(obj.guiObjects.( 'xAxisMax' ), 'String')); %#ok<ST2NM>
                   obj.yAxisMin = str2num(get(obj.guiObjects.( 'yAxisMin' ), 'String')); %#ok<ST2NM>
                   obj.yAxisMax = str2num(get(obj.guiObjects.( 'yAxisMax' ), 'String')); %#ok<ST2NM>
                   
               end
               
               set(obj.guiObjects.( 'xAxisMin' ), 'String', obj.xAxisMin);
               set(obj.guiObjects.( 'xAxisMax' ), 'String', obj.xAxisMax);
               set(obj.guiObjects.( 'yAxisMin' ), 'String', obj.yAxisMin);
               set(obj.guiObjects.( 'yAxisMax' ), 'String', obj.yAxisMax);
               axis(obj.graph, [obj.xAxisMin,obj.xAxisMax,obj.yAxisMin,obj.yAxisMax]);
           catch
               % There maybe an error with the Java callback, Lets do
               % nothing, leave the values as they were
           end
       end
       
        function removeResponses(obj, newRun)
            for i=1:numel(obj.responseFields)
                paramTag =  obj.responseFields{i};
                responseObject = obj.availableResponses.( paramTag );
                try
                    if (obj.graphsAdded > 1 && (~obj.isHolding || ~responseObject.multipleGraphsCanHold)) || ...
                           ~obj.isHolding &&  obj.graphsAdded == 1 || newRun
                        line = findobj('DisplayName',paramTag);
                        delete(line);                        
                    end
                catch
                end
            end
        end
        
       function clearFigure(obj)
            obj.removeResponses(true);
            
            for i=1:numel(obj.responseFields)
                paramTag =  obj.responseFields{i};
                responseObject = obj.availableResponses.( paramTag );
                responseObject.clearFigure();
            end
                        
            obj.checkingForGrid;
            obj.addSavedGraphs;
       end
       
       function addSavedGraphs(obj)
           hold(obj.graph, 'all');
           for g = 1:length(obj.savedGraphs)
               name = ['save ' num2str(g)];
               
               if isempty(findobj('DisplayName',name))
                   lastPlot = obj.savedGraphs{g};
                   plot(obj.graph,lastPlot.XData,lastPlot.YData,'DisplayName',name);
                   set(obj.graph,'Color',obj.axesBackgroundColor);
                   set(obj.graph, 'XColor', obj.gridColor);
                   set(obj.graph, 'YColor', obj.gridColor);
                   axis(obj.graph,'tight') ;
                   obj.setAxis;
                   drawnow;
               end
           end
           hold(obj.graph, 'off');
       end
       
       function close(obj)
           delete(obj.gui);
           delete(obj);
       end
       
        function run(obj)
            if ~obj.autoAxisEnabled
                obj.setAxisTextEnabled('off');
            end
            
            if obj.canSave
                set(obj.guiObjects.SaveGraph, 'Enable', 'off');
            end
        end
        
        function completeRun(obj)
            if ~obj.autoAxisEnabled
                obj.setAxisTextEnabled('on');
            end
            
            if obj.canSave
                set(obj.guiObjects.SaveGraph, 'Enable', 'on');
            end
        end
        
        function holdState = getHoldState(obj)
            if obj.isHolding && obj.isMultiColored || obj.graphsAdded > 1
                holdState = 'all';
            else
                holdState = 'on';
            end
        end
        
        %% Graphing Functions
        function checkingForGrid(obj)
            if obj.gridOn
                set(obj.graph,'XGrid','on')
                set(obj.graph,'YGrid','on')
                set(obj.graph, 'XColor', obj.gridColor);
                set(obj.graph, 'YColor', obj.gridColor);
            end
            
        end
        
        % This is called by petri protocol passing the necessary
        % information for plotting the data
        function handleEpoch(obj, epoch)
            obj.removeResponses(false);
            graphResponses( obj , epoch );
        end
        
        
        % The function that draws the responses returned from th eselect
        % responses
        function graphResponses(obj, epoch)
            if obj.graphsAdded > 0 && ~obj.isPaused
                obj.checkingForGrid;
                
                for i=1:numel(obj.responseFields)
                    paramTag =  obj.responseFields{i};
                    responseObject = obj.availableResponses.( paramTag );
                    
                    if responseObject.showResponse
                        [XData , YData] = responseObject.response(obj.protocolPlugin, epoch , obj.amp );
                        
                        
                        if ~isempty(XData) || ~isempty(YData)
                            hold(obj.graph, obj.getHoldState);
                            if obj.graphsAdded > 1
                                plot(obj.graph,XData,YData,'Color',responseObject.lineColor,'DisplayName',paramTag);
                            else
                                plot(obj.graph,XData,YData,'DisplayName',paramTag);
                            end
                            set(obj.graph,'Color',obj.axesBackgroundColor);
                            set(obj.graph, 'XColor', obj.gridColor);
                            set(obj.graph, 'YColor', obj.gridColor);
                            axis(obj.graph,'tight') ;
                            obj.setAxis;
                            drawnow;
                        end
                        hold(obj.graph, 'off');
                    end
                    
                    for g = 1:length(obj.savedGraphs)
                        name = ['save ' num2str(g)];
                        line = findobj('DisplayName',name);
                        uistack(line, 'top');
                    end
                end
            end
        end
    end
    
end

