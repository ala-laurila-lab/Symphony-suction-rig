classdef PetriProtocol < SymphonyProtocol
    %PETRIPROTOCOL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = private)
        timeString = 'HH:MM:SS'
        externalApp
        notesFile = []
        solutionController = []
        SymphRigSwitches = []
        figure = []
        varMeanFig = []
    end
    
    properties (Hidden, Dependent)
        amplifierScalingFactor
        ampMode
    end
    
    properties (Hidden)
        storedAmpMode
        showStimuli = true
    end
    
    methods
        
        function init(obj, rigConfig, userData)
            init@SymphonyProtocol(obj, rigConfig, userData);
            
            obj.externalApp = obj.rigConfig.externalApps;
            
            appName = 'notesFile';
            obj.getExternalApp(appName);
            
            appName = 'solutionController';
            obj.getExternalApp(appName);
            
            if rigConfig.isDevice('RigSwitches')
                obj.SymphRigSwitches = SymphonyRigSwitches(obj, rigConfig);
            end
            
            if isempty(obj.figure) && obj.graphing
                obj.figure = PetriFigureHandler(obj, obj.amp);
            end
            
            if isempty(obj.varMeanFig) && obj.graphing
                obj.varMeanFig = PrePointsFigureHandler(obj, obj.amp);
            end
            
        end
        
        function sendToLog( obj, varargin )
            for textLine=1:length(varargin)
                if textLine == 1
                    s = char(varargin{textLine});
                else  
                    s = char(s, varargin{textLine});
                end
            end
            obj.notesFile.log(s);
        end
        
        function close(obj)
            close@SymphonyProtocol(obj);
            if ~isempty(obj.SymphRigSwitches)
                obj.SymphRigSwitches.close;
            end
            
            if ~isempty(obj.varMeanFig)
                obj.varMeanFig.close();
                delete(obj.varMeanFig);
            end
            
            if ~isempty(obj.figure)
                obj.figure.close();
                delete(obj.figure);
            end
            delete(obj.SymphRigSwitches);
        end
        
        %% valid Device
        function getExternalApp(obj, appName)
            if obj.externalApp.isValidApp(appName)
                obj.( appName ) = obj.externalApp.getApp(appName);
            end
        end
        
        %% Log Functions
        function bool = loggingIsValid(obj)
            bool = false;
            % continueLogging
            if isvalid(obj.notesFile)
                if ~isempty(obj.notesFile) && ...
                        obj.notesFile.continueLogging && ...
                        obj.allowLogging  && ...
                        obj.allowSavingEpochs
                    bool = true;
                end
            end
        end
        
        %% Overridden functions
        
        function prepareRun(obj)
            if ~isempty(obj.figure) && obj.graphing
                obj.figure.clearFigure();
            elseif isempty(obj.figure) && obj.graphing
                obj.figure = PetriFigureHandler(obj, obj.amp);
            end
            
            if ~isempty(obj.varMeanFig) && obj.graphing
                obj.varMeanFig.clearFigure();
            elseif isempty(obj.varMeanFig) && obj.graphing
                obj.varMeanFig = PrePointsFigureHandler(obj, obj.amp);
            end
            
            if ~isempty(obj.solutionController)
                try
                    if strcmp(obj.solutionController.conn.Status, 'open')
                        obj.solutionController.disconnect();
                    end
                catch
                end
            end
            
            prepareRun@SymphonyProtocol(obj);
            % Adding the parameters from the edit-UI menu that we want to
            % add to the notes file
            if obj.loggingIsValid && isprop(obj, 'propertiesToLog') && ~isempty(obj.propertiesToLog)
                count = numel(obj.propertiesToLog);
                                
                x = 1;
                
                formatSpec = '%s StimLED:%s';
                s = sprintf(formatSpec, obj.displayName, obj.StimulusLED);
                
                if(strcmp(obj.amp, 'Amplifier_Ch1'))
                    formatSpec = '%s      Amp1-%s\n';
                else
                    formatSpec = '%s      Amp2-%s\n';
                end
                
                s = sprintf(formatSpec, s, char(obj.rigConfig.getAmpMode(obj.amp)));
                
                for f = 1:count
                    unit = '';
                    printingString = '';
                    value=obj.( obj.propertiesToLog{f} );
                    
                    nameForLogging = obj.propertiesToLog{f};
                    
                    if f == 1
                        formatSpec = '\n%s%s: %s%s  ';
                    else
                        formatSpec = '%s%s: %s%s  ';
                    end
                    
                    if strcmp(obj.propertiesToLog{f}, 'backgroundLEDs')
                        leds = fieldnames(value);
                        for led = 1:numel(leds)
                            name = leds{led};
                            channel = value.(leds{led});
                            background = channel.epochBackground;
                            
                            printingString = [printingString ' ' name ':' num2str(background) 'mV']; %#ok<AGROW>
                        end
                    elseif strcmp(obj.propertiesToLog{f}, 'customAmpHoldSignal')
                        [~,~,~,holdSignal] = obj.getHoldSignal();
                        nameForLogging = 'AmpHold';
                        printingString = num2str(holdSignal);
                    elseif ~ischar(value)
                        if f == 1
                            formatSpec ='\n%s%s: %d%s  ';
                        else
                            formatSpec ='%s%s: %d%s  ';
                        end
                                                
                        printingString = value;
                    end
                    
                    if strcmp(obj.propertiesToLog{f}, 'preTime') || strcmp(obj.propertiesToLog{f}, 'tailTime') || strcmp(obj.propertiesToLog{f}, 'stimTime')
                        unit = 'ms';
                    elseif strcmp(obj.propertiesToLog{f}, 'customAmpHoldSignal') || strcmp(obj.propertiesToLog{f}, 'preAndTailSignal')
                        unit = 'mV';
                    end
                    
                    
                    s = sprintf(formatSpec,s,nameForLogging,printingString,unit);
                    x = x + 1;
                end
                
                
                
                obj.sendToLog(s);
            end
        end
        
        function prepareRig(obj)
            prepareRig@SymphonyProtocol(obj);
        end
        
        function completeRun(obj)
            completeRun@SymphonyProtocol(obj);
            if obj.loggingIsValid
                obj.notesFile.saveFcn;
            end
            
            if ~isempty(obj.figure) && obj.graphing
                obj.figure.completeRun();
            end
            
            if ~isempty(obj.solutionController)
                try
                    if strcmp(obj.solutionController.conn.Status, 'closed')
                        obj.solutionController.connect();
                    end
                catch
                end
            end
            
        end
        
        function run(obj)
            if ~isempty(obj.figure) && obj.graphing
                obj.figure.run();
            end
            run@SymphonyProtocol(obj);
        end
        
        function completeEpoch(obj, epoch)
            completeEpoch@SymphonyProtocol(obj, epoch);
            
            % If you are plotting the solution, this will update the graph
            if ~isempty(obj.figure) && obj.graphing
                obj.figure.handleEpoch(epoch);
            elseif isempty(obj.figure) && obj.graphing
                obj.figure = PetriFigureHandler(obj, obj.amp);
                obj.figure.handleEpoch(epoch);
            end
            
            if ~isempty(obj.varMeanFig) && obj.graphing
                obj.varMeanFig.handleEpoch(epoch);
            elseif isempty(obj.varMeanFig) && obj.graphing
                obj.varMeanFig = PrePointsFigureHandler(obj, obj.amp);
                obj.varMeanFig.handleEpoch(epoch);
            end
            
            
            % Override this method to perform any post-analysis, etc. on the current epoch.
            s = '';  %#ok<NASGU>
            
            epoch.addParameter('EpochNumber', obj.numEpochsCompleted);
            
            % Adding all the information we want about the epoch into the
            % notes file
            if obj.loggingIsValid
                formatSpec = '%u      %u:%u:%u';
                s = sprintf(formatSpec, ...
                    obj.numEpochsCompleted, ...
                    epoch.startTime.Item2.Hour, ...
                    epoch.startTime.Item2.Minute, ...
                    epoch.startTime.Item2.Second);
                                                
                if ~isempty(strfind(obj.displayName,'LED Factor Pulse')) && isprop(obj,'storedPulseAmplitude')
                    formatSpec = '%s      StimAmp:%gmV';
                    s = sprintf(formatSpec, s, obj.storedPulseAmplitudeBackground{obj.numEpochsCompleted}); 
                end
                
                if obj.rigConfig.isDevice('Optometer')
                    formatSpec = '%s      Optometer: %s';
                    s = sprintf(formatSpec, s, recordLEDCalibration(epoch, obj.lightRange));
                end
                
                if obj.rigConfig.isDevice('HeatController')
                    formatSpec = '%s      Temp:%gC';
                    s = sprintf(formatSpec, s, recordSolutionTemp(epoch));
                end
                
                if ~isempty(obj.solutionController) && ...
                        obj.solutionController.recordStatus;
                    
                    formatSpec = '%s      %s';
                    s = sprintf(formatSpec, s, 'valve:');
                    
                    status = textscan(obj.solutionController.getAppStatus, '%s', 'delimiter', sprintf(','));
                    formatSpec = '%s %d';
                    
                    for v = 2:(length(status{1})-1)
                        s = sprintf(formatSpec, s, str2double(status{1}{v}));
                    end
                    
                    epoch.addParameter('ValveStatus', s);
                end
                obj.sendToLog(s);
            end
            
            if ~isempty(obj.SymphRigSwitches)
                obj.SymphRigSwitches.switchesChanged(epoch);
            end
        end
        
        %This function checks to see if the maximum value of the voltage
        %ouput is below that of 10v. This is for the output devices
        function isOverMaxAmplitude(obj)
            factor = 1e-3;
            maxAllowableAmplitude = factor * 10000;
            
            leds = fieldnames(obj.backgroundLEDs);
            for led = 1:numel(leds)
                name = char(leds{led});
                channel = obj.backgroundLEDs.(name);
                if factor * channel.( 'steadyBackground' ) > maxAllowableAmplitude || ...
                        factor * channel.( 'epochBackground' ) > maxAllowableAmplitude
                    error('StimulusLED:CONTROLLER:ERROR', 'The max value for the protocol has to be less then 10,000mV. The largest value for the epochs you have entered will be ' + (factor * channel.( 'epochBackground' )))
                end
            end
        end
        
        function sF = get.amplifierScalingFactor(obj)
            if obj.rigConfig.isAxopatchDevice(obj.amp)
                sF = 50;
            elseif obj.rigConfig.isMultiClampDevice(obj.amp)
                sF = 1;
            end
        end
        
        function applyAmpHoldSignal(obj, varargin)
            [holdSignal,unit,~,~] = obj.getHoldSignal();
            
            obj.setDeviceBackground(obj.amp, holdSignal, unit);
            
            dateStamp = datestr(now, 'HH:MM:SS');
            unit = 'mV';
            [~,~,~,holdSignal] = obj.getHoldSignal();
            
            if length(varargin) == 1
                if obj.loggingIsValid && varargin{1}
                    if(strcmp(obj.amp, 'Amplifier_Ch1'))
                        formatSpec = '\n%s AMP1 HOLD:%g%s';
                    else
                        formatSpec = '\n%s AMP2 HOLD:%g%s';
                    end         
                    
                    s = sprintf(formatSpec,dateStamp, holdSignal, unit);
                    obj.sendToLog(s);
                end
            end
        end
        
        function [holdSignalScaled, unit, factor, holdSignalUnscaled] = getHoldSignal(obj)
            % Set the amp hold signal.
            holdSignalUnscaled = obj.amplifierScalingFactor * obj.customAmpHoldSignal.ampHoldSignal;
            
            if strcmp(obj.ampMode, 'VClamp') || strcmp(obj.ampMode, 'V-Clamp')
                unit = 'V';
                factor = 1e-3;
            else
                unit = 'A';
                factor = 1e-12;
            end
            
            holdSignalScaled = obj.amplifierScalingFactor * obj.customAmpHoldSignal.ampHoldSignal * factor;
        end
        
        function aM = get.ampMode(obj)
            temp = char(obj.rigConfig.getAmpMode(obj.amp));
            
            if ~isempty(temp)
                aM = temp;
                obj.storedAmpMode = aM;
            else
                if obj.rigConfig.isAxopatchDevice(obj.amp)
                    % We can only get the Axopatch device reading before
                    % the protocol starts so we need to use the initia;
                    % configuration
                    aM = obj.storedAmpMode;
                end
            end
        end
        
        function [stim, units] = generateTTLStimulus(obj)
            import Symphony.Core.*;
            
            % Convert time to sample points.
            prePts = round(obj.preTime / 1e3 * obj.sampleRate);
            stimPts = round(obj.stimTime / 1e3 * obj.sampleRate);
            tailPts = round(obj.tailTime / 1e3 * obj.sampleRate);
            
            % Create pulse stimulus.
            stim = ones(1, prePts + stimPts + tailPts) * 0;
            stim(prePts + 1:prePts + stimPts) = 1;
            
            units = Symphony.Core.Measurement.UNITLESS;
        end
        
        % This function is to apply the backgrounds you can set in the edit
        % parameters GUI
        function applyBackgrounds(obj, bLED, updateObjBackground, state)
            if updateObjBackground
                obj.backgroundLEDs = bLED;
            end
            
            obj.isOverMaxAmplitude;
            
            leds = fieldnames(bLED);
            units = 'mV';
            
            s= '';
            
            for led = 1:numel(leds)
                name = char(leds{led});
                channel = bLED.(name);
                dateStamp = datestr(now, 'HH:MM:SS');
                if obj.rigConfig.isDevice(name)
                    obj.setDeviceBackground(name, channel.( state ), units);
                    if obj.loggingIsValid && strcmp(state, 'steadyBackground')
                        formatSpec = '\n%s LED%s :%g%s';
                        s = sprintf(formatSpec,dateStamp,name,channel.( state ), units);
                        obj.sendToLog(s);
                    end
                end
            end
        end
        
    end
    
end

