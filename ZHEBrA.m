%% Josh Barrios 11/15/2019
% Zebrafish Head Embedded Behavior Analysis
% A generalized analysis workflow for head-embedded behavior data
% analysis. This workflow is for high-resolution, high speed images of
% head-embedded fish.

% Data prompts: Parent folder directory (should contain folders containing
% all images), data format (folder of many tifs, tif stack, or RAW), stim
% info (list of stim onset frames), image info (dark fish on light bg or
% light fish on dark bg, and fish orientation and head location)

close all
%% Get experiment info

% Get parent path
parent_path = uigetdir([],'Please select parent directory.');

% Get data type
answer = questdlg('How was the data saved?', ...
    'Data type', ...
    'Tif stack','Tif series','RAW','Tif series');
% Handle data type response
switch answer
    case 'Tif stack'
        disp(['====Analyzing tif stack===='])
        data_type = 1;
    case 'Tif series'
        disp(['====Analyzing tif series===='])
        data_type = 2;
    case 'RAW'
        disp('====Analyzing RAW====')
        data_type = 3;
        % Get RAW image dimensions
        prompt = {'Enter image size x dimension','Enter image size y dimension', 'Enter image size z dimension'};
        title1 = 'Input RAW image dimensions';
        dims = [1 35];
        def_input = {'360','400','30000'};
        answer2 = inputdlg(prompt,title1,dims,def_input);
        x_dim = str2double(answer2{1});
        y_dim = str2double(answer2{2});
        z_dim = str2double(answer2{3});
        clear prompt title dims def_input answer2
end
clear answer

%Get fish orientation
fish_or = questdlg('Which direction is the rostral end of the fish facing?', ...
    'Fish orientation', ...
    'Right','Down','Up','Right');

%Get background subtraction decision
BG_sub = questdlg('Do the images need background subtraction? (Low contrast images, usually 2p)', ...
    'Background subtraction', ...
    'Yes','No','Yes');

%Get head location
d = dir(parent_path);        %Get dir info for parent path (number of experiment folders)
for k = 3:length(d)
    [fish_n(k-2),plane_n,trial_n] = GetTrialInfo(fullfile(parent_path,d(k).name));
end

%fish_num_inds = findseq(fish_n);
fish_num_inds = [1,2,3,4,5,6,7,8]';
%Ask if all fish share the same head location and tail length
fish_con = questdlg('Do all fish share the same head location and tail length?', ...
    'Fish consistency', ...
    'Yes','No','Yes');

switch fish_con
    case 'Yes'
        
        first_ind = find(fish_num_inds(1,:));
        first_ind = first_ind(1);
        sub_path = d(first_ind+2).name;  %get name of sub folder for example image
        sub_dir = dir(fullfile(parent_path,sub_path));   %Get dir info for experiment folder
        num_subs = length(sub_dir);
        if data_type < 3
            for k = 1:num_subs
                if contains(sub_dir(k).name,'.tif')
                    im_inds(k) = 1;
                else
                    im_inds(k) = 0;
                end
            end
        else
            for k = 1:num_subs
                if contains(sub_dir(k).name,'.raw')
                    im_inds(k) = 1;
                else
                    im_inds(k) = 0;
                end
            end
        end
        im_ind = min(find(im_inds));
        
        switch data_type
            case 1
                im_path = fullfile(parent_path,sub_path,sub_dir(im_ind).name);
                mov = ReadTifFunc(im_path);
                im = mov(:,:,1);
                clear mov
            case 2
                im_path = fullfile(parent_path,sub_path,sub_dir(im_ind).name);
                mov = ReadTifFunc(im_path);
                im = mov(:,:,1);
                clear mov
            case 3
                im_path = fullfile(parent_path,sub_path,sub_dir(im_ind).name);
                mov=ReadRAW2(im_path,y_dim,x_dim,1);
                im = mov(:,:,1);
                clear mov
        end
        
        switch fish_or
            case 'Down'
                im = imrotate(im,90);
            case 'Up'
                im = imrotate(im,270);
        end
        
        imagesc(im);
        title('Please click once on caudal tip of swim bladder')
        [x,y] = ginput(1);
        hL = round([x,y]);
        head_loc = repmat(hL,[max(fish_n),1]);
        close
        
        imagesc(im);
        title('Please click once on the tip of the tail')
        [x,y] = ginput(1);
        tailLoc = round([x,y]);
        close
        
        % Calculate tail length
        tL = pdist([head_loc(1,:);tailLoc],'euclidean');
        tail_length = repmat(tL,[max(fish_n),1]);
        
        clear tailLoc x y im im_path im_inds im_ind d sub_dir sub_path num_subs
        
    case 'No'
        
        % For each fish, get an example image and ask the user for input
        all_fish_nums = fish_num_inds(:,1);
        for o = 1:length(all_fish_nums)
            fn = all_fish_nums(o);
            first_ind = find(fish_num_inds(:,1) == fn);
            %first_ind = fish_num_inds(first_ind(1),2);
            sub_path = d(first_ind+2).name;  %get name of sub folder for example image
            sub_dir = dir(fullfile(parent_path,sub_path));   %Get dir info for experiment folder
            num_subs = length(sub_dir);
            if data_type < 3
                for k = 1:num_subs
                    if contains(sub_dir(k).name,'.tif')
                        im_inds(k) = 1;
                    else
                        im_inds(k) = 0;
                    end
                end
            else
                for k = 1:num_subs
                    if contains(sub_dir(k).name,'.raw')
                        im_inds(k) = 1;
                    else
                        im_inds(k) = 0;
                    end
                end
            end
            im_ind = min(find(im_inds));
            
            switch data_type
                case 1
                    im_path = fullfile(parent_path,sub_path,sub_dir(im_ind).name);
                    mov = ReadTifFunc(im_path);
                    im = mov(:,:,1);
                    clear mov
                case 2
                    im_path = fullfile(parent_path,sub_path,sub_dir(im_ind).name);
                    mov = ReadTifFunc(im_path);
                    im = mov(:,:,1);
                    clear mov
                case 3
                    im_path = fullfile(parent_path,sub_path,sub_dir(im_ind).name);
                    mov=ReadRAW2(im_path,y_dim,x_dim,1);
                    im = mov(:,:,1);
                    clear mov
            end
            
            switch fish_or
                case 'Down'
                    im = imrotate(im,90);
                case 'Up'
                    im = imrotate(im,270);
            end
            
            imagesc(im);
            title('Please click once on caudal tip of swim bladder')
            [x,y] = ginput(1);
            head_loc(fn,:) = round([x,y]);
            close
            
            imagesc(im);
            title('Please click once on the tip of the tail')
            [x,y] = ginput(1);
            tailLoc = round([x,y]);
            close
            
            % Calculate tail length
            tail_length(fn) = pdist([head_loc(fn,:);tailLoc],'euclidean');
        end
        
        clear tailLoc x y im im_path im_inds im_ind d sub_dir sub_path num_subs
end

% Get illumination info

ill_info = questdlg('Light fish on dark background or dark fish on light background?', ...
    'Illumination info', ...
    'Light on Dark','Dark on Light','Light on Dark');

% Get stim info
prompt = {'Enter all stim onset frames, separated by spaces'};
title1 = 'Stim info';
dims = [1 50];
answer3 = inputdlg(prompt,title1,dims);
stim_frames = str2num(answer3{1});
clear answer3 title prompt dims

% Get genotype info
prompt = {'Enter any important notes to pull from folder names, separated by spaces. Must be exactly as is in folder names.'};
title1 = 'Genotype or trial type info';
dims = [1 70];
def_input = {'genotype or trial type'};
answer4 = inputdlg(prompt,title1,dims);
notes = strsplit(answer4{:});
clear def_input dims prompt title answer4

% Run clustering?
clust = questdlg('Would you like to run clustering analysis on these behaviors?', ...
    'Clustering?', ...
    'K-means','Cluster-dv','No clustering','No clustering');

%% Run Find_Tail on all movies and save trckPts and theta_sum

d = dir(parent_path);        %Get dir info for parent path

num_subs = length(d);

for ku = 3:num_subs
    
    %     try
    sub_path = d(ku).name;  %get name of sub folder for analysis
    sub_dir = dir(fullfile(parent_path,sub_path));   %Get dir info for experiment folder
    display(strcat('Analyzing...',sub_path));
    
    % Read in movie
    
    if data_type < 3
        for k = 1:length(sub_dir)
            if contains(sub_dir(k).name,'.tif')
                im_inds(k) = 1;
            else
                im_inds(k) = 0;
            end
        end
    else
        for k = 1:length(sub_dir)
            if contains(sub_dir(k).name,'.raw')
                im_inds(k) = 1;
            else
                im_inds(k) = 0;
            end
        end
    end
    im_ind = min(find(im_inds));
    switch data_type
        case 2
            im_path = fullfile(parent_path,sub_path);
            mov = ReadDirFunc(im_path);
            display(strcat('Finished Reading...',sub_path));
        case 1
            im_path = fullfile(parent_path,sub_path,sub_dir(im_ind).name);
            mov = ReadTifFunc(im_path);
            display(strcat('Finished Reading...',sub_path));
        case 3
            im_path = fullfile(parent_path,sub_path,sub_dir(im_ind).name);
            mov=ReadRAW2(im_path,y_dim,x_dim,z_dim);
            display(strcat('Finished Reading...',sub_path));
    end
    
    % Prep movie for FindTail based on answers above
    
    if ill_info == 'Dark on Light'
        mov = imcomplement(mov);
    end
    
    switch fish_or
        case 'Down'
            mov = imrotate(mov,90);
        case 'Up'
            mov = imrotate(mov,270);
    end
    
    % Get trial data for "bhav_data" array
    [fish_num,plane_num,trial_num] = GetTrialInfo(sub_path);
    
    % Pull out appropriate head_loc and tail_length
    
    head_loc_n = head_loc(fish_num,:);
    tail_length_n = tail_length(fish_num);
    
    % Run FindTail and save results
    
    [trck_pts_all,theta_sum] = FindTail(mov,head_loc_n,tail_length_n,BG_sub);
    
    save(fullfile(parent_path,sub_path,'trckPts.mat'),'trck_pts_all');
    save(fullfile(parent_path,sub_path,'theta_sum.mat'),'theta_sum');
    
    % Get notes data for "bhav_data" array
    for l = 1:length(notes)
        if contains(sub_path,notes{l})
            bhav_data(ku-2).notes = notes{l};
        end
    end
    
    % Run BoutExtractor
    BoutExtractor;
    
    % Save BoutExtractor Results
    efigName = get(fig_handle, 'Name');
    savefig(fig_handle, fullfile(parent_path, sub_path, 'bout_extractor_results.fig'));
    
    % Build "bhav_data" structure array
    bhav_data(ku-2).fish_num = fish_num;
    bhav_data(ku-2).plane_num = plane_num;
    bhav_data(ku-2).trial_num = trial_num;
    bhav_data(ku-2).trackPts = trck_pts_all;
    
    
    if ~isempty(bouts)
        bhav_data(ku-2).bout_data = bout_data;
        bhav_data(ku-2).onset_frames = bout_data{3,:};
        % bhav_data(ku-2).bhavTypes = ;
    else
        bhav_data(ku-2).bout_data = [];
        bhav_data(ku-2).onset_frames = [];
        % bhav_data(ku-2).bhavTypes = [];
    end
    
    bhav_data(ku-2).stim_frames = stim_frames;
    
    clearvars -except parent_path data_type fish_or head_loc tail_length ill_info d num_subs bhav_data stim_frames bouts notes fish_num_inds BG_sub clust
    
end

clearvars -except bhav_data clust

%% Run behavior clustering

switch clust
    
    case 'K-means'
        %%
        BuildDataForClustering;
        data = abs(data);
        
        % Run PCA
        [coeff,score,latent,tsquared,explained,mu] = pca(data);
        PC_data = score(:,1:3);
        
        % Determine optimal number of clusters
        for k = 1:6
            test_clust(:,k) = kmeans(PC_data,k);
        end
        
        eva = evalclusters(PC_data,test_clust,'DaviesBouldin');
        
        clusters = kmeans(PC_data,eva.OptimalK);
        clearvars -except bhav_data clusters
        num_clusters = max(clusters);
        
        % Add cluster assignments to bhav_data
        ind = 1;
        for k = 1:length(bhav_data)
            if ~isempty(bhav_data(k).bout_data)
                num_bouts = size(bhav_data(k).bout_data,2);
                these_bouts = clusters(ind:ind - 1 + num_bouts);
                bhav_data(k).cluster_ID = these_bouts;
                ind = ind+num_bouts;
            end
        end
        clearvars -except bhav_data num_clusters
        
        % Plot traces of each cluster
        
        PlotBehaviorClusterTypes;
        clearvars -except bhav_data
        
    case 'Cluster-dv'
        %%
        BuildDataForClustering;
        %         data = abs(data);
        
        % Run PCA
        [coeff,score,latent,tsquared,explained,mu] = pca(data);
        data = score(:,1:3);
        
        clusterDv_2;
        close all
        
        clusters = cluster_assignment_all;
        clearvars -except bhav_data clusters
        num_clusters = max(clusters);
        
        % Add cluster assignments to bhav_data
        ind = 1;
        for k = 1:length(bhav_data)
            if ~isempty(bhav_data(k).bout_data)
                num_bouts = size(bhav_data(k).bout_data,2);
                these_bouts = clusters(ind:ind - 1 + num_bouts);
                bhav_data(k).cluster_ID = these_bouts;
                ind = ind+num_bouts;
            end
        end
        clearvars -except bhav_data num_clusters
        
        % Plot traces of each cluster
        
        PlotBehaviorClusterTypes;
        clearvars -except bhav_data
end














