serial_port_for_LED_Controller = 'COM3';
serial_port_for_precon_sensor = 'COM5';
devNum_odorC1 = 'dev1'; 
devNum_odorC2 = 'dev3';
serial_port_for_MFC1 = 'COM6';
serial_port_for_MFC2 = 'COM7';

rigName = 'olfactoryArena1';

%%settings of the camera
camera(1).ip = '127.0.0.1';
camera(1).port = 5010;

camera(2).ip = '127.0.0.1';
camera(2).port = 5020;

%Temp and Humidity update period (in secs)
THUpdateP = 1;

% %frame Rate
% frameRate = 30;
% %movie Format
movieFormat = 'ufmf';
% %region of interest
% ROI = [0 0 1024 1024];
% %trigger mode
% triggerMode = 'internal';

%%settings for the LED controller
IrInt_DefaultVal = 30;

%Directory settings
expDataDir = 'D:\Yoshi';
expProtocolDir = 'C:\Users\labadmin\Documents\MATLAB\Olfactory\GUI_Version\Protocols';

%file settings
defaultMetaXmlFile = 'C:\Users\labadmin\Documents\MATLAB\Olfactory\GUI_Version\olfactoryArenaMetaTree.xml';
defaultExpNotesFile = 'C:\Users\labadmin\Documents\MATLAB\Olfactory\GUI_Version\olfactoryArenaExpNotes.xml';
defaultProtocol = 'C:\Users\labadmin\Documents\MATLAB\Olfactory\GUI_Version\protocolVer3.xlsx';

%defaultJsonFile
biasFile = 'C:\Users\labadmin\Documents\MATLAB\Olfactory\GUI_Version\bias_gui.bat';
defaultJsonFile{1} = 'C:\Users\labadmin\Documents\MATLAB\Olfactory\GUI_Version\bias_config1.json';
defaultJsonFile{2} = 'C:\Users\labadmin\Documents\MATLAB\Olfactory\GUI_Version\bias_config2.json';
