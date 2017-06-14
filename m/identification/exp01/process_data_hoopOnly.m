% load('meas_hoop01_f20_a01.mat')
% load('meas_hoop01_f10_a01.mat')
% load('meas_hoop01_f05_a01.mat')
% load('meas_hoop01_f2.500000e+00_a01.mat')
% load('meas_hoop01_prbs.mat')
load('meas_hoop02_chirp.mat')

u = double(meas_pos.Data(:,1));
th = double(meas_pos.Data(:,2));
Dth = double(meas_pos.Data(:,3));

Dth2 = diff(th)/prms.Ts;
Dth2 = [Dth2; Dth2(end)];
%%
a = 658.8;
b = [1.0000    0.28];

A = -b(2)/b(1);
B = a/b(1);

ath1 = A;
bth1 = B;

Ih = 1/a;