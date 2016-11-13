function Jh = collocation_nonlncon_neq_J( N, prms)
    disp('-- Jacobian for neq constraints --')

    fileName = [];
    if exist('coll_nlnc_neq_J_functionHandlers.mat', 'file')
        load('coll_nlnc_neq_J_functionHandlers.mat')

        for k=1:numel(coll_nlnc_neq_J)
            if isequal(coll_nlnc_neq_J{k}.N, N) && isequal(coll_nlnc_neq_J{k}.prms, prms)
                fileName = coll_nlnc_neq_J{k}.funName;
                break;
            end
        end    
    else
        coll_nlnc_neq_J = {};
    end
        
    if ~isempty(fileName)
        disp('- Loading from the library')
        Jh = str2func(fileName);
    else
        disp('- Calculating')
        u = sym('u', [N 1], 'real');
        x = sym('x', [N 4], 'real');
        T = sym('T', 1, 'real');

        psi = x(1:(N-1),3);
        Dpsi = x(1:(N-1),4);

        cneq = -prms.g*cos(psi)-(prms.Ro-prms.Rb).*Dpsi.^2;

        z = [x u]';
        z = [z(:); T];
        J = jacobian(cneq, z);

        random_string = char(floor(25*rand(1, 10)) + 65);
        fileName =  sprintf(strcat('collocation_nonlncon_neq_J_',random_string));
        while exist(strcat(fileName,'txt'), 'file')
            random_string = char(floor(25*rand(1, 10)) + 65);
            fileName =  sprintf(strcat('collocation_nonlncon_neq_J_',random_string));
        end

        Jh = matlabFunction(J, 'Vars', {z}, 'File', fullfile('costAndConstrFunctions', fileName));

        I = numel(coll_nlnc_neq_J)+1;
        coll_nlnc_neq_J{I}.N = N;
        coll_nlnc_neq_J{I}.prms = prms;
        coll_nlnc_neq_J{I}.funName = fileName;
        
        disp('- Saving to the library')
        save coll_nlnc_neq_J_functionHandlers coll_nlnc_neq_J
    end
end

