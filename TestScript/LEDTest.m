LEDController1 = LEDController('COM4');
LEDController1.reset();
%LEDController1.setBlueLEDPower(10);

%LEDController1.setRedLEDPower(10);
LEDController1.setRedLEDPower(0,0,'0001');
LEDController1.setRedLEDPower(0,0,'0010');
LEDController1.setRedLEDPower(0,0,'0100');
LEDController1.setRedLEDPower(100,0,'1000');

LEDController1.setBlueLEDPower(0,0,'0001');
LEDController1.setBlueLEDPower(100,0,'0010');
LEDController1.setBlueLEDPower(0,0,'0100');
LEDController1.setBlueLEDPower(0,0,'1000');

LEDController1.setGreenLEDPower(100,0,'0001');
LEDController1.setGreenLEDPower(0,0,'0010');
LEDController1.setGreenLEDPower(0,0,'0100');
LEDController1.setGreenLEDPower(0,0,'1000');

% %step 1: test on/off 
% LEDController1.turnOnLED();
% pause(10);
% LEDController1.turnOffLED();
% 
% %step 2: test pulse command
% param.pulse_width =5000;
% param.pulse_period = 6000;
% param.number_of_pulses = 1;
% param.pulse_train_interval = 0;
% param.LED_delay = 0;
% param.iteration = 1;
% param.color = 'red';
% LEDController1.setPulseParam(param);
% 
% pause(0.1);
% LEDController1.startPulse();
% pause(10);
% LEDController1.stopPulse();

%step 3: test experimental protocols

%remove all experiment steps
LEDController1.removeAllExperimentSteps();
LEDController1.removeAllExperimentStepOrders();

LEDController1.setRedLEDPower(0);
LEDController1.setGreenLEDPower(0);
LEDController1.setBlueLEDPower(0);

oneStep(1).NumStep = 1;
oneStep(1).Duration = 60;
oneStep(1).DelayTime = 5;
%red light
oneStep(1).RedIntensity = 30;
oneStep(1).RedPulseWidth = 1000;
oneStep(1).RedPulsePeriod = 2000;
oneStep(1).RedPulseNum = 1;
oneStep(1).RedOffTime = 0;
oneStep(1).RedIteration = 10;
%green light
oneStep(1).GrnIntensity = 0;
oneStep(1).GrnPulseWidth = 500;
oneStep(1).GrnPulsePeriod = 1000;
oneStep(1).GrnPulseNum = 1;
oneStep(1).GrnOffTime = 2000;
oneStep(1).GrnIteration = 10;
%blue light
oneStep(1).BluIntensity = 0;
oneStep(1).BluPulseWidth = 500;
oneStep(1).BluPulsePeriod = 1000;
oneStep(1).BluPulseNum = 1;
oneStep(1).BluOffTime = 2000;
oneStep(1).BluIteration = 10;
% oneStep(1).Pattern = '1001100110011001';
oneStep(1).Pattern = '10011001';

oneStep(2).NumStep = 2;
oneStep(2).Duration = 60;
oneStep(2).DelayTime = 0;
%red light
oneStep(2).RedIntensity = 30;
oneStep(2).RedPulseWidth = 1000;
oneStep(2).RedPulsePeriod = 2000;
oneStep(2).RedPulseNum = 10;
oneStep(2).RedOffTime = 0;
oneStep(2).RedIteration = 1;
%green light
oneStep(2).GrnIntensity = 0;
oneStep(2).GrnPulseWidth = 1000;
oneStep(2).GrnPulsePeriod = 1000;
oneStep(2).GrnPulseNum = 1;
oneStep(2).GrnOffTime = 2000;
oneStep(2).GrnIteration = 10;
%blue light
oneStep(2).BluIntensity = 0;
oneStep(2).BluPulseWidth = 1000;
oneStep(2).BluPulsePeriod = 1000;
oneStep(2).BluPulseNum = 1;
oneStep(2).BluOffTime = 2000;
oneStep(2).BluIteration = 10;
% oneStep(2).Pattern = '1001100110011001';
oneStep(2).Pattern = '10011001';

totalSteps = LEDController1.addOneStep(oneStep(1));
totalSteps = LEDController1.addOneStep(oneStep(2));

steps = LEDController1.getExperimentSteps();

LEDController1.stepOrder(2);
LEDController1.stepOrder(1);
LEDController1.stepOrder(1);
LEDController1.stepOrder(2);

stepOrders = LEDController1.getExperimentStepOrders();
disp(stepOrders);

LEDController1.runExperiment();

tic 
for i = 0:1:840
    status = LEDController1.getExperimentStatus();
    disp(status);
%     temp = textscan(status,'%f,%d,%f,%f,%f');
%     timeInfo = temp{1}/1000;
%     step = temp{2};
%     redIntensity = temp{3};
%     grnIntensity = temp{4};
%     bluIntensity = temp{5};
    pause(1);
end 
toc

LEDController1.delete();