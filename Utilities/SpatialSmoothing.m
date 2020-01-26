%% Spatial and temporal smoothing
%  Josh Barrios 4/15/2018
%  Spatially smooths tail tracking points and returns smoothed point
%  locations and a temporally smoothed tail angle trace
%  both smoothing operations use a 10 frame window

function [smooth_pts,theta_sum,all_thetas] = SpatialSmoothing(trck_pts)

for l = 1:2
    for n = 1:size(trck_pts,2)
        smooth_pts(l,n,:) = smooth(trck_pts(l,n,:),10);
    end
end
% smooth_pts = trck_pts;
% Calculate angle

for k = 1:size(trck_pts,3)
    
    theta = single(pi);
    
    for a = 1:size(trck_pts,2)-1
        
        Y1 = smooth_pts(1,a,k);
        Y2 = smooth_pts(1,a+1,k);
        X1 = smooth_pts(2,a,k);
        X2 = smooth_pts(2,a+1,k);
        
        R = [cos(2*pi - theta) -sin(2*pi - theta); sin(2*pi - theta) cos(2*pi - theta)];
        p1 = [Y1,X1];
        p2 = [Y2,X2];
        p1a = p1*R;
        p2a = p2*R;
        
        y1 = p1a(1);
        y2 = p2a(1);
        x1 = p1a(2);
        x2 = p2a(2);
        
        dX = x2 - x1;
        dY = y2 - y1;
        
        all_thetas(a,k) = atan(dY / dX);
        
        theta = theta + all_thetas(a,k);
        
    end
    theta_sum(k) = sum(rad2deg(all_thetas(:,k)));
end

theta_sum = smooth(theta_sum,10);
