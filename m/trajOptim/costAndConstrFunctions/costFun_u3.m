function J = costFun_u3( z, xf_des, N )

z = reshape(z(1:end-1), 5, N)';
u = z(:,5);

dpsi = z(:,4);

J = u'*u - 0.004*dpsi(floor(N/2))^2;


end

