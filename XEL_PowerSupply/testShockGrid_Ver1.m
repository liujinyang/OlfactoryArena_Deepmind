volt = 90;
delayTime = 0;
onTime = 1000;
offTime = 1000;
cycles = 30;
PScomport = 'COM8';
LEDcomport = 'COM3';


%Test the shock grid
hPS = serial(PScomport);
fopen(hPS);

hLEDC = serial(LEDcomport, 'BaudRate', 115200, 'Terminator', 'CR');
fopen(hLEDC);

%set voltage 
data = ['V1 ', num2str(volt)];
fprintf(hPS, '%s\n', data);
fprintf(hPS, '%s\r\n', 'I1 0.005');
shockPara =  ['shock ',num2str(delayTime),',',num2str(onTime), ',', num2str(offTime), ',', num2str(cycles)];
fprintf(hLEDC,shockPara);

pause(1);
fprintf(hLEDC, 'startsh');

pause(60);

%reset to 0 V
fprintf(hPS, '%s\n', 'V1 0');

fclose(hPS);
fclose(hLEDC);

