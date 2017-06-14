function [A, B, C, D] = ballInAHoopODEFUN_linMatrices(x, u, prms)
% -- On a hoop --
% x(1) - theta
% x(2) - Dtheta
% x(3) - psi
% x(4) - Dpsi
psi = x(3);

ath1 = prms.ath1;
ath2 = prms.ath2;
ath3 = prms.ath3;
bth  = prms.bth;

apsi1 = prms.apsi1;
apsi2 = prms.apsi2;
apsi3 = prms.apsi3;
bpsi  = prms.bpsi;

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