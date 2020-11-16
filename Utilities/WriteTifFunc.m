function WriteTifFunc(stack,path,file_name)

imwrite(uint16(stack(:,:,1)), fullfile(path,file_name));

for k = 2:size(stack,3)
    imwrite(uint16(stack(:,:,k)), fullfile(path,file_name), 'writemode', 'append');
end