%Code from Markku
Innts=logspace(-1.2,0.978,20);
pause(60)
s2 = serial('COM2','DataBits',8);fopen(s2);s2.Terminator='CR/LF';fprintf(s2,'AB');fprintf(s2,'GF');
pause(20)
fclose(s2); delete(s2);clear('s2');
pause(10)
[out1,Ch1_Intf] = read_radiometer(Innts,1,-0.05);
pause(10)
s2 = serial('COM2','DataBits',8);fopen(s2);s2.Terminator='CR/LF';fprintf(s2,'AB');fprintf(s2,'GF');
pause(20)
fclose(s2); delete(s2);clear('s2');
pause(10)
[out1,Ch2_ND1_Intf] = read_radiometer(Innts,2,-0.05);

 save('intf.mat','Ch2_ND1_Intf','Ch1_Intf')
% pause(29);
% 
% 
% 
% s2 = serial('COM2','DataBits',8);fopen(s2);s2.Terminator='CR/LF';fprintf(s2,'AB');fprintf(s2,'GF');
% pause(29);
% fclose(s2); delete(s2);clear('s2');
% pause(29);
% [out1bg0,out2bg06] = read_radiometer(Innts,1,0.6);
% 
% save('bg_endurance2.mat','out2bg06')
% pause(29);
% 
% 
% 
% s2 = serial('COM2','DataBits',8);fopen(s2);s2.Terminator='CR/LF';fprintf(s2,'AB');fprintf(s2,'GF');
% pause(29);
% fclose(s2); delete(s2);clear('s2');
% pause(29);
% [out1bg0,out2bg06z] = read_radiometer(Innts,1,0.6);
% 
% save('bg_endurance3.mat','out2bg06z')
% pause(29);



