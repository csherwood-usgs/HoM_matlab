% rectify_one - Rectify one pair of images
clear
close all
ppath = './'
c1file = '1581508801.c1.timex.jpg'
c2file = '1581508801.c2.timex.jpg'
% weights for conversion to grayscale
w = [0.2989 .5870 .1140];
% RGB code for yellow
yellow = [253/255, 184/255, 19/255];

%%
% Origin of local coord system
worldCoord='NAD83(2011) UTM Zone 19N (m)';
localOrigin = [ 410935  4655890]; % [ x y]
localAngle =[55]; % Degrees +CCW from Original World X

localFlagInput=1;
iz=0;
ixlim=[0 500];
iylim=[0 700];
idxdy=2;

ioeopath{1}= 'CACO01_C1_IOEOBest.mat';
ioeopath{2}= 'CACO01_C2_IOEOBest.mat';
for k=1:length(ioeopath)
    % Load Solution from C_singleExtrinsicSolution
    load(ioeopath{k})
    % Save IOEO into larger structure
    % Take First Solution (Can be altered if non-first frame imagery desired
    Extrinsics{k}=extrinsics(1,:);
    Intrinsics{k}=intrinsics;
end

% Rename IEEO to original EOIO name so names consistent
extrinsics=Extrinsics;
intrinsics=Intrinsics;
% load and assign extrinsics
for k=1:length(ioeopath)
    %  World Extrinsics
    extrinsics{k}=extrinsics{k};
    %  Local Extrinsics
    localExtrinsics{k} = localTransformExtrinsics(localOrigin,localAngle,1,extrinsics{k})
end
disp(extrinsics{1})
disp(localExtrinsics{1})
%%
%  Create Equidistant Input Grid
[iX iY]=meshgrid([ixlim(1):idxdy:ixlim(2)],[iylim(1):idxdy:iylim(2)]);

%  Make Elevation Input Grid
iZ=iX*0+iz;

%  Assign Input Grid to Wolrd/Local, and rotate accordingly depending on
%  inputLocalFlag

% If World Entered
if localFlagInput==0
    % Assign World Grid as Input Grid
    X=iX;
    Y=iY;
    Z=iZ;
    
    % Assign local Grid as Rotated input Grid
    [ localX localY]=localTransformEquiGrid(localOrigin,localAngle,1,iX,iY);
    localZ=localX.*0+iz;
end

% If entered as Local
if localFlagInput==1
    % Assign local Grid as Input Grid
    localX=iX;
    localY=iY;
    localZ=iZ;
    
    % Assign world Grid as Rotated local Grid
    [ X Y]=localTransformEquiGrid(localOrigin,localAngle,0,iX,iY);
    Z=X*.0+iz;
end
%%
% grab the unix time from the file name
epoch_str = c1file(1:10);
epoch = str2num(epoch_str);

% convert unix time into a datenum
dn=epoch2Matlab(epoch);
datestr(dn)
% load the image
have_both = 0;
im1 = imread( [ppath,c1file], 'jpg');

% convert to grayscale using the weight vectors above
img = uint8(im1(:,:,1)*w(1) + im1(:,:,2)*w(2) + im1(:,:,3)*w(3));

% average brightness
a = mean(img(:));

% estimate sharpness
s = estimate_sharpness(double(img));

im2 = imread(c2file, 'jpg');

I{1}=im1;
I{2}=im2;

% show the image
[localIr]= imageRectifier_CRS(I,intrinsics,localExtrinsics,localX,localY,localZ,1);

% make this a convenient size for digitizing - but keep the correct
% width/height ratio
truesize(gcf,[500, 700])

