function dx = ballInAHoopODEFUN(t, x, prms, tt_u, u)
% -- On a hoop --
% x(1) - theta
% x(2) - Dtheta
% x(3) - psi
% x(4) - Dpsi
Dth = x(2,:);
psi = x(3,:);
Dpsi = x(4,:);

ath1 = prms.ath1;
ath2 = prms.ath2;
ath3 = prms.ath3;
bth  = prms.bth;

apsi1 = prms.apsi1;
apsi2 = prms.apsi2;
apsi3 = prms.apsi3;
bpsi  = prms.bpsi;

if nargin == 5
    ut = interp1(tt_u, u, t, 'previous');
elseif nargin == 4
        ut = tt_u;
else
        ut = 0;
end

dx = [  Dth;
        ath1*Dth    + ath2*sin(psi)     + ath3*Dpsi     + bth*ut;
        Dpsi;
        apsi1*Dth   + apsi2*sin(psi)    + apsi3*Dpsi    + bpsi*ut];