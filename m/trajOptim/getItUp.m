clear all;
addpath('..')
addpath('../utils')
addpath('costAndConstrFunctions\')

params_init;
[psi_res, Dpsi_res] = calcEscapeState(-prms.Ri-prms.Rb, prms);
psi_res = psi_res-2*pi;
Dpsi_res = double(sign(psi_res)*abs(Dpsi_res));

% Calculate Dth(t1) (angular velocity of the hoop when the ball leaves the
% hoop) and Dth(2) (angular velocity of the hoop when the ball lands on the
% inner hoop) minimizaing Dpsi when the ball enters the inner hoop mode

% Cost function expressing Dpsi^2 + Dth_t2^2
f = @(Dth_t1, Dth_t2) (Dth_t2 + prms.Ro/prms.Ri*(Dth_t1 - Dpsi_res) ...
    - (prms.Ro - prms.Rb)/(prms.Ri+prms.Rb)*cos(psi_res)*Dpsi_res).^2 + Dth_t2.^2;
options = optimoptions('fmincon','Display','iter','Algorithm','sqp');
X = fminunc(@(x) f(x(1), x(2)), [0;0], options);
Dth_t1 = X(1);
Dth_t2 = X(2);

% % Visualize the cost function and the optimal solution
% [dth1, dth2] = meshgrid(-20:10, -20:10);
% figure(1);clf
% surface(dth1, dth2,f(dth1, dth2));
% hold on
% plot3(Dth_t1, Dth_t2, f(Dth_t1, Dth_t2), 'r.', 'MarkerSize', 20)
% hold off
% xlabel('Dth_t1')
% ylabel('Dth_t2')

% Number of knot points
N = 50;

umax = 1;
x0 = [0;0;0;0];
xf_des = [0; Dth_t1; psi_res; Dpsi_res];

xf_hardcon{1}.n = N;
xf_hardcon{1}.k = 2;
xf_hardcon{1}.x = xf_des(2:4,:);

Aneq = eye(5*N+1);
lcon_neq.Aneq = Aneq(3:5:end,:);
lcon_neq.bneq = 0.9*pi/2*ones(N,1);

[ t_star, u_star, x_star, Ts ] = trajOptim_coll_opti(xf_des, N, prms, ...
    'umax', umax, ...
    'costFun', @costFun_u, ...
    'xf_hardcon', xf_hardcon, ...
    'grad', @costFun_u_grad, ...
    'lcon_neq', lcon_neq, ...
    'nlcon_eq', @collocation_nonlncon_eq2, ...
    'nlcon_eq_jac', @collocation_nonlncon_eq_J2, ...
    'Tf_lim', [1.0 1.5]);
Tf = N*Ts;

% Since the optimal trajevtory obtained by solution of the NLP problem have
% shifted state trajecotry from the control trajectory (states x_k are from
% k=1,...,N and controls u_k are from k=0,...N-1) augment these
% trajectories so that they both star at k=0 and end at k=N
t_star = [t_star'; t_star(end) + Ts];
x_star = [x0'; x_star];
u_star = [u_star; 0];

traj = Traj(t_star, x_star, u_star, prms);
    
save(sprintf('optimTrajectories/getItUp_N%d_T%.1f_umax%d.mat', N, Tf, umax), 'traj', 'Ts', 'xf_des')
%% Visualize the optimal trajectory
visu(traj, 'slider', true)

%% Simulate the optimal trajectory - meaning, apply the optimal control input to the model
th0 = 0;
Dth0 = 0;
psi0 = 0;
Dpsi0 = 0;

tau = timeseries([u_star;0;0], [t_star, Tf, Tf+1e2]);

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