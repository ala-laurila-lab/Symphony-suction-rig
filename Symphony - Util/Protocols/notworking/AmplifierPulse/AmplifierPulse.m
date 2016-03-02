classdef AmplifierPulse < SymphonyProtocol

    properties (Constant)
        identifier = 'petri.symphony-das.AmplifierPulse'
        version = 1
        displayName = 'Amplifier Pulse'
    end
    
    properties
        amp
        preTime = 50
        stimTime = 500
        tailTime = 50
        pulseAmplitude = 100
        preAndTailSignal = -60
        ampHoldSignal = -60
        numberOfAverages = uint16(5)
        interpulseInterval = 0
        graphing = true
    end
    
    properties (Hidden)
        storedAmpMode
    end
    
    properties (Hidden, Dependent, SetAccess = private)
        ampMode
    end    
    
    methods           
        
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
                case {'pulseAmplitude', 'preAndTailSignal', 'ampHoldSignal'}
                    p.units = 'mV or pA';
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
            prepareRun@SymphonyProtocol(obj);
            
            % Set the amp hold signal.
            if strcmp(obj.ampMode, 'VClamp') || strcmp(obj.ampMode, 'V-Clamp')
                obj.setDeviceBackground(obj.amp, obj.ampHoldSignal * 1e-3, 'V');
            else
                obj.setDeviceBackground(obj.amp, obj.ampHoldSignal * 1e-12, 'A');
            end
            
            % Open figures showing the response and mean response of the amp.
            obj.openFigure('Mean Response', obj.amp);
            obj.openFigure('Response', obj.amp);
        end
        
        
        function [stim, units] = generateStimulus(obj)
            % Convert time to sample points.
            prePts = round(obj.preTime / 1e3 * obj.sampleRate);
            stimPts = round(obj.stimTime / 1e3 * obj.sampleRate);
            tailPts = round(obj.tailTime / 1e3 * obj.sampleRate);
            
            % Create pulse stimulus.
            stim = ones(1, prePts + stimPts + tailPts) * obj.preAndTailSignal;
            stim(prePts + 1:prePts + stimPts) = obj.pulseAmplitude + obj.preAndTailSignal;
            
            % Convert the pulse stimulus to appropriate units for the current multiclamp mode.
            if strcmp(obj.ampMode, 'VClamp') || strcmp(obj.ampMode, 'V-Clamp')
                stim = stim * 1e-3; % mV to V
                units = 'V';
            else
                stim = stim * 1e-12; % pA to A
                units = 'A';
            end
        end
        
        function run(obj)
            run@PetriProtocol(obj);
        end
        
        function stimuli = sampleStimuli(obj)
            % Return a sample stimulus for display in the edit parameters window.
            stimuli{1} = obj.generateStimulus();
        end
        
        
        function prepareEpoch(obj, epoch)
            % Call the base method.
            prepareEpoch@SymphonyProtocol(obj, epoch);
            
            % Add the amp pulse stimulus to the epoch.
            [stim, units] = obj.generateStimulus();
            epoch.addStimulus(obj.amp, [obj.amp '_Stimulus'], stim, units);  
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
        
    end
    
end