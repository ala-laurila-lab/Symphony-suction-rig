classdef PetriRigConfiguration < RigConfiguration
    %Peti Ala-Laurilas Lab Rig Configuration
    %   This is a class where all lab specific coding for our Rigs gets
    %   added
    properties
        externalApps
    end
    
    %%
    %   Methods dealing with external devices, custom components for
    %   Petri's Lab
    %%
    methods
        %%
        % This method should get called at the end of the
        % createDevices method, in the specific Rig Configuration file
        %%
        function createDevices(obj)
            obj.externalApps = SymphonyExternalApps();
            if obj.numAxoPatchDevices > 0 ... 
                    && obj.numMultiClampDevices > 0
                error('LED:AMPLIFIER:ERROR', 'Both the Axopatch Device and the Multiclamp device have been added to the rig config');
            elseif obj.numAxoPatchDevices < 1 ... 
                    && obj.numMultiClampDevices < 1
                error('LED:AMPLIFIER:ERROR', 'Neither the Axopatch Device or the Multiclamp device have been added to the rig config');
            end
        end
        
        % A function to determine the mode of the Axopatch device
        % With the Axopatch, we need to query the machine every time as we
        % can not record a change in the reading.
        function mode = getAmpMode(obj, amp)
            mode = '';
            
            if obj.isAxopatchDevice(amp)
                outputArray = obj.getSingleReadingFromDevice(amp);
                if ~isempty(outputArray)
                    modeNum = outputArray{3};
                    mode = Symphony.ExternalDevices.AxopatchInputConversion.getAxopatchMode(modeNum);
                else
                    mode = '';
                end
            elseif obj.isMultiClampDevice(amp)
                mode = obj.multiClampMode(amp);
            end
        end
        
        %%
        %   A function to close all devices created
        %   And remove the function Listeners
        %%        
        function close(obj)
            close@RigConfiguration(obj);
            obj.externalApps.closeApps;
            obj.externalApps.removeListeners;
            delete(obj.externalApps);
        end   
    end

    %%
    %   Methods for use with the original rigConfig file
    %%    
    methods
        
        %%
        %   A simple device test (Devices Attached to the HEKA board)
        %%        
        function isDevice = isDevice(obj, deviceName)
            isDevice = false;
            
            if ~isempty(obj.deviceWithName(deviceName))
                isDevice = true;
            end
        end    
        
        
        % testing to see if the amplifier attached is an axopatch device
        function isAxopatchDevice = isAxopatchDevice(obj, deviceName)
            isAxopatchDevice = false;
            
            if ~isempty(obj.deviceWithName(deviceName))
                aPD = obj.axoPatchDevices;
                
                for i = 1:length(aPD)
                    if strcmp(char(deviceName), char(aPD{i}.Name))
                        isAxopatchDevice = true;
                        break;
                    end
                end
            end
        end    
        
        % Testing to see if the device attached is a multiclamp device
        function isMultiClampDevice = isMultiClampDevice(obj, deviceName)
            isMultiClampDevice = false;
            
            if ~isempty(obj.deviceWithName(deviceName))
                mCD = obj.multiClampDevices;
                
                for i = 1:length(mCD)
                    if strcmp(char(deviceName), char(mCD{i}.Name))
                        isMultiClampDevice = true;
                        break;
                    end
                end                
            end
        end           
    end
        
end

