clear all;
addpath('../../')
addpath('../../utils')
params_init;
ctrl_analysis_up;

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

%% Generate optimal traj.
[t, x, u] = traj.interp(prms.Ts/50);
t_S1 = t;
psi_S1 = x(:,3);
Dpsi_S1 = x(:,4);
Dth_S1 = x(:,2);
r_S1 = x(:,5);
u_S1 = u;

x0 = [+prms.Ro-prms.Rb; 0; psi_S1(end); Dpsi_S1(end)];
options = odeset('RelTol',1e-8,'AbsTol',1e-10);
[tt, z] = ode45(@(t, x) [x(2); x(1)*x(4)^2 + prms.g*cos(x(3)); x(4); -(prms.g*sin(x(3)) + 2*x(4)*x(2))/x(1) ], [0 .2], x0, options);

I = z(:,1)>(prms.Ri+prms.Rb);
I(1) = 0;
r_S2 = z(I,1);
t_S2 = tt(I) + t_S1(end);
psi_S2 = z(I,3);
Dpsi_S2 = z(I,4);

% Dth
% Cost function expressing Dpsi^2 + Dth_t2^2
psi_res = x(end,3);
Dpsi_res = x(end,4);
f = @(Dth_t1, Dth_t2) (Dth_t2 + prms.Ro/prms.Ri*(Dth_t1 - Dpsi_res) - (prms.Ro - prms.Rb)/(prms.Ri+prms.Rb)*cos(psi_res)*Dpsi_res).^2 + Dth_t2.^2;
options = optimoptions('fmincon','Display','iter','Algorithm','sqp');
X = fminunc(@(x) f(x(1), x(2)), [0;0], options);
Dth_t1 = X(1);
Dth_t2 = X(2);

Dth_S2 = linspace(Dth_t1, Dth_t1, numel(t_S2))';
%
t_S3 = [0 1]' + t_S2(end) + 1e-4;
psi_S3 = -pi*[1;1];
Dpsi_S3 = [0;0];
Dth_S3 = [0;0];
r_S3 = (prms.Ri+prms.Rb)*[1; 1];
%
u_S2 = zeros(numel(t_S2),1);
u_S3 = zeros(numel(t_S3),1);
%
t_S = [t_S1; t_S2; t_S3];
psi_S = [psi_S1; psi_S2; psi_S3];
Dpsi_S = [Dpsi_S1; Dpsi_S2; Dpsi_S3];
Dth_S = [Dth_S1; Dth_S2; Dth_S3];
r_S = [r_S1; r_S2; r_S3];
u_S = [u_S1; u_S2; u_S3];

subplot(311)
plot(t_S, psi_S, t_sim_withFB, x_sim_withFB(:,3), '--')

subplot(312)
plot(t_S, Dpsi_S, t_sim_withFB, x_sim_withFB(:,4), '--')

subplot(313)
plot(t_S, Dth_S, t_sim_withFB, x_sim_withFB(:,2), '--')

%%
% save experiments/simul_exp02 t_sim_withFB x_sim_withFB u_sim_withFB t_S psi_S Dpsi_S Dth_S r_S u_S

visu(Traj(t_sim_withFB, x_sim_withFB, u_sim_withFB, prms), 'slider', 1)