clear all
clc
addpath('../../')
params_init;

expNum = 2;

load(sprintf('meas_hoopAndBall%02d.mat', expNum))
%%
t = meas_pos.Time;
th = meas_pos.Data(:,2);
Dth = meas_pos.Data(:,3);
psi = meas_pos.Data(:,4);

figure(1)
clf
subplot(211)
plot(t, th)

subplot(212)
plot(t, psi)

[t_StartEnd,~] = ginput(2);
t_Start = t_StartEnd(1);
t_End = t_StartEnd(2);

I = t>=t_Start & t<t_End;
th = th(I);
Dth = Dth(I);
psi = psi(I);
t = t(I);
t = t - t(1);
th = th - th(1);

th = double(th);
Dth = double(Dth);
psi = double(psi);

Dth2 = diff(th)/prms.Ts;
Dpsi2 = diff(psi)/prms.Ts;

th0 = th(1);
psi0 = psi(1);
%%
figure(1)
clf

subplot(311)
plot(t, th)

subplot(312)
plot(t, Dth)

subplot(313)
plot(t, psi)
%%
z0 = [-1; -Dth2(1);Dpsi2(1)];

z0(1) = prmsf.ath1_f(prms.Rb,	prms.Ro, prms.m, prms.g,	prms.Ib, prms.Ih, prms.bb, 0.007);
z0(4) = prmsf.ath2_f(prms.Rb,	prms.Ro, prms.m, prms.g,	prms.Ib, prms.Ih, prms.bb, 0.007);
z0(5) = prmsf.ath3_f(prms.Rb,	prms.Ro, prms.m, prms.g,	prms.Ib, prms.Ih, prms.bb, 0.007);
z0(6) = prmsf.apsi1_f(prms.Rb,	prms.Ro, prms.m, prms.g,	prms.Ib, prms.Ih, prms.bb, 0.007);

opts = optimoptions('fminunc', 'Display', 'iter');
zf = fminunc(@(z) costFunHoopAndBall(z, t, th, psi, prms, prmsf), z0, opts);

ath1 = zf(1)
ath2 = zf(4)
ath3 = zf(5)
apsi1 = zf(6)

