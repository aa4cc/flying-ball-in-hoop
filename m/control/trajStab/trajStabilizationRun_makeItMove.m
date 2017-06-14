clear all;
params_init;

load('makeItOscilate_N50_T0.8_umax2.mat')
load('calibData_hom.mat')

[t, x, u] = traj.interp(prms.Ts);
x = x(:,1:4); % The state trajectory contains states [th, Dth, psi, Dpsi, r, Dr, phi, Dphi] but we need only [th, Dth, psi, Dpsi]

% The trajectory contains also the final time with zero input. That is
% something we do not need here
t = t(1:end-1,:);
x = x(1:end-1,:);
u = u(1:end-1,:);
%% Design a LQR stabilizying the trajectory
Q = 1e2*diag([.1, 1, .5]);
Qf = Q;
R = .1;

K = trajStabController( t, x, u, prms.Ts, Q, Qf, R, prms );
K = squeeze(K);

N = numel(t);
k = 40;
t = 0:prms.Ts:(k*N-1)*prms.Ts;
x = repmat(x, k, 1);
u = repmat(u, k, 1);
K = repmat(K, k, 1);

K_TS = timeseries(K, t);
x_star_TS = timeseries(x(:,2:end), t);
u_star_TS = timeseries(u, t);

%% Simulation
th0 = 0;
Dth0 = 0;
psi0 = 0;
Dpsi0 = 0;

sim('simul/ballInaHoop_trajStab', [0 t(end)+1.5]);
t_sim = simData.Time;
x_sim = simData.Data(:,1:8);
u_sim = simData.Data(:,9);

visu(Traj(t_sim, x_sim, u_sim, prms), 'slider', 1)
return;


%%
K_TS = timeseries(single(K), t);
x_star_TS = timeseries(single(x(:,2:end)), t);
u_star_TS = timeseries(single(u), t);
