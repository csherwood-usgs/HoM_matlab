% pic_sharpness - Test the sharpness function
ppath = 'C:\crs\proj\2019_CACO_CoastCam\2019-12_products\'
cams = {'c1','c2'}  % The names of cameras at your station
prods = {'snap','timex','var','bright','dark'} % product types
% build the path, looking for only cameara one, snaps
p = strcat( ppath ,'*.', cams{1}, '.', prods{1}, '.jpg')
files = dir(p);

% Conversion from grayscale to color is simply combining the RGB values
% The simplest is to just average them, so the weights are each 1/3
avg = [.33 .33 .33]
% Grayscale luminosity ratio
% However, you can give them different weights, and some sources suggest
% these because they match our eyes perception.
% https://www.johndcook.com/blog/2009/08/24/algorithms-convert-color-grayscale/
lumin = [.21 .72 .07]
% https://www.tutorialspoint.com/dip/grayscale_to_rgb_conversion.htm
lumin2 = [.3 .59 .11]
% https://www.mathworks.com/matlabcentral/answers/99136-how-do-i-convert-my-rgb-image-to-grayscale-without-using-the-image-processing-toolbox
ntsc = [0.2989 .5870 .1140]

% use the switch command to choose one of the sets of weights
% change this to select weights:
which_weights='ntsc'
switch which_weights
    case 'avg'
        w = avg;
    case 'lumin'
        w = lumin;
    case 'lumin2'
        w = lumin2;
    case 'ntsc'
        w = ntsc;
    otherwise
        disp('No valid choice of weights')
end

%loop through some photos
for i= 200:248
    % what time was it? Grab the unix time from the file name
    epoch = str2num(files(i).name(1:10));
    % convert unix time into a datenum
    dn=epoch2Matlab(epoch)
    datestr(dn)

    % load the image
    im = imread( [ppath,files(i).name] );

    % display the image
    figure(1); clf
    imagesc(im)
    % convert to grayscale using one of the weight vectors above
    img = uint8(im(:,:,1)*w(1) + im(:,:,2)*w(2) + im(:,:,3)*w(3));
    
    % plot the grayscale images
    figure(2)
    imagesc(img)
    colormap(gray)
    
    % estimate the sharpness and write on image
    % surprisingly, the Matlab gradient function does not work for
    % integers, so I am casting the whole array as a real number (double
    % precision) before passing it to the estimate sharpness function
    s = estimate_sharpness(double(img));
    
    % use the sprintf function and formating to make a text string
    ts = sprintf('%s sharpness = %.3f',datestr(dn),s)
    % display it on the figure
    text( 150,100,ts)

    pause
end