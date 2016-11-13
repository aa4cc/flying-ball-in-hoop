classdef Traj
    properties (Access = private)
        t_raw;
        u_raw;
        x_raw;
        prms;
    end
    methods
        function obj = Traj(t, x, u, prms)
            if size(t,2) > size(t,1)
                t = t';
            end
            
            if size(x,2) > size(x,1)
                x = x';
            end
            
            if size(u,2) > size(u,1)
                u = u';
            end
            
            if size(x,2) < 5
                r = (prms.Ro-prms.Rb)*ones(size(x,1),1);
                Dr = zeros(size(x,1),1);
                phi = (x(:,1) - x(:,3))*prms.Ro/prms.Rb;
                Dphi = (x(:,2) - x(:,4))*prms.Ro/prms.Rb;
                
                x = [x r Dr phi Dphi];
            end
            
            if size(t,1) ~= size(x,1) || size(t,1) ~= size(u,1)
                error('The lengths of time, state and input vector differs!')
            end            
            
            obj.t_raw = t;
            obj.x_raw = x;
            obj.u_raw = u;
            obj.prms = prms;
        end
        
        function [t, x, u] = interp(obj, Ts)
            t = (0:Ts:obj.t_raw(end))';
            u = interp1(obj.t_raw, obj.u_raw, t);
            x = zeros(numel(t), 4);
            for i=1:8
                x(:,i) = interp1(obj.t_raw, obj.x_raw(:,i), t);
            end
        end
        
        function TS = getTimeSeries(obj, Ts)
            [t, ~, u] = obj.interp(Ts);
            TS = timeseries(u, t);
        end
        
        function prms = getPrms(obj)
            prms = obj.prms;
        end
        
        function [x, y] = getXY(obj, Ts)
            if nargin < 2
                x_state = obj.x_raw;
            else
                [~, x_state, ~] = obj.interp(Ts);
            end
            
            psi = x_state(:,3);
            r = x_state(:,5);
            x = r.*sin(psi);
            y = r.*cos(psi);
        end
    end
end