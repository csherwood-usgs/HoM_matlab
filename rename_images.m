% rename_images - Rename the images
% This simplifies the names of the intrinsic calibration images
% Run this in a directory with COPIES of (a subset of) the images
D = dir('*.jpg')
for i=1:length(D)
    name_parts = split(D(i).name,'-');
    prefix = split(name_parts(1),'_');
    new_name = strcat(prefix(1),name_parts(4),'.jpg');
    status = movefile(D(i).name,new_name{1});
end