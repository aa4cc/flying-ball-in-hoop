function Jh = collocation_nonlncon_eq_J( x0, N, f, prms )
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
        ceq = [];

        u = sym('u', [N 1], 'real');
        x = sym('x', [N 4], 'real');
        T = sym('T', 1, 'real');
        z = [x0(:)'; x];
        u_ext = [u; u(end)];

        for k = 2:size(z,1)
            x1 = z(k-1,:)';
            x2 = z(k,:)';
            u1 = u_ext(k-1);
            u2 = u_ext(k);

            f1 = f(x1, u1);
            f2 = f(x2, u2);
            xc = (x1+x2)/2 + T*(f1-f2)/8;
            fc = f(xc, (u1+u2)/2);
            Dxc = -3*(x1-x2)/2/T - (f1+f2)/4;

        %     ceq(:,k-1) = fc - Dxc;
            ceq = [ceq; fc - Dxc];
        end

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