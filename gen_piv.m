function []=gen_piv(plotting)
%% Load mic_ip.wav (input to the 32 mics.)
[z,fs] = audioread(['mic_ip' '.wav']);mic_ip=z;
load('mic.mat');
fs=8000;
c=343.2355;
micRad=0.042;

%% STFT
nwin = 64;
nfft = nwin;
ninc = 32;
win = hamming(nwin,'periodic');
[Z,pm] = stft(mic_ip,win,ninc,nfft,fs);

%% SHT
sph_harmonic_order_max=1;
Praw = sht(Z,mic,sph_harmonic_order_max);

%% Mode strength Compensation
params.freq_min = 500;
params.freq_max = 4000;
[b,i_b] = modeStrength('rigid',micRad,micRad,pm.f,sph_harmonic_order_max,c);
Pcomp = bsxfun(@rdivide,Praw,b(:,i_b));

%% PIV
pivs = piv(Pcomp);

%% Histogram
% - turn PIV at each TF-bin into single Mx3 matrix
% - form a histogram of the directions
% - smooth the histogram to get final 2D representation
stacked_pivs = reshape(permute(pivs,[1 3 2]),[],3);
[counts,az_grid,inc_grid] = piv_hist(stacked_pivs,4.5,2.25);
[smoothed_hist] = smooth_histogram_pd(counts,4,az_grid,inc_grid);
% pcolor(180*az_grid/pi,180*inc_grid/pi,smoothed_hist);colorbar;%az in 0to360
%convert az to -180 to 180
midLoc=ceil(length(smoothed_hist)/2);az_grid=180*(az_grid-pi)/pi;inc_grid=180*inc_grid/pi;
% smoothed_hist=counts;
smoothed_hist=[smoothed_hist(:,midLoc+1:end),smoothed_hist(:,1:midLoc)];
if plotting==1%% PIV
    figure;
    pcolor(az_grid,inc_grid,smoothed_hist);colorbar;colormap(hot);
    xlabel('azimuth');ylabel('inc');
    title('Pseudo-intensity vector');

    figure;subplot(1,2,1);
    x=az_grid(1,:);
    y=sum(smoothed_hist,1);
    bar(x,y);xlabel('azimuth [deg]');ylabel('Number of samples');

    subplot(1,2,2);
    x=inc_grid(:,1);
    y=sum(smoothed_hist,2);
    bar(x,y);xlabel('inclination [deg]');ylabel('Number of samples');
end
save('piv_ip.mat','smoothed_hist','az_grid','inc_grid');
% disp('Saved PIV.');