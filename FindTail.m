%% Tail tracking function for 2p and behavior rig data.
% Josh Barrios, 6/11/2018, updated 2/2019
% This version is meant to run on full stacks of pre-acquired data
% Assumes rostral right, caudal left orientation and light fish on dark BG

function [trck_pts_all,theta_sum,sub_pics] = FindTail(mov,head_loc,tail_length,BG_sub)
find_tail_tick = tic;
%% Initialize variables

num_trck_pts = single(8);
r = single(tail_length / (num_trck_pts - 1));
theta = single(zeros(num_trck_pts - 1,1));
trck_pts = single(zeros(2,num_trck_pts,1));
trck_pts_all = zeros(2,8,size(mov,3));

% First search arc is always 140 degrees around 180
search_theta = single(pi);

mov = single(mov);

if ~exist('BG_sub','var')
    BG_sub = 'Yes';
end

switch BG_sub
    case 'Yes'
        BG_sub_tick = tic;
        
        sub_pics = BG_subtract(mov);
        
        display(strcat('Finished background subtraction_',num2str(toc(BG_sub_tick)),'s elapsed'));
    case 'No'
        sub_pics = mov;
        sub_pics = imgaussfilt(sub_pics,4);
end

%% Find anchor point

trck_pts_all(1,1,:) = head_loc(2);
trck_pts_all(2,1,:) = head_loc(1);

theta_sum(size(mov,3)) = 0;

for k = 1:size(mov,3)
    
    frame = sub_pics(:,:,k);
    
    trck_pts(1,1) = trck_pts_all(1,1,1);
    trck_pts(2,1) = trck_pts_all(2,1,1);
    
    %% Find second point
    
    % Build search arc (180 degrees around search_theta)
    th = (search_theta - pi/2 :pi/200: search_theta + pi/2)';
    x_unit = r * cos(th) + trck_pts(2,1);
    y_unit = r * sin(th) + trck_pts(1,1);
    
    % visualize search arc (uncomment only for debugging)
    %         figure
    %         hold on
    %         imagesc(frame)
    %         h = plot(x_unit, y_unit,'k');
    %         hold off
    
    % Get grey values of image within the search arc, and find the
    % center of mass (mid_point) using the highest 50% of grey_values
    
    grey_values = frame(size(frame,1) * (round(x_unit) - 1) + round(y_unit));
    
    max_val = max(grey_values);
    min_val = min(grey_values);
    mid_val = ((max_val - min_val) * 0.75) + min_val;
    grey_values_ind = grey_values > mid_val;
    grey_values = grey_values .* single(grey_values_ind);
    
    mid_point = round(sum(grey_values.*(1:length(grey_values))')/sum(grey_values));
    mid_angle = th(mid_point);
    
    trck_pts(2,2) = r * cos(mid_angle) + trck_pts(2,1);
    trck_pts(1,2) = r * sin(mid_angle) + trck_pts(1,1);
    
    % measure angle
    
    Y1 = trck_pts(1,1);
    Y2 = trck_pts(1,2);
    X1 = trck_pts(2,1);
    X2 = trck_pts(2,2);
    
    % Rotate points to search_theta using rotation matrix R
    
    R = [cos(2*pi - search_theta) -sin(2*pi - search_theta); sin(2*pi - search_theta) cos(2*pi - search_theta)];
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
    
    theta(1) = atan(dY / dX);
    
    %% Find the rest of the points
    
    cum_theta = theta(1);
    
    for i = 3:num_trck_pts
        
        % Build search arc (180 degrees around search_theta)
        search_theta2 = cum_theta + pi;
        th = search_theta2 - pi/2 :pi/200: search_theta2 + pi/2;
        x_unit = r * cos(th) + trck_pts(2,i-1);
        y_unit = r * sin(th) + trck_pts(1,i-1);
        
        % visualize search arc (uncomment only for debugging)
        % figure
        % hold on
        % imagesc(frame)
        % h = plot(x_unit, y_unit,'k');
        % hold off
        
        % Error report if point is out of frame
        try
            clear grey_values
            grey_values = frame(size(frame,1) * (round(x_unit) - 1) + round(y_unit));
        catch ME
            if (strcmp(ME.identifier,'MATLAB:badsubscript'))
                display(strcat('Out of frame error in frame_',num2str(k)))
                for l = i:num_trck_pts
                    trck_pts(2,l) = 1 * cos(mid_angle) + trck_pts(2,i-1);
                    trck_pts(1,l) = 1 * cos(mid_angle) + trck_pts(1,i-1);
                end
                break
            end
        end
        
        % Get grey_values of image within the search arc, and find the
        % center of mass (mid_point) using the highest 25% of grey_values
        
        max_val = max(grey_values);
        min_val = min(grey_values);
        mid_val = ((max_val - min_val) * 0.75) + min_val;
        if mid_val == max_val
            mid_val = max_val * 0.75;
        end
        grey_values_ind = grey_values > mid_val;
        grey_values = grey_values .* single(grey_values_ind);
        
        mid_point = round(sum(grey_values.*(1:length(grey_values)))/sum(grey_values));
        try
            mid_angle = th(mid_point);
            
            trck_pts(2,i) = r * cos(mid_angle) + trck_pts(2,i-1);
            trck_pts(1,i) = r * sin(mid_angle) + trck_pts(1,i-1);
        catch
            trck_pts(2,i) = trck_pts(2,i-1);
            trck_pts(1,i) = trck_pts(1,i-1);
        end
        
        Y1 = trck_pts(1,i-1);
        Y2 = trck_pts(1,i);
        X1 = trck_pts(2,i-1);
        X2 = trck_pts(2,i);
        
        % Rotate points to cum_theta
        
        R = [cos(2*pi - cum_theta) -sin(2*pi - cum_theta); sin(2*pi - cum_theta) cos(2*pi - cum_theta)];
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
        
        theta(i-1) = atan(dY / dX);
        
        cum_theta = cum_theta + theta(i-1);
        
        %         if i == 8
        %             val(:,k) = grey_values;
        %         end
        
    end
    
    trck_pts_all(:,:,k) = trck_pts;
    theta_sum(k) = sum(rad2deg(theta));
    
end

display(strcat('Finished analyzing...',num2str(toc(find_tail_tick)),' seconds elapsed'));