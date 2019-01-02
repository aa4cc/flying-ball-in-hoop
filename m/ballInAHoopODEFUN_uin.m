function dx = ballInAHoopODEFUN_uin(t, x, prms, tt_u, u)
% -- On a hoop --
% x(1) - theta
% x(2) - Dtheta
% x(3) - psi
% x(4) - Dpsi
Dth = x(2,:);
psi = x(3,:);
Dpsi = x(4,:);

ath1 = prms.uin.ath1;
ath2 = prms.uin.ath2;
ath3 = prms.uin.ath3;
bth  = prms.uin.bth;

apsi1 = prms.uin.apsi1;
apsi2 = prms.uin.apsi2;
apsi3 = prms.uin.apsi3;
bpsi  = prms.uin.bpsi;

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