function J = costFun_u( z, xf_des, N )

z = reshape(z(1:end-1), 5, N)';
u = z(:,5);

dpsi = z(:,4);

J = u'*u - 0.0007*(dpsi')*dpsi;


end

