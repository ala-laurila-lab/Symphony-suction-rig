% This protocol sends pulses on the same interval to the
% StimulusLED

classdef LEDPulseBackground < PetriProtocol
    
    
    properties (Constant)
        identifier = 'petri.symphony-das.LEDPulseBackground'
        version = 1
        displayName = 'LEDPulseBackground'
    end
    
    
    properties
        amp
        StimulusLED = {'Ch1','Ch2','Ch3'}
        pulseAmplitude = 100
        preTime = 50
        stimTime = 500
        tailTime = 50
        preAndTailSignal = -60
        numberOfAverages = uint16(5)
        interpulseInterval = 0
        ampHoldSignal = -60
        
        backgroundLEDs
        
        graphing = true
        
        %ttl1 = {'A','B'}
        
        %%
        %lightRange = {'pico','nano','micro','raw'}
        
        % If you are using the Optometer, and it is connected to the Rig obj.addDevice('Optometer', 'ANALOG_IN.3', '');
        % The light range variable needs to be uncommented
        
        %%        
    end
    
    
    properties (Hidden)
        allowLogging
        storedAmpMode
        propertiesToLog = { ...
            'preTime' ...
            'stimTime' ...
            'tailTime' ...
            'pulseAmplitude' ...
            'preAndTailSignal' ...
            };
    end
    
    properties (Hidden, Dependent, SetAccess = private)
        ampMode
    end
    
    methods
        function init(obj, rigConfig, userData)
            init@PetriProtocol(obj, rigConfig, userData);
            obj.allowLogging = true;
        end
        
        function dn = requiredDeviceNames(obj) %#ok<MANU>
            % Override this method to indicate the names of devices that are required for this protocol.
            dn = {};
        end
        
        
        function p = parameterProperty(obj, parameterName)
            % Call the base method to create the property object.
            p = parameterProperty@SymphonyProtocol(obj, parameterName);
            
            % Return properties for the specified parameter (see ParameterProperty class).
            switch parameterName
                case 'amp'
                    % Prefer assigning default values in the property block above.
                    % However if a default value cannot be defined as a constant or expression, it must be defined here.
                    if obj.rigConfig.numAxoPatchDevices > 0 ...
                            && obj.rigConfig.numMultiClampDevices > 0
                        error('AMPLIFIER:ERROR', 'Both the Axpatch Device and the Multiclamp device have been added to the rig config');
                    elseif obj.rigConfig.numAxoPatchDevices > 0
                        p.defaultValue = obj.rigConfig.axoPatchDeviceNames();
                    elseif obj.rigConfig.numMultiClampDevices > 0
                        p.defaultValue = obj.rigConfig.multiClampDeviceNames();
                    else
                        error('AMPLIFIER:ERROR', 'No Amplifier has been found on this Rig');
                    end
                case {'preTime', 'stimTime', 'tailTime'}
                    p.units = 'ms';
                case {'pulseAmplitude', 'preAndTailSignal'}
                    p.units = 'mV or pA';
                case 'backgroundLEDs'
                    p.units = 'mV or pA';
                    p.defaultValue = struct();
                    stimLED = findprop(obj, 'StimulusLED');
                    stimLED = stimLED.DefaultValue;
                    
                    for i = 1:length(stimLED)
                        p.defaultValue.(char(stimLED(i))) = struct();
                        p.defaultValue.(char(stimLED(i))).steadyBackground = 0;
                        p.defaultValue.(char(stimLED(i))).epochBackground = 0;
                    end
            end
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
        
        function prepareRun(obj)
            % Call the base method.
            prepareRun@PetriProtocol(obj);
            % Set the amp hold signal.
            if strcmp(obj.ampMode, 'VClamp') || strcmp(obj.ampMode, 'V-Clamp')
                obj.setDeviceBackground(obj.amp, obj.ampHoldSignal * 1e-3, 'V');
            else
                obj.setDeviceBackground(obj.amp, obj.ampHoldSignal * 1e-12, 'A');
            end
            
            obj.applyBackgrounds(obj.backgroundLEDs, false, 'epochBackground');
        end
        
        function completeRun(obj)
            completeRun@PetriProtocol(obj);
            obj.applyBackgrounds(obj.backgroundLEDs, false, 'steadyBackground');
        end
        
        function [stim, units] = generateStimulus(obj)
            units = 'V';
            % Convert time to sample points.
            prePts = round(obj.preTime / 1e3 * obj.sampleRate);
            stimPts = round(obj.stimTime / 1e3 * obj.sampleRate);
            tailPts = round(obj.tailTime / 1e3 * obj.sampleRate);
            
            % Create pulse stimulus.
            stim = ones(1, prePts + stimPts + tailPts) * obj.preAndTailSignal + obj.backgroundLEDs.(obj.StimulusLED).epochBackground;
            stim(prePts + 1:prePts + stimPts) = (obj.pulseAmplitude + obj.backgroundLEDs.(obj.StimulusLED).epochBackground);
            stim = stim * 1e-3;
        end
        
        function stimuli = sampleStimuli(obj)
            % Return a sample stimulus for display in the edit parameters window.
            stimuli{1} = obj.generateStimulus();
        end
        
        
        function prepareRig(obj)
            % Call the base class method to set the DAQ sample rate.
            
            obj.isOverMaxAmplitude;
            
            prepareRig@PetriProtocol(obj);
            %obj.applyBackgrounds(obj.backgroundLEDs, false, 'steadyBackground');
            %             if strcmp(obj.ttl1,'A')
            %                 ttl = 0;
            %             else
            %                 ttl = 1;
            %             end
            %
            %             obj.setDeviceBackground([obj.StimulusLED 'AORB'], ttl, '_unitless_');
        end
        
        function isOverMaxAmplitude(obj)
            isOverMaxAmplitude@PetriProtocol(obj);
            maxAllowableAmplitude = 10000;
            
            maxProtocolAmplitude = (obj.pulseAmplitude + obj.backgroundLEDs.(obj.StimulusLED).epochBackground);
            maxProtocolAmplitudePreAndTailSignal = ((obj.pulseAmplitude + obj.backgroundLEDs.(obj.StimulusLED).epochBackground) + obj.preAndTailSignal);
            
            if	maxProtocolAmplitude > maxAllowableAmplitude || ...
                    maxProtocolAmplitudePreAndTailSignal > maxAllowableAmplitude
                error('StimulusLED:CONTROLLER:ERROR', 'The max value for the protocol has to be less then 10,000mV')
            end
        end
        
        function prepareEpoch(obj, epoch)
            % Call the base method.
            prepareEpoch@SymphonyProtocol(obj, epoch);
            
            [ stim , units ] = obj.generateStimulus();
            epoch.addStimulus(obj.StimulusLED, [obj.StimulusLED '_Stimulus'], stim, units);
        end
        
        function run(obj)
            run@PetriProtocol(obj);
        end
        
        function queueEpoch(obj, epoch)
            % Call the base method to queue the actual epoch.
            queueEpoch@SymphonyProtocol(obj, epoch);
            
            % Queue the inter-pulse interval after queuing the epoch.
            if obj.interpulseInterval > 0
                obj.queueInterval(obj.interpulseInterval);
            end
        end
        
        
        function keepQueuing = continueQueuing(obj)
            % Check the base class method to make sure the user hasn't paused or stopped the protocol.
            keepQueuing = continueQueuing@SymphonyProtocol(obj);
            
            % Keep queuing until the requested number of averages have been queued.
            if keepQueuing
                keepQueuing = obj.numEpochsQueued < obj.numberOfAverages;
            end
        end
        
        
        function keepGoing = continueRun(obj)
            % Check the base class method to make sure the user hasn't paused or stopped the protocol.
            keepGoing = continueRun@SymphonyProtocol(obj);
            
            % Keep going until the requested number of averages have been completed.
            if keepGoing
                keepGoing = obj.numEpochsCompleted < obj.numberOfAverages;
            end
        end
        
        function completeEpoch(obj, epoch)
            completeEpoch@PetriProtocol(obj, epoch);
        end
        
    end
    
end

