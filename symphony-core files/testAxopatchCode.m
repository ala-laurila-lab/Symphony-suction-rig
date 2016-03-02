%%Local Configuration
%     obj.addAxoPatchDevice('Amplifier_Ch1', ...
%                              'ANALOG_IN.1', 'ANALOG_IN.2', ...
%                              'ANALOG_IN.3', 'ANALOG_IN.4');


%% RigConfiguration Code

classdef testAxopatchCode < handle
    
    properties
        rigConfig
        daqControllerFactory
        symphonyConfig
    end
    
    methods
        function obj = testAxopatchCode()           
            % Load the Symphony framework.
            obj.loadAssemblies;
            obj.init;
        end
        
        function loadAssemblies(obj)
            obj.addSymphonyNETAssembly('Symphony.Core');
            obj.addSymphonyNETAssembly('Symphony.ExternalDevices');                    
        end

        function addSymphonyNETAssembly(obj, assembly) %#ok<INUSL>
            isWin64bit = strcmpi(getenv('PROCESSOR_ARCHITEW6432'), 'amd64') || strcmpi(getenv('PROCESSOR_ARCHITECTURE'), 'amd64');

            if isWin64bit
                symphonyPath = fullfile(getenv('PROGRAMFILES(x86)'), 'Physion\Symphony\bin');
            else
                symphonyPath = fullfile(getenv('PROGRAMFILES'), 'Physion\Symphony\bin');
            end

            NET.addAssembly(fullfile(symphonyPath, [assembly '.dll']));
        end     
        
        function init(obj)
            obj.symphonyConfig = obj.getSymphonyConfig();
            obj.daqControllerFactory = obj.symphonyConfig.daqControllerFactory;
            
            obj.rigConfig = TestAxopatchRig();
            obj.rigConfig.init(obj.symphonyConfig, obj.daqControllerFactory);
        end
        
        function symphonyConfig = getSymphonyConfig(obj) %#ok<MANU>
            symphonyConfig = SymphonyConfiguration();
            symphonyConfig = symphonyrc(symphonyConfig);
            up = userpath;
            up = regexprep(up, '[;:]$', ''); % Remove semicolon/colon at end of user path
            if exist(fullfile(up, 'symphonyrc.m'), 'file')
                rc = funcAtPath('symphonyrc', up);
                symphonyConfig = rc(symphonyConfig);
            end        
        end
    end     
end        
        