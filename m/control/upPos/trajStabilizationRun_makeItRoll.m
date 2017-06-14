clear all;
addpath('../../')
addpath('../../utils')
addpath('../../trajOptim')
params_init;

load('rollIt_N75_T1.5_umax200.mat')
load('calibData_hom.mat')

[t, x, u] = traj.interp(prms.Ts);
x = [0 0 0 0; x(:,1:4)];
u = [u;u(end)];
t = [t;t(end)+prms.Ts];
%% Design a LQR stabilizying the trajectory
Q = 1e2*diag([.1, 5, .5]);
Qf = Q;
R = .15e-1;

% Q = 1e2*diag([.1, 10, .5]);
% Qf = Q;
% R = .25e-1;

% [1e1 5e3 1e1]), .2e-1
[K_down, S_down] = downpos_K(Q, R, prms);
K = trajStabController_continous( t, x, prms.Ts, Q, S_down, R, prms );
K = squeeze(K);

N = numel(t);
NdoNothing = round(3/prms.Ts);
t = 0:prms.Ts:(2*N + 3*NdoNothing-1)*prms.Ts;

K_down = -repmat(K_down, NdoNothing, 1);
K_2 = [K_down; K; K_down; K; K_down];

u_2 = [zeros(NdoNothing,1); u];
u_2 = [u_2; -u_2; zeros(NdoNothing,1)];

x_2 = [zeros(NdoNothing,3); x(:,2:end)];

xtmp = x_2;
xtmp(:,2) = xtmp(:,2)+2*pi;
x_2 = [x_2; -xtmp; zeros(NdoNothing,3)];

%% Initialization for Simulation
th0 = 0;
Dth0 = 0;
psi0 = 0;
Dpsi0 = 0;

P0 = eye(2);
x0 = [psi0; Dpsi0];

K_TS = timeseries(K_2, t);
x_star_TS = timeseries(x_2, t);
u_star_TS = timeseries(u_2, t);

sim('simul/ballInaHoop_trajStab', [0 t(end)+1.5]);
t_sim = simData.Time;
x_sim = simData.Data(:,1:8);
u_sim = simData.Data(:,9);

visu(Traj(t_sim, x_sim, u_sim, prms), 'slider', 1)
return;

% visu(Traj(t_sim_withFB, x_sim_withFB, u_sim_withFB, prms),1, 1/240, 'makeItRoll')
%% Initialization for experiments on real hardware
th0 = 0;
Dth0 = 0;
psi0 = 0;
Dpsi0 = 0;

P0 = single(eye(2));
x0 = single([psi0; Dpsi0]);

K_TS = timeseries(single(K_2), t);
x_star_TS = timeseries(single(x_2), t);
u_star_TS = timeseries(single(u_2), t);