function Jh = collocation_nonlncon_eq_J2( x0, N, fun, prms )
    disp('-- Jacobian for eq constraints --')

    fileName = [];
    if exist('coll_nlnc_eq_J_functionHandlers.mat', 'file')
        load('coll_nlnc_eq_J_functionHandlers.mat')

        for k=1:numel(coll_nlnc_eq_J)
            if isequal(coll_nlnc_eq_J{k}.N, N) && isequal(coll_nlnc_eq_J{k}.prms, prms)
                fileName = coll_nlnc_eq_J{k}.funName;
                break;
            end
        end
    else
        coll_nlnc_eq_J = {};
    end

    if ~isempty(fileName)
        disp('- Loading from the library')
        Jh = str2func(fileName);
    else        
        disp('- Calculating')

        u = sym('u', [N 1], 'real');
        x = sym('x', [N 4], 'real');
        T = sym('T', 1, 'real');
        
        u_ext = [u; u(end)];
        z = [x0(:)'; x];
        
        f = fun(z',u_ext')';
        
        uc = (u_ext(1:end-1)+u_ext(2:end))/2;
        
        xc = 1/2*( z(1:end-1,:) + z(2:end,:) ) + T/8 * (f(1:end-1,:) - f(2:end,:));
        dot_xc = -(3/2/T)*( z(1:end-1,:) - z(2:end,:) ) - 1/4* (f(1:end-1,:) + f(2:end,:));
        fc = fun(xc', uc')';
        ceq = fc-dot_xc;
        ceq = ceq(:);

        %%
        z = [x u]';
        z = z(:);
        z = [z; T];
        J = jacobian(ceq, z);
        
        random_string = char(floor(25*rand(1, 10)) + 65);
        fileName =  sprintf(strcat('collocation_nonlncon_eq_J_',random_string));
        while exist(strcat(fileName,'txt'), 'file')
            random_string = char(floor(25*rand(1, 10)) + 65);
            fileName =  sprintf(strcat('collocation_nonlncon_eq_J_',random_string));
        end

        Jh = matlabFunction(J, 'Vars', {z}, 'File', fullfile('costAndConstrFunctions', fileName));

        I = numel(coll_nlnc_eq_J)+1;
        coll_nlnc_eq_J{I}.N = N;
        coll_nlnc_eq_J{I}.prms = prms;
        coll_nlnc_eq_J{I}.funName = fileName;
        
        disp('- Saving to the library')
        save coll_nlnc_eq_J_functionHandlers coll_nlnc_eq_J
    end