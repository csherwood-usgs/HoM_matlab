% averageall - Average all of the images in a specified directory

clear
% weights used to convert RGB to grayscale
% https://www.mathworks.com/matlabcentral/answers/99136-how-do-i-convert-my-rgb-image-to-grayscale-without-using-the-image-processing-toolbox
w = [0.2989 .5870 .1140]

ppath = 'C:\crs\proj\2019_CACO_CoastCam\2020-03-04_HoM_Survey\alltimex_C1\'
p = strcat( ppath ,'*.jpg')
files = dir(p);
nfiles = length(files)

% read one file to get image size
im = imread( [ppath,files(1).name] );
sz = size(im);

% make a zero matrix that is the size of the image
ima = uint8(zeros(sz(1:2)));

for i = 1:nfiles
    im = imread( [ppath,files(i).name] );
    ima = ima + uint8((im(:,:,1)*w(1) + im(:,:,2)*w(2) + im(:,:,3)*w(3))/nfiles);
end

figure(1); clf
imagesc(ima)
colormap(gray)
colorbar

% write the image to the same directory (delete it before running again!)
imwrite(ima, [ppath,ppath(end-2:end-1),'avg.jpg'])




