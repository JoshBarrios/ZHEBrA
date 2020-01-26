%% Josh Barrios 9/19/18
% Collates data from all swim bouts from behaviorData cell arrays into a
% matrix for clustering analyses

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
% 11. max angle 7
% 12. max segmental angular change (mTrace)
% 13. mean segmental angular change (mTrace)
% 14. bout duration (frames)

% ------------half beat kinematic parameters-------------

% 15. Max bout frequency (frequency of half-beats (1/frames))
% 16. Mean bout frequency (frequency of half-beats (1/frames))

% 17. half beat 1 max velocity
% 18. half beat 1 mean velocity
% 19. half beat 1 max angle (C1 angle)
% 20. half beat 1 end angle
% 21. half beat 1 duration
% 22. half beat 1 max angle segment 1
% 23. half beat 1 max angle segment 2
% 24. half beat 1 max angle segment 3
% 25. half beat 1 max angle segment 4
% 26. half beat 1 max angle segment 5
% 27. half beat 1 max angle segment 6
% 28. half beat 1 max angle segment 7
% 29. half beat 1 max segmental angular change (mTrace)
% 30. half beat 1 mean segmental angular change (mTrace)

% 31. half beat 2 max velocity
% 32. half beat 2 mean velocity
% 33. half beat 2 max angle (C2 angle)
% 34. half beat 2 end angle
% 35. half beat 2 duration
% 36. half beat 2 max angle segment 1
% 37. half beat 2 max angle segment 2
% 38. half beat 2 max angle segment 3
% 39. half beat 2 max angle segment 4
% 40. half beat 2 max angle segment 5
% 41. half beat 2 max angle segment 6
% 42. half beat 2 max angle segment 7
% 43. half beat 2 max segmental angular change (mTrace)
% 44. half beat 2 mean segmental angular change (mTrace)

% 45. half beat 3 max velocity
% 46. half beat 3 mean velocity
% 47. half beat 3 max angle
% 48. half beat 3 end angle
% 49. half beat 3 duration
% 50. half beat 3 max angle segment 1
% 51. half beat 3 max angle segment 2
% 52. half beat 3 max angle segment 3
% 53. half beat 3 max angle segment 4
% 54. half beat 3 max angle segment 5
% 55. half beat 3 max angle segment 6
% 56. half beat 3 max angle segment 7
% 57. half beat 3 max segmental angular change (mTrace)
% 58. half beat 3 mean segmental angular change (mTrace)

data = [];
for k = 1:size(bhav_data,2)
    if ~isempty(bhav_data(k).bout_data)
        bouts = bhav_data(k).bout_data;
        for l = 1:size(bouts,2)
            this_bout = bouts(:,l);
            this_boutMat = cell2mat(this_bout(1,1));
            data = cat(1,data,this_boutMat);
        end
        test_bool(k) = 1;
        test(k) = size(bouts,2);
    else
        test_bool(k) = 0;
        test(k) = 0;
    end
end
data = double(data);



