volt = 90;
delayTime = 0;
onTime = 1000;
offTime = 1000;
cycles = 30;
PScomport = 'COM10';
LEDcomport = 'COM4';


%Test the shock grid
hPS = shockerPowerSupply(PScomport);
hLEDC = LEDController(LEDcomport);

%set voltage 
hPS.setVoltage(volt);
hPS.turnOnPS();

hLEDC.setShockPattern('1111111111111111');

pause(1);
hLEDC.turnOnShock();

pause(60);
hLEDC.turnOnShock();

shockPulse.onTime = 1000;
shockPulse.offTime = 1000;
shockPulse.iterations = 10;
shockPulse.delay = 0;
hLEDC.setShockPulse(shockPulse);

hLEDC.startShockPulse();
pause(20);

%reset to 0 V
hPS.turnOff();

hPS.delete();
hLEDC.delete();

