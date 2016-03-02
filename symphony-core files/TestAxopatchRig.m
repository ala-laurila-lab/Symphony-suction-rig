classdef TestAxopatchRig < RigConfiguration
    
    properties (Constant)
        displayName = 'TestRig'
    end
    
    methods  
        %%function to close the Heka Device
        function closeHEKA(obj)
            if isa(obj.controller.DAQController, 'Heka.HekaDAQController')
                obj.controller.DAQController.CloseHardware();
            end   
        end
        
        %%Functions in the Base rig configurations
        function createDevices(obj)
            obj.addAxoPatchDevice('Amplifier_Ch1', 'ANALOG_IN.1', 'ANALOG_IN.2', 'ANALOG_IN.3', 'ANALOG_IN.4');
        end 
        
        %% Programming for RigConfig
        function addAxoPatchDevice(obj, deviceName, gain, frequency, mode, cellCapacitence)
            import Symphony.Core.*;
            import Symphony.ExternalDevices.*;    

            serialNumber = obj.getDeviceSerialNumber('Axopatch_serialNumber');

            coalescingStreams = NET.createArray('System.String', 4);
            coalescingStreams(1) = gain;
            coalescingStreams(2) = frequency;
            coalescingStreams(3) = mode;
            coalescingStreams(4) = cellCapacitence;
            
            units = 'V';
            
            aP = AxopatchDevice(serialNumber, obj.controller, Measurement(double(0), units), coalescingStreams);
            aP.Name = deviceName;
            aP.Clock = obj.controller.DAQController;

            % Bind the streams.
            obj.addCoalescingStreams(aP, coalescingStreams);    
            aP.CoalescingInputStreams();
            %obj.closeHEKA;
        end

        function sN = getDeviceSerialNumber(obj, preferenceKey) %#ok<INUSL>
            sN = [];
            
            if ispref('Symphony', preferenceKey)
                sN = getpref('Symphony', preferenceKey, '');
            end

            if isempty(sN)
                answer = inputdlg({'Enter the serial number of the MultiClamp:'}, 'Symphony', 1, {''});
                if isempty(answer)
                    error('Symphony:MultiClamp:NoSerialNumber', 'Cannot create a MultiClamp device without a serial number');
                else
                    sN = uint32(str2double(answer{1}));
                    setpref('Symphony', preferenceKey, sN);
                end
            end    
        end

        function addCoalescingStreams(obj, device, inputStreams)
            for i=1:inputStreams.Length
                stream = obj.streamWithName(inputStreams(i), false);
                device.BindStream(stream);
            end
        end
        
        %% In RigConfig
        function stream = streamWithName(obj, streamName, isOutput)
            import Symphony.Core.*;

            if isa(obj.controller.DAQController, 'Heka.HekaDAQController')     % TODO: or has method 'GetStream'?
                stream = obj.controller.DAQController.GetStream(streamName);
            else
                if isOutput
                    stream = DAQOutputStream(streamName);
                else
                    stream = DAQInputStream(streamName);
                end
                stream.SampleRate = Measurement(obj.sampleRate, 'Hz');
                stream.MeasurementConversionTarget = 'V';
                stream.Clock = obj.controller.DAQController;
                obj.controller.DAQController.AddStream(stream);
            end
        end        
    end
end