clear all;
addpath('..')
addpath('../utils')
addpath('costAndConstrFunctions\')
params_init;

% Number of samples
N = 50;

umax = 200;
x0 = [0;0;0;0];
xf_des = [8*pi;0;-4*pi;0];

% Final state constraint
xf_hardcon{1}.n = N;
xf_hardcon{1}.k = 1;
xf_hardcon{1}.x = xf_des(1:4,:);

% Initial condition
Ts = 0.04;
t_star = (0:Ts:(N-1)*Ts)';
u_star = 100*sin(t_star*2*pi/0.7);
x_star = zeros(N,4);
x_star(:,3) = linspace(0,-4*pi,numel(t_star));
z = [x_star u_star]';
opt_initVal = [z(:); Ts];

[ t_star, u_star, x_star, Ts ] = trajOptim_coll_opti(xf_des, N, prms, 'umax', umax, ...
    'costFun', @costFun_u, ...
    'xf_hardcon', xf_hardcon, ...
    'grad', @costFun_u_grad, ...
    'nlcon_eq', @collocation_nonlncon_eq, ...
    'nlcon_eq_jac', @collocation_nonlncon_eq_J, ...
    'nlcon_neq', @collocation_nonlncon_neq, ...
    'nlcon_neq_jac', @collocation_nonlncon_neq_J, ...
    'Tf_lim', [1 2], ...
    'opt_initVal', opt_initVal);
Tf = Ts*N;

traj = Traj(t_star, x_star, u_star, prms);
save(sprintf('optimTrajectories/rollIt_N%d_T%.1f_umax%d.mat', N, Tf, umax), 'traj', 'Ts', 'xf_des')

%% Visualize the optimal trajectory
visu(traj, 'slider', true)

%% Simulate the optimal trajectory - meaning, apply the optimal control input to the model
th0 = 0;
Dth0 = 0;
psi0 = 0;
Dpsi0 = 0;

DDth = timeseries([u_star;0;0], [t_star, Tf, Tf+1e2]);

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