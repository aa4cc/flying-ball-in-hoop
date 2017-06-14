function dx = ballInAHoop3n_ODEFUN(t, x, prms, tu, u)
% -- On a hoop --
% x(1) - Dtheta
% x(2) - psi
% x(3) - Dpsi

if nargin > 3
    dx = ballInAHoopODEFUN(t, [0; x], prms, tu, u);
else
    dx = ballInAHoopODEFUN(t, [0; x], prms);
end

dx = dx(2:end);