% clc;clear all;close all;
function [errMat]=est_doa_2(plotting,nclusters)
load('piv_ip.mat');
load('source_gt.mat');
source_gt=source_gt*pi/180;
%% K means on piv_ip
% nclusters=2;
f1=az_grid(:);
f2=inc_grid(:);
% tmp=smoothed_hist(:).^2;
% f3=2*(tmp./max(tmp));
f3=smoothed_hist(:);
f4=cosd(f1);
f5=sind(f1);
% f6=cosd(f2);
% f7=sind(f2);
[~,centroids] = kmeans([f3,f4,f5,f2],nclusters);
% [~,centroids] = kmeans([f3,f4,f5,f6,f7],nclusters);
% ,'start',zeros(nclusters,4));
c(:,1)=atand(centroids(:,3)./centroids(:,2));
c(:,2)=centroids(:,4);
% c(:,2)=atand(centroids(:,5)./centroids(:,4));
c(:,1:2)=c(:,1:2)*pi/180;
%% Error code
if plotting==1
    pcolor(az_grid,inc_grid,smoothed_hist);colorbar;colormap(hot);hold on;
    xlabel('azimuth');ylabel('inc');
    title('Pseudo-intensity vector');
    scatter(c(:,1)*180/pi,c(:,2)*180/pi,'filled');
end
% [assignment,cost] = munkres(dist);
estOrient=zeros(size(source_gt));
cartSource=zeros(size(source_pos_gt));
errMat=zeros(1,length(source_gt));
for igt=1:length(source_gt)
    %     est=c((assignment==igt),1:2)*180/pi;estOrient(igt,:)=est;
    est=c(igt,1:2)*180/pi;estOrient(igt,:)=est;
    gt=source_gt(igt,:)*180/pi;
%     fprintf('Source %d, Est: %f %f, ',igt,est);
%     fprintf('GT: %f %f,',gt);
    if plotting==1
        xplot=[est(1),gt(1)];yplot=[est(2),gt(2)];
        plot(xplot,yplot,'white');
    end
    [xhat,yhat,zhat]=sph2cart(est(1)*pi/180,(90-est(2))*pi/180,1);cartSource(igt,:)=[xhat,yhat,zhat];
    err=acos(source_pos_gt(igt,1)*xhat+source_pos_gt(igt,2)*yhat+source_pos_gt(igt,3)*zhat)*180/pi;
%     fprintf(' Error: %f ',err);
%     errMat(igt)=err;
    gt=gt*pi/180;est=est*pi/180;
    err2=(1/pi)*acos((gt*est')/(norm(gt)*norm(est)));
%     disp(gt);disp(est);
%     fprintf(' Error 2: %f\n',abs(err2)*180/pi);
    errMat(igt)=abs(err2)*180/pi;
end

if plotting==1
    figure;
    scatter3(sphLocation(1),sphLocation(2),sphLocation(3),'x');hold on;
    scatter3(s(:,1),s(:,2),s(:,3));
    estDir=cartSource+sphLocation;
    xplot=[sphLocation(1),estDir(1,1)];yplot=[sphLocation(2),estDir(1,2)];zplot=[sphLocation(3),estDir(1,3)];
    plot3(xplot,yplot,zplot,'linewidth',2,'color','r');
    xplot=[sphLocation(1),estDir(2,1)];yplot=[sphLocation(2),estDir(2,2)];zplot=[sphLocation(3),estDir(2,3)];
    plot3(xplot,yplot,zplot,'linewidth',2,'color','g');
    
    legend('Mic','Source','Estimate1','Estimate2');
    xlabel('Width, x[m]');ylabel('Depth, y[m]');zlabel('Height, z[m]');
    axis([0 4.5 0 4 0 10]);
    title('Source Position v/s DOA estimates');
end

