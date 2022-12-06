function varargout = OlfactoryArena_Shocker(varargin)
% OLFACTORYARENA_SHOCKER MATLAB code for OlfactoryArena_Shocker.fig
%      OLFACTORYARENA_SHOCKER, by itself, creates a new OLFACTORYARENA_SHOCKER or raises the existing
%      singleton*.
%
%      H = OLFACTORYARENA_SHOCKER returns the handle to a new OLFACTORYARENA_SHOCKER or the handle to
%      the existing singleton*.
%
%      OLFACTORYARENA_SHOCKER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in OLFACTORYARENA_SHOCKER.M with the given input arguments.
%
%      OLFACTORYARENA_SHOCKER('Property','Value',...) creates a new OLFACTORYARENA_SHOCKER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before OlfactoryArena_Shocker_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to OlfactoryArena_Shocker_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help OlfactoryArena_Shocker

% Last Modified by GUIDE v2.5 09-Dec-2019 10:31:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @OlfactoryArena_Shocker_OpeningFcn, ...
    'gui_OutputFcn',  @OlfactoryArena_Shocker_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before OlfactoryArena_Shocker is made visible.
function OlfactoryArena_Shocker_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to OlfactoryArena_Shocker (see VARARGIN)

% Choose default command line output for OlfactoryArena_Shocker
handles.output = hObject;

olfactoryArena_user_setting;

hComm = initialize_olfactoryArena;
handles.hComm = hComm;

% add this per Kristin's request
if ~exist('PreconSensor','file'),
    p = fileparts(mfilename('fullpath'));
    addpath(genpath(p));
end

for i = 1:length(hComm.flea3)
    if ~(hComm.flea3(i) == 0)
        flyBowl_camera_control(handles.hComm.flea3(i),'preview');
    end
end

handles.THUpdateP = THUpdateP;

handles.tTemp = timer('StartDelay', 3, 'Period', handles.THUpdateP, 'ExecutionMode', 'fixedRate', 'TimerFcn',{@displayTempMfr, handles.figure1} );
%guidata(hObject, handles); Do I need to update the handles before the

if ~(handles.hComm.MFC.serialPort == 0)
    start(handles.tTemp);
end

handles.expProtocolDir = expProtocolDir;
handles.expDataDir1 = expDataDir1;
handles.expDataDir2 = expDataDir2;
handles.rig = rigName;

handles.board1.currentVialPattern = [0 0 0 0];
handles.board2.currentVialPattern = [0 0 0 0];
handles.board3.currentVialPattern = [0 0 0 0];
handles.board4.currentVialPattern = [0 0 0 0];

%check whether the total time of pulse set is shorter than step duration 
totalRTime = RDelay + RIteration * (RPulsePeriod/1000 * RPulseNum + ROffTime);
if totalRTime >= stepDuration
    errorMessage = sprintf('Toatal time of the pulse set should be shorter than the step duration.\n');
    uiwait(warndlg(errorMessage));
end

handles.Blu_int_val = 0;
handles.Grn_int_val = 0;
handles.Chr_int_val = 0;

%handles.defaultProtocol = defaultProtocol;

% Update handles structure
handles.pulseWidth = 0;
handles.pulsePeriod = 0;
handles.expRun = 0;
handles.LEDPattern = '1111';
handles.protocol.duration = stepDuration;
handles.protocol.RIntensity = RIntensity;

%shock pattern in the order of board4 board3 board2 board1
handles.shockpattern = logical([0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1]);

handles.shockVolt = 10;
handles.shockOnTime = 1000;
handles.shockOffTime = 1000;
handles.shockCycles = 10;

%find default metadata xml file
%updateLineNames;
%updateEffectors;

handles.expDefaultDir = expDefaultDir;
handles.defaultMetaXmlFile = defaultMetaXmlFile;
handles.defaultExpNotesFile = defaultExpNotesFile;
handles.jsonFile = defaultJsonFile;
handles.movieFormat = movieFormat;
handles.intensityMode = 'LINEAR';

%Reset LED
handles.hComm.LEDController1.reset();

%load default IR intensity value from user setting file
Ir_int_val = IrInt_DefaultVal;
handles.IrIntValue = Ir_int_val;
set(handles.IrInt, 'Value', Ir_int_val/100);
set(handles.IrIntVal, 'String', [num2str(Ir_int_val) '%']);
handles.hComm.LEDController1.setIRLEDPower(Ir_int_val);

%reset MFC to default value
setMFC_Callback(handles.setMFC,eventdata,handles);

guidata(hObject, handles);

% UIWAIT makes OlfactoryArena_Shocker wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function displayTempMfr(obj, event, Hfig)
% tic
handles = guidata(Hfig);
results = handles.hComm.MFC.pollData('A');
if isempty(results)
    stop(handles.tTemp);
    return;
end
set(handles.temp_val1, 'String', num2str(results.temp));
set(handles.mfr_val1, 'String', num2str(results.volumetricFlow));
set(handles.psia_val1, 'String', num2str(results.pressure));


results = handles.hComm.MFC.pollData('B');
if ~isempty(results)
    set(handles.temp_val2, 'String', num2str(results.temp));
    set(handles.mfr_val2, 'String', num2str(results.volumetricFlow));
    set(handles.psia_val2, 'String', num2str(results.pressure));
end

results = handles.hComm.MFC.pollData('C');
if ~isempty(results)
    set(handles.temp_val3, 'String', num2str(results.temp));
    set(handles.mfr_val3, 'String', num2str(results.volumetricFlow));
    set(handles.psia_val3, 'String', num2str(results.pressure));
end

results = handles.hComm.MFC.pollData('D');
if ~isempty(results)
    set(handles.temp_val4, 'String', num2str(results.temp));
    set(handles.mfr_val4, 'String', num2str(results.volumetricFlow));
    set(handles.psia_val4, 'String', num2str(results.pressure));
end
    
results = handles.hComm.MFC.pollData('E');
if ~isempty(results)
    set(handles.temp_val5, 'String', num2str(results.temp));
    set(handles.mfr_val5, 'String', num2str(results.volumetricFlow));
    set(handles.psia_val5, 'String', num2str(results.pressure));
end

results = handles.hComm.MFC.pollData('F');
if ~isempty(results)
    set(handles.temp_val6, 'String', num2str(results.temp));
    set(handles.mfr_val6, 'String', num2str(results.volumetricFlow));
    set(handles.psia_val6, 'String', num2str(results.pressure));
end

results = handles.hComm.MFC.pollData('G');
if ~isempty(results)
    set(handles.temp_val7, 'String', num2str(results.temp));
    set(handles.mfr_val7, 'String', num2str(results.volumetricFlow));
    set(handles.psia_val7, 'String', num2str(results.pressure));
end

results = handles.hComm.MFC.pollData('H');
if ~isempty(results)
    set(handles.temp_val8, 'String', num2str(results.temp));
    set(handles.mfr_val8, 'String', num2str(results.volumetricFlow));
    set(handles.psia_val8, 'String', num2str(results.pressure));
end
% toc
% [temp,humid,~,~] = handles.hComm.THSensor.read(1);
% set(handles.temp_val1, 'String', num2str(temp));
% set(handles.mfr_val1, 'String', num2str(humid));

% handles.TempValue = temp;
% handles.HumdValue = humd;
%guidata(obj, handles);

% --- Outputs from this function are returned to the command line.
function varargout = OlfactoryArena_Shocker_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function ChrInt_Callback(hObject, eventdata, handles)
% hObject    handle to ChrInt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
Chr_int_val = round(get(hObject,'Value')*100);   % this is done so only one dec place
set(handles.ChrIntVal, 'String', [num2str(Chr_int_val) '%']);
handles.Chr_int_val = Chr_int_val;
%send command to controller
handles.hComm.LEDController1.setRedLEDPower(Chr_int_val, 0, handles.LEDPattern);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function ChrInt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ChrInt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function IrInt_Callback(hObject, eventdata, handles)
% hObject    handle to IrInt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
Ir_int_val = round(get(hObject,'Value')*100);   % this is done so only one dec place
set(handles.IrIntVal, 'String', [num2str(Ir_int_val) '%']);

%send command to controller
handles.IrIntValue = Ir_int_val;
handles.hComm.LEDController1.setIRLEDPower(Ir_int_val);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function IrInt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to IrInt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in OnOff.
function OnOff_Callback(hObject, eventdata, handles)
% hObject    handle to OnOff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of OnOff

button_state = get(hObject,'Value');
if button_state == get(hObject,'Max')
    handles.LEDON = 1;
    
    set(hObject,'String','OFF');
    %This step is important because Set visible backlight commands needs
    %reset to turn off all quarants
    handles.hComm.LEDController1.setVisibleBacklightsOff();
    
    handles.hComm.LEDController1.setRedLEDPower(handles.Chr_int_val, 0, handles.LEDPattern);
    handles.hComm.LEDController1.setGreenLEDPower(handles.Grn_int_val, 0, handles.LEDPattern);
    handles.hComm.LEDController1.setBlueLEDPower(handles.Blu_int_val, 0, handles.LEDPattern);
    handles.hComm.LEDController1.turnOnLED();
    
elseif button_state == get(hObject,'Min')
    handles.LEDON = 0;
    set(hObject,'String','ON');
    
    
    handles.hComm.LEDController1.turnOffLED();
    
end
guidata(hObject, handles);

function ChrIntVal_Callback(hObject, eventdata, handles)
% hObject    handle to ChrIntVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ChrIntVal as text
%        str2double(get(hObject,'String')) returns contents of ChrIntVal as a double


% --- Executes during object creation, after setting all properties.
function ChrIntVal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ChrIntVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function IrIntVal_Callback(hObject, eventdata, handles)
% hObject    handle to IrIntVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of IrIntVal as text
%        str2double(get(hObject,'String')) returns contents of IrIntVal as a double


% --- Executes during object creation, after setting all properties.
function IrIntVal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to IrIntVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes when entered data in editable cell(s) in LedPattern.
function LedPattern_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to LedPattern (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

% The quadrant is arranged in the following way
%2  1
%3  4
%The controller is located at the 4th quadrant

LED_pattern_raw = get(hObject,'data');

Pattern = '0000';
if ~isempty(find(LED_pattern_raw,1))
    Temp = LED_pattern_raw;
    Temp1 = [Temp(1,2) Temp(1,1) Temp(2,1) Temp(2,2)];
    for i = 1 : 4
        if Temp1(i) 
            Pattern(i) = '1';
        end 
    end
end

handles.LEDPattern = Pattern;

guidata(hObject, handles);

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: delete(hObject) closes the figure

%close the serial port connection
%turn off IR

%stop update temp and humdity. clear the timer
try
    if ~(handles.hComm.MFC.serialPort == 0)
        stop(handles.tTemp);
    end
    handles.hComm.LEDController1.setIRLEDPower(0);
    clearup_olfactoryArena(handles.hComm)
    
catch ME
    disp(ME);
end
delete(hObject);
%close all;
%clear all;


function pulse_width_Callback(hObject, eventdata, handles)
% hObject    handle to pulse_width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pulse_width as text
%        str2double(get(hObject,'String')) returns contents of pulse_width as a double

handles.pulseWidth = str2double(get(hObject,'String')) ;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function pulse_width_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pulse_width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pulse_period_Callback(hObject, eventdata, handles)
% hObject    handle to pulse_period (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pulse_period as text
%        str2double(get(hObject,'String')) returns contents of pulse_period as a double
handles.pulsePeriod = str2double(get(hObject,'String')) ;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function pulse_period_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pulse_period (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in select_exp.
function select_exp_Callback(hObject, eventdata, handles)
% hObject    handle to select_exp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of select_exp
% oldPath = pwd;
% cd(handles.expProtocolDir);
[filename, pathname] = uigetfile([handles.expProtocolDir,'\*.xlsx;'], 'Select an experiment file');
if isequal(filename,0)
    return
else
    expFile = fullfile(pathname, filename);
    set(handles.exp_name, 'string', expFile);
    handles.expFile = expFile;
    [~,~,protocolExt] = fileparts(expFile);
end

rng('shuffle');

[indata,intext,~] = xlsread(expFile);

handles.ProtocolHeader = intext(1:2,:);
handles.ProtocolData = indata;

%trial control
handles.protocol.stepNum= indata(:,1);
handles.protocol.totalStepNum = length(handles.protocol.stepNum);
handles.totalDuration = handles.protocol.totalStepNum * handles.protocol.duration;
%led control

handles.protocol.redProb1= indata(:,2);
handles.protocol.redProb2 = indata(:,3);

%vial control
handles.protocol.vial11 = indata(:,4);%board1 and vial1
handles.protocol.vial12 = indata(:,5);%board1 and vial2
handles.protocol.vial13 = indata(:,6);%board1 and vial3
handles.protocol.vial14 = indata(:,7);%board1 and vial4
handles.protocol.vial21 = indata(:,8);%board2 and vial1
handles.protocol.vial22 = indata(:,9);%board2 and vial2
handles.protocol.vial23 = indata(:,10);%board2 and vial3
handles.protocol.vial24 = indata(:,11);%board2 and vial4
handles.protocol.valveDelay= 0;
handles.protocol.valveOnTime = 10;


%LED control
randNum1 = rand(handles.protocol.totalStepNum,1);
randNum2 = rand(handles.protocol.totalStepNum,1);
handles.Red13 = zeros(handles.protocol.totalStepNum,1);
handles.Red24 = zeros(handles.protocol.totalStepNum,1);

for i= 1:handles.protocol.totalStepNum       
    if randNum1(i)<= handles.protocol.redProb1(i)            
        handles.Red13(i) = 1;
        if randNum2(i)<= handles.protocol.redProb2(i)
            handles.protocol.LEDPattern(i) = 4;  %all on
            handles.Red24(i) = 1;
        else
            handles.protocol.LEDPattern(i) = 3;  %only 13 on
        end
    else
        if randNum2(i)<= handles.protocol.redProb2(i)
            handles.protocol.LEDPattern(i) = 2;  %only 24 on
            handles.Red24(i) = 1;
        else
            handles.protocol.LEDPattern(i) = 1;  %all off
        end
    end
end

%MFC control
for i=1:handles.protocol.totalStepNum
    if handles.protocol.vial11(i)+handles.protocol.vial12(i)+handles.protocol.vial13(i)+handles.protocol.vial14(i)> 1
        handles.protocol.MFC1SV(i) = 10;
        handles.protocol.MFC3SV(i) = 10;
    else
        handles.protocol.MFC1SV(i) = 20;
        handles.protocol.MFC3SV(i) = 20;
    end
    handles.protocol.MFC2SV(i) = 200;
    handles.protocol.MFC4SV(i) = 200;
end

handles.ProtocolData = [handles.ProtocolData, handles.Red13, handles.Red24];

%shocker control
%         handles.protocol.shock1Patt= '0000';
%         handles.protocol.shock2Patt= '0000';
handles.protocol.voltage = zeros(handles.protocol.totalStepNum,1);
handles.protocol.shockOnTime = zeros(handles.protocol.totalStepNum,1);
handles.protocol.shockOffTime = zeros(handles.protocol.totalStepNum,1);
handles.protocol.shockIterations = zeros(handles.protocol.totalStepNum,1);
handles.protocol.shockDelay = zeros(handles.protocol.totalStepNum,1);


%video control
handles.protocol.videoName = 'movie';

%remove all experiment steporders
handles.hComm.LEDController1.removeAllExperimentStepOrders();

%add new experiment steporder 
try
    for stepIndex = 1:length(handles.protocol.stepNum)
        handles.hComm.LEDController1.stepOrder(handles.protocol.LEDPattern(stepIndex));
    end
   
    stepOrders = handles.hComm.LEDController1.getExperimentStepOrders();
    disp(stepOrders);
    if length(stepOrders) ~= length(handles.protocol.stepNum)

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
        
%get whole Valve pattern
for i = 1:handles.protocol.totalStepNum
    handles.protocol.valvePatt1{i} = [handles.protocol.vial11(i), handles.protocol.vial12(i), handles.protocol.vial13(i), handles.protocol.vial14(i)];
    handles.protocol.valvePatt2{i} = [handles.protocol.vial21(i), handles.protocol.vial22(i), handles.protocol.vial23(i), handles.protocol.vial24(i)];
end

%get the shocker 
for i = 1:handles.protocol.totalStepNum
    handles.protocol.shockPatt{i} = '0000000000000000';
end
    
guidata(hObject, handles);

% --- Executes on button press in run_exp.
function run_exp_Callback(hObject, eventdata, handles)
% hObject    handle to run_exp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of run_exp

button_state = get(hObject,'Value');
%button is down, start experiment
if button_state == get(hObject,'Max')
    handles.expRun = 1;
    set(hObject,'String','ABORT');
    
    %stop update the temperature and humidity value
    if ~(handles.hComm.MFC.serialPort == 0)
        stop(handles.tTemp);
    end
    
    %disable those inputs
    set(findall(handles.LED_Control_Panel, '-property', 'enable'), 'enable', 'off');
    set(findall(handles.Vial_Control_Panel, '-property', 'enable'), 'enable', 'off');
    set(findall(handles.MFC_Control_Panel, '-property', 'enable'), 'enable', 'off');
    set(findall(handles.Environment_Panel, '-property', 'enable'), 'enable', 'off');
    set(findall(handles.shock_control_panel, '-property', 'enable'), 'enable', 'off');
    set(handles.select_exp, 'enable', 'off');
    
    
    %% input meta data information
    defaultsFile = handles.defaultMetaXmlFile;
    
    % Load defaults XML tree from sample file
    defaultsTree = loadXMLDefaultsTree(defaultsFile);
    
    [pathstr, protocolName, ext]  = fileparts(handles.expFile);
    %    defaultsTree.setValueByPathString('protocol', protocolName);
    %defaultsTree.setValueByPathString('exp_datetime', datestr(now,30));
    defaultsTree.setValueByUniquePath({'olfactoryArena' 'environment' 'IR_intensity'}, num2str(handles.IrIntValue));
    defaultsTree.setValueByUniquePath({'olfactoryArena' 'environment' 'LED_intensity_scale'}, handles.intensityMode);

    if ~(handles.hComm.THSensor == 0)
        [temp,humid,~,~] = handles.hComm.THSensor.read(1);
        defaultsTree.setValueByUniquePath({'olfactoryArena' 'environment' 'temperature'}, num2str(temp));
        defaultsTree.setValueByUniquePath({'olfactoryArena' 'environment' 'humidity'}, num2str(humid));
    end

    if ~(handles.hComm.MFC.serialPort == 0)    
        results = handles.hComm.MFC.pollData('A');
        if ~isempty(results)
            defaultsTree.setValueByUniquePath({'olfactoryArena' 'environment' 'MFC1_temp'}, num2str(results.temp))
            defaultsTree.setValueByUniquePath({'olfactoryArena' 'environment' 'MFC1_massFlow'}, num2str(results.volumetricFlow))
            defaultsTree.setValueByUniquePath({'olfactoryArena' 'environment' 'MFC1_pressure'}, num2str(results.pressure))
        end

        results = handles.hComm.MFC.pollData('B');
        if ~isempty(results)
            defaultsTree.setValueByUniquePath({'olfactoryArena' 'environment' 'MFC2_temp'}, num2str(results.temp))
            defaultsTree.setValueByUniquePath({'olfactoryArena' 'environment' 'MFC2_massFlow'}, num2str(results.volumetricFlow))
            defaultsTree.setValueByUniquePath({'olfactoryArena' 'environment' 'MFC2_pressure'}, num2str(results.pressure))
        end

        results = handles.hComm.MFC.pollData('C');
        if ~isempty(results)
            defaultsTree.setValueByUniquePath({'olfactoryArena' 'environment' 'MFC3_temp'}, num2str(results.temp))
            defaultsTree.setValueByUniquePath({'olfactoryArena' 'environment' 'MFC3_massFlow'}, num2str(results.volumetricFlow))
            defaultsTree.setValueByUniquePath({'olfactoryArena' 'environment' 'MFC3_pressure'}, num2str(results.pressure))
        end

        results = handles.hComm.MFC.pollData('D');
        if ~isempty(results)
            defaultsTree.setValueByUniquePath({'olfactoryArena' 'environment' 'MFC4_temp'}, num2str(results.temp))
            defaultsTree.setValueByUniquePath({'olfactoryArena' 'environment' 'MFC4_massFlow'}, num2str(results.volumetricFlow))
            defaultsTree.setValueByUniquePath({'olfactoryArena' 'environment' 'MFC4_pressure'}, num2str(results.pressure))
        end

        results = handles.hComm.MFC.pollData('E');
        if ~isempty(results)
            defaultsTree.setValueByUniquePath({'olfactoryArena' 'environment' 'MFC5_temp'}, num2str(results.temp))
            defaultsTree.setValueByUniquePath({'olfactoryArena' 'environment' 'MFC5_massFlow'}, num2str(results.volumetricFlow))
            defaultsTree.setValueByUniquePath({'olfactoryArena' 'environment' 'MFC5_pressure'}, num2str(results.pressure))
        end

        results = handles.hComm.MFC.pollData('F');
        if ~isempty(results)
            defaultsTree.setValueByUniquePath({'olfactoryArena' 'environment' 'MFC6_temp'}, num2str(results.temp))
            defaultsTree.setValueByUniquePath({'olfactoryArena' 'environment' 'MFC6_massFlow'}, num2str(results.volumetricFlow))
            defaultsTree.setValueByUniquePath({'olfactoryArena' 'environment' 'MFC6_pressure'}, num2str(results.pressure))
        end

        results = handles.hComm.MFC.pollData('G');
        if ~isempty(results)
            defaultsTree.setValueByUniquePath({'olfactoryArena' 'environment' 'MFC7_temp'}, num2str(results.temp))
            defaultsTree.setValueByUniquePath({'olfactoryArena' 'environment' 'MFC7_massFlow'}, num2str(results.volumetricFlow))
            defaultsTree.setValueByUniquePath({'olfactoryArena' 'environment' 'MFC7_pressure'}, num2str(results.pressure))
        end

        results = handles.hComm.MFC.pollData('H');
        if ~isempty(results)
            defaultsTree.setValueByUniquePath({'olfactoryArena' 'environment' 'MFC8_temp'}, num2str(results.temp))
            defaultsTree.setValueByUniquePath({'olfactoryArena' 'environment' 'MFC8_massFlow'}, num2str(results.volumetricFlow))
            defaultsTree.setValueByUniquePath({'olfactoryArena' 'environment' 'MFC8_pressure'}, num2str(results.pressure))
        end        
    end
    
%     defaultsTree.setValueByUniquePath({'olfactoryArena' 'flies' 'genotype'},...
%         [defaultsTree.getValueByUniquePath({'olfactoryArena','flies', 'male_parent'}), '_',...
%         defaultsTree.getValueByUniquePath({'olfactoryArena','flies', 'female_parent'})]);
    
    %defaultsTree.setValueByUniquePath({'OlfactoryArena_Shocker' 'flies' 'genotype' 'content'}, 'abcd');
    handles.protocolName= protocolName;
    
    % Create figure in which to place JIDE property grid
    fig = figure( ...
        'MenuBar', 'none', ...
        'Name', 'Metadata Input GUI', ...
        'NumberTitle', 'off', ...
        'Toolbar', 'none' ...
        );
    
    % Create JIDE PropertyGrid and display defaults data in figure
    pgrid = PropertyGrid(fig,'Position', [0 0 1 1]);
    pgrid.setDefaultsTree(defaultsTree, 'advanced');
    
    % Block unit figure is destroyed
    uiwait(fig);
%     defaultsTree.setValueByUniquePath({'olfactoryArena' 'flies' 'genotype'},...
%         [defaultsTree.getValueByUniquePath({'olfactoryArena','flies', 'male_parent'}),'_' ...
%         defaultsTree.getValueByUniquePath({'olfactoryArena','flies', 'female_parent'})]);
    
    % Create XML meta data file from defaults tree. Note we haven't checked if
    % we have all the required values filled in, but this is suppose to be a
    % simple example - I'll show how to do this in a more ellaborate example.
    metaData = createXMLMetaData(defaultsTree);
    
    % Save defaultsTree as xml file. Note, the current values for all the meta
    % data are saved in the tree so that it is possible to have meata data whose
    % default option is to use the last value used.
    defaultsTree.write(defaultsFile);
    
    % Save meta tree as xml file
    currentDate = datestr(now, 29);
    tempPath{1} = [handles.expDataDir1, '\', currentDate];
    tempPath{2} = [handles.expDataDir2, '\', currentDate];
    chamCamName{1} = handles.expDataDir1(end-9:end);
    chamCamName{2} = handles.expDataDir2(end-9:end);
    
    mParentName = metaData.children(2).attribute.male_parent;
    fParentName = metaData.children(2).attribute.female_parent;
    handles.expStartTime = datestr(now,30);
    
    for i = 1:length(handles.hComm.flea3)

        if ~exist(tempPath{i}, 'dir')
            mkdir(tempPath{i});
        end

        dataPath = [tempPath{i}, '\', protocolName,'_',mParentName,...
            '_',fParentName,'_',chamCamName{i},'_',handles.expStartTime];
        
        if length(dataPath)>255
            dataPath = [tempPath{i}, '\', protocolName,'_',...
                chamCamName{i},'_',handles.expStartTime];
        end
        
        if ~exist(dataPath, 'dir')
            tempDataPath = dataPath;
            mkdir(tempDataPath);
        end
        handles.expDataSubdir{i} = tempDataPath;
    end  
    
    %% save data files
    for i = 1:length(handles.hComm.flea3)
        %save the meta data file
        metaDataFile = [handles.expDataSubdir{i}, '\metaData.xml'];
        metaData.write(metaDataFile);
        
        % save the protocol file
%         protocol = handles.protocol;
%         protocolFile = [handles.expDataSubdir{i}, '\protocol.mat'];
%         save(protocolFile,'protocol');
        protocolExl = [handles.expDataSubdir{i}, '\protocol.xlsx'];
        ExlCell = cell(handles.protocol.totalStepNum + 2, size(handles.ProtocolData,2));
        ExlCell(1:2,:) = handles.ProtocolHeader;
        ExlCell(3:end,:) = num2cell(handles.ProtocolData);
        xlswrite(protocolExl, ExlCell);
        %copyfile(handles.expFile, protocolExl);
%         protocolCSV = [handles.expDataSubdir{i}, '\protocol.csv'];
        
        %save user setting file
        userSettingMFile = [handles.expDefaultDir, 'olfactoryArena_user_setting.m'];
        userSettingTxtFile = [handles.expDataSubdir{i}, '\olfactoryArena_user_setting.txt'];
        copyfile(userSettingMFile, userSettingTxtFile);
        
        %save the json file
        jsonFile = [handles.expDataSubdir{i}, '\cameraSettings',num2str(i-1),'.json'];
        if ~(handles.hComm.flea3(i) == 0)
            flyBowl_camera_control(handles.hComm.flea3(i),'saveconfig', jsonFile);
        end
    end
    
    % create an experiment timestamp file
    expTimeFile = [handles.expDataSubdir{1}, '\expTimeStamp.txt'];
    handles.expTimeFileID = fopen(expTimeFile, 'w+');
    
    %record movie
    for i = 1:length(handles.hComm.flea3)
        if ~(handles.hComm.flea3(i) == 0)
            flyBowl_camera_control(handles.hComm.flea3(i),'stop');
            %start recording
            trialMovieName = [handles.expDataSubdir{i}, '\', handles.protocol.videoName, '.', handles.movieFormat];
            flyBowl_camera_control(handles.hComm.flea3(i),'start', trialMovieName);
        end
    end
    
    guidata(hObject, handles);
    
    %handles.tExperiment = timer('StartDelay',1, 'TimerFcn',{@experiment, handles.figure1});
    handles.tExperiment = timer('TimerFcn',{@experiment, handles.figure1});
    
    handles.hComm.LEDController1.blinkMarker(500);
    
    handles.hComm.LEDController1.runExperiment();

    start(handles.tExperiment);
    
else
    %abort
    handles.expRun = 0;
    try
        stop(handles.tExperiment);
        handles.hComm.LEDController1.stopExperiment();
        fprintf(handles.expTimeFileID, '%.10f , Aborted.\n', now);
%         fprintf(handles.expTimeFileID, '%.10f , stop running the shocker.\n', now);
    catch ME
        disp(ME);
    end
    
    
    handles.hComm.LEDController1.turnOffLED();
    set(handles.current_step, 'string','Aborted!');
    set(hObject,'String','RUN');
    
    %turn off valves
    handles.hComm.odormixer1.valveOff();
    handles.hComm.odormixer2.valveOff();
    handles.hComm.odormixer3.valveOff();
    handles.hComm.odormixer4.valveOff();
       
    %set Power supply to 0V
    handles.hComm.shockerPS1.setVoltage(0);
    
    %stop camera recording
    for i = 1:length(handles.hComm.flea3)
        if ~(handles.hComm.flea3(i) == 0)
            flyBowl_camera_control(handles.hComm.flea3(i),'stop');
            flyBowl_camera_control(handles.hComm.flea3(i),'preview');
            try
                fprintf(handles.expTimeFileID, '%.10f , stop camera recording %d.\n', now);
            catch
            end
            
        end
    end
    
    if isfield(handles,'expTimeFileID')
        fclose(handles.expTimeFileID);
    end
    
    %start update temp and humidity value
    try
        if ~(handles.hComm.MFC.serialPort == 0)
            %handles.tTemp = timer('StartDelay', 3, 'Period', handles.THUpdateP, 'ExecutionMode', 'fixedRate', 'TimerFcn',{@displayTempHumd, handles.figure1} );
            start(handles.tTemp);
        end
    catch ME
        disp(ME);
    end
    
    %enable those inputs
    set(findall(handles.LED_Control_Panel, '-property', 'enable'), 'enable', 'on');
    set(findall(handles.Vial_Control_Panel, '-property', 'enable'), 'enable', 'on');
    set(findall(handles.MFC_Control_Panel, '-property', 'enable'), 'enable', 'on');
    set(findall(handles.Environment_Panel, '-property', 'enable'), 'enable', 'on');
    set(findall(handles.shock_control_panel, '-property', 'enable'), 'enable', 'on');
    set(handles.select_exp, 'enable', 'on');
    
end

guidata(hObject, handles);

function experiment(src,evt,hFig)
handles = guidata(hFig);
handles.IsExpFinished = 0;

currentMFC1SV = 20;
currentMFC2SV = 200;
currentMFC3SV = 20;
currentMFC4SV = 200;
lastStepCount = 0;

while handles.expRun == 1
    
    status = handles.hComm.LEDController1.getExperimentStatus();
    temp = textscan(status,'%f,%d,%f,%f,%f');
    temp1 = [0,0,0,0];
    temp2 = [0,0,0,0];
    
    time = temp{1}/1000; %in second 
    step = floor(time/handles.protocol.duration)+1;
    stepFromController = temp{2};
    rL = temp{3}/100;
    gL = temp{4}/100;
    bL = temp{5}/100;
    
    %change valve and MFC
    if step ~= lastStepCount
        
        if step > handles.protocol.totalStepNum || stepFromController == 0
            handles.expRun = 0;
            handles.IsExpFinished = 1;
            break;
        end

    
        %turn on/off valves
        if ~isempty(handles.hComm.odormixer1.NIdaq) && (handles.protocol.valveOnTime>0)
            %to do check how to get chan
            
            temp1 = handles.protocol.valvePatt1{step};
            temp2 = handles.protocol.valvePatt2{step};
            
            %activePause(hFig, delayT);
            handles.hComm.odormixer1.valveOn(temp1);
            handles.hComm.odormixer2.valveOn(temp2);
            handles.hComm.odormixer3.valveOn(temp1);
            handles.hComm.odormixer4.valveOn(temp2);
        end
        
        % set the MFC flow rate
        if handles.protocol.MFC1SV(step) ~= currentMFC1SV
            handles.hComm.MFC.setPoint('A',handles.protocol.MFC1SV(step));
            handles.hComm.MFC.setPoint('E',handles.protocol.MFC1SV(step));
        end
        
        if handles.protocol.MFC2SV(step) ~= currentMFC2SV
            handles.hComm.MFC.setPoint('B',handles.protocol.MFC2SV(step));
            handles.hComm.MFC.setPoint('F',handles.protocol.MFC2SV(step));
        end
        
        if handles.protocol.MFC3SV(step) ~= currentMFC3SV
            handles.hComm.MFC.setPoint('C',handles.protocol.MFC3SV(step));
            handles.hComm.MFC.setPoint('G',handles.protocol.MFC3SV(step));
        end
        
        if handles.protocol.MFC4SV(step) ~= currentMFC4SV
            handles.hComm.MFC.setPoint('D',handles.protocol.MFC4SV(step));
            handles.hComm.MFC.setPoint('H',handles.protocol.MFC4SV(step));
        end
        
        currentMFC1SV = handles.protocol.MFC1SV(step);
        currentMFC2SV = handles.protocol.MFC2SV(step);
        currentMFC3SV = handles.protocol.MFC3SV(step);
        currentMFC4SV = handles.protocol.MFC4SV(step);
        lastStepCount = step;    

        currentStep = sprintf('STEP: %s,\nRLED:Intensity, pattern: %d,%d,\nCurrent Valve: %s,%s\nCurrent MFC: %s,%s,%s,%s,\n',...
            num2str(handles.protocol.stepNum(step)),...
            handles.protocol.RIntensity,handles.protocol.LEDPattern(step),...
            num2str(temp1),num2str(temp2),...
            num2str(currentMFC1SV), num2str(currentMFC2SV), num2str(currentMFC3SV), num2str(currentMFC4SV));
        
        set(handles.current_step, 'string', currentStep);

    end
    
    drawnow;
end

if handles.IsExpFinished == 1
    %%Experiment ends
    
    %to guaranttee the leds are off at the end
    %stopTime = tic;
    handles.hComm.LEDController1.stopExperiment();

    
        %turn off valves
    handles.hComm.odormixer1.valveOff();
    handles.hComm.odormixer2.valveOff();
    handles.hComm.odormixer3.valveOff();
    handles.hComm.odormixer4.valveOff();
       
    %set Power supply to 0V
    handles.hComm.shockerPS1.setVoltage(0);
    
    set(handles.run_exp,'String','RUN');
    handles.expRun = 0;
    
    %stop camera recording
    for i = 1:length(handles.hComm.flea3)
        if ~(handles.hComm.flea3(i) == 0)
            flyBowl_camera_control(handles.hComm.flea3(i),'stop');
            fprintf(handles.expTimeFileID, '%.10f , stop camera recording %d.\n', now);
            flyBowl_camera_control(handles.hComm.flea3(i),'preview');
        end
    end
    
    if isfield(handles,'expTimeFileID')
        fclose(handles.expTimeFileID);
    end
    %toc(stopTime)
    %toc(expStartTime)
    
    set(handles.current_step, 'string', 'Done!!');
    
    %% input experiment notes after the experiment is done
    defaultNoteFile = handles.defaultExpNotesFile;
    
    % Load defaults XML tree from sample file
    defaultNoteTree = loadXMLDefaultsTree(defaultNoteFile);
    
    % Create figure in which to place JIDE property grid
    fig = figure( ...
        'MenuBar', 'none', ...
        'Name', 'Experiment Note Input GUI', ...
        'NumberTitle', 'off', ...
        'Toolbar', 'none' ...
        );
    
    % Create JIDE PropertyGrid and display defaults data in figure
    pgrid = PropertyGrid(fig,'Position', [0 0 1 1]);
    pgrid.setDefaultsTree(defaultNoteTree, 'advanced');
    
    % Block unit figure is destroyed
    uiwait(fig);
    
    % Create XML meta data file from defaults tree. Note we haven't checked if
    % we have all the required values filled in, but this is suppose to be a
    % simple example - I'll show how to do this in a more ellaborate example.
    noteData = createXMLMetaData(defaultNoteTree);
    
    % Save defaultsTree as xml file. Note, the current values for all the meta
    % data are saved in the tree so that it is possible to have meata data whose
    % default option is to use the last value used.
    defaultNoteTree.write(defaultNoteFile);
    
    
    %% save data files
    for i = 1:length(handles.hComm.flea3)
        
        %save the meta data file
        noteFile = [handles.expDataSubdir{i}, '\expNotes.xml'];
        noteData.write(noteFile);
        
        %copy log file
        if i>1
            logfile1 = [handles.expDataSubdir{1}, '\expTimeStamp.txt'];
            logfile2 = [handles.expDataSubdir{i}, '\expTimeStamp.txt'];
            copyfile(logfile1, logfile2);
        end
        
        %     %hardcode to change the movie file name
        movieFileWithVer = [handles.expDataSubdir{i}, '\movie*.', handles.movieFormat];
        
        D = dir(movieFileWithVer);
        if ~isempty(D)
            for j = 1:length(D)
                movieFileWithVer = fullfile(handles.expDataSubdir{i},D(j).name);
                defaultMovieFile = fullfile(handles.expDataSubdir{i}, [D(j).name(1:end-10),'.',handles.movieFormat]);
                movefile(movieFileWithVer, defaultMovieFile);
            end
        end
        
    end
    
    %enable those inputs
    set(findall(handles.LED_Control_Panel, '-property', 'enable'), 'enable', 'on');
    set(findall(handles.Vial_Control_Panel, '-property', 'enable'), 'enable', 'on');
    set(findall(handles.MFC_Control_Panel, '-property', 'enable'), 'enable', 'on');
    set(findall(handles.Environment_Panel, '-property', 'enable'), 'enable', 'on');
    set(findall(handles.shock_control_panel, '-property', 'enable'), 'enable', 'on');
    set(handles.select_exp, 'enable', 'on');
    set(handles.run_exp,'Value',0);
    
    handles.hComm.LEDController1.turnOffLED();
        
    %start update temp and humidity value
    if ~(handles.hComm.MFC.serialPort == 0)
        %handles.tTemp = timer('StartDelay', 3, 'Period', handles.THUpdateP, 'ExecutionMode', 'fixedRate', 'TimerFcn',{@displayTempHumd, handles.figure1} );
        start(handles.tTemp);
    end
    
end

function activePause(figureHandle, pauseT)
curTime = tic;
while toc(curTime) < pauseT
    handles = guidata(figureHandle);
    %java.lang.Thread.sleep(50); %pause 0.05 second.
    pause(0.1);
    if handles.expRun == 0
        return;
    end
end
        

function exp_name_Callback(hObject, eventdata, handles)
% hObject    handle to exp_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of exp_name as text
%        str2double(get(hObject,'String')) returns contents of exp_name as a double


% --- Executes during object creation, after setting all properties.
function exp_name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to exp_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function current_step_Callback(hObject, eventdata, handles)
% hObject    handle to current_step (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of current_step as text
%        str2double(get(hObject,'String')) returns contents of current_step as a double


% --- Executes during object creation, after setting all properties.
function current_step_CreateFcn(hObject, eventdata, handles)
% hObject    handle to current_step (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function delay(sec)

% function pause the program
% ms = delay time in seconds
tic;
while toc < sec
end

function temp_val1_Callback(hObject, eventdata, handles)
% hObject    handle to temp_val1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of temp_val1 as text
%        str2double(get(hObject,'String')) returns contents of temp_val1 as a double


% --- Executes during object creation, after setting all properties.
function temp_val1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to temp_val1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function mfr_val1_Callback(hObject, eventdata, handles)
% hObject    handle to mfr_val1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mfr_val1 as text
%        str2double(get(hObject,'String')) returns contents of mfr_val1 as a double


% --- Executes during object creation, after setting all properties.
function mfr_val1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mfr_val1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected object is changed in intensity_choice.
function intensity_choice_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in intensity_choice
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'linear_button'
        display('linear intensity');
        handles.intensityMode = 'LINEAR';
    case 'log_button'
        display('log intensity');
        handles.intensityMode = 'LOG';
end
guidata(hObject, handles);



% --- Executes on button press in valve_on.
function valve_on_Callback(hObject, eventdata, handles)
% hObject    handle to valve_on (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of valve_on

button_state = get(hObject,'Value');
if button_state == get(hObject,'Max')
    handles.valveON = 1;
    set(hObject,'String','OFF');

    handles.hComm.odormixer1.valveOn(handles.board1.currentVialPattern);
    handles.hComm.odormixer2.valveOn(handles.board2.currentVialPattern);
    handles.hComm.odormixer3.valveOn(handles.board3.currentVialPattern);
    handles.hComm.odormixer4.valveOn(handles.board4.currentVialPattern);

elseif button_state == get(hObject,'Min')
    handles.valveON = 0;
    set(hObject,'String','ON');

    handles.hComm.odormixer1.valveOff();
    handles.hComm.odormixer2.valveOff();
    handles.hComm.odormixer3.valveOff();
    handles.hComm.odormixer4.valveOff();
 
end
guidata(hObject, handles);



function mfr_val2_Callback(hObject, eventdata, handles)
% hObject    handle to mfr_val2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mfr_val2 as text
%        str2double(get(hObject,'String')) returns contents of mfr_val2 as a double


% --- Executes during object creation, after setting all properties.
function mfr_val2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mfr_val2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function temp_val2_Callback(hObject, eventdata, handles)
% hObject    handle to temp_val2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of temp_val2 as text
%        str2double(get(hObject,'String')) returns contents of temp_val2 as a double


% --- Executes during object creation, after setting all properties.
function temp_val2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to temp_val2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function board2_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to board2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function mfr_val3_Callback(hObject, eventdata, handles)
% hObject    handle to mfr_val3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mfr_val3 as text
%        str2double(get(hObject,'String')) returns contents of mfr_val3 as a double


% --- Executes during object creation, after setting all properties.
function mfr_val3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mfr_val3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function temp_val3_Callback(hObject, eventdata, handles)
% hObject    handle to temp_val3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of temp_val3 as text
%        str2double(get(hObject,'String')) returns contents of temp_val3 as a double


% --- Executes during object creation, after setting all properties.
function temp_val3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to temp_val3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function mfr_val4_Callback(hObject, eventdata, ~)
% hObject    handle to mfr_val4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mfr_val4 as text
%        str2double(get(hObject,'String')) returns contents of mfr_val4 as a double


% --- Executes during object creation, after setting all properties.
function mfr_val4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mfr_val4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function temp_val4_Callback(hObject, eventdata, handles)
% hObject    handle to temp_val4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of temp_val4 as text
%        str2double(get(hObject,'String')) returns contents of temp_val4 as a double


% --- Executes during object creation, after setting all properties.
function temp_val4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to temp_val4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function psia_val1_Callback(hObject, eventdata, handles)
% hObject    handle to psia_val1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of psia_val1 as text
%        str2double(get(hObject,'String')) returns contents of psia_val1 as a double


% --- Executes during object creation, after setting all properties.
function psia_val1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to psia_val1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function psia_val2_Callback(hObject, eventdata, handles)
% hObject    handle to psia_val2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of psia_val2 as text
%        str2double(get(hObject,'String')) returns contents of psia_val2 as a double


% --- Executes during object creation, after setting all properties.
function psia_val2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to psia_val2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function psia_val3_Callback(hObject, eventdata, handles)
% hObject    handle to psia_val3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of psia_val3 as text
%        str2double(get(hObject,'String')) returns contents of psia_val3 as a double


% --- Executes during object creation, after setting all properties.
function psia_val3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to psia_val3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function psia_val4_Callback(hObject, eventdata, handles)
% hObject    handle to psia_val4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of psia_val4 as text
%        str2double(get(hObject,'String')) returns contents of psia_val4 as a double


% --- Executes during object creation, after setting all properties.
function psia_val4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to psia_val4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function shock_volt_Callback(hObject, eventdata, handles)
% hObject    handle to shock_volt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of shock_volt as text
%        str2double(get(hObject,'String')) returns contents of shock_volt as a double

shockVolt = str2double(get(hObject,'String'));
if isempty(shockVolt)||shockVolt<0||shockVolt>120
    warndlg('shock voltage should be a integer ranges from 0 to 120V!','Wrong Input Value');
    return
end
handles.shockVolt = shockVolt;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function shock_volt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to shock_volt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function shock_ontime_Callback(hObject, eventdata, handles)
% hObject    handle to shock_ontime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of shock_ontime as text
%        str2double(get(hObject,'String')) returns contents of shock_ontime as a double
shockOnTime = str2double(get(hObject,'String'));

if isempty(shockOnTime)||shockOnTime<10
    warndlg('shocker onTime should be a integer larger than 10ms!','Wrong Input Value');
    return
end

handles.shockOnTime = shockOnTime;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function shock_ontime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to shock_ontime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function shock_offtime_Callback(hObject, eventdata, handles)
% hObject    handle to shock_offtime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of shock_offtime as text
%        str2double(get(hObject,'String')) returns contents of shock_offtime as a double
shockOffTime = str2double(get(hObject,'String'));

if isempty(shockOffTime)||shockOffTime<10
    warndlg('shocker offTime should be a integer larger than 10ms!','Wrong Input Value');
    return
end


handles.shockOffTime = shockOffTime;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function shock_offtime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to shock_offtime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function shock_cycles_Callback(hObject, eventdata, handles)
% hObject    handle to shock_cycles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of shock_cycles as text
%        str2double(get(hObject,'String')) returns contents of shock_cycles as a double
shockCycles = str2double(get(hObject,'String'));

if isempty(shockCycles)||shockCycles<1
    warndlg('shocker cycles should be a positive integer!','Wrong Input Value');
    return
end

handles.shockCycles = shockCycles;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function shock_cycles_CreateFcn(hObject, eventdata, handles)
% hObject    handle to shock_cycles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in test_shocker.
function test_shocker_Callback(hObject, eventdata, handles)
% hObject    handle to test_shocker (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of test_shocker
set(hObject,'enable', 'off');

%use the grid shocker
shockerparam.delayTime = 0;
shockerparam.onTime = handles.shockOnTime;
shockerparam.offTime = handles.shockOffTime;
shockerparam.cycles = handles.shockCycles;
pauseTime = (shockerparam.onTime + shockerparam.offTime)/1000*shockerparam.cycles;

shockPatt = sprintf('%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d',handles.shockpattern);

handles.hComm.LEDController1.setShockPattern(shockPatt);

handles.hComm.LEDController1.setShockPulse(shockerparam);

handles.hComm.shockerPS1.setVoltage(handles.shockVolt);

handles.hComm.LEDController1.startShockPulse();

tstart = tic;

while toc(tstart)<pauseTime
    volt = handles.hComm.shockerPS1.getVoltage();
    if ~isempty(volt)
        set(handles.volt_s, 'String', volt);
    end
    
    curr = handles.hComm.shockerPS1.getCurrent();
    if ~isempty(curr)
        set(handles.current_s, 'String', curr);
    end
end

handles.hComm.LEDController1.stopShockPulse();

handles.hComm.shockerPS1.setVoltage(0);
set(handles.volt_s, 'String', 0);
set(handles.current_s, 'String', 0);
set(hObject,'enable', 'on');


% --- Executes when entered data in editable cell(s) in shockPattern.
function shockPattern_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to shockPattern (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

shock_pattern_raw = get(hObject,'data');

if isempty(find(shock_pattern_raw))
    Pattern = logical(zeros(1,16));
else
     temp = shock_pattern_raw;
     Pattern = [temp(1,:),temp(2,:),temp(3,:),temp(4,:)];
end

handles.shockpattern(9:16) = Pattern;
guidata(hObject, handles);






function edit25_Callback(hObject, eventdata, handles)
% hObject    handle to volt_s (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of volt_s as text
%        str2double(get(hObject,'String')) returns contents of volt_s as a double


% --- Executes during object creation, after setting all properties.
function volt_s_CreateFcn(hObject, eventdata, handles)
% hObject    handle to volt_s (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit26_Callback(hObject, eventdata, handles)
% hObject    handle to current_s (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of current_s as text
%        str2double(get(hObject,'String')) returns contents of current_s as a double


% --- Executes during object creation, after setting all properties.
function current_s_CreateFcn(hObject, eventdata, handles)
% hObject    handle to current_s (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function GrnInt_Callback(hObject, eventdata, handles)
% hObject    handle to GrnInt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
Grn_int_val = round(get(hObject,'Value')*100);   % this is done so only one dec place
set(handles.GrnIntVal, 'String', [num2str(Grn_int_val) '%']);
handles.Grn_int_val = Grn_int_val;
%send command to controller
handles.hComm.LEDController1.setGreenLEDPower(Grn_int_val, 0, handles.LEDPattern);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function GrnInt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GrnInt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function BluInt_Callback(hObject, eventdata, handles)
% hObject    handle to BluInt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
Blu_int_val = round(get(hObject,'Value')*100);   % this is done so only one dec place
set(handles.BluIntVal, 'String', [num2str(Blu_int_val) '%']);
handles.Blu_int_val = Blu_int_val;
%send command to controller
handles.hComm.LEDController1.setBlueLEDPower(Blu_int_val, 0, handles.LEDPattern);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function BluInt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BluInt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function setMFC1_Callback(hObject, eventdata, handles)
% hObject    handle to setMFC1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of setMFC1 as text
%        str2double(get(hObject,'String')) returns contents of setMFC1 as a double


% --- Executes during object creation, after setting all properties.
function setMFC1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to setMFC1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function setMFC2_Callback(hObject, eventdata, handles)
% hObject    handle to setMFC2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of setMFC2 as text
%        str2double(get(hObject,'String')) returns contents of setMFC2 as a double


% --- Executes during object creation, after setting all properties.
function setMFC2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to setMFC2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in setMFC.
function setMFC_Callback(hObject, eventdata, handles)
% hObject    handle to setMFC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
MFC1SV = str2double(get(handles.setMFC1,'String'));
MFC2SV = str2double(get(handles.setMFC2,'String'));
MFC3SV = str2double(get(handles.setMFC3,'String'));
MFC4SV = str2double(get(handles.setMFC4,'String'));
MFC5SV = str2double(get(handles.setMFC5,'String'));
MFC6SV = str2double(get(handles.setMFC6,'String'));
MFC7SV = str2double(get(handles.setMFC7,'String'));
MFC8SV = str2double(get(handles.setMFC8,'String'));

handles.hComm.MFC.setPoint('A',MFC1SV);
handles.hComm.MFC.setPoint('B',MFC2SV);
handles.hComm.MFC.setPoint('C',MFC3SV);
handles.hComm.MFC.setPoint('D',MFC4SV);
handles.hComm.MFC.setPoint('E',MFC5SV);
handles.hComm.MFC.setPoint('F',MFC6SV);
handles.hComm.MFC.setPoint('G',MFC7SV);
handles.hComm.MFC.setPoint('H',MFC8SV);

function setMFC3_Callback(hObject, eventdata, handles)
% hObject    handle to setMFC3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of setMFC3 as text
%        str2double(get(hObject,'String')) returns contents of setMFC3 as a double


% --- Executes during object creation, after setting all properties.
function setMFC3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to setMFC3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function setMFC4_Callback(hObject, eventdata, handles)
% hObject    handle to setMFC4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of setMFC4 as text
%        str2double(get(hObject,'String')) returns contents of setMFC4 as a double


% --- Executes during object creation, after setting all properties.
function setMFC4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to setMFC4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes when entered data in editable cell(s) in LED_Pattern.
function LED_Pattern_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to LED_Pattern (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)



% --- Executes when selected cell(s) is changed in LED_Pattern.
function LED_Pattern_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to LED_Pattern (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
LED_pattern_raw = get(hObject,'data');

if isempty(find(LED_pattern_raw))
    Pattern = logical(zeros(1,16));
else
    Temp = LED_pattern_raw;
    Pattern = [Temp(1,:),Temp(2,:),Temp(3,:),Temp(4,:)];
end

handles.LEDpattern(1:8) = Pattern;

guidata(hObject, handles);

% --- Executes when selected object is changed in uibuttongroup1.
function uibuttongroup1_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup1 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.board1.currentVialNum = eventdata.NewValue.String;
switch handles.board1.currentVialNum
    case '0'
        handles.board1.currentVialPattern = [0 0 0 0];
    case '1'
        handles.board1.currentVialPattern = [1 0 0 0];
    case '2'
        handles.board1.currentVialPattern = [0 1 0 0];
    case '3'
        handles.board1.currentVialPattern = [0 0 1 0];
    case '4'
        handles.board1.currentVialPattern = [0 0 0 1];
end
guidata(hObject, handles);

% --- Executes when selected object is changed in uibuttongroup2.
function uibuttongroup2_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup2 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.board2.currentVialNum = eventdata.NewValue.String;
switch handles.board2.currentVialNum
    case '0'
        handles.board2.currentVialPattern = [0 0 0 0];
    case '1'
        handles.board2.currentVialPattern = [1 0 0 0];
    case '2'
        handles.board2.currentVialPattern = [0 1 0 0];
    case '3'
        handles.board2.currentVialPattern = [0 0 1 0];
    case '4'
        handles.board2.currentVialPattern = [0 0 0 1];
end
guidata(hObject, handles);

% --- Executes when selected object is changed in uibuttongroup3.
function uibuttongroup3_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup3 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.board3.currentVialNum = eventdata.NewValue.String;
switch handles.board3.currentVialNum
    case '0'
        handles.board3.currentVialPattern = [0 0 0 0];
    case '1'
        handles.board3.currentVialPattern = [1 0 0 0];
    case '2'
        handles.board3.currentVialPattern = [0 1 0 0];
    case '3'
        handles.board3.currentVialPattern = [0 0 1 0];
    case '4'
        handles.board3.currentVialPattern = [0 0 0 1];
end
guidata(hObject, handles);

% --- Executes when selected object is changed in uibuttongroup4.
function uibuttongroup4_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup4 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.board4.currentVialNum = eventdata.NewValue.String;
switch handles.board4.currentVialNum
    case '0'
        handles.board4.currentVialPattern = [0 0 0 0];
    case '1'
        handles.board4.currentVialPattern = [1 0 0 0];
    case '2'
        handles.board4.currentVialPattern = [0 1 0 0];
    case '3'
        handles.board4.currentVialPattern = [0 0 1 0];
    case '4'
        handles.board4.currentVialPattern = [0 0 0 1];
end
guidata(hObject, handles);



function setMFC5_Callback(hObject, eventdata, handles)
% hObject    handle to setMFC5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of setMFC5 as text
%        str2double(get(hObject,'String')) returns contents of setMFC5 as a double


% --- Executes during object creation, after setting all properties.
function setMFC5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to setMFC5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function setMFC6_Callback(hObject, eventdata, handles)
% hObject    handle to setMFC6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of setMFC6 as text
%        str2double(get(hObject,'String')) returns contents of setMFC6 as a double


% --- Executes during object creation, after setting all properties.
function setMFC6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to setMFC6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function setMFC7_Callback(hObject, eventdata, handles)
% hObject    handle to setMFC7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of setMFC7 as text
%        str2double(get(hObject,'String')) returns contents of setMFC7 as a double


% --- Executes during object creation, after setting all properties.
function setMFC7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to setMFC7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function setMFC8_Callback(hObject, eventdata, handles)
% hObject    handle to setMFC8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of setMFC8 as text
%        str2double(get(hObject,'String')) returns contents of setMFC8 as a double


% --- Executes during object creation, after setting all properties.
function setMFC8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to setMFC8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function mfr_val5_Callback(hObject, eventdata, handles)
% hObject    handle to mfr_val5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mfr_val5 as text
%        str2double(get(hObject,'String')) returns contents of mfr_val5 as a double


% --- Executes during object creation, after setting all properties.
function mfr_val5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mfr_val5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function temp_val5_Callback(hObject, eventdata, handles)
% hObject    handle to temp_val5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of temp_val5 as text
%        str2double(get(hObject,'String')) returns contents of temp_val5 as a double


% --- Executes during object creation, after setting all properties.
function temp_val5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to temp_val5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function mfr_val6_Callback(hObject, eventdata, handles)
% hObject    handle to mfr_val6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mfr_val6 as text
%        str2double(get(hObject,'String')) returns contents of mfr_val6 as a double


% --- Executes during object creation, after setting all properties.
function mfr_val6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mfr_val6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function temp_val6_Callback(hObject, eventdata, handles)
% hObject    handle to temp_val6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of temp_val6 as text
%        str2double(get(hObject,'String')) returns contents of temp_val6 as a double


% --- Executes during object creation, after setting all properties.
function temp_val6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to temp_val6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function mfr_val7_Callback(hObject, eventdata, handles)
% hObject    handle to mfr_val7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mfr_val7 as text
%        str2double(get(hObject,'String')) returns contents of mfr_val7 as a double


% --- Executes during object creation, after setting all properties.
function mfr_val7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mfr_val7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function temp_val7_Callback(hObject, eventdata, handles)
% hObject    handle to temp_val7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of temp_val7 as text
%        str2double(get(hObject,'String')) returns contents of temp_val7 as a double


% --- Executes during object creation, after setting all properties.
function temp_val7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to temp_val7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function mfr_val8_Callback(hObject, eventdata, handles)
% hObject    handle to mfr_val8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mfr_val8 as text
%        str2double(get(hObject,'String')) returns contents of mfr_val8 as a double


% --- Executes during object creation, after setting all properties.
function mfr_val8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mfr_val8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function temp_val8_Callback(hObject, eventdata, handles)
% hObject    handle to temp_val8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of temp_val8 as text
%        str2double(get(hObject,'String')) returns contents of temp_val8 as a double


% --- Executes during object creation, after setting all properties.
function temp_val8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to temp_val8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function psia_val5_Callback(hObject, eventdata, handles)
% hObject    handle to psia_val5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of psia_val5 as text
%        str2double(get(hObject,'String')) returns contents of psia_val5 as a double


% --- Executes during object creation, after setting all properties.
function psia_val5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to psia_val5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function psia_val6_Callback(hObject, eventdata, handles)
% hObject    handle to psia_val6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of psia_val6 as text
%        str2double(get(hObject,'String')) returns contents of psia_val6 as a double


% --- Executes during object creation, after setting all properties.
function psia_val6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to psia_val6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function psia_val7_Callback(hObject, eventdata, handles)
% hObject    handle to psia_val7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of psia_val7 as text
%        str2double(get(hObject,'String')) returns contents of psia_val7 as a double


% --- Executes during object creation, after setting all properties.
function psia_val7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to psia_val7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function psia_val8_Callback(hObject, eventdata, handles)
% hObject    handle to psia_val8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of psia_val8 as text
%        str2double(get(hObject,'String')) returns contents of psia_val8 as a double


% --- Executes during object creation, after setting all properties.
function psia_val8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to psia_val8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
