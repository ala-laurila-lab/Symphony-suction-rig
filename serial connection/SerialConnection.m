%%
javaaddpath('C:\Users\local_admin\Documents\MATLAB\serial connection\ComPortConnector.jar');
import com.comportconnector.lib.*;

%% Solution Controller

%Opening the Connection
c = Connector('COM7');
c.connect(); 

%Saying that I want to send and recieve data (You dont have to both send and recieve data)
rd = RecieveData(c.getIn()); 			
s = SendData(c.getOut());

%Opening/closing the channels
s.sendString('V,1,1');  % Turning on Channel 1

% Requesting from the Device what channels are open & closed
s.sendString('S');
rd.submitTask()
 
%Closing the connection
c.closeAll();
rd.closeThreadPool();
 
% Clearing all variables
clear s c rd;
 
 
 %% LED Controller
 
 %Opening the Connection
 c = Connector('COM7');
 c.connect();

%Saying that I want to send and recieve data (You dont have to both send and recieve data)
 rd = RecieveData(c.getIn());			
 s = SendData(c.getOut());
 
%Turning on the LED plugged into channel 1 port 2
 s.sendString('L,1,2,4095,1024,0');
 
 % Requesting from the Device the status of channel 1
 s.sendString('R,1');
 rd.submitTask()
  
%Closing the connection
 c.closeAll();
 rd.closeThreadPool();
 
 % Clearing all variables
 clear s c rd;
 
 %% Optomketer
 %Opening the Connection
 c = Connector('COM5');
 c.connect();

%Saying that I want to send and recieve data (You dont have to both send and recieve data)
 rd = RecieveData(c.getIn());			
 s = SendData(c.getOut());
 
%Turning on the LED plugged into channel 1 port 2
s.sendString('AOS');

 %Closing the connection
 c.closeAll();
 rd.closeThreadPool();
 
%% Optomketer
opt = struct();
opt.port = 'COM5';

opt.conn = serial(opt.port);
opt.conn.BaudRate = 9600;
opt.conn.ReadAsyncMode = 'continuous';
%opt.conn.Terminator = 'LF/CR';
opt.conn.Terminator = 'CR/LF';

fopen(opt.conn);
%%
fprintf(opt.conn,'AOO0.0');
response = fscanf(opt.conn)

%%
fprintf(opt.conn,'AOM0.0');
response = fscanf(opt.conn)

%%
fprintf(opt.conn,'W');
response = fscanf(opt.conn)

%%
fprintf(opt.conn,'AOS');
response = fscanf(opt.conn)

%%
fclose(opt.conn);