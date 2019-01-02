function [A, B, C, D] = ballInAHoopODEFUN_uout_linMatrices(x, u, prms)
% -- On a hoop --
% x(1) - theta
% x(2) - Dtheta
% x(3) - psi
% x(4) - Dpsi
psi = x(3);

ath1 = prms.uout.ath1;
ath2 = prms.uout.ath2;
ath3 = prms.uout.ath3;
bth  = prms.uout.bth;

apsi1 = prms.uout.apsi1;
apsi2 = prms.uout.apsi2;
apsi3 = prms.uout.apsi3;
bpsi  = prms.uout.bpsi;

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