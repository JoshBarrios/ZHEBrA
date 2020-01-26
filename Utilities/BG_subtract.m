%% Josh Barrios 4/10/2019
% Fast background subtraction of behavior movies
% INPUTS:
% mov is a single precision 3D array, intended to be a movie of fish
% behavior.
% OUTPUTS:
% sub_pics is a background-subtracted version of mov

function sub_pics = BG_subtract(mov)

%% Detect GPU

GPU_bool = logical(sum(gpuDeviceCount));

%% calculate image size and get maximum GPU memory

if GPU_bool
    
    mov_size = size(mov,1)*size(mov,2)*size(mov,3)*4;
    
    gpu_info = gpuDevice;
    max_mem = gpu_info.AvailableMemory;
    
    %% Grab chunks, port to GPU, run frame subtraction, and gather diff trace
    num_chunks = ceil(mov_size/max_mem)*4;
    chunk_size = round(size(mov,3)/num_chunks);
    RFS_trace = zeros(1,(num_chunks-2)*chunk_size + chunk_size,'single');
    
    for k = 1:num_chunks-1
        chunk_inds = [(k-1)*chunk_size + 1 : (k-1)*chunk_size + chunk_size];
        chunk = gpuArray(mov(:,1:round((size(mov,1)/3)*2),chunk_inds));
        chunk = imgaussfilt(chunk,1);
        chunk = diff(chunk,2,3);
        chunk(:,:,end+1:end+2) = 0;
        RFS_trace(chunk_inds) = gather(squeeze(std(std(single(chunk),[],1),[],2)));
    end
    
else
    if size(mov,3) > 500
        frameEnd = 500;
    else
        frameEnd = size(mov,3);
    end
    smooth_mov = imgaussfilt(mov);
    RFS_mov = diff(smooth_mov(:,1:round((size(mov,1)/3)*2),1:frameEnd),2,3);
    RFS_trace = squeeze(std(std(single(RFS_mov),[],1),[],2));
end

%% Clean up RFS_trace, find frames with movement for min projecting
min_bout_length = 36; % Assumes frame rate of 500 fps
clean_trace = single(RFS_trace > prctile(RFS_trace,50));
seqs = findseq(clean_trace);
% Remove sequences of length < min_bout_length
for k = 1:size(seqs,1)
    
    if seqs(k,1) == 1 && seqs(k,4) < min_bout_length
        clean_trace(seqs(k,2):seqs(k,3)) = 0;
    end
     
end
% Remove singleton "sequences"
for k = 2:size(clean_trace,2) - 1
    
   if clean_trace(k-1) == 0 && clean_trace(k+1) == 0
       clean_trace(k) = 0;
   end
    
end
% Remove inter-bout-intervals < min_bout_length
in_bouts = findseq(clean_trace);
for k = 1:size(in_bouts,1)
    
    if in_bouts(k,1) == 0 && in_bouts(k,4) < min_bout_length
        clean_trace(in_bouts(k,2):in_bouts(k,3)) = 1;
    end
     
end

% Remove singleton inter-bout-intervals
for k = 2:size(clean_trace,2) - 1
    
   if clean_trace(k-1) == 1 && clean_trace(k+1) == 1
       clean_trace(k) = 1;
   end
    
end

%% Get target frame for bg subtraction and make min projection in a 100 frame window around it

if logical(sum(clean_trace))
    mov_traces = RFS_trace.*clean_trace;
    sub_frame = find(mov_traces == max(mov_traces));
    sub_frame = sub_frame(1);
else
    sub_frame = find(RFS_trace == max(RFS_trace));
    sub_frame = sub_frame(1);
end

if sub_frame < 51
    min_point = min(mov(:,:,1:sub_frame + 50),[],3);
else if sub_frame > size(mov,3) - 51
        min_point = min(mov(:,:,sub_frame - 50:size(mov,3)),[],3);
    else
        min_point = min(mov(:,:,sub_frame - 50:sub_frame + 50),[],3);
    end
end

%% Run background subtraction
sub_pics = zeros(size(mov),'single');
if GPU_bool
    for k = 1:num_chunks-1
        chunk_inds = [(k-1)*chunk_size + 1 : (k-1)*chunk_size + chunk_size];
        chunk = gpuArray(mov(:,:,chunk_inds));
        chunk = pagefun(@minus,chunk,min_point);
        chunk = imgaussfilt(chunk,4);
        sub_pics(:,:,chunk_inds) = gather(chunk);
    end
    clear chunk
    last_chunk_inds = [chunk_inds(end)+1:size(mov,3)];
    last_chunk = gpuArray(mov(:,:,last_chunk_inds));
    last_chunk = pagefun(@minus,last_chunk,min_point);
    last_chunk = imgaussfilt(last_chunk,4);
    sub_pics(:,:,last_chunk_inds) = gather(last_chunk);
else
    sub_pics = mov - min_point;
    sub_pics = imgaussfilt(sub_pics,4);
end
