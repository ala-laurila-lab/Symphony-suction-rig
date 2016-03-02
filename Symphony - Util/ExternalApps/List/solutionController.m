classdef (Sealed) solutionController < ExternalApps
    %% 
    properties (SetAccess = private, GetAccess = public)
        %the connection object
        port
        conn
        portList
        
        %channel identifiers
        channels
        
        recordStatus
    end
        
    properties (Hidden)
        %the connection object
        portValue
        BytesAvailable
        t
        
        %channel identifiers
        channelCode
    end
   
    properties (SetObservable, GetObservable, AbortSet, SetAccess = private, GetAccess = public)
        appStatus = '';     
        readControl = '';
    end

    %% Main Methods
    methods          
        function ed = solutionController( varargin )
            ed = ed@ExternalApps();
            
            narginchk(0,1);
            ed.channels = 5;
            
            parameters = varargin{1};
            
            [~,y] = size(parameters);
            
            for v = 1:(y)
                input = parameters{v};
                
                if iscell(input)
                    if strcmp(input{1},'port') && isnumeric(input{2})
                        ed.port = ['COM' int2str(input{2})];
                    elseif strcmp(input{1},'channels') && isnumeric(input{2}) && input{2} < 53
                        ed.channels = input{2};
                    end
                end
            end
            
            serialInfo = instrhwinfo('serial');
            ed.portList = serialInfo.AvailableSerialPorts;
            
            ed.portValue = 1;
            if ~isempty(ed.port)
                for pv = 1:length(ed.portList)
                    if(ed.port == ed.portList{pv})
                        ed.portValue = pv;
                    end
                end
            end
            
            ed.recordStatus = 0;
            ed.initTimer;
            ed.calcChannelCodes();
            ed.showGui();
            ed.addCustomAppListener('readControl' , 'update' ,'PostSet');
        end
                
        function showGui(ed)
            % Dimensions of the GUI
            smallPanelWidth = 75;
            panelWidth = 150;
            %dialogWidth = 4 * panelWidth;
            dialogWidth = panelWidth + 3 * smallPanelWidth;
            dialogHeight = ed.channels * 35;
            
            %Variables Used for placing objects on the GUI
            fLI = 5;
            sLI = 75;
            FontSize = 9;
            HeadingFontSize = 10;
            objectHeight = 30;
            objectWidth = 65;            
            
             %Construcing the GUI
            ed.gui = figure(...
                'Units', 'points', ...
                'Name', 'Solution Controller', ...
                'Menubar', 'none', ...
                'NumberTitle', 'off', ...
                'position',[dialogWidth, dialogHeight, dialogWidth, dialogHeight],...
                'CloseRequestFcn', @(hObject,eventdata)closeRequestFcn(ed,hObject,eventdata), ...
                'Tag', 'figure', ...
                'Resize','on' ...
            );

            ed.color = get(ed.gui, 'Color');
            
            % The Settings Panel
            panelParamTag = 'Settings';
            ed.guiObjects.(panelParamTag) = uipanel(...
                'Parent', ed.gui, ...
                'Units', 'points', ...
                'FontSize', HeadingFontSize, ...
                'Title', panelParamTag, ...
                'Tag', panelParamTag, ...
                'Position', [0 0 smallPanelWidth dialogHeight] ...
            );
                                    
            paramTag = 'PortsLabel'; 
            ed.guiObjects.(paramTag) = uicontrol(...
                 'Parent', ed.guiObjects.(panelParamTag), ...
                 'Style', 'text', ...
                 'String', 'Select Port:', ...
                 'Units', 'points', ...
                 'Position', [fLI (dialogHeight - 48) objectWidth objectHeight], ...
                 'FontSize', FontSize, ...
                 'Tag', paramTag);

            paramTag = 'Ports'; 
            ed.guiObjects.(paramTag) = uicontrol(...
                'Parent', ed.guiObjects.(panelParamTag), ...
                'Units', 'points', ...
                'Position', [fLI (dialogHeight - 70) objectWidth-5 objectHeight], ...
                'String', ed.portList, ...
                'Style', 'popupmenu', ...
                'Value', ed.portValue, ...
                'Enable', 'On', ...
                'Tag', paramTag);

            paramTag = 'Connect'; 
            ed.guiObjects.(paramTag) = uicontrol(...
                'Parent', ed.guiObjects.(panelParamTag), ...
                'Units', 'points', ...
                'Enable', 'On', ...
                'Callback', @(hObject,eventdata)connect(ed,hObject,eventdata), ...
                'Position', [fLI (dialogHeight - 135) objectWidth objectHeight], ...
                'String', paramTag, ...
                'Tag', paramTag);

            paramTag = 'Disconnect'; 
            ed.guiObjects.(paramTag) = uicontrol(...
                'Parent', ed.guiObjects.(panelParamTag), ...
                'Units', 'points', ...
                'Enable', 'Off', ...
                'Callback',  @(hObject,eventdata)disconnect(ed,hObject,eventdata), ...
                'Position', [fLI (dialogHeight - 170) objectWidth objectHeight], ...
                'String', paramTag, ...
                'Tag', paramTag);

            % The Panel to control the valves
            panelParamTag = 'ValveControl';
            ed.guiObjects.(panelParamTag) = uipanel(...
                'Parent', ed.gui, ...
                'Units', 'points', ...
                'FontSize', HeadingFontSize, ...
                'Title', panelParamTag, ...
                'Tag', panelParamTag, ...
                'Position', [smallPanelWidth 0 panelWidth dialogHeight] ...
            );

            for v = 1:ed.channels

                sPanelParamTag = ['valve' ed.channelCode(v)];
                ed.guiObjects.(sPanelParamTag) = uipanel(...
                    'Parent', ed.guiObjects.(panelParamTag), ...
                    'Units', 'points', ...
                    'FontSize', FontSize, ...
                    'Title', v, ...
                    'Tag', sPanelParamTag, ...
                    'Position', [1 ((dialogHeight - 15) - ((v) * (((dialogHeight - 15)/ed.channels)))) 145 (dialogHeight/ed.channels)] ...
                );

                paramTag = ['Open' ed.channelCode(v)];
                ed.guiObjects.(paramTag) = uicontrol(...
                    'Parent', ed.guiObjects.(sPanelParamTag), ...
                    'Units', 'points', ...
                    'Enable', 'Off', ...
                    'Position', [fLI 3 objectWidth 20], ...
                    'Callback',   @(hObject,eventdata)openClose(ed, hObject,eventdata,v, 1), ...
                    'String', 'Open', ...
                    'Tag', paramTag);

                paramTag = ['Close' ed.channelCode(v)];
                ed.guiObjects.(paramTag) = uicontrol(...
                    'Parent', ed.guiObjects.(sPanelParamTag), ...
                    'Units', 'points', ...
                    'Enable', 'Off', ...
                    'Position', [sLI 3 objectWidth 20], ...
                    'Callback',  @(hObject,eventdata)openClose(ed, hObject,eventdata,v, 0), ...
                    'String', 'Close', ...
                    'Tag', paramTag);       
            end
            
            % The Panel Display the Valve Status
            panelParamTag = 'ValveStatus';
            ed.guiObjects.(panelParamTag) = uipanel(...
                'Parent', ed.gui, ...
                'Units', 'points', ...
                'FontSize', HeadingFontSize, ...
                'Title', panelParamTag, ...
                'Tag', panelParamTag, ...
                'Position', [(smallPanelWidth + panelWidth) 0 smallPanelWidth dialogHeight] ...
            );

            for v = 1:ed.channels
                sPanelParamTag = [panelParamTag ed.channelCode(v)];
                ed.guiObjects.(sPanelParamTag) = uipanel(...
                    'Parent', ed.guiObjects.(panelParamTag), ...
                    'Units', 'points', ...
                    'FontSize', FontSize, ...
                    'Tag', sPanelParamTag, ...
                    'Position', [1 ((dialogHeight - 15) - ((v) * (((dialogHeight - 15)/ed.channels)))) smallPanelWidth-5 ((dialogHeight/ed.channels) - 6)] ...
                );
            end
            
            % The Panel Display the Valve Status
            panelParamTag = 'ValveControl';
            ed.guiObjects.(panelParamTag) = uipanel(...
                'Parent', ed.gui, ...
                'Units', 'points', ...
                'FontSize', HeadingFontSize, ...
                'Title', panelParamTag, ...
                'Tag', panelParamTag, ...
                'Position', [(2*smallPanelWidth + panelWidth) 0 smallPanelWidth dialogHeight] ...
            );
 
            for v = 1:ed.channels
                sPanelParamTag = [panelParamTag ed.channelCode(v)];
                ed.guiObjects.(sPanelParamTag) = uipanel(...
                    'Parent', ed.guiObjects.(panelParamTag), ...
                    'Units', 'points', ...
                    'FontSize', FontSize, ...
                    'Tag', sPanelParamTag, ...
                    'Position', [1 ((dialogHeight - 15) - ((v) * (((dialogHeight - 15)/ed.channels)))) smallPanelWidth - 5 ((dialogHeight/ed.channels) - 6)] ...
                );
 
                paramTag = ['PortsLabel' ed.channelCode(v)]; 
                ed.guiObjects.(paramTag) = uicontrol(...
                 'Parent', ed.guiObjects.(sPanelParamTag), ...
                 'Style', 'text', ...
                 'String', '', ...
                 'Units', 'points', ...
                 'Position', [5 (FontSize - 6) smallPanelWidth - 25 objectHeight/2], ...
                 'FontSize', FontSize, ...
                 'Tag', paramTag);
                
            end
           
        end
    end
    
    %% Helper Functions
    methods
        function calcChannelCodes(ed)
            upperCaseStart = 65;
            alphabetLength = 26;
            lowerCaseStart = 97;

            for v = 1:ed.channels
                if v < (alphabetLength + 1)
                    indexnum = v - 1;
                    number = upperCaseStart;
                else
                    indexnum = v - 1 - alphabetLength;
                    number = lowerCaseStart;
                end

                ed.channelCode(v) = char(number + indexnum);
            end            
        end
    end
    
    %% GUI Functions
    methods
        function closeRequestFcn(ed, ~, ~)
            closeApp(ed);
        end
        
        % The GUI is deleted in the External App Class.
        function closeApp(ed)
            closeApp@ExternalApps(ed);
            
            if ~isempty(ed.conn)
                fclose(ed.conn);
                delete(ed.conn);
            end
           
           ed.stopTimer();
           
           delete(ed.t);
           delete(ed);
        end
        
        function openClose(ed, ~ , ~ , v, s)
            msg = ['V,' int2str(v) ',' int2str(s)];
            ed.send(msg);
            ed.appStatus = ed.status('S');
        end
        
        function update(ed)
            if(~isempty(ed.appStatus))
                status = textscan(ed.appStatus, '%s', 'delimiter', sprintf(','));
            end
            
            if(~isempty(ed.readControl))
                statusRC = textscan(ed.readControl, '%s', 'delimiter', sprintf(','));
            end
            
            if(~isempty(ed.readControl) && ~isempty(ed.appStatus))
                for v = 1:ed.channels  
                   ed.changeValveStatus(v, str2double(status{1}{v+1}), str2double(statusRC{1}{v+1}));
                end
                ed.recordStatus = 1;
            end
        end
                
        % A function to change the status of the valve in the GUI
        function changeValveStatus(ed, valve, status, control)
            name = ed.channelCode(valve);

            onBtn = '';
            offBtn = '';  
                    
            % status values:
            % 0 = Off
            % 1 = On
            % 2 = Overloaded
            % 3 = Disconnecting From the App. (ie. No Color Marker)
            
            switch status
                case 0
                    c = [1 0 0];
                    onBtn = 'On';
                    offBtn = 'Off';        
                case 1
                    onBtn = 'Off';
                    offBtn = 'On';
                    c = [0 1 0];
                case 2
                    %To Do
                case 3
                    c = ed.color;
                    onBtn = 'Off';
                    offBtn = 'Off';      
                    app = '';
            end
            
 
            % status values:
            % 0 = Front panel switch
            % 1 = On
            % 2 = Remote switch
            
            if status ~= 3
                switch control
                    case 0
                        onBtn = 'Off';
                        offBtn = 'Off';            
                        app = 'Remote';
                    case 1
                        app = 'Computer';
                    case 2
                        onBtn = 'Off';
                        offBtn = 'Off';      
                        app = 'Remote';
                end     
            end
            
            if ~isempty(onBtn)
                label = ['Open' name];
                set(ed.guiObjects.(label), 'Enable', onBtn);
            end
            
            if ~isempty(offBtn)
                label = ['Close' name];
                set(ed.guiObjects.(label), 'Enable', offBtn);
            end
            
            label = ['PortsLabel' name];
            set(ed.guiObjects.(label), 'String', app);          
            
            label = ['ValveStatus' name];
            set(ed.guiObjects.(label), 'BackgroundColor', c); 
        end     
        
    end
    %% Serial Port Methods
    methods    
       function send(ed, msg)
           fprintf(ed.conn,msg);
       end
       
       function flush(ed)
           if ed.conn.BytesAvailable > 0
            fread(ed.conn, ed.conn.BytesAvailable)
           end
       end
       
       function status = status(ed, msg) 
            pause(0.03);
            ed.send(msg); 
            status = fscanf(ed.conn);
        end
        
        function disconnect( varargin )
            narginchk(1,3);
            ed =  varargin{1};

            ed.appStatus = ed.status('S');

            ed.stopTimer;
            fclose(ed.conn);

            set(ed.guiObjects.Disconnect, 'Enable', 'Off');
            set(ed.guiObjects.Connect, 'Enable', 'On');    
            set(ed.guiObjects.Ports, 'Enable', 'On');       

            for v = 1:ed.channels
                ed.changeValveStatus(v, 3, 3);
            end
        end
        
        function appStatus = getAppStatus( ed )
            ed.recordStatus = 0;
            appStatus = ed.appStatus;
        end
        
        function valveStatus( ed , ~ , ~ )
            try
                if strcmp(ed.conn.Status, 'open') && strcmp(ed.t.Running, 'on')
                    ed.appStatus = ed.status('S');
                    ed.readControl = ed.status('C');
                end
            catch %#ok<CTCH>
            end
        end
        
        %% Timer Functions
        function initTimer(ed)
            ed.t = timer;
            ed.t.Name = 'SolutionControllerTimer';
            ed.t.TimerFcn = {@ed.valveStatus};
            ed.t.Period = 0.02;
            ed.t.ExecutionMode = 'fixedSpacing';
            ed.t.Tag = 'SolutionControllerPolling';
        end    
                    
        function startTimer(ed)
            if(strcmp(ed.t.Running, 'off'))
                start(ed.t);
            end
        end

        
        function stopTimer(ed)
            if(strcmp(ed.t.Running, 'on'))
                stop(ed.t);
            end
        end
        
        function connect( varargin )
            narginchk(1,3);
            ed =  varargin{1};
            ed.portValue = get(ed.guiObjects.Ports,'Value');
            ed.port = ed.portList{ed.portValue};

            ed.conn = serial(ed.port);

            ed.conn.BaudRate = 57600;
            ed.conn.ReadAsyncMode = 'continuous';
            ed.conn.Terminator = 'LF/CR';

            fopen(ed.conn);

            set(ed.guiObjects.Disconnect, 'Enable', 'On');
            set(ed.guiObjects.Connect, 'Enable', 'Off');
            set(ed.guiObjects.Ports, 'Enable', 'Off');
            
            ed.appStatus = '';
            ed.readControl = '';
            ed.startTimer;
        end 
    end
end

