classdef ExternalApps < handle
    
    properties
        %GUI
        gui
        color
        guiObjects
        
        % listeners
        appListeners
    end
    
    %%
    %   eventData = The information passea from the listener class
    %   var = the variable that is being listenea to
    %   updateFunction = the function to be callea with the update
    %%       
    methods (Static)
        function updateOnChange( ~ , eventData , var , updateFunction )
            h = eventData.AffectedObject;
            if(~strcmp(h.( var ),''))
                h.( updateFunction );
            end
        end     
    end
    
    %%
    methods
        function ea = ExternalApps( varargin )
            ea = ea@handle();
            ea.guiObjects = struct();
            ea.appListeners = struct();
        end

        %%
        %   var = the variable that you are listening to        
        %   updateFunction = the function to call on variable change
        %   when = the timeing of the trigger
        %%        
        function addCustomAppListener(ea, var , updateFunction , when )
            changeVarCount = length(fieldnames(ea.appListeners)) + 1;
            appListener = ['function' int2str(changeVarCount)];
            
            ea.appListeners.( appListener ) = struct();
            ea.appListeners.( appListener ).var = var;
            ea.appListeners.( appListener ).function = updateFunction;
            
            changeFunction =  @( metaProp , eventData )ea.updateOnChange( metaProp , eventData , var , updateFunction );
            addlistener( ea , var , when , changeFunction );            
        end
 
        %%
        %   A function to delete the gui
        %%         
        function closeApp(ea)
            if isvalid(ea)
                delete(ea.gui);
            end
        end
        
    end
    
end