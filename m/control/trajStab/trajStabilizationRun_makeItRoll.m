clear all;
params_init;

doubleRoll = 1;

load('calibData_hom.mat')
% load('rollIt_N50_T1.5_umax1.mat') % *1.15
% load('rollIt_N50_T1.5_umax1_WORKING.mat') % *1.3
% load('rollIt_N50_T1.4_umax1_WORKING_AllPsi.mat') % Works without a scaling factor and the trajectory also maximizes psi along all trajectory
load('rollIt_N75_T1.5_umax1.mat') % Maximizes psi only in the middle of the trajectory

[t, x, u] = traj.interp(prms.Ts);
x = x(:,1:4); % The state trajectory contains states [th, Dth, psi, Dpsi, r, Dr, phi, Dphi] but we need only [th, Dth, psi, Dpsi]

% The trajectory contains also the final time with zero input. That is
% something we do not need here
t = t(1:end-1,:);
x = x(1:end-1,:);
u = u(1:end-1,:);
%% Design a LQR stabilizying the trajectory
% Q = 10*diag([.1, 10, 1]);
% Qf = Q;
% R = 10;
Q = diag([1, 500, 100]); 
Qf = Q;
R = 10;

Q_dwn = 1e2*diag([.1, 5, 1]);
R_dwn = 10;

[K_down, S_down] = downpos_K(Q_dwn, R_dwn, prms);
K = trajStabController( t, x, u, prms.Ts, Q, S_down, R, prms );
% K = trajStabController_continous( t, x, u, Q, S_down, R, prms );
K = squeeze(K);

N = numel(t);
NdoNothing = round(1.5/prms.Ts);
% t = 0:prms.Ts:(2*N + 3*NdoNothing-1)*prms.Ts;

K_down = -repmat(K_down, NdoNothing, 1);
% K_2 = [K_down; K; K_down; K; K_down];
% 
% u_2 = [zeros(NdoNothing,1); u];
% u_2 = [u_2; -u_2; zeros(NdoNothing,1)];
% 
% x_2 = [zeros(NdoNothing,3); x(:,2:end)];
% 
% xtmp = x_2;
% xtmp(:,2) = xtmp(:,2)+2*pi;
% x_2 = [x_2; -xtmp; zeros(NdoNothing,3)];

if ~doubleRoll
    K_2 = [K_down;K;K_down];
    u_2 = [zeros(NdoNothing,1); u; zeros(NdoNothing,1)];
    x_2 = [repmat([0 0 0], NdoNothing, 1);x(:,2:end); repmat([0 -2*pi 0], NdoNothing, 1)];
    t = 0:prms.Ts:(N + 2*NdoNothing-1)*prms.Ts;
else
    K_2 = [K_down;K;K_down;K;K_down];
    u_2 = [zeros(NdoNothing,1); u; zeros(NdoNothing,1); -u; zeros(NdoNothing,1)];
    
    xtmp = x;
    xtmp(:,3) = xtmp(:,3)+2*pi;

    x_2 = [repmat([0 0 0], NdoNothing, 1);x(:,2:end); repmat([0 -2*pi 0], NdoNothing, 1); -xtmp(:,2:end); repmat([0 0 0], NdoNothing, 1)];
    t = 0:prms.Ts:(2*N + 3*NdoNothing-1)*prms.Ts;
end
K_TS = timeseries(K_2, t);
x_star_TS = timeseries(x_2, t);
u_star_TS = timeseries(u_2, t);

%% Initialization for Simulation
th0 = 0;
Dth0 = 0;
psi0 = 0;
Dpsi0 = 0;

sim('simul/ballInaHoop_trajStab', [0 t(end)]);
t_sim = simData.Time;
x_sim = simData.Data(:,1:8);
u_sim = simData.Data(:,9);

visu(Traj(t_sim, x_sim, u_sim, prms), 'slider', 1)
return;

%%
K_TS = timeseries(single(K_2), t);
x_star_TS = timeseries(single(x_2), t);
% u_star_TS = timeseries(single(1.3*u_2), t);
u_star_TS = timeseries(single(u_2), t);