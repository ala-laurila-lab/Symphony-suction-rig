classdef SealAndLeak < PetriProtocol

    properties (Constant)
        identifier = 'petri.symphony-das.SealAndLeak'
        version = 1
        displayName = 'Seal and Leak'
        graphing = false
    end
    
    properties
        amp
        mode = {'seal', 'leak'}
        alternateMode = true
        preTime = 15
        stimTime = 30
        tailTime = 15
        pulseAmplitude = 5      
        customAmpHoldSignal
    end
    
    properties (Hidden)
        allowLogging = false;
        ttlTriggerPulse = 1;
        sealAmpHold
        leakAmpHold
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
                case 'alternateMode'
                    p.description = 'Alternate from seal to leak to seal etc., on each successive run.';
                case {'preTime', 'stimTime', 'tailTime'}
                    p.units = 'ms';
                case {'pulseAmplitude', 'leakAmpHoldSignal'}
                    p.units = 'mV or pA';
                case 'customAmpHoldSignal'
                    p.defaultValue = struct();
                    p.defaultValue.ampHoldSignal = -60;
                    p.defaultValue.currentAmpHoldSignal = -60;                    
            end
        end
 
       
        function init(obj, rigConfig, userData)
            % Call the base method.
            init@PetriProtocol(obj, rigConfig, userData);
            
            % Epochs of indefinite duration, like those produced by this protocol, cannot be saved. 
            obj.neverAllowSavingEpochs = true;
            obj.allowPausing = false;      
        end  
        
        function prepareRig(obj)
            prepareRig@PetriProtocol(obj);    
            obj.leakAmpHold = obj.customAmpHoldSignal.ampHoldSignal;
            obj.sealAmpHold = 0;            
        end
        
        function prepareRun(obj)
            % Call the base method.
            prepareRun@PetriProtocol(obj);
                        
            obj.customAmpHoldSignal.ampHoldSignal = obj.ampHoldSignal();
            
            % Set the amp hold signal.
            obj.applyAmpHoldSignal;
        end
        
        function ampHoldSignal = ampHoldSignal(obj)
            if strcmpi(obj.mode, 'leak')
                ampHoldSignal = obj.leakAmpHold;
            else
              ampHoldSignal = obj.sealAmpHold;
            end
        end
        
        function [stim, units] = generateStimulus(obj)
            % Convert time to sample points.
            prePts = round(obj.preTime / 1e3 * obj.sampleRate);
            stimPts = round(obj.stimTime / 1e3 * obj.sampleRate);
            tailPts = round(obj.tailTime / 1e3 * obj.sampleRate);
            
            [~, units, factor, ~] = obj.getHoldSignal;
            
            % Create pulse stimulus.           
            stim = ones(1, prePts + stimPts + tailPts) * obj.customAmpHoldSignal.ampHoldSignal;
            stim(prePts + 1:prePts + stimPts) = obj.pulseAmplitude + obj.customAmpHoldSignal.ampHoldSignal;
            
            stim = stim * factor;
            stim = stim * obj.amplifierScalingFactor;
        end
        
        function run(obj)
            run@PetriProtocol(obj);
        end
        
        function stimuli = sampleStimuli(obj)
            % return a sample stimulus for display in the edit parameters window.
            stimuli{1} = obj.generateStimulus();
        end
               
        function prepareEpoch(obj, epoch)            
            % With an indefinite epoch protocol we should not call the base class.
            %prepareEpoch@SymphonyProtocol(obj, epoch);
            
            % Set the epoch default background values for each device.
            devices = obj.rigConfig.devices();
            for i = 1:length(devices)
                device = devices{i};
                
                % Set the default epoch background to be the same as the device background.
                if ~isempty(device.OutputSampleRate)
                    epoch.setBackground(char(device.Name), device.Background.Quantity, device.Background.DisplayUnit);
                end
            end
                        
            % Add the amp pulse stimulus to the epoch.
            [stim, units] = obj.generateStimulus();            
            epoch.addStimulus(obj.amp, [obj.amp '_Stimulus'], stim, units, 'indefinite');
            
            [stim, units] = obj.generateTTLStimulus();    
            epoch.addStimulus('OscilloscopeTrigger', 'OscilloscopeTrigger_Stimulus', stim, units, 'indefinite');      
        end
        
        
        function keepQueuing = continueQueuing(obj)
            % Check the base class method to make sure the user hasn't paused or stopped the protocol.
            keepQueuing = continueQueuing@SymphonyProtocol(obj);
            
            % Queue only one indefinite epoch.
            if keepQueuing
                keepQueuing = obj.numEpochsQueued < 1;
            end            
        end
        
        
        function completeRun(obj)
            % Call the base method.
            completeRun@SymphonyProtocol(obj);
            
            if obj.alternateMode
                if strcmpi(obj.mode, 'seal')
                    obj.mode = 'leak';
                else
                    obj.mode = 'seal';
                end
            end
        end
        
    end
    
end

