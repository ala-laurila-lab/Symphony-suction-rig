% To use the Digital Out Channels, All ANALOG_OUT outputs need to be added
% to the configuration, even if they are unused.
% For Example: 
%             obj.addDevice('Ch1', 'ANALOG_OUT.3', '');
%             obj.addDevice('Ch2', 'ANALOG_OUT.2', '');   % output only
%             obj.addDevice('Ch3', 'ANALOG_OUT.0', '');   % output only
%             obj.addAxoPatchDevice('Amplifier_Ch1', 'ANALOG_OUT.1', 'ANALOG_IN.0', 'ANALOG_IN.1', 'ANALOG_IN.2',  'ANALOG_IN.3', '' ,'');

classdef Axopatch < PetriRigConfiguration
    
    properties (Constant)
        displayName = 'Axopatch'
    end
    
    methods         
        %%Functions in the Base rig configurations
        function createDevices(obj)
            obj.addAxoPatchDevice('Amplifier_Ch1', 'ANALOG_OUT.0', 'ANALOG_IN.0', 'ANALOG_IN.1', 'ANALOG_IN.2',  'ANALOG_IN.3', '' ,'');
            obj.addDevice('Ch1', 'ANALOG_OUT.1', '');
            obj.addDevice('Ch2', 'ANALOG_OUT.2', '');   % output only
%             obj.addDevice('Ch3', 'ANALOG_OUT.0', '');   % output only

%           obj.addDevice('Ch1AORB', 'DIGITAL_OUT.1', '');
%           obj.addDevice('Ch2AORB', 'DIGITAL_OUT.1', '');   % output only
%           obj.addDevice('Ch3AORB', 'DIGITAL_OUT.1', '');   % output only
            
            obj.addDevice('OscilloscopeTrigger', 'DIGITAL_OUT.1', '');
            
			obj.addDevice('RigSwitches','', 'DIGITAL_IN.0');
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