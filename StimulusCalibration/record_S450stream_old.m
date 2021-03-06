clear; close all;
%% setings
com_port = 'COM9';%Check with device manager
save_root = 'C:\Users\Public\Documents\StimulusCalibration';
delete(instrfind('Port',com_port));
%% input dialog
prompt = {'Gain','RecordingTime',...
    'Protocol','Channel','InitialPulseAmplitude','ScalingFactor',...
    'NumberOfIntensities','NumberOfRepeats',...
    'BackgroundLED',...
    'PreTime','StimTime','TailTime',...
    'NDF1','NDF2','NDF3'};
dlg_title = 'Input';
num_lines = 1;
def = {'g','30',...
        'LEDFactorPulse','2','100','1.291',...
        '11','15',...
        '-20',...
        '500','20','1700',...
        '2B','0.5A',''};
answer = inputdlg(prompt,dlg_title,num_lines,def);
%fname = answer{1};
gain = answer{1};
t_rec = str2double(answer{2});
stimParameters = cell2struct(answer',prompt,2);
%% open COM port
s = serial(com_port,'DataBits',8);
s.Terminator='CR/LF';
fopen(s);
%% set gain
str_gain = [];
while isempty(strfind(str_gain,['GAIN_',lower(gain)]))
    fprintf(s,['G',upper(gain)]);
    %while s.BytesAvailable == 0
        pause(0.1);
    %end
    while s.BytesAvailable > 0
        str_gain = [str_gain fscanf(s)]
    end
end
%% Ready to record
ButtonName = questdlg(sprintf('Gain: %s. Hit OK to start recording',str_gain), ...
                         'Start recording?', ...
                         'OK', 'Cancel','OK');
if ~strcmp(ButtonName,'OK')
    return;
end
%% Start continuous recording
bytes_init = s.ValuesReceived;
fprintf(s,'stream');
display('recording started')
data = {}; n=1; prev = 0;
while (s.ValuesReceived - bytes_init) < 53*8*t_rec
   if s.BytesAvailable > 0
      data{n,1} = fgetl(s);
      n = n+1;
   end
end
fprintf(s,'s');
fclose(s);
display('recording stopped');
%% plot results
plot_S450stream(data, str_gain, gain);
%% Put some setting back???
%% Put gain back to auto?
%% Time constant??

%% Save file
[y,m,d]=datevec(date);
if m<10
    m = sprintf('0%d',m);
else
    m = sprintf('%d',m);
end
if d<10
    d = sprintf('0%d',d);
else
    d = sprintf('%d',d);
end
dir_date = sprintf('%d_%s%s',y,m,d);
save_dir = fullfile(save_root,dir_date);
if ~exist(save_dir,'file')
   mkdir(save_dir); 
end
cd(save_dir);
fname_def = sprintf('SerialOut_%s_Ch%s_%sms_%smV_%sInt_%sRep_Gain%s',...
                    stimParameters.Protocol,...
                    stimParameters.Channel,... 
                    stimParameters.StimTime,... 
                    stimParameters.InitialPulseAmplitude,...
                    stimParameters.NumberOfIntensities,...
                    stimParameters.NumberOfRepeats,...
                    upper(stimParameters.Gain));
f_num = 1;
sname = sprintf('%s_%d.mat',fname_def,f_num);
while exist(sname,'file')
   f_num = f_num+1;
   sname = sprintf('%s_%d.mat',fname_def,f_num);
end
[filename, pathname] = uiputfile(sname, 'Save as');
if filename ~=0
    save(fullfile(pathname,filename),'data','stimParameters');
    %uiwait(msgbox(sprintf('Saved as %s in %s',filename, pathname),'Title','modal'));
else
    %uiwait(msgbox(sprintf('No file is saved'),'Title','modal'));
    
end

%% Note for future
% % for improvement, one can add start & stop button-GUI like below
% g=0;
% FH = figure();
% b = uicontrol('style','push','string','g++','callback','g=g+1');
% while g < 3
%     fprintf(1,'g = %i\n',g);
%     drawnow
% end
