addpath('vgg/')
%% Take a snapshot from the raspi cam
resp = webread(['http://', ip_rpi, ':', num2str(port_rpi), '/lamp/on']);
if ~strcmp(resp(1:2), 'OK')
    error('Raspi-ballpos webserivce is not available.')
end
pause(1)

figure(1)
imagesc(raspiGetImage(ip_rpi, 'Red'));
axis equal
webread(['http://', ip_rpi, ':', num2str(port_rpi), '/lamp/off']);
%%
% load('measured_pos.mat')

resp = webread(['http://', ip_rpi, ':', num2str(port_rpi), '/lamp/on']);
set_param('cameraCalib', 'SimulationCommand', 'start')
pause(10)
webread(['http://', ip_rpi, ':', num2str(port_rpi), '/lamp/off']);
%%

x = measured_pos.signals.values(1,:)';
y = measured_pos.signals.values(2,:)';
x_steadypos = x(1);  %x coordinate of the ball in the steady position
y_steadypos = y(1);  %y coordinate of the ball in the steady position

circle_lsq = @(z) ((x-z(1)).^2 + (y-z(2)).^2 - z(3)^2); % z = [xc; yc; r]

%%
z0 = [240;240;240];
z_opt = lsqnonlin(circle_lsq, z0);

xc_opt = z_opt(1);
yc_opt = z_opt(2);
r_opt = z_opt(3);
%%
th = linspace(0, 2*pi, 100);
ximg_circ = r_opt*cos(th) + xc_opt;
yimg_circ = r_opt*sin(th) + yc_opt;
figure(1)

hold on
plot(x, y, '.')
plot(ximg_circ, yimg_circ)
plot(x_steadypos, y_steadypos, 'o')
hold off

axis equal
set(gca, 'YDir', 'reverse')
%%
xreal_circ = 1e3*(prms.Ro-prms.Rb)*cos(th);
yreal_circ = 1e3*(prms.Ro-prms.Rb)*sin(th);

%%
zs1 = [ximg_circ; yimg_circ];
zs2 = [xreal_circ; yreal_circ];

H_unrot = vgg_H_from_x_lin(zs1,zs2);
%% Back-project the tru poisitons of the true screw positions
zs = H_unrot\[zs2; ones(1,numel(ximg_circ)) ];
zs_x = zs(1,:)./zs(3,:);
zs_y = zs(2,:)./zs(3,:);

xc = zs_x(end);
yc = zs_y(end);
%% Plot the identified hoop positions
R = 1e3*[prms.Rui, prms.Ro, prms.Ro-prms.Rb, prms.Rui+prms.Rb];
c = [1 0 0;
     1 0 0;
     0.5 0.5 0.5;
     0.5 0.5 0.5];
for i = 1:numel(R)
    x_tmp = R(i)*cos(th);
    y_tmp = R(i)*sin(th);
    
    zs = H_unrot\[x_tmp; y_tmp; ones(1,numel(th)) ];
    zs_x = zs(1,:)./zs(3,:);
    zs_y = zs(2,:)./zs(3,:);
    
    hold on
    plot(zs_x, zs_y, 'Color', c(i,:))
    hold off
end

%% Calculate the psi angle from the measured positions
Rot = @(th) [cos(th) -sin(th) 0; sin(th) cos(th) 0; 0 0 1];
z_ball = H_unrot*[x_steadypos; y_steadypos'; 1];
z_ball_x = z_ball(1)/z_ball(3);
z_ball_y = z_ball(2)/z_ball(3);
th0 = atan2(z_ball_y, z_ball_x);

H = Rot(-th0)*H_unrot;
save calibMatrix H