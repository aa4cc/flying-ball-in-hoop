function [A, B, C, D] = ballInAHoopODEFUN_uin_linMatrices(x, u, prms)
% -- On a hoop --
% x(1) - theta
% x(2) - Dtheta
% x(3) - psi
% x(4) - Dpsi
psi = x(3);

ath1 = prms.uin.ath1;
ath2 = prms.uin.ath2;
ath3 = prms.uin.ath3;
bth  = prms.uin.bth;

apsi1 = prms.uin.apsi1;
apsi2 = prms.uin.apsi2;
apsi3 = prms.uin.apsi3;
bpsi  = prms.uin.bpsi;

A = [0              1               0               0;
     0              ath1            ath2*cos(psi)   ath3;
     0              0               0               1;
     0              apsi1           apsi2*cos(psi)  apsi3];

 B = [0;
     bth;
     0;
     bpsi];
 
C = [1 0 0 0;
     0 1 0 0;
     0 0 1 0];
 
D = zeros(3,1);