classdef Odrive < matlab.System ...
        & coder.ExternalDependency ...
        & matlab.system.mixin.Propagates ...
        & matlab.system.mixin.CustomIcon
    % Simulink Odrive Uart ascii protocol
    % tested Raspberry pi 3b and Odrive 3.5
    % Uart must be enablen on Raspberry pi by sudo raspi-config
    
    
    properties
        % Public, tunable properties.
    end
    properties (Nontunable)
        Maxcurrent = 10;
        Vel_limit = 20000;
        Control_mode = 'position'
    end
    properties(Logical,Nontunable)
      % Use motor 0
      Motor0 = true;
      
    end
    properties(Logical,Nontunable)
      % Use motor 1
      Motor1 = true; 
    end
    properties(Logical,Nontunable)
      % Setup was already done
      Setup_done = true; 
    end
    properties(Logical,Nontunable)
      % Read current and bus voltage
      Extra_read = true; 
    end
    properties(Constant, Hidden)
        Control_modeSet = matlab.system.StringSet({'position','velocity','current'})
    end
    
    properties (Access = private)
        % Pre-computed constants.
    end
    
    methods
        % Constructor
        function obj = DigitalWrit(varargin)
            % Support name-value pair arguments when constructing the object.
            setProperties(obj,nargin,varargin{:});
        end
    end
    
    methods (Access=protected)
        function setupImpl(obj) %#ok<MANU>
            if isempty(coder.target)
                % Place simulation setup code here
            else
                % Call C-function implementing device initialization
                coder.cinclude('odrive_raspi.h');
                coder.ceval('digitalIOSetup');
                coder.ceval('openCommunication');
                if (not(obj.Setup_done))
                    if (obj.Motor0)
                        coder.ceval('odriveSetup',0,obj.Vel_limit,obj.Maxcurrent);
                    end
                    if (obj.Motor1)
                        coder.ceval('odriveSetup',1,obj.Vel_limit,obj.Maxcurrent);
                    end
                end
            end
        end
        
        function [encoder_motor0,encoder_motor1,bus_voltage,current_motor0,current_motor1] = stepImpl(obj,motor0,motor1)  %#ok<INUSD>
            encoder_motor0 = double(0);
            encoder_motor1 = double(0);
            bus_voltage = double(0);
            current_motor0 = double(0);
            current_motor1 = double(0);
            switch obj.Control_mode
                   case 'position'
                      control = 'p'
                   case 'velocity'
                      control = 'v'
                case 'current'
                    control = 'c'
                   otherwise
                      control = 'n'
            end 
            if isempty(coder.target)
                % Place simulation output code here 
            else
                % Call C-function implementing device output
                if (obj.Motor0)
                    coder.ceval('driveCommand', 0,control,motor0);
                    encoder_motor0 = coder.ceval('readPosition', 0);
                end
                if (obj.Motor1)
                    encoder_motor1 = coder.ceval('readPosition', 1);
                    coder.ceval('driveCommand', 1,control,motor1);
                end
                if (obj.Extra_read)
                    bus_voltage = coder.ceval('readVoltage');
                    current_motor0 = coder.ceval('readCurrent',0);
                    current_motor1 = coder.ceval('readCurrent',1);
                end
                
            end
        end
        
        function releaseImpl(obj) %#ok<MANU>
            if isempty(coder.target)
                % Place simulation termination code here
            else
                % Call C-function implementing device termination
                %coder.ceval('sink_terminate');
            end
        end
    end
    
    methods (Access=protected)
        %% Define input properties
        function num = getNumInputsImpl(~)
            num = 2;
        end
        
        function num = getNumOutputsImpl(~)
            num = 5;
        end
        function flag = isOutputSizeLockedImpl(~,~)
            flag = true;
        end
        function [varargout] = isOutputFixedSizeImpl(~,~)
            varargout{1} = true;
            varargout{2} = true;
            varargout{3} = true;
            varargout{4} = true;
            varargout{5} = true;
        end
        function flag = isOutputComplexityLockedImpl(~,~)
            flag = true;
        end
        function [varargout] = isOutputComplexImpl(~)
            varargout{1} = false;
            varargout{2} = false;
            varargout{3} = false;
            varargout{4} = false;
            varargout{5} = false;
        end

        function [varargout] = getOutputSizeImpl(~)
            varargout{1} = [1,1];
            varargout{2} = [1,1];
             varargout{3} = [1,1];
             varargout{4} = [1,1];
             varargout{5} = [1,1];
        end

        function [varargout] = getOutputDataTypeImpl(~)
            varargout{1} = 'double';
            varargout{2} = 'double';
            varargout{3} = 'double';
            varargout{4} = 'double';
            varargout{5} = 'double';
        end
        
        function flag = isInputSizeLockedImpl(~,~)
            flag = true;
        end
        
        function varargout = isInputFixedSizeImpl(~,~)
            varargout{1} = true;
        end
        
        function flag = isInputComplexityLockedImpl(~,~)
            flag = true;
        end
        
       %function validateInputsImpl(~, u)
         %   if isempty(coder.target)
                % Run input validation only in Simulation
          %      validateattributes(u,{'double'},{'scalar'},'','u');
           % end
      % end
        
        function icon = getIconImpl(~)
            % Define a string as the icon for the System block in Simulink.
            icon = 'Odrive';
        end
    end
    
    methods (Static, Access=protected)
        function simMode = getSimulateUsingImpl(~)
            simMode = 'Interpreted execution';
        end
        
        function isVisible = showSimulateUsingImpl
            isVisible = false;
        end
    end
    
    methods (Static)
        function name = getDescriptiveName()
            name = 'Odrive';
        end
        
        function b = isSupportedContext(context)
            b = context.isCodeGenTarget('rtw');
        end
        
        function updateBuildInfo(buildInfo, context)
            if context.isCodeGenTarget('rtw')
               % Update buildInfo
                srcDir = fullfile(fileparts(mfilename('fullpath')),'src'); %#ok     
                includeDir = fullfile(fileparts(mfilename('fullpath')),'include');                 
                addIncludePaths(buildInfo,includeDir);
                % Use the following API's to add include files, sources and linker flags
                addSourceFiles(buildInfo,'odrive_raspi.c', srcDir);
                %addSourceFiles(buildInfo,'wiringPi.c', srcDir);
                addLinkFlags(buildInfo,{'-lwiringPi'});
                addCompileFlags(buildInfo,{'-I/usr/local/include -L/usr/local/lib -lwiringPi'});
            end
        end
    end
end
