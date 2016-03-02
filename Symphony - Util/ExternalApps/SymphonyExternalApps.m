classdef SymphonyExternalApps < handle
    properties
        availableApps;
        addedCustomApps;
    end

    %%
    %   eventData = The information passed from the listener class
    %   var = the variable that is being listened to
    %   updateFunction = the function to be called with the update
    %%       
    methods (Static)
        function appOnChange( ~ , eventData , var , updateFunction )
            h = eventData.AffectedObject;
            if(~strcmp(h.( var ),''))
                h.( updateFunction );
            end
        end           
    end
    
    %%
    methods
        function cd = SymphonyExternalApps()
            cd.addedCustomApps = struct();
            cd.generateAppList;
        end
                
        %%
        %   A method to add a custom apps Listener
        %
        %   appName = the name of the objects class
        %   var = the variable that you are listening to        
        %   updateFunction = the function to call on variable change
        %   when = the timeing of the trigger
        %%
        function addCustomAppListener(cd, appName , var , updateFunction , when )
             if isfield(cd.addedCustomApps,appName)
                changeVarCount = length(fieldnames(cd.addedCustomApps.(appName).listener)) + 1;
                
                appListener = ['function' int2str(changeVarCount)];
                
                cd.addedCustomApps.(appName).listener.( appListener ) = struct();
                cd.addedCustomApps.(appName).listener.( appListener ).var = var;
                cd.addedCustomApps.(appName).listener.( appListener ).function = updateFunction;
                
                cd.addedCustomApps.(appName).listener.( appListener ).changeFunction = ...
                    @( metaProp , eventData )cd.appOnChange( metaProp , eventData , var , updateFunction );
                
                cd.addedCustomApps.(appName).listener.( appListener ).listener = ...
                    addlistener( cd.addedCustomApps.(appName).constructor , var, when , cd.addedCustomApps.(appName).listener.( appListener ).changeFunction);
             end
        end
        
        %%
        %   A method to add a custom app
        %
        %   appName = the name of the objects class
        %   parameters = A cell of parameters to pass to the object
        %           eg: - {{'port',8} , {'channels',5}}
        %               - {8,5}
        %%        
        function addCustomApp(cd, appName, parameters)
            constructor = str2func(appName);
            cd.addedCustomApps.(appName) = struct();
            
            if ~isempty(parameters) && iscell(parameters)
                cd.addedCustomApps.(appName).constructor = constructor(parameters);
            else
                cd.addedCustomApps.(appName).constructor = constructor();
            end 
            
            cd.addedCustomApps.(appName).listener = struct();
        end
        
        %% Helper Functions
        %%
        %   A method to close all external apps
        %%        
        function closeApps(cd)
             fields = fieldnames(cd.addedCustomApps);
             for i=1:numel(fields)
                 if cd.isValidApp( fields{i} )
                     cd.addedCustomApps.( fields{i} ).constructor.closeApp;
                     delete(cd.addedCustomApps.( fields{i} ).constructor);
                 end
             end        
        end
        %%
        %   A method to close an external app
        %
        %   appName = the name of the objects class that you are closing        
        %%        
        function closeApp(cd, appName)
             if cd.isValidApp( appName )
                 cd.addedCustomApps.( appName ).constructor.closeApp;
                 delete(cd.addedCustomApps.( appName ).constructor);
             end
        end        
        
        %% Helper Functions
        %%
        %   A method to close all listeners
        %%           
        function removeListeners(cd)
            fields = fieldnames(cd.addedCustomApps);
            for i=1:numel(fields)
                appName = fields{i};
                 for j=1:length(fieldnames(cd.addedCustomApps.(appName).listener))
                    appListener = ['function' int2str(j)];
                    cd.addedCustomApps.(appName).listener.( appListener ).listener = event.listener.empty;
                 end
            end
        end
            
        %%
        %   A method to generate a app list of all available apps
        %
        %   appName = the name of the objects class that you are testing
        %%          
        function generateAppList(cd)
            cd.availableApps = struct();
            appPath = fileparts(mfilename('fullpath'));
            
            
            appList = dir(fullfile(appPath,'List'));
            appListLength = length(appList);
            
            if appListLength > 2
                for d = 3:length(appList)
                    name = appList(d).name;
                    extension = '.m';
                    
                    if strfind(name, extension) 
                        name = strrep(name, extension, '');
                        cd.availableApps.( name ) = 1;
                    end
                end
            end
        end
        
        %%
        %   A method to return the requested app
        %
        %   appName = the name of the objects class that you are testing
        %%   
        function app = getApp(cd, appName)
            try
                app = cd.addedCustomApps.(appName).constructor;
            catch ME %#ok<NASGU>
                app = [];
            end
        end
        
        %%
        %   A method to return the requested app and listeners
        %
        %   appName = the name of the objects class that you are testing
        %%           
        function appL = getAppAndListeners(cd, appName)
            try
                appL = cd.addedCustomApps.(appName);
            catch ME %#ok<NASGU>
                appL = [];
            end
        end
        
        %%
        %   A method to check if the app has been added
        %
        %   appName = the name of the objects class that you are testing
        %%           
        function isAvailableApp = isAvailableApp(cd, appName)
            isAvailableApp = false;
            
            if cd.availableApps.( appName )
                isAvailableApp = true;
            end
        end    
        
        %%
        %   A method to check if the app has been added and it has not
        %   been deleted
        %
        %   appName = the name of the objects class that you are testing
        %%          
        function isValidApp = isValidApp(cd, appName)
            isValidApp = false;
            
            try
                 if cd.isAvailableApp( appName ) && ...
                         isvalid(cd.addedCustomApps.( appName ).constructor)
                    isValidApp = true;
                 end   
            catch ME %#ok<NASGU>
                isValidApp = false;
            end
        end
    end
end