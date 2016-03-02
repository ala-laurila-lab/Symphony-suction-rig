%photodiode protocol

led='blue';%'AND157HGP_green_soft';

durations   = [5 10 20];
intensities = [0 0.8 2 8]; %0 0.8 2 4 for other than green
for k=1:10
    for i=1:length(durations)
        for j=1:length(intensities)
            
               [out{i}(j,:,k), in{i}(j,:,k)] = measure_flashes(intensities(j), durations(i) );
        end
    end
    k
end

save(strcat(led,'.mat'), 'out', 'in')

clear out in