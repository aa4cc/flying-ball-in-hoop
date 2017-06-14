addpath('vgg/')
addpath('../../')
params_init;

expNum = 1;

img = imread(sprintf('meas_pos%02d.png', expNum));

figure(1)
clf
imshow(img);

%% Mark the outer screw positions in clock-wise direction on the hoop; as the last (7th) point, mark the center of the hoop
disp('Mark the outer screw positions in clock-wise direction on the hoop; as the last (13th) point, mark the center of the hoop')
[x_screw_marked, y_screw_marked] = ginput(13);

disp('Mark the position of the ball in the bottom stable position')
[x_ball, y_ball] = ginput(1);

hold on
plot(x_screw_marked, y_screw_marked, 'y*')
hold off
%% Calculate the homograpy matrix
th = (0:30:340)'/180*pi;
x_screw_real = 104.1398 * cos(th);
y_screw_real = 104.1398 * sin(th);

x_screw_real = [x_screw_real; 0];
y_screw_real = [y_screw_real; 0];

zs1 = [x_screw_marked'; y_screw_marked'];
zs2 = [x_screw_real'; y_screw_real'];

H_unrot = vgg_H_from_x_lin(zs1,zs2);
Hinv = inv(H_unrot);

%% Back-project the tru poisitons of the true screw positions
zs = Hinv*[zs2; ones(1,numel(x_screw_marked)) ];
zs_x = zs(1,:)./zs(3,:);
zs_y = zs(2,:)./zs(3,:);

xc = zs_x(end);
yc = zs_y(end);

hold on
plot(zs_x, zs_y, 'ro')
hold off

%% Plot the identified hoop positions
th = 0:.1:2*pi;
th = [th th(1)];

R = 1e3*[prms.Ri, prms.Ro, prms.Ro-prms.Rb, prms.Ri+prms.Rb];
c = [1 0 0;
     1 0 0;
     0.5 0.5 0.5;
     0.5 0.5 0.5];
for i = 1:numel(R)
    x_tmp = R(i)*cos(th);
    y_tmp = R(i)*sin(th);
    
    zs = Hinv*[x_tmp; y_tmp; ones(1,numel(th)) ];
    zs_x = zs(1,:)./zs(3,:);
    zs_y = zs(2,:)./zs(3,:);
    
    hold on
    plot(zs_x, zs_y, 'Color', c(i,:))
    hold off
end

%% Plot the measured positions to the image
load(sprintf('meas_pos%02d.mat', expNum) )
x = double(meas_pos.Data(1,:));
y = double(meas_pos.Data(2,:));
t = meas_pos.Time;

hold on
plot(x, y, 'g.')
hold off

%% Calculate the psi angle from the measured positions
Rot = @(th) [cos(th) -sin(th) 0; sin(th) cos(th) 0; 0 0 1];
z_ball = H_unrot*[x_ball; y_ball'; 1];
z_ball_x = z_ball(1)/z_ball(3);
z_ball_y = z_ball(2)/z_ball(3);
th0 = atan2(z_ball_y, z_ball_x);

H = Rot(-th0)*H_unrot;
zp = H*[x(:)'; y(:)'; ones(1, numel(x))];
xp2 = zp(1,:)'./zp(3,:)';
yp2 = zp(2,:)'./zp(3,:)';
th = unwrap(atan2(yp2, xp2));

figure(2)
clf
plot(t, th)
xlabel('Time [s]')
ylabel('Psi [rad]')
grid on

save calibData_hom H
%%
return
%%
th = th(t>2);
t = t(t>2);
t = t-t(1);

[~, I] = max(th);
t = t(I:end) - t(I);
th = th(I:end)-th(end);
th0 = th(1);

Iend = numel(t);
t = t(1:Iend);
th = th(1:Iend);
%%
k1_calc = -1 / prms.out.a_bar*prms.out.b_bar
k2_calc = -1 / prms.out.a_bar*prms.out.c_bar

xf = fminunc(@(x) costFun(x, t, th, th0), [-1; -87]);
k1_optim = xf(1)
k2_optim = xf(2)

b_bar_optim = -k1_optim*prms.out.a_bar
c_bar_optim = -k2_optim*prms.out.a_bar

% friction coefficient identified by optimization
b_optim = b_bar_optim/prms.Ro^2*prms.Rb^2

%%
[t_calc, y_calc] = ode45(@(t,x) [x(2); k2_calc*sin(x(1)) + k1_calc*x(2)], [t(1); t(end)], [th0; 0]);
y_calc = y_calc(:,1);

[t_optim, y_optim] = ode45(@(t,x) [x(2); k2_optim*sin(x(1)) + k1_optim*x(2)], [t(1); t(end)], [th0; 0]);
y_optim = y_optim(:,1);

plot(t, th, t_calc, y_calc, t_optim, y_optim, '--')
grid on
xlabel('Time [s]')
ylabel('Psi [rad]')
legend('Measured', 'Known + lucky guess', 'Identified by optim.')