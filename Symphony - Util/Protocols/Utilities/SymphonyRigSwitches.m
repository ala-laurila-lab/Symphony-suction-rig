classdef SymphonyRigSwitches < handle
    properties
        % These are the functions tied to every switch
        
% Examples        
%         switchOne = {'pauseProtocol'};
%         switchTwo = {'stopProtocol'};
%         switchThree = {'startProtocol'};
        
        % These are the available switches. The value in the cell eg,
        % 'runProtocol' is a function that you have to create and place in
        % this file (switch control functions start at line 156).
        switchOne = {'runProtocol'};
        switchTwo = {'dontSave'};
        switchThree = {'updateFigures'};
        switchFour = {'stopProtocol'};
        switchFive = {''};
        switchSix = {''};    
        switchSeven = {''};
        switchEight = {''};       
    end
    
    properties (Hidden)
        switches
        totalSwitchValue
        switchListNo
        protocol
        rigConfig
        t
        
        numberOfAverages = []
    end
    
    methods
        function rs = SymphonyRigSwitches(protocol, rigConfig)
            rs.protocol = protocol;
            rs.rigConfig = rigConfig;
            
            rs.switches = {};
            
            switchList = properties(rs);
            rs.switchListNo = numel(switchList);
            
            % Creating the struct that contains all the switches
            % information
            for switchIndex = 1:rs.switchListNo
                name = switchList{switchIndex};
                
                rs.switches{switchIndex} = struct();
                rs.switches{switchIndex}.( 'switchFunction' ) = rs.( name ){1};
                rs.switches{switchIndex}.( 'state' ) = 0;
                rs.switches{switchIndex}.( 'switchPostion' ) = 2^(switchIndex - 1);
            end
            
            rs.totalSwitchValue = 0;
            rs.initTimer;
            rs.startTimer;
        end
        
        function close(rs)
            try
                rs.stopTimer;
                delete(timer);
            catch
                % When the user cancels making a protocol, the object will
                % have already been deleted
            end
        end
        
        %% Timer Functions
        % To read the reading from the daq board while protocol is not
        % running

        function initTimer(rs)
            rs.t = timer;
            rs.t.Name = 'SymphonyRigSwitches';
            rs.t.TimerFcn = {@rs.timerFunction};
            rs.t.Period = 0.5;
            rs.t.ExecutionMode = 'fixedSpacing';
            rs.t.Tag = 'RigSwitchPolling';
        end    
        
        function startTimer(rs)
            if(strcmp(rs.t.Running, 'off'))
                start(rs.t);
            end
        end
        
        function stopTimer(rs)
            if(strcmp(rs.t.Running, 'on'))
                stop(rs.t);
            end
        end
        
        function timerFunction( rs , ~ , ~ )
            try
                bitMaskTotal = rs.rigConfig.getSingleReadingFromDevice('RigSwitches');
                rs.changeState(bitMaskTotal{1});      
            catch
                % The User is Changing rigs, protocol or the multiclamp is
                % switched off
            end
        end
        
        %% Switch Change Functions
        
        % reading in the digital input to determine which switches were
        % changed
        function switchesChanged(rs, epoch)
            response = epoch.response('RigSwitches');
            samples = length(response);
            
            if samples > 0
                bitMaskTotal = response(samples);
                rs.changeState(bitMaskTotal);
            end
        end
        
        % Setting the state of the switch that has been changed
        function setState(rs, switchIndex, value)
            rs.switches{switchIndex}.( 'state' ) = value;
            functionName = rs.switches{switchIndex}.( 'switchFunction' );
            
            %if value == 1 
                try
                    rs.( functionName )(value);
                catch
                    %Not a function, who cares lets not run it
                end
            %end
        end
        
        % This function is called to see if any switches have had there state changed
        function changeState(rs, bitMaskTotal)
            %converting the number recieved to its binary form
            binary = dec2bin(bitMaskTotal,8);
            binaryString = num2str(binary);            
            
            % Find the location of any on switches and off switches
            onSwitches = strfind(binaryString, '1');
            offSwitches = strfind(binaryString, '0');
            
            for os = 1:length(onSwitches)
                % Binary numbers read from right to left so we have to change the direction
                switchIndex = (8 - onSwitches(os)) + 1;
                rs.setState(switchIndex,1);
            end

             for os = 1:length(offSwitches)
                % Binary numbers read from right to left so we have to change the direction                 
                switchIndex = (8 - offSwitches(os)) + 1;
                rs.setState(switchIndex,0);
             end
        end
		
        %% Switch control functions
        % The value is that state of the switch.
        %   - value = 0 when the switch is down
        %   - value = 1 when the switch is up
        function dontSave( rs , value )
            if value == 0
                rs.protocol.allowSavingEpochs = false;
                rs.protocol.protocol.persistor = [];                
            else
                rs.protocol.allowSavingEpochs = true;
                rs.protocol.persistor = rs.protocol.symphonyUIPersistor;
            end
        end
        
        function runProtocol( rs , value )
            if rs.protocol.numberOfIntensities ~= 0
                rs.numberOfAverages = rs.protocol.numberOfEpochs;    
            end
            
            if value == 1
                if ~isempty(rs.numberOfAverages)
                    rs.protocol.numberOfEpochs = rs.numberOfAverages;
                end
            else
                rs.protocol.numberOfEpochs = rs.protocol.numberOfIntensities;
            end
        end
        
        function updateFigures( rs , value )
            if value == 1
                rs.protocol.graphing = true;
            else
                rs.protocol.graphing = false;
            end
        end
        
       %% Example Switch control functions
       % Not currently in use
       function stopProtocol( rs , value )
           if value == 0 && strcmp(rs.protocol.state, 'running')
                rs.protocol.stop();
                obj.SymphRigSwitches.startTimer;
           end
       end
       
       function pauseProtocol( rs , value )
            if value == 1 && strcmp(rs.protocol.state, 'running')
                rs.protocol.pause();
                rs.startTimer;
            end
       end
       
       function startProtocol( rs , value )
           if value == 1 && rs.protocol.rigPrepared && (strcmp(rs.protocol.state, 'stopped') || strcmp(rs.protocol.state, 'paused'))
               rs.stopTimer;
               rs.protocol.run();
           end
       end
		
    end
end