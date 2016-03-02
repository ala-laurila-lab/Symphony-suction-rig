

s2 = serial('COM2','DataBits',8);fopen(s2);s2.Terminator='CR/LF';


'Turn off display and hit any key'
pause()

fprintf(s2,'AB');

fclose(s2);delete(s2);clear('s2');