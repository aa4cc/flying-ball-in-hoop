function img = loadImg( ip_host, ip_rpi )
%% Params
N = 5;
expos_time = 10;
%%
P = mfilename('fullpath');
[pathstr,~,~] = fileparts(P);

fileID = fopen(fullfile(pathstr, 'remoteCmds.txt'),'w');
% fprintf(fileID,'source cv/bin/activate\n');
fprintf(fileID,'python3 ~/flying-ball/rpi_posMeas/tcpExp.py -f 2 -n %d -i %s 9898 -e %d\n', N, ip_host, expos_time);
fclose(fileID);
%%
plink_path = fullfile(pathstr, 'plink.exe');
cert_path = fullfile(pathstr, 'key.ppk');
cmds_path = fullfile(pathstr, 'remoteCmds.txt');

system(sprintf('start /b %s -ssh pi@%s -i %s -m %s &', plink_path, ip_rpi, cert_path, cmds_path ));
%%
t = tcpip('0.0.0.0', 9898, 'NetworkRole', 'server', 'InputBufferSize', 480*480*3);
fopen(t);

w = 480;
h = 480;

for i=1:N
    data_raw = uint8(fread(t, h*w*3, 'uint8'));
    data = reshape(data_raw, [3, h, w]);
    img = uint8(zeros(w,h,3));
    img(:,:,1) = squeeze( data(1,:,:) )';
    img(:,:,2) = squeeze( data(2,:,:) )';
    img(:,:,3) = squeeze( data(3,:,:) )';

    pause(.1)
end

fclose(t);
%%
delete(fullfile(pathstr, 'remoteCmds.txt'))
end

