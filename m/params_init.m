clear prms

prms.Ts = 1/50;
prms.usat = 300;
%% Physical parameters
R_oring = 1.5*1e-3; % diameter of the oring
d_orings = 14.7*1e-3; % distance between the orings - center to center
prms.Rb_real = 0.01; % radius of the ball
h = sqrt((prms.Rb_real + R_oring)^2 - (d_orings/2)^2); % perpendicular distance from the center of the ball to the line going through the centers of the orings
d_rotAxis2oring_outer = 194/2*1e-3; % distance from the center of the hoop (rotation axis) to the center of the outer oring;
d_rotAxis2oring_inner = 45*1e-3; % distance from the center of the hoop (rotation axis) to the center of the outer oring;

prms.Rb = h*prms.Rb_real/(prms.Rb_real + R_oring); % efective radius of the ball
prms.Ro = d_rotAxis2oring_outer - (h-prms.Rb); % radius of the hoop
prms.Ri = d_rotAxis2oring_inner - (h-prms.Rb); % radius of the hoop

prms.m = .032; % mass of the metal ball
prms.I = 2/5*prms.m*prms.Rb_real^2; % Inertia of the ball
prms.b = 1.3954e-06;
prms.g = 9.81;

prms.out.a_bar = prms.I*prms.Ro^2/prms.Rb^2 + prms.m*(prms.Ro-prms.Rb)^2;
prms.out.b_bar = prms.b*prms.Ro^2/prms.Rb^2;
% prms.out.c_bar = prms.m*prms.g*(prms.Ro-prms.Rb);
prms.out.d_bar = -prms.out.b_bar;
prms.out.e_bar = prms.I*prms.Ro/prms.Rb*(prms.Ro/prms.Rb+1);

% identified by optimization
prms.out.c_bar = 0.0298;

%% Coefficients for the EKF for the model describing the motion of the ball on the outer hoop (the larger one)
prms.out.KF.a_bar = prms.out.a_bar;
prms.out.KF.b_bar = prms.out.b_bar;
prms.out.KF.c_bar = prms.out.c_bar;
prms.out.KF.d_bar = prms.out.d_bar;
prms.out.KF.e_bar = prms.out.e_bar;

prms.out.KF.Q = diag([.1 10]);
prms.out.KF.R = .1;

prms.out.KF.Q3 = diag([.1 10 .1 10 .1 10]);
prms.out.KF.R3 = 0.1;
%% Coefficients of the model describing the motion of the ball on the inner hoop (the smaller one)
prms.in.a_bar = prms.I*prms.Ri^2/prms.Rb^2 + prms.m*(prms.Ri+prms.Rb)^2;
prms.in.b_bar = prms.b*prms.Ri^2/prms.Rb^2;
prms.in.c_bar = prms.m*prms.g*(prms.Ri+prms.Rb);
prms.in.d_bar = -prms.in.b_bar;
prms.in.e_bar = prms.I*prms.Ri/prms.Rb*(prms.Ri/prms.Rb-1);

%% Coefficients for the EKF for the model describing the motion of the ball on the inner hoop (the smaller one)
prms.in.KF.a_bar = prms.in.a_bar;
prms.in.KF.b_bar = prms.in.b_bar;
prms.in.KF.c_bar = prms.in.c_bar;
prms.in.KF.d_bar = prms.in.d_bar;
prms.in.KF.e_bar = prms.in.e_bar;

prms.in.KF.Q = diag([.1 10]);
prms.in.KF.R = .1;

prms.in.KF.Q3 = diag([.1 10 .1 10 .1 10]);
prms.in.KF.R3 = 0.1;
%%
ip_host = '147.32.86.104';
ip_rpi = '147.32.86.141';