%% Josh Barrios 4/15/18
% Reads in tracking points, smooths and extracts tail angle measurements and
% identifies swim bouts

% Update 9/18/18- adding more kinematic params and combining
% params from first three half-beats into total_bout

%% Run spatial and temporal smoothing

[smooth_pts,smooth_trace,all_thetas] = SpatialSmoothing(trck_pts_all);

%%

min_bout_length = 36; % Assumes frame rate of 500 fps

% Take derivative of all angles and get cumulative sum

for k = 1:size(all_thetas,1)
    dall_thetas(k,:) = diff(all_thetas(k,:));
end

motion_trace = cumsum(dall_thetas,1);
abs_motion_trace = sum(abs(motion_trace),1);

%% Find 80th percentile of motion data, apply it as a threshold to abs_motion_trace

pos_thresh = prctile(abs(abs_motion_trace),70);

% pos_thresh = 0.05;

% Make boolean trace
pos_bout_bool = zeros(size(abs_motion_trace));
pos_bout_bool(abs_motion_trace > abs(pos_thresh)) = 1;

seqs = findseq(pos_bout_bool);

% Remove sequences of length < min_bout_length
for k = 1:size(seqs,1)
    
    if seqs(k,1) == 1 && seqs(k,4) < min_bout_length
        pos_bout_bool(seqs(k,2):seqs(k,3)) = 0;
    end
    
end

% Remove singleton "sequences"
for k = 2:size(pos_bout_bool,2) - 1
    
    if pos_bout_bool(k-1) == 0 && pos_bout_bool(k+1) == 0
        pos_bout_bool(k) = 0;
    end
    
end

% Remove inter-bout-intervals < min_bout_length
in_bouts = findseq(pos_bout_bool);
for k = 1:size(in_bouts,1)
    
    if in_bouts(k,1) == 0 && in_bouts(k,4) < min_bout_length
        pos_bout_bool(in_bouts(k,2):in_bouts(k,3)) = 1;
    end
    
end

% Remove singleton inter-bout-intervals
for k = 2:size(pos_bout_bool,2) - 1
    
    if pos_bout_bool(k-1) == 1 && pos_bout_bool(k+1) == 1
        pos_bout_bool(k) = 1;
    end
    
end


% fig_handle = figure;
% subplot(3,1,1)
% plot(abs(abs_motion_trace))
% title(strcat('Fish number ',num2str(fish_num),' Plane number ',num2str(plane_num),' Trial number ',num2str(trial_num)))
% ylabel('dMovement')
% subplot(3,1,2)
% plot(pos_bout_bool)
% ylabel('Bout Boolean')
% ylim([-1 2])
% subplot(3,1,3)
% plot(smooth_trace)
% ylabel('Tail Angle')

% figure
% subplot(3,1,1)
% plot(abs(abs_motion_trace))
% title(strcat('Fish number ',num2str(fish_num),' Plane number ',num2str(plane_num),' Trial number ',num2str(trial_num)))
% ylabel('dMovement')
% subplot(3,1,2)
% plot(pos_bout_bool)
% ylabel('Bout Boolean')
% ylim([-1 2])
% subplot(3,1,3)
% plot(smooth_trace)
% ylabel('Tail Angle')



% Final bout ID
bouts = findseq(pos_bout_bool);
bouts = bouts(bouts(:,2) > min_bout_length,:);
bout_bool = bouts(:,1) == 1;
bouts = bouts(bout_bool,:);

%% ID half beats

for k = 1:size(bouts,1)
    
    bout_traces{k,:} = smooth_trace(bouts(k,2):bouts(k,3));
    
    % Apply boxcar mean filter and subtract
    bout_tracesAdj{k,:} = bout_traces{k,:} - smooth(movmean(bout_traces{k,:},36),50);
    
    % Find and put half-beats in order
    half_beats = findseq(single(bout_tracesAdj{k,:} > 0));
    [B,I] = sort(half_beats(:,2));
    half_beats_sorted{k} = half_beats(I,:);
    
end

%% Extract kinematic parameters

% Kinematic parameters in order:
% 1. Max angular velocity (degrees/frame)
% 2. mean angular velocity (degrees/frame)
% 3. max angle
% 4. end angle
% 5. max angle at segment 1
% 6. max angle at segment 2
% 7. max angle at segment 3
% 8. max angle at segment 4
% 9. max angle at segment 5
% 10.max angle at segment 6
% 11. max angle at segment 7
% 12. max segmental angular change (abs_motion_trace)
% 13. mean segmental angular change (abs_motion_trace)
% 14. bout duration (frames)

% ------------half beat kinematic parameters-------------

% 15. Max bout frequency (frequency of half-beats (1/frames))
% 16. Mean bout frequency (frequency of half-beats (1/frames))
% 17. half beat 1 direction

% 18. half beat 1 max velocity
% 19. half beat 1 mean velocity
% 20. half beat 1 max angle (C1 angle)
% 21. half beat 1 end angle
% 22. half beat 1 duration
% 23. half beat 1 max angle segment 1
% 24. half beat 1 max angle segment 2
% 25. half beat 1 max angle segment 3
% 26. half beat 1 max angle segment 4
% 27. half beat 1 max angle segment 5
% 28. half beat 1 max angle segment 6
% 29. half beat 1 max angle segment 7
% 30. half beat 1 max segmental angular change (abs_motion_trace)
% 31. half beat 1 mean segmental angular change (abs_motion_trace)

% 32. half beat 2 max velocity
% 33. half beat 2 mean velocity
% 34. half beat 2 max angle (C2 angle)
% 35. half beat 2 end angle
% 36. half beat 2 duration
% 37. half beat 2 max angle segment 1
% 38. half beat 2 max angle segment 2
% 39. half beat 2 max angle segment 3
% 40. half beat 2 max angle segment 4
% 41. half beat 2 max angle segment 5
% 42. half beat 2 max angle segment 6
% 43. half beat 2 max angle segment 7
% 44. half beat 2 max segmental angular change (abs_motion_trace)
% 45. half beat 2 mean segmental angular change (abs_motion_trace)

% 46. half beat 3 max velocity
% 47. half beat 3 mean velocity
% 48. half beat 3 max angle
% 49. half beat 3 end angle
% 50. half beat 3 duration
% 51. half beat 3 max angle segment 1
% 52. half beat 3 max angle segment 2
% 53. half beat 3 max angle segment 3
% 54. half beat 3 max angle segment 4
% 55. half beat 3 max angle segment 5
% 56. half beat 3 max angle segment 6
% 57. half beat 3 max angle segment 7
% 58. half beat 3 max segmental angular change (abs_motion_trace)
% 59. half beat 3 mean segmental angular change (abs_motion_trace)

for k = 1:size(bouts,1)
    
    this_trace = bout_traces{k};
    bout_start = bouts(k,2);
    bout_end = bouts(k,3);
    
    total_bout(1) = max(abs(diff(this_trace)));
    total_bout(2) = mean(abs(diff(this_trace)));
    total_bout(3) = max(abs(this_trace));
    total_bout(4) = this_trace(end);
    total_bout(5) = max(abs(all_thetas(1,bout_start:bout_end)));
    total_bout(6) = max(abs(all_thetas(2,bout_start:bout_end)));
    total_bout(7) = max(abs(all_thetas(3,bout_start:bout_end)));
    total_bout(8) = max(abs(all_thetas(4,bout_start:bout_end)));
    total_bout(9) = max(abs(all_thetas(5,bout_start:bout_end)));
    total_bout(10) = max(abs(all_thetas(6,bout_start:bout_end)));
    total_bout(11) = max(abs(all_thetas(7,bout_start:bout_end)));
    total_bout(12) = max(abs(abs_motion_trace(bout_start:bout_end)));
    total_bout(13) = mean(abs(abs_motion_trace(bout_start:bout_end)));
    total_bout(14) = bouts(k,4);
    
    %% Extract kinematic parameters from half beats
    
    half_beats = half_beats_sorted{1,k};
    half_beat_durations = half_beats(:,4);
    
    total_bout(15) = 1/min(half_beat_durations);
    total_bout(16) = mean(1./half_beat_durations);
    if mean(this_trace(half_beats(1,2):half_beats(2,3))) > 0
        total_bout(17) = 1;
    else
        total_bout(17) = 0;
    end
    
    % Handle cases where there are fewer than 3 half-beats
    if size(half_beats,1) < 3
        q = size(half_beats,1);
        half_beat_data(q+1:3,:) = NaN;
    else
        q = 3;
    end
    
    for l = 1:q
        
        this_beat_trace = this_trace(half_beats(l,2):half_beats(l,3));
        beat_start = half_beats(l,2) + bout_start;
        beat_end = half_beats(l,3) + bout_start;
        
        half_beat_data(l,1) = max(abs(diff(this_beat_trace)));
        half_beat_data(l,2) = mean(abs(diff(this_beat_trace)));
        half_beat_data(l,3) = max(abs(this_beat_trace));
        half_beat_data(l,4) = this_beat_trace(end);
        half_beat_data(l,5) = half_beats(l,4);
        half_beat_data(l,6) = max(abs(all_thetas(1,beat_start:beat_end)));
        half_beat_data(l,7) = max(abs(all_thetas(2,beat_start:beat_end)));
        half_beat_data(l,8) = max(abs(all_thetas(3,beat_start:beat_end)));
        half_beat_data(l,9) = max(abs(all_thetas(4,beat_start:beat_end)));
        half_beat_data(l,10) = max(abs(all_thetas(5,beat_start:beat_end)));
        half_beat_data(l,11) = max(abs(all_thetas(6,beat_start:beat_end)));
        half_beat_data(l,12) = max(abs(all_thetas(7,beat_start:beat_end)));
        if beat_end == size(all_thetas,2)  % abs_motion_trace cannot be indexed at final position of actual trace
            half_beat_data(1,13) = max(abs(abs_motion_trace(beat_start:beat_end-1)));
            half_beat_data(l,14) = mean(abs(abs_motion_trace(beat_start:beat_end-1)));
        else
            half_beat_data(l,13) = max(abs(abs_motion_trace(beat_start:beat_end)));
            half_beat_data(l,14) = mean(abs(abs_motion_trace(beat_start:beat_end)));
        end
        
        
    end
    
    half_beat_data_vect = reshape(half_beat_data',[1 42]);
    
    %% Organize data
    
    bout_data{1,k} = [total_bout,half_beat_data_vect];
    bout_data{2,k} = bout_traces{k};
    bout_data{3,k} = bout_start;  % Bout onset frames
    
end

