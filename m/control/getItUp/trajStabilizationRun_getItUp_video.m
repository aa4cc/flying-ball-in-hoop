clear all;
addpath('../../')
addpath('../../trajStabilization')
params_init;
ctrl_analysis_up;

% load('getItUp_N50_T1.5_umax150.mat')
load('getItUp_N75_T1.5_umax150.mat')
load('calibData_hom.mat')

[t, x, u] = traj.interp(prms.Ts);

x = [0 0 0 0; x(:,1:4)];
u = [u;u(end)];
t = [t;t(end)+prms.Ts];
%% Design a LQR stabilizying the trajectory
Q = 1e3*diag([1, 2, .2]);
Qf = 2*Q;
R = .2e0;

K = trajStabController_continous( t, x, prms.Ts, Q, Qf, R, prms );
K = squeeze(K);

N = numel(u);
NdoNothing = 0;
t = 0:prms.Ts:((N+NdoNothing)-1)*prms.Ts;

K = [zeros(NdoNothing, 3); K];
u = [zeros(NdoNothing,1); u];
x = [zeros(NdoNothing,4); x];

% u = u;
% x = x;
% K = K;

K_TS = timeseries(K, t);
x_star_TS = timeseries(x(:,2:end), t);
u_star_TS = timeseries(u, t);

% -40.1194
% Dphi = (x_star(end,1) - x_star(end,3))*prms.Ro/prms.Rb;
% Dx = (prms.Ro-prms.Rb)*cos(psi)*Dpsi;
% Dy = (prms.Ro-prms.Rb)*cos(psi)*Dpsi;
% dpsi_mode3_enter = prms.Rb/prms.Ri*Dphi - sqrt(Dx^2+Dy^2)/(prms.Ri+prms.Rb)*sin(atan2(0,-prms.Ri-prms.Rb)-atan2(Dx,Dy));
%% Simulation
th0 = 0;
Dth0 = 0;
psi0 = 0;
Dpsi0 = 0;

P0 = eye(2);
x0 = [psi0; Dpsi0];

%% Simulation
sim('simul/ballInaHoop_getItUp', [0 t(end)+1.5]);
t_sim_withFB = simData.Time;
x_sim_withFB = simData.Data(:,1:8);
u_sim_withFB = simData.Data(:,9);

traj = Traj(t_sim_withFB, x_sim_withFB, u_sim_withFB, prms);

%%
visu(traj, ...
    'timeStep', 1/240, ...
    'movieFileName', 'getItUp_8x', ...,
    'fps', 30);
%%
visu(traj, ...
    'timeStep', 1/30, ...
    'movieFileName', 'getItUp_1x', ...,
    'fps', 30);