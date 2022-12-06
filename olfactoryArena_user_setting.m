serial_port_for_LED_Controller = 'COM4';
serial_port_for_precon_sensor = 'COM1';
% Old
% devNum_odorC1 = 'dev1'; 
% devNum_odorC2 = 'dev3';
% devNum_odorC3 = 'dev4'; 
% devNum_odorC4 = 'dev5';
% new (JCSimon 5/12/2021)


% devNum_odorC1 = 'dev4'; 
% devNum_odorC2 = 'dev3';
% devNum_odorC3 = 'dev2'; 
% devNum_odorC4 = 'dev1';
devNum_odorC1 = 'Dev1'; 
devNum_odorC2 = 'Dev7';
devNum_odorC3 = 'Dev5'; 
devNum_odorC4 = 'Dev6';


% %PID JCS 8/26/2021
% devNum_PID1 = 'dev2';
serial_port_for_MFC = 'COM5';

serial_port_for_sorensen_ps = 'COM6';

rigName = 'olfactoryArena1';

%%settings of the camera
camera(1).ip = '127.0.0.1';
camera(1).port = 5010;
camera(2).ip = '127.0.0.1';
camera(2).port = 5020;

%Temp and Humidity update period (in secs)
THUpdateP = 2;

%LED protocol settings 
stepDuration = 10; %in seconds

%RGB setting
RIntensity = 16;
RPulseWidth = 1000; %in ms
RPulsePeriod = 2000; %in ms
RPulseNum = 1;
ROffTime = 0;
RDelay = 3.9; %in seconds
RIteration = 3;

GIntensity = 0;
GPulseWidth = 0;  %in ms
GPulsePeriod = 0; %in ms
GPulseNum = 0;
GOffTime = 0;
GDelay = 0;  %in seconds
GIteration = 0;

BIntensity = 0;
BPulseWidth = 0;  %in ms
BPulsePeriod = 0; %in ms
BPulseNum = 0;   
BOffTime = 0;
BDelay = 0;    %in seconds
BIteration = 0;

% %frame Rate
% frameRate = 30;
% %movie Format
movieFormat = 'ufmf';
% %region of interest
% ROI = [0 0 1024 1024];
% %trigger mode
% triggerMode = 'internal';

%%settings for the LED controller
% 0% for testing LED power; 40% for old olfactory base; 
% 75% looks better for new 4-area light barrier base and filter will require 100% (JCSimon 3/2021)
IrInt_DefaultVal = 25; 

%Directory settings
expDataDir1 = 'D:\Data\Cham2-Cam0';
expDataDir2 = 'D:\Data\Cham2-Cam1';
expDefaultDir = 'C:\Users\labadmin\Documents\MATLAB\OlfactoryArena_Deepmind\';
expProtocolDir = [expDefaultDir,'Protocols\'];

%file settings
defaultMetaXmlFile = [expDefaultDir,'olfactoryArenaMetaTree.xml'];
defaultExpNotesFile = [expDefaultDir,'olfactoryArenaExpNotes.xml'];
defaultProtocol = [expDefaultDir,'protocolVer3.xlsx'];

%defaultJsonFile
biasFile = [expDefaultDir,'bias_gui.bat'];
defaultJsonFile{1} = [expDefaultDir,'bias_config1.json'];
defaultJsonFile{2} = [expDefaultDir,'bias_config2.json'];
