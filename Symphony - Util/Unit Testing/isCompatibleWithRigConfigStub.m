function isCompatibleWithRigConfigStub( configClassName ,  protocolClassName)
    if verLessThan('matlab', '7.12')
        error('Symphony requires MATLAB 7.12.0 (R2011a) or later');
    end

    % Load the Symphony .NET framework
    addSymphonyFramework();
    
    constructor = str2func(configClassName);
    rigConfig = constructor();   
    
    constructor = str2func(protocolClassName);
    newProtocol = constructor();

    [ rigConfigProtocolCompatiblity , rigConfigCompatiblityMsg ] = isCompatibleWithRigConfigCopy(rigConfig, newProtocol);
    
    if ~isempty(rigConfig)
        rigConfig.close();
    end

    disp(rigConfigProtocolCompatiblity);
    disp(rigConfigCompatiblityMsg);
end


%%
% @param rigConfig: The Rig Configuration that will be tested against the protocol
%
% @output c: A Boolean that returns true if the Rig and Protocol are compatible
% @output msg: Returns an Error msg if the Rig and Protocol are not compatible. This is the error message that will be displayed in the GUI.
%
% Note: Override this method if you would like to alter the compatability check between the Rig and the Protocol
function [ c , msg ] = isCompatibleWithRigConfigCopy(rigConfig,newProtocol)
    c = true;
    msg = '';

    deviceNames = newProtocol.requiredDeviceNames();
    for i = 1:length(deviceNames)
        device = rigConfig.deviceWithName(deviceNames{i});
        if isempty(device)
            c = false;
            msg = [ 'The protocol cannot be run because there is no ''' deviceNames{i} ''' device.' ];
            break;
        end                
    end
end