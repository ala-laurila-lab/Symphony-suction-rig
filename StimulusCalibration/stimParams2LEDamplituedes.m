function [V_set, V_back, msg, problem] = stimParams2LEDamplituedes(s,n_rep)
%% figure out which channel
V_back = str2double(s.BackgroundLED);%in mV
%% Get background voltage and calculate voltage vector
V_single = str2double(s.InitialPulseAmplitude)*str2double(s.ScalingFactor).^[0:str2double(s.NumberOfIntensities)-1]+V_back;
V_set = repmat(V_single,1, str2double(s.NumberOfRepeats));
%% error check
if n_rep < length(V_set)
    msg = sprintf(['# of saved epochs (%d) is smaller than the # of expected ',...
        'epochs (%d) from stimulus parameters!'],n_rep, length(V_set));
    problem = true;
elseif n_rep > length(V_set)
    msg = sprintf(['# of saved epochs (%d) is larger than the # of expected ',...
        'epochs (%d) from stimulus parameters, which is very strange!!!'],...
        n_rep, length(V_set));
    problem = true;
else
    msg = 'OK';
    problem = false;
end