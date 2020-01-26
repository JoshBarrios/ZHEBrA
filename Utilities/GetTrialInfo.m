%% Josh Barrios 12/10/2018
% Extracts fish number, plane number, and trial number from folder name.

function [fish_num,plane_num,trial_num] = GetTrialInfo(sub_path)

folders = split(sub_path,"\");

sub_path = folders{end};

% Find fish_num
if contains(sub_path,'Fish')
    fish_ind = strfind(sub_path,'Fish');
    if fish_ind + 5 > length(sub_path)
        fish_num = str2num(sub_path(fish_ind + 4));
    else 
        fish_num = findNum(sub_path(fish_ind + 4:end));
    end
    
else contains(sub_path,'F');
    fish_ind = strfind(sub_path,'F');
    if ~isempty(fish_ind)
        fish_ind = fish_ind(end);
    end
    if fish_ind + 2 > length(sub_path)
        fish_num = str2num(sub_path(fish_ind + 1));
    else 
        fish_num = findNum(sub_path(fish_ind + 1:end));
    end
end

% Find plane_num
if contains(sub_path,'Plane')
    plane_ind = strfind(sub_path,'Plane');
    if plane_ind + 6 > length(sub_path)
        plane_num = str2num(sub_path(plane_ind + 5));
    else 
        plane_num = findNum(sub_path(plane_ind + 5:end));
    end
    
else contains(sub_path,'P');
    plane_ind = strfind(sub_path,'P');
    if ~isempty(plane_ind)
        plane_ind = plane_ind(end);
    end
    if plane_ind + 2 > length(sub_path)
        plane_num = str2num(sub_path(plane_ind + 1));
    else 
        plane_num = findNum(sub_path(plane_ind + 1:end));
    end
end



% Find trial_num
if contains(sub_path,'Trial')
    trial_ind = strfind(sub_path,'Trial');
    if trial_ind + 6 > length(sub_path)
        trial_num = str2num(sub_path(trial_ind + 5));
    else 
        trial_num = findNum(sub_path(trial_ind + 5:end));
    end
    
else contains(sub_path,'T');
    trial_ind = strfind(sub_path,'T');
    if ~isempty(trial_ind)
        trial_ind = trial_ind(end);
    end
    if trial_ind + 2 > length(sub_path)
        trial_num = str2num(sub_path(trial_ind + 1));
    else 
        trial_num = findNum(sub_path(trial_ind + 1:end));
    end
end

if isempty(fish_num)
    fish_num = NaN;
end
if isempty(plane_num)
    plane_num = NaN;
end
if isempty(trial_num)
    trial_num = NaN;
end

