% pic_color - Starting to look at picture color
ppath = 'C:\crs\proj\2019_CACO_CoastCam\2019-12_products\'
cams = {'c1','c2'}  % The names of cameras at your station
prods = {'snap','timex','var','bright','dark'} % product types
% build the path, looking for only cameara one, snaps
p = strcat( ppath ,'*.', cams{1}, '.', prods{1}, '.jpg')
files = dir(p);

% for now, lets just look at one file
i=212
figure(3); clf
for i= 200:248
    % what time was it? Grab the unix time from the file name
    epoch = str2num(files(i).name(1:10));
    % convert unix time into a datenum
    dn=epoch2Matlab(epoch)
    datestr(dn)

    % load the image
    im = imread( [ppath,files(i).name] );

    % how big is that image?
%     size(im)

    % display the image
%     figure(1); clf
%     imagesc(im)

    % what is the average color?
    mrgb = mean(im,[1 2])

    % display a patch with the avearage color
    % (RGB values range from 0-255, but Matlab color triplets range from 0 - 1
%     figure(2); clf
%     patch([0 1 1 0],[0 0 1 1],mrgb/255)

    c = squeeze(mrgb/255)

    scatter(dn,mean(im,'all'),25,c','filled')
    hold on
end