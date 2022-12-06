volt = 90;
onTime = 1;
offTime = 4;
duration = 50;
comport = 4;

%Test the shock grid
hPS = serial(['com',num2str(comport)]);
fopen(hPS);

%set voltage 
data = ['V1 ', num2str(volt)];
fprintf(hPS, '%s\n', data);
fprintf(hPS, '%s\r\n', 'I1 0.005');

iteration = ceil(duration/5);
for i = 1:iteration
    fprintf(hPS, '%s\r\n', 'OP1 1');
    pause(onTime);
    fprintf(hPS, '%s\r\n', 'OP1 0');
    pause(offTime);
end

%reset to 0 V
fprintf(hPS, '%s\n', 'V1 0');

fclose(hPS);

