function config = symphonyrc(config)
    userDir = regexprep(userpath, ';', '');
    symphonyDir = 'C:\Program Files\Physion\Symphony - UI\Symphony';
    
    % Directory containing rig configurations.
    % Rig configuration .m files must be at the top level of this directory.
    config.rigConfigsDir = fullfile(userDir, 'Symphony - Util\Rig Configurations\List');
    
    % Directory containing protocols.
    % Each protocol .m file must be contained within a directory of the same name as the protocol class itself.
    config.protocolsDir = fullfile(userDir, 'Symphony - Util\Protocols\List');
    
    % Directory containing figure handlers (built-in figure handlers are always available).
    % Figure handler .m files must be at the top level of this directory.
    config.figureHandlersDir = '';
    
    % Text file specifying the source hierarchy.
    config.sourcesFile = fullfile(userDir, 'Symphony - Util\Source.txt');
    
    % Factories to define which DAQ controller and epoch persistor Symphony should use.
    % HekaDAQControllerFactory and EpochHDF5PersistorFactory are only supported on Windows.
    if ispc
        config.daqControllerFactory = HekaDAQControllerFactory();
        config.epochPersistorFactory = EpochHDF5PersistorFactory();
    else
        config.daqControllerFactory = SimulationDAQControllerFactory('LoopbackSimulation');
        config.epochPersistorFactory = EpochXMLPersistorFactory();
    end
    
    clear userDir;
end