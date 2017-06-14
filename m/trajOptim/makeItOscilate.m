clear all;
addpath('..')
addpath('../utils')
addpath('costAndConstrFunctions\')
params_init;

% Number of knots
N = 50;
umax = 2;
psi_des = -70/180*pi;
x0 = [0;0;psi_des;0];
xf_des = [0;0;psi_des;0];

xf_hardcon{1}.n = N;
xf_hardcon{1}.k = 1;
xf_hardcon{1}.x = xf_des;

xf_hardcon{2}.n = N/2;
xf_hardcon{2}.k = 3;
xf_hardcon{2}.x = [-psi_des;0];

[ t_star, u_star, x_star, Ts ] = trajOptim_coll_opti(xf_des, N, prms, ...
    'umax', umax, ...
    'costFun', @costFun_u, ...
    'x0', x0, ...
    'xf_hardcon', xf_hardcon, ...
    'grad', @costFun_u_grad, ...
    'nlcon_eq', @collocation_nonlncon_eq2, ...
    'nlcon_eq_jac', @collocation_nonlncon_eq_J2, ...
    'nlcon_neq', @collocation_nonlncon_neq, ...
    'nlcon_neq_jac', @collocation_nonlncon_neq_J, ...
    'Tf_lim', [0.25 1]);
Tf = N*Ts;

% Since the optimal trajevtory obtained by solution of the NLP problem have
% shifted state trajecotry from the control trajectory (states x_k are from
% k=1,...,N and controls u_k are from k=0,...N-1) augment these
% trajectories so that they both star at k=0 and end at k=N
t_star = [t_star'; t_star(end) + Ts];
x_star = [x0'; x_star];
u_star = [u_star; 0];

traj = Traj(t_star, x_star, u_star, prms);
save(sprintf('optimTrajectories/makeItOscilate_N%d_T%.1f_umax%d.mat', N, Tf, umax), 'traj', 'Ts', 'xf_des')
%% Visualize the optimal trajectory
visu(traj, 'slider', true)

%% Simulate the optimal trajectory - meaning, apply the optimal control input to the model
th0 = x0(1);
Dth0 = x0(2);
psi0 = x0(3);
Dpsi0 = x0(4);

tau = timeseries([u_star;0;0], [t_star; Tf; Tf+1e2]);

sim('../hybridModel/ballInaHoop_SF', [0 t_star(end)+1]);

t_sim = simData.Time;
x_sim = simData.Data(:,1:8);
u_sim = simData.Data(:,9);

visu(Traj(t_sim, x_sim, u_sim, prms), 'slider', true)
%% Plot the difference between the optimal trajectory and the trajectory obtained for the optimal input
figure(27)
subplot(411)
plot(t_star, x_star(:,1), t_sim, x_sim(:,1), '--')
xlim([t_star(1) t_star(end)])
grid on
title('Hoop angle - theta')
xlabel('Time [s]')
ylabel('theta [rad]')
legend('Optimal trajectory', 'Simulation')

subplot(412)
plot(t_star, x_star(:,2), t_sim, x_sim(:,2), '--')
xlim([t_star(1) t_star(end)])
grid on
title('Hoop ang. velocity - Dtheta')
xlabel('Time [s]')
ylabel('Dtheta [rad/s]')
legend('Optimal trajectory', 'Simulation')

subplot(413)
plot(t_star, x_star(:,3), t_sim, unwrap(x_sim(:,3)), '--')
xlim([t_star(1) t_star(end)])
grid on
title('Ball angle - psi')
xlabel('Time [s]')
ylabel('psi [rad]')
legend('Optimal trajectory', 'Simulation')

subplot(414)
plot(t_star, x_star(:,4), t_sim, x_sim(:,4), '--')
xlim([t_star(1) t_star(end)])
grid on
title('Ball ang. velocity - Dtheta')
xlabel('Time [s]')
ylabel('Dtheta [rad/s]')
legend('Optimal trajectory', 'Simulation')