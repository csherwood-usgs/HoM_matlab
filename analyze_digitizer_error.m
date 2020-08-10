% analyze_digitizer_error - Demo of a way to evaluate digitizer error
clear
close all
% path to where I have put all of the timex images
ppath = 'D:/USGS/CACO01/timex/'
c1files = dir([ppath,'*.c1.timex.jpg'])
c2files = dir([ppath,'*.c2.timex.jpg'])

%%
% oname='CACO01_C1C2_';
% % % OutPut Directory
% odir= 'C:\crs\proj\2019_CACO_CoastCam\production'; % CRS

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
C= {};
% select a file 
i=1

% load the images
im1 = imread( [ppath,c1files(i).name], 'jpg');
% need to use the time to find matching image...the index doesn't work
epoch_str = c1files(i).name(1:10);
try
    c2fn = [ppath,epoch_str,'.c2.timex.jpg']
    im2 = imread(c2fn, 'jpg');
    have_both = 1
catch
    disp(['No match for ',epoch])
end

I{1}=im1;
I{2}=im2;

% show the image
[localIr]= imageRectifier_CRS(I,intrinsics,localExtrinsics,localX,localY,localZ,1);

% make this a convenient size for digitizing - but keep the correct
% width/height ratio
truesize(gcf,[500, 700])

% Digitize the coastline location by clicking, starting at north and
% working south
% finish w/ Enter
% can also skip pic without digitizing by hitting Enter
for jj=1:3
    coastline = ginput;
    C{jj} = coastline;
end

%% plot digitized data
figure(2); clf
% plot the shorelines
for i = 1:length(C)
    A = C{i};
    plot(A(:,1),A(:,2),'-')
    xlim([0, 200])
    ylim([0, 700])
    hold on
end
xlabel('Cross-shore distance (m)')
ylabel('Alongshore distance (m)')
title('Digitized Coastlines')
print('digitized_shorelines.png','-dpng')
%% interpolate in alongshore direction
yi = 60:2:400;
xi = NaN*ones(length(C),length(yi));
figure(3); clf
for i = 1:length(C)
    A=C{i};
    xi(i,:) = interp1(A(:,2),A(:,1),yi,'spline');
end

% average shoreline location
anom = xi - mean(xi);
anom_sd = std(anom);
sd_all = std(anom(:))

ts = sprintf('MAD:  %.2f\nstd:   %.2f\nMax:  %.2f',mean(abs(anom(:))),std(anom(:)),max(abs(anom(:))))

figure(3); clf
cmap = parula(length(C));
for i = 1:length(C)
    plot(anom(i,:),yi,'-','linewidth',2,'color',cmap(i,:))
    hold on
end
xlim([-10 10])
text(.1,.85,ts,'units','normalized')

xlabel('Cross-shore distance (m)')
ylabel('Alongshore distance (m)')
title('Interpolated Shoreline Anomaly')
print('shoreline_anomaly.png','-dpng')
