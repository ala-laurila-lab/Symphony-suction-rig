classdef PrePointsFigureHandler < handle
    
    properties (Constant)
        figureType = 'PrePoints'
        varianceColor = 'yellow'
        meanColor = 'white'
        axesBackgroundColor = 'black'
        BackgroundColor = [0.35 0.35 0.35];
        pointSize = 50
        lineWidth = 1
    end
    
    
    properties
        updateCallback
        epochNumber = 0
        deviceName      
        
        %line drawing properties
        prevMeanY
        prevVarianceY
        
        varAxes
        meanAxes
        
        protocolPlugin
        
        gui
    end
    
    
    methods
        
        function obj = PrePointsFigureHandler(protocol, deviceName)
            obj.protocolPlugin = protocol;
            obj.deviceName = deviceName;
            
            %Construcing the GUI
            obj.gui = figure(...
                'Units', 'points', ...
                'Name', 'PrePoints Mean/Var', ...
                'Menubar', 'figure', ...
                'NumberTitle', 'off', ...
                'Tag', 'figure', ...
                'resize', 'on', ...
                'Color', obj.BackgroundColor, ...
                'CloseRequestFcn', '' ...
                );            
            
            
%             obj.varAxes = axes('Parent',obj.gui,'Color',obj.axesBackgroundColor);
%             set(obj.varAxes,'XColor',obj.varianceColor,'YColor',obj.varianceColor)
            obj.varAxes = axes('Parent',obj.gui,'XAxisLocation','bottom', 'YAxisLocation','left','YColor',obj.varianceColor,'XColor',obj.varianceColor);
            ylabel(obj.varAxes, 'Variance');
            axis(obj.varAxes,'tight');
            
            obj.meanAxes = axes('Parent',obj.gui,'XAxisLocation','top', 'YAxisLocation','right','YColor',obj.meanColor,'XColor',obj.meanColor);
            ylabel(obj.meanAxes, 'Mean');
            axis(obj.meanAxes,'tight');
            
            set(obj.varAxes,'Color',obj.axesBackgroundColor);
            set(obj.meanAxes,'Color','none');
            
        end
        
       function close(obj)
           delete(obj.gui);
           delete(obj);
       end
        
        function clearFigure(obj)
            obj.epochNumber = 0;
            obj.prevMeanY = 0;
            obj.prevVarianceY = 0;
            cla(obj.meanAxes);
            cla(obj.varAxes);
        end
        
        function handleEpoch(obj, epoch)
            obj.epochNumber = obj.epochNumber + 1;
            if isempty(obj.deviceName)
                % Use the first device response found if no device name is specified.
                [responseData, ~, ~] = epoch.response();
            else
                [responseData, ~, ~] = epoch.response(obj.deviceName);
            end
            
            prePts = round(epoch.parameters.preTime / 1e3 * epoch.parameters.sampleRate);
            preResponsePoints = responseData(1:prePts);
%             
            prePointMean = mean(preResponsePoints);
            prePointVariance = var(preResponsePoints);
            
            axis(obj.meanAxes,'tight');
            hold(obj.meanAxes, 'all');
            
            axis(obj.varAxes,'tight');
            hold(obj.varAxes, 'all');
            
% 
            scatter(obj.meanAxes,obj.epochNumber, prePointMean, obj.pointSize, obj.meanColor, 'fill');
            scatter(obj.varAxes,obj.epochNumber, prePointVariance, obj.pointSize, obj.varianceColor, 'fill');

            if obj.epochNumber > 1
                plot(obj.meanAxes,[(obj.epochNumber-1) obj.epochNumber],[obj.prevMeanY prePointMean],'Color',obj.meanColor, 'LineWidth',obj.lineWidth,'DisplayName','Prepoint Mean - Line');              
                plot(obj.varAxes,[(obj.epochNumber-1) obj.epochNumber],[obj.prevVarianceY prePointVariance],'Color',obj.varianceColor, 'LineWidth',obj.lineWidth,'DisplayName','Prepoint Variance - Line');
            end

            set(obj.varAxes,'Color',obj.axesBackgroundColor);
            set(obj.meanAxes,'Color','none');
            
            hold(obj.varAxes, 'off');
            hold(obj.meanAxes, 'off');
            
            obj.prevMeanY = prePointMean;
            obj.prevVarianceY = prePointVariance;
        end
        
    end
    
end
