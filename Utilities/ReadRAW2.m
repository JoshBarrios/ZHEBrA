% Josh Barrios 4/13/18
% This version of ReadRAW takes the size of the movie as inputs

function [im_data]=ReadRAW2(file_name,size_y,size_x,total_frames)
tic

% Use low-level File I/O to read the file
fp = fopen(file_name , 'rb');

% set offset to first image
slice = 1;
total_z_pos = 1;
first_offset = size_x*size_y*2*(slice-1);
ofds = zeros(1,total_frames);

%compute frame offsets
file_en = total_frames/total_z_pos;
im_data = cell(1,file_en);
for i = 1:file_en
    ofds(i) = first_offset+(i-1)*size_x*size_y*total_z_pos;
end

for cnt = 1:file_en
    fseek(fp,ofds(cnt),'bof');
    tmp1 = fread(fp, [size_x size_y], 'uint8', 0, 'ieee-le')';
    im_data{cnt} = cast(tmp1,'uint8');
end

im_data = cell2mat(im_data);
im_data = reshape(im_data,[size_y,size_x,file_en]);
fclose(fp);
im_data = uint8(im_data);

elapsedTime = toc;
display(strcat('========== Finished reading RAW image...',num2str(elapsedTime),' seconds elapsed =========='));
end