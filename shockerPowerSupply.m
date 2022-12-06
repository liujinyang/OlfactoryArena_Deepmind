classdef shockerPowerSupply < handle
    %power supply class for Sorensen Xel 120P
    
    properties
        serialPort
    end
    
    methods
        function obj = shockerPowerSupply(COMPort)
            try
                obj.serialPort = serialport(COMPort, 9600);
                configureTerminator(obj.serialPort,"CR/LF");
                %fopen(obj.serialPort);
                writeline(obj.serialPort, "OP1?");
                pause(0.1);
                readline(obj.serialPort);
            catch ME
                display(ME.message);
                obj.serialPort = 0;
            end
        end
        
        function setVoltage(obj, volt)
            if ~(obj.serialPort == 0)
                if volt==0
                    writeline(obj.serialPort, "I1 0");
                else
                    writeline(obj.serialPort, "I1 0.005");
                end
                data = ['V1 ', num2str(volt)];
                writeline(obj.serialPort, data);
            end
        end
        
        function turnOnPS(obj)
            if ~(obj.serialPort == 0)
                writeline(obj.serialPort, "OP1 1");
            end
        end
        
        function turnOff(obj)
            if ~(obj.serialPort == 0)
                writeline(obj.serialPort, "OP1 0");
            end
        end
        
        function delete(obj)
            if ~(obj.serialPort == 0)
                writeline(obj.serialPort, "OP1 0");
                setVoltage(obj, 0);
                delete(obj.serialPort);
            end
        end
        
        function volt = getVoltage(obj)
            if ~(obj.serialPort == 0)
                writeline(obj.serialPort, "V1O?");
                val = erase(readline(obj.serialPort),"V");
            else
                val = "";
            end
            volt = str2double(val);
        end
        
        function amp = getCurrent(obj)
            if ~(obj.serialPort == 0)
                writeline(obj.serialPort, "I1O?");
                val = erase(readline(obj.serialPort),"A");
            else
                val = "";
            end
            amp = str2double(val);
        end
        
    end
end