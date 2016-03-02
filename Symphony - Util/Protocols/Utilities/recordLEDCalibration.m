       %% Calibration Recording
       % This function is to read the output of the optometer and record
       % the value in the logging application. (In the edit parameters you need to select the range in which you are working eg. pico, nano, or micro)
       % The raw output is stored in the H5 file, so this is just for the
       % notes file.
       function optometerReading = recordLEDCalibration(epoch, lightRange)
            recordedOptometer = epoch.response('Optometer');
            outputRange = 4;
            average = 0;
            
            samples = length(recordedOptometer); 
            for i = 1:samples
                average = average + recordedOptometer(i);
            end
            
            if strcmp(lightRange,'pico')
                factor = 4;
            elseif strcmp(lightRange,'micro')
                factor = 2;
            elseif strcmp(lightRange,'nano')
                factor = 3;
            else
                factor = 0;
            end
            
            average = average/samples;
            optometerReading = [num2str((1 - (outputRange - average)) * 10^factor) ' ' lightRange];
       end