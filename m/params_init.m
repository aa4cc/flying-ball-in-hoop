% diameter of the ball: 24.6 mm
clear prms

prms.Ts = 1/50;
prms.usat = 0.7;
%% Physical parameters
R_oring = 1.5*1e-3; % diameter of the oring
d_orings = 14.7*1e-3; % distance between the orings - center to center
prms.Rb_real = 0.0246/2; % radius of the ball
h = sqrt((prms.Rb_real + R_oring)^2 - (d_orings/2)^2); % perpendicular distance from the center of the ball to the line going through the centers of the orings
d_rotAxis2oring_outer = 203.828/2*1e-3; % distance from the center of the hoop (rotation axis) to the center of the outer oring;
d_rotAxis2oring_Uinner = 89/2*1e-3; % distance from the center of the hoop (rotation axis) to the center of the outer oring in the inner part of the ushape
d_rotAxis2oring_Uouter = 111/2*1e-3; % distance from the center of the hoop (rotation axis) to the center of the outer oring in the outer part of the ushape

prms.Rb = h*prms.Rb_real/(prms.Rb_real + R_oring); % efective radius of the ball
prms.Ro = d_rotAxis2oring_outer - (h-prms.Rb); % rolling radius of the outer hoop
prms.Rui = d_rotAxis2oring_Uinner - (h-prms.Rb); % rolling radius of the ball in the inner ushape
prms.Ruo = d_rotAxis2oring_Uouter + (h-prms.Rb); % rolling radius of the ball in the outer ushape

prms.m = .0608; % mass of the metal ball
prms.Ib = 2/5*prms.m*prms.Rb_real^2; % Inertia of the ball
prms.b = 1.3954e-06;
prms.g = 9.81;

%% Identified parameters
prms.Ih = 1/658.8;
prms.bb = 2.5737e-06;
prms.bh = 0.0075;

%% Parameters of the model
% Model is given by the following equations
%
% DDth = ath(1)*Dth + ath(2)*sin(psi) + ath(3)*Dpsi + bth(1)*u
% DDpsi = apsi(1)*Dth + apsi(2)*sin(psi) + apsi(3)*Dpsi + bpsi(1)*u
prmsf.ath1_f 	=	@(Rb,Ro,mb,g,Ib,Ih,bb,bh)-(-Ib.*Ro.^3.*bb+Rb.^5.*bh.*mb+Ib.*Rb.*Ro.^2.*bh+Rb.*Ro.^4.*bb.*mb-Rb.^4.*Ro.*bh.*mb.*2.0-Rb.^2.*Ro.^3.*bb.*mb.*2.0+Rb.^3.*Ro.^2.*bb.*mb+Rb.^3.*Ro.^2.*bh.*mb)./(Rb.*(Ib.*Ih.*Ro.^2+Ib.*Rb.^4.*mb+Ih.*Rb.^4.*mb+Ib.*Ro.^4.*mb-Ih.*Rb.^3.*Ro.*mb.*2.0-Ib.*Rb.^2.*Ro.^2.*mb.*2.0+Ih.*Rb.^2.*Ro.^2.*mb));
prmsf.ath2_f 	=	@(Rb,Ro,mb,g,Ib,Ih,bb,bh)(Ib.*Ro.*g.*mb.*(Rb+Ro).*(Rb-Ro))./(Ib.*Ih.*Ro.^2+Ib.*Rb.^4.*mb+Ih.*Rb.^4.*mb+Ib.*Ro.^4.*mb-Ih.*Rb.^3.*Ro.*mb.*2.0-Ib.*Rb.^2.*Ro.^2.*mb.*2.0+Ih.*Rb.^2.*Ro.^2.*mb);
prmsf.ath3_f 	=	@(Rb,Ro,mb,g,Ib,Ih,bb,bh)-(Ro.*(Ib.*Ro.^2.*bb-Rb.*Ro.^3.*bb.*mb-Rb.^3.*Ro.*bb.*mb+Rb.^2.*Ro.^2.*bb.*mb.*2.0))./(Rb.*(Ib.*Ih.*Ro.^2+Ib.*Rb.^4.*mb+Ih.*Rb.^4.*mb+Ib.*Ro.^4.*mb-Ih.*Rb.^3.*Ro.*mb.*2.0-Ib.*Rb.^2.*Ro.^2.*mb.*2.0+Ih.*Rb.^2.*Ro.^2.*mb));
prmsf.bth_f 	=	@(Rb,Ro,mb,g,Ib,Ih,bb,bh)(Ib.*Ro.^2+Rb.^4.*mb+Rb.^2.*Ro.^2.*mb-Rb.^3.*Ro.*mb.*2.0)./(Ib.*Ih.*Ro.^2+Ib.*Rb.^4.*mb+Ih.*Rb.^4.*mb+Ib.*Ro.^4.*mb-Ih.*Rb.^3.*Ro.*mb.*2.0-Ib.*Rb.^2.*Ro.^2.*mb.*2.0+Ih.*Rb.^2.*Ro.^2.*mb);
prmsf.apsi1_f 	=	@(Rb,Ro,mb,g,Ib,Ih,bb,bh)(Ib.*Ro.^3.*bb+Ib.*Rb.*Ro.^2.*bb-Ib.*Rb.*Ro.^2.*bh-Ib.*Rb.^2.*Ro.*bh+Ih.*Rb.*Ro.^2.*bb)./(Rb.*(Ib.*Ih.*Ro.^2+Ib.*Rb.^4.*mb+Ih.*Rb.^4.*mb+Ib.*Ro.^4.*mb-Ih.*Rb.^3.*Ro.*mb.*2.0-Ib.*Rb.^2.*Ro.^2.*mb.*2.0+Ih.*Rb.^2.*Ro.^2.*mb));
prmsf.apsi2_f 	=	@(Rb,Ro,mb,g,Ib,Ih,bb,bh)(g.*mb.*(Rb-Ro).*(Ib.*Rb.^2+Ih.*Rb.^2+Ib.*Ro.^2+Ib.*Rb.*Ro.*2.0))./(Ib.*Ih.*Ro.^2+Ib.*Rb.^4.*mb+Ih.*Rb.^4.*mb+Ib.*Ro.^4.*mb-Ih.*Rb.^3.*Ro.*mb.*2.0-Ib.*Rb.^2.*Ro.^2.*mb.*2.0+Ih.*Rb.^2.*Ro.^2.*mb);
prmsf.apsi3_f 	=	@(Rb,Ro,mb,g,Ib,Ih,bb,bh)-(Ib.*Ro.^3.*bb+Ib.*Rb.*Ro.^2.*bb+Ih.*Rb.*Ro.^2.*bb)./(Rb.*(Ib.*Ih.*Ro.^2+Ib.*Rb.^4.*mb+Ih.*Rb.^4.*mb+Ib.*Ro.^4.*mb-Ih.*Rb.^3.*Ro.*mb.*2.0-Ib.*Rb.^2.*Ro.^2.*mb.*2.0+Ih.*Rb.^2.*Ro.^2.*mb));
prmsf.bpsi_f 	=	@(Rb,Ro,mb,g,Ib,Ih,bb,bh)(Ib.*Ro.*(Rb+Ro))./(Ib.*Ih.*Ro.^2+Ib.*Rb.^4.*mb+Ih.*Rb.^4.*mb+Ib.*Ro.^4.*mb-Ih.*Rb.^3.*Ro.*mb.*2.0-Ib.*Rb.^2.*Ro.^2.*mb.*2.0+Ih.*Rb.^2.*Ro.^2.*mb);

prms.ath1	= 	prmsf.ath1_f(prms.Rb,	prms.Ro, prms.m, prms.g,	prms.Ib, prms.Ih, prms.bb, prms.bh);
prms.ath2	= 	prmsf.ath2_f(prms.Rb,	prms.Ro, prms.m, prms.g,	prms.Ib, prms.Ih, prms.bb, prms.bh);
prms.ath3	= 	prmsf.ath3_f(prms.Rb,	prms.Ro, prms.m, prms.g,	prms.Ib, prms.Ih, prms.bb, prms.bh);
prms.bth		= 	prmsf.bth_f(prms.Rb,	prms.Ro, prms.m, prms.g,	prms.Ib, prms.Ih, prms.bb, prms.bh);
prms.apsi1	= 	prmsf.apsi1_f(prms.Rb,	prms.Ro, prms.m, prms.g,	prms.Ib, prms.Ih, prms.bb, prms.bh);
prms.apsi2	= 	prmsf.apsi2_f(prms.Rb,	prms.Ro, prms.m, prms.g,	prms.Ib, prms.Ih, prms.bb, prms.bh);
prms.apsi3	= 	prmsf.apsi3_f(prms.Rb,	prms.Ro, prms.m, prms.g,	prms.Ib, prms.Ih, prms.bb, prms.bh);
prms.bpsi	= 	prmsf.bpsi_f(prms.Rb,	prms.Ro, prms.m, prms.g,	prms.Ib, prms.Ih, prms.bb, prms.bh);
  
prms.ath1 =  -0.4800;
prms.ath2 = -5.1195;
prms.ath3 =   0.0677;
prms.bth = 586.3695;
prms.apsi1 =   -0.0034;
prms.apsi2 = -73.6336;
prms.apsi3 = -0.3351;
prms.bpsi = 210.12;

%% Coefficients for the EKF for the model describing the motion of the ball on the outer hoop (the larger one)
prms.out.KF.Q = diag([0.01 1 .01 1]);
prms.out.KF.R = diag([.01 5 .01]);

prms.out.P0 = eye(4);
prms.out.x0 = zeros(4,1);

%% Coefficients of the model describing the motion of the ball on the inner hoop (the smaller one)
% prms.in.a_bar = prms.Ib*prms.Ri^2/prms.Rb^2 + prms.m*(prms.Ri+prms.Rb)^2;
% prms.in.b_bar = prms.b*prms.Ri^2/prms.Rb^2;
% prms.in.c_bar = prms.m*prms.g*(prms.Ri+prms.Rb);
% prms.in.d_bar = -prms.in.b_bar;
% prms.in.e_bar = prms.Ib*prms.Ri/prms.Rb*(prms.Ri/prms.Rb-1);

prms.uout.apsi1 = -0.0034;
prms.uout.apsi2 = -73.6336;
prms.uout.apsi3 = -0.3351;
prms.uout.bpsi  = 210.12;

prms.uin.ath1	= 	prmsf.ath1_f(prms.Rb,	prms.Rui, prms.m, prms.g,	prms.Ib, prms.Ih, prms.bb, prms.bh);
prms.uin.ath2	= 	prmsf.ath2_f(prms.Rb,	prms.Rui, prms.m, prms.g,	prms.Ib, prms.Ih, prms.bb, prms.bh);
prms.uin.ath3	= 	prmsf.ath3_f(prms.Rb,	prms.Rui, prms.m, prms.g,	prms.Ib, prms.Ih, prms.bb, prms.bh);
prms.uin.bth	= 	prmsf.bth_f(prms.Rb,	prms.Rui, prms.m, prms.g,	prms.Ib, prms.Ih, prms.bb, prms.bh);
prms.uin.apsi1	= 	prmsf.apsi1_f(prms.Rb,	prms.Rui, prms.m, prms.g,	prms.Ib, prms.Ih, prms.bb, prms.bh);
prms.uin.apsi2	= 	prmsf.apsi2_f(prms.Rb,	prms.Rui, prms.m, prms.g,	prms.Ib, prms.Ih, prms.bb, prms.bh);
prms.uin.apsi3	= 	prmsf.apsi3_f(prms.Rb,	prms.Rui, prms.m, prms.g,	prms.Ib, prms.Ih, prms.bb, prms.bh);
prms.uin.bpsi	= 	prmsf.bpsi_f(prms.Rb,	prms.Rui, prms.m, prms.g,	prms.Ib, prms.Ih, prms.bb, prms.bh);

%% Coefficients for the EKF for the model describing the motion of the ball in the inner part of the ushape
prms.uin.KF.Q = diag([0.01 1 .01 1]);
prms.uin.KF.R = diag([.01 5 .01]);

prms.uin.P0 = eye(4);
prms.uin.x0 = zeros(4,1);
%%
% ip_host = '147.32.86.211';
ip_rpi = '192.168.1.16';
port_rpi = 5001; % port of the raspi-ballpos webservice

rpi_user = 'pi';
rpi_passwd = 'mamradtisk';
%%
odefun = @ballInAHoopODEFUN;
odefun_linMatrices = @ballInAHoopODEFUN_linMatrices;