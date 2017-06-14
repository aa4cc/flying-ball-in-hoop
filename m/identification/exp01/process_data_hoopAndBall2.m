clear all
clc
addpath('../../')
params_init;

expNum = 2;

load(sprintf('meas_hoopAndBall2_%02d.mat', expNum))
%%
delay = 2;
tEnd = 15;
t = meas_pos.Time(1:(tEnd/prms.Ts)-delay);
u = meas_pos.Data(1:(tEnd/prms.Ts)-delay,1);
th = meas_pos.Data(1:(tEnd/prms.Ts)-delay,2);
Dth = meas_pos.Data(1:(tEnd/prms.Ts)-delay,3);
psi = meas_pos.Data((1+delay):(tEnd/prms.Ts),4);

u = double(u);
th = double(th);
Dth = diff(double(th))/prms.Ts; Dth(end+1) = Dth(end); 
psi = double(psi);

%%
figure(1)
clf

subplot(411)
plot(t, u)

subplot(412)
plot(t, th)

subplot(413)
plot(t, Dth)

subplot(414)
plot(t, psi)
%%
z0 = [];
% % z0(1) = prms.ath1/5;
% z0(1) = -.4;
% z0(2) = 0.5*prms.ath2/10;
% % z0(3) = prms.ath3;
% z0(3) = prms.bth/600;
% % z0(3) = 658/600;
% z0(4) = 0.7*0.3473;
% % z0(6) = prms.apsi2;
% z0(5) = -z0(4);
% z0(6) = 0.8*prms.bpsi/300;

z0(1) = prms.ath1;
z0(2) = prms.ath2/10;
z0(3) = prms.bth/600;
z0(4) = prms.apsi1*10;
z0(5) = prms.apsi3;
z0(6) = prms.bpsi/300;

opts = optimoptions('fminunc', 'Display', 'iter');
zf = fminunc(@(z) costFunHoopAndBall2(z, t, Dth, psi, u, prms), z0, opts);

ath1	= 	zf(1)
ath2	= 	zf(2)*10
ath3	= 	prms.ath3
bth		= 	600*zf(3)
apsi1	= 	zf(4)/10
apsi2	= 	prms.apsi2
apsi3	= 	zf(5)
bpsi	= 	300*zf(6)

