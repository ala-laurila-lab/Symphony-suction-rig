classdef TwoChannelMulticlamp < PetriRigConfiguration
    
    properties (Constant)
        displayName = '2 Channel Multiclamp'
    end
    
    methods   
        %% Note: The names of the devices are important, the can not be changed!
        function createDevices(obj)
            %%Multiclamp Devices (DO NOT CHANGE THE NAMES!!!!!)
            obj.addMultiClampDevice('Amplifier_Ch1', 1, 'ANALOG_OUT.0', 'ANALOG_IN.0');
            obj.addMultiClampDevice('Amplifier_Ch2', 2, 'ANALOG_OUT.1', 'ANALOG_IN.1'); % If adding a 3rd LED Channel, this line needs to be commented out 

            %% LED Devices
            obj.addDevice('Ch1', 'ANALOG_OUT.2', '');
            obj.addDevice('Ch2', 'ANALOG_OUT.3', '');
%             obj.addDevice('Ch3', 'ANALOG_OUT.1', '');   % If adding a 3rd LED Channel, this line needs to be uncommented & vice versa
            
            %% Adding the heat controller
            obj.addDevice('HeatController', '', 'ANALOG_IN.2');

            %% Adding the Optometer
%             obj.addDevice('Optometer', '', 'ANALOG_IN.3'); %Uncomment if you are using the optometer, make sure the correcct channel is being used
            
            %% Adding the Rig Switches
			obj.addDevice('RigSwitches','', 'DIGITAL_IN.0');  % input only
            
            %% Adding the TTL Trigger
            obj.addDevice('OscilloscopeTrigger', 'DIGITAL_OUT.1', '');
            
            %% Adding the external apps (not connected to the Heka Board, ie. notepad, solution controller etc...)
            createDevices@PetriRigConfiguration(obj);
            obj.createExternalApps;
        end 
        
        %% For PetriRig
        function createExternalApps(obj)
            % Adding the NotesFile application
            obj.externalApps.addCustomApp('notesFile', {{ 'rigConfig' , obj.displayName }});
            
            % Adding the Solution Controller
             obj.externalApps.addCustomApp('solutionController', {{'channels',5},{'port',6}});
             obj.externalApps.addCustomAppListener('solutionController' , 'appStatus' , 'update' , 'PostSet');            
        end

        function close(obj)
            close@PetriRigConfiguration(obj);
        end
    end
end