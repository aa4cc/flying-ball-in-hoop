clear all;
addpath('../../')
addpath('../../trajStabilization')
params_init;

load('makeItOscilate_N50_T0.9_umax100.mat')
load('calibData_hom.mat')

[t, x, u] = traj.interp(prms.Ts);
x = [0 0 0 0; x(:,1:4)];
u = [u;u(end)];
t = [t;t(end)+prms.Ts];
%% Design a LQR stabilizying the trajectory
Q = 1e2*diag([.1, 1, .5]);
Qf = Q;
R = 5e-1;

K = trajStabController_continous( t, x, prms.Ts, Q, Qf, R, prms );
K = squeeze(K);

N = numel(t);
k = 100;
t = 0:prms.Ts:(k*N-1)*prms.Ts;
x = single(repmat(x, k, 1));
u = single(repmat(u, k, 1));
K = single(repmat(K, k, 1));

K_TS = timeseries(K, t);
x_star_TS = timeseries(x(:,2:end), t);
u_star_TS = timeseries(u, t);

%% Simulation
th0 = 0;
Dth0 = 0;
psi0 = 0;
Dpsi0 = 0;

P0 = single(eye(2));
x0 = single([psi0; Dpsi0]);