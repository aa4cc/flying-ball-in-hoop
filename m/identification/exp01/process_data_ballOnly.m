clear all
clc
addpath('../../')
params_init;

expNum = 1;

load(sprintf('meas_ballOnly%02d.mat', expNum))
%%
t = meas_pos.Time;
psi = meas_pos.Data(:,4);

figure(1)
clf
plot(t, psi)

[t_StartEnd,~] = ginput(2);
t_Start = t_StartEnd(1);
t_End = t_StartEnd(2);

I = t>=t_Start & t<t_End;
psi = psi(I);
t = t(I);
t = t - t(1);

psi = double(psi);
Dpsi = diff(psi)/prms.Ts;
t = double(t);
%%
figure(1)
clf
plot(t, psi)

%%
psi0 = psi(1);
%%
% z0 = [1; Dpsi(1)];
z0 = [-0.1; Dpsi(1); -71.3488];

opts = optimoptions('fminunc', 'Display', 'iter');
zf = fminunc(@(x) costFunBallOnly(x, t, psi, prms, prmsf), z0, opts);

bb = 1e-6*zf(1)

return;

%%

[t_optim, y_optim] = ode45(@(t,x) [x(2); apsi2_optim*sin(x(1)) + apsi3_optim*x(2)], [t(1); t(end)], [psi0; 0]);
y_optim = y_optim(:,1);

plot(t, psi, t_optim, y_optim, '--')
grid on
xlabel('Time [s]')
ylabel('Psi [rad]')
legend('Measured', 'Identified by optim.')

