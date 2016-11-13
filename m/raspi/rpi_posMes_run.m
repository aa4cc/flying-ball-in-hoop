function rpi_posMes_run( fps, num_frames, tracking, stream, exposition_time, ip_rpi )

if nargin < 3
    tracking = 0;
end

if nargin < 4
    stream = 0;
end

if nargin < 5
    exposition_time = 10;
end

%%
P = mfilename('fullpath');
[pathstr,~,~] = fileparts(P);

fileID = fopen(fullfile(pathstr, 'remoteCmds.txt'),'w');
% fprintf(fileID,'source cv/bin/activate\n');
% fprintf(fileID,'~/flying-ball/rpi_posMeas/posMeas_withoutThreads.py -f %d -n %d -i %s 9898 -e %d', fps, num_frames, ip_host, exposition_time);
fprintf(fileID,'taskset 0x08 ~/flying-ball/rpi_posMeas/posMeas_withoutThreads_zmq.py -f %d -n %d -e %d', fps, num_frames, exposition_time);

if tracking
    fprintf(fileID,' -t');
end

if stream
    fprintf(fileID,' -s t');
end

fprintf(fileID,'\n');
fclose(fileID);
%%
plink_path = fullfile(pathstr, 'plink.exe');
cert_path = fullfile(pathstr, 'key.ppk');
cmds_path = fullfile(pathstr, 'remoteCmds.txt');

system(sprintf('start /b %s -ssh pi@%s -i %s -m %s', plink_path, ip_rpi, cert_path, cmds_path ))
%%
% Wait till the script starts
pause(1)

% delete('remoteCmds.txt')

end

