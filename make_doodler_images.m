% make_doodler_images.m - Make recified images with no annotation.
clear
close all
% path to where I have put all of the timex images
ppath = 'D:/USGS/CACO01/timex/'
c1files = dir([ppath,'*.c1.timex.jpg'])
c2files = dir([ppath,'*.c2.timex.jpg'])

% weights for conversion to grayscale
w = [0.2989 .5870 .1140];
% RGB code for yellow
yellow = [253/255, 184/255, 19/255];

%load wave data (dnwave and wavedata)
% column numbers in wavedata
% 1   2     3     4     5     6   7     8     9     10    11
%WDIR WSPD GST  WVHT   DPD   APD MWD   PRES  ATMP  WTMP  DEWP
%degT m/s  m/s     m   sec   sec degT   hPa  degC  degC  degC
load 44018.mat

%load tide data (lat, lon, T, tid)
load HoM_tides.mat
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
%% Loop through all of the files and make list of those that meet criteria
% this takes a while, so think about the criteria you want
% set list count to zero
k=0;
% arrays that will hold some useful data
ilist = [];
tlist = [];
Hslist = [];
slist = [];
alist = [];
% loop through the files, check criteria
for i=1:length(c1files)
    % grab the unix time from the file name
    epoch_str = c1files(i).name(1:10);
    epoch = str2num(epoch_str);
    
    % convert unix time into a datenum
    dn(i)=epoch2Matlab(epoch);
    datestr(dn(i))
    % load the image
    have_both = 0;
    im1 = imread( [ppath,c1files(i).name], 'jpg');
    try
        c2fn = [ppath,epoch_str,'.c2.timex.jpg']
        im2 = imread(c2fn, 'jpg');
        have_both = 1;
    catch
        fprintf(1,'No match for %s',epoch)
    end
    
    % convert to grayscale using the weight vectors above
    img = uint8(im1(:,:,1)*w(1) + im1(:,:,2)*w(2) + im1(:,:,3)*w(3));
    
    % average brightness
    a = mean(img(:));
    
    % estimate sharpness
    s = estimate_sharpness(double(img));
    
    % get interpolated tide and waves
    tide = interp1(T,tid,dn(i));
    % met and wave data
    met = interp1(dnwave,wavedata,dn(i));
    Hs = met(4);
    Td = met(5);
    Wdir = met(7);
    
    % add image to list if meets criteria
    if(a>40 && s>0.8 && have_both && tide > 1.2)
        k=k+1
        ilist(k)=i;     % list of indexes in file directory
        tlist(k)=tide; 
        Hslist(k)=Hs;
        slist(k)=s;
        alist(k)=a;
    end
end
%%
% plot the data for times with images
figure(1); clf
plot(dn(ilist),Hslist,'.')
hold on
plot(dn(ilist),tlist,'.')
datetick('x')
%%
jj = 0;
C= {};
dnc = [];
% loop through the selected files and find highest tide in every 20 files
for i=1:20:k
    jj=jj+1;
    % find the highest tide
    ilast = min(i+19,k);  % (prevent trying to read past entries in tlist)
    [M,j]=max(tlist(i:ilast));
    fprintf(1,'j=%d, tide = %.1f\n',j,M)
    kk = ilist((i+j-1))
    
    % load the images
    im1 = imread( [ppath,c1files(kk).name], 'jpg');
    % need to use the time to find matching image...the index doesn't work
    epoch_str = c1files(kk).name(1:10);
    try
        c2fn = [ppath,epoch_str,'.c2.timex.jpg']
        im2 = imread(c2fn, 'jpg');
        have_both = 1
    catch
        disp(['No match for ',epoch])
    end
       
    I{1}=im1;
    I{2}=im2;
    
    datm = datestr(dn(kk),'YYYYMMDD_HHmm');
    plotName = sprintf('%s_%.0f_%.0f.tif',datm,10*M,10*Hslist(i+j-1))
    % show the image
    [localIr]= imageRectifier_CRS_plain_plot(I,intrinsics,localExtrinsics,localX,localY,localZ,1,plotName);
    
    % make this a convenient size for digitizing - but keep the correct
    % width/height ratio
    truesize(gcf,[500, 700])
    
    % Digitize the coastline location by clicking, starting at north and
    % working south
    % finish w/ Enter
    % can also skip pic without digitizing by hitting Enter
    coastline = ginput;
    C{jj} = coastline;
    dnc(jj)=dn(kk);
    
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

figure(3); clf
plot([110 160],[320 320],'--','color',[.7 .7 .7])
hold on
plot([110 160],[240 240],'--','color',[.7 .7 .7])
plot([110 160],[160 160],'--','color',[.7 .7 .7])
plot([110 160],[80 80],'--','color',[.7 .7 .7])

cmap = parula(length(C));
for i = 1:length(C)
    plot(xi(i,:),yi,'-','linewidth',2,'color',cmap(i,:))
    hold on
end
xlim([110 160])
h=colorbar;
h.Ticks = [0 1];
s1 = datestr(dnc(1),1)
s2 = datestr(dnc(length(C)),1)
h.TickLabels = [s1; s2]
xlabel('Cross-shore distance (m)')
ylabel('Alongshore distance (m)')
title('Interpolated Shorelines')
print('smoothed_shorelines.png','-dpng')
%% plot cross-shore shoreline location as a function of time
figure(4); clf
subplot(411)
i = find(yi==320);
plot(dnc,xi(:,i))
hold
plot(dnc,xi(:,i),'o')
grid on
ylim([120 160])
set(gca,'xticklabels',[])
text(.03,.9,'y=320','units','normalized');
title('Shoreline Position Over Time')

subplot(412)
i = find(yi==240);
plot(dnc,xi(:,i))
ylim([120 160])
set(gca,'xticklabels',[])
ylabel('Cross-shore Location (m)')
text(.03,.9,'y=240','units','normalized');

subplot(413)
i = find(yi==160);
plot(dnc,xi(:,i))
ylim([120 160])
set(gca,'xticklabels',[])
text(.03,.9,'y=160','units','normalized');

subplot(414)
i = find(yi==80);
plot(dnc,xi(:,i))
ylim([120 160])
text(.03,.9,'y=180','units','normalized');
datetick('x',6,'keeplimits','keepticks')
print('shoreline_time_series.png','-dpng')

