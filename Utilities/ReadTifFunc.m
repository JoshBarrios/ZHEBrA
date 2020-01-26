function mov = ReadTifFunc(path)

info = imfinfo(path);
num_images = numel(info);
width = info.Width;
height = info.Height;

% mov = singlezeros(height,width,num_images);
for k = 1:num_images
    mov(:,:,k) = imread(path,'tif',k,'Info',info);
end

mov = uint8(mov);