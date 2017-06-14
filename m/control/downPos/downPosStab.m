clear all;
addpath('../../')
addpath('../../utils')
params_init;

load('calibData_hom.mat')

%% Design a LQR stabilizying the trajectory
Q = 1e1*diag([.025, 5, .25]);
R = 50;

K = downpos_K(Q, R, prms);