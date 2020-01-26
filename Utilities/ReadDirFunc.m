function pictures = ReadDirFunc(parent_path)
% path = uigetdir;
tic;
display('=====Reading in directory=====');

d = dir(parent_path);

for k = 1:length(d)
    if contains(d(k).name,'.tif')
        is_im(k) = 1;
    else
        is_im(k) = 0;
    end
end

im_inds = find(is_im);

num_images = length(im_inds);
    
pictures(:,:,1) = imread(fullfile(parent_path,d(im_inds(1)).name));
[pic_x,pic_y] = size(pictures(:,:,1));
pictures = zeros(pic_x,pic_y,num_images,'uint8');

parfor m = 1:num_images
    ind = im_inds(m);
        im_name = d(ind).name;
        fullname = fullfile(parent_path,im_name);
        pictures(:,:,m) = imread(fullname);
end    

pictures = uint8(pictures);

display(strcat('=====Finished reading directory_', num2str(toc),'s elapsed====='));