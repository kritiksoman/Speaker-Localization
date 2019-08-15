clear all;
close all;
clc;
addpath('utils');
plotting=0;
% rng default;
omega=[5,90;50,90];
source_file_path = fullfile('flac',{'84-121123-0000.flac','84-121123-0025.flac'});
tic
nclusters=length(omega);
gen_db(omega,source_file_path,0.4);%generates input for the mics given position of source
gen_piv(1);%generates PIV from mic input
% errMat=est_doa(plotting);%using hungarian assignment
% errMat=est_doa_2(0,nclusters);%using just k-means
% disp(rms(errMat));
toc
