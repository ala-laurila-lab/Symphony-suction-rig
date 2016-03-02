function [out,out2] = read_radiometer_dura(intens,ch,bg)

%Radiometer in serial port
s2 = serial('COM2','DataBits',8);
fopen(s2);
s2.Terminator='CR/LF';
%fprintf(s2,'GG');

%DAQ
s = daq.createSession('ni');
s.addAnalogOutputChannel('Dev1',0,'Voltage');
s.addAnalogOutputChannel('Dev1',1,'Voltage');
s.addAnalogOutputChannel('Dev1',2,'Voltage');
flash=-0.05*ones(4000,3);



flash(1:end,ch+1)=intens;
if bg>0
flash(1:end,3)=bg;
end
%s.queueOutputData(flash);


%s.startBackground;

for i=1:30
    fprintf(s2,'R');
    out=fscanf(s2);
    for j=1:length(out)
        nums(j)=isempty(str2num(out(j)));
        inds = find(nums==0);      
    end
    out2(:,i) = str2num(out(inds(1):inds(end)));
    pause(10);
end
%  time=(linspace(0,20*pi,100));
%  s1=sin(time*30)/2; s2=sin(time*60)/4; ss=s1+s2;
%  sound(ss,1200)

 fclose(s2);
 delete(s2);
 clear('s2');


flash=-0.05*ones(4000,3);
s.queueOutputData(flash);
s.startForeground;

