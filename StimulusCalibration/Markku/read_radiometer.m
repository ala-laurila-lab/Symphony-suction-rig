%Code from Markku
function [out,out2] = read_radiometer(intens,ch,bg)

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

for ints=1:length(intens)

flash(1300:3000,ch+1)=intens(ints);
% if bg>0
% flash(1:end,3)=bg;
% end
s.queueOutputData(flash);


s.startBackground;

for i=1:36
    fprintf(s2,'R');
    out=fscanf(s2);
    for j=1:length(out)
        nums(j)=isempty(str2num(out(j)));
        inds = find(nums==0);      
    end
    out2(ints,i) = str2num(out(inds(1):inds(end)));
    if out(inds(1)-1)=='-'
        out2(ints,i)=out2(ints,i)*-1;
    end
    pause(0.1);
end

 if ints==length(intens)
  fclose(s2);
  delete(s2);
  clear('s2');
 end
end
 time=(linspace(0,20*pi,1000));
 ss1=sin(time*30)/2; ss2=sin(time*60)/4; ss=ss1+ss2;
 sound(ss(1:399),1200)