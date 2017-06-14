load('.\optimTrajectories\rollIt_N50_T1.5_umax1_0.mat')
[t_0, x_0, u_0] = traj.interp(1/50);

load('.\optimTrajectories\rollIt_N50_T1.5_umax1_1.mat')
[t_1, x_1, u_1] = traj.interp(1/50);

load('.\optimTrajectories\rollIt_N50_T1.5_umax1_2.mat')
[t_2, x_2, u_2] = traj.interp(1/50);


figure(2)
subplot(311)
plot(t_0, u_0, t_1, u_1, t_2, u_2)

subplot(312)
plot(t_0, x_0(:,3), t_1, x_1(:,3), t_2, x_2(:,3))

subplot(313)
plot(t_0, x_0(:,4), t_1, x_1(:,4), t_2, x_2(:,4))