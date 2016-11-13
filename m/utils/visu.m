function visu( traj, varargin )

p = inputParser;
default_slider = false;
default_filename = [];
default_dt = 1/25;
default_fps = 25;

addParameter(p, 'slider', default_slider);
addParameter(p, 'movieFileName', default_filename);
addParameter(p, 'timeStep', default_dt);
addParameter(p, 'fps', default_fps);
parse(p,varargin{:});


slider = p.Results.slider;
dt = p.Results.timeStep;
filename = p.Results.movieFileName;
fps = p.Results.fps;

prms = traj.getPrms();

[t, x, ~] = traj.interp(dt);
th = x(:,1);
phi = x(:,7);

[xp, yp] = traj.getXY(dt);

f = figure(25);
clf

set(gcf, 'Position', [500   300   640   640]);
set(gcf,'color','w');
if slider
    ax = axes('Parent',f,'position',[0.1 0.15  0.8 0.8]);
    b = uicontrol('Parent',f,'Style','slider','Position',[60,30,520,20],...
              'value',1, 'min',1, 'max',numel(t), 'SliderStep', [1 1]/numel(t));
    bgcolor = f.Color;
    bl1 = uicontrol('Parent',f,'Style','text','Position',[20,23,23,23],...
                    'String',sprintf('%.2f', t(1)),'BackgroundColor',bgcolor);
    bl2 = uicontrol('Parent',f,'Style','text','Position',[600,23,23,23],...
                    'String',sprintf('%.2f', t(end)),'BackgroundColor',bgcolor);
    bl3 = uicontrol('Parent',f,'Style','text','Position',[280,0,100,23],...
                    'String','Time [s]','BackgroundColor',bgcolor);
    b.Callback = @(es,ed) update(round(es.Value));                 
else
   ax = axes();
end
set(gca,'YDir','Reverse');
axis(1.2*prms.Ro*[-1 1 -1 1])
axis equal
xticks([])
yticks([])
box on
grid on

h_title = title(sprintf('Time: %2.2f', 0));

Nhoop = 16;
circ_x = zeros(Nhoop+1,4);
circ_y = zeros(Nhoop+1,4);

th_q1 = linspace(0, pi/2, Nhoop);
circ_x(:,1) = [cos(th_q1) 0]';
circ_y(:,1) = [sin(th_q1) 0]';

th_q2 = linspace(pi/2, pi, Nhoop);
circ_x(:,2) = [cos(th_q2) 0]';
circ_y(:,2) = [sin(th_q2) 0]';

th_q3 = linspace(pi, 3*pi/2, Nhoop);
circ_x(:,3) = [cos(th_q3) 0]';
circ_y(:,3) = [sin(th_q3) 0]';

th_q4 = linspace(3*pi/2, 2*pi, Nhoop);
circ_x(:,4) = [cos(th_q4) 0]';
circ_y(:,4) = [sin(th_q4) 0]';

hoop_dark = [157,153,173]/255;
hoop_bright = [194,188,213]/255;

ball_dark = [96,154,101]/255;
ball_bright = [188,213,190]/255;
hold on
% Hoop
h_hoop(1) = fill(ax, 1.05*prms.Ro*circ_x(:,1), 1.05*prms.Ro*circ_y(:,1), hoop_dark);
h_hoop(2) = fill(ax, 1.05*prms.Ro*circ_x(:,2), 1.05*prms.Ro*circ_y(:,2), hoop_bright);
h_hoop(3) = fill(ax, 1.05*prms.Ro*circ_x(:,3), 1.05*prms.Ro*circ_y(:,3), hoop_dark);
h_hoop(4) = fill(ax, 1.05*prms.Ro*circ_x(:,4), 1.05*prms.Ro*circ_y(:,4), hoop_bright);
thtmp = 0:0.1:2*pi;
fill(ax, prms.Ro*cos(thtmp), prms.Ro*sin(thtmp), [1 1 1])

% Hoop - inner
h_hoop2(1) = fill(ax, prms.Ri*circ_x(:,1), prms.Ri*circ_y(:,1), hoop_dark);
h_hoop2(2) = fill(ax, prms.Ri*circ_x(:,2), prms.Ri*circ_y(:,2), hoop_bright);
h_hoop2(3) = fill(ax, prms.Ri*circ_x(:,3), prms.Ri*circ_y(:,3), hoop_dark);
h_hoop2(4) = fill(ax, prms.Ri*circ_x(:,4), prms.Ri*circ_y(:,4), hoop_bright);

% Ball
h_ball(1) = fill(ax, prms.Rb*circ_x(:,1), prms.Rb*circ_y(:,1), ball_dark);
h_ball(2) = fill(ax, prms.Rb*circ_x(:,2), prms.Rb*circ_y(:,2), ball_bright);
h_ball(3) = fill(ax, prms.Rb*circ_x(:,3), prms.Rb*circ_y(:,3), ball_dark);
h_ball(4) = fill(ax, prms.Rb*circ_x(:,4), prms.Rb*circ_y(:,4), ball_bright);
hold off


if ~isempty(filename)
    vidObj = VideoWriter(filename);
    vidObj.Quality = 95;
    vidObj.FrameRate = fps;
    open(vidObj);
end

for i = 1:(numel(t)-1)
    tic
    
    if slider
        set(b, 'Value', i);
    end
    
    fprintf('Time %2.2f/%2.2f\n', t(i), t(end));
        
    update(i);
    if ~isempty(filename)
        writeVideo(vidObj, getframe(gcf));
    end
               
    t_elapsed = toc;
    dt = (t(i+1)-t(i));
    if (dt - t_elapsed) > 0
        pause((dt - t_elapsed));
    end
    
%     pause(0.1);
end

if ~isempty(filename)
    close(vidObj);
end

function update(i)    
    showHoop(th(i), h_hoop, h_hoop2, circ_x, circ_y, prms);    
    showBall(xp(i), yp(i), phi(i), h_ball, circ_x, circ_y, prms);
    set(h_title, 'String', sprintf('Time: %2.2f s', t(i)));
    drawnow;
end
end

function [xp, yp] = transf(x, y, ang, l)
    T = [cos(ang) -sin(ang) l(1); sin(ang) cos(ang) l(2); 0 0 1];
    tmp = T*[x(:)'; y(:)'; ones(1, numel(x))];
    xp = tmp(1,:)';
    yp = tmp(2,:)';
end

function showHoop(th, h_hoop, h_hoop2, circ_x, circ_y, prms)
    for i=1:4
        [xtmp, ytmp] = transf(1.05*prms.Ro*circ_x(:,i), 1.05*prms.Ro*circ_y(:,i), -th, [0 0]);
        set(h_hoop(i), 'XData', xtmp, 'YData', ytmp);
        
        [xtmp, ytmp] = transf(prms.Ri*circ_x(:,i), prms.Ri*circ_y(:,i), -th, [0 0]);
        set(h_hoop2(i), 'XData', xtmp, 'YData', ytmp);
    end
end

function showBall(xp, yp, phi, h_ball, circ_x, circ_y, prms)
    for k=1:4
        xtmp = prms.Rb*circ_x(:,k);
        ytmp = prms.Rb*circ_y(:,k);
        [xtmp, ytmp] = transf(xtmp, ytmp, -phi, [0; 0]);
        set(h_ball(k), 'XData', xtmp+xp, 'YData', ytmp+yp);
    end
end