       %% Heat Recording
       % This is to display the temperature from the heat controller in the
       % notes file. (It returns the average)
       function average = recordSolutionTemp(epoch)
            recordedTemp = epoch.response('HeatController');
            samples = length(recordedTemp); 
            total = 0;
            
            for i = 1:samples
                total = total + recordedTemp(i);
            end
            
            average = 10 * (total/samples);
            m = 3; % Number of significant decimals, default to 3
            
            if average < 1
                m = 1;
            elseif average < 10
                m = 2;
            elseif average < 100
                m = 3;
            elseif average < 1000
                m = 4;
            end
            
             k = floor(log10(abs(average)))-m+1;
             average = round(average/10^k)*10^k;
       end