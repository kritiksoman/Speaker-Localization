clc; clear all; close all;
addpath('utils');
%% (Fig.4) Script to generate Distribution of absolute angular error as a function of T60 for two sources 45◦ apart on the horizontal plane of the microphone array.

error_04=zeros(100,3);
rand_flac1=randi([3,2679],1,100);
rand_flac2=randi([3,2679],1,100);
rand_omega=-pi+ (2*pi)*rand(1,100);
files=dir('flac');
plotting=0;
beta_array=[0.2,0.4,0.6];
for j=1:length(beta_array)    
    for i=1:100
        omega=[rand_omega(i),90;rand_omega(i)+pi/4,90];        
        source_file_path = fullfile('flac',{files(rand_flac1(i)).name,files(rand_flac2(i)).name});
        nclusters=length(omega);
        gen_db(omega,source_file_path,beta_array(j));%generates input for the mics given position of source
        gen_piv(plotting);%generates PIV from mic input
        errMat=est_doa(plotting);%using hungarian assignment
%         errMat=est_doa_2(plotting,nclusters);%using just k-means
        error_04(i,j)=rms(errMat);
    end
end
boxplot(error_04,'Labels',{'0.2','0.4','0.6'});
xlabel('Reverberation time [seconds]');
ylabel('DOA estimation error [degrees]');
title(' Distribution of abs. angular error for 2 sources at 45 deg.');
