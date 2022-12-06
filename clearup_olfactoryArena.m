function clearup_olfactoryArena(hComm)

%clearup LED controller
hComm.LEDController1.delete();

hComm.shockerPS1.delete();

if ~(hComm.THSensor == 0)
    hComm.THSensor.close();
end

hComm.MFC.delete();

hComm.odormixer1.delete();
hComm.odormixer2.delete();
hComm.odormixer3.delete();
hComm.odormixer4.delete();

%clearup the camera
try    
    for camCounter = 1:length(hComm.flea3)
        if ~(hComm.flea3(camCounter)==0)
            hComm.flea3(camCounter).stopCapture();
            hComm.flea3(camCounter).disableLogging();
            hComm.flea3(camCounter).disconnect();
            hComm.flea3(camCounter).closeWindow();
        end
    end
catch
%catch an error    
end
