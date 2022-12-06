function hComm = initialize_olfactoryArena()

olfactoryArena_user_setting;

%initialize LED controller
fprintf('Opening LED controller...\n');
LEDController1 = LEDController(serial_port_for_LED_Controller);
hComm.LEDController1 = LEDController1;

%Reset LED
hComm.LEDController1.reset();

oneStep = struct();
%start to load 4 LED patterns  
for stepIndex = 1:4
    oneStep(stepIndex).NumStep = stepIndex;
    oneStep(stepIndex).Duration = stepDuration;  %in seconds
    oneStep(stepIndex).DelayTime = RDelay;
    %red light
    oneStep(stepIndex).RedIntensity = RIntensity;
    oneStep(stepIndex).RedPulseWidth = RPulseWidth;
    oneStep(stepIndex).RedPulsePeriod = RPulsePeriod;
    oneStep(stepIndex).RedPulseNum = RPulseNum;
    oneStep(stepIndex).RedOffTime = ROffTime;
    oneStep(stepIndex).RedIteration = RIteration;
    %green light
    oneStep(stepIndex).GrnIntensity = GIntensity;
    oneStep(stepIndex).GrnPulseWidth = GPulseWidth;
    oneStep(stepIndex).GrnPulsePeriod = GPulsePeriod;
    oneStep(stepIndex).GrnPulseNum = GPulseNum;
    oneStep(stepIndex).GrnOffTime = GOffTime;
    oneStep(stepIndex).GrnIteration = GIteration;
    %blue light
    oneStep(stepIndex).BluIntensity = BIntensity;
    oneStep(stepIndex).BluPulseWidth = BPulseWidth;
    oneStep(stepIndex).BluPulsePeriod = BPulsePeriod;
    oneStep(stepIndex).BluPulseNum = BPulseNum;
    oneStep(stepIndex).BluOffTime = BOffTime;
    oneStep(stepIndex).BluIteration = BIteration;     
end

oneStep(1).RedIntensity = 0;

oneStep(1).Pattern = '00000000';
oneStep(2).Pattern = '10011001';
oneStep(3).Pattern = '01100110';
oneStep(4).Pattern = '11111111';

%remove all experiment steps
hComm.LEDController1.removeAllExperimentSteps();

%add new experiment steps
try
    for stepIndex = 1:4
        totalSteps = hComm.LEDController1.addOneStep(oneStep(stepIndex));
    end
    
    if totalSteps == 4
        expData = hComm.LEDController1.getExperimentSteps();
        disp(expData);
    else
        errID = 'LEDController:UploadProtocolError';
        msgtext = 'The LED protocol upload failed.';
        
        ME = MException(errID,msgtext);
        throw(ME);
    end
    
catch ME
    errorMessage = sprintf('Error in uploading LED protocol.\n %s\n', ...
        ME.message);
    uiwait(warndlg(errorMessage));
    set(handles.run_exp,'enable', 'off');
end


%initialize precon sensor
fprintf('Opening Temperature and humidity sensor...\n');
THSensor = PreconSensor(serial_port_for_precon_sensor);
[success, errMsg] = THSensor.open();
if success
    hComm.THSensor = THSensor;
else
    hComm.THSensor = 0;    
    display(errMsg);
end

%initalize odor controller1
fprintf('Opening odormixer1...\n');
odormixer1 = Odormixer(devNum_odorC1);
odormixer1.valveOff();
hComm.odormixer1 = odormixer1;

%initalize odor controller2
fprintf('Opening odormixer2...\n');
odormixer2 = Odormixer(devNum_odorC2);
odormixer2.valveOff();
hComm.odormixer2 = odormixer2;

%initalize odor controller3
fprintf('Opening odormixer3...\n');
odormixer3 = Odormixer(devNum_odorC3);
odormixer3.valveOff();
hComm.odormixer3 = odormixer3;

%initalize odor controller4
fprintf('Opening odormixer4...\n');
odormixer4 = Odormixer(devNum_odorC4);
odormixer4.valveOff();
hComm.odormixer4 = odormixer4;

%initialize MFC
fprintf('Opening mass flow controllers...\n');
MFC = MassFlowController(serial_port_for_MFC);
hComm.MFC = MFC;

%initialize the sorensen power supply
fprintf('Connecting to Sorensen Power Supply %s\n', serial_port_for_sorensen_ps);
shockerPS1 = shockerPowerSupply(serial_port_for_sorensen_ps);
shockerPS1.setVoltage(0);
shockerPS1.turnOnPS();
hComm.shockerPS1 = shockerPS1;

%initialize  PID data recorder  7/26/2021 
PIDaio=connectToUSB6009_YS;
hComm.PIDaio=PIDaio;

try
    %Run the camera server program bias
    dos([biasFile, ' &']);
    %initialize the camera
    for camCounter = 1:length(camera)
        flea3(camCounter) = BiasControlV60(camera(camCounter).ip,camera(camCounter).port);
        %flea3.initializeCamera(frameRate, movieFormat, ROI, triggerMode);
        flea3(camCounter).connect();
        flea3(camCounter).loadConfiguration(defaultJsonFile{camCounter});
        flea3(camCounter).disableLogging();
        hComm.flea3(camCounter) = flea3(camCounter);
    end
    
catch ME
    disp(ME.message);
    if camCounter == 1
        clear flea3
        for i = 1:length(camera)
            flea3(i) = 0;
            hComm.flea3(i) = flea3(i);
        end
    elseif camCounter == 2
        flea3(2) = 0;
        hComm.flea3(2) = flea3(2);
    end
end

