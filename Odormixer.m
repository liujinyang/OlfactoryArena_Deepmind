classdef Odormixer < handle
    
    properties
        NIdaq
    end
    
    methods
        function obj = Odormixer(deviceID)
            try
                %intialize daq
                obj.NIdaq = daq.createSession('ni');
                addDigitalChannel(obj.NIdaq,deviceID,'port0/line0:7','OutputOnly');
            catch ME
                disp(ME.message);
                obj.NIdaq = '';
            end
        end
        
        
        function valveOn(obj, vialPatt)
            if ~isempty(obj.NIdaq)
                %outputSingleScan(obj.NIdaq,chans);
                %open valve, paus
                command = [0,0,0,0,0,0,0,0];
                for i = 1:4 
                    if vialPatt(i) == 1
                        command(5-i) = 1;
                        command(5) = 1;
                    end
                end
                
                outputSingleScan(obj.NIdaq,command);
                
             end
        end
        
        function valveOff(obj)
            if ~isempty(obj.NIdaq)
                % close valve, pause
                outputSingleScan(obj.NIdaq,[0,0,0,0,0,0,0,0]);
            end
        end
        
%         function valveOnTime(obj,chan,delay,ontime)
%             if ~isempty(obj.NIdaq)
%                 pause(delay);
%                 valveon(obj,chan);
%                 pause(ontime);
%                 valveoff(obj);
%             end
%         end
        
        function delete(obj)
            clear obj.NIdaq;
        end
        
    end
end
