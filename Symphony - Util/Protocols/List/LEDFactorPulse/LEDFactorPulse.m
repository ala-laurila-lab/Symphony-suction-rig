% The steps for this equation are
% pulseAmlitude
% pulseAmlitude * scalingFactor
% pulseAmlitude * scalingFactor ^ 2
% pulseAmlitude * scalingFactor ^ 4
% pulseAmlitude * scalingFactor ^ 6
% ....
% Until the max limit is reached

classdef LEDFactorPulse < PetriProtocol
    
    
    properties (Constant)
        identifier = 'petri.symphony-das.LEDFactorPulse'
        version = 1
        displayName = 'LED Factor Pulse'
    end
    
    
    properties
        amp
        StimulusLED = {'Ch1','Ch2','Ch3'}
        initialPulseAmplitude = 100
        scalingFactor = 2
        preTime = 50
        stimTime = 500
        tailTime = 50
        numberOfIntensities = 5
        numberOfRepeats = 1
        interpulseInterval = 0
        customAmpHoldSignal
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
        allowLogging = true
        propertiesToLog = { ...
            'preTime' ...
            'stimTime' ...
            'tailTime' ...
            'backgroundLEDs' ...
            'customAmpHoldSignal' ...
            };
        pulseAmplitude
        storedPulseAmplitude = {};
        storedPulseAmplitudeBackground = {};
        power = 0;
        numberOfEpochs = 0; 
        epochCount = 0;
    end
    
    methods
        function init(obj, rigConfig, userData)
            init@PetriProtocol(obj, rigConfig, userData);
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
                case {'pulseAmplitude', 'initialPulseAmplitude'}
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
                case 'customAmpHoldSignal'
                    p.units = 'mV or pA';
                    p.defaultValue = struct();
                    p.defaultValue.ampHoldSignal = -60;
                    p.defaultValue.currentAmpHoldSignal = -60;
            end
        end
        
        function prepareRun(obj)
            % Call the base method.
            prepareRun@PetriProtocol(obj);
            obj.resetParameters();
            
            % Set the amp hold signal.
            obj.applyAmpHoldSignal();
            
            obj.numberOfEpochs = obj.numberOfIntensities * obj.numberOfRepeats;
            
            obj.applyBackgrounds(obj.backgroundLEDs, false, 'epochBackground');
        end
        
        function resetParameters(obj)
            obj.pulseAmplitude = obj.initialPulseAmplitude;
            obj.power = 0;
            obj.epochCount = 0;
            obj.storedPulseAmplitude = {};
            obj.storedPulseAmplitudeBackground = {};
            obj.numEpochsQueued = 0;
        end
        
        function run(obj)
            run@PetriProtocol(obj);
        end
        
        function completeRun(obj)
            completeRun@PetriProtocol(obj);
            obj.applyBackgrounds(obj.backgroundLEDs, false, 'steadyBackground');
        end
        
        function [stim, units] = generateStimulus(obj)
            units = 'V';
            
            if obj.numEpochsQueued ~= 0 && mod(obj.numEpochsQueued, obj.numberOfIntensities) == 0
                obj.power = 0;
                obj.pulseAmplitude = obj.initialPulseAmplitude;
            end
            
            obj.pulseAmplitude = obj.initialPulseAmplitude * (obj.scalingFactor)^obj.power;
            obj.power = obj.power + 1;
            obj.epochCount = obj.epochCount + 1;
            obj.storedPulseAmplitude{obj.epochCount} = obj.pulseAmplitude;
            obj.storedPulseAmplitudeBackground{obj.epochCount} = (obj.pulseAmplitude + obj.backgroundLEDs.(obj.StimulusLED).epochBackground);
            
            % Convert time to sample points.
            prePts = round(obj.preTime / 1e3 * obj.sampleRate);
            stimPts = round(obj.stimTime / 1e3 * obj.sampleRate);
            tailPts = round(obj.tailTime / 1e3 * obj.sampleRate);
            
            % Create pulse stimulus.
            stim = ones(1, prePts + stimPts + tailPts) * obj.backgroundLEDs.(obj.StimulusLED).epochBackground;
            stim(prePts + 1:prePts + stimPts) = (obj.pulseAmplitude + obj.backgroundLEDs.(obj.StimulusLED).epochBackground);
            stim = stim * 1e-3;
        end
        
        function stimuli = sampleStimuli(obj)
            % Return a sample stimulus for display in the edit parameters window.
            try
                obj.resetParameters();
                stimuli = cell(obj.numberOfIntensities, 1);
                for i=1:obj.numberOfIntensities
                    stimuli{i} = obj.generateStimulus();
                end
            catch
            end
        end
        
        
        function prepareRig(obj)
            obj.isOverMaxAmplitude;
            
            % Call the base class method to set the DAQ sample rate.
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
            
            maxEquationValue = obj.initialPulseAmplitude * ( obj.scalingFactor^(obj.numberOfIntensities-1) );
            maxProtocolAmplitude = (maxEquationValue + obj.backgroundLEDs.(obj.StimulusLED).epochBackground);
            maxProtocolAmplitudePreAndTailSignal = (maxEquationValue + obj.backgroundLEDs.(obj.StimulusLED).epochBackground);
            
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
            
            [stim, units] = obj.generateTTLStimulus();
            epoch.addStimulus('OscilloscopeTrigger', 'OscilloscopeTrigger_Stimulus', stim, units);
            
            if obj.initialPulseAmplitude <= 0
                [stim, units] = obj.generateTTLStimulus();
                %epoch.addStimulus('ShutterTrigger', 'ShutterTrigger_Stimulus', stim, units);
                epoch.addStimulus('RandomName', 'RandomName_Stimulus', stim, units);
            end
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
                keepQueuing = obj.numEpochsQueued < obj.numberOfEpochs;
                if ~keepQueuing
                    obj.numberOfEpochs = obj.numEpochsQueued;
                end
                
            end
        end
        
        
        function keepGoing = continueRun(obj)
            % Check the base class method to make sure the user hasn't paused or stopped the protocol.
            keepGoing = continueRun@SymphonyProtocol(obj);
            
            % Keep going until the requested number of averages have been completed.
            if keepGoing
                keepGoing = obj.numEpochsCompleted < obj.numberOfEpochs;
            end
        end
        
        function completeEpoch(obj, epoch)
            completeEpoch@PetriProtocol(obj, epoch);
        end
        
    end
    
end

