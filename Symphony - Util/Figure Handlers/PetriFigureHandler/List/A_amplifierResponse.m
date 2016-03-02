classdef A_amplifierResponse < handle
    % AMPLIFIERRESPONSE
    %   This gets the response from the amplifier and graphs it
    
    %%Required Properties
    % properties that are required by all responses. It will throw an error without these.
    % These are properties that you can modify.    
    properties
        lineColor = 'green' % you can use [0 0 0] notation as well
        showResponse = true % if True the response will graph automatically
        caption = 'Amplifier Response' % The name listed on the plot GUI
        canSave = false %When Hold graph is pressed in the GUI, do you want this plot to remain?
        multipleGraphsCanHold = true % do you want this graph to be held through iterations?
        lastPlot %if can save is true, this is the variable where you have to store the graph you want saved
%       for example  
%             if obj.canSave
%                 obj.lastPlot.XData = (1:numel(responseData))/sampleRate;
%                 obj.lastPlot.YData = responseData;
%             end
    end
    
     %% Required Methods
    methods
        function obj = A_amplifierResponse
        end        
        
        % This is a required function, without it Matlab will through an
        % error. This is where you clean up any properties etc... before a
        % new run
        function clearFigure(obj) %#ok<MANU>
        end       
        
        % This is where you put the data you want to graph.
        %   XData = The data for the x-axis
        %   YData = The data for the y-axis
        % eg. the parent function graphs the responses plot(XData,YData);
        %
        % Note: If wither value is empty, it will not graph the function.
        function [XData , YData] = response(obj, protocolPlugin, epoch, amp)  %#ok<INUSL>
            if isempty(amp)
                % Use the first device response found if no device name is specified.
                [responseData, sampleRate, ~] = epoch.response();
            else
                [responseData, sampleRate, ~] = epoch.response(amp);
            end            
            
            XData = (1:numel(responseData))/sampleRate;
            YData = responseData;
        end
    end
    
end

