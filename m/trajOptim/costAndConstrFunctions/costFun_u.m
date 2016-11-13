function J = costFun_u( z, xf_des, N )

z = reshape(z(1:end-1), 5, N)';
u = z(:,5);

J = u'*u;


end

