function [A, B, C, D] = ballInAHoop3n_ODEFUN_linMatrices(x, u, prms)
% -- On a hoop --
% x(1) - Dtheta
% x(2) - psi
% x(3) - Dpsi

[A, B, C, D] = ballInAHoopODEFUN_linMatrices([0;x], u, prms);
A = A(2:end,2:end);
B = B(2:end,:);
C = C(:,2:end);