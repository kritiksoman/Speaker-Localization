% clc;clear all;close all;
function [errMat]=est_doa(plotting)
load('piv_ip.mat');
load('source_gt.mat');
source_gt=source_gt*pi/180;
%% K means on piv_ip
nclusters=10;
f1=az_grid(:);
f2=inc_grid(:);
f3=smoothed_hist(:);
% f1n=(f1-mean(f1))/sqrt(var(f1));
% % (max(f1)-min(f1));
% f2n=(f2-mean(f2))/sqrt(var(f2));
% % (max(f2)-min(f2));
% f3n=(f3-mean(f3))/sqrt(var(f3));
% % (max(f3)-min(f3));
[idx,c] = kmeans([f1,f2,f3],nclusters,'start',zeros(nclusters,3));
% c(:,1)=(c(:,1)*sqrt(var(f1)))+mean(f1);
% c(:,2)=(c(:,2)*sqrt(var(f2)))+mean(f2);
c(:,1:2)=c(:,1:2)*pi/180;

% [idx,c_old] = kmeans(f3,10);
% c=zeros(10,2);
% for i=1:length(c_old)
%     [~,p]=min(f3-c_old(i));
%     c(i,1)=f1(p);
%     c(i,2)=f2(p);
% end

%% Angular Distance
dist=zeros(nclusters,length(source_gt));
for icenter=1:length(c)
    for igt=1:length(source_gt)
        n=c(icenter,1:2)*source_gt(igt,:)';
        d=norm(c(icenter,1:2))*norm(source_gt(igt,:));
        dist(icenter,igt)=(1/pi)*acos(n/d);
%         dist(icenter,igt)=norm(c(icenter,1:2)-source_gt(igt,:));%2 norm distance
    end
end
%% Hungarian assignment
if plotting==1
    pcolor(az_grid,inc_grid,smoothed_hist);colorbar;colormap(hot);hold on;
    xlabel('azimuth');ylabel('inc');
    title('Pseudo-intensity vector');
    scatter(c(:,1)*180/pi,c(:,2)*180/pi,'filled');
end
[assignment,cost] = munkres(dist);
estOrient=zeros(size(source_gt));
cartSource=zeros(size(source_pos_gt));
errMat=zeros(1,length(source_gt));
for igt=1:length(source_gt)
    est=c((assignment==igt),1:2)*180/pi;estOrient(igt,:)=est;    
    gt=source_gt(igt,:)*180/pi;
%     fprintf('Source %d, Est: %f %f, ',igt,est);
%     fprintf('GT: %f %f,',gt);
    if plotting==1
        xplot=[est(1),gt(1)];yplot=[est(2),gt(2)];
        plot(xplot,yplot,'white');
    end
    [xhat,yhat,zhat]=sph2cart(est(1)*pi/180,(90-est(2))*pi/180,1);cartSource(igt,:)=[xhat,yhat,zhat];
    err=acos(source_pos_gt(igt,1)*xhat+source_pos_gt(igt,2)*yhat+source_pos_gt(igt,3)*zhat)*180/pi;
%     fprintf(' Error: %f',err);
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