% animate_oblique_timex.m - Demo of a way to animage images
clear
close all
ppath = 'D:/USGS/CACO01/timex/'
c1files = dir([ppath,'*.c1.timex.jpg'])
c2files = dir([ppath,'*.c2.timex.jpg'])

% weights for conversion to grayscale
w = [0.2989 .5870 .1140];
% RGB code for yellow
yellow = [253/255, 184/255, 19/255];

%%
oname='CACO01_C1C2_';
% % OutPut Directory
odir= 'C:\crs\proj\2019_CACO_CoastCam\production'; % CRS
worldCoord='NAD83(2011) UTM Zone 19N (m)';
localOrigin = [ 410935  4655890]; % [ x y]
localAngle =[55]; % Degrees +CCW from Original World X

localFlagInput=1;
iz=0;
ixlim=[0 500];
iylim=[0 700];
idxdy=2;

ioeopath{1}= 'C:\crs\proj\2019_CACO_CoastCam\test_extrinsic\CACO01_C1_IOEOInitial.mat';
ioeopath{2}= 'C:\crs\proj\2019_CACO_CoastCam\test_extrinsic\CACO01_C2_IOEOInitial.mat';
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
    localExtrinsics{k} = localTransformExtrinsics(localOrigin,localAngle,1,extrinsics{k});
end

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
figure(1); clf

v = VideoWriter('testavi2.mp4','MPEG-4');
v.Quality = 95;
v.FrameRate = 5;
open(v)

% set inner loop counter to zero
k=0
% loop through some of the files
for i=1:length(c1files)
    % grab the unix time from the file name
    epoch_str = c1files(i).name(1:10);
    epoch = str2num(epoch_str);

    % convert unix time into a datenum
    dn=epoch2Matlab(epoch);
    datestr(dn);
    % UTC is five hours ahead of EST; make correction
    dn = dn-5./24.;
    
    % load the image
    have_both = 0
    im1 = imread( [ppath,c1files(i).name], 'jpg');
    try
        c2fn = [ppath,epoch_str,'.c2.timex.jpg']
        im2 = imread(c2fn, 'jpg');
        have_both = 1
    catch
        disp(['No match for ',epoch])
    end
    
    % convert to grayscale using one of the weight vectors above
    img = uint8(im1(:,:,1)*w(1) + im1(:,:,2)*w(2) + im1(:,:,3)*w(3));
    
    % average brightness
    a = mean(img(:))
    
    % estimate sharpness
    s = estimate_sharpness(double(img));
    
    if(a>50 && have_both) % don't plot dark images
        % increment frame counter
        k=k+1;
        
        I{1}=im1;
        I{2}=im2

        [localIr]= imageRectifier_CRS(I,intrinsics,localExtrinsics,localX,localY,localZ,1);

        % show the image

        % generate a text string
        ts = sprintf('%s EST\n%s\nAvg. = %.0f; Sharp. = %.1f',datestr(dn),c1files(i).name,a,s)
        % write text on the image (and grab the handle that is returned)
        h = text(.75,.9,ts,'units','normalized');
        % set the text color to yellow (or not)
        % set(h,'color',yellow);
        % drawnow command makes sure image is updated and shown
        drawnow
        frame=getframe(gcf);
        writeVideo(v,frame);
        % uncomment this if you are making a gif - makes a array of images
        %        M{k}=frame2im(frame);
        % pause long enough to see the image
        pause(.1)
    end
end
close(v)

% uncomment these to save the frames to a .gif file - but it gets big fast
% filename = 'testAnimated.gif'; % Specify the output file name
% for idx = 1:k
%     [A,map] = rgb2ind(M{idx},256);
%     if idx == 1
%         imwrite(A,map,filename,'gif','LoopCount',Inf,'DelayTime',.3);
%     else
%         imwrite(A,map,filename,'gif','WriteMode','append','DelayTime',.3);
%     end
% end



