clear all;clc;close all
addpath('utils');
%% (Fig.5) Script to generate : Distribution of absolute angular error as a function of source spacing for two sources on the horizontal plane of the microphone array (T60=0.4 s).
plotting=0;        
rand_flac1=randi([3,2679],1,100);
rand_flac2=randi([3,2679],1,100);
rand_omega=-pi+ (2*pi)*rand(1,100);
files=dir('flac');
saperation=[5 10 15 30 45 90 135 180];
error=zeros(100,numel(saperation));
beta=0.4;
tic
for j=1:numel(saperation)
    for i=1:100
        omega=[rand_omega(i),90;(rand_omega(i))+saperation(j)*pi/180,90];
        source_file_path = fullfile('flac',{files(rand_flac1(i)).name,files(rand_flac2(i)).name});
        
        nclusters=length(omega);
        gen_db(omega,source_file_path,beta);%generates input for the mics given position of source
        gen_piv(plotting);%generates PIV from mic input
%         errMat=est_doa(plotting);%using hungarian assignment
        errMat=est_doa_2(plotting,nclusters);%using just k-means
        error(i,j)=rms(errMat);
    end
end
toc
% boxplot(error)

boxplot(error,'Labels',{'5','10','15','30','45','90','135','180'});
xlabel('Source separation [degrees]');
ylabel('DOA estimation error [degrees]');
title('Distribution of absolute angular error as a function of source spacing');


