function []=gen_db(omega,source_file_path,beta)
%% Mic and Parameters
load('mic.mat');
fs = 8000;                      % Sampling frequency (Hz)
c=343.2355;                           % Sound velocity (m/s)
nsample = 2*1024;                   % Length of desired RIR
N_harm = 30;                        % Maximum order of harmonics to use in SHD
K = 1;                              % Oversampling factor

L = [5 4 6];                        % Room dimensions (x,y,z) in m
sphLocation = [2.54,2.55,4.48];       % Receiver location (x,y,z) in m

HP = 1;                             % Optional high pass filter (0/1)
src_type = 'o';                     % Directional source type ('o','c','s','h','b')

%Example 1
order = 1;                          % Reflection order (-1 is maximum reflection order)
refl_coeff_ang_dep = 0;             % Real reflection coeff(0) or angle dependent reflection coeff(1)
% beta =0.4;                         % Reverbration time T_60 (s)
% beta = 0.2*ones(1,6);             % Room reflection coefficients [\beta_x_1 \beta_x_2 \beta_y_1 \beta_y_2 \beta_z_1 \beta_z_2]

% sphRadius = 0.042;                  % Radius of the spherical microphone array (m)
% sphType = 'rigid';                  % Type of sphere (open/rigid)
% mic = [pi/4 pi; pi/2 pi];		    % Microphone positions (azimuth, elevation)

%% Source and parameters
% omega=[omega1;omega2];
[n_omega,~]=size(omega);
x=zeros(n_omega,3);
s=zeros(n_omega,3);
for i = 1:n_omega
    [x(i,1),x(i,2),x(i,3)]=sph2cart(omega(i,1)*pi/180,(90-omega(i,2))*pi/180,1);
    s(i,:)=[x(i,1)+sphLocation(1) x(i,2)+sphLocation(2) x(i,3)+sphLocation(3)];
end
% [x1,y1,z1] = sph2cart(omega1(1)*pi/180,(90-omega1(2))*pi/180,1);
% [x2,y2,z2] = sph2cart(omega2(1)*pi/180,(90-omega2(2))*pi/180,1);
% s = [x1+sphLocation(1) y1+sphLocation(2) z1+sphLocation(3);x2+sphLocation(1) y2+sphLocation(2) z2+sphLocation(3)];

[src_ang(:,1),src_ang(:,2)] = mycart2sph(-sphLocation(1)+s(:,1),-sphLocation(2)+s(:,2),-sphLocation(3)+s(:,3)); % Towards the receiver
[nSource,~]=size(src_ang);
% source_file_path = fullfile('source_audio',{'F1s3.wav','F3s3.wav','M9s3.wav'});
source_gt=src_ang*180/pi;
% disp('Source orientation ground truth (az,inc):');disp(source_gt);%print source ground truth orientation
% source_pos_gt=[x1,y1,z1;x2,y2,z2];
source_pos_gt=x;
save('source_gt.mat','source_gt','source_pos_gt','sphLocation','s');
%% 
% tic
duration = 1; % seconds
nSamplesRequired = ceil(duration*fs);
mic_ip = zeros(nSamplesRequired,length(mic.sensor_angle));

for n=1:nSource
    ainfo = audioinfo(source_file_path{n});
    in_fs = ainfo.SampleRate;
    in_sig = audioread(source_file_path{n},[1 ceil(duration*in_fs)]);
    if in_fs~=fs
        in_sig = resample(in_sig,fs,in_fs);
    end
    in_sig = activlev(in_sig,fs,'n');
    [h1, ~] = smir_generator(c, fs, sphLocation, s(n,:), L, beta, mic.sphType, mic.a, mic.sensor_angle, N_harm, nsample, K, order, refl_coeff_ang_dep, HP, src_type, src_ang(n,:));
    tmp_mic_signals = fftfilt(squeeze(h1'),in_sig);
    nSamplesAvailable = size(tmp_mic_signals,1);
    if nSamplesAvailable>nSamplesRequired
        mic_ip = mic_ip + tmp_mic_signals(1:nSamplesRequired,:);
    else
        mic_ip(1:nSamplesAvailable,:) = mic_ip(1:nSamplesAvailable,:) + tmp_mic_signals;
    end
end
% toc

%% Add Noise
snr_db = 10;
mic_ip = mic_ip + 10.^(-snr_db/20) * randn(size(mic_ip));
nBits = 24;
audiowrite(['mic_ip' '.wav'],normalise(mic_ip,nBits),fs,'BitsPerSample',nBits)
% disp('Saved mic_ip.wav');


