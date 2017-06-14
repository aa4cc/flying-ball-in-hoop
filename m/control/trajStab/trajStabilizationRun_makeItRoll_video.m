clear all;
addpath('../../')
addpath('../../trajStabilization')
addpath('../../trajOptim')
params_init;

load('rollIt_N75_T1.5_umax200.mat')
load('calibData_hom.mat')

Ts = 1/240;

[t, x, u] = traj.interp(Ts);
x = [0 0 0 0; x(:,1:4)];
u = [u;u(end)];
t = [t;t(end)+Ts];
%% Design a LQR stabilizying the trajectory
Q = 1e2*diag([.1, 5, .5]);
Qf = Q;
R = .25e-1;

[K_down, S_down] = downpos_K(Q, R, prms);
K = trajStabController_continous( t, x, Ts, Q, S_down, R, prms );
K = squeeze(K);

N = numel(t);
NdoNothing = round(.5/Ts);
t = 0:Ts:(N + 2*NdoNothing-1)*Ts;

K_down = -repmat(K_down, NdoNothing, 1);
K_2 = [K_down; K; K_down];

u_2 = [zeros(NdoNothing,1); u; zeros(NdoNothing,1)];

x_2 = [zeros(NdoNothing,3); x(:,2:end)];
xtmp = zeros(NdoNothing,3);
xtmp(:,2) = xtmp(:,2)+2*pi;
x_2 = [x_2; -xtmp;];

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

sim('simul/ballInaHoop_trajStab', [0 t(end)]);
t_sim = simData.Time;
x_sim = simData.Data(:,1:8);
u_sim = simData.Data(:,9);
%%
visu(traj, ...
    'timeStep', 1/240, ...
    'movieFileName', 'makeItRoll_8x', ...,
    'fps', 30);
%%
visu(traj, ...
    'timeStep', 1/30, ...
    'movieFileName', 'makeItRoll_1x', ...,
    'fps', 30);