classdef (Sealed) notesFile < handle
    properties
        gui
        guiObjects
    end
    
    properties (SetAccess = private, GetAccess = public)
        currentFileName
        continueLogging = 1
    end
    
    properties (SetAccess = private, GetAccess = private)
        dateStamp
        saveTimer
        userDir
        newFileCount = 0
        newFileCode
        folders
        fileNames
        % timerInterval = 60;
        rigConfig = 'No Rig Configuration'
        
    end
    
    properties (Constant)
        timeString = 'HH:MM:SS';
        dateString = 'mm_dd_yy';
    end
    
    
    %% Main Method
    methods
        %%
        %   The objects instantiating method
        %
        %   @param varagin:
        %       - It accepts the RigConfiguration object in the form {'rigConfig', rigConfig}
        %%
        function nf = notesFile( varargin )
            narginchk(0,1);
            
            if ~isempty(varargin)
                parameters = varargin{1};
                [~,y] = size(parameters);
                for v = 1:(y)
                    input = parameters{v};
                    if iscell(input)
                        if strcmp(input{1},'rigConfig')
                            nf.rigConfig = input{2};
                        end
                    end
                end
            end
            
            nf.userDir = regexprep(userpath, ';', '');
            
            nf.folders = struct();
            nf.folders.main = fullfile(nf.userDir, 'Symphony - Util\Notes Files');            
            nf.folders.hidden = fullfile(nf.userDir, 'Symphony - Util\.Hidden Notes Files'); 
            nf.folders.headers = fullfile(nf.userDir, 'Symphony - Util\Header Files'); 
            
            nf.dateStamp = datestr(now, nf.dateString);
                        
            nf.showGui;
%             nf.initTimer;
%             nf.startTimer;
        end   
        
        %%
        %   A function create the GUI
        %%
        function showGui(nf)
            %Construcing the GUI
            
            dialogWidth = 600;
            dialogHeight = 700;
            
            nf.gui = figure(...
                'Units', 'points', ...
                'Name', 'Notes File: ', ...
                'Menubar', 'none', ...
                'NumberTitle', 'off', ...
                'Tag', 'figure', ...
                'position',[364, 100, dialogWidth, dialogHeight],...
                'CloseRequestFcn', @(hObject,eventdata)closeRequestFcn(nf,hObject,eventdata), ...
                'ResizeFcn', @(hObject,eventdata)windowDidResize_Callback(nf,hObject,eventdata), ...
                'Resize','on' ...
                );
            
            nf.guiObjects = struct();
            
            nf.guiObjects.textArea = uicontrol(...
                'Parent',nf.gui,...
                'BackgroundColor',[1 1 1],...
                'FontSize', 8,...
                'Units','points',...
                'Enable','off',...
                'HorizontalAlignment','left',...
                'Max',1000,...
                'Position',[0 0 dialogWidth dialogHeight],...
                'Min',1,...
                'Style','edit',...
                'Tag','textArea'...
                );
            
            nf.guiObjects.menu = nf.createMenu;
            % nf.openExistingFile;
            nf.initNew;
            nf.windowDidResize_Callback();
        end
        
        %%
        %   A function to create the menu system for the GUI
        %%       
        function menu = createMenu(nf)
            menu = struct();
            menu.file = struct();
            menu.edit = struct();
            menu.comments = struct();
            
            menu.file.parent = uimenu(nf.gui,'Label','File');
            menu.file.continueLoggingMenu = uimenu(menu.file.parent,'Label','Pause');
            menu.file.loggingOn = uimenu(menu.file.continueLoggingMenu,'Label','Start Logging','Enable','off','Callback',@(hObject,eventdata)pauseLoggingFcn(nf,hObject,eventdata,1));
            menu.file.loggingOff = uimenu(menu.file.continueLoggingMenu,'Label','Stop Logging','Enable','on','Callback',@(hObject,eventdata)pauseLoggingFcn(nf,hObject,eventdata,0));
            
            menu.file.new = uimenu(menu.file.parent,'Label','New','Accelerator','n','Callback',@(hObject,eventdata)newFcn(nf,hObject,eventdata , ''));
            menu.file.open = uimenu(menu.file.parent,'Label','Open','Accelerator','o','Callback',@(hObject,eventdata)openFcn(nf,hObject,eventdata));
            menu.file.save = uimenu(menu.file.parent,'Label','Save','Accelerator','s','Callback',@(hObject,eventdata)saveFcn(nf,hObject,eventdata));
                       
            menu.edit.parent = uimenu(nf.gui,'Label','Edit');
            menu.edit.enable = uimenu(menu.edit.parent,'Label','Enable','Accelerator','e','Callback',@(hObject,eventdata)enableFcn(nf,hObject,eventdata));
            menu.edit.disable = uimenu(menu.edit.parent,'Label','Disable','Accelerator','d','Enable','Off', 'Callback',@(hObject,eventdata)disableFcn(nf,hObject,eventdata));
            
            menu.comments.parent = uimenu(nf.gui,'Label','Insert');
            menu.comments.insert = uimenu(menu.comments.parent,'Label','Comments','Accelerator','i','Callback',@(hObject,eventdata)insertCommentsFcn(nf,hObject,eventdata));
            menu.comments.insert = uimenu(menu.comments.parent,'Label','Log Header Template','Accelerator','l','Callback',@(hObject,eventdata)insertLogHeaderFcn(nf,hObject,eventdata));
            
            menu.goto.parent = uimenu(nf.gui,'Label','GoTo');
            menu.goto.sof = uimenu(menu.goto.parent,'Label','Top','Accelerator','t','Callback',@(hObject,eventdata)goto(nf,hObject,eventdata,0));
            menu.goto.eof = uimenu(menu.goto.parent,'Label','End Of File','Accelerator','g','Callback',@(hObject,eventdata)goto(nf,hObject,eventdata));
        end
        
        %%
        %   A function to resize the text area
        %%               
        function windowDidResize_Callback(nf,~,~)
            figPos = get(nf.gui, 'Position'); 
            textAreaPos	= get(nf.guiObjects.textArea, 'Position');
            textAreaPos(3) = figPos(3);
            textAreaPos(4) = figPos(4);
            set(nf.guiObjects.textArea, 'Position', textAreaPos);
        end
        
        %%
        %   A function pause the continuous logging from Symphony
        %   @param status: a boolean to determine what state the logging should be
        %       - true or 1 = on
        %       - false or 0 = off
        %%        
        function pauseLoggingFcn( nf , ~ , ~ , status )
            nf.continueLogging = status;
            if nf.continueLogging
                set(nf.guiObjects.menu.file.loggingOn,'Enable', 'off');
                set(nf.guiObjects.menu.file.loggingOff,'Enable', 'on');
            else
                set(nf.guiObjects.menu.file.loggingOn,'Enable', 'on');
                set(nf.guiObjects.menu.file.loggingOff,'Enable', 'off');                
            end
        end
        
        %%
        %   A function to GoTo a particular line
        %
        %   @param varagin: 
        %       - m.goto( oneinputvariable ) -> varargin{2} = the position
        %       of the document to goto
        %       - m.goto( ~ , ~ , ~ , fourinputvariable ) -> varargin{4} = the position
        %       of the document to goto. Note: This method is only called by the GUI     
        %%        
        function goto( varargin )
            narginchk(1,4);
            
            try
                nf = varargin{1};

                javaTextAreaHandler = findjobj(nf.guiObjects.textArea);
                javaTextArea = javaTextAreaHandler.getComponent(0).getComponent(0);

                if nargin == 4 && isnumeric(varargin{4}) && varargin{4} == 0
                    position = varargin{4};
                elseif nargin == 2 && isnumeric(varargin{2}) && varargin{2} == 0
                    position = varargin{2};
                else
                    position = javaTextArea.getDocument.getLength;
                end

                javaTextArea.setCaretPosition(position);
            catch
            end
        end
        
        %%
        %   A method to enable editing of the notes file
        %%        
        function enableFcn( nf , ~ , ~ )
            set(nf.guiObjects.menu.edit.enable, 'Enable', 'off');
            set(nf.guiObjects.menu.edit.disable, 'Enable', 'on');
            set(nf.guiObjects.textArea, 'Enable', 'on');
        end
        
        %%
        %   A method to disable editing of the notes file
        %%         
        function disableFcn( nf , ~ , ~ )
            set(nf.guiObjects.menu.edit.enable, 'Enable', 'on');
            set(nf.guiObjects.menu.edit.disable, 'Enable', 'off');
            set(nf.guiObjects.textArea, 'Enable', 'off');
        end

       
        %%
        %   A function to insert a heading file at the top of the notepad.
        %   NOTE: This will not delete any content that is already in the
        %   notepad
        %
        %   @param varargin:
        %       - Currently no external parameters are handled by the
        %       function.
        %%        
        function insertLogHeaderFcn( nf , ~ , ~ )
            [filename, pathname] =  uigetfile({'*.log;*.txt','All Files'}, 'Log Header File', nf.folders.headers);
            if filename ~= 0
                nf.folders.headers = pathname;
                file = fullfile(pathname, filename);
                fileText = nf.parseFile(file);
                
                currentText = char(get(nf.guiObjects.textArea, 'String'));
                
                set(nf.guiObjects.textArea, 'String', char(fileText,currentText));
            end
        end
        
        %%
        %   A function to insert comments into the notepad content. To do
        %   this it generates a small pop up GUI
        %
        %%        
        function insertCommentsFcn( nf , ~ , ~ )
            comment = inputdlg('Enter you Comment','Comments', [30 100]);
            
            if ~isempty(comment)
                comment = char(comment);
                commentBanner = '***************************************************';
                currentText = char(get(nf.guiObjects.textArea, 'String'), '');    

                set(nf.guiObjects.textArea, 'String', char(currentText,commentBanner,datestr(now, nf.timeString), comment, commentBanner));
            end
        end
        
        %%
        %   A function to close the app, called by the GUI. For
        %   programming use the closeApp Function
        %%        
        function closeRequestFcn( nf , ~ , ~ )
            closeApp(nf)
        end
        
        %%
        %   A function to close the app and delete any timers
        %%        
        function closeApp(nf)
            %nf.stopTimer;
            %delete(nf.saveTimer);
            
            saveFcn(nf);
            
            delete(nf.gui);
            delete(nf);
        end

        %%
        %   A function to open a new file
        %%        
        function openFcn ( nf , hObject , eventdata )
            [filename, pathname] =  uigetfile({'*.log;*.txt','All Files'}, 'Log Header File', nf.userDir);
            if filename ~= 0
                msg = [ 
                        '\n\nNote: The File Opened will not be Overwritten.' ...
                        'It will only be saved under the new file name.'
                      ];
                  
                nf.newFcn( hObject , eventdata , msg);
                file = fullfile(pathname, filename);
                fileText = nf.parseFile(file);
                nf.log(fileText);   
            end 
        end
 
        %%
        %   A function to save to the main folder location and the hidden
        %
        %   @param varargin:
        %       - Currently no external parameters are handled by the
        %       function.
        %%
        function saveFcn( varargin )
            narginchk(1,3);
            nf = varargin{1};
            
            s = get(nf.guiObjects.textArea, 'String');
            nRow = size(s,1);

            foldersLoc = fieldnames(nf.folders);

            for folder = 1:2
                loc = nf.folders.(foldersLoc{folder});
                if exist(loc, 'dir')
                    f = [loc '\' nf.fileNames.currentFileName '.log'];
                    fid = fopen(f, 'w');

                    formatSpec = '%s%s\n';
                    out = '';

                    for iRow = 1:nRow
                        out = sprintf(formatSpec,out,s(iRow,:));
                    end
                    fprintf(fid, out);
                    fclose(fid);
                else
                    waitfor(warndlg(['could not save to the folder location "' loc '" as it is not a valid folder']));
                end
            end
            
        end
        
        %%
        %   A function to start a new file, with a new file name. Note: It
        %   is a blank file.
        %
        %   @param msg: A message to display to the user when generating a new file        
        %%
        function newFcn( nf , ~ , ~ , msg)
            nf.saveFcn;
            oldFile = nf.fileNames.currentFileName;
            
            if nf.newFileCount > 0
                nf.fileNames.( ['file' nf.newFileCode(nf.newFileCount)] ) = oldFile;
            else
                nf.fileNames.file = oldFile;
            end
            
            nf.newFileName;
            
            warning = sprintf([ 
                        'The File you were just working on, ' ...
                        oldFile ...
                        ' has now been saved. ' ...
                        'A new File will be created with the name: ' ...
                        nf.fileNames.currentFileName ...
                        msg ...
                      ]);
            
            waitfor(warndlg(warning));
            set(nf.guiObjects.textArea, 'String', '');
            set(nf.gui,  'Name', ['Notes File: ' nf.fileNames.currentFileName]);
        end
        
        function initNew(nf)
            nf.fileNames = struct();
            nf.fileNames.currentFileName = [nf.dateStamp ' - ' nf.rigConfig];
            
            tempFileName = getpref('SymphonyLogger', 'currentFileName', nf.fileNames.currentFileName);

            dateCheck = strfind(tempFileName, nf.dateStamp);
            rigConfigCheck = strfind(tempFileName, nf.rigConfig);
            
            if isempty(dateCheck) || isempty(rigConfigCheck)
                nf.newFileCount = 0;
                set(nf.gui,  'Name', ['Notes File: ' nf.fileNames.currentFileName]);
            else
                nf.newFileCount = getpref('SymphonyLogger', 'newFileCount', nf.newFileCount);
                nf.newFileCode = getpref('SymphonyLogger', 'newFileCode', nf.newFileCode);
                nf.goto(0);
                nf.newFileName;                
            end
        end
        
        
        %%
        %   A function to open an existing file
        %%
        function openExistingFile(nf)
            tempFileName = getpref('SymphonyLogger', 'currentFileName', nf.fileNames.currentFileName);
            
            dateCheck = strfind(tempFileName, nf.dateStamp);
            rigConfigCheck = strfind(tempFileName, nf.rigConfig);
            
            fileLoc = fullfile(nf.folders.main ,[tempFileName '.log']);
            
            if ~isempty(dateCheck) && exist(fileLoc, 'file') && isempty(rigConfigCheck)
                nf.fileNames.currentFileName = tempFileName;
                nf.newFileCount = getpref('SymphonyLogger', 'newFileCount', nf.newFileCount);
                fileText = nf.parseFile(fileLoc);
                nf.log(fileText);
                nf.newFileCode = getpref('SymphonyLogger', 'newFileCode', nf.newFileCode);
            elseif ~isempty(dateCheck) && ~isempty(rigConfigCheck)
                setpref('SymphonyLogger', 'currentFileName', nf.fileNames.currentFileName);
                nf.newFileCount = getpref('SymphonyLogger', 'newFileCount', nf.newFileCount);
                nf.newFileCode = getpref('SymphonyLogger', 'newFileCode', nf.newFileCode);
                nf.goto(0);
                nf.newFileName;
            else
                setpref('SymphonyLogger', 'currentFileName', nf.fileNames.currentFileName);
                setpref('SymphonyLogger', 'newFileCount', nf.newFileCount);
                setpref('SymphonyLogger', 'newFileCode', []);
                nf.goto(0);
            end
        end
        
        %%
        %   A function to parse an external file and insert into the
        %   notepad application
        %
        %   @param fileString: The files location to open        
        %%
        function  out = parseFile(nf, fileString)
            fid = fopen(fileString, 'r');
            openFile = textscan(fid, '%s', 'Delimiter', '\n');
            fclose(fid);
            out = nf.parseText(openFile{1}); 
        end
        
        %%
        %   A function send either a string or a cell of strings to the
        %   text editor
        %
        %   @param varargin:
        %       An infinite amount of Strings or Cells can be passed into
        %       the logging application to log.
        %%
        function log( nf, varargin )
            narginchk(2,100);
            
            for textLine = 1:length(varargin)
                if ischar(varargin{textLine});
                    if textLine == 1
                         s = [varargin{textLine}];
                    else
                        s = [s varargin{textLine}]; %#ok<AGROW>
                    end
                end
            end

            currentText = char(get(nf.guiObjects.textArea, 'String'));
            
            if isempty(currentText)
                currentText = '';
            end
            
            set(nf.guiObjects.textArea, 'String', char(currentText,s));

            nf.goto(0);
        end

        %%
        %   A function to parse text
        %
        %   @param text: The text to parse in a valid format for matlab        
        %%        
        function out = parseText( ~ , text)
            out = '';
            for iRow = 1:length(text)
                out = char(out, text{iRow});
            end
        end
        
        %%
        %   Generating a new filename for an additional file
        %%       
        function newFileName(nf)
            upperCaseStart = 65;
            alphabetLength = 26;
            lowerCaseStart = 97;
            
            nf.newFileCount = nf.newFileCount + 1;
            
            if nf.newFileCount < (alphabetLength + 1)
                indexnum = nf.newFileCount - 1;
                number = upperCaseStart;
            else
                indexnum = nf.newFileCount - 1 - alphabetLength;
                number = lowerCaseStart;
            end
            
            nf.newFileCode(nf.newFileCount) = char(number + indexnum);
            nf.fileNames.currentFileName = [nf.dateStamp ' - ' nf.rigConfig ' - ' nf.newFileCode(nf.newFileCount)];
            setpref('SymphonyLogger', 'currentFileName', nf.fileNames.currentFileName);
            setpref('SymphonyLogger', 'newFileCount', nf.newFileCount);
            setpref('SymphonyLogger', 'newFileCode', nf.newFileCode);
            set(nf.gui,  'Name', ['Notes File: ' nf.fileNames.currentFileName]);
        end

        %%
        %   A Simple function to say if the string is a directory
        %
        %   @param dir: The string of a directory
        %%         
        function oDir = dirCheck( ~ , dir )
            if isdir(dir)
                oDir = true;
            else
                oDir = false;
            end
        end

        %%
        %   A function to initiate the autosave timer
        %   Note: To start the timer after it has been initiated you need
        %   to call the start function. nf.startTimer;
        %%           
%         function initTimer(nf)
%             nf.saveTimer = timer;
%             nf.saveTimer.TimerFcn = {@nf.saveFcn};
%             nf.saveTimer.Period = nf.timerInterval;
%             nf.saveTimer.ExecutionMode = 'fixedSpacing';
%             nf.saveTimer.Tag = 'Save Timer';
%         end    
%  
%         %%
%         %   A function to start the autosave timer
%         %%          
%         function startTimer(nf)
%             if(strcmp(nf.saveTimer.Running, 'off'))
%                 start(nf.saveTimer);
%             end
%         end
% 
%         %%
%         %   A function to stop the autosave timer
%         %%           
%         function stopTimer(nf)
%             if(strcmp(nf.saveTimer.Running, 'on'))
%                 stop(nf.saveTimer);
%             end
%         end        
    end
    
end