function [psi_res, Dpsi_res] = calcEscapeState(y, prms)
psi = sym('psi','real');
T = sym('T','real');

eq1 = prms.g*cos(psi) + (prms.Ro-prms.Rb)/T^2*(tan(psi))^2==0;
eq2 = T^2/2*prms.g + (prms.Ro-prms.Rb)*sin(psi)*tan(psi) + (prms.Ro-prms.Rb)*cos(psi)==y;

res = solve(eq1, eq2, 'Real', true);

psi_res = mod(double(res.psi),2*pi);

T_res = double(res.T);
Dpsi_res = -1/T_res*tan(psi_res);